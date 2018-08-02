require "benchmark_driver"

Benchmark.driver do |x|
  x.prelude <<~RUBY
    require "with_refinements"

    using WithRefinements

    module M
      refine(String) do
        def goodbye
          -"goodbye"
        end
      end
    end
  RUBY

  x.report 'plain', %{
    using M
    "hello".goodbye
  }

  x.report 'with_refinements', %{
    with_refinements(M) { "hello".goodbye }
  }
end
