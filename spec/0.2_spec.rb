require 'spec_helper'

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
end
