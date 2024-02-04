archtec_ci = {}

local mp = minetest.get_modpath("archtec_ci")

dofile(mp .. "/dumpnodes.lua")

function archtec_ci.run()
	archtec_ci.dumpnodes()
end

minetest.after(2, archtec_ci.run)

minetest.after(10, function()
	minetest.request_shutdown("CI")
end)