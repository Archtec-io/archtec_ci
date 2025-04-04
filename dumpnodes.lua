local function get_tile(tiles, n)
	local tile = tiles[n]
	if type(tile) == "table" then
		return tile.name or tile.image
	elseif type(tile) == "string" then
		return tile
	end
end

local function strip_texture(tex)
	tex = (tex .. "^"):match("%(*(.-)%)*^") -- strip modifiers
	if tex:find("[combine", 1, true) then
		tex = tex:match(".-=([^:]-)") -- extract first texture
	elseif tex:find("[png", 1, true) then
		return nil -- can"t
	end
	return tex
end

local function pairs_s(dict)
	local keys = {}
	for k in pairs(dict) do
		keys[#keys+1] = k
	end
	table.sort(keys)
	return ipairs(keys)
end

function archtec_ci.dumpnodes()
	local ntbl = {}
	for _, nn in pairs_s(core.registered_nodes) do
		local prefix, name = nn:match("(.-):(.*)")
		if prefix == nil or name == nil then
			print("ignored(1): " .. nn)
		else
			if ntbl[prefix] == nil then
				ntbl[prefix] = {}
			end
			ntbl[prefix][name] = true
		end
	end
	local out, err = io.open(core.get_worldpath() .. "/nodes.txt", "wb")
	if not out then
		return true, err
	end
	local n = 0
	for _, prefix in pairs_s(ntbl) do
		out:write("# " .. prefix .. "\n")
		for _, name in pairs_s(ntbl[prefix]) do
			local nn = prefix .. ":" .. name
			local nd = core.registered_nodes[nn]
			local tiles = nd.tiles or nd.tile_images
			if tiles == nil or nd.drawtype == "airlike" then
				print("ignored(2): " .. nn)
			else
				local tex = get_tile(tiles, 1)
				tex = tex and strip_texture(tex)
				if not tex then
					print("ignored(3): " .. nn)
				else
					out:write(nn .. " " .. tex .. "\n")
					n = n + 1
				end
			end
		end
		out:write("\n")
	end
	out:close()
	return true, n .. " nodes dumped."
end
