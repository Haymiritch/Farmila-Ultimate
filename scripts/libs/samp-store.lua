local req = require("requests")

local module = {}

local api_key = nil

module._VERSION = "1.0.1"
module._NAME = "Account Uploader by ULong"

local print = function(arg) 
	if type(printLog) == "function" then
		return printLog("["..module._NAME.."]: "..arg)
	else 
		return print("["..module._NAME.."]: "..arg)
	end
end

function module.InitApiKey(key)
	api_key = key
	return true
end

function module.UploadAccount(u_server, u_price, u_name, u_password, u_info, u_title, u_regip)
	if api_key ~= nil then
	
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

		local function AnsiToUtf8(s)
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
	
		local res = req.get(
		'https://samp-store.ru/ajax/api.php',
		{
			params = {
				method = "add_account",
				key = api_key,
				server = u_server,
				price = u_price,
				reg = u_regip,
				alogin = u_name,
				password = u_password,
				info = AnsiToUtf8(u_info),
				tittle = AnsiToUtf8(u_title)
			}
		})
		if res.text:find("OK") then
			print("Account added!")
			return true
		elseif res.text:find("API_KEY WRONG") then
			print("Wrong API key!")
			return false
		else 
			print("Error occurred. Please try again")
			return false
		end
	else
		print("API key not specified")
		return false
	end
end

return module