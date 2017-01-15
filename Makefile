build:
	@luarocks make rockspecs/outcome-1.0.0-0.rockspec > /dev/null

test: build
	@luacheck --no-unused-args --std max+busted *.lua spec
	@busted --verbose --coverage

test_setup:
	luarocks install luacheck
	luarocks install ldoc
	luarocks install markdown
	luarocks install busted
	luarocks install luacov
	luarocks install luacov-coveralls

docs:
	@rm -rf doc && mkdir doc
	@ldoc outcome.lua

publish_docs: docs
	rm -rf /tmp/outcome-docs || true
	mkdir /tmp/outcome-docs
	cp doc/* /tmp/outcome-docs
	git checkout gh-pages
	cp /tmp/outcome-docs/* ./
	rm -rf /tmp/outcome-docs || true
	git add -A
	git commit -m "Updating documentation"
	git push origin docs
	git checkout master

release:
	make test
	$(if $(TAG),,$(error TAG is not defined. Pass via "make tag TAG=1.0.0"))
	$(if $(LUAROCKS),,$(error LUAROCKS api key is not defined))
	@echo Tagging $(TAG)
	chag update $(TAG)
	sed -i '' -e "s/_VERSION = \".*\"/_VERSION = \"$(TAG)\"/" outcome.lua
	git add -A
	git commit -m '$(TAG) release'
	chag tag
	git push origin master
	git push origin $(TAG)
	make publish_docs
	luarocks pack outcome
	luarocks upload outcome-$(TAG)-0.all.rock --api-key=$(LUAROCKS)
	rm outcome-$(TAG)-0.all.rock

.PHONY: test build travis docs publish_docs release