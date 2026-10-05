--!strict
--- Right-to-left layout, for Arabic and Hebrew.
---
--- Roblox does not mirror a place's GUI for a right-to-left locale, and its own top bar stays left
--- to right, so a game mirrors only its own layout, itself. The engine shapes the text; this
--- handles what it cannot: which side an element sits on, and which way a label aligns.
---
--- What is not mirrored: the top row, whose right corner is already the reading start while the
--- left belongs to Roblox's own buttons. And the world, never.
---
--- Whether the locale reads right to left is the game's to say: `Rtl.reader` takes that function.
--- The mechanics above it are unconditional, so a spec can exercise them on any client.
const Layout = require("./Layout")

const Rtl = {}

--- The mirror, switched by the game's locale.
export type Reader = {
	--- Whether the locale reads right to left now.
	active: () -> boolean,
	--- Mirrors the geometry and realigns the text of a built subtree, only when active. Call once
	--- per subtree, after its last child exists.
	apply: (root: GuiObject) -> (),
	--- Moves one edge-anchored element to the opposite edge when active, and nothing else:
	--- `apply` leaves the root where it is, so a HUD piece that owns its screen position needs this.
	flipEdge: (frame: GuiObject) -> (),
	--- The LayoutOrder for item `index` of a row with a reading order: a list fills left to right,
	--- so a right-to-left locale reverses it.
	slot: (index: number) -> number,
	--- The alignment a label has at the start of a line.
	start: () -> Enum.TextXAlignment,
}

--> Mirrors an edge-anchored frame to the other side. A centred frame maps to itself.
function Rtl.flipX(frame: GuiObject)
	const anchor = frame.AnchorPoint
	const position = frame.Position
	const anchorX, scale, offset = Layout.mirrorX(anchor.X, position.X.Scale, position.X.Offset)
	frame.AnchorPoint = Vector2.new(anchorX, anchor.Y)
	frame.Position = UDim2.new(scale, offset, position.Y.Scale, position.Y.Offset)
end

const function flipped(alignment: Enum.HorizontalAlignment): Enum.HorizontalAlignment
	if alignment == Enum.HorizontalAlignment.Left then
		return Enum.HorizontalAlignment.Right
	elseif alignment == Enum.HorizontalAlignment.Right then
		return Enum.HorizontalAlignment.Left
	end
	return alignment
end

--> Swaps a list or grid layout's horizontal alignment, Left and Right.
function Rtl.flipListAlign(layout: Instance)
	if layout:IsA("UIListLayout") or layout:IsA("UIGridLayout") then
		layout.HorizontalAlignment = flipped(layout.HorizontalAlignment)
	end
end

const function flippedText(alignment: Enum.TextXAlignment): Enum.TextXAlignment
	if alignment == Enum.TextXAlignment.Left then
		return Enum.TextXAlignment.Right
	elseif alignment == Enum.TextXAlignment.Right then
		return Enum.TextXAlignment.Left
	end
	return alignment
end

const function alignOne(object: Instance)
	if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
		object.TextXAlignment = flippedText(object.TextXAlignment)
	end
end

--> Swaps TextXAlignment Left and Right on every text object under `root`, `root` included. A
--> second call swaps it back: call once per subtree.
function Rtl.alignText(root: Instance)
	alignOne(root)
	for _, object in root:GetDescendants() do
		alignOne(object)
	end
end

--> Mirrors a hand-positioned subtree: every child that owns its X moves to the opposite edge. A
--> child placed by a list or grid layout is left alone (the layout overwrites its position, and a
--> flipped anchor would shift it by its own width); such a container mirrors through its layout's
--> alignment instead, and each item is still recursed into.
function Rtl.mirror(root: GuiObject)
	const layout = root:FindFirstChildWhichIsA("UIGridStyleLayout")
	if layout then
		Rtl.flipListAlign(layout)
	end
	for _, child in root:GetChildren() do
		if child:IsA("GuiObject") then
			if not layout then
				Rtl.flipX(child)
			end
			Rtl.mirror(child)
		end
	end
end

--> The mirror for a game whose locale answers `isRtl`. It is asked on every call, so a locale
--> that changes mid-session is followed by whatever is built afterwards.
function Rtl.reader(isRtl: () -> boolean): Reader
	return {
		active = isRtl,
		apply = function(root: GuiObject)
			if isRtl() then
				Rtl.mirror(root)
				Rtl.alignText(root)
			end
		end,
		flipEdge = function(frame: GuiObject)
			if isRtl() then
				Rtl.flipX(frame)
			end
		end,
		slot = function(index: number): number
			return if isRtl() then -index else index
		end,
		start = function(): Enum.TextXAlignment
			return if isRtl() then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left
		end,
	}
end

return Rtl
