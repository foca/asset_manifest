setup do
  AssetManifest::Helpers.new(
    "/css/app.css" => {
      "integrity" => "CSS-INTEGRITY",
      "checksum" => "CSS-CHECKSUM",
    },
    "/css/app.min.css" => {
      "integrity" => "CSS-INTEGRITY-MIN",
      "checksum" => "CSS-CHECKSUM-MIN",
    },
    "/js/app.js" => {
      "integrity" => "JS-INTEGRITY",
      "checksum" => "JS-CHECKSUM",
    },
    "/js/app.min.js" => {
      "integrity" => "JS-INTEGRITY-MIN",
      "checksum" => "JS-CHECKSUM-MIN",
    },
    "/img/favicon.ico" => {
      "integrity" => "FAVICON-INTEGRITY",
      "checksum" => "FAVICON-CHECKSUM",
    },
    "/img/thing.png" => {
      "integrity" => "IMAGE-INTEGRITY",
      "checksum" => "IMAGE-CHECKSUM",
    },
  )
end

test "link tag" do |assets|
  assert_html \
    %Q(<link rel="favicon"
             href="/img/favicon-FAVICON-CHECKSUM.ico"
             integrity="FAVICON-INTEGRITY">),
    assets.link_tag("/img/favicon.ico", html: { rel: "favicon" })
end

test "stylesheet tag" do |assets|
  assert_html \
    %Q(<link rel="stylesheet"
             href="/css/app-CSS-CHECKSUM.css"
             integrity="CSS-INTEGRITY">),
    assets.stylesheet_tag("/css/app.css")
end

test "script tag" do |assets|
  assert_html \
    %Q(<script src="/js/app-JS-CHECKSUM.js" integrity="JS-INTEGRITY"></script>),
    assets.script_tag("/js/app.js")
end

test "image tag" do |assets|
  assert_html \
    %Q(<img src="/img/thing-IMAGE-CHECKSUM.png"
            alt="A thing">),
    assets.image_tag("/img/thing.png", html: { alt: "A thing" })
end
