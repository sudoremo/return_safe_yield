require 'test_helper'

class ReturnSafeYieldTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ReturnSafeYield::VERSION
  end

  def test_call_then_yield_with_return
    $count = 0

    def foo(&block)
      $count += 1
      ReturnSafeYield.call_then_yield(block, 'arg1') do
        $count += 1
      end
    end

    def main
      foo do |arg1|
        assert_equal 'arg1', arg1
        $count += 1
        return
      end
    end

    main

    assert_equal 3, $count
  end

  def test_call_then_yield_without_return
    $count = 0

    def foo(&block)
      $count += 1
      ReturnSafeYield.call_then_yield(block) do |a, b|
        assert_equal 'a', a
        assert_equal 'b', b
        $count += 1
        'test'
      end
    end

    result = foo do
      $count += 1
      next 'a', 'b'
    end

    assert_equal 'test', result

    assert_equal 3, $count
  end

  def test_call_then_yield_with_exception_in_first_proc
    block = proc do
      fail 'Test'
    end
    assert_raises do
      ReturnSafeYield.call_then_yield(block) do
      end
    end
  end

  def test_call_then_yield_with_exception_in_second_proc
    block = proc do
    end
    assert_raises do
      ReturnSafeYield.call_then_yield(block) do
        fail
      end
    end
  end

  def test_safe_yield_with_return
    $bad_proc = proc do |a, b|
      assert_equal 'a', a
      assert_equal 'b', b
      return 'bla'
    end

    def main
      ReturnSafeYield.safe_yield($bad_proc, 'a', 'b')
    end

    assert_raises ReturnSafeYield::UnexpectedReturnException do
      main
    end
  end

  def test_safe_yield_without_return
    assert_equal 'test', ReturnSafeYield.safe_yield(proc { 'test' })
  end
end
