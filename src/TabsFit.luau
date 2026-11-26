--!strict
const TabFit = require("./TabFit")
const TabsFit = {}

function TabsFit.apply(
	frame: Frame,
	buttons: { [string]: TextButton },
	vertical: boolean,
	count: number,
	gap: number,
	height: number,
	most: number
)
	const size = frame.AbsoluteSize
	if vertical then
		const h = TabFit.height(TabFit.points(size.Y, size.X, most), count, gap, height)
		for _, button in buttons do
			button.Size = UDim2.fromOffset(most, h)
		end
	else
		const width = TabFit.width(TabFit.points(size.X, size.Y, height), count, gap, most)
		for _, button in buttons do
			button.Size = UDim2.fromOffset(width, height)
		end
	end
end

return TabsFit
