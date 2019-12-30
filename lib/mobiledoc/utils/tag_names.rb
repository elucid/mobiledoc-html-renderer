module Mobiledoc
  module Utils
    module TagNames
      MARKUP_SECTION_TAG_NAMES = [
        'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pull-quote', 'aside'
      ]

      LIST_SECTION_TAG_NAMES = [
        'ul', 'ol'
      ]

      MARKUP_TYPES = [
        'b', 'i', 'strong', 'em', 'a', 'u', 'sub', 'sup', 's', 'code'
      ]

      def normalize_tag_name(name)
        name.downcase
      end
    end
  end
end
