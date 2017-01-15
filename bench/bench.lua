local outcome = require "outcome"

local tests = {}
local ns = 1000000000

local function runbenchmark(name, f, count)
  local clock = os.clock
  local start = clock()
  for _ = 1, count do f() end
  local time = clock() - start
  io.write(string.format("%20.10f ns/iter\t%s\n", (time / count) * ns, name))
end

local function bench(name, f)
  tests[name] = f
end

local function run(count)
  for name, f in pairs(tests) do
    runbenchmark(name, f, count)
  end
end

local function someOptionProvider(v)
  return outcome.some(v)
end

local function someValueProvider(v)
  return v
end

local function noneOptionProvider()
  return outcome.none()
end

local function noneValueProvider()
  return nil
end

bench("create option", function()
  local _ = outcome.some(1)
end)

bench("map some option", function()
  return someOptionProvider(1)
      :map(function(value) return value + 1 end)
      :unwrap()
end)

bench("map some if", function()
  local r = someValueProvider(1)
  if r ~= nil then r = r + 1 end
  assert(r ~= nil)
  return r
end)

bench("map none option", function()
  return noneOptionProvider()
      :map(function(value) return value + 1 end)
      :unwrapOr(1)
end)

bench("map none if", function()
  local r = noneValueProvider()
  if r ~= nil then
    r = r + 1
  end
  if r ~= nil then
    return 1
  else
    return nil
  end
end)

run(1000000)
