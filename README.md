# Outcome

[![Build Status](https://travis-ci.org/mtdowling/outcome.png?branch=master)](https://travis-ci.org/mtdowling/outcome)
[![Coverage Status](https://coveralls.io/repos/mtdowling/outcome/badge.svg?branch=master&service=github)](https://coveralls.io/github/mtdowling/outcome?branch=master)

Outcome: functional and composable option and result types for Lua. Outcome's
API is heavily inspired and based up the Rust
[Option](https://doc.rust-lang.org/std/option/enum.Option.html) and
[Result](https://doc.rust-lang.org/std/result/enum.Result.html) types.

* [Option](#option)
* [Result](#result)

The API documentation can be read online at http://mtdowling.com/outcome/.


## Option

The Option type is used to contain a non-nil result that may or may not be
present. An Option that has no value is *empty*. If an Option has a value, the
value can be retrieved using `unwrap()`. Calling `unwrap()` on an empty Option
will result in an error.

Returning an Option type from a function rather than returning a value that may
be `nil` helps to avoid null pointer errors and provides composable
abstractions over the result.

**Examples**

```lua
local outcome = require "outcome"
local Option = outcome.Option

-- Options are either empty or present.
assert(Option.empty():isEmpty())
assert(Option.of("foo"):isPresent())

-- You can map over the value in an Option.
local result = Option.of(1)
    :map(function(value) return value + 1 end)
    :unwrap()
assert(result == 2)

-- Raises an error with the message provided in expect.
Option.empty():expect("Expected a value"):

-- You can provide a default value when unwrapping an Option.
assert("foo" == Option.empty():unwrapOr("foo"))
```


## Result

`Result<T, E>` is a type used for returning and propagating errors.

There are two kinds of Result objects:

* Ok: the result contains a successful value.
* Err: The result contains an error value.

**Examples**

```lua
local outcome = require "outcome"
local Result = outcome.Result

-- Results are either Ok or Err.
assert(Result.ok("ok value"):isOk())
assert(Result.err("error value"):isErr())

-- You can map over the Ok value in a Result.
local result = Result.ok(1)
    :map(function(value) return value + 1 end)
    :unwrap()
assert(result == 2)

-- Raises an error with the message provided in expect.
Result.err("error value"):expect("Result was not Ok"):

-- You can provide a default value when unwrapping a Result.
assert("foo" == Result.err("error value"):unwrapOr("foo"))
```


## Installation

Just copy `outcome.lua` wherever you want it. Then write this in any Lua file
where you want to use it:

```lua
local outcome = require "outcome"
```

You can also install Outcome using [luarocks](https://luarocks.org/):

```
luarocks install outcome
```


## Tests

This project uses [busted](https://github.com/Olivine-Labs/busted) for testing.
If you want to run the tests, you will have to install busted first.

```
luarocks install busted
```

After busted is installed, execute the following command to run the tests:

```
make test
```
