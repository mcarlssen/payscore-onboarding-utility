# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"
begin
  require "bootsnap/setup"
rescue LoadError
  # bootsnap optional
end
