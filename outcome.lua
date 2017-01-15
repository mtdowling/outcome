--- Outcome: Functional and composable option and result types for Lua.
-- @module outcome
local outcome = {
  _VERSION     = "1.0.0",
  _DESCRIPTION = 'Functional and composable option and result types for Lua.',
  _URL         = 'https://github.com/mtdowling/outcome',
  _LICENSE     = [[
    MIT LICENSE
    Copyright (c) 2017 Michael Dowling

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
  ]]
}

local assert, type = assert, type
local setmetatable, getmetatable = setmetatable, getmetatable

--- Option type.
--
-- The Option class is used as a functional replacement for null. Using Option
-- provides a composable mechanism for working with values that may or may not
-- be present. This Option implementation is heavily inspired by the Option
-- type in Rust, and somewhat by the Optional type in Java.
--
-- @type Option
local Option = {}

local OptionMetatable = {
  __index = Option,
  __lt = function (lhs, rhs)
    return lhs._value ~= nil and rhs._value ~= nil and lhs._value < rhs._value
  end,
  __le = function (lhs, rhs)
    return lhs._value ~= nil and rhs._value ~= nil and lhs._value <= rhs._value
  end,
  __eq = function(a, b)
    return a._value == b._value
  end
}

local function assertOption(value)
  assert(type(value) == "table" and getmetatable(value) == OptionMetatable,
      "Value must be an `Option<T>`. Found " .. type(value))
  return value
end

--- Create a new Option, wrapping a value.
-- If the provided value is nil, then the Option is considered empty.
-- @param value Value T to wrap.
-- @treturn Option `Option<T>`
function Option.of(value)
  return setmetatable({_value = value}, OptionMetatable)
end

--- Returns an empty Option.
-- @treturn Option Returns `Option<T>`
-- @treturn Option `Option<T>`
function Option.empty()
  return outcome._EMPTY_OPTION
end

--- Returns true if the option contains a value.
-- @treturn bool
function Option:isPresent()
  return self._value ~= nil
end

--- Returns true if the option value is nil.
-- @treturn bool
function Option:isEmpty()
  return self._value == nil
end

--- Returns the value if present, or throws an error.
-- @return T the wrapped option.
function Option:unwrap()
  return self:expect()
end

--- Unwraps and returns the value if present, or raises a specific error.
-- @tparam string message Message to raise.
-- @return T returns the wrapped value.
function Option:expect(message)
  assert(self._value ~= nil, message or "Call to unwrap on a nil value")
  return self._value
end

--- Unwraps and returns the value if present, or returns default value.
-- @param defaultValue Default value T to return.
-- @return T returns the wrapped value or the default.
function Option:unwrapOr(defaultValue)
  if self._value ~= nil then
    return self._value
  else
    return defaultValue
  end
end

--- Unwraps and returns the value if present, or returns the result of invoking
-- a function that when called returns a value.
-- @tparam function valueProvider to invoke if the value is empty.
-- @return T returns the wrapped value or the value returned from valueProvider.
function Option:unwrapOrElse(valueProvider)
  if self._value ~= nil then
    return self._value
  else
    return valueProvider()
  end
end

--- Takes the value out of the option, leaving a nil in its place.
-- @treturn Option Returns `Option<T>`
function Option:take()
  if self._value == nil then
    return Option.empty()
  end
  local result = Option.of(self._value)
  self._value = nil
  return result
end

--- Invokes a method with the value if present.
-- @tparam function consumer Consumer to invoke with a side effect.
function Option:ifPresent(consumer)
  if self._value ~= nil then
    consumer(self._value)
  end
end

--- Invokes a method if the option value is empty.
-- @tparam function consumer Method to invoke if the value is empty.
function Option:ifEmpty(consumer)
  if self._value == nil then
    consumer()
  end
end

--- Returns `other` if the option value is present, otherwise returns self.
-- @tparam `Option<T>` other Alternative Option to return.
-- @treturn Option Returns `Option<T>`
function Option:andOther(other)
  if self._value == nil then
    return assertOption(other)
  else
    return self
  end
end

--- Returns self if a value is present, otherwise returns `other`.
-- @tparam `Option<T>` other Alternative Option to return.
-- @treturn Option Returns `Option<T>`
function Option:orOther(other)
  if self._value ~= nil then
    return self
  else
    return assertOption(other)
  end
end

--- Returns self if a value is present, otherwise returns the result of f.
-- @tparam function f Function that returns an `Option<T>`.
-- @treturn Option Returns `Option<T>`
function Option:orElseOther(f)
  if self._value ~= nil then
    return self
  else
    return assertOption(f())
  end
end

--- Maps an `Option<T>` to `Option<U>` by applying a function to the contained
-- value.
-- @tparam function f Function that accepts T and returns U.
-- @treturn Option Returns `Option<U>`
function Option:map(f)
  if self._value == nil then
    return self
  else
    return Option.of(f(self._value))
  end
end

--- Applies a function to the contained value (if any), or returns a default.
-- @param defaultValue Value U to return if the option is empty.
-- @tparam function f Function that accepts T and returns U.
-- @treturn Option Returns `Option<U>`
function Option:mapOr(defaultValue, f)
  if self._value == nil then
    return Option.of(defaultValue)
  else
    return Option.of(f(self._value))
  end
end

--- Applies a function to the contained value (if any), or computes a default.
-- @tparam function defaultProvider Default function to invoke that returns U.
-- @tparam function mapFunction Function that accepts T and returns U.
-- @treturn Option Returns `Option<U>`
function Option:mapOrElse(defaultProvider, mapFunction)
  if self._value == nil then
    return Option.of(defaultProvider())
  else
    return Option.of(mapFunction(self._value))
  end
end

--- Returns an empty option if the option value is not preset. Otherwise calls
-- f with the wrapped value and returns the result.
-- @tparam function f Function that accepts T and returns `Option<U>`.
-- @treturn Option Returns `Option<U>`
function Option:flatmap(f)
  if self._value == nil then
    return self
  else
    return assertOption(f(self._value))
  end
end

--- Transforms the `Option<T>` into a `Result<T, E>`, mapping a present value to
-- an Ok Result, and an empty value to Result err.
-- @tparam function err Error to use in the Result if the value is empty.
-- @treturn Result Returns `Result<T, E>`
function Option:okOr(err)
  if self._value ~= nil then
    return outcome.Result.ok(self._value)
  else
    return outcome.Result.err(err)
  end
end

--- Transforms the `Option<T>` into a `Result<T, E>`, mapping a present value
-- to an Ok Result, and an empty value to Result err.
-- @tparam function errorProvider Function that returns E.
-- @treturn Result Returns `Result<T, E>`
function Option:okOrElse(errorProvider)
  if self._value ~= nil then
    return outcome.Result.ok(self._value)
  else
    return outcome.Result.err(errorProvider())
  end
end

--- `Result<T, E>` is a type used for returning and propagating errors.
--
-- There are two kinds of Result objects:
--
-- * Ok: the result contains a successful value.
-- * Err: The result contains an error value.
--
-- @type Result
local Result = {}

local ResultMetatable = {
  __index = Result,
  __lt = function (lhs, rhs)
    return lhs._kind == rhs._kind and lhs._value < rhs._value
  end,
  __le = function (lhs, rhs)
    return lhs._kind == rhs._kind and lhs._value <= rhs._value
  end,
  __eq = function(lhs, rhs)
    return lhs._kind == rhs._kind and lhs._value == rhs._value
  end
}

local OK, ERR = true, false

local function assertResult(value)
  assert(type(value) == "table" and getmetatable(value) == ResultMetatable,
      "Value must be a `Result<T, E>`. Found " .. type(value))
  return value
end

--- Create a new Ok Result.
-- @tparam T value Ok value to wrap.
-- @treturn Result Returns `Result<T, E>`
function Result.ok(value)
  return setmetatable({_value = value, _kind = OK}, ResultMetatable)
end

--- Create a new Err Result.
-- @tparam T value Error value to wrap.
-- @treturn Result Returns `Result<T, E>`
function Result.err(value)
  return setmetatable({_value = value, _kind = ERR}, ResultMetatable)
end

--- Invokes a function and returns a `Result<T, E>`.
-- If the function errors, an Err Result is returned.
-- @tparam function f Function to invoke that returns T or raises E.
-- @tparam ... Arguments to pass to the function.
-- @treturn Result Returns `Result<T, E>`
function Result.pcall(f, ...)
  local value, err = pcall(f, ...)
  if err then
    return Result.ok(value)
  else
    return Result.err(err)
  end
end

--- Returns true if the result is Ok.
-- @treturn bool
function Result:isOk()
  return self._state == OK
end

--- Returns true if the result is an error.
-- @treturn bool
function Result:isErr()
  return self._state == ERR
end

local function errorToString(value)
  local valueType = type(value)
  if valueType == "string" then
    return value
  elseif valueType == "table" then
    local mt = getmetatable(value)
    return mt and mt.__tostring and string(value) or "table error"
  elseif valueType == "nil" then
    return "nil error"
  elseif valueType == "boolean" then
    return "boolean error (" .. value .. ")"
  elseif valueType == "number" then
    return "number error (" .. value .. ")"
  else
    return "error of type " .. valueType
  end
end

--- Returns the value if Ok, or raises an error using the error value.
-- @return T the wrapped result value.
-- @raise Errors with if the result is Err.
function Result:unwrap()
  if self._kind == ERR then
    error(errorToString(self._value))
  end
  return self._value
end

--- Unwraps a result, yielding the content of an Err.
-- @return E the error value.
-- @raise Errors if the value is Ok.
function Result:unwrapErr()
  assert(self._kind == ERR, "Call to unwrapErr on an Ok Result")
  return self._value
end

--- Unwraps and returns the value if Ok, or errors with a message.
-- @tparam string message Message to include in the error.
-- @return T returns the wrapped value.
function Result:expect(message)
  assert(self._kind == OK, message)
  return self._value
end

--- Unwraps and returns the value if Ok, or returns default value.
-- @param defaultValue Default value T to return.
-- @return T returns the wrapped value or the default.
function Result:unwrapOr(defaultValue)
  if self._kind == OK then
    return self._value
  else
    return defaultValue
  end
end

--- Unwraps and returns the value if Ok, or returns the result of invoking
-- a method that when called returns a value.
-- @tparam function valueProvider Function to invoke if the value is an error.
-- @return T returns the Ok value or the value returned from valueProvider.
function Result:unwrapOrElse(valueProvider)
  if self._kind == OK then
    return self._value
  else
    return valueProvider()
  end
end

--- Invokes a method with the value if the Result is Ok.
-- @tparam function consumer Consumer to invoke with a side effect.
function Result:ifOk(consumer)
  if self._kind == OK then
    consumer(self._value)
  end
end

--- Invokes a method if the Result is an Err and passes the error to consumer.
-- @tparam function consumer Method to invoke if the value is error.
function Result:ifErr(consumer)
  if self._kind == ERR then
    consumer(self._value)
  end
end

--- Converts from `Result<T, E>` to `Option<T>`.
-- Converts self into an `Option<T>`, consuming self, and discarding the error,
-- if any.
-- @treturn Result Returns `Result<T, E>`
function Result:okOption()
  if self._kind == OK then
    return Option.of(self._value)
  else
    return Option.empty()
  end
end

--- Converts from `Result<T, E>` to `Option<E>`.
-- Converts self into an `Option<E>`, consuming self, and discarding the
-- success value, if any.
-- @treturn Result Returns `Result<T, E>`
function Result:errOption()
  if self._kind == ERR then
    return Option.of(self._value)
  else
    return Option.empty()
  end
end

--- Returns other if the result is Ok, otherwise returns the Err value of self.
-- @tparam Result other `Result<T, E>` other Alternative Result to return.
-- @treturn Result Returns `Result<T, E>`
function Result:andOther(other)
  if self._kind == OK then
    return assertResult(other)
  else
    return self
  end
end

--- Returns other if the result is Err, otherwise returns self.
-- @tparam Result other `Result<T, E>` other Alternative Result to return.
-- @treturn Result Returns `Result<T, E>`
function Result:orOther(other)
  if self._kind == OK then
    return self
  else
    return assertResult(other)
  end
end

--- Calls resultProvider if the result is Err, otherwise returns self.
--
-- This function can be used for control flow based on result values.
-- @tparam function resultProvider Function that returns `Result<T, E>`.
-- @treturn Result Returns `Result<T, E>`
function Result:orElseOther(resultProvider)
  if self._value ~= nil then
    return self
  else
    return assertOption(resultProvider())
  end
end

--- Maps a `Result<T, E>` to `Result<U, E>` by applying a function to a
-- contained Ok value, leaving an Err value untouched.
--
-- This function can be used to compose the results of two functions.
-- @tparam function f Function that accepts `T` and returns `U`.
-- @treturn Result Returns `Result<U, E>`
function Result:map(f)
  if self._kind == OK then
    return Result.ok(f(self._value))
  else
    return self
  end
end

--- Maps a `Result<T, E>` to `Result<T, F>` by applying a function to a
-- contained Err value, leaving an Ok value untouched.
--
-- This function can be used to pass through a successful result while handling
-- an error.
-- @tparam function f Function that accepts `E` and returns `U`.
-- @treturn Result Returns `Result<T, F>`
function Result:mapErr(f)
  if self._kind == ERR then
    return Result.err(f(self._value))
  else
    return self
  end
end

--- Calls f if the result is Ok, otherwise returns the Err value of self.
--
-- This function can be used for control flow based on Result values.
-- @tparam function f Function that accepts T and returns `Result<T. E>`.
-- @treturn Result Returns `Result<T, E>`
function Result:flatmap(f)
  if self._kind == OK then
    assertResult(f(self._value))
  else
    return self
  end
end

outcome.Result = Result
outcome.Option = Option
outcome._EMPTY_OPTION = Option.of(nil)

return outcome
