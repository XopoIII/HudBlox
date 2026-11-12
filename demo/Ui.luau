--!strict
--- Complete additive public UI API consumer; checked under both solvers, not engine execution.
const Hud = require(game:GetService("ReplicatedStorage"):WaitForChild("HudBlox"))
const function mount(parent: Instance)
	const dialog: Hud.DialogHandle =
		Hud.Dialog.new(parent, "Slots", "", 620, 600, { minimumHit = 44, scale = 1, onClose = function() end })
	const column = Hud.DialogColumn.mount(dialog.body)
	const surface = Hud.Surface.mount(column, { kind = "panel", size = UDim2.new(1, 0, 0, 160), padding = 12 })
	const row = Hud.Surface.row(surface, { height = 48, gap = 8 })
	const button = Hud.Native.button(row, "", "secondary")
	Hud.Native.state(button, true, true)
	-- A press and a tap are different questions, so they get different buttons: a hold reports the
	-- finger, a tap reports the activation. One button with both would run an action twice.
	const tapped = Hud.Native.button(row, "", "secondary")
	const progress: Hud.ProgressHandle = Hud.Progress.mount(surface, { height = 8, color = Hud.Native.PRIMARY })
	progress.set(0.5)
	const viewport = Hud.Viewport.mount(surface)
	const drag: Hud.PointerHandle = Hud.Pointer.drag(viewport, {
		moved = function(dx: number, dy: number)
			print(dx, dy)
		end,
		ended = function() end,
	})
	const hold = Hud.Pointer.hold(button, {
		began = function(input: InputObject)
			print(input.UserInputType)
		end,
		ended = function(input: InputObject)
			print(input.UserInputType)
		end,
	})
	const stopClick = Hud.Pointer.activate(tapped, dialog.toggle)
	const stop = dialog.observe(function(open: boolean)
		print(open)
	end)
	dialog.primary(button)
	dialog.setOpen(true)
	print(dialog.isOpen())
	return function()
		stop()
		stopClick()
		hold.cancel()
		hold.destroy()
		drag.cancel()
		drag.destroy()
		progress.destroy()
		dialog.destroy()
		dialog.destroy()
	end
end
return mount
