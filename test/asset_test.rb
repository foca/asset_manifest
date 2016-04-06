setup do
  {
    "/css/app.css" => {
      "integrity" => "INTEGRITY",
      "checksum" => "CHECKSUM",
    },
    "/css/app.min.css" => {
      "integrity" => "INTEGRITY-MIN",
      "checksum" => "CHECKSUM-MIN",
    },
  }
end

scope "plain asset with a manifest" do
  test "gets integrity and cache-busting checksums from manifest" do |manifest|
    asset = AssetManifest::Asset.new("/css/app.css", manifest: manifest)
    assert_equal "INTEGRITY", asset.integrity
    assert_equal "/css/app-CHECKSUM.css", asset.path
  end

  test "includes the host in the final URL" do |manifest|
    asset = AssetManifest::Asset.new(
      "/css/app.css",
      manifest: manifest,
      host: "https://example.com",
    )
    assert_equal "https://example.com/css/app-CHECKSUM.css", asset.url
  end
end

scope "Missing asset from the manifest" do
  test "includes asset path in the exception" do |manifest|
    error = assert_raise KeyError do
      AssetManifest::Asset.new("/no/file", manifest: manifest)
    end
    assert error.message =~ %r|/no/file|, "No asset path in the error message"
  end
end

scope "Minified assets" do
  test "includes '.min' in the URL when it should minify" do |manifest|
    asset = AssetManifest::Asset.new(
      "/css/app.css",
      manifest: manifest,
      minify: true,
    )

    assert_equal "/css/app-CHECKSUM-MIN.min.css", asset.path
  end

  test "does not include '.min' in the URL when it shouldn't" do |manifest|
    asset = AssetManifest::Asset.new(
      "/css/app.css",
      manifest: manifest,
      minify: false,
    )

    assert_equal "/css/app-CHECKSUM.css", asset.path
  end
end

scope "CORS settings" do
  test "assumes no CORS required when asset is in the same host" do |manifest|
    asset = AssetManifest::Asset.new(
      "/css/app.css",
      manifest: manifest,
      host: ""
    )

    assert_equal false, asset.cors?
    assert_equal nil, asset.cors
  end

  test "defaults to 'anonymous' for cross origin assets" do |manifest|
    asset = AssetManifest::Asset.new(
      "/css/app.css",
      manifest: manifest,
      host: "https://assets.example.com",
    )

    assert_equal true, asset.cors?
    assert_equal "anonymous", asset.cors
  end

  test "uses the provided value for the cross origin attribute" do |manifest|
    asset = AssetManifest::Asset.new(
      "/css/app.css",
      manifest: manifest,
      host: "https://assets.example.com",
      cors: "use-credentials"
    )

    assert_equal true, asset.cors?
    assert_equal "use-credentials", asset.cors
  end
end
