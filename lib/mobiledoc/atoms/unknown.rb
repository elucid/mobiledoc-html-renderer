module Mobiledoc
  module UnknownAtom
    module_function

    def type
      'html'
    end

    def render(env, payload, options)
      name = env[:name]

      raise StandardError.new(%Q[Card "#{name}" not found])
    end
  end
end
