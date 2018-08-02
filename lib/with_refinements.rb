require "with_refinements/version"

module WithRefinements
  class << self
    def binding_with(refinements)
      b = clean_binding
      b.local_variable_set(:__refinements__, refinements)
      b.eval('__refinements__.each {|r| using r }')
      b
    end

    def code_from_block(block)
      iseq = RubyVM::InstructionSequence.of(block).to_a
      loc = iseq[4].yield_self {|h| h[:code_range] || h[:code_location] }
      path = iseq[7]
      File.readlines(path)[loc[0]-1..loc[2]-1].tap {|ls|
        if loc[0] == loc[2]
          ls[0] = ls[0][loc[1]...loc[3]]
        else
          ls[0], ls[-1] = ls[0][loc[1]..-1], ls[-1][0..loc[3]]
        end

        # remove -> from -> {}
        if ls[0].start_with?('->')
          ls[0] = ls[0][2..-1]
        end
      }.join
    end

    private

    def clean_binding
      TOPLEVEL_BINDING.eval('Module.new { break binding }')
    end
  end

  refine(Object) do
    def with_refinements(*refinements, local_variables: true, &block)
      # enable refinements
      b = WithRefinements.binding_with(refinements)

      # setup block eval context
      bb = block.binding
      b.local_variable_set(:__self__, bb.receiver)

      # copy local_variables
      if local_variables
        bb.local_variables.each {|n| b.local_variable_set(n, bb.local_variable_get(n)) }
      end

      # eval block code
      ret = b.eval("__self__.instance_eval #{WithRefinements.code_from_block(block)}")

      # write back local_variables
      if local_variables
        bb.local_variables.each {|n| bb.local_variable_set(n, b.local_variable_get(n)) }
      end

      ret
    end
  end
end
