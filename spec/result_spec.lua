local outcome = require "outcome"

describe("Result", function()

  it("returns an instance of Result for Ok", function()
    local value = outcome.ok("foo")
    assert.equal("outcome.Result", value.class)
    assert.equal("foo", value:unwrap())
    value = outcome.err("foo")
    assert.equal("outcome.Result", value.class)
    assert.equal("foo", value:unwrapErr())
  end)

  describe("when comparing Results", function()
    it("checks for equality", function()
      local a = outcome.ok("a")
      local b = outcome.ok("a")
      assert.is_true(a == b)
      a = outcome.ok("a")
      b = outcome.ok("b")
      assert.is_false(a == b)
      a = outcome.err("a")
      b = outcome.ok("a")
      assert.is_false(a == b)
      a = outcome.err("a")
      b = outcome.err("a")
      assert.is_true(a == b)
      a = outcome.err("a")
      b = outcome.err("b")
      assert.is_false(a == b)
    end)

    it("gracefully handles nil comparisons", function()
      local a = outcome.ok("a")
      local b = outcome.ok(nil)
      assert.is_false(a == b)
      assert.is_false(a < b)
      assert.is_false(a <= b)
    end)

    it("checks for less than", function()
      local a = outcome.ok(1)
      local b = outcome.ok(2)
      assert.is_true(a < b)
      assert.is_true(a <= b)
    end)
  end)

  describe("when calling isOk or isErr", function()
    it("handles ok values", function()
      local value = outcome.ok("a")
      assert.is_true(value:isOk())
      assert.is_false(value:isErr())
    end)

    it("handles err", function()
      local value = outcome.err("foo")
      assert.is_false(value:isOk())
      assert.is_true(value:isErr())
    end)
  end)

  describe("when calling ifOk or ifErr", function()
    it("handles ok values", function()
      local value = outcome.ok(1)
      local v, e
      value:ifOk(function(okValue) v = okValue end)
      value:ifErr(function(err) e = err end)
      assert.equal(1, v)
      assert.is_nil(e)
    end)

    it("handles err values", function()
      local value = outcome.err(1)
      local v, e
      value:ifOk(function(okValue) v = okValue end)
      value:ifErr(function(err) e = err end)
      assert.equal(1, e)
      assert.is_nil(v)
    end)
  end)

  describe("when unwrapping values", function()
    it("raises error for an err result", function()
      local value = outcome.err("abc")
      assert.has_error(function() value:unwrap() end, "abc")
      assert.has_error(function() value:expect("Baz!") end, "Baz!")
    end)

    it("returns value when ok", function()
      local value = outcome.ok("foo")
      assert.equal("foo", value:unwrap())
      assert.equal("foo", value:unwrapOr("bar"))
      assert.equal("foo", value:unwrapOrElse(function() return "bar" end))
      assert.equal("foo", value:expect("Missing value?"))
    end)

    it("returns other if err", function()
      local value = outcome.err("e")
      assert.equal("foo", value:unwrapOr("foo"))
      assert.equal("bar", value:unwrapOrElse(function() return "bar" end))
    end)
  end)

  describe("when composing result", function()
    it("returns other result when result is err", function()
      local value = outcome.err("e")
      local result = value:orOther(outcome.ok("bar"))
      assert.equal("bar", result:unwrap())
      result = value:orElseOther(function() return outcome.ok("baz") end)
      assert.equal("baz", result:unwrap())
    end)

    it("returns self when result is ok", function()
      local value = outcome.ok("foo")
      local result = value:orOther(outcome.ok("bar"))
      assert.equal("foo", result:unwrap())
      result = value:orElseOther(function() return outcome.ok("baz") end)
      assert.equal("foo", result:unwrap())
    end)

    it("maps over value when ok", function()
      local value = outcome.ok(1)
      local result = value:map(function(v) return v + 1 end)
      assert.equal(2, result:unwrap())
      assert.equal(1, value:unwrap())
    end)

    it("does not map over value when value is err", function()
      local value = outcome.err("a")
      local result = value:map(error)
      assert.is_true(result:isErr())
    end)

    it("maps over err when err", function()
      local value = outcome.err(1)
      local result = value:mapErr(function(v) return v + 1 end)
      assert.equal(2, result:unwrapErr())
    end)

    it("does not map over err when value is ok", function()
      local value = outcome.ok()
      local result = value:mapErr(error)
      assert.is_true(result:isOk())
    end)

    it("flatmaps over values", function()
      local value = outcome.ok(1)
      local result = value:flatmap(function() return outcome.ok(2) end, error)
      assert.equal(2, result:unwrap())
    end)
  end)
end)
