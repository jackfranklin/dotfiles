local m = require("alternate-files")
describe("Alternate files", function()
  it("finds the right possible files", function()
    local alternates = m.generate_potential_alternatives("/foo.ts", {
      [".test.ts"] = { ".ts" },
      [".ts"] = { ".test.ts", ".css" },
      [".css"] = { ".ts" },
    })
    assert.are_same({
      "/foo.test.ts",
      "/foo.css",
    }, alternates)
  end)
end)
