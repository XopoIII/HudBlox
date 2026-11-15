--!strict
--- A whole dialog in Roblox's own look: a backdrop, a panel, a title, a divider, a close button, a
--- body to fill and a footer for buttons, handing back `toggle` and `setOpen`.
---
--- Gamepad B closes it, as do the X and a tap outside; while it is up a gamepad's focus stays inside
--- the panel (`Focus`), starting on the dialog's primary button when it names one (`primary`), else
--- on the body's first control, and on the X only when there is nothing else. On a pad the X wears
--- B's picture and the primary button A's (`PadGlyph`), so a player sees at once that A accepts and
--- B closes.
---
--- - The panel's size comes from the screen (`DialogGeometry`), drawn at Roblox's scale of its bar
---   (half again on a television), worked out again as the screen, its inset or the bar changes.
--- - Visibility transitions are synchronous: an old animation never hides a reopened dialog.
--- - A transparent blocker under the panel's content eats taps, so a press on the panel never
---   reaches the backdrop and closes it.
--- - The touch thumbstick and jump button step aside while it is up (`TouchControls`), since they
---   are core UI drawn over everything.
--- - The panel keeps above the game's bottom band (a hotbar) where the screen has room, and tells
---   the game to hide the band while it is up where it has not (`Options.cover`).
---
--- The close button stands on the left and the title beside it, as in the Escape menu; the title's
--- text starts where the game's reader starts (`Host`).
const DialogFooter = require("./DialogFooter")
const DialogGeometry = require("./DialogGeometry")
const DialogHeader = require("./DialogHeader")
const Focus = require("./Focus")
const Host = require("./Host")
const ModalState = require("./ModalState")
const Native = require("./Native")

const SafeArea = require("./SafeArea")
const TouchControls = require("./TouchControls")

const Dialog = {}
local guiCounter = 0

--- The header's height, and the panel's padding above it.
Dialog.HEAD_H = 48
Dialog.TOP_PAD = 12
--- The DisplayOrder of a dialog's ScreenGui: above a HUD at 0.
Dialog.DISPLAY_ORDER = 10
--- The PlayerGui attribute that counts the dialogs that are up, for whatever steps aside for one.
Dialog.OPEN_ATTRIBUTE = "ModalsOpen"
--- The size of a pad's picture on the X and on the primary button, in pixels.
Dialog.CAP = 20

export type Options = {
	--- What the game keeps at the bottom of the screen (`DialogGeometry.Bottom`). None when left out.
	bottom: DialogGeometry.Bottom?,
	--- Called with true while this dialog is up and does not clear the bottom band, and with false
	--- when that ends: the game hides the band meanwhile.
	cover: ((covered: boolean) -> ())?,
	minimumHit: number?,
	--- Explicit density, clamped to at least one: never shrinks touch targets.
	scale: number?,
	--- Only the X, backdrop and gamepad back call this, synchronously after closing.
	onClose: (() -> ())?,
	--- A page rather than a dialog: the panel is the whole screen from its own top edge, with its
	--- header and its padding taken away, so that a game's page begins on Roblox's own line. The
	--- backdrop stays to hold the taps, and is not seen.
	page: boolean?,
}

export type Dialog = {
	gui: ScreenGui,
	panel: Frame,
	title: TextLabel,
	body: Frame,
	footer: Frame,
	setOpen: (open: boolean) -> (),
	toggle: () -> (),
	--- Names the button A accepts with: the pad's focus starts on it each time the dialog opens, and
	--- it wears A's picture. Nil takes the name off again.
	primary: (button: GuiButton?) -> (),
	--- Fired with the new state every time the dialog opens or closes.
	changed: BindableEvent,
	observe: ((boolean) -> ()) -> () -> (),
	isOpen: () -> boolean,
	destroy: () -> (),
}

const function corner(parent: Instance, radius: number)
	const round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(0, radius)
	round.Parent = parent
end

--> A dialog named `name` in `playerGui`, `width` wide and `height` tall at most, titled `title`.
--> The body fills what the title and the footer leave; the footer is a horizontal row for buttons,
--> empty (and taking no room) until one is added.
function Dialog.new(
	playerGui: Instance,
	name: string,
	title: string,
	width: number,
	height: number,
	options: Options?
): Dialog
	const bottom = if options then options.bottom else nil
	const cover = if options then options.cover else nil
	const page = options ~= nil and options.page == true
	const room = if page then 0 else Native.PAD
	const above = if page then 0 else Dialog.TOP_PAD
	guiCounter += 1
	const rtl = Host.rtl()
	const scope = `modal:{guiCounter}`

	const gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	-- A page is drawn in the device's own safe area: not inside the core UI's insets, which would
	-- lift it a strip above the screen, and never under a notch or an island, where a page's line and
	-- its corner would be cut. Roblox's own bar stands in that same area, so the page's line meets it.
	if page then
		gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	end
	gui.DisplayOrder = Dialog.DISPLAY_ORDER
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
	backdrop.BackgroundTransparency = if page then 1 else Native.BACKDROP_T
	backdrop.Size = UDim2.fromScale(1, 1)
	-- Neither it nor the blocker is a control: a gamepad never lands on them.
	backdrop.Selectable = false
	backdrop.Parent = gui

	const panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.BackgroundColor3 = Native.SURFACE
	panel.BackgroundTransparency = Native.MODAL_T
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Parent = gui
	corner(panel, Native.CORNER)
	const scale = Instance.new("UIScale")
	scale.Parent = panel
	const pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, room)
	pad.PaddingRight = UDim.new(0, room)
	pad.PaddingBottom = UDim.new(0, room)
	pad.PaddingTop = UDim.new(0, above)
	pad.Parent = panel

	-- A Frame, even an Active one, lets a tap through to the backdrop button behind it (measured);
	-- a button the panel's size does not.
	const blocker = Instance.new("TextButton")
	blocker.Name = "TapBlocker"
	blocker.Text = ""
	blocker.AutoButtonColor = false
	blocker.BackgroundTransparency = 1
	blocker.Position = UDim2.fromOffset(-room, -above)
	blocker.Size = UDim2.new(1, room * 2, 1, room + above)
	blocker.ZIndex = 0
	blocker.Selectable = false
	blocker.Parent = panel

	const head, close = DialogHeader.mount(panel, title, if options then options.minimumHit else nil)
	-- A page carries its own line: the header and its divider are not drawn, and the body is the
	-- whole panel
	if page then
		for _, child in panel:GetChildren() do
			if child:IsA("GuiObject") and (child.Name == "Header" or child.Name == "Divider") then
				child.Visible = false
			end
		end
	end

	const top = if page then 0 else Dialog.HEAD_H + 1 + Native.GAP / 2
	const body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(0, top)
	body.Size = UDim2.new(1, 0, 1, -top)
	body.Parent = panel

	const footer = DialogFooter.mount(panel, body, top, page, rtl.active())

	local open, dead = false, false
	const changed = Instance.new("BindableEvent")
	const function place()
		const chrome = math.max(1, if options and options.scale then options.scale else SafeArea.chromeScale())
		const size, strip = gui.AbsoluteSize, SafeArea.topStrip(gui)
		const frame = if page
			then DialogGeometry.page(size.X, size.Y, chrome)
			else DialogGeometry.scaled(size.X, size.Y, strip, width, height, bottom, chrome)
		scale.Scale = chrome
		if cover then
			cover(open and not frame.clearsBottom)
		end
		panel.AnchorPoint = Vector2.new(0.5, 0)
		panel.Size = UDim2.fromOffset(frame.width, frame.height)
		panel.Position = UDim2.new(0.5, 0, 0, frame.top)
	end
	const unbind = SafeArea.bind(gui, place)
	local state: ModalState.Handle
	const function shut()
		if dead or not state.isOpen() then
			return
		end
		state.set(false)
		if not dead and options and options.onClose then
			options.onClose()
		end
	end
	state = ModalState.new(function(want: boolean)
		open = want
		const up = playerGui:GetAttribute(Dialog.OPEN_ATTRIBUTE)
		playerGui:SetAttribute(
			Dialog.OPEN_ATTRIBUTE,
			math.max((if type(up) == "number" then up else 0) + (if want then 1 else -1), 0)
		)
		TouchControls.set(scope, want)
		gui.Enabled = want
		if want then
			place()
			Focus.push(scope, panel, {
				back = shut,
				first = function(): GuiObject?
					return footer.accept()
				end,
			})
		else
			if cover then
				cover(false)
			end
			Focus.pop(scope)
		end
		if not dead then
			changed:Fire(want)
		end
	end)
	const backConnection = backdrop.Activated:Connect(shut)
	const closeConnection = close.Activated:Connect(shut)
	const function release()
		if dead then
			return
		end
		dead = true
		state.destroy()
		unbind()
		backConnection:Disconnect()
		closeConnection:Disconnect()
		changed:Destroy()
	end
	--- The gui lays the dialog down by itself when it is destroyed, and destroying an instance
	--- whose parent is already going warns that the parent's Parent is locked: a gui taken by its
	--- holder is only released, never destroyed a second time.
	const function destroy()
		if dead then
			return
		end
		release()
		gui:Destroy()
	end
	gui.Destroying:Connect(release)
	gui.Parent = playerGui

	return {
		gui = gui,
		panel = panel,
		title = head,
		body = body,
		footer = footer.frame,
		setOpen = state.set,
		observe = state.observe,
		isOpen = state.isOpen,
		destroy = destroy,
		toggle = function()
			state.set(not open)
		end,
		primary = function(button: GuiButton?)
			if not dead then
				footer.primary(button)
			end
		end,
		changed = changed,
	}
end

return Dialog
