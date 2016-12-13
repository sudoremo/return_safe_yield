# return_safe_yield

[![Gem Version](https://badge.fury.io/rb/return_safe_yield.svg)](https://badge.fury.io/rb/return_safe_yield)
[![Build Status](https://travis-ci.org/remofritzsche/return_safe_yield.svg?branch=master)](https://travis-ci.org/remofritzsche/return_safe_yield)

Provides helpers for dealing with `return` statements in blocks
and procs by either disallowing them or else ensuring that some code
runs after yielding

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'return_safe_yield'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install return_safe_yield

## Usage

### The problem

Consider the following code:

```ruby
def some_method(&block)
  puts 1
  yield
  puts 3
end

def test
  some_method do
    puts 2
    return
  end
end

test
```

In this case, our `return` statement exits not only the method `test`, but also
the method `some_method`. The line `puts 3` is never called.

This is standard ruby behaviour. It lies in a block's responsibility to not use
`return` if the actual block caller does not support it.

But what if you're not in control of the code that actually calls your block,
and you don't know if it's safe to use `return`? And, on the other hand, what if
you're writing 'black box' library code that accepts blocks or procs and does
not handle `return`s in there well?

For this reason, this Gem provides two different methods for dealing with return
statements in blocks.

Note that this implementation is a bit controversal, as there is a variety of
skilled ruby developers thinking that the responsibility always lies with a
block's or proc's author and no special handling should be performed. So if
you're using this library, please make sure you absolutely need it in your case.

See [this StackOverflow question](http://stackoverflow.com/questions/41100983)
for an interesting discussion of this subject.

### Handle `return` statements gracefully

The first solution provided by this Gem is the method
`ReturnSafeYield.call_then_yield`. It contains a very simple `begin ... rescue ...
ensure` construct and can be passed two blocks. The second block is always
executed unless the first block fails, even if the first block contains a
`return` statement.

Use it as follows:

```ruby
unknown_block = proc do
  return
end

ReturnSafeYield.call_then_yield(unknown_block) do
  # => This line is called even though the above block contains a `return`.
end

# => This line is still not called as the `return` statement exits the current
#    method context.
```

You can also pass arguments to the first block:

```ruby
unknown_block = proc do |arg1, arg2|
end

ReturnSafeYield.call_then_yield(unknown_block, 'arg1 value', 'arg2 value') do
end
```

The second block receives the first block's return value as arguments (this
does not apply if `return` is used explicitely):

```ruby
unknown_block = proc
  'return value'
end

ReturnSafeYield.call_then_yield(unknown_block) do |arg1|
  arg1 == 'return value' # => true
end
```

### Fail if block / proc contains `return`

The second approach offered by this Gem is the method `safe_yield`. It makes
sure the given block does not contain a `return` statement. If it does, an
`ReturnSafeYield::UnexpectedReturnException` exception is thrown.

Use it as follows:

```ruby
unknown_block = proc do |some_argument|
  return
end

ReturnSafeYield.safe_yield(unknown_block, some_argument)
# => Raises an ReturnSafeYield::UnexpectedReturnException exception
```

This is the rigorous way of handling it and its use is controversial among a
variety of rubyists.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/remofritzsche/return_safe_yield. This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
