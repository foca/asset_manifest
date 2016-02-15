require_relative "../asset_manifest"

# Cuba plugin to simplify using AssetManifest. Gives you an entrypoint into the set of
# helpers to render different HTML tags.
#
# All you need to do is add this:
#
#   Cuba.plugin AssetManifest::Cuba
#
# For example, in your template you could do something like this:
#
#   <%= assets.stylesheet_tag("/css/main.css") %>
#   <%= assets.script_tag("/js/main.js") %>
#
# Configuration
# -------------
#
# You can configure the following things:
#
# * `Cuba.settings[:asset_manifest][:public]`:
#   The public directory where assets go. Defaults to `./public`.
#
# * `Cuba.settings[:asset_manifest][:manifest]`:
#   Path to the asset manifest. Defaults to `{{ public }}/manifest.json`.
#
# * `Cuba.settings[:asset_manifest][:minified]`:
#   Whether to append a `min` to the filename. If this is trueish, then a link
#   to `foo.xyz` would turn to a link to `foo.min.xyz`. Defaults to `nil`.
#
# * `Cuba.settings[:asset_manifest][:asset_host]`:
#   Host to serve assets from. Defaults to an empty String (same root as the
#   Cuba app).
#
module AssetManifest::Cuba
  def self.setup(app)
    settings = app.settings[:asset_manifest] ||= {}

    settings[:public] ||= "./public"
    settings[:manifest] ||= File.join(settings[:public], "manifest.json")
    settings[:minified] ||= nil
    settings[:asset_host] ||= ""
  end

  # Public: Helper proxy for your apps.
  #
  # Example:
  #
  #     <%= assets.stylesheet_tag("/css/main.css") %>
  #
  def assets
    @_assets ||= AssetManifest::Helpers.new(
      JSON.parse(File.read(settings[:asset_manifest][:manifest])),
      {
        minify: settings[:asset_manifest][:minified],
        host: settings[:asset_manifest][:asset_host],
      }
    )
  end
end
