module Mobiledoc
  module Utils
    module TagNames
      MARKUP_SECTION_TAG_NAMES = [
        'p', 'h1', 'h2', 'h3', 'blockquote', 'pull-quote'
      ]

      LIST_SECTION_TAG_NAMES = [
        'ul', 'ol'
      ]

      MARKUP_TYPES = [
        'b', 'i', 'strong', 'em', 'a', 'u', 'sub', 'sup', 's'
      ]

      def normalize_tag_name(name)
        name.downcase
      end
    end
  end
end
