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
--- - A dialog asked for a `sheet` fills a screen too short to frame it (`DialogGeometry.tight`),
---   from the device's own top edge to its bottom, its header on Roblox's own line and clear of the
---   platform's capsules, which is what a phone's dialogs are.
---
--- The close button stands on the left and the title beside it, as in the Escape menu; the title's
--- text starts where the game's reader starts (`Host`).
const DialogGeometry = require("./DialogGeometry")
const DialogPanel = require("./DialogPanel")
const DialogSkin = require("./DialogSkin")
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
	--- A dialog that fills a screen too short to frame it (`DialogGeometry.tight`): the panel takes
	--- the whole screen from the device's own top edge to its bottom, and its header — the X and the
	--- title — stands on Roblox's own line, clear of the platform's capsules at the left and of
	--- `rightReserve` at the right, so a game's own corner may stand over it. A screen with room
	--- keeps the framed dialog, and a page is never a sheet.
	sheet: boolean?,
	--- Room the game keeps at the right of a sheet's line for its own corner, in the kit's units and
	--- drawn at the bar's scale, as `TopBar`'s own `rightReserve`. 0 when left out.
	rightReserve: number?,
	--- The panel's fill, corner, scrim and shading, when a game wants its own room rather than
	--- Roblox's Escape-menu panel. Every field left out is Roblox's own.
	skin: DialogSkin.Skin?,
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
	const sheet = options ~= nil and options.sheet == true
	const reserve = if options and options.rightReserve then options.rightReserve else 0
	const room = if page then 0 else Native.PAD
	const above = if page then 0 else Dialog.TOP_PAD
	guiCounter += 1
	const rtl = Host.rtl()
	const scope = `modal:{guiCounter}`

	const deck = DialogPanel.new({
		name = name,
		title = title,
		side = room,
		above = above,
		page = page,
		sheet = sheet,
		reserve = reserve,
		minimumHit = if options then options.minimumHit else nil,
		skin = if options then options.skin else nil,
		rtl = rtl.active(),
		display = Dialog.DISPLAY_ORDER,
	})
	const gui, panel, body, backdrop = deck.gui, deck.panel, deck.body, deck.backdrop
	local open, dead = false, false
	const changed = Instance.new("BindableEvent")
	const function place()
		const chrome = math.max(1, if options and options.scale then options.scale else SafeArea.chromeScale())
		const size, strip = gui.AbsoluteSize, SafeArea.topStrip(gui)
		local frame = if page
			then DialogGeometry.page(size.X, size.Y, chrome)
			else DialogGeometry.scaled(size.X, size.Y, strip, width, height, bottom, chrome)
		-- A sheet: the screen has no room to frame the dialog, so the panel takes all of it, from
		-- the device's own top edge to its bottom, and its header stands on Roblox's own line.
		const sheeted = sheet and not page and frame.tight
		if sheeted then
			frame = DialogGeometry.page(size.X, size.Y, chrome)
		end
		if cover then
			cover(open and not frame.clearsBottom)
		end
		deck.place(frame, sheeted, chrome)
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
					return deck.accept()
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
	const closeConnection = deck.close.Activated:Connect(shut)
	-- A sheet's line is the platform's, and that line moves when a voice icon or a language load
	-- arrives: the ink steps aside with it.
	const insetConnection = if sheet and not page
		then game:GetService("GuiService"):GetPropertyChangedSignal("TopbarInset"):Connect(place)
		else nil
	const function release()
		if dead then
			return
		end
		dead = true
		state.destroy()
		unbind()
		backConnection:Disconnect()
		closeConnection:Disconnect()
		if insetConnection then
			insetConnection:Disconnect()
		end
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
		title = deck.title,
		body = body,
		footer = deck.footer,
		setOpen = state.set,
		observe = state.observe,
		isOpen = state.isOpen,
		destroy = destroy,
		toggle = function()
			state.set(not open)
		end,
		primary = function(button: GuiButton?)
			if not dead then
				deck.primary(button)
			end
		end,
		changed = changed,
	}
end

return Dialog
