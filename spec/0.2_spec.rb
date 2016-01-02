require 'spec_helper'
require 'mobiledoc_html_renderer/utils/section_types'

# NOTE: I would like this to be scoped to the describe block but
# doing so does not make the section type constants available to
# examples
include Mobiledoc::Utils::SectionTypes

describe Mobiledoc::HTMLRenderer do
  MOBILEDOC_VERSION = '0.2.0'

  def render(mobiledoc)
    described_class.new(mobiledoc).render[:result]
  end

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
end
