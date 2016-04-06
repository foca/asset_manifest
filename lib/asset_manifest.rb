require_relative "asset_manifest/version"

module AssetManifest
  class Helpers
    def initialize(manifest, asset_options = {})
      @manifest = manifest
      @asset_options = asset_options
    end

    # Public: Generate a <link> tag.
    #
    # path   - The absolute path (for the browser) to the stylesheet.
    # html   - A Hash with HTML attribute mappings for this tag.
    # **opts - Any keyword arguments will be forwarded to the initializer of
    #          AssetManifest::Asset to calculate the tag's attributes.
    #
    # Returns a String.
    def link_tag(path, html: {}, **opts)
      link = asset(path, opts)
      attrs = attributes(html)
      attrs.concat(sri(link))
      %Q(<link href="#{link.url}" #{attrs.join(" ")}>)
    end

    # Public: Generate a <link> tag to a stylesheet.
    #
    # path   - The absolute path (for the browser) to the stylesheet.
    # html   - A Hash with HTML attribute mappings for this tag.
    # **opts - Any keyword arguments will be forwarded to the initializer of
    #          AssetManifest::Asset to calculate the tag's attributes.
    #
    # Returns a String.
    def stylesheet_tag(path, html: {}, **opts)
      html.update(rel: "stylesheet")
      link_tag(path, html: html, **opts)
    end

    # Public: Generate a <script> tag to a JS file.
    #
    # path   - The absolute path (for the browser) to the script.
    # html   - A Hash with HTML attribute mappings for this tag.
    # **opts - Any keyword arguments will be forwarded to the initializer of
    #          AssetManifest::Asset to calculate the tag's attributes.
    #
    # Returns a String.
    def script_tag(path, html: {}, **opts)
      script = asset(path, opts)
      attrs = attributes(html)
      attrs.concat(sri(script))
      %Q(<script src="#{script.url}" #{attrs.join(" ")}></script>)
    end

    # Public: Generate an <img> tag.
    #
    # path   - The absolute path (for the browser) to the image.
    # html   - A Hash with HTML attribute mappings for this tag.
    # **opts - Any keyword arguments will be forwarded to the initializer of
    #          AssetManifest::Asset to calculate the tag's attributes.
    #
    # Returns a String.
    def image_tag(path, html: {}, **opts)
      image = asset(path, opts)
      attrs = attributes(html)
      %Q(<img src="#{image.url}" #{attrs.join(" ")}>)
    end

    # Internal: Generate an attribute list from a Hash. If there's a `:data` key
    # and it's itself a Hash, its keys will get a `data-` prefix.
    #
    # opts   - A Hash of attribute => value mappings. If a value is the literal
    #          `true`, then we'll consider the attribute to be a Boolean
    #          attribute and output it without value (ie. `{ hidden: true }`
    #          would transform into `["hidden"]`, not `['hidden="true"']`.
    # prefix - A prefix to add to attribute names. Defaults to an empty String.
    #
    # Returns an Array of 'attribute="value"' Strings.
    def attributes(opts, prefix="")
      attrs = []

      if Hash === opts[:data]
        attrs.concat(attributes(opts.delete(:data), "data-"))
      end

      attrs.concat(
        opts.map { |attr, val| val == true ? attr : %Q(#{attr}="#{val}") }
      )

      attrs
    end

    # Internal: Returns an AssetManifest::Asset for the given path, using the default
    # asset options and any other options passed in the `opts` Hash.
    def asset(path, opts)
      Asset.new(path, manifest: @manifest, **@asset_options.merge(opts))
    end

    # Internal: Generate the Sub-Resource Integrity attributes for the tags that
    # require it.
    #
    # tag - An AssetManifest::Asset object.
    #
    # Returns an Array of attribute=value Strings.
    def sri(asset)
      attrs = [%Q(integrity="#{asset.integrity}")]
      attrs << %Q(crossorigin="#{asset.cors}") if asset.cors?
      attrs
    end
  end

  class Asset
    # Public: Returns a String with the SRI hash for this asset.
    attr_reader :integrity

    # Public: Returns a String with the value of the crossorigin attribute, or
    # `nil` if the asset isn't served from a special asset host.
    attr_reader :cors

    def initialize(path, manifest:,
                         host: "",
                         minify: nil,
                         integrity: nil,
                         checksum: nil,
                         cors: "anonymous")
      minify = (minify if minify) # Ensure `false` gets converted to `nil`
      @path = base_path(path, minify)
      @manifest = manifest.fetch(@path, {})
      @integrity = integrity || @manifest.fetch("integrity") do
        fail KeyError, "No integrity information for `#{path}` in the manifest"
      end
      @checksum = checksum || @manifest.fetch("checksum") do
        fail KeyError, "No checksum information for `#{path}` in the manifest"
      end
      @minify = minify
      @host = host
      @cors = cors if cors?
    end

    # Public: Returns a String with the path to the asset from the host's root
    # (i.e. without the asset host).
    def path
      @_path ||= begin
        sep = @minify ? ".min." : "."
        *asset, ext = @path.split(sep)
        asset.last << "-#{@checksum}"
        [*asset, ext].join(sep)
      end
    end

    # Public: Returns a String with the full URL of the asset (including the
    # asset host, if any).
    def url
      @url ||= File.join(@host, path)
    end

    # Public: Returns a Boolean representing whether we should set up a
    # `crossorigin` attribute for this asset.
    def cors?
      @host != ""
    end

    private

    def base_path(path, minify)
      minify = "min" if minify
      *asset, ext = path.split(".")
      [*asset, *minify, ext].join(".")
    end
  end
end
