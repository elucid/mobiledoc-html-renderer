require "mobiledoc_html_renderer/version"
require "mobiledoc_html_renderer/renderers/0.2"

module Mobiledoc
  class HTMLRenderer
    def render(mobiledoc)
      case mobiledoc['version']
      when '0.2.0', nil
        Renderer_0_2.new(mobiledoc).render
      end
    end
  end
end
