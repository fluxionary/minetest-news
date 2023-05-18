local private_state
news, private_state = fmod.create()

local mod_storage = private_state.mod_storage

local f = string.format
local S = news.S

local function get_news()
	return mod_storage:get_string("news")
end

local function get_last_update()
	return mod_storage:get_int("last_update")
end

local function set_news(news)
	mod_storage:set_string("news", news)
	mod_storage:set_int("last_update", os.time())
end

local function last_seen_key(player_name)
	return f("p:%s", player_name)
end

local function get_last_seen(player_name)
	return mod_storage:get_int(last_seen_key(player_name))
end

local function set_last_seen(player_name, last_seen)
	mod_storage:set_int(last_seen_key(player_name), last_seen)
end

local function build_show_formspec()
	local parts = {
		"size[12,8.25]",
		f("button_exit[-0.05,7.8;2,1;exit;X]"),
		f("textarea[0.25,0;12.1,9;news;;%s]", get_news()),
	}
	return table.concat(parts, "")
end

local function build_edit_formspec()
	local parts = {
		"size[12,8.25]",
		f("button_exit[-0.05,7.8;2,1;exit;submit]"),
		f("textarea[0.25,0;12.1,9;news;;%s]", get_news()),
	}
	return table.concat(parts, "")
end

minetest.register_chatcommand("news_edit", {
	description = S("edit news"),
	privs = { [news.settings.edit_priv] = true },
	func = function(name)
		minetest.show_formspec(name, "news:edit", build_edit_formspec())
	end,
})

minetest.register_chatcommand("news", {
	description = S("show news"),
	func = function(name)
		minetest.show_formspec(name, "news:read", build_show_formspec())
	end,
})

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	if get_last_seen(player_name) < get_last_update() then
		minetest.show_formspec(player_name, "news:read", build_show_formspec())
		set_last_seen(player_name, os.time())
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "news:edit" and minetest.check_player_privs(player, news.settings.edit_priv) and fields.news then
		set_news(fields.news)
	end
end)
