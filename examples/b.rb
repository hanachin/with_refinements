require "benchmark_driver"

Benchmark.driver do |x|
  x.prelude <<~RUBY
    require "bundler/setup"
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

  x.report 'with_refinements(local_variable_get: false)', %{
    with_refinements(M, local_variable_get: false) { "hello".goodbye }
  }
end
