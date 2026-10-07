--!strict
--- Every Tool the local player has, in the Backpack or in hand, as the backpack draws it.
---
--- What a Tool is, the game says (`Describe`): the kit reads no attribute and no name off it.
---
--- Equipping moves a Tool from the Backpack into the character and back, and the engine may fire the
--- two halves in either order, so a removal is only believed a frame later, once the Tool has not
--- turned up in the other. The Backpack itself is replaced on every respawn, and followed.
const Items = {}

--- One thing the backpack shows, as the game describes its Tool.
export type Item = {
	tool: Tool,
	--- The same for the same kept thing through a hold, a stow, a death and a respawn.
	id: string,
	--- Just taken: it goes on the bar, and pushes the oldest thing off a full one.
	fresh: boolean,
	--- What the tip above its slot says, in the player's language.
	tip: string,
	--- Everything a search may find it by, as one text; the kit folds its case.
	search: string,
	--- Which filter shows it alone (`Grid.Filter.kind`).
	kind: string,
	--- The colour of its slot's rim; no rim when nil.
	rim: Color3?,
	--- Whether it counts in the inventory's number.
	counted: boolean,
	--- What its picture is of: two items with the same text draw the same picture, so a slot handed
	--- a fresh record of the same thing keeps its own.
	picture: string,
}

--- What `tool` is. Called once for each Tool as it arrives. The game's.
export type Describe = (tool: Tool) -> Item

export type Hooks = {
	added: (item: Item) -> (),
	--- The same id may already be back on a new Tool (a respawn refills the Backpack before the old
	--- one is swept), so the caller checks the Tool.
	removed: (item: Item) -> (),
	--- Something was equipped or put away.
	held: () -> (),
}

export type Watch = {
	--- Every item there is now.
	list: () -> { Item },
	--- The Tool in hand, if any.
	inHand: () -> Tool?,
}

--> Follows `player`'s Tools for the session, describing each with `describe`.
function Items.watch(player: Player, describe: Describe, hooks: Hooks): Watch
	const items: { [Tool]: Item } = {}
	local backpack: Instance? = nil
	local character: Model? = nil

	const function home(tool: Tool): boolean
		const parent = tool.Parent
		return parent ~= nil and (parent == backpack or parent == character)
	end

	const function arrive(child: Instance)
		if not child:IsA("Tool") then
			return
		end
		if items[child] then
			hooks.held()
			return
		end
		const item = describe(child)
		items[child] = item
		hooks.added(item)
		if child.Parent == character then
			hooks.held()
		end
	end

	const function leave(child: Instance)
		if not child:IsA("Tool") or not items[child] then
			return
		end
		task.defer(function()
			const item = items[child]
			if not item then
				return
			end
			if home(child) then
				hooks.held()
				return
			end
			items[child] = nil
			hooks.removed(item)
			hooks.held()
		end)
	end

	const function follow(container: Instance)
		container.ChildAdded:Connect(arrive)
		container.ChildRemoved:Connect(leave)
		for _, child in container:GetChildren() do
			arrive(child)
		end
	end

	-- Anything no longer in either: a Backpack or a character destroyed whole may not report each
	-- Tool on the way out.
	const function sweep()
		for tool, item in items do
			if not home(tool) then
				items[tool] = nil
				hooks.removed(item)
			end
		end
		hooks.held()
	end

	const function onBackpack(child: Instance)
		if child:IsA("Backpack") then
			backpack = child
			task.defer(sweep)
			follow(child)
		end
	end

	const function onCharacter(model: Model)
		character = model
		task.defer(sweep)
		follow(model)
	end

	player.ChildAdded:Connect(onBackpack)
	const current = player:FindFirstChildOfClass("Backpack")
	if current then
		onBackpack(current)
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		onCharacter(player.Character)
	end

	return {
		list = function(): { Item }
			const out: { Item } = {}
			for _, item in items do
				table.insert(out, item)
			end
			return out
		end,
		inHand = function(): Tool?
			return if character then character:FindFirstChildOfClass("Tool") else nil
		end,
	}
end

return Items
