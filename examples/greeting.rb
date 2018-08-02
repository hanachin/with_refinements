require "with_refinements"

module Helloable
  refine(Object) do
    def hello
      puts :hello
    end
  end
end

module Hiable
  refine(Object) do
    def hi
      puts :hi
    end
  end
end

class Person
  using WithRefinements

  def initialize(with:)
    @things = Array(with)
  end

  def greet(&block)
    with_refinements(*@things, &block)
  end
end

a = Person.new(with: Hiable)
b = Person.new(with: Helloable)

a.greet do
  hello rescue hi
end

b.greet do
  hi rescue hello
end
