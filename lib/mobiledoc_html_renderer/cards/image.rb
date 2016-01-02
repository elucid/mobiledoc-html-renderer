module Mobiledoc
  module ImageCard
    module_function

    def name
      'image-card'
    end

    def type
      'html'
    end

    def render(env, options, payload)
      if payload['src']
        %Q[<img src="#{payload['src']}">]
      end
    end
  end
end
