require 'spec_helper'
require 'mobiledoc/utils/section_types'
require 'mobiledoc/utils/marker_types'
require 'mobiledoc/cards/image'

module ZeroThreeZero
  include Mobiledoc::Utils::SectionTypes
  include Mobiledoc::Utils::MarkerTypes

  MOBILEDOC_VERSION = '0.3.0'

  describe Mobiledoc::HTMLRenderer, "(#{MOBILEDOC_VERSION})" do

    def render(mobiledoc)
      described_class.new.render(mobiledoc)
    end

    let(:data_uri) { "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACwAAAAAAQABAAACAkQBADs=" }

    it 'renders an empty mobiledoc' do
      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [],
        'markups' => [],
        'sections' => []
      }

      rendered = render(mobiledoc)

      expect(rendered).to eq('<div></div>')
    end

    it 'renders a mobiledoc without markups' do
      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [MARKUP_MARKER_TYPE, [], 0, 'hello world']]
          ]
        ]
      }

      rendered = render(mobiledoc)

      expect(rendered).to eq('<div><p>hello world</p></div>')
    end

    it 'renders a mobiledoc with simple (no attributes) markup' do
      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [],
        'markups' => [
          ['B']
        ],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [MARKUP_MARKER_TYPE, [0], 1, 'hello world']]
          ]
        ]
      }

      rendered = render(mobiledoc)

      expect(rendered).to eq('<div><p><b>hello world</b></p></div>')
    end

    it 'renders a mobiledoc with complex (has attributes) markup' do
      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [],
        'markups' => [
          ['A', ['href', 'http://google.com']]
        ],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [MARKUP_MARKER_TYPE, [0], 1, 'hello world']
          ]]
        ]
      }

      rendered = render(mobiledoc)

      expect(rendered).to eq('<div><p><a href="http://google.com">hello world</a></p></div>')
    end

    it 'renders a mobiledoc with multiple markups in a section' do
      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [],
        'markups' => [
          ['B'],
          ['I']
        ],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [MARKUP_MARKER_TYPE, [0], 0, 'hello '], # b
            [MARKUP_MARKER_TYPE, [1], 0, 'brave '], # b + i
            [MARKUP_MARKER_TYPE, [], 1, 'new '], # close i
            [MARKUP_MARKER_TYPE, [], 1, 'world'] # close b
          ]]
        ]
      }

      rendered = render(mobiledoc)

      expect(rendered).to eq('<div><p><b>hello <i>brave new </i>world</b></p></div>')
    end

    it 'renders a mobiledoc with image section' do
      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [IMAGE_SECTION_TYPE, data_uri]
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
        'atoms' => [],
        'cards' => [
          [card_name, payload]
        ],
        'markups' => [],
        'sections' => [
          [CARD_SECTION_TYPE, 0]
        ]
      }

      rendered = render(mobiledoc)

      expect(rendered).to eq(%Q[<div><div><img src="#{data_uri}"></div></div>])
    end

    it 'render mobiledoc with list section and list items' do
      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [LIST_SECTION_TYPE, 'ul', [
            [[MARKUP_MARKER_TYPE, [], 0, 'first item']],
            [[MARKUP_MARKER_TYPE, [], 0, 'second item']]
          ]]
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
        'atoms' => [],
        'cards' => [
          [card_name, expected_payload]
        ],
        'markups' => [],
        'sections' => [
          [CARD_SECTION_TYPE, 0]
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
        'atoms' => [],
        'cards' => [
          [bad_card.name]
        ],
        'markups' => [],
        'sections' => [
          [CARD_SECTION_TYPE, 0]
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
        'atoms' => [],
        'cards' => [
          [card.name]
        ],
        'markups' => [],
        'sections' => [
          [CARD_SECTION_TYPE, 0]
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
          [MARKUP_SECTION_TYPE, 'P', [
            [MARKUP_MARKER_TYPE, [], 0, 'hello world']]
          ]
        ]
      }

      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [
          [card.name, { 'mobiledoc' => inner_mobiledoc }]
        ],
        'markups' => [],
        'sections' => [
          [CARD_SECTION_TYPE, 0]
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
        'atoms' => [],
        'cards' => [
          [card_name]
        ],
        'markups' => [],
        'sections' => [
          [CARD_SECTION_TYPE, 0]
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
        'atoms' => [],
        'cards' => [
          [card_name, expected_payload]
        ],
        'markups' => [],
        'sections' => [
          [CARD_SECTION_TYPE, 0]
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
        'atoms' => [],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [MARKUP_MARKER_TYPE, [], 0, xss]]
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
        'atoms' => [],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [MARKUP_MARKER_TYPE, [], 0, text]]
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
        'atoms' => [],
        'cards' => [],
        'markups' => [],
        'sections' => []
      }

      expect{ render(mobiledoc) }.to raise_error('Unexpected Mobiledoc version "0.1.0"')

      mobiledoc['version'] = '0.2.1'

      expect{ render(mobiledoc) }.to raise_error('Unexpected Mobiledoc version "0.2.1"')
    end

    it 'XSS: unexpected markup and list section tag names are not renderered' do
      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'script', [
            [MARKUP_MARKER_TYPE, [], 0, 'alert("markup section XSS")']
          ]],
          [LIST_SECTION_TYPE, 'script', [
            [[MARKUP_MARKER_TYPE, [], 0, 'alert("list section XSS")']]
          ]]
        ]
      }

      rendered = render(mobiledoc)

      expect(rendered).to_not match(/script/)
    end

    it 'XSS: unexpected markup types are not rendered' do
      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [],
        'cards' => [],
        'markups' => [
          ['b'], # valid
          ['em'], # valid
          ['script'] # invalid
        ],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'p', [
            [MARKUP_MARKER_TYPE, [0], 0, 'bold text'],
            [MARKUP_MARKER_TYPE, [1,2], 3, 'alert("markup XSS")'],
            [MARKUP_MARKER_TYPE, [], 0, 'plain text']
          ]]
        ]
      }

      rendered = render(mobiledoc)

      expect(rendered).to_not match(/script/)
    end

    it 'renders a mobiledoc with atom' do
      atom_name = 'hello-atom'

      expected_options = { some: :options }
      expected_payload = { some: :payload }
      expected_value = 'Bob'

      atom = Module.new do
        module_function

        def name
          'hello-atom'
        end

        def type
          'html'
        end

        def render(env, value, payload, options)
        end
      end

      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [
          [atom_name, expected_value, expected_payload]
        ],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [ATOM_MARKER_TYPE, [], 0, 0]]
          ]
        ]
      }

      expect(atom).to receive(:render).with({name: atom_name}, expected_value, expected_payload, expected_options).and_return("Hello Bob")

      renderer = Mobiledoc::HTMLRenderer.new(atoms: [atom], card_options: expected_options)
      rendered = renderer.render(mobiledoc)

      expect(rendered).to eq('<div><p>Hello Bob</p></div>')
    end

    it 'throws when given atom with invalid type' do
      bad_atom = Module.new do
        module_function

        def name
          'bad'
        end

        def type
          'other'
        end

        def render(env, value, payload, options)
        end
      end

      expect{ Mobiledoc::HTMLRenderer.new(atoms: [bad_atom]) }.to raise_error(%Q[Atom "bad" must be of type "html", was "other"])
    end

    it 'throws when given atom without `render`' do
      bad_atom = Module.new do
        module_function

        def name
          'bad'
        end

        def type
          'html'
        end
      end

      expect{ Mobiledoc::HTMLRenderer.new(atoms: [bad_atom]) }.to raise_error(%Q[Atom "bad" must define `render`])
    end

    it 'throws if atom render returns invalid result' do
      bad_atom = Module.new do
        module_function

        def name
          'bad'
        end

        def type
          'html'
        end

        def render(env, value, payload, options)
          Object.new
        end
      end

      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [
          [bad_atom.name, 'Bob', { id: 42 }]
        ],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [ATOM_MARKER_TYPE, [], 0, 0]]
          ]
        ]
      }

      renderer = Mobiledoc::HTMLRenderer.new(atoms: [bad_atom])

      expect{ renderer.render(mobiledoc) }.to raise_error(/Atom "bad" must render html/)
    end

    it 'atom may render nothing' do
      atom = Module.new do
        module_function

        def name
          'ok'
        end

        def type
          'html'
        end

        def render(env, value, payload, options)
        end
      end

      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [
          [atom.name, 'Bob', { id: 42 }]
        ],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [ATOM_MARKER_TYPE, [], 0, 0]]
          ]
        ]
      }

      renderer = Mobiledoc::HTMLRenderer.new(atoms: [atom])

      expect{ renderer.render(mobiledoc) }.to_not raise_error
    end

    it 'throws when rendering unknown atom without unknown_atom_handler' do
      atom_name = 'missing-atom'

      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [
          [atom_name, 'Bob', { id: 42 }]
        ],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [ATOM_MARKER_TYPE, [], 0, 0]]
          ]
        ]
      }

      renderer = Mobiledoc::HTMLRenderer.new(atoms: [])

      expect{ renderer.render(mobiledoc) }.to raise_error(%Q[Atom "missing-atom" not found])
    end

    it 'rendering unknown atom uses unknown_atom_handler' do
      atom_name = 'missing-atom'

      expected_value = 'Bob'
      expected_payload = { some: :payload }
      expected_options = { some: :options }

      unknown_atom_handler = Module.new do
        module_function

        def type
          'html'
        end

        def render(env, value, payload, options)
        end
      end

      mobiledoc = {
        'version' => MOBILEDOC_VERSION,
        'atoms' => [
          [atom_name, expected_value, expected_payload]
        ],
        'cards' => [],
        'markups' => [],
        'sections' => [
          [MARKUP_SECTION_TYPE, 'P', [
            [ATOM_MARKER_TYPE, [], 0, 0]]
          ]
        ]
      }

      expect(unknown_atom_handler).to receive(:render).with({name: atom_name}, expected_value, expected_payload, expected_options)

      renderer = Mobiledoc::HTMLRenderer.new(atoms: [], card_options: expected_options, unknown_atom_handler: unknown_atom_handler)
      rendered = renderer.render(mobiledoc)
    end

    context '0.3.1' do
      it 'renders 0.3.1-specific sections and markups' do
        mobiledoc = {
          'version' => '0.3.1',
          'atoms' => [],
          'cards' => [],
          'markups' => [
            ['CODE']
          ],
          'sections' => [
            [MARKUP_SECTION_TYPE, 'ASIDE', [
              [MARKUP_MARKER_TYPE, [0], 1, 'hello world']]
            ]
          ]
        }

        rendered = render(mobiledoc)

        expect(rendered).to eq('<div><aside><code>hello world</code></aside></div>')
      end
    end
  end
end
