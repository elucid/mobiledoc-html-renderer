require "nokogiri"
require "mobiledoc/utils/section_types"
require "mobiledoc/utils/tag_names"
require "mobiledoc/cards/image"
require "mobiledoc/error"

module Mobiledoc
  class Renderer_0_2
    MOBILEDOC_VERSION = /[0][.][2][.].$/

    include Mobiledoc::Utils::SectionTypes
    include Mobiledoc::Utils::TagNames

    attr_accessor :root, :marker_types, :sections, :doc, :cards, :card_options, :unknown_card_handler

    def initialize(mobiledoc, state)
      version, section_data = *mobiledoc.values_at('version', 'sections')
      validate_version(version)

      self.marker_types, self.sections = *section_data

      self.doc = Nokogiri::HTML.fragment('')
      self.root = create_document_fragment
      self.cards = state[:cards]
      self.card_options = state[:card_options]
      self.unknown_card_handler = state[:unknown_card_handler]
    end

    def validate_version(version)
      if (self.class::MOBILEDOC_VERSION =~ version).nil?
        raise Mobiledoc::Error.new(%Q[Unexpected Mobiledoc version "#{version}"]);
      end
    end

    def render
      root = create_document_fragment

      sections.each do |section|
        rendered = render_section(section)

        if rendered
          append_child(root, rendered)
        end
      end

      root.to_html(save_with: 0).gsub('  ', ' &nbsp;')
    end

    def create_document_fragment
      create_element('div')
    end

    def create_element(tag_name)
      tag_name = normalize_tag_name(tag_name)
      Nokogiri::XML::Node.new(tag_name, doc)
    end

    def set_attribute(element, prop_name, prop_value)
      element.set_attribute(prop_name, prop_value)
    end

    def create_text_node(text)
      Nokogiri::XML::Text.new(text, doc)
    end

    def create_element_from_marker_type(tag_name='', attributes=[])
      element = create_element(tag_name)

      attributes.each_slice(2) do |prop_name, prop_value|
        set_attribute(element, prop_name, prop_value)
      end

      element
    end

    def append_child(target, child)
      target.add_child(child)
    end

    def render_section(section)
      type = section.first
      case type
      when MARKUP_SECTION_TYPE
        render_markup_section(*section)
      when IMAGE_SECTION_TYPE
        render_image_section(*section)
      when LIST_SECTION_TYPE
        render_list_section(*section)
      when CARD_SECTION_TYPE
        render_card_section(*section)
      end
    end

    def render_markup_section(type, tag_name, markers)
      return unless valid_section_tag_name?(tag_name, MARKUP_SECTION_TYPE)

      element = create_element(tag_name)
      _render_markers_on_element(element, markers)
      element
    end

    def render_image_section(type, url)
      element = create_element('img')
      set_attribute(element, 'src', url)
      element
    end

    def render_list_section(type, tag_name, items)
      return unless valid_section_tag_name?(tag_name, LIST_SECTION_TYPE)

      element = create_element(tag_name)
      items.each do |item|
        append_child(element, render_list_item(item))
      end

      element
    end

    def render_list_item(markers)
      element = create_element('li')
      _render_markers_on_element(element, markers)
      element
    end

    def render_card_section(type, name, payload={})
      card = find_card(name)

      _render_card_section(card, name, payload)
    end

    def _render_card_section(card, name, payload)
      card_wrapper = _create_card_element
      card_arg = _create_card_argument(name, payload)
      rendered = card.render(*card_arg)

      _validate_card_render(rendered, card.name)

      if rendered
        append_child(card_wrapper, rendered)
      end

      card_wrapper
    end

    def find_card(name)
      card = cards.find { |c| c.name == name }

      case
      when card
        card
      when ImageCard.name == name
        ImageCard
      else
        unknown_card_handler
      end
    end

    def _create_card_element
      create_element('div')
    end

    def _create_card_argument(card_name, payload={})
      env = {
        name: card_name
      }

      [ env, payload, card_options ]
    end

    def _validate_card_render(rendered, card_name)
      return unless rendered

      unless rendered.is_a?(String)
        raise Mobiledoc::Error.new(%Q[Card "#{card_name}" must render html, but result was #{rendered.class}"]);
      end
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
            opened_element = create_element_from_marker_type(*marker_type)
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
        raise Mobiledoc::Error.new(%Q[Cannot validate tag_name for unknown section type "#{section_type}"])
      end
    end

    def valid_marker_type?(type)
      type = normalize_tag_name(type)

      MARKUP_TYPES.include?(type)
    end
  end
end
