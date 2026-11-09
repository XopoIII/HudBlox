--!strict
return {
	{
		file = "src/UiRules.luau",
		from = "math.clamp(value, 0, 1)",
		to = "value",
		breaks = "progress accepts endpoints, clamps finite values and rejects nonfinite values",
	},
	{
		file = "src/UiRules.luau",
		from = "math.abs(value) == math.huge",
		to = "false",
		breaks = "progress accepts endpoints, clamps finite values and rejects nonfinite values",
	},
	{
		file = "src/UiRules.luau",
		from = "UiRules.MIN_HIT = 44",
		to = "UiRules.MIN_HIT = 36",
		breaks = "hit safety keeps 44 minimum without rewriting native measured metrics",
	},
	{
		file = "src/ModalState.luau",
		from = "if dead or open == want then",
		to = "if dead then",
		breaks = "modal effects precede synchronous observers and duplicate transitions are silent",
	},
	{
		file = "src/ModalState.luau",
		from = "if not dead then\n\t\t\t\tlisteners[listener] = true\n\t\t\tend",
		to = "if false then\n\t\t\t\tlisteners[listener] = true\n\t\t\tend",
		breaks = "modal effects precede synchronous observers and duplicate transitions are silent",
	},
	{
		file = "src/ModalState.luau",
		from = "listeners[listener] = nil",
		to = "listeners[listener] = true",
		breaks = "modal effects precede synchronous observers and duplicate transitions are silent",
	},
	{
		file = "src/ModalState.luau",
		from = "if dead or mine ~= version then",
		to = "if false then",
		breaks = "reentrant transition invalidates old snapshot",
	},
	{
		file = "src/ModalState.luau",
		from = "if dead or open == want then",
		to = "if open == want then",
		breaks = "modal destroy releases once without notifying or allowing reopen",
	},
	{
		file = "src/PointerState.luau",
		from = "if dead or active ~= nil then",
		to = "if dead then",
		breaks = "capture rejects stealing and foreign end, releases once and invalidates before teardown",
	},
	{
		file = "src/PointerState.luau",
		from = "if active ~= value then",
		to = "if false then",
		breaks = "capture rejects stealing and foreign end, releases once and invalidates before teardown",
	},
	{
		file = "src/PointerState.luau",
		from = "active = nil\n\t\treturn old",
		to = "active = active\n\t\treturn old",
		breaks = "capture rejects stealing and foreign end, releases once and invalidates before teardown",
	},
	{
		file = "src/PointerState.luau",
		from = "dead = true",
		to = "dead = false",
		breaks = "capture rejects stealing and foreign end, releases once and invalidates before teardown",
	},
}
