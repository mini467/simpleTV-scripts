-- скрапер TVS для загрузки плейлиста "ontivi" http://ontivi.net (21/3/20)
-- необходим видоскрипт: ontivi
-- ## переименовать каналы ##
local filter = {
	{'имя до', 'после'},
	}
-- ##
	module('ontivi_pls', package.seeall)
	local my_src_name = 'ontivi'
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\ontivi.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, show_progress = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 0, ExtFilter = 1, FilterCH = 0, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3785.143 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = 'http://ontivi.net'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url .. '/chanel'})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local t, i = {}, 1
		local adr, title
			for w in answer:gmatch('<div class="all%-channel%-item">.-</li>') do
				adr = w:match('href="([^"]+)')
				title = w:match('"name">([^<]+)')
				if adr and title then
					t[i] = {}
					t[i].name = title:gsub(',', '%%2C')
					t[i].address = url .. adr
					i = i + 1
				end
			end
			if i == 1 then return end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then
				m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - ошибка загрузки плейлиста'
												, color = ARGB(255, 255, 0, 0)
												, showTime = 1000 * 5
												, id = 'channelName'})
			 return
			end
		t_pls = ProcessFilterTableLocal(t_pls)
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')'
										, color = ARGB(255, 155, 255, 155)
										, showTime = 1000 * 5
										, id = 'channelName'})
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')