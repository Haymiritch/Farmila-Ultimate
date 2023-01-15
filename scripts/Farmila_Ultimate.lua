--Кодеры: Haymiritch, Chocomami1488 (Ведро говна)
--Выкладывать каку только под нашим именем(чтоби знали кому на овощебазе дали notepad++)

--Спасибо Shamanije за Route Player
--Спасибо Dimiano за SlapFix и Animfix

os.execute('color 0')

require('addon')
local effil = require 'effil'
local sampev = require('samp.events')
local vector3d = require('libs.vector3d')
local ss = require('samp-store')
local requests = require('requests')
local inicfg = require 'inicfg'
local cfg = inicfg.load(nil, 'Farmila_Settings')
local ffi = require('ffi')

local servername = ('Сервер неизвестен')
local promo = ('mason')
local referal = ('Farmila_Ultimate')

local rep = false
local loop = false
local packet, veh = {}, {}
local counter = 0

local count = 0
local sekund = 0
local minut = 0
local chas = 0
local promoactivated = false
local timerstop = false
local napisal = false

ss.InitApiKey(cfg.sampstore.tokenss)

-- НЕ ТРОГАЙТЕ ТО ЧТО ВВЕРХУ(ну и снизу тоже не надо) ИНАЧЕ СКРИПТ ТРАХ БАБАХ БУДЕТ
----------------------------------------------------------------------------
local link = ('https://api.telegram.org/bot' .. cfg.telegram.tokenbot .. '/sendMessage?chat_id=' .. cfg.telegram.chatid .. '&text=')
-----ЕБАТОРИЯ С ТГ УВЕДАМИ/ЗАПРОСАМИ/САМП СТОРОМ
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

-----СЕЙВ АККОВ В ФАЙЛ
function acclog(text)
	local f = io.open(getPath()..'\\scripts\\Farmila_Accounts.txt', 'a')
	f:write(text)
	f:close()
end

-----ТЕКСТ ДЛЯ СЕЙВА АККОВ
function logaccount()
	-- Nick_Name | password | level | ip | money | servername | regip |
	local response = requests.get('https://api.ipify.org')
	if response.status_code == 200 then
		local regip = response.text	
		acclog(savenick..' | '..cfg.settings.pass..' | '..lvl..' | '..serverip..' | '..money..' | '..servername..' | '..regip..'\n')
		print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mАккаунт успешно сохранен с рег айпи.\x1b[0;37m')
	else
		acclog(savenick..' | '..cfg.settings.pass..' | '..lvl..' | '..serverip..' | '..money..' | '..servername..'\n')
		print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mАккаунт успешно сохранен без рег айпи.\x1b[0;37m')
	end
end

-----ХУЕТА ДЛЯ САМП СТОРА
function sampstoreupload()
	newTask(function()
		sendInput('/mn')
		repeat wait(0) until promoactivated
		if cfg.sampstore.vilagivat == 1 then
			local response = requests.get('https://api.ipify.org')
			if response.status_code == 200 then
				local regip = response.text
				local upload_res = ss.UploadAccount(serverip, cfg.sampstore.price, namen, cfg.settings.pass, cfg.sampstore.infopokupo, cfg.sampstore.infoakk, regip)
				if upload_res then
					print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mАккаунт успешно выложен на самп-стор.\x1b[0;37m')
					if cfg.telegram.ssakkuveda == 1 then
						sendtg('[Farmila Ultimate]\n\nАккаунт успешно выложен на сампстор!\nНик: '..nick..'\nСервер: '..servername..'\nЛевел: '..lvl..'\nСервер: '..servername..'\nЦена за аккаунт: '..cfg.sampstore.price..'\nЦену вы должны были указать в конфиге.')
					end
					generatenick()
				end
			else
				local upload_res = ss.UploadAccount(serverip, cfg.sampstore.price, namen, cfg.settings.pass, cfg.sampstore.infopokupo, cfg.sampstore.infoakk, _)
				if upload_res then
					print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mАккаунт успешно выложен на самп-стор без рег айпи.\x1b[0;37m')
					if cfg.telegram.ssakkuveda == 1 then
						sendtg('[Farmila Ultimate]\n\nАккаунт успешно выложен на сампстор!\nНик: '..nick..'\nСервер: '..servername..'\nЛевел: '..lvl..'\nСервер: '..servername..'\nЦена за аккаунт: '..cfg.sampstore.price..'\nЦену вы должны были указать в конфиге.')
					end
					generatenick()
				end
			end
		end
	end)
end

-----ПРИ ЗАГРУЗКЕ СКРИПТА
function onLoad()
	newTask(function()
		while true do
			wait(0)
			lvl = getScore()
			nick = getNick()
			money = getMoney()
			setWindowTitle('[Farmila Ultimate] '..nick..' | '..servername..' | Level: '..lvl..' | Money: '..money)
			if lvl >= 7 then
				exit()
			elseif not napisal and lvl == 6 then
				sampstoreupload()
				napisal = true
			end
		end
	end)
	if cfg.settings.avtosmenanicka == 1 then
		generatenick()
	end
	if cfg.proxy.zahodsproxy == 1 then
		proxyConnect(cfg.proxy.proxyip, cfg.proxy.proxyuser, cfg.proxy.proxypass)
	end
	print('\x1b[0;36m------------------------------------------------------------------------\x1b[37m')
	print('')
	print('			\x1b[0;33mFARMILA ULTIMATE V1\x1b[37m  - \x1b[0;32mЗАГРУЖЕН!\x1b[37m           ')
	print('           \x1b[0;33m                  REBORN    \x1b[37m                                         ')
	print('')
	print('\x1b[0;36m------------------------------------------------------------------------\x1b[37m')
end

-----КЛЮЧ ГЕНА ХУЙНИ
function random(min, max)
	math.randomseed(os.time()^3.14)
	return math.random(min, max)
end

-----ГЕНЕРАЦИЯ РАНДОМ НИКА
function generatenick()
	local names_and_surnames = {}
	for line in io.lines(getPath('config\\randomnick.txt')) do
		names_and_surnames[#names_and_surnames + 1] = line
	end
	local name = names_and_surnames[random(1, 5162)]
    local surname = names_and_surnames[random(5163, 81533)]
    local nick = ('%s_%s'):format(name, surname)
    setNick(nick)
	print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mИзменили ник на: \x1b[0;32m'..getNick()..'\x1b[37m.')
	recreset(1)
end

-----СЪЁБ СО СПАВНА
function pobeg()
	if cfg.settings.ubegatsospawna == 1 then
		newTask(function()
			local x, y = getPosition()
			if x >= 1700 and x <= 1800 and y >= -1950 and y <= -1850 then -- old losantos spawn
				print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mВы на старом спавне ЛС.\x1b[0;37m') 
				local put = random(1,50)
				runRoute('!play lsold'..put)
			elseif x >= 1000 and x <= 1200 and y >= -1900 and y <= -1700 then  -- new losantos spawn
				print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mВы на новом спавне ЛС.\x1b[0;37m') 
				local put = random(1,51)
				runRoute('!play lsnew'..put)
			else
				print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mМы не можем понять где вы, маршрут не запущен.\x1b[0;37m')
			end
		end)
	end
end

-----ПРИ ПОДКЛЮЧЕНИИ
function onConnect()
	serverip = getIP()
	if serverip == '185.169.134.3:7777' then
		servername = ('Phoenix')
		promo = cfg.promo.phoenix
		referal = cfg.referal.referalphoenix
	elseif serverip == '185.169.134.4:7777' then
		servername = ('Tucson')
		promo = cfg.promo.tucson
		referal = cfg.referal.referaltucson
	elseif serverip == '185.169.134.43:7777' then
		servername = ('Scottdale')
		promo = cfg.promo.scottdale
		referal = cfg.referal.referalscottdale
	elseif serverip == '185.169.134.44:7777' then
		servername = ('Chandler')
		promo = cfg.promo.chandler
		referal = cfg.referal.referalchandler
	elseif serverip == '185.169.134.45:7777' then
		servername = ('Brainburg')
		promo = cfg.promo.brainburg
		referal = cfg.referal.referalbrainburg
	elseif serverip == '185.169.134.5:7777' then
		servername = ('Saint-rose')
		promo = cfg.promo.saintrose
		referal = cfg.referal.referalsaintrose
	elseif serverip == '185.169.134.59:7777' then
		servername = ('Mesa')
		promo = cfg.promo.mesa
		referal = cfg.referal.referalmesa
	elseif serverip == '185.169.134.61:7777' then
		servername = ('Red-rock')
		promo = cfg.promo.redrock
		referal = cfg.referal.referalredrock
	elseif serverip == '185.169.134.107:7777' then
		servername = ('Yuma')
		promo = cfg.promo.yuma
		referal = cfg.referal.referalyuma
	elseif serverip == '185.169.134.109:7777' then
		servername = ('Surprise')
		promo = cfg.promo.surprise
		referal = cfg.referal.referalsurprise
	elseif serverip == '185.169.134.166:7777' then
		servername = ('Prescott')
		promo = cfg.promo.prescott
		referal = cfg.referal.referalprescott
	elseif serverip == '185.169.134.171:7777' then
		servername = ('Glendale')
		promo = cfg.promo.glendale
		referal = cfg.referal.referalglendale
	elseif serverip == '185.169.134.172:7777' then
		servername = ('Kingman')
		promo = cfg.promo.kingman
		referal = cfg.referal.referalkingman
	elseif serverip == '185.169.134.173:7777' then
		servername = ('Winslow')
		promo = cfg.promo.winslow
		referal = cfg.referal.referalwinslow
	elseif serverip == '185.169.134.174:7777' then
		servername = ('Payson')
		promo = cfg.promo.payson
		referal = cfg.referal.referalpayson
	elseif serverip == '80.66.82.191:7777' then
		servername = ('Gilbert')
		promo = cfg.promo.gilbert
		referal = cfg.referal.referalgilbert
	elseif serverip == '80.66.82.190:7777' then
		servername = ('Showlow')
		promo = cfg.promo.showlow
		referal = cfg.referal.referalshowlow
	elseif serverip == '80.66.82.188:7777' then
		servername = ('Casa-Grande')
		promo = cfg.promo.casagrande
		referal = cfg.referal.referalcasagrande
	elseif serverip == '80.66.82.168:7777' then
		servername = ('Page')
		promo = cfg.promo.page
		referal = cfg.referal.referalpage
	elseif serverip == '80.66.82.159:7777' then
		servername = ('Sun-City')
		promo = cfg.promo.suncity
		referal = cfg.referal.referalsuncity
	elseif serverip == '80.66.82.200:7777' then
		servername = ('Queen-Creek')
		promo = cfg.promo.queencreek
		referal = cfg.referal.referalqueencreek
	elseif serverip == '80.66.82.144:7777' then
		servername = ('Sedona')
		promo = cfg.promo.sedona
		referal = cfg.referal.referalsedona
	elseif serverip == '80.66.82.132:7777' then
		servername = ('Holiday')
		promo = cfg.promo.holiday
		referal = cfg.referal.referalholiday
	elseif serverip == '80.66.82.128:7777' then
		servername = ('Wednesday')
		promo = cfg.promo.wednesday
		referal = cfg.referal.referalwednesday
	end
end

-----ДИАЛОГИ
function sampev.onShowDialog(id, style, title, btn1, btn2, text)
	if title:find('1/4') then
        sendDialogResponse(id, 1, 0, cfg.settings.pass)
        return false
    end
    if title:find('2/4') then
		sendDialogResponse(id, 1, 0, '')
        return false
    end
	if title:find('3/4') then
		sendDialogResponse(id, 1, 0, '')
        return false
    end
	if title:find('Откуда вы о нас узнали?') then
		sendDialogResponse(id, 1, 1, '')
        return false
	end
	if title:find('Введите ник пригласившего?') then
		sendDialogResponse(id, 1, 0, referal)
		joinedreg = true
		joinedlog = false
        return false
	end
	if title:find('Дополнительная') then
		sendDialogResponse(id, 0, 0, '')
		return false
	end
	if title:find('Авторизация') then
		sendDialogResponse(id, 1, 0, cfg.settings.pass)
		joinedlog = true
		joinedreg = false
		return false
	end
	if title:find('Этот аккаунт заблокирован!') then
		generatenick()
		return false
	end
	if title:find('Игровое меню') and not promoactivated then
		sendDialogResponse(id, 1, 11, '')
		return false
	end
	if text:find('Введите') then
		sendDialogResponse(id, 1, 0, promo)
		return false
	end
	if text:find('Вы действительно хотите использовать промо-код') then
		sendDialogResponse(id, 1, 0, '')
		return false
	end
end

-----ТЕКСТДРАВЫ СО СКИНАМИ
function sampev.onShowTextDraw(id, data)
	if id == 521 then
		randomskin()
	end
end

-----ПРИ СПАВНЕ С РАНЕЕ ЗАРЕГАННОГО АККА
function sampev.onSetInterior(interior)
	if interior == 0 and joinedlog then
		loggedin()
		timeron()
		pobeg()
		joinedlog = false
	end
end

-----ХУКИ НА ТЕКСТ
function sampev.onServerMessage(color, text)
	if text:find('^Добро пожаловать на Arizona Role Play!$') then
		connected()
	end
	if text:find('^ Администратор %w+_%w+%[%d+%] посадил игрока '..nick..'%[%d+%] в деморган на %d+ минут%. Причина: .+$') then
		adminname, jailtime, reason = text:match('^ Администратор (%w+_%w+)%[%d+%] посадил игрока '..nick..'[%d+$] в деморган на (%d+) минут. Причина: (.+)$')
		jailed()
	end
	if text:find('^ Администратор %w+_%w+%[%d+%] кикнул игрока '..nick..'%[%d+%]%. Причина: .+$') then
		adminname, reason = text:match('^ Администратор (%w+_%w+)%[%d+%] кикнул игрока '..nick..'%[%d+%]%. Причина: (.+)$')
		kicked()
	end
	if text:find('^ Администратор %w+_%w+%[%d+%] забанил игрока '..nick..'%[%d+%]%. Причина: .+$') then
		adminname, reason = text:match('^ Администратор (%w+_%w+)%[%d+%] забанил игрока '..nick..'%[%d+%]%. Причина: (.+)$')
		ipban()
	end
	if text:find('^Администратор %w+_%w+%[%d+%] забанил игрока '..nick..'%[%d+%] на %d+ дней%. Причина: .+$') then
		adminname, reason = text:match('^Администратор (%w+_%w+)%[%d+%] забанил игрока '..nick..'%[%d+%] на %d+ дней%. Причина: (.+)$')
		noipban()
	end
	if text:find('^Поздравляю! Вы достигли %d+%-го уровня!$') then
		pdlvl = text:match('^Поздравляю! Вы достигли (%d+)%-го уровня!$')
		lvlup()
	end
	if text:find('^%[Подсказка%] Вы успешно активировали промо%-код и получили %$%d+!$') then
		promoactivated = true
	end
	if text:find('^Вы закончили свое лечение%.$') then
		recreset(1)
	end
	if text:find('^Администратор %w+_%w+%[%d+%] вас заспавнил$') then
		adminname = text:match('^Администратор (%w+_%w+)%[%d+%] вас заспавнил$')
		admspawn()
	end
	if text:find('^Администратор телепортировал вас на собеседование%.$') then
		admsobes()
	end
	if text:find('^Вы были телепортированы администратором  %w+_%w+$') then
		adminname = text:match('^Вы были телепортированы администратором  (%w+_%w+)$')
		admtp()
	end
	if text:find('^Администратор %w+_%w+%[ID: %d+%] телепортировал вас на координаты: .+,.+,.+$') then
		adminname = text:match('^Администратор (%w+_%w+)%[ID: %d+%] телепортировал вас на координаты: .+,.+,.+$')
		admcoordtp()
	end
end

function onPrintLog(text)
	if text:find('^Disconnected%.') then
		recreset()
	end
	if text:find('^The connection was lost%. Reconnecting in %d+ seconds%.') then
		recreset()
	end
	if text:find('^Bad nickname$') then 
		generatenick()
	end
	if text:find('^You are banned$') then
		count = count + 1
		if count == 20 then
			if cfg.telegram.ipbanuveda == 1 then
				sendtg('[Farmila Ultimate]\n\nАйпи заблокирован\nНик: '..nick..'\nСервер: '..servername)
			end
		end
	end
end

-----УВЕДЫ
function admsobes()
	if cfg.telegram.admsobesuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nТелепортировали на собеседование\nНик: '..nick..'\nСервер: '..servername..'\n\nПерезаходим на сервер')
	end
	recreset(1)
end

function admspawn()
	if cfg.telegram.admspawnuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nЗаспавнил админ\nНик: '..nick..'\nСервер: '..servername..'\nНик админа: '..adminname..'\n\nПерезаходим на сервер')
	end
	recreset(1)
end

function admtp()
	if cfg.telegram.admtpuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nТелепортировал админ\nНик: '..nick..'\nСервер: '..servername..'\nНик админа: '..adminname..'\n\nПерезаходим на сервер')
	end
	recreset(1)
end

function admcoordtp()
	if cfg.telegram.admcoordtpuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nТелепортировал админ по кордам\nНик: '..nick..'\nСервер: '..servername..'\nНик админа: '..adminname..'\n\nПерезаходим на сервер')	
	end
	recreset(1)
end

function kicked()
	if cfg.telegram.kickuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nКикнули\nНик: '..nick..'\nСервер: '..servername..'\n\nНик админа: '..adminname..'\nПричина: '..reason..'')
	end
	recreset(1)
end

function jailed()
	timerstop = true
	if cfg.telegram.jailuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nПосадили в деморган\nНик: '..nick..'\nСервер: '..servername..'\n\nНик админа: '..adminname..'\nПричина: '..reason..'\nВремя: '..jailtime..'\n\nАккаунт прожил: '..chas..' ч. '..minut..' мин. '..sekund..' сек. ')
	end
	generatenick()
end

function registered()
	if cfg.telegram.reguveda == 1 then
		sendtg('[Farmila Ultimate]\n\nЗарегистрировались\nНик: '..nick..'\nСервер: '..servername)
	end
end

function loggedin()
	if cfg.telegram.loginuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nАвторизовались\nНик: '..nick..'\nСервер: '..servername)
	end
end

function connected()
	if cfg.telegram.joinuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nПодключились\nНик: '..nick..'\nСервер: '..servername)
	end
end

function noipban()
	generatenick()
	if cfg.telegram.noipbanuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nЗабанили\nНик: '..nick..'\nСервер: '..servername..'\n\nНик админа: '..adminname..'\nПричина: '..reason..'\n\nАккаунт прожил: '..chas..' ч. '..minut..' мин. '..sekund..' сек. ')
	end
	timerstop = true
end

function ipban()
	generatenick()
	if cfg.telegram.ipbanuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nЗабанили по IP \nНик: '..nick..'\nСервер: '..servername..'\n\nНик админа: '..adminname..'\nПричина: '..reason..'\n\nАккаунт прожил: '..chas..' ч. '..minut..' мин. '..sekund..' сек. ')
	end
	timerstop = true
end

function lvlup()
	if cfg.telegram.levelupuveda == 1 then
		sendtg('[Farmila Ultimate]\n\nПовысил уровень \nНик: '..nick..'\nСервер: '..servername..'\nНовый Уровень: '..pdlvl)
	end
end

function timeron()
	timerstop = false
	newTask(function()
		while true do wait(0)
			if not timerstop then
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

-----КОМАНДЫ
function onRunCommand(cmd)
	if cmd:find'!test' then
		sendtg('[Farmila Ultimate]\n\nТест уведомлений Telegram\nВаш сервер: '..servername)
	end
	if cmd:find('!play') or cmd:find('!stop') or cmd:find('!loop') then
		runRoute(cmd)
		return false
	end
end

-----ДЛЯ СБРОСА ВСЕХ ПЕРЕМЕННЫХ ПРИ РЕКОННЕКТЕ
function recreset(recstate)
	if counter > 1 then
		runRoute('!stop')
	end
	promoactivated = false
	napisal = false
	counter = 0
	count = 0
	if recstate == 1 then
		reconnect()
	end
end	
-----РАНДОМ СКИН
function randomskin()
	newTask(function()
		local skin = random(0, 10)
		local endskin = 0
		while endskin ~= skin do
			sendClickTextdraw(520)
			wait(500)
			endskin = endskin + 1
		end
		sendClickTextdraw(521)
	end)
end

-----ХУЙНЯ
function onSendRPC(id, bs)
	if id == 128 then
		return true
	end
end

-----ТУТ ВСЮ ХУЙНЮ КОТОРАЯ БУДЕТ ПРОИСХОДИТЬ ПРИ СПАВНЕ АККА ЗАРЕГАННОГО БОТОМ
function onReceiveRPC(id, bs)
	if id == 129 and joinedreg then
		registered()
		timeron()
		pobeg()
		joinedreg = false
	end
end

----ПРОКСИ
function onProxyError()
	print('Ошибка подключения к прокси.')
end
function onProxyConnect()
	print('Прокси хороший, подключился)')
end
function onRequestConnect()
	if cfg.proxy.zahodsproxy == 1 then
		if not isProxyConnected() then
			return false
		end
	end
end

-----ВСЁ ЧТО БУДЕТ ПРОИСХОДИТЬ ПО ОКОНЧАНИЮ МАРШРУТА
function routefinished()
	sendInput('/beg')
	print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mАккаунт начал стоять зарабатывать деньги.\x1b[0;37m')
end

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
				print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mМаршрут завершен.\x1b[0;37m')
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
			print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mЗапустили маршрут: '..act:match('!play (.*)')..'\x1b[0;37m')
			counter = 1
			rep = true
			loop = false
		else
			print('route doesnt exist')
		end
	elseif act:find('!stop') then
		if counter >= 1 then
			rep = false
			print('[\x1b[0;33mFarmila Ultimate\x1b[37m] \x1b[0;36mОстановились на пакете номер: '..counter..'\x1b[0;37m')
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