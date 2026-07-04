local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("maincpp", {
    t({
      "#include <iostream>",
      "#include <vector>",
      "using namespace std",
      "",
      "int main() {",
      i(1, "    "),
      "    cout << \"Hello, World!\" << endl;",
      "    return 0;",
      "}",
    }),
  }),
  -- 他のC++テンプレートスニペットの追加可能
}
