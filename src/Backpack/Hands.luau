--!strict
--- What a gamepad's "in the hands" button means (Y unless the game says another), and whether the
--- press is the backpack's at all. Pure, so every row is a spec (`tests/unit/BackpackHands.luau`);
--- `Pad` binds the button and does what this says.
---
--- A and X move things about the open inventory (`Moves`). Neither puts a thing in the hands: before
--- this button a pad's player sent the thing to the bar, closed the inventory and stepped along the
--- bar with the bumpers. One press now does what a press on the bar does with the inventory closed,
--- for any slot of the bar or the inventory, and closes the inventory after it.
---
--- | The inventory | The focus | The press is |
--- |---|---|---|
--- | closed, or the player is not on a gamepad, or another panel is over it | anywhere | `"pass"`: not ours, the game's own use of the button hears it |
--- | open, on a pad, holding the focus | not on a slot (the search box, a filter) | `"none"`: ours, and nothing happens |
--- | the same | on an empty slot | `"none"` |
--- | the same | on a thing that is not in the hands | `"equip"`: into the hands, and the inventory closes |
--- | the same | on the thing in the hands | `"stow"`: put away, as a press on its bar slot puts it away, and the inventory closes |
---
--- Every outcome but `"pass"` sinks the press: with the inventory open the button is the backpack's,
--- so a game's own use of it (a way home, a prompt) does not also fire.
const Hands = {}

export type Outcome = "equip" | "stow" | "none" | "pass"

export type Press = {
	--- The inventory is open.
	open: boolean,
	--- The player is on a gamepad now.
	pad: boolean,
	--- The inventory is the panel that holds the pad's focus: no other panel is over it.
	holds: boolean,
	--- The focus is on a slot of the bar or the inventory.
	slot: boolean,
	--- What that slot holds; nil for an empty one.
	id: string?,
	--- What is in the hands; nil with empty hands.
	held: string?,
}

--> What one press of the button is.
function Hands.press(press: Press): Outcome
	if not (press.open and press.pad and press.holds) then
		return "pass"
	end
	const id = press.id
	if not press.slot or id == nil then
		return "none"
	end
	return if id == press.held then "stow" else "equip"
end

--> Whether the press belongs to the backpack, so nothing else may hear it.
function Hands.sinks(outcome: Outcome): boolean
	return outcome ~= "pass"
end

--> Whether the press changes what is in the hands; the inventory closes after one that does.
function Hands.acts(outcome: Outcome): boolean
	return outcome == "equip" or outcome == "stow"
end

--> The button to bind: the game's `option`, the kit's `default` when the game says nothing, and nil
--> (no button, nothing bound) when the game says `false`.
function Hands.button<Key>(option: Key | false | nil, default: Key): Key?
	if option == false then
		return nil
	end
	return if option == nil then default else option
end

return Hands
