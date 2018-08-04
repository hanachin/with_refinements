require "with_refinements/version"

module WithRefinements
  @context_cache = {}
  @refined_proc_cache = Hash.new {|h,k| h[k] = {} }

  class << self
    attr_accessor :context_cache, :refined_proc_cache

    def context(refinements)
      context_cache[refinements] ||= clean_binding.tap do |b|
        b.local_variable_set(:__refinements__, refinements)
        b.eval('__refinements__.each {|r| using r }')
      end
    end

    def refined_proc(c, block, local_variables)
      refined_proc_cache[c][block.source_location] ||= (
        bb = block.binding
        if local_variables == false
          lvars = []
          args = "__binding__"
        elsif (lvars = bb.local_variables).empty?
          args = "__binding__"
        else
          args = "__binding__, " + lvars.join(",")
        end
        c.eval(<<~RUBY)
          proc do |#{args}|
            ret = __binding__.receiver.instance_eval #{WithRefinements.code_from_block(block)}
            #{lvars.map {|v| "__binding__.local_variable_set(:#{v}, #{v})" }.join("\n")}
            ret
          end
        RUBY
      )
    end

    def code_from_block(block)
      path, loc = block_source_location(block)
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

    def block_source_location(block)
      iseq = RubyVM::InstructionSequence.of(block).to_a
      loc = iseq[4].yield_self {|h| h[:code_range] || h[:code_location] }
      path = iseq[7]
      return path, loc
    end

    def clean_binding
      TOPLEVEL_BINDING.eval('Module.new { break binding }')
    end
  end

  refine(Object) do
    def with_refinements(*refinements, local_variables: true, &block)
      # setup block eval context
      c = WithRefinements.context(refinements)
      p = WithRefinements.refined_proc(c, block, local_variables)
      bb = block.binding
      if local_variables
        lvars = bb.local_variables.map {|v| bb.local_variable_get(v) }
      else
        lvars = []
      end
      p.call(bb, *lvars)
    end
  end
end
