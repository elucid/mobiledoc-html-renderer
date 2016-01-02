module Mobiledoc
  class UnknownCard < Struct.new(:name)
    def type
      'html'
    end

    def render(*args)
      raise StandardError.new(%Q[Card "#{name}" not found])
    end
  end
end
