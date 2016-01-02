require "mobiledoc_html_renderer/version"
require "nokogiri"
require "mobiledoc_html_renderer/utils/section_types"
require "mobiledoc_html_renderer/utils/tag_names"

module Mobiledoc
  class HTMLRenderer
    include Mobiledoc::Utils::SectionTypes
    include Mobiledoc::Utils::TagNames

    attr_accessor :root, :marker_types, :sections, :doc

    def initialize(mobiledoc)
      version, section_data = *mobiledoc.values_at('version', 'sections')
      self.marker_types, self.sections = *section_data

      self.doc = Nokogiri::HTML::DocumentFragment.parse('')
      self.root = create_document_fragment
    end

    def render
      root = create_document_fragment

      sections.each do |section|
        rendered = render_section(section)

        if rendered
          append_child(root, rendered)
        end
      end

      { result: root.to_html }
    end

    def create_document_fragment
      create_element('div')
    end

    def create_element(tag_name)
      tag_name = normalize_tag_name(tag_name)
      Nokogiri::XML::Node.new(tag_name, doc)
    end

    def create_text_node(text)
      Nokogiri::XML::Text.new(text, doc)
    end

    def append_child(target, child)
      target.add_child(child)
    end

    def render_section(section)
      type = section.first
      case type
      when MARKUP_SECTION_TYPE
        render_markup_section(*section)
      end
    end

    def render_markup_section(type, tag_name, markers)
      return unless valid_section_tag_name?(tag_name, MARKUP_SECTION_TYPE)

      element = create_element(tag_name)
      _render_markers_on_element(element, markers)
      element
    end

    def _render_markers_on_element(element, markers)
      elements = [element]
      current_element = element

      markers.each do |marker|
        open_types, close_count, text = *marker

        open_types.each do |open_type|
          marker_type = marker_types[open_type]
          tag_name = marker_type.first

          if valid_marker_type?(tag_name)
            opened_element = create_element_from_marker_type(marker_type)
            append_child(current_element, opened_element)
            elements.push(opened_element)
            current_element = opened_element
          else
            close_count -= 1
          end
        end

        append_child(current_element, create_text_node(text))

        close_count.times do
          elements.pop
          current_element = elements.last
        end
      end
    end

    def valid_section_tag_name?(tag_name, section_type)
      tag_name = normalize_tag_name(tag_name)

      case section_type
      when MARKUP_SECTION_TYPE
        MARKUP_SECTION_TAG_NAMES.include?(tag_name)
      when LIST_SECTION_TYPE
        LIST_SECTION_TAG_NAMES.include?(tag_name)
      else
        raise StandardError.new("Cannot validate tagName for unknown section type #{section_type}")
      end
    end
  end
end
