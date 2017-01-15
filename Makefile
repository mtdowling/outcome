build:
	@luarocks make rockspecs/outcome-1.0-0.rockspec > /dev/null

test_setup:
	luarocks install luacheck
	luarocks install busted
	luarocks install luacov
	luarocks install luacov-coveralls

test: build
	@busted --verbose --coverage

docs:
	@rm -rf build && mkdir build
	@ldoc -d build -f markdown -t "Outcome documentation" -p Outcome -b outcome outcome.lua

travis: test
	luacheck --no-unused-args --std max+busted *.lua spec

release_docs: docs
	rm -rf /tmp/outcome-docs || true
	mkdir /tmp/outcome-docs
	cp build/* /tmp/outcome-docs
	git checkout docs
	cp /tmp/outcome-docs/* ./
	rm -rf /tmp/outcome-docs || true
	git add -A
	git commit -m "Updating documentation"
	git push origin docs
	git checkout master

.PHONY: test build travis docs
