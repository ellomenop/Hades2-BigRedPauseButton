---@meta _
-- grabbing our dependencies,
-- these funky (---@) comments are just there
--	 to help VS Code find the definitions of things

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'SGG_Modding-ENVY-auto'
mods['SGG_Modding-ENVY'].auto()
-- ^ this gives us `public` and `import`, among others
--	and makes all globals we define private to this plugin.
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = PLUGIN

---@module 'SGG_Modding-Hades2GameDef-Globals'
game = rom.game
import_as_fallback(game)

---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
chalk_config = chalk.auto 'config.lua'
config = {
	enabled = chalk_config.enabled,
	pause_keybind = chalk_config.pause_keybind,
	previously_bound_keys = {chalk_config.pause_keybind}
}
public.config = config -- so other mods can access our config

-- ^ this updates our `.cfg` file in the config folder!
public.config = config -- so other mods can access our config

function toggle_pause()
	config.running = not config.running
	if not config.running then
		game.ClearSimSpeedChanges()
	end
end

function keybind_callback_and_no_op_if_changed(key, callback)
	print("Pressed " .. key .. " and current keybind is ".. chalk_config.pause_keybind)
	if key == chalk_config.pause_keybind then
		callback()
	end
end

local function on_ready()
	-- what to do when we are ready, but not re-do on reload.
	if config.enabled == false then return end

	rom.gui.add_imgui(function()
		if rom.ImGui.Begin("Big Red Pause Button") then

			rom.ImGui.Text("Green = paused, red = unpaused:")

			local color = { 1, 0, 0, 1 }
			if config.running then
				color = {0, 1, 0, 1}
			end

			local pressed = rom.ImGui.ColorButton("BigRedPauseButton", color, rom.ImGuiColorEditFlags.NoTooltip, 200, 200)
			if pressed then
				toggle_pause()
			end

			rom.ImGui.End()
		end
	end)

	rom.gui.add_imgui(function()
		rom.ImGui.SetNextWindowSize(400, 150)
		if rom.ImGui.Begin("BRPB - Pause Keybind") then
	
			rom.ImGui.Text("Pause Keybind (e.g. \"Shift P\" or \"X\" or \"ControlShift Z\")")
			rom.ImGui.Text("But not all keys work without modifiers")
			local text, enter_pressed = rom.ImGui.InputText("",  chalk_config.pause_keybind, 50, rom.ImGuiInputTextFlags.EnterReturnsTrue)
			if enter_pressed then
				chalk_config.pause_keybind = text
				if not game.Contains(config.previously_bound_keys, text) then
					table.insert(config.previously_bound_keys, text)
					rom.inputs.on_key_pressed{text, Name = "BigRedPause", function() 
						keybind_callback_and_no_op_if_changed(text, toggle_pause)
					end}
				end
			end

			rom.ImGui.End()
		end
	end)

	local keybind = chalk_config.pause_keybind
	rom.inputs.on_key_pressed{keybind, Name = "BigRedPause", function() 
		keybind_callback_and_no_op_if_changed(keybind, toggle_pause)
	end}
end

local function on_reload()
	-- what to do when we are ready, but also again on every reload.
	-- only do things that are safe to run over and over.

	import 'reload.lua'
end

-- this allows us to limit certain functions to not be reloaded.
local loader = reload.auto_single()

-- this runs only when modutil and the game's lua is ready
modutil.on_ready_final(function()
	loader.load(on_ready, on_reload)
end)
