build:
	luarocks make rockspecs/outcome-1.0-0.rockspec > /dev/null

test: build
	busted

docs:
	@rm -rf build && mkdir build
	@ldoc -d build -f markdown -t "Outcome documentation" -p Outcome -b outcome outcome.lua

.PHONY: test build
