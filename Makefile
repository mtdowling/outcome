clean:
	rm -rf docs

build:
	@luarocks make rockspecs/$$(ls rockspecs/ | tail -n 1) > /dev/null

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

docs: clean
	@rm -rf doc && mkdir doc
	@ldoc outcome.lua

publish_docs: docs
	rm -rf /tmp/outcome-docs || true
	mkdir /tmp/outcome-docs
	cp -R doc/* /tmp/outcome-docs
	git checkout gh-pages
	cp -R /tmp/outcome-docs/* ./
	rm -rf /tmp/outcome-docs || true
	git add -A
	git commit -m "Updating documentation"
	git push origin gh-pages
	git checkout master

release:
	make test
	$(if $(TAG),,$(error TAG is not defined. Pass via "make tag TAG=1.0.0"))
	$(if $(LUAROCKS),,$(error LUAROCKS api key is not defined))
	@echo Tagging $(TAG)
	chag update $(TAG)
	sed -i '' -e "s/_VERSION = \".*\"/_VERSION = \"$(TAG)\"/" outcome.lua
	git add -A && git commit -m '$(TAG) release' || echo "Already updated. Skipping"
	chag tag || echo "Already tagged. Skipping"
	git push origin master && git push origin $(TAG)
	make publish_docs
	luarocks pack outcome
	luarocks upload rockspecs/outcome-$(TAG)-0.rockspec --api-key=$(LUAROCKS)
	rm outcome-$(TAG)-0.all.rock || true
	rm outcome-$(TAG)-0.src.rock

bench: build
	lua bench/bench.lua
	luajit bench/bench.lua

.PHONY: clean test build travis docs publish_docs release
