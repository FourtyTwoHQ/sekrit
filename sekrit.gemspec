lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sekrit/version"

Gem::Specification.new do |spec|
    spec.name          = "sekrit"
    spec.version       = Sekrit::VERSION
    spec.authors       = ["Ben Sarrazin"]
    spec.email         = ["b@srz.io"]

    spec.summary       = %q{A gem for encrypting/decrypting files for your projects.}
    spec.description   = %q{Register files to encrypt/decrypt and store them in a separate git repository.}
    spec.homepage      = "https://github.com/fourtytwohq/sekrit"
    spec.license       = "MIT"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/fourtytwohq/sekrit"
    spec.metadata["changelog_uri"] = "https://github.com/fourtytwohq/sekrit"

    # Specify which files should be added to the gem when it is released.
    # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
    spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
        `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
    spec.bindir        = "exe"
    spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
    spec.require_paths = ["lib"]

    spec.add_development_dependency "bundler", "~> 2.0"
    spec.add_development_dependency "rake", "~> 10.0"
    spec.add_development_dependency "minitest", "~> 5.0"
    spec.add_runtime_dependency 'git', '~> 1.5.0'
    spec.add_runtime_dependency 'rainbow', '~> 3.0.0'
    spec.add_runtime_dependency 'terminal-table', '~> 1.8.0'
    spec.add_runtime_dependency 'thor', '~> 0.20.3'
end
