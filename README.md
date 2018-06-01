# WithRefinements

Activate the refinements in block scope.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'with_refinements'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install with_refinements

## Usage

```rb
module Greeting
  refine(Object) do
    def hello
      puts :hello
    end
  end
end

# the refinements are activated inside the block
with_refienements(Greeting) do
  hello
end

# the refinements are not activated outside the block
hello
# undefined local variable or method `hello' for main:Object (NameError)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hanachin/with_refinements. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the WithRefinements project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hanachin/with_refinements/blob/master/CODE_OF_CONDUCT.md).
