-- Leader key support.
--
-- Plugins (and users) bind chords under the pseudo-key prefix <vis-leader>:
--
--	vis:map(vis.modes.NORMAL, '<vis-leader>n', fn)
--
-- No keyboard input ever produces "<vis-leader>" itself, so such bindings
-- lie dormant until a leader key is chosen. The `leader` option installs a
-- key alias expanding to <vis-leader> in the normal and visual modes:
--
--	:set leader \	 use backslash as the leader in the focused window
--	:set leader none  disable again
--
-- Setting the option while a window is focused applies to that window only
-- (e.g. per filetype via WIN_OPEN); setting it from visrc at startup, before
-- any window exists, applies globally.

-- the pseudo-key must name a registered action to be tokenized by
-- vis_keys_next; pressing a leader with no chord completion runs it (no-op)
vis:action_register('vis-leader', function() end,
	'Leader chord prefix, see the `leader` option')

local MODES = { vis.modes.NORMAL, vis.modes.VISUAL, vis.modes.VISUAL_LINE }

local global_leader = nil
local window_leaders = setmetatable({}, {__mode = 'k'})

local function apply(target, key, old)
	for _, mode in ipairs(MODES) do
		if old then pcall(function() target:unmap(mode, old) end) end
		if key then target:map(mode, key, '<vis-leader>') end
	end
end

vis:option_register('leader', 'string', function(value)
	local key = value
	if key == '' or key == 'none' or key == 'off' then key = nil end
	local win = vis.win
	if win then
		apply(win, key, window_leaders[win])
		window_leaders[win] = key
	else
		apply(vis, key, global_leader)
		global_leader = key
	end
	return true
end, function()
	local win = vis.win
	return (win and window_leaders[win]) or global_leader or 'none'
end, 'Key aliased to the <vis-leader> mapping prefix (`none` disables)')
