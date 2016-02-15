require_relative "lib/asset_manifest/version"

Gem::Specification.new do |s|
  s.name        = "asset_manifest"
  s.licenses    = ["MIT"]
  s.version     = AssetManifest::VERSION
  s.summary     = "Utilities for serving your static assets."
  s.description = "AssetManifest provides utilities for generating SRI and cache-busting hashes to your static assets during compilation."
  s.authors     = ["Nicolas Sanguinetti"]
  s.email       = ["contacto@nicolassanguinetti.info"]
  s.homepage    = "http://github.com/13floor/asset_manifest"

  s.files = Dir[
    "LICENSE",
    "README.md",
    "lib/**/*.rb",
    "bin/*",
  ]

  s.executables << "asset-manifest"

  s.add_development_dependency "cutest", "~> 1.2"
  s.add_development_dependency "rack", "~> 2.5"
end
