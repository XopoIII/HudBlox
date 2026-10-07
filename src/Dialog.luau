--!strict
--- A whole dialog in Roblox's own look: a backdrop, a panel, a title, a divider, a close button, a
--- body to fill and a footer for buttons, handing back `toggle` and `setOpen`.
---
--- Gamepad B closes it, as do the X and a tap outside; while it is up a gamepad's focus stays inside
--- the panel (`Focus`), starting on the body's first control and on the X only when there is
--- nothing else.
---
--- - The panel's size comes from the screen (`DialogGeometry`), worked out again whenever the screen,
---   its inset or Roblox's top bar changes, so a rotation never leaves it off the edge.
--- - It pops in (0.9 to 1, Back) and shrinks out, so opening reads as one movement.
--- - A transparent blocker under the panel's content eats taps, so a press on the panel never
---   reaches the backdrop and closes it.
--- - The touch thumbstick and jump button step aside while it is up (`TouchControls`), since they
---   are core UI drawn over everything.
--- - The panel keeps above the game's bottom band (a hotbar) where the screen has room, and tells
---   the game to hide the band while it is up where it has not (`Options.cover`).
---
--- The close button stands on the left and the title beside it, as in the Escape menu; the title's
--- text starts where the game's reader starts (`Host`).
const DialogGeometry = require("./DialogGeometry")
const Focus = require("./Focus")
const Host = require("./Host")
const Native = require("./Native")
const Rtl = require("./Rtl")
const SafeArea = require("./SafeArea")
const TouchControls = require("./TouchControls")

const Dialog = {}

--- The header's height, and the panel's padding above it.
Dialog.HEAD_H = 40
Dialog.TOP_PAD = 12
--- The DisplayOrder of a dialog's ScreenGui: above a HUD at 0.
Dialog.DISPLAY_ORDER = 10
--- The PlayerGui attribute that counts the dialogs that are up, for whatever steps aside for one.
Dialog.OPEN_ATTRIBUTE = "ModalsOpen"

export type Options = {
	--- What the game keeps at the bottom of the screen (`DialogGeometry.Bottom`). None when left out.
	bottom: DialogGeometry.Bottom?,
	--- Called with true while this dialog is up and does not clear the bottom band, and with false
	--- when that ends: the game hides the band meanwhile.
	cover: ((covered: boolean) -> ())?,
}

export type Dialog = {
	gui: ScreenGui,
	panel: Frame,
	title: TextLabel,
	body: Frame,
	footer: Frame,
	setOpen: (open: boolean) -> (),
	toggle: () -> (),
	--- Fired with the new state every time the dialog opens or closes.
	changed: BindableEvent,
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
	const rtl = Host.rtl()
	const scope = `modal:{name}`

	const gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = Dialog.DISPLAY_ORDER
	gui.Enabled = false

	const backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
	backdrop.BackgroundTransparency = Native.BACKDROP_T
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
	pad.PaddingLeft = UDim.new(0, Native.PAD)
	pad.PaddingRight = UDim.new(0, Native.PAD)
	pad.PaddingBottom = UDim.new(0, Native.PAD)
	pad.PaddingTop = UDim.new(0, Dialog.TOP_PAD)
	pad.Parent = panel

	-- A Frame, even an Active one, lets a tap through to the backdrop button behind it (measured);
	-- a button the panel's size does not.
	const blocker = Instance.new("TextButton")
	blocker.Name = "TapBlocker"
	blocker.Text = ""
	blocker.AutoButtonColor = false
	blocker.BackgroundTransparency = 1
	blocker.Position = UDim2.fromOffset(-Native.PAD, -Dialog.TOP_PAD)
	blocker.Size = UDim2.new(1, Native.PAD * 2, 1, Native.PAD + Dialog.TOP_PAD)
	blocker.ZIndex = 0
	blocker.Selectable = false
	blocker.Parent = panel

	const header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, Dialog.HEAD_H)
	header.Parent = panel

	const head = Native.text(header, title, Native.TITLE_SIZE, { weight = Enum.FontWeight.Bold })
	head.Name = "Title"
	head.TextWrapped = false
	head.TextTruncate = Enum.TextTruncate.AtEnd
	head.Size = UDim2.new(1, -Native.ICON_BUTTON - 8, 0, Dialog.HEAD_H)

	const close = Native.iconButton(header, "x")
	close.Name = "Close"
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, 0, 0, 2)
	-- The last place a gamepad's focus starts (`Pick`).
	close.SelectionOrder = 1000
	-- Built with the close button at the right and mirrored once, whatever the locale: the X stands
	-- on the left, as the Escape menu's does, and the title takes the rest of the row.
	Rtl.mirror(header)

	const divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.BackgroundColor3 = Native.DIVIDER
	divider.BackgroundTransparency = Native.DIVIDER_T
	divider.BorderSizePixel = 0
	divider.Position = UDim2.fromOffset(0, Dialog.HEAD_H)
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Parent = panel

	const footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.BackgroundTransparency = 1
	footer.AnchorPoint = Vector2.new(0, 1)
	footer.Position = UDim2.fromScale(0, 1)
	footer.Size = UDim2.fromScale(1, 0)
	footer.Parent = panel
	const row = Instance.new("UIListLayout")
	row.FillDirection = Enum.FillDirection.Horizontal
	-- Buttons are added in reading order; in a right-to-left locale that runs from the right.
	row.HorizontalAlignment = if rtl.active() then Enum.HorizontalAlignment.Right else Enum.HorizontalAlignment.Left
	row.HorizontalFlex = Enum.UIFlexAlignment.Fill
	row.Padding = UDim.new(0, 12)
	row.Parent = footer

	const top = Dialog.HEAD_H + 1 + Native.GAP / 2
	const body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(0, top)
	body.Size = UDim2.new(1, 0, 1, -top)
	body.Parent = panel

	-- A footer with buttons takes a button's height and a gap off the body.
	footer.ChildAdded:Connect(function(child: Instance)
		if child:IsA("GuiButton") then
			footer.Size = UDim2.new(1, 0, 0, Native.BUTTON_H)
			body.Size = UDim2.new(1, 0, 1, -top - Native.BUTTON_H - Native.GAP)
		end
	end)

	local open = false

	-- The panel fits the screen; worked out again whenever the screen or its inset moves.
	const function place()
		const frame =
			DialogGeometry.layout(gui.AbsoluteSize.X, gui.AbsoluteSize.Y, SafeArea.topStrip(gui), width, height, bottom)
		if cover then
			cover(open and not frame.clearsBottom)
		end
		panel.AnchorPoint = Vector2.new(0.5, 0)
		panel.Size = UDim2.fromOffset(frame.width, frame.height)
		panel.Position = UDim2.new(0.5, 0, 0, frame.top)
	end
	SafeArea.bind(gui, place)

	const changed = Instance.new("BindableEvent")
	local token = 0
	local setOpen: (want: boolean) -> ()
	const function shut()
		setOpen(false)
	end

	setOpen = function(want: boolean)
		if open == want then
			return
		end
		open = want
		token += 1
		const mine = token
		-- How many dialogs are up: whatever steps aside for one reads this.
		const up = playerGui:GetAttribute(Dialog.OPEN_ATTRIBUTE)
		playerGui:SetAttribute(
			Dialog.OPEN_ATTRIBUTE,
			math.max((if type(up) == "number" then up else 0) + (if want then 1 else -1), 0)
		)
		TouchControls.set(scope, want)
		if want then
			gui.Enabled = true
			place()
			scale.Scale = 0.9
			game:GetService("TweenService")
				:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
				:Play()
			Focus.push(scope, panel, { back = shut })
		else
			if cover then
				cover(false)
			end
			Focus.pop(scope)
			const shrink =
				game:GetService("TweenService")
					:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.9 })
			shrink.Completed:Once(function()
				-- Opened again while shrinking: leave it up.
				if mine == token then
					gui.Enabled = false
				end
			end)
			shrink:Play()
		end
		changed:Fire(want)
	end

	backdrop.Activated:Connect(shut)
	close.Activated:Connect(shut)
	gui.Parent = playerGui

	return {
		gui = gui,
		panel = panel,
		title = head,
		body = body,
		footer = footer,
		setOpen = setOpen,
		toggle = function()
			setOpen(not open)
		end,
		changed = changed,
	}
end

return Dialog
