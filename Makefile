build:
	@luarocks make rockspecs/outcome-1.0-0.rockspec > /dev/null

test: build
	@busted --verbose --coverage

docs:
	@rm -rf build && mkdir build
	@ldoc -d build -f markdown -t "Outcome documentation" -p Outcome -b outcome outcome.lua

travis: test
	luacheck --no-unused-args --std max+busted *.lua spec

.PHONY: test build travis docs
