local ls = require('luasnip')
local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep;
local repeat_and_change = function(placeholder_index, index_to_copy)
  return d(placeholder_index, function(args)
    return sn(nil, i(1, args[index_to_copy]))
  end, {index_to_copy})
end
return {
  s("thisp", fmt("this.#{}", {i(1)})),
  s("defp", fmt("#{}({}):{} {{{}}}", {i(1), i(2), i(3), i(4)})),
  s("cl", fmt("console.log({});", {i(1)})),

  -- clo: smart console.log
  s("clo", fmt("console.log('{}', {});", {
    repeat_and_change(2, 1),
    i(1),
  })),

  -- ima: import * as foo from bar
  s("ima", fmt([[import * as {} from '{}.js';]], {i(2), i(1)})),

  -- imn: import {} from foo
  s("imn", fmt([[import {{{}}} from '{}.js';]], {i(2), i(1)})),

  -- describe
  s("desc", fmt([[describe('{}', () => {{
  {}
}});]], {i(1), i(0)})),

  -- it, with the option to be async
  s("spec", fmt([[it('{}', {}() => {{
  {}
}});]], {i(1), c(2, {t "async ", t ""}), i(0)})),

  s("custom-element", fmt([[class {} extends HTMLElement {{
  #shadow = this.attachShadow({{ mode: 'open' }});

  #render(): void {{
  }}
}}

customElements.define({}, {})]], {i(1), i(2), rep(1)})),
}
