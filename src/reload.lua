---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- so only assign to values or define things here.
function StartPauseWatcher()
    thread_running = true

    while thread_running do
		if config.running then
			game.AddSimSpeedChange("bigredpausebutton", {Fraction = 0, LerpTime = 0, Priority = true})
		end

		-- Update once per frame
        wait(0.016)
    end
end

OnAnyLoad{ function()
    -- Every load tell the previous timer to stop and start a new one (modUtil LoadOnce wasn't working)
	thread_running = false
    wait(0.016)
    thread(StartPauseWatcher)
end}
