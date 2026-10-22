--!strict
--- A card a game draws over the screen by hand, which holds a gamepad while it stands, as the
--- kit's own dialogs do (`Dialog`): the ring on the button it names first, the stick and the D-pad
--- walking its buttons, the world's prompts and the character held (`Focus`), and the card's keys
--- said on it: A's picture on the first button, which A presses, and B's on the one B does.
---
--- A card built hidden (a ScreenGui not yet `Enabled`) takes the pad as it is shown, and gives it
--- back as it is hidden or destroyed: the game mounts it once and forgets it.
const Focus = require("./Focus")
const PadGlyph = require("./PadGlyph")

const PadCard = {}

--- The size of the keys' pictures on a card's buttons, in pixels.
PadCard.CAP = 20

export type Options = {
	--- What B does while the card holds the pad. Nothing when left out.
	back: (() -> ())?,
	--- The button that does what B does, which wears B's picture.
	cancel: GuiObject?,
}

--> Gives the pad to the card `root` under `name` while it is shown, the ring starting on `first`.
function PadCard.hold(name: string, root: GuiBase2d, first: GuiObject, options: Options?)
	PadGlyph.corner(first, Enum.KeyCode.ButtonA, PadCard.CAP)
	const cancel = if options then options.cancel else nil
	if cancel then
		PadGlyph.corner(cancel, Enum.KeyCode.ButtonB, PadCard.CAP)
	end
	local held = false
	const function hold(on: boolean)
		if on == held then
			return
		end
		held = on
		if on then
			Focus.push(name, root, {
				back = if options then options.back else nil,
				first = function(): GuiObject?
					return first
				end,
			})
		else
			Focus.pop(name)
		end
	end
	const function shown(): boolean
		return root.Parent ~= nil and (not root:IsA("ScreenGui") or root.Enabled)
	end
	if root:IsA("ScreenGui") then
		root:GetPropertyChangedSignal("Enabled"):Connect(function()
			hold(shown())
		end)
	end
	root.Destroying:Connect(function()
		hold(false)
	end)
	root.AncestryChanged:Connect(function()
		hold(shown())
	end)
	hold(shown())
end

return PadCard
