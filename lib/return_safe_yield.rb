require 'return_safe_yield/version'

module ReturnSafeYield
  class UnexpectedReturnException < StandardError; end

  # Calls the two given blocks (`first`, then `&_second`), even if the first
  # block contains a return. The second block receives the return value of the
  # first block as arguments.
  #
  # The second block is not called if the first one raises an exception.
  #
  # Example:
  #
  #   unknown_block = proc do
  #     return
  #   end
  #   ReturnSafeYield.call_then_yield(unknown_block) do
  #     # => This line is called even though the above block contains a `return`.
  #   end
  #
  #   # => This line here might not be called however as the `return` statement
  #   #    exits the current method context.
  def self.call_then_yield(first, &_second)
    exception = false
    first_block_result = nil
    begin
      first_block_result = first.call
    rescue
      exception = true
      fail
    ensure
      yield(*first_block_result) unless exception
    end
  end

  # Yields the given block and raises a `UnexpectedReturnException` exception if
  # the block contained a `return` statement. Thus it is safe to assume that
  # yielding a block in this way never jumps out of your surrounding routine.
  #
  # Note that you cannot pass a block using `safe_yield do`, as it does not make
  # sense to check for `return` statements in code controlled by the caller
  # itself.
  #
  # Example:
  #
  #   unknown_block = proc do |some_argument|
  #     return
  #   end
  #
  #   ReturnSafeYield.safe_yield(unknown_block, some_argument)
  #   # => Raises a UnexpectedReturnException exception
  def self.safe_yield(block, *args, &cb)
    state = :returned
    result = block.call(*args, &cb)
    state = :regular
    return result
  rescue
    state = :exception
    fail
  ensure
    if state == :returned
      fail UnexpectedReturnException, "Block #{block.inspect} contains a `return` which it is not supposed to."
    end
  end
end