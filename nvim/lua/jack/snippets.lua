local ls = require("luasnip")
local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local repeat_and_change = function(placeholder_index, index_to_copy)
  return d(placeholder_index, function(args)
    return sn(nil, i(1, args[index_to_copy]))
  end, { index_to_copy })
end
local M = {}

M.utils = {}
M.utils.repeat_and_change = repeat_and_change

M.all = function()
  return {
    s("todobug", fmt([[ TODO({}): {}]], { i(1), i(0) })),
    s("todoplain", fmt([[ TODO: {}]], { i(0) })),
  }
end

M.javascript = function()
  return {
    s("jslog", fmt([[console.log(JSON.stringify({}, null, 2));{}]], { i(1), i(0) })),
    s("fixme", fmt([[// FIXME: {}]], { i(0) })),

    s("cl", fmt("console.log({});", { i(1) })),

    -- clo: smart console.log
    s(
      "clo",
      fmt("console.log('{}', {});", {
        repeat_and_change(2, 1),
        i(1),
      })
    ),

    -- ima: import * as foo from bar
    s("ima", fmt([[import * as {} from '{}';]], { i(2), i(1) })),

    -- imn: import {} from foo
    s("imn", fmt([[import {{{}}} from '{}';]], { i(2), i(1) })),

    -- imd: import baz from foo
    s("imd", fmt([[import {} from '{}';]], { i(2), i(1) })),

    -- connectedCallback
    s(
      "connCall",
      fmt(
        [[
connectedCallback() {{
  this.#shadow.adoptedStyleSheets = [{}];
}}
    ]],
        { i(1) }
      )
    ),

    -- describe
    s(
      "desc",
      fmt(
        [[describe('{}', () => {{
  {}
}});]],
        { i(1), i(0) }
      )
    ),

    -- it, with the option to be async
    s(
      "spec",
      fmt(
        [[it('{}', {}() => {{
  {}
}});]],
        { i(1), c(2, { t("async "), t("") }), i(0) }
      )
    ),

    s(
      "custom-element",
      fmt(
        [[class {} extends HTMLElement {{
  #shadow = this.attachShadow({{ mode: 'open' }});

  #render(): void {{
  }}
}}

customElements.define({}, {})]],
        { i(1), i(2), rep(1) }
      )
    ),

    s("tag", fmt([[<{}{}>{}</{}>]], { i(1), i(2), i(0), rep(1) })),

    -- if
    s(
      "iff",
      fmt(
        [[if({}) {{
  {}
}}]],
        { i(1), i(0) }
      )
    ),

    -- if else
    s(
      "elif",
      fmt(
        [[if({}) {{
  {}
}} else {{
  {}
}}]],
        { i(1), i(2), i(0) }
      )
    ),
    -- if not
    s(
      "ifnot",
      fmt(
        [[if(!{}) {{
  {}
}}]],
        { i(1), i(0) }
      )
    ),
    -- if not then throw
    s(
      "ifnotthrow",
      fmt(
        [[if(!{}) {{
  throw new Error('{}');
}}]],
        { i(1), i(0) }
      )
    ),
    -- for const of
    s(
      "fforof",
      fmt(
        [[for (const {} of {}) {{
  {}
}}]],
        { i(1), i(2), i(0) }
      )
    ),
    s(
      "ffunc",
      fmt(
        [[{}function {}({}) {{
  {}
}}]],
        { c(1, { t("export "), t("") }), i(2), i(3), i(0) }
      )
    ),
    s(
      "cbf",
      fmt(
        [[({}) => {{
  {}
}}]],
        { i(1), i(0) }
      )
    ),
    s("ccon", fmt([[const {} = {}]], { i(1), i(0) })),
    s("destruct", fmt([[const {{ {} }} = {}]], { i(1), i(0) })),
    s("ase", fmt([[assert.strictEqual({}, {})]], { i(1), i(0) })),
    s("ade", fmt([[assert.deepEqual({}, {})]], { i(1), i(0) })),
    s("ait", fmt([[assert.isTrue({})]], { i(0) })),
    s("aif", fmt([[assert.isFalse({})]], { i(0) })),
    s(
      "cdoc",
      fmt(
        [[
/**
 * {}
 */]],
        { i(0) }
      )
    ),
    s(
      "lit-html-component",
      fmt(
        [[import {{ html, render }} from 'lit-html';
import styles from './{}.css';

export class {} extends HTMLElement {{
  #shadow = this.attachShadow({{ mode: 'open' }});

  connectedCallback() {{
    this.#shadow.adoptedStyleSheets = [styles];
  }}

  #render(): void {{
    render(html`<p>hello world</p>`, this.#shadow, {{ host: this }});
  }}
}}

customElements.define('{}', {});
{}]],
        { i(1), i(2), rep(1), rep(2), i(0) }
      )
    ),
  }
end

M.typescript = function()
  return {
    s(
      "ffunc",
      fmt(
        [[{}function {}({}): {} {{
  {}
}}]],
        { c(1, { t("export "), t("") }), i(2), i(3), i(4), i(0) }
      )
    ),
    s(
      "inter",
      fmt(
        [[interface {} {{
  {}
}}]],
        { i(1), i(0) }
      )
    ),
    s(
      "meth",
      fmt(
        [[{}({}): {} {{
  {}
}}]],
        { i(1), i(2), i(3), i(0) }
      )
    ),
    s(
      "##",
      fmt(
        [[#{}({}): {} {{
  {}
}}]],
        { i(1), i(2), i(3), i(0) }
      )
    ),
    s("tsmap", fmt([[new Map<{}, {}>({})]], { i(1), i(2), i(0) })),
  }
end

M.lua = function()
  return {
    ls.parser.parse_snippet(
      "lf",
      [[local $1 = function($2)
  $0
end]]
    ),
  }
end

M.svelte = function()
  return {
    ls.parser.parse_snippet(
      "svcomp",
      [[<script>
  $0
</script>
$1
<style>
$2
</style>]],
      {}
    ),
    ls.parser.parse_snippet("svimp", [[import $1 from './$1.svelte';]]),
  }
end

return M
