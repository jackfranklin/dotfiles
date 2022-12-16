local ls = require("luasnip")

return {
  ls.parser.parse_snippet(
    "svcomp",
    [[<script>
  $0
</script>
$1
<style>
$2
</style>]]
  ),
  ls.parser.parse_snippet("svimp", [[import $1 from './$1.svelte';]]),
}
