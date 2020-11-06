-- скрапер TVS для загрузки плейлиста "corntv" http://corntv.ru (29/9/20)
-- Copyright © 2017-2020 Nexterr
-- необходим видоскрипт: corntv.lua
-- ## переименовать каналы ##
local filter = {
	{'1000', 'TV1000'},
	{'1000 Action', 'TV1000 Action'},
	{'1000 Comedy', 'ViP Comedy'},
	{'1000 Megahit', 'ViP Megahit'},
	{'1000 Premium', 'ViP Premiere'},
	{'1000 Русское кино', 'TV1000 Русское кино'},
	}
-- ##
	module('corntv_pls', package.seeall)
	local my_src_name = 'corntv'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\corntv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:82.0) Gecko/20100101 Firefox/82.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 16000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'http://corntv.ru/live-tv.html'})
			if rc ~= 200 then return end
		answer = answer:gsub('<!%-.-%->', '')
		local cat, i = {}, 1
			for adr, title in answer:gmatch('href="(https?://corntv%.ru/live%-tv/category/.-)">(.-)<') do
				if adr and title then
					cat[i] = {}
					cat[i].name = title
					cat[i].address = adr
					i = i + 1
				end
			end
			if i == 1 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local t, j = {}, 1
		local adr, title
			for x = 1, #cat do
				local rc, answer = m_simpleTV.Http.Request(session, {url = cat[x].address})
				if rc == 200 then
					answer = answer:gsub('<!%-.-%->', '')
						for w in answer:gmatch('<figure.-</figure>') do
							adr = w:match('href="([^"]+)')
							title = w:match('<figcaption.->([^<]+)')
							if adr and title then
								t[j] = {}
								t[j].name = title
								t[j].group = cat[x].name
								t[j].group_logo = 'http://corntv.ru/uploads/logo_popkorn_iskh.png'
								t[j].group_is_unique = 1
								t[j].logo = w:match('data%-src="([^"]+)')
								t[j].address = adr
								j = j + 1
							end
						end
				end
			end
		m_simpleTV.Http.Close(session)
			if i == j then return end
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
											, color = 0xffff6600
											, showTime = 1000 * 5
											, id = 'channelName'})
			 return
			end
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')'
									, color = 0xff99ff99
									, showTime = 1000 * 5
									, id = 'channelName'})
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')