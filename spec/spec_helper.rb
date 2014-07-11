require "ofx"
require "pry-byebug"

RSpec::Matchers.define :have_key do |key|
  match do |hash|
    hash.respond_to?(:keys) &&
    hash.keys.kind_of?(Array) &&
    hash.keys.include?(key)
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

   config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.order = "random"
  config.raise_errors_for_deprecations!
end

