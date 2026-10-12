--!strict
--- Whether an action can be bound where this code runs.
---
--- The engine binds an action through `ContextActionService` from a client only; on a server the
--- call raises ("can only be called from a local script"). A game's own suite often runs on a
--- server (an Open Cloud task, a spec under `ServerScriptService`), and a dialog, a top bar's menu
--- or a backpack built there has no key and no pad to answer to. So the kit asks here before it
--- binds: on a client everything is bound as it always was, and on a server nothing is bound and
--- nothing is raised, and the panel is built, opened and closed all the same.
---
--- Unbinding is not asked about: the engine takes `UnbindAction` anywhere, and an action that was
--- never bound is unbound quietly.
const Bindable = {}

--> True on a client, false on a server.
function Bindable.here(): boolean
	return game:GetService("RunService"):IsClient()
end

return Bindable
