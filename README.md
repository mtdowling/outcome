# Outcome

Outcome: functional and composable option and result types for Lua.

[Documentation](http://mtdowling.com/jmespath.rs/jmespath/)

Outcome provides two types:

* [Option](#option)
* [Result](#result)

## Option

TODO

## Result

TODO

## Installation

Just copy the `outcome.lua` file wherever you want it. Then write this in any
Lua file where you want to use it:

```lua
local outcome = require "outcome"
```

## Tests

This project uses [busted](https://github.com/Olivine-Labs/busted) for testing.
If you want to run the tests, you will have to install busted first.

```
luarocks install busted
```

After busted is installed, execute the following:

```
busted
```
