--!strict
--- Whether the kit holds the world's prompts off, and what it gives back when it lets go.
---
--- While a gamepad owns a panel, the buttons a prompt listens to belong to the panel, so `Focus`
--- switches `ProximityPromptService` off. The switch is the game's too: a game turns its prompts
--- off for reasons of its own (a cutscene, a camera shot) and expects them to stay off. So the kit
--- writes the switch only when its own hold begins or ends, remembers what the game had it at
--- when the hold began, and gives exactly that back. With no hold, a panel opening or closing
--- leaves the switch alone.
const PromptHold = {}

export type Hold = {
	--- Whether the kit holds the prompts off now.
	held: boolean,
	--- What the switch read when the hold began.
	before: boolean,
}

--> No hold yet.
function PromptHold.new(): Hold
	return { held = false, before = true }
end

--> The kit wants the prompts held (`want`) and the switch reads `now`: what to write to the
--> switch, or nil to leave it as it is.
function PromptHold.step(hold: Hold, want: boolean, now: boolean): boolean?
	if want and not hold.held then
		hold.held, hold.before = true, now
		return false
	elseif not want and hold.held then
		hold.held = false
		return hold.before
	end
	return nil
end

--> `step` against the service itself: writes its switch only when the hold begins or ends.
function PromptHold.apply(hold: Hold, want: boolean, service: ProximityPromptService)
	const write = PromptHold.step(hold, want, service.Enabled)
	if write ~= nil then
		service.Enabled = write
	end
end

return PromptHold
