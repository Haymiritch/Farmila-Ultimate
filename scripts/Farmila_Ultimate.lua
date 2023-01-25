os.execute('color 0')

require('addon')
local effil = require 'effil'
local sampev = require('samp.events')
local vector3d = require('libs.vector3d')
local ss = require('samp-store')
local requests = require('requests')
local inicfg = require('inicfg')
local cfg = inicfg.load(nil, 'Farmila_Settings')
local ffi = require('ffi')
local socket = require 'socket'

local temppass = ('')
local servername = ('������ ����������')
local serverip = ('���� ������� ����������')
local promo = ('mason')
local referal = ('Farmila_Referal')

local rep = false
local loop = false
local packet, veh = {}, {}
local counter = 0

local timer = false
local count = 0
local sekund = 0
local minut = 0
local chas = 0
local promoactivated = false
local napisal = false

ss.InitApiKey(cfg.sampstore.tokenss)

-- �� �������� �� ��� ������(�� � ����� ���� �� ����) ����� ������ ���������
----------------------------------------------------------------------------
local link = ('https://api.telegram.org/bot' .. cfg.telegram.tokenbot .. '/sendMessage?chat_id=' .. cfg.telegram.chatid .. '&text=')
-----�������� � �� �������/���������/���� ������
local ansi_decode={
  [128]='\208\130',[129]='\208\131',[130]='\226\128\154',[131]='\209\147',[132]='\226\128\158',[133]='\226\128\166',
  [134]='\226\128\160',[135]='\226\128\161',[136]='\226\130\172',[137]='\226\128\176',[138]='\208\137',[139]='\226\128\185',
  [140]='\208\138',[141]='\208\140',[142]='\208\139',[143]='\208\143',[144]='\209\146',[145]='\226\128\152',
  [146]='\226\128\153',[147]='\226\128\156',[148]='\226\128\157',[149]='\226\128\162',[150]='\226\128\147',[151]='\226\128\148',
  [152]='\194\152',[153]='\226\132\162',[154]='\209\153',[155]='\226\128\186',[156]='\209\154',[157]='\209\156',
  [158]='\209\155',[159]='\209\159',[160]='\194\160',[161]='\209\142',[162]='\209\158',[163]='\208\136',
  [164]='\194\164',[165]='\210\144',[166]='\194\166',[167]='\194\167',[168]='\208\129',[169]='\194\169',
  [170]='\208\132',[171]='\194\171',[172]='\194\172',[173]='\194\173',[174]='\194\174',[175]='\208\135',
  [176]='\194\176',[177]='\194\177',[178]='\208\134',[179]='\209\150',[180]='\210\145',[181]='\194\181',
  [182]='\194\182',[183]='\194\183',[184]='\209\145',[185]='\226\132\150',[186]='\209\148',[187]='\194\187',
  [188]='\209\152',[189]='\208\133',[190]='\209\149',[191]='\209\151'
}

function AnsiToUtf8(s)
  local r, b = ''
  for i = 1, s and s:len() or 0 do
    b = s:byte(i)
    if b < 128 then
      r = r..string.char(b)
    else
      if b > 239 then
        r = r..'\209'..string.char(b - 112)
      elseif b > 191 then
        r = r..'\208'..string.char(b - 48)
      elseif ansi_decode[b] then
        r = r..ansi_decode[b]
      else
        r = r..'_'
      end
    end
  end
  return r
end

function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end
    local status = t:status()
    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then resolve(result) else reject(result) end
    elseif err then
        reject(err)
    elseif status == 'canceled' then
        reject(status)
    end
    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end

function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then reject = function() end end
    newTask(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return AnsiToUtf8(str)
end

function sendtg(msg)
    msg = msg:gsub('{......}', '')
    msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. cfg.telegram.tokenbot .. '/sendMessage?chat_id=' .. cfg.telegram.chatid .. '&text='..msg,'', function(result) end)
end
---------------------------------------------

-----���� ����� � ����
function acclog(text)
	local f = io.open(getPath()..'\\scripts\\Farmila_Accounts.txt', 'a')
	f:write(text)
	f:close()
end

-----����� ��� ����� �����
function logaccount()
	-- Nick_Name | password | level | ip | money | servername | regip |
	local response = requests.get('https://api.ipify.org')
	if response.status_code == 200 then
		local regip = response.text
		local nick = getNick()
		local lvl = getScore()
		local money = getMoney()
		acclog(nick..' | '..pass..' | '..lvl..' | '..serverip..' | '..money..' | '..servername..' | '..regip..'\n')
		print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m������� ������� �������� � ��� ����.\x1b[0;37m')
	else
		acclog(nick..' | '..pass..' | '..lvl..' | '..serverip..' | '..money..' | '..servername..'\n')
		print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m������� ������� �������� ��� ��� ����.\x1b[0;37m')
	end
	if cfg.sampstore.vilagivat == 0 then
		generatenick()
	end
end

-----��� ���� �����
function sampstoreupload()
	sendInput('/mn')
	newTask(function()
		local response = requests.get('https://api.ipify.org')
		if response.status_code == 200 then
			local regip = response.text
		end
		wait(10000)
		if cfg.sampstore.vilagivat == 1 then
			local response = requests.get('https://api.ipify.org')
			if response.status_code == 200 then
				local regip = response.text
				local namen = getNick()
				local upload_res = ss.UploadAccount(serverip, cfg.sampstore.price, namen, pass, cfg.sampstore.infopokupo, cfg.sampstore.infoakk, regip)
				if upload_res then
					print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m������� ������� ������� �� ����-����.\x1b[0;37m')
					if cfg.telegram.ssakkuveda == 1 then
						sendtg('[Farmila Ultimate]\n\n������� ������� ������� �� ��������!\n���: '..nick..'\n������: '..servername..'\n�����: '..lvl..'\n������: '..servername..'\n���� �� �������: '..cfg.sampstore.price..'\n���� �� ������ ���� ������� � �������.')
					end
				end
			end
		end
		logaccount()
		wait(2500)
		generatenick()
		napisal = true
	end)
end

-----��� �������� �������
function onLoad()
	if cfg.settings.lvlprokachki < 6 then
		cfg.settings.lvlprokachki = 6
	end
	newTask(function()
		while true do
			wait(1)
			local lvl = getScore()
			local nick = getNick()
			local money = getMoney()
			setWindowTitle('[Farmila Ultimate] '..nick..' | '..servername..' | Level: '..lvl..' | Money: '..money)
		end
		local score = getScore()
		if score == cfg.settings.lvlprokachki and napisal == true then
			sampstoreupload()
			napisal = false
		end
	end)
	if cfg.settings.randomnick == 1 then
		generatenick()
	end
	if cfg.proxy.zahodsproxy == 1 then
		proxyConnect(cfg.proxy.proxyip, cfg.proxy.proxyuser, cfg.proxy.proxypass)
	end
	print('\x1b[0;36m------------------------------------------------------------------------\x1b[37m')
	print('')
	print('			\x1b[0;33mFARMILA ULTIMATE\x1b[37m  - \x1b[0;32m��������!\x1b[37m           ')
	print('           \x1b[0;33m                  REBORN    \x1b[37m                                         ')
	print('')
	print('\x1b[0;36m------------------------------------------------------------------------\x1b[37m')
end

-----���� ���� ������ �
function random(min, max)
	math.randomseed(os.time()*os.clock())
	return math.random(min, max)
end

-----��������� ������ ����
function generatenick()
	if cfg.settings.randompass == 1 then
		generatepass()
	end
	local names_and_surnames = {}
	for line in io.lines(getPath('config\\randomnick.txt')) do
		names_and_surnames[#names_and_surnames + 1] = line
	end
	local name = names_and_surnames[random(1, 5162)]
    local surname = names_and_surnames[random(5163, 81533)]
    local nick = ('%s_%s'):format(name, surname)
    setNick(nick)
	print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m�������� ��� ��: \x1b[0;32m'..getNick()..'\x1b[37m.')
	reconnect()
end

function generatepass()
	for k = random(8,8),1,-1 do
		temppass = temppass..string.char(random(97, 122))
	end
	pass = temppass
	temppass = ''
end


-----����� �� ������
function pobeg()
	if cfg.settings.spawnroute == 1 and lvl < cfg.settings.lvlprokachki then
		newTask(function()
			wait(6000)
			local x, y = getPosition()
			if x >= 1700 and x <= 1800 and y >= -1950 and y <= -1850 then -- old losantos spawn
				print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m�� �� ������ ������ ��.\x1b[0;37m')
				local put = random(1,50)
				runRoute('!play lsold'..put)
			elseif x >= 1000 and x <= 1200 and y >= -1900 and y <= -1700 then  -- new losantos spawn
				print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m�� �� ����� ������ ��.\x1b[0;37m')
				local put = random(1,51)
				runRoute('!play lsnew'..put)
			else
				print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m�� �� ������ ��/��, ���� ������ �� ���� ���������� �����.\x1b[0;37m')
			end
		end)
	end
end

function resetall()
	if counter > 1 then
		runRoute('!stop')
	end
	napisal = false
	counter = 0
	count = 0
end

-----��� �����������
function onConnect()
	resetall()
	serverip = getIP()
	if serverip == '185.169.134.3:7777' then
		servername = ('Phoenix')
		promo = cfg.promo.phoenix
		referal = cfg.referal.phoenix
	elseif serverip == '185.169.134.4:7777' then
		servername = ('Tucson')
		promo = cfg.promo.tucson
		referal = cfg.referal.tucson
	elseif serverip == '185.169.134.43:7777' then
		servername = ('Scottdale')
		promo = cfg.promo.scottdale
		referal = cfg.referal.scottdale
	elseif serverip == '185.169.134.44:7777' then
		servername = ('Chandler')
		promo = cfg.promo.chandler
		referal = cfg.referal.chandler
	elseif serverip == '185.169.134.45:7777' then
		servername = ('Brainburg')
		promo = cfg.promo.brainburg
		referal = cfg.referal.brainburg
	elseif serverip == '185.169.134.5:7777' then
		servername = ('Saint-rose')
		promo = cfg.promo.saintrose
		referal = cfg.referal.saintrose
	elseif serverip == '185.169.134.59:7777' then
		servername = ('Mesa')
		promo = cfg.promo.mesa
		referal = cfg.referal.mesa
	elseif serverip == '185.169.134.61:7777' then
		servername = ('Red-rock')
		promo = cfg.promo.redrock
		referal = cfg.referal.redrock
	elseif serverip == '185.169.134.107:7777' then
		servername = ('Yuma')
		promo = cfg.promo.yuma
		referal = cfg.referal.yuma
	elseif serverip == '185.169.134.109:7777' then
		servername = ('Surprise')
		promo = cfg.promo.surprise
		referal = cfg.referal.surprise
	elseif serverip == '185.169.134.166:7777' then
		servername = ('Prescott')
		promo = cfg.promo.prescott
		referal = cfg.referal.prescott
	elseif serverip == '185.169.134.171:7777' then
		servername = ('Glendale')
		promo = cfg.promo.glendale
		referal = cfg.referal.glendale
	elseif serverip == '185.169.134.172:7777' then
		servername = ('Kingman')
		promo = cfg.promo.kingman
		referal = cfg.referal.kingman
	elseif serverip == '185.169.134.173:7777' then
		servername = ('Winslow')
		promo = cfg.promo.winslow
		referal = cfg.referal.winslow
	elseif serverip == '185.169.134.174:7777' then
		servername = ('Payson')
		promo = cfg.promo.payson
		referal = cfg.referal.payson
	elseif serverip == '80.66.82.191:7777' then
		servername = ('Gilbert')
		promo = cfg.promo.gilbert
		referal = cfg.referal.gilbert
	elseif serverip == '80.66.82.190:7777' then
		servername = ('Showlow')
		promo = cfg.promo.showlow
		referal = cfg.referal.showlow
	elseif serverip == '80.66.82.188:7777' then
		servername = ('Casa-Grande')
		promo = cfg.promo.casagrande
		referal = cfg.referal.casagrande
	elseif serverip == '80.66.82.168:7777' then
		servername = ('Page')
		promo = cfg.promo.page
		referal = cfg.referal.page
	elseif serverip == '80.66.82.159:7777' then
		servername = ('Sun-City')
		promo = cfg.promo.suncity
		referal = cfg.referal.suncity
	elseif serverip == '80.66.82.200:7777' then
		servername = ('Queen-Creek')
		promo = cfg.promo.queencreek
		referal = cfg.referal.queencreek
	elseif serverip == '80.66.82.144:7777' then
		servername = ('Sedona')
		promo = cfg.promo.sedona
		referal = cfg.referal.sedona
	elseif serverip == '80.66.82.132:7777' then
		servername = ('Holiday')
		promo = cfg.promo.holiday
		referal = cfg.referal.holiday
	elseif serverip == '80.66.82.128:7777' then
		servername = ('Wednesday')
		promo = cfg.promo.wednesday
		referal = cfg.referal.wednesday
	end
end
-----�������
function sampev.onShowDialog(id, style, title, btn1, btn2, text)
	newTask(function()
		if title:find("%(1/4%) ������") then
			wait(2500)
			sendDialogResponse(id, 1, 0, cfg.settings.pass)
			return false
		end
		if title:find("%[2/4%] �������� ��� ���") then
			wait(2500)
			sendDialogResponse(id, 1, 0, '')
			return false
		end
		if title:find("%[3/4%] �������� ���� ����") then
			wait(2500)
			sendDialogResponse(id, 1, random(0, 1), '')
			return false
		end
		if title:find("%[4/4%] ������ �� � ��� ������?") then
			wait(2500)
			sendDialogResponse(id, 1, 1, '')
			return false
		end
		if title:find("%[4/4%] ������� ��� �������������?") then
			wait(2500)
			sendDialogResponse(id, 1, 0, referal)
			registered()
			joinedreg = true
			joinedlog = false
			return false
		end
		if title:find('�����������') then
			sendDialogResponse(id, 1, 0, cfg.settings.pass)
			joinedlog = true
			joinedreg = false
			return false
		end
	end)
	if title:find("�����") then
		sendDialogResponse(id, 0, 0, '')
		return false
	end
	if title:find("�������������� ����������") then
		sendDialogResponse(id, 1, 0, '')
		return false
	end
	if title:find("��������!") then
		sendDialogResponse(id, 1, 0, '')
		return false
	end
	if title:find('���� ������� ������������!') then
		generatenick()
		return false
	end
	if title:find('������� ����') then
		sendDialogResponse(id, 1, 10, '')
		return false
	end
	if text:find('������� �����') then
		sendDialogResponse(id, 1, 0, promo)
		return false
	end
	if text:find('�� ������������� ������ ������������') then
		sendDialogResponse(id, 1, 0, '')
		return false
	end
end

-----���������� �� �������
function sampev.onShowTextDraw(id, data)
	if data.selectable and data.text == 'selecticon2' and data.position.x == 396.0 and data.position.y == 315.0 then
        for i = 1, random(1, 10) do newTask(sendClickTextdraw, i * 500, id) end
    elseif data.selectable and data.text == 'selecticon3' and data.position.x == 233.0 and data.position.y == 337.0 then
        newTask(sendClickTextdraw, 6000, id)
    end
end

-----��� ������ � ����� ����������� ����
function sampev.onSetInterior(interior)
	if interior == 0 and joinedlog then
		loggedin()
		timeron()
		pobeg()
		joinedlog = false
	end
end

-----���� �� �����
function sampev.onServerMessage(color, text)
	if text:match('^����� ���������� �� Arizona Role Play!$') then
		connected()
	end
	if text:match('^�� ��������� ���������� �������%. �� ��������� �� �������$') then
		generatenick()
	end
	if text:match('^ ������������� %w+_%w+%[%d+%] ������� ������ '..nick..'%[%d+%] � ��� �� %d+ �����%. �������: .+$') then
		adminname, jailtime, reason = text:match('^ ������������� (%w+_%w+)%[%d+%] ������� ������ '..nick..'[%d+$] � ��� �� (%d+) �����. �������: (.+)$')
		adminkpz()
	end
	if text:match('^ ������������� %w+_%w+%[%d+%] ������� ������ '..nick..'%[%d+%] � �������� �� %d+ �����%. �������: .+$') then
		adminname, jailtime, reason = text:match('^ ������������� (%w+_%w+)%[%d+%] ������� ������ '..nick..'[%d+$] � �������� �� (%d+) �����. �������: (.+)$')
		jailed()
	end
	if text:match('^ ������������� %w+_%w+%[%d+%] ������ ������ '..nick..'%[%d+%]%. �������: .+$') then
		adminname, reason = text:match('^ ������������� (%w+_%w+)%[%d+%] ������ ������ '..nick..'%[%d+%]%. �������: (.+)$')
		kicked()
	end
	if text:match('^ ������������� %w+_%w+%[%d+%] ������� ������ '..nick..'%[%d+%]%. �������: .+$') then
		adminname, reason = text:match('^ ������������� (%w+_%w+)%[%d+%] ������� ������ '..nick..'%[%d+%]%. �������: (.+)$')
		ipban()
	end
	if text:match('^������������� %w+_%w+%[%d+%] ������� ������ '..nick..'%[%d+%] �� %d+ ����%. �������: .+$') then
		adminname, reason = text:match('^������������� (%w+_%w+)%[%d+%] ������� ������ '..nick..'%[%d+%] �� %d+ ����%. �������: (.+)$')
		noipban()
	end
	if text:match('^�� ��������� ���� �������%.$') then
		reconnect()
	end
	if text:match('^������������� %w+_%w+%[%d+%] ��� ���������$') then
		adminname = text:match('^������������� (%w+_%w+)%[%d+%] ��� ���������$')
		admspawn()
	end
	if text:match('^������������� �������������� ��� �� �������������%.$') then
		admsobes()
	end
	if text:match('^�� ���� ��������������� ���������������  %w+_%w+$') then
		adminname = text:match('^�� ���� ��������������� ���������������  (%w+_%w+)$')
		admtp()
	end
	if text:match('^������������� %w+_%w+%[ID: %d+%] �������������� ��� �� ����������: .+,.+,.+$') then
		adminname = text:match('^������������� (%w+_%w+)%[ID: %d+%] �������������� ��� �� ����������: .+,.+,.+$')
		admcoordtp()
	end
end

function onPrintLog(text)
	if text:match('^%[NET%] Disconnected%.$') then
		resetall()
	end
	if text:match('^%[NET%] Bad nickname$') then
		generatenick()
	end
	if text:match('^%[NET%] You are banned$') then
		count = count + 1
		if count == 20 then
			if cfg.telegram.ipbanuveda == 1 then
				sendtg('[Farmila Ultimate]\n\n���� ������������\n���: '..nick..'\n������: '..servername)
			end
		end
	end
end

-----�����
function admsobes()
	if cfg.telegram.admsobesuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n��������������� �� �������������\n���: '..nick..'\n������: '..servername)
	end
end

function admspawn()
	if cfg.telegram.admspawnuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n��������� �����\n���: '..nick..'\n������: '..servername..'\n��� ������: '..adminname)
	end
end

function admtp()
	if cfg.telegram.admtpuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n�������������� �����\n���: '..nick..'\n������: '..servername..'\n��� ������: '..adminname)
	end
end

function admcoordtp()
	if cfg.telegram.admcoordtpuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n�������������� ����� �� ������\n���: '..nick..'\n������: '..servername..'\n��� ������: '..adminname)
	end
end

function adminkpz()
	generatenick()
	if cfg.telegram.adminkpzuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n�������� � ���\n���: '..nick..'\n������: '..servername..'\n\n��� ������: '..adminname..'\n�������: '..reason..'\n\n������� ������: '..chas..' �. '..minut..' ���. '..sekund..' ���. ')
	end
	timer = true
end

function kicked()
	if cfg.telegram.kickuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n�������\n���: '..nick..'\n������: '..servername..'\n\n��� ������: '..adminname..'\n�������: '..reason..'')
	end
end

function jailed()
	if cfg.settings.demorganlimit > jailtime then
		if cfg.telegram.jailuveda == 1 then
			sendtg('[Farmila Ultimate]\n\n�������� � ��������\n���: '..nick..'\n������: '..servername..'\n\n��� ������: '..adminname..'\n�������: '..reason..'\n�����: '..jailtime..'\n\n������� ������: '..chas..' �. '..minut..' ���. '..sekund..' ���. ')
		end
		timer = true
		generatenick()
	else
		if cfg.telegram.jailuveda == 1 then
			sendtg('[Farmila Ultimate]\n\n�������� � ��������\n���: '..nick..'\n������: '..servername..'\n\n��� ������: '..adminname..'\n�������: '..reason..'\n�����: '..jailtime..'')
		end
		wait(jailtime * 60000 + 30000)
		reconnect()
	end
end

function registered()
	if cfg.telegram.reguveda == 1 then
		sendtg('[Farmila Ultimate]\n\n������������������\n���: '..nick..'\n������: '..servername)
		timerstop = false
	end
end

function loggedin()
	if cfg.telegram.loginuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n��������������\n���: '..nick..'\n������: '..servername)
	end
end

function connected()
	if cfg.telegram.joinuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n������������\n���: '..nick..'\n������: '..servername)
	end
end

function noipban()
	generatenick()
	if cfg.telegram.noipbanuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n��������\n���: '..nick..'\n������: '..servername..'\n\n��� ������: '..adminname..'\n�������: '..reason..'\n\n������� ������: '..chas..' �. '..minut..' ���. '..sekund..' ���. ')
	end
	timerstop = true
end

function ipban()
	generatenick()
	if cfg.telegram.ipbanuveda == 1 then
		sendtg('[Farmila Ultimate]\n\n�������� �� IP \n���: '..nick..'\n������: '..servername..'\n\n��� ������: '..adminname..'\n�������: '..reason..'\n\n������� ������: '..chas..' �. '..minut..' ���. '..sekund..' ���. ')
	end
	timerstop = true
end

function timeron()
	timer = false
	newTask(function()
		while true do wait(0)
			if not timer then
				wait(1000)
				sekund = sekund + 1
				if sekund == 60 then
					minut = minut + 1
					sekund = sekund - 60
				elseif minut == 60 then
					chas = chas + 1
					minut = minut - 60
				end
			else
				secund = 0
				minut = 0
				chas = 0
				break
			end
		end
	end)
end
-----�������
function onRunCommand(cmd)
	if cmd:find'!test' then
		sendtg('[Farmila Ultimate]\n\n���� ����������� Telegram\n��� ������: '..servername)
	end
	if cmd:find('!play') or cmd:find('!stop') then
		runRoute(cmd)
		return false
	end
end

-----��� ��� ����� ������� ����� ����������� ��� ������ ���� ����������� �����
function onReceiveRPC(id, bs)
	if id == 129 and joinedreg then
		registered()
		timeron()
		pobeg()
		joinedreg = false
	end
end

----������
function onProxyError()
	print('������ ����������� � ������.')
end
function onProxyConnect()
	print('������ �������, �����������)')
end

function onRequestConnect()
	if cfg.proxy.zahodsproxy == 1 then
		if not isProxyConnected() then
			return false
		end
	end
end

-----�Ѩ ��� ����� ����������� �� ��������� ��������
function routefinished()
	sendInput('/beg')
	print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m������� ����� ������������ ������.\x1b[0;37m')
end

-----ROUTE PLAYER
local bitstream = {
	onfoot = bitStream.new(),
	incar = bitStream.new(),
	aim = bitStream.new()
}

function sampev.onSendVehicleSync(data)
	if rep then
		return false
	end
end

function sampev.onSendPlayerSync(data)
	if rep then
		return false
	end
end

function sampev.onVehicleStreamIn(vehid, data)
	veh[vehid] = data.health
end

newTask(function()
	while true do
		check_update()
		wait(50)
	end
end)

function check_update()
	if rep then
		local ok = fillBitStream(getVehicle() ~= 0 and 2 or 1)
		if ok then
			if getVehicle() ~= 0 then bitstream.incar:sendPacket() else bitstream.onfoot:sendPacket() end
			setPosition(packet[counter].x, packet[counter].y, packet[counter].z)
			counter = counter + 1
			if counter%20 == 0 then
				local aok = fillBitStream(3)
				if aok then
					bitstream.aim:sendPacket()
				else
					err()
				end
			end
		else
			err()
		end

		bitstream.onfoot:reset()
		bitstream.incar:reset()
		bitstream.aim:reset()

		if counter == #packet then
			if not loop then
				print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m������� ��������.\x1b[0;37m')
				routefinished()
				rep = false
				setPosition(packet[counter].x, packet[counter].y, packet[counter].z)
				setQuaternion(packet[counter].qw, packet[counter].qx, packet[counter].qy, packet[counter].qz)
				packet = {}
			end
			counter = 1
		end
	end
end

function err()
	rep = false
	packet = {}
	counter = 1
	print('an error has occured while writing data')
end

function fillBitStream(mode)
	if mode == 2 then
		local bs = bitstream.incar
		bs:writeUInt8(packet[counter].packetId)
		bs:writeUInt16(getVehicle())
		bs:writeUInt16(packet[counter].lr)
		bs:writeUInt16(packet[counter].ud)
		bs:writeUInt16(packet[counter].keys)
		bs:writeFloat(packet[counter].qw)
		bs:writeFloat(packet[counter].qx)
		bs:writeFloat(packet[counter].qy)
		bs:writeFloat(packet[counter].qz)
		bs:writeFloat(packet[counter].x)
		bs:writeFloat(packet[counter].y)
		bs:writeFloat(packet[counter].z)
		bs:writeFloat(packet[counter].sx)
		bs:writeFloat(packet[counter].sy)
		bs:writeFloat(packet[counter].sz)
		bs:writeFloat(veh[getVehicle()])
		bs:writeUInt8(getHealth())
		bs:writeUInt8(getArmour())
		bs:writeUInt8(0)
		bs:writeUInt8(0)
		bs:writeUInt8(packet[counter].gear)
		bs:writeUInt16(0)
		bs:writeFloat(0)
		bs:writeFloat(0)

	elseif mode == 1 then
		local bs = bitstream.onfoot
		bs:writeUInt8(packet[counter].packetId)
		bs:writeUInt16(packet[counter].lr)
		bs:writeUInt16(packet[counter].ud)
		bs:writeUInt16(packet[counter].keys)
		bs:writeFloat(packet[counter].x)
		bs:writeFloat(packet[counter].y)
		bs:writeFloat(packet[counter].z)
		bs:writeFloat(packet[counter].qw)
		bs:writeFloat(packet[counter].qx)
		bs:writeFloat(packet[counter].qy)
		bs:writeFloat(packet[counter].qz)
		bs:writeUInt8(getHealth())
		bs:writeUInt8(getArmour())
		bs:writeUInt8(0)
		bs:writeUInt8(packet[counter].sa)
		bs:writeFloat(packet[counter].sx)
		bs:writeFloat(packet[counter].sy)
		bs:writeFloat(packet[counter].sz)
		bs:writeFloat(0)
		bs:writeFloat(0)
		bs:writeFloat(0)
		bs:writeUInt16(0)
		bs:writeUInt16(packet[counter].anim)
		bs:writeUInt16(packet[counter].flags)

	elseif mode == 3 then
		local bs = bitstream.aim
		bs:writeUInt8(203)
		bs:writeUInt8(packet[counter].mode)
		bs:writeFloat(packet[counter].cx)
		bs:writeFloat(packet[counter].cy)
		bs:writeFloat(packet[counter].cz)
		bs:writeFloat(packet[counter].px)
		bs:writeFloat(packet[counter].py)
		bs:writeFloat(packet[counter].pz)
		bs:writeFloat(packet[counter].az)
		bs:writeUInt8(packet[counter].zoom)
		bs:writeUInt8(packet[counter].wstate)
		bs:writeUInt8(packet[counter].unk)

	else return false end
	return true
end

function runRoute(act)
	if act:find('!play .*') then
		packet = loadIni(getPath()..'routes\\'..act:match('!play (.*)')..'.rt')
		if packet then
			print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m��������� �������: '..act:match('!play (.*)')..'\x1b[0;37m')
			counter = 1
			rep = true
			loop = false
		else
			print('route doesnt exist')
		end
	elseif act:find('!stop') then
		if counter >= 1 then
			rep = false
			print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36m������������ �� ������ �����: '..counter..'\x1b[0;37m')
			counter = 0
		else
			print('not playing any route')
		end
	end
end

function loadIni(fileName)
	local file = io.open(fileName, 'r')
	if file then
		local data = {}
		local section
		for line in file:lines() do
			local tempSection = line:match('^%[([^%[%]]+)%]$')
			if tempSection then
				section = tonumber(tempSection) and tonumber(tempSection) or tempSection
				data[section] = data[section] or {}
			end
			local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$')
			if param and value ~= nil then
				if tonumber(value) then
					value = tonumber(value)
				elseif value == 'true' then
					value = true
				elseif value == 'false' then
					value = false
				end
				if tonumber(param) then
					param = tonumber(param)
				end
				data[section][param] = value
			end
		end
		file:close()
		return data
	end
	return false
end