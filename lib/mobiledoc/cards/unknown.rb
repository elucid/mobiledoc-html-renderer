require "mobiledoc/error"

module Mobiledoc
  module UnknownCard
    module_function

    def type
      'html'
    end

    def render(env, payload, options)
      name = env[:name]

      raise Mobiledoc::Error.new(%Q[Card "#{name}" not found])
    end
  end
end
