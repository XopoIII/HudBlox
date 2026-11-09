--!strict
--- A native track and fill. The host supplies the fraction and optional accent.
const Native = require("./Native")
const Surface = require("./Surface")
const UiRules = require("./UiRules")
const Progress = {}
export type Options = { color: Color3?, height: number? }
export type Handle = { frame: Frame, set: (number) -> (), destroy: () -> () }
function Progress.mount(parent: Instance, options: Options?): Handle
	const frame = Surface.mount(
		parent,
		{ kind = "tile", size = UDim2.new(1, 0, 0, if options and options.height then options.height else 8) }
	)
	frame.ClipsDescendants = true
	const fill = Surface.mount(frame, { kind = "tile", size = UDim2.fromScale(0, 1) })
	fill.BackgroundColor3 = if options and options.color then options.color else Native.PRIMARY
	local dead = false
	return {
		frame = frame,
		set = function(value: number)
			if not dead then
				fill.Size = UDim2.fromScale(UiRules.fraction(value), 1)
			end
		end,
		destroy = function()
			if dead then
				return
			end
			dead = true
			frame:Destroy()
		end,
	}
end
return Progress
