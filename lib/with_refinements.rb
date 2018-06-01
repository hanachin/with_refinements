require "with_refinements/version"

module WithRefinements
  class << self
    def clean_binding
      eval('module Class.new::CleanRoom; binding; end')
    end

    def code_from_block(block)
      iseq = RubyVM::InstructionSequence.of(block).to_a
      loc = iseq[4].yield_self {|h| h[:code_range] || h[:code_location] }
      path = iseq[7]
      File.readlines(path)[loc[0]-1..loc[2]-1].tap {|ls|
        ls[0], ls[-1] = ls[0][loc[1]..-1], ls[-1][0..loc[3]]
      }.join
    end
  end

  refine(Object) do
    def with_refinements(*ms, &block)
      # enable refinements
      b = WithRefinements.clean_binding
      b.local_variable_set(:__modules__, ms)
      b.eval('__modules__.each {|m| using m }')

      # setup block eval context
      bb = block.binding
      b.local_variable_set(:__self__, bb.eval('self'))
      bb.local_variables.each {|n| b.local_variable_set(n, bb.local_variable_get(n)) }

      # eval block code
      b.eval("__self__.instance_eval #{WithRefinements.code_from_block(block)}")
    end
  end
end
