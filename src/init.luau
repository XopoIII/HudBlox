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
--- A kit module reads nothing of the game it is in: the icons, the locale's direction, the focus
--- ring and every colour beyond Roblox's measured plate are arguments. Nothing touches `game`
--- when it is required. See README.md for the whole API.
const Band = require("@self/Band")
const Button = require("@self/Button")
const Clearance = require("@self/Clearance")
const Icons = require("@self/Icons")
const Indicator = require("@self/Indicator")
const Layout = require("@self/Layout")
const Measure = require("@self/Measure")
const Native = require("@self/Native")
const Pill = require("@self/Pill")
const Rtl = require("@self/Rtl")
const SafeArea = require("@self/SafeArea")
const Theme = require("@self/Theme")
const TopBar = require("@self/TopBar")
const TouchClearance = require("@self/TouchClearance")

export type Theme = Theme.Theme
export type Icon = Theme.Icon
export type IconOptions = Icons.Options
export type Part = Pill.Part
export type Segment = Pill.Segment
export type Capsule = Pill.Capsule
export type Row = TopBar.Row
export type ButtonOptions = Button.Options
export type Screen = Layout.Screen
export type Top = Layout.Top
export type Control = Clearance.Control
export type Rect = Band.Rect
export type Follow = Indicator.Follow
export type RtlReader = Rtl.Reader

return {
	--- The top line: the right row and the left buttons.
	TopBar = TopBar,
	--- A capsule on its own.
	Pill = Pill,
	--- A round button on its own.
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
	--- The arithmetic, free of Instances: the top line, and the bottom corners.
	Layout = Layout,
	Clearance = Clearance,
	--- The measured numbers.
	Measure = Measure,
}
