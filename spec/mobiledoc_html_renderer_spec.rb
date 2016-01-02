require 'spec_helper'

describe Mobiledoc::HTMLRenderer do
  it 'has a version number' do
    expect(Mobiledoc::HTMLRenderer::VERSION).not_to be nil
  end

  it 'can be instantiated' do
    expect { described_class.new }.to_not raise_exception
  end
end
