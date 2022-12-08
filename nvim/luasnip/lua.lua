local ls = require("luasnip")

return {
	ls.parser.parse_snippet(
		"lf",
		[[local $1 = function($2)
  $0
end]]
	),
}
