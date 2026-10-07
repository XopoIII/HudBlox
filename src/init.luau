--!strict
--- HudBlox: HUD capsules and round buttons that look like Roblox's own top bar, placed by the
--- device's real safe zones.
---
---     const HudBlox = require(path.to.HudBlox)
---     const theme = { icon = HudBlox.Icons.resolver({ ids = MyIcons }) }
---     const gui = HudBlox.SafeArea.screen(playerGui, "Hud")
---     const row = HudBlox.TopBar.mount(gui, theme)
---     const wallet = row.addPill({ { lead = "coin", pin = { "999.9K" } } })
---     wallet.segments[1].value.Text = "120"
---
--- A kit module reads nothing of the game it is in: the icons and every colour beyond Roblox's
--- measured plate are arguments, and what there is one of for the whole client (which way the
--- reader reads, who counts a gamepad's presses) is said once through `Host`. Nothing touches
--- `game` when it is required. See README.md for the whole API.
const Backpack = require("@self/Backpack")
const Badge = require("@self/Badge")
const Band = require("@self/Band")
const Button = require("@self/Button")
const Clearance = require("@self/Clearance")
const Dialog = require("@self/Dialog")
const DialogGeometry = require("@self/DialogGeometry")
const Focus = require("@self/Focus")
const Host = require("@self/Host")
const HotbarCover = require("@self/HotbarCover")
const Icons = require("@self/Icons")
const Indicator = require("@self/Indicator")
const Layout = require("@self/Layout")
const Measure = require("@self/Measure")
const Native = require("@self/Native")
const PadGlyph = require("@self/PadGlyph")
const PadInput = require("@self/PadInput")
const PadMenu = require("@self/PadMenu")
const Pick = require("@self/Pick")
const Pill = require("@self/Pill")
const Ring = require("@self/Ring")
const Rtl = require("@self/Rtl")
const SafeArea = require("@self/SafeArea")
const Stack = require("@self/Stack")
const Theme = require("@self/Theme")
const TopBar = require("@self/TopBar")
const TouchClearance = require("@self/TouchClearance")
const TouchControls = require("@self/TouchControls")

export type Theme = Theme.Theme
export type Icon = Theme.Icon
export type IconOptions = Icons.Options
export type Part = Pill.Part
export type Segment = Pill.Segment
export type Capsule = Pill.Capsule
export type Row = TopBar.Row
export type ButtonOptions = Button.Options
export type BadgeOptions = Badge.Options
export type BadgeHandle = Badge.Handle
export type Screen = Layout.Screen
export type Top = Layout.Top
export type Control = Clearance.Control
export type Rect = Band.Rect
export type Follow = Indicator.Follow
export type RtlReader = Rtl.Reader
export type HostHooks = Host.Hooks
export type PadAct = Host.PadAct
export type DialogOptions = Dialog.Options
export type DialogHandle = Dialog.Dialog
export type DialogBottom = DialogGeometry.Bottom
export type DialogFrame = DialogGeometry.Frame
export type FocusOptions = Focus.Options
export type PickTarget = Pick.Target
export type PadMenuConfig = PadMenu.Config
export type BackpackConfig = Backpack.Config
export type BackpackHandle = Backpack.Handle
export type BackpackItem = Backpack.Item
export type BackpackWords = Backpack.Words
export type BackpackFilter = Backpack.Filter
export type BackpackDraw = Backpack.Draw
export type BackpackAct = Backpack.Act
export type BackpackOrder = Backpack.Order
export type BackpackPlace = Backpack.Place

return {
	--- The top line: the right row and the left buttons.
	TopBar = TopBar,
	--- A capsule on its own.
	Pill = Pill,
	--- A round button on its own.
	Badge = Badge,
	Button = Button,
	--- Builds a theme's `icon` from a table of asset ids.
	Icons = Icons,
	--- The theme's type and its defaults.
	Theme = Theme,
	--- Reads the screen: the HUD's ScreenGui, Roblox's strip, the top-bar inset.
	SafeArea = SafeArea,
	--- Reads the touch controls for the bottom corners.
	TouchClearance = TouchClearance,
	--- The game's own bottom furniture, reported and cleared.
	Band = Band,
	--- The corner read-outs.
	Indicator = Indicator,
	--- Roblox's menu look: colours, type, buttons.
	Native = Native,
	--- The right-to-left mirror.
	Rtl = Rtl,
	--- What a game says of itself once: its reader's direction, its pad counter.
	Host = Host,
	--- A whole dialog, and the arithmetic of where it sits.
	Dialog = Dialog,
	DialogGeometry = DialogGeometry,
	--- Where a gamepad's selection is, one panel at a time; its ring, and the pure parts.
	Focus = Focus,
	Ring = Ring,
	Pick = Pick,
	Stack = Stack,
	--- Whether the player is on a gamepad, a button's picture, and the D-pad's way to the top bar.
	PadInput = PadInput,
	PadGlyph = PadGlyph,
	PadMenu = PadMenu,
	--- Hides the touch controls and holds the character under a dialog.
	TouchControls = TouchControls,
	--- A hotbar and the inventory above it in the stock layout, drawn for the game's own Tools; and
	--- what hides a hotbar while something covers it.
	Backpack = Backpack,
	HotbarCover = HotbarCover,
	--- The arithmetic, free of Instances: the top line, and the bottom corners.
	Layout = Layout,
	Clearance = Clearance,
	--- The measured numbers.
	Measure = Measure,
}
