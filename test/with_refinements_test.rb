require "test_helper"

class WithRefinementsTest < Test::Unit::TestCase
  using WithRefinements

  module Bang
    refine(String) do
      def bang
        self + "!"
      end
    end
  end

  module Fword
    refine(String) do
      def fnize
        f = "*" * size
        f[0] = self[0]
        f
      end
    end
  end

  def test_refine_do_block
    assert("hi!" == (with_refinements(Bang) do "hi".bang end))
  end

  def test_refine_brace_block
    assert("hi!" == with_refinements(Bang) { "hi".bang })
  end

  def test_refine_proc
    b = proc { "hi".bang }
    assert("hi!" == with_refinements(Bang, &b))
  end

  def test_refine_proc_new
    b = Proc.new { "hi".bang }
    assert("hi!" == with_refinements(Bang, &b))
  end

  def test_refine_lambda
    b = lambda { "hi".bang }
    assert("hi!" == with_refinements(Bang, &b))
  end

  def test_refine_lambda_sugar
    b = -> { "hi".bang }
    assert("hi!" == with_refinements(Bang, &b))
  end

  def test_block_scope
    with_refinements(Bang) { }
    assert_raise(NoMethodError) { "hi".bang }
  end

  def test_local_var_ref
    hi = "hi"
    assert("hi!" == with_refinements(Bang) { hi.bang })
  end

  def test_using_multiple_module
    assert("h**" == with_refinements(Bang, Fword) { "hi".bang.fnize })
  end

  def test_using_anonymous_module
    assert("hi!!" == with_refinements(Module.new { refine(String) { def bangbang; self + "!!"; end }}) { "hi".bangbang })
  end
end
