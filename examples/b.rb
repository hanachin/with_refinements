require "benchmark_driver"

Benchmark.driver do |x|
  x.prelude <<~RUBY
    require "sin_refinements"
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

  x.report 'with_refinements_light', %{
    with_refinements_light(M) { "hello".goodbye }
  }

  x.report 'SinRefinements.refining', %{
    SinRefinements.refining(M) { "hello".goodbye }
  }

  x.report 'SinRefinements.light_refining', %{
    SinRefinements.light_refining(M) { "hello".goodbye }
  }
end
