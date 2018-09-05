require "mobiledoc_html_renderer/version"
require "mobiledoc/renderers/0.2"
require "mobiledoc/renderers/0.3"
require "mobiledoc/cards/unknown"
require "mobiledoc/atoms/unknown"
require "mobiledoc/error"

module Mobiledoc
  class HTMLRenderer
    attr_accessor :state

    def initialize(options={})
      cards = options[:cards] || []
      validate_cards(cards)

      atoms = options[:atoms] || []
      validate_atoms(atoms)

      card_options = options[:card_options] || {}

      unknown_card_handler = options[:unknown_card_handler] || UnknownCard
      unknown_atom_handler = options[:unknown_atom_handler] || UnknownAtom

      self.state = {
        cards: cards,
        atoms: atoms,
        card_options: card_options,
        unknown_card_handler: unknown_card_handler,
        unknown_atom_handler: unknown_atom_handler
      }
    end

    def validate_cards(cards)
      unless cards.is_a?(Array)
        raise Mobiledoc::Error.new("`cards` must be passed as an array")
      end

      cards.each do |card|
        unless card.type == 'html'
          raise Mobiledoc::Error.new(%Q[Card "#{card.name}" must be of type "html", was "#{card.type}"])
        end

        unless card.respond_to?(:render)
          raise Mobiledoc::Error.new(%Q[Card "#{card.name}" must define \`render\`])
        end
      end
    end

    def validate_atoms(atoms)
      unless atoms.is_a?(Array)
        raise Mobiledoc::Error.new("`atoms` must be passed as an array")
      end

      atoms.each do |atom|
        unless atom.type == 'html'
          raise Mobiledoc::Error.new(%Q[Atom "#{atom.name}" must be of type "html", was "#{atom.type}"])
        end

        unless atom.respond_to?(:render)
          raise Mobiledoc::Error.new(%Q[Atom "#{atom.name}" must define \`render\`])
        end
      end
    end

    def render(mobiledoc)
      version = mobiledoc['version']

      case version
      when Renderer_0_2::MOBILEDOC_VERSION
        Renderer_0_2.new(mobiledoc, state).render
      when Renderer_0_3::MOBILEDOC_VERSION
        Renderer_0_3.new(mobiledoc, state).render
      else
        raise Mobiledoc::Error.new(%Q[Unexpected Mobiledoc version "#{version}"])
      end
    end
  end
end
