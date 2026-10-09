--!strict
--- Wires the backpack's parts together for one player: the Tools the game describes, their order,
--- what a tap and a drop mean, what is drawn, the keys and the gamepad. `Backpack` is its front door
--- and says what each part does.
const Bar = require("./Bar")
const Config = require("./Config")
const Dialog = require("../Dialog")
const Gesture = require("./Gesture")
const Grid = require("./Grid")
const HotbarCover = require("../HotbarCover")
const Items = require("./Items")
const Keys = require("./Keys")
const Moves = require("./Moves")
const Order = require("./Order")
const Pad = require("./Pad")
const Paint = require("./Paint")
const Rest = require("./Rest")
const Slot = require("./Slot")
const TouchControls = require("../TouchControls")

const Mount = {}

--- A touch screen narrower than this gets the stock backpack's small layout.
Mount.PHONE_W = 1024

export type Act = Config.Act
export type Config = Config.Config
export type Handle = Config.Handle

--> Draws `player`'s backpack and follows it for the session. Roblox's own is switched off.
function Mount.mount(player: Player, config: Config): Handle
	HotbarCover.disableCore()
	const playerGui = player:WaitForChild("PlayerGui")
	const gui = Instance.new("ScreenGui")
	gui.Name = "Backpack"
	gui.ResetOnSpawn = false
	-- Input positions and AbsolutePosition share a space this way (`Gesture`).
	gui.IgnoreGuiInset = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	const used = config.used
	const function count(act: Act)
		if used then
			used(act)
		end
	end

	const moves = Moves.new()
	local watch: Items.Watch? = nil
	const grid = Grid.new(gui, Bar.BOTTOM + Bar.HEIGHT + 4, config.text, config.filters or {})
	local state: Paint.State
	local render: () -> ()
	local bar: Bar.Bar
	local pad: Pad.Pad

	const function equip(id: string)
		const item = state.byId[id]
		const character = player.Character
		const humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not (item and humanoid) then
			return
		end
		if item.tool.Parent == character then
			humanoid:UnequipTools()
		else
			humanoid:EquipTool(item.tool)
		end
	end

	const function tap(source: Gesture.Source)
		const picked = moves.picked
		const result = Moves.tap(moves, state.order, os.clock(), source.id, source.place, state.open)
		if result == "equip" and source.id then
			equip(source.id)
		elseif result == "sent" then
			count("Double")
		elseif result == "moved" and picked then
			count("Pair")
		end
		render()
	end

	const gesture = Gesture.new({
		gui = gui,
		scroller = grid.scroller,
		editing = function(): boolean
			return state.open
		end,
		tap = tap,
		drop = function(source: Gesture.Source, point: Vector2)
			const target = Paint.hit(state, point)
			if source.id and Moves.drop(moves, state.order, source.id, target) == "moved" then
				count("Drag")
			end
			render()
		end,
		ghost = function(source: Gesture.Source): GuiObject?
			const slot = Paint.slotOf(state, source.id)
			return if slot then slot.ghost() else nil
		end,
		lifted = function(source: Gesture.Source, on: boolean)
			const slot = Paint.slotOf(state, source.id)
			if slot then
				slot.setLifted(on)
			end
		end,
	})

	const function bindSlot(slot: Slot.Slot)
		gesture.bind(slot.frame, function(): Gesture.Source?
			return { id = slot.id, place = slot.place }
		end)
		-- The tip above a slot under the mouse or a gamepad's focus.
		pad.slot(slot, function(on: boolean)
			bar.hover(if on then slot else nil, if on and slot.id then state.byId[slot.id] else nil)
		end)
	end
	gesture.bind(grid.scroller, function(): Gesture.Source?
		return { id = nil, place = { zone = "grid", index = 0 } }
	end)

	bar = Bar.new(gui, bindSlot, config.draw)

	state = {
		order = Order.new(10, config.pinned),
		byId = {},
		gridSlots = {},
		bar = bar,
		grid = grid,
		open = false,
		picked = nil :: string?,
		hidden = false,
		inHand = function(): Tool?
			return if watch then watch.inHand() else nil
		end,
		rests = {},
		clock = os.clock,
		newSlot = function(index: number): Slot.Slot
			const slot = Slot.new(grid.scroller, { zone = "grid", index = index }, config.draw)
			slot.setNumber(nil)
			-- The scroller sinks clicks already; an Active slot might keep a finger's swipe from
			-- scrolling it.
			slot.frame.Active = false
			bindSlot(slot)
			return slot
		end,
	}

	-- Many changes land in one frame (a respawn refills everything): drawn once.
	local queued = false
	render = function()
		if queued then
			return
		end
		queued = true
		task.defer(function()
			queued = false
			state.picked = moves.picked
			state.hidden = HotbarCover.hidden()
			Paint.all(state)
		end)
	end

	const function setOpen(want: boolean)
		if want == state.open or (want and HotbarCover.hidden()) then
			return
		end
		state.open = want
		grid.frame.Visible = want
		-- On a phone the open inventory reaches the thumbstick's corner.
		TouchControls.set("backpack", want)
		Moves.clear(moves)
		gesture.cancel()
		bar.hover(nil, nil)
		pad.opened(want)
		if want then
			count("Open")
			grid.scroller.CanvasPosition = Vector2.zero
		end
		render()
	end

	const function heldId(): string?
		return Items.idOf(state.byId, state.inHand())
	end

	pad = Pad.new({
		gui = gui,
		bar = bar,
		tap = tap,
		equip = equip,
		held = heldId,
		button = config.padEquip,
		send = function(id: string)
			Moves.send(moves, state.order, id)
			render()
		end,
		close = function()
			setOpen(false)
		end,
	})

	const function fit()
		const camera = game:GetService("Workspace").CurrentCamera
		const phone = game:GetService("UserInputService").TouchEnabled
			and camera ~= nil
			and camera.ViewportSize.X < Mount.PHONE_W
		const size = if phone then 3 else 10
		if size ~= #bar.slots then
			Order.resize(state.order, size)
			bar.resize(size)
			grid.resize(if phone then 6 else 10, if phone then 2 else 4)
		end
		render()
	end
	fit()
	const camera = game:GetService("Workspace").CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
	end

	watch = Items.watch(player, config.describe, {
		added = function(item: Items.Item)
			const had = state.byId[item.id]
			state.byId[item.id] = item
			if not had then
				Order.add(state.order, item.id, item.fresh)
			end
			render()
		end,
		removed = function(item: Items.Item)
			if state.byId[item.id] ~= item then
				return
			end
			state.byId[item.id] = nil
			Order.remove(state.order, item.id)
			if moves.picked == item.id then
				Moves.clear(moves)
			end
			render()
		end,
		held = render,
	})

	Keys.bind({
		slot = function(index: number)
			const id = if index <= state.order.size then state.order.bar[index] else nil
			if id then
				equip(id)
			end
		end,
		toggle = function()
			setOpen(not state.open)
		end,
		step = function(by: number)
			const id = Order.step(state.order, heldId(), by)
			if id then
				equip(id)
			end
		end,
	})

	grid.searched.Event:Connect(render)
	HotbarCover.onChange(function(hidden: boolean)
		if hidden then
			setOpen(false)
		end
		render()
	end)
	-- A dialog opening closes the inventory; the two would overlap.
	playerGui:GetAttributeChangedSignal(Dialog.OPEN_ATTRIBUTE):Connect(function()
		const up = playerGui:GetAttribute(Dialog.OPEN_ATTRIBUTE)
		if type(up) == "number" and up > 0 then
			setOpen(false)
		end
	end)

	return {
		toggle = function()
			setOpen(not state.open)
		end,
		rest = function(tool: Tool, seconds: number)
			for id, item in state.byId do
				if item.tool == tool then
					Rest.start(state.rests, id, seconds, state.clock())
					render()
				end
			end
		end,
	}
end

return Mount
