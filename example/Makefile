ASSETS += public/css/app.css
ASSETS += public/js/app.js

.PHONY: assets
assets: $(ASSETS) public/manifest.json

.PHONY: clean
clean:
	rm -rf public

# You'd probably use some precompiler here, and not just cp.
public/%: assets/% | public
	mkdir -p `dirname $@`
	cp $< $@

public/manifest.json: $(ASSETS) | public
	asset-manifest -d public $^ > $@

public:
	mkdir -p $@
