# Asset Manifest

Tiny set of utilities to compute subresource integrity and cache busting
checksums for static assets.

## How it works

Asset Manifest provides two main utilities:

* An executable that you should run when compiling your static assets. This
  generates a `manifest` file that includes the SRI hash and a checksum (for
  cache-busting purposes) of each of your assets.

* A ruby library to generate the proper links to the assets taking into account
  the data from your manifest.

## Usage

Somewhere in your makefile, you'll want to generate the `public/manifest.json`
file like so:

``` Makefile
# Assuming you keep an ASSETS list with all the assets you're compiling...
ASSETS += public/css/app.css
ASSETS += public/css/app.min.css
ASSETS += public/js/app.js
ASSETS += public/js/app.min.js

# ...you'd want a rule like this one:
public/manifest.json: $(ASSETS)
	asset-manifest -d public $^ > $@
```

Then, in your app, you'll want to initialize `AssetManifest::Helpers` passing
the contents of this JSON file:

``` ruby
assets = AssetManifest::Helpers.new(
  JSON.parse(File.read("./public/manifest.json")),
  { minify: ENV["RACK_ENV"] == "production" }
)
```

Finally, you'll want to pass this object to your views, so that you can do the
following:

``` erb
<%= assets.stylesheet_tag("/css/app.css") %>
<%= assets.script_tag("/js/app.js") %>
```

This would produce output similar to:

``` html
<link rel="stylesheet"
      href="/css/app-07915293e2bb992a67c618e1aa335d978efc3734.css"
      integrity="sha256-yqqr5VJwz1IM5iTlSram51zrBvuE21FbiYgNnD2fwgE=">
<script src="/js/app-1a4aefaba81b61c7ea763d42fcb39584e5784c32.js"
        integrity="sha256-ZmTdnjlqI4ppv9cW8Y5i6PixtV4CQlVUvxB2iySwU94="></script>
```

(Whitespace added for clarity)

### With Rake instead of Make

Assuming you have an `ASSETS` constant with the list of assets, you can use the
following example in your `Rakefile` to re-generate your manifest when your
assets change.

``` rake
rule "public/manifest.json" => ASSETS do |t|
  sh "asset-manifest -d public #{t.prerequisites.join(" ")} > #{t.name}"
end

task assets: ASSETS
task assets: "public/manifest.json"
```

You can add this file to your `assets` so that the file is automatically
generated when your source assets change.

## Cuba plugin

If you use [Cuba](http://cuba.is), then you can just do this:

``` ruby
require "asset_manifest/cuba"
Cuba.plugin AssetManifest::Cuba
```

This will set up an `assets` helper available in all your apps that you can use
/ pass to the templates.

## License

This project is shared under the MIT license. See the attached [LICENSE][] file
for details.

[LICENSE]: ./LICENSE
