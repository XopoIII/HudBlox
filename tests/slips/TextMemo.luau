--!strict
--- The slips of src/TextMemo.luau: each a small error in what a kept measurement is kept by, what
--- is kept at all and how many, and the rule it breaks.
const MUTANTS = {
	{
		file = "src/TextMemo.luau",
		from = "\ttable.sort(sorted)\n",
		to = "",
		breaks = "the candidates' order does not change the key",
	},
	{
		file = "src/TextMemo.luau",
		from = "const sorted = table.clone(candidates)",
		to = "const sorted = candidates",
		breaks = "the caller's list is left as it was",
	},
	{
		file = "src/TextMemo.luau",
		from = "{ family, weight, style, tostring(size), table.concat(sorted, SEPARATOR) }",
		to = "{ family, weight, tostring(size), table.concat(sorted, SEPARATOR) }",
		breaks = "another style is another key",
	},
	{
		file = "src/TextMemo.luau",
		from = "{ family, weight, style, tostring(size), table.concat(sorted, SEPARATOR) }",
		to = "{ family, style, tostring(size), table.concat(sorted, SEPARATOR) }",
		breaks = "another weight is another key",
	},
	{
		file = "src/TextMemo.luau",
		from = "{ family, weight, style, tostring(size), table.concat(sorted, SEPARATOR) }",
		to = "{ family, weight, style, table.concat(sorted, SEPARATOR) }",
		breaks = "another size is another key",
	},
	{
		file = "src/TextMemo.luau",
		from = "tostring(size), table.concat(sorted, SEPARATOR) }",
		to = "tostring(size), table.concat(sorted) }",
		breaks = "two candidates are not their joining",
	},
	{
		file = "src/TextMemo.luau",
		from = "\tif not (widest > 0) then\n\t\treturn\n\tend\n",
		to = "",
		breaks = "a failed pass is never kept",
	},
	{
		file = "src/TextMemo.luau",
		from = "if not (widest > 0) then",
		to = "if widest < 0 then",
		breaks = "a zero and what is not a number are failed passes",
	},
	{
		file = "src/TextMemo.luau",
		from = "\tif memo.answers[key] == nil then\n",
		to = "\tif true then\n",
		breaks = "a key kept again counts once",
	},
	{
		file = "src/TextMemo.luau",
		from = "if memo.count >= TextMemo.LIMIT then",
		to = "if memo.count > TextMemo.LIMIT then",
		breaks = "the answer over the limit starts the memo again",
	},
	{
		file = "src/TextMemo.luau",
		from = "\t\t\ttable.clear(memo.answers)\n",
		to = "",
		breaks = "a memo started again has forgotten what it held",
	},
	{
		file = "src/TextMemo.luau",
		from = "\t\t\tmemo.count = 0\n",
		to = "",
		breaks = "a memo started again counts from nothing",
	},
	{
		file = "src/TextMemo.luau",
		from = "TextMemo.LIMIT = 256",
		to = "TextMemo.LIMIT = 255",
		breaks = "a memo holds two hundred and fifty-six answers",
	},
}

return MUTANTS
