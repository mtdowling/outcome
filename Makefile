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

.PHONY: test build travis docs
