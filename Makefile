PACKAGES := asset_manifest
VERSION_FILE := lib/$(PACKAGES)/version.rb

DEPS := $(GEM_HOME)/installed
VERSION := $(shell sed -ne '/.*VERSION *= *"\(.*\)".*/s//\1/p' <$(VERSION_FILE))
GEMS := $(addprefix pkg/, $(addsuffix -$(VERSION).gem, $(PACKAGES)))

export RUBYLIB := $(RUBYLIB):test:lib

.PHONY: all
all: test $(GEMS)

.PHONY: test
test: $(DEPS)
	cutest -r ./test/helper.rb ./test/**/*_test.rb

.PHONY: clean
clean:
	rm pkg/*.gem

.PHONY: release
release: $(GEMS)
	git tag v$(VERSION)
	for gem in $^; do gem push $$gem; done

pkg/%-$(VERSION).gem: %.gemspec $(VERSION_FILE) | pkg
	gem build $<
	mv $(@F) pkg/

$(DEPS): .gems | $(GEM_HOME)
	which dep &>/dev/null || gem install dep
	dep install
	touch $(GEM_HOME)/installed

pkg $(GEM_HOME):
	mkdir -p $@
