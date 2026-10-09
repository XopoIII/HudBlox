--!strict
--- The top line: a right-aligned row of capsules and round buttons, and round buttons on the left
--- just past Roblox's own.
---
--- This module owns the ROW: its width, its alignment and where it sits. What goes in it is the
--- game's. The row is bounded by where Roblox's buttons actually end (`GuiService.TopbarInset`),
--- only while it really shares their line, and fits itself again whenever the inset or the screen
--- changes. The arithmetic is `Layout.top`, where the specs are.
---
--- THE FAILURE MODE IS NOT A CLIPPED CAPSULE. IT IS A SECOND LINE, WHERE NOBODY WILL SEE IT. The
--- row is right-anchored, so a width that is too small shows as neither a gap nor a clip: it only
--- decides where wrapping begins. Once a wrapped line landed exactly behind an icon column; once the
--- first line was drawn off the top of the screen. So `mount` WARNS when the row grows past one
--- capsule's height, and `Layout.fits` answers the question ahead of time for a worst case.
---
--- When the row runs short, add a segment to a capsule rather than another capsule: a segment costs
--- `Measure.SEGMENT_GAP`, a capsule costs both paddings and `Measure.GAP`.
const Button = require("./Button")
const Layout = require("./Layout")
const Measure = require("./Measure")
const Pill = require("./Pill")
const SafeArea = require("./SafeArea")
const Theme = require("./Theme")

const TopBar = {}

export type Row = {
	--- The row's frame, so a caller can hang something of its own on the same line.
	frame: Frame,
	--- Adds a capsule to the right row, with one segment per part. The row fills left to right and
	--- hugs the right edge, so the last thing added is the one in the corner.
	--- The UIScale is on the plate and is the caller's to animate: a pulse grows the capsule
	--- evenly and the row does not move.
	addPill: (parts: { Pill.Part }, tappable: boolean?) -> (Pill.Capsule, UIScale),
	--- Adds a round button to the right row, after what is already there.
	addButton: (icon: string) -> TextButton,
	--- Adds a round button on the LEFT, past Roblox's own buttons, where a player looks for what
	--- the platform itself would put there. Each one takes its width off the right row.
	addLeftButton: (icon: string) -> TextButton,
	--- Places everything again. The row does this itself when the screen or the inset changes.
	fit: () -> (),
	--- Disconnects everything and destroys the row and its left buttons. A surface that can be
	--- rebuilt must call it: a second row mounts exactly on top of the first.
	destroy: () -> (),
}

--> Mounts the top line into `gui`. For the row to share the line of Roblox's own buttons, `gui`
--> must ignore the gui inset (`SafeArea.screen` makes one); in a gui that respects it the row sits
--> below them and uses the whole width.
function TopBar.mount(gui: ScreenGui, theme: Theme.Theme): Row
	const row = Instance.new("Frame")
	row.Name = "TopRow"
	row.AnchorPoint = Vector2.new(1, 0)
	row.Position = UDim2.new(1, -Measure.EDGE, 0, Measure.TOP)
	-- The width is replaced by `fit`. It has to be FIXED for wrapping to have anything to measure
	-- against, which is why the row does not size itself on X.
	row.Size = UDim2.new(1, -Measure.EDGE * 2, 0, Measure.HEIGHT)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0

	const list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Padding = UDim.new(0, Measure.GAP)
	-- Right-aligned and wrapping: what no longer fits drops to a second line, not off the side.
	list.HorizontalAlignment = Enum.HorizontalAlignment.Right
	list.VerticalAlignment = Enum.VerticalAlignment.Top
	list.Wraps = true
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = row
	row.Parent = gui

	const lefts: { TextButton } = {}
	const connections: { RBXScriptConnection } = {}

	const function fit()
		const top = Layout.top(SafeArea.measure(gui), SafeArea.insetMinX(), #lefts)
		for index, button in lefts do
			button.Position = UDim2.fromOffset(top.lefts[index], Measure.TOP)
		end
		row.Size = UDim2.fromOffset(top.rowWidth, Measure.HEIGHT)
	end
	const unbind = SafeArea.bind(gui, fit)
	table.insert(connections, game:GetService("GuiService"):GetPropertyChangedSignal("TopbarInset"):Connect(fit))

	-- The engine knows the instant the row wraps: a second line makes it taller. 1 for rounding.
	-- A warning, not an error: a wrapped row is still a running game, and somebody must find out.
	table.insert(
		connections,
		row:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if row.AbsoluteSize.Y > Measure.HEIGHT + 1 then
				warn(
					`[HudBlox] the top row WRAPPED: {row.AbsoluteSize.Y} px tall against one capsule's `
						.. `{Measure.HEIGHT}, row {row.AbsoluteSize.X} px on a {gui.AbsoluteSize.X} px screen. `
						.. "A wrapped line is drawn where nobody looks; fold a capsule into a segment."
				)
			end
		end)
	)

	-- The row fills left to right and hugs the right edge: the LAST thing added keeps the corner.
	local order = 0
	const function nextOrder(): number
		order += 1
		return order
	end

	const function addPill(parts: { Pill.Part }, tappable: boolean?): (Pill.Capsule, UIScale)
		-- The capsule sits in a holder, and the holder is what the row lays out. A capsule that is
		-- SCALED cannot be a direct child: UIScale changes AbsoluteSize, the list re-flows on it,
		-- and in a right-aligned row every extra pixel is spent on the left (measured at 1.14: the
		-- left edge moved 14.8 px, the right 0). An anchor point does not rescue it.
		const holder = Instance.new("Frame")
		holder.Name = "PillHolder"
		holder.BackgroundTransparency = 1
		holder.BorderSizePixel = 0
		holder.LayoutOrder = nextOrder()
		holder.Size = UDim2.fromOffset(0, Measure.HEIGHT)
		holder.Parent = row

		const capsule = Pill.build(holder, theme, parts, tappable)
		const plate = capsule.plate
		plate.AnchorPoint = Vector2.new(0.5, 0.5)
		plate.Position = UDim2.fromScale(0.5, 0.5)
		const scale = Instance.new("UIScale")
		scale.Parent = plate

		-- The holder tracks the capsule's UNSCALED width: dividing the live size back out by the
		-- scale keeps the row's spacing honest while the capsule is mid-pulse.
		const function fitHolder()
			holder.Size = UDim2.fromOffset(plate.AbsoluteSize.X / scale.Scale, Measure.HEIGHT)
		end
		fitHolder()
		-- Dies with the row anyway; listed with the rest so `destroy` disconnects everything.
		table.insert(connections, plate:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitHolder))
		return capsule, scale
	end

	const function addButton(icon: string): TextButton
		const button = Button.round(row, theme, icon)
		button.LayoutOrder = nextOrder()
		return button
	end

	const function addLeftButton(icon: string): TextButton
		const button = Button.round(gui, theme, icon, { name = "LeftButton" })
		table.insert(lefts, button)
		fit()
		return button
	end

	const function destroy()
		unbind()
		for _, connection in connections do
			connection:Disconnect()
		end
		for _, button in lefts do
			button:Destroy()
		end
		row:Destroy()
	end

	return {
		frame = row,
		addPill = addPill,
		addButton = addButton,
		addLeftButton = addLeftButton,
		fit = fit,
		destroy = destroy,
	}
end

return TopBar
