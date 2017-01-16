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
present. An Option that has no value is *None*. If an Option has a value, the
value can be retrieved using `unwrap()`. Calling `unwrap()` on a None Option
will result in an error.

Returning an Option type from a function rather than returning a value that may
be `nil` helps to avoid null pointer errors and provides composable
abstractions over the result.

**Examples**

```lua
local outcome = require "outcome"

-- Options are either None or Some.
assert(outcome.none():isNone())
assert(outcome.some("foo"):isSome())

-- You can map over the value in an Option.
local result = outcome.some(1)
    :map(function(value) return value + 1 end)
    :unwrap()
assert(result == 2)

-- Raises an error with the message provided in expect.
outcome.none():expect("Expected a value"):

-- You can provide a default value when unwrapping an Option.
assert("foo" == outcome.none():unwrapOr("foo"))
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
assert(outcome.ok("ok value"):isOk())
assert(outcome.err("error value"):isErr())

-- You can map over the Ok value in a Result.
local result = outcome.ok(1)
    :map(function(value) return value + 1 end)
    :unwrap()
assert(result == 2)

-- Raises an error with the message provided in expect.
outcome.err("error value"):expect("Result was not Ok"):

-- You can provide a default value when unwrapping a Result.
assert("foo" == outcome.err("error value"):unwrapOr("foo"))
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

There's a really simply benchmark tool that can be run using the following
command:

```
make bench
```
