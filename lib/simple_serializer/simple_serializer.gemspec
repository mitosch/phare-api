lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "simple_serializer/version"

Gem::Specification.new do |gem|
  gem.name = "simple_serializer"
  gem.version = SimpleSerializer::VERSION

  # gem.required_ruby_version = '>= 2.0.0' if gem.respond_to? :required_ruby_version=
  # gem.required_rubygems_version = Gem::Requirement.new(">= 0") if gem.respond_to? :required_rubygems_version=
  # gem.metadata = { "allowed_push_host" => "https://rubygems.org" } if gem.respond_to? :metadata=
  gem.require_paths = ["lib"]
  gem.authors = ["Mischa Schindowski"]
  gem.description = "A simple serializer for rails objects"
  gem.email = ""
  # gem.extra_rdoc_files = [
  #   "LICENSE.txt",
  #   "README.md"
  # ]
  gem.files = Dir["lib/**/*"]
  gem.homepage = "http://github.com/mitosch/simple_serializer"
  # gem.licenses = ["Apache-2.0"]
  gem.rubygems_version = "2.5.1"
  gem.summary = "Simple serializer for rails objects"

  # gem.add_runtime_dependency(%q<activesupport>, [">= 4.2"])
  # gem.add_development_dependency(%q<activerecord>, [">= 4.2"])
  # gem.add_development_dependency(%q<skylight>, ["~> 1.3"])
  # gem.add_development_dependency(%q<rspec>, ["~> 3.5.0"])
  # gem.add_development_dependency(%q<oj>, ["~> 3.3"])
  # gem.add_development_dependency(%q<rspec-benchmark>, ["~> 0.3.0"])
  # gem.add_development_dependency(%q<bundler>, ["~> 1.0"])
  # gem.add_development_dependency(%q<byebug>, [">= 0"])
  # gem.add_development_dependency(%q<active_model_serializers>, ["~> 0.10.7"])
  # gem.add_development_dependency(%q<sqlite3>, ["~> 1.3"])
  # gem.add_development_dependency(%q<jsonapi-rb>, ["~> 0.5.0"])
  # gem.add_development_dependency(%q<jsonapi-serializers>, ["~> 1.0.0"])
end
