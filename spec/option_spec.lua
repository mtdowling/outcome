local outcome = require "outcome"
local Option = outcome.Option

describe("Option", function()
  describe("when creating Option", function()
    it("returns an instance of Option for empty", function()
      local value = Option.empty()
      assert.equal(Option, getmetatable(value).__index)
    end)

    it("returns an instance of Option for of", function()
      local value = Option.of("foo")
      assert.equal(Option, getmetatable(value).__index)
      assert.equal("foo", value:unwrap())
    end)
  end)

  describe("when comparing Options", function()
    it("checks for equality", function()
      local a = Option.of("a")
      local b = Option.of("a")
      assert.is_true(a == b)
      a = Option.of("a")
      b = Option.empty()
      assert.is_false(a == b)
    end)

    it("gracefully handles nil comparisons", function()
      local a = Option.empty()
      local b = Option.of("a")
      assert.is_false(a == b)
      assert.is_false(a < b)
      assert.is_false(a <= b)
    end)

    it("checks for less than", function()
      local a = Option.of(1)
      local b = Option.of(2)
      assert.is_true(a < b)
      assert.is_true(a <= b)
    end)
  end)

  describe("when calling isPresent or isEmpty", function()
    it("handles empty values", function()
      local value = Option.empty()
      assert.is_true(value:isEmpty())
      assert.is_false(value:isPresent())
    end)

    it("handles values", function()
      local value = Option.of("foo")
      assert.is_false(value:isEmpty())
      assert.is_true(value:isPresent())
    end)
  end)

  describe("when calling ifPresent or ifEmpty", function()
    it("handles empty values", function()
      local value = Option.empty()
      local called = 0
      value:ifPresent(function() called = called + 1 end)
      value:ifEmpty(function() called = called + 2 end)
      assert.equal(2, called)
    end)

    it("handles values", function()
      local value = Option.of("foo")
      local called = 0
      value:ifPresent(function() called = called + 1 end)
      value:ifEmpty(function() called = called + 2 end)
      assert.equal(1, called)
    end)
  end)

  describe("when unwrapping values", function()
    it("raises error for an empty option", function()
      local value = Option.empty()
      assert.has_error(function() value:unwrap() end,
          "Call to unwrap on a nil value")
      assert.has_error(function() value:expect("Baz!") end, "Baz!")
    end)

    it("returns value when not empty", function()
      local value = Option.of("foo")
      assert.equal("foo", value:unwrap())
      assert.equal("foo", value:unwrapOr("bar"))
      assert.equal("foo", value:unwrapOrElse(function() return "bar" end))
      assert.equal("foo", value:expect("Missing value?"))
    end)

    it("returns other if none", function()
      local value = Option.empty()
      assert.equal("foo", value:unwrapOr("foo"))
      assert.equal("bar", value:unwrapOrElse(function() return "bar" end))
    end)
  end)

  describe("takes values", function()
    it("takes nothing from an empty option", function()
      local value = Option.empty()
      local result = value:take()
      assert.is_true(value:isEmpty())
      assert.is_true(result:isEmpty())
    end)

    it("takes values from an option", function()
      local value = Option.of("foo")
      assert.is_false(value:isEmpty())
      assert.equal("foo", value:take():unwrap())
      assert.is_true(value:isEmpty())
    end)
  end)

  describe("when composing options", function()
    it("returns other option when option is empty", function()
      local value = Option.empty()
      local result = value:orOther(Option.of("bar"))
      assert.equal("bar", result:unwrap())
      result = value:orElseOther(function() return Option.of("bar") end)
      assert.equal("bar", result:unwrap())
    end)

    it("returns self when not empty", function()
      local value = Option.of("foo")
      local result = value:orOther(Option.of("bar"))
      assert.equal("foo", result:unwrap())
      result = value:orElseOther(function() return Option.of("foo") end)
      assert.equal("foo", result:unwrap())
    end)

    it("maps over value when present", function()
      local value = Option.of(1)
      local result = value:map(function(v) return v + 1 end)
      assert.equal(2, result:unwrap())
      assert.equal(1, value:unwrap())
    end)

    it("does not map over value when value is empty", function()
      local value = Option.empty()
      local result = value:map(error)
      assert.is_true(result:isEmpty())
    end)

    it("returns default value from mapOr when empty", function()
      local value = Option.empty()
      local result = value:mapOr("foo", error)
      assert.equal("foo", result:unwrap())
    end)

    it("returns mapped value from mapOrElse when not emoty", function()
      local value = Option.of(1)
      local result = value:mapOrElse(error, function(v) return v + 1 end)
      assert.equal(2, result:unwrap())
    end)

    it("returns result of default value from mapOrElse when empty", function()
      local value = Option.empty()
      local result = value:mapOrElse(function() return "foo" end, error)
      assert.equal("foo", result:unwrap())
    end)

    it("flatmaps over values", function()
      local value = Option.of(1)
      local result = value:flatmap(function() return Option.of(2) end, error)
      assert.equal(2, result:unwrap())
    end)
  end)
end)
