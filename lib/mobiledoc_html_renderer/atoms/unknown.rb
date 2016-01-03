module Mobiledoc
  class UnknownAtom < Struct.new(:name)
    def type
      'html'
    end

    def render(*args)
      raise StandardError.new(%Q[Atom "#{name}" not found])
    end
  end
end
