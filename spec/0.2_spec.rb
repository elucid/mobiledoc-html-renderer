require 'spec_helper'
require 'mobiledoc_html_renderer/utils/section_types'
require 'mobiledoc_html_renderer/cards/image'

# NOTE: I would like this to be scoped to the describe block but
# doing so does not make the section type constants available to
# examples
include Mobiledoc::Utils::SectionTypes

describe Mobiledoc::HTMLRenderer do
  MOBILEDOC_VERSION = '0.2.0'

  def render(mobiledoc)
    described_class.new.render(mobiledoc)
  end

  let(:data_uri) { "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACwAAAAAAQABAAACAkQBADs=" }

  it 'renders an empty mobiledoc' do
    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        []  # sections
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to eq('<div></div>')
  end

  it 'renders a mobiledoc without markups' do
    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [
          [MARKUP_SECTION_TYPE, 'P', [
            [[], 0, 'hello world']]
          ]
        ]  # sections
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to eq('<div><p>hello world</p></div>')
  end

  it 'renders a mobiledoc with simple (no attributes) markup' do
    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [ # markers
          ['B'],
        ],
        [ # sections
          [MARKUP_SECTION_TYPE, 'P', [
            [[0], 1, 'hello world']]
          ]
        ]
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to eq('<div><p><b>hello world</b></p></div>')
  end

  it 'renders a mobiledoc with complex (has attributes) markup' do
    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [ # markers
          ['A', ['href', 'http://google.com']],
        ],
        [ # sections
          [MARKUP_SECTION_TYPE, 'P', [
            [[0], 1, 'hello world']
          ]]
        ]
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to eq('<div><p><a href="http://google.com">hello world</a></p></div>')
  end

  it 'renders a mobiledoc with multiple markups in a section' do
    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [ # markers
          ['B'],
          ['I']
        ],
        [ # sections
          [MARKUP_SECTION_TYPE, 'P', [
            [[0], 0, 'hello '], # b
            [[1], 0, 'brave '], # b + i
            [[], 1, 'new '], # close i
            [[], 1, 'world'] # close b
          ]]
        ]
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to eq('<div><p><b>hello <i>brave new </i>world</b></p></div>')
  end

  it 'renders a mobiledoc with image section' do
    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [IMAGE_SECTION_TYPE, data_uri]
        ]
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to eq(%Q[<div><img src="#{data_uri}"></div>])
  end

  it 'renders a mobiledoc with built-in image card' do
    card_name = Mobiledoc::ImageCard.name

    payload = { 'src' => data_uri }

    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [CARD_SECTION_TYPE, card_name, payload]
        ]
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to eq(%Q[<div><div><img src="#{data_uri}"></div></div>])
  end

  it 'render mobiledoc with list section and list items' do
    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [LIST_SECTION_TYPE, 'ul', [
            [[[], 0, 'first item']],
            [[[], 0, 'second item']]
          ]]
        ]
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to eq('<div><ul><li>first item</li><li>second item</li></ul></div>')
  end

  it 'renders a mobiledoc with card section' do
    card_name = 'title-card'
    expected_payload = {}
    expected_options = {}

    title_card = Module.new do
      module_function

      def name
        'title-card'
      end

      def type
        'html'
      end

      def render(env, payload, options)
      end
    end

    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [CARD_SECTION_TYPE, card_name, expected_payload]
        ]
      ]
    }

    expect(title_card).to receive(:render).with({name: card_name}, expected_payload, expected_options).and_return("Howdy friend")

    renderer = Mobiledoc::HTMLRenderer.new(cards: [title_card], card_options: expected_options)
    rendered = renderer.render(mobiledoc)

    expect(rendered).to eq('<div><div>Howdy friend</div></div>')
  end

  it 'throws when given invalid card type' do
    bad_card = Module.new do
      module_function

      def name
        'bad'
      end

      def type
        'other'
      end

      def render(env, payload, options)
      end
    end

    expect{ Mobiledoc::HTMLRenderer.new(cards: [bad_card]) }.to raise_error(%Q[Card "bad" must be of type "html", was "other"])
  end

  it 'throws when given card without `render`' do
    bad_card = Module.new do
      module_function

      def name
        'bad'
      end

      def type
        'html'
      end
    end

    expect{ Mobiledoc::HTMLRenderer.new(cards: [bad_card]) }.to raise_error(%Q[Card "bad" must define `render`])
  end

  it 'throws if card render returns invalid result' do
    bad_card = Module.new do
      module_function

      def name
        'bad'
      end

      def type
        'html'
      end

      def render(env, payload, options)
        Object.new
      end
    end

    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [CARD_SECTION_TYPE, 'bad']
        ]
      ]
    }

    renderer = Mobiledoc::HTMLRenderer.new(cards: [bad_card])

    expect{ renderer.render(mobiledoc) }.to raise_error(/Card "bad" must render html/)
  end

  it 'card may render nothing' do
    card = Module.new do
      module_function

      def name
        'ok'
      end

      def type
        'html'
      end

      def render(env, payload, options)
      end
    end

    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [CARD_SECTION_TYPE, 'ok']
        ]
      ]
    }

    renderer = Mobiledoc::HTMLRenderer.new(cards: [card])

    expect{ renderer.render(mobiledoc) }.to_not raise_error
  end

  it 'rendering nested mobiledocs in cards' do
    card = Module.new do
      module_function

      def name
        'nested-card'
      end

      def type
        'html'
      end

      def render(env, payload, options)
        options[:renderer].render(payload['mobiledoc'])
      end
    end

    inner_mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [MARKUP_SECTION_TYPE, 'P', [
            [[], 0, 'hello world']]
          ]
        ]
      ]
    }

    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [CARD_SECTION_TYPE, 'nested-card', { 'mobiledoc' => inner_mobiledoc }]
        ]
      ]
    }

    renderer = Mobiledoc::HTMLRenderer.new(cards: [card], card_options: { renderer: self })

    rendered = renderer.render(mobiledoc)

    expect(rendered).to eq('<div><div><div><p>hello world</p></div></div></div>')
  end

  it 'rendering unknown card without unknown_card_handler throws' do
    card_name = 'missing-card'

    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [CARD_SECTION_TYPE, card_name]
        ]
      ]
    }

    renderer = Mobiledoc::HTMLRenderer.new(cards: [])

    expect{ renderer.render(mobiledoc) }.to raise_error(%Q[Card "missing-card" not found])
  end

  it 'rendering unknown card uses unknown_card_handler' do
    card_name = 'missing-card'
    expected_payload = {}
    expected_options = {}

    unknown_card_handler = Module.new do
      module_function

      def type
        'html'
      end

      def render(env, payload, options)
      end
    end

    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [CARD_SECTION_TYPE, card_name, expected_payload]
        ]
      ]
    }

    expect(unknown_card_handler).to receive(:render).with({name: card_name}, expected_payload, expected_options)

    renderer = Mobiledoc::HTMLRenderer.new(cards: [], card_options: expected_options, unknown_card_handler: unknown_card_handler)
    rendered = renderer.render(mobiledoc)
  end

  it 'throws if given an object of cards' do
    expect{ Mobiledoc::HTMLRenderer.new(cards: {}) }.to raise_exception('`cards` must be passed as an array')
  end

  it 'XSS: tag contents are entity escaped' do
    xss = "<script>alert('xx')</script>"

    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [MARKUP_SECTION_TYPE, 'P', [
            [[], 0, xss]]
          ]
        ]
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to eq("<div><p>&lt;script&gt;alert('xx')&lt;/script&gt;</p></div>")
  end

  it 'multiple spaces should preserve whitespace with nbsps' do
    space = ' '
    text = [ space * 4, 'some', space * 5, 'text', space * 6].join

    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [], # markers
        [ # sections
          [MARKUP_SECTION_TYPE, 'P', [
            [[], 0, text]]
          ]
        ]
      ]
    }

    rendered = render(mobiledoc)

    sn = ' &nbsp;'
    expected_text = [ sn * 2, 'some', sn * 2, space, 'text', sn * 3 ].join

    expect(rendered).to eq("<div><p>#{expected_text}</p></div>")
  end

  it 'throws when given an unexpected mobiledoc version' do
    mobiledoc = {
      'version' => '0.1.0',
      'sections' => [
        [], []
      ]
    }

    expect{ render(mobiledoc) }.to raise_error('Unexpected Mobiledoc version "0.1.0"')

    mobiledoc['version'] = '0.2.1'

    expect{ render(mobiledoc) }.to raise_error('Unexpected Mobiledoc version "0.2.1"')
  end

  it 'XSS: unexpected markup and list section tag names are not renderered' do
    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [],
        [
          [MARKUP_SECTION_TYPE, 'script', [
            [[], 0, 'alert("markup section XSS")']
          ]],
          [LIST_SECTION_TYPE, 'script', [
            [[[], 0, 'alert("list section XSS")']]
          ]]
        ]
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to_not match(/script/)
  end

  it 'XSS: unexpected markup types are not rendered' do
    mobiledoc = {
      'version' => MOBILEDOC_VERSION,
      'sections' => [
        [
          ['b'], # valid
          ['em'], # valid
          ['script'] # invalid
        ],
        [
          [MARKUP_SECTION_TYPE, 'p', [
            [[0], 0, 'bold text'],
            [[1,2], 3, 'alert("markup XSS")'],
            [[], 0, 'plain text']
          ]]
        ]
      ]
    }

    rendered = render(mobiledoc)

    expect(rendered).to_not match(/script/)
  end
end
