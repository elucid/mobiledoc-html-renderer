require "mobiledoc/renderers/0.2"
require 'mobiledoc/utils/marker_types'
require "mobiledoc/error"

module Mobiledoc
  class Renderer_0_3 < Renderer_0_2
    MOBILEDOC_VERSION = /[0][.][3][.].$/

    include Mobiledoc::Utils::MarkerTypes

    attr_accessor :atom_types, :card_types, :atoms, :unknown_atom_handler

    def initialize(mobiledoc, state)
      version, sections, atom_types, card_types, marker_types = *mobiledoc.values_at('version', 'sections', 'atoms', 'cards', 'markups')
      validate_version(version)

      self.doc = Nokogiri::HTML.fragment('')
      self.root = create_document_fragment
      self.sections = sections
      self.atom_types = atom_types
      self.card_types = card_types
      self.marker_types = marker_types
      self.cards = state[:cards]
      self.atoms = state[:atoms]
      self.card_options = state[:card_options]
      self.unknown_card_handler = state[:unknown_card_handler]
      self.unknown_atom_handler = state[:unknown_atom_handler]
    end

    def render_card_section(type, index)
      card, name, payload = _find_card_by_index(index)

      _render_card_section(card, name, payload)
    end

    def _find_card_by_index(index)
      card_type = card_types[index]

      unless card_type
        raise Mobiledoc::Error.new("No card definition found at index #{index}")
      end

      name, payload = *card_type
      card = find_card(name)

      [ card, name, payload ]
    end

    def _render_markers_on_element(element, markers)
      elements = [element]
      current_element = element

      markers.each do |marker|
        type, open_types, close_count, value = *marker

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

        case type
        when MARKUP_MARKER_TYPE
          append_child(current_element, create_text_node(value))
        when ATOM_MARKER_TYPE
          append_child(current_element, _render_atom(value))
        else
          raise Mobiledoc::Error.new("Unknown markup type (#{type})");
        end

        close_count.times do
          elements.pop
          current_element = elements.last
        end
      end
    end

    def find_atom(name)
      atom = atoms.find { |a| a.name == name }

      atom || unknown_atom_handler
    end

    def _render_atom(index)
      atom, name, value, payload = _find_atom_by_index(index)
      atom_arg = _create_atom_argument(atom, name, value, payload)
      rendered = atom.render(*atom_arg)

      _validate_atom_render(rendered, atom.name)

      rendered || create_text_node('')
    end

    def _find_atom_by_index(index)
      atom_type = atom_types[index]

      unless atom_type
        raise Mobiledoc::Error.new("No atom definition found at index #{index}")
      end

      name, value, payload = *atom_type
      atom = find_atom(name)

      [ atom, name, value, payload ]
    end

    def _create_atom_argument(atom, atom_name, value, payload={})
      env = {
        name: atom_name
      }

      [ env, value, payload, card_options ]
    end

    def _validate_atom_render(rendered, atom_name)
      return unless rendered

      unless rendered.is_a?(String)
        raise Mobiledoc::Error.new(%Q[Atom "#{atom_name}" must render html, but result was #{rendered.class}"]);
      end
    end

  end
end
