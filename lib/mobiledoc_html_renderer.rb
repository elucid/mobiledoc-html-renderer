require "mobiledoc_html_renderer/version"
require "nokogiri"

module Mobiledoc
  class HTMLRenderer
    def render(mobiledoc)
      root = create_document_fragment

      mobiledoc['sections'].each do |section|
        rendered = render_section(section)

        if rendered
          append_child(root, rendered)
        end
      end

      { result: root.to_html }
    end

    def create_document_fragment
      doc = Nokogiri::HTML::DocumentFragment.parse('')
      Nokogiri::XML::Node.new('div', doc)
    end

    def render_section(section)
    end
  end
end
