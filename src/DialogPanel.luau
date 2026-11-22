--!strict
--- The panel a dialog draws in: the backdrop that takes a tap outside, the nearly solid panel with
--- its padding, the blocker that keeps a press on the panel from reaching that backdrop, the title
--- row with its divider, the body and the footer — and where all of it goes for a frame of the
--- screen. What a dialog does with the panel (opening, closing, focus) is `Dialog`'s.
const DialogFooter = require("./DialogFooter")
const DialogGeometry = require("./DialogGeometry")
const DialogHeader = require("./DialogHeader")
const DialogSkin = require("./DialogSkin")
const Measure = require("./Measure")
const Native = require("./Native")
const SafeArea = require("./SafeArea")

const DialogPanel = {}

--- The height of a framed panel's header, and the air above it.
DialogPanel.HEAD_H = 48
DialogPanel.TOP_PAD = 12

export type Options = {
	--- The panel's own padding, inside its edges: its lines never touch the screen's side.
	side: number,
	--- The air between the panel's top edge and a framed header.
	above: number,
	--- A page: no header, no divider, no padding above, and the body is the whole panel.
	page: boolean,
	--- A dialog asked for a sheet: filled where the screen cannot frame it.
	sheet: boolean,
	--- Room a sheet keeps at the right of its line for the game's own corner.
	reserve: number,
	minimumHit: number?,
	--- The fill, corner, scrim and shading a game wants instead of Roblox's own panel.
	skin: DialogSkin.Skin?,
	--- Whether the reader reads right to left, which the footer's row follows.
	rtl: boolean,
	--- The ScreenGui's DisplayOrder, above a HUD at 0.
	display: number,
	name: string,
	title: string,
}

export type Panel = {
	gui: ScreenGui,
	backdrop: TextButton,
	panel: Frame,
	title: TextLabel,
	close: TextButton,
	body: Frame,
	footer: Frame,
	--- Lays the panel out for `frame`, the screen's arithmetic, drawn at `chrome`: the platform's
	--- scale of its own bar. `sheeted` fills the screen and puts the title on its line.
	place: (frame: DialogGeometry.Frame, sheeted: boolean, chrome: number) -> (),
	--- Names the button a gamepad's A accepts with, as the footer's own handle does.
	primary: (button: GuiButton?) -> (),
	--- That button now, which a gamepad's focus starts on.
	accept: () -> GuiButton?,
	--- Whether a sheet is filled now: what the last `place` was told.
	filled: () -> boolean,
}

--> Where the body begins, in the panel's units: under a framed header, the whole panel for a page,
--> and under the platform's own line for a sheet.
function DialogPanel.bodyTop(sheeted: boolean, page: boolean): number
	if sheeted then
		return Measure.TOP + Measure.HEIGHT + 1
	end
	return if page then 0 else DialogPanel.HEAD_H + 1 + Native.GAP / 2
end

--> Builds it closed, into `playerGui` when the caller parents it.
function DialogPanel.new(options: Options): Panel
	const page = options.page
	const side = options.side
	const above = options.above
	const reserve = options.reserve
	const skin = DialogSkin.resolve(options.skin, {
		panel = Native.SURFACE,
		panelTransparency = Native.MODAL_T,
		corner = Native.CORNER,
		backdropTransparency = Native.BACKDROP_T,
	})
	const gui = Instance.new("ScreenGui")
	gui.Name = options.name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	-- A page and a sheet are drawn in the device's own safe area: not inside the core UI's insets,
	-- which would lift them a strip above the screen, and never under a notch or an island, where
	-- their line and corner would be cut. Roblox's own bar stands in that same area, so the line
	-- meets it.
	if page or options.sheet then
		gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	end
	gui.DisplayOrder = options.display
	gui.Enabled = false
	-- Sibling ordering, not the default global one: the later panel's subtree then draws over the
	-- backdrop, so the panel's ZIndex 0 TapBlocker sits above the ZIndex 1 backdrop but below the
	-- panel's own content. Ordering globally puts the blocker behind the backdrop, and a tap on the
	-- panel reaches the backdrop and closes the dialog.
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	const backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
	backdrop.BackgroundTransparency = if page then 1 else skin.backdropTransparency
	backdrop.Size = UDim2.fromScale(1, 1)
	-- Neither it nor the blocker is a control: a gamepad never lands on them.
	backdrop.Selectable = false
	backdrop.Parent = gui

	const panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.BackgroundColor3 = skin.panel
	panel.BackgroundTransparency = skin.panelTransparency
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Parent = gui
	const round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(0, skin.corner)
	round.Parent = panel
	-- A skin's shading answers "where is the light" without a texture: one ramp, multiplied over the
	-- fill, above nothing — a `UIGradient` on a `Frame` carries no order of its own.
	if skin.gradient then
		const shade = Instance.new("UIGradient")
		shade.Color = skin.gradient
		shade.Rotation = skin.gradientRotation
		shade.Parent = panel
	end
	const scale = Instance.new("UIScale")
	scale.Parent = panel
	const pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, side)
	pad.PaddingRight = UDim.new(0, side)
	pad.PaddingBottom = UDim.new(0, side)
	pad.PaddingTop = UDim.new(0, above)
	pad.Parent = panel

	-- A Frame, even an Active one, lets a tap through to the backdrop button behind it (measured);
	-- a button the panel's size does not.
	const blocker = Instance.new("TextButton")
	blocker.Name = "TapBlocker"
	blocker.Text = ""
	blocker.AutoButtonColor = false
	blocker.BackgroundTransparency = 1
	blocker.Position = UDim2.fromOffset(-side, -above)
	blocker.Size = UDim2.new(1, side * 2, 1, side + above)
	blocker.ZIndex = 0
	blocker.Selectable = false
	blocker.Parent = panel

	const head = DialogHeader.mount(panel, options.title, options.minimumHit, side)
	-- A page carries its own line: the header and its divider are not drawn, and the body is the
	-- whole panel.
	if page then
		for _, child in panel:GetChildren() do
			if child:IsA("GuiObject") and (child.Name == "Header" or child.Name == "Divider") then
				child.Visible = false
			end
		end
	end

	const top = DialogPanel.bodyTop(false, page)
	const body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(0, top)
	body.Size = UDim2.new(1, 0, 1, -top)
	body.Parent = panel

	const foot = DialogFooter.mount(panel, body, top, page, options.rtl)
	local filled = false

	const function place(frame: DialogGeometry.Frame, sheeted: boolean, chrome: number)
		filled = sheeted
		scale.Scale = chrome
		panel.AnchorPoint = Vector2.new(0.5, 0)
		panel.Size = UDim2.fromOffset(frame.width, frame.height)
		panel.Position = UDim2.new(0.5, 0, 0, frame.top)
		-- A sheet is the screen's own edge: no corner to round off, and nothing above its line.
		round.CornerRadius = UDim.new(0, if sheeted then 0 else skin.corner)
		pad.PaddingTop = UDim.new(0, if sheeted or page then 0 else above)
		-- A sheet's ink begins past the platform's capsules, and ends before the game's own corner;
		-- the panel's own padding is already in front of it, so only the difference is a step.
		head.fit(if sheeted
			then {
				top = Measure.TOP,
				height = Measure.HEIGHT,
				left = math.max(0, SafeArea.topbarFreeX(gui) / chrome - side),
				right = reserve,
			}
			else nil)
		const edge = DialogPanel.bodyTop(sheeted, page)
		body.Position = UDim2.fromOffset(0, edge)
		body.Size = UDim2.new(1, 0, 1, -edge)
		foot.top(edge)
	end

	return {
		gui = gui,
		backdrop = backdrop,
		panel = panel,
		title = head.title,
		close = head.close,
		body = body,
		footer = foot.frame,
		place = place,
		primary = foot.primary,
		accept = foot.accept,
		filled = function(): boolean
			return filled
		end,
	}
end

return DialogPanel
