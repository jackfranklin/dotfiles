local ls = require('luasnip')

return {
  ls.parser.parse_snippet("svcomp", [[<script>
  $0
</script>
$1
<style>
$2
</style>]]
  ),
}
