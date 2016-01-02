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
    described_class.new(mobiledoc).render[:result]
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
end
