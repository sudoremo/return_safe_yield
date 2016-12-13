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
      end
    end

    foo do
      $count += 1
      next 'a', 'b'
    end

    assert_equal 3, $count
  end
end
