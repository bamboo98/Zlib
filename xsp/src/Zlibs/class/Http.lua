local api = require "Zlibs.class.api"
local Zlog = require "Zlibs.class.Log"
local http = require "Zlibs.socket.http"
local smtp = require "Zlibs.socket.smtp"
local mime = require "Zlibs.socket.mime"
local socket = require "Zlibs.socket.socket"
local ltn12 = require "Zlibs.socket.ltn12"
local string = require "Zlibs.class.string"

local typelist={
	["tif"] = "image/tiff",
	["001"] = "application/x-001",
	["301"] = "application/x-301",
	["323"] = "text/h323",
	["906"] = "application/x-906",
	["907"] = "drawing/907",
	["a11"] = "application/x-a11",
	["acp"] = "audio/x-mei-aac",
	["ai"] = "application/postscript",
	["aif"] = "audio/aiff",
	["aifc"] = "audio/aiff",
	["aiff"] = "audio/aiff",
	["anv"] = "application/x-anv",
	["asa"] = "text/asa",
	["asf"] = "video/x-ms-asf",
	["asp"] = "text/asp",
	["asx"] = "video/x-ms-asf",
	["au"] = "audio/basic",
	["avi"] = "video/avi",
	["awf"] = "application/vndadobeworkflow",
	["biz"] = "text/xml",
	["bmp"] = "application/x-bmp",
	["bot"] = "application/x-bot",
	["c4t"] = "application/x-c4t",
	["c90"] = "application/x-c90",
	["cal"] = "application/x-cals",
	["cat"] = "application/vndms-pkiseccat",
	["cdf"] = "application/x-netcdf",
	["cdr"] = "application/x-cdr",
	["cel"] = "application/x-cel",
	["cer"] = "application/x-x509-ca-cert",
	["cg4"] = "application/x-g4",
	["cgm"] = "application/x-cgm",
	["cit"] = "application/x-cit",
	["class"] = "java/*",
	["cml"] = "text/xml",
	["cmp"] = "application/x-cmp",
	["cmx"] = "application/x-cmx",
	["cot"] = "application/x-cot",
	["crl"] = "application/pkix-crl",
	["crt"] = "application/x-x509-ca-cert",
	["csi"] = "application/x-csi",
	["css"] = "text/css",
	["cut"] = "application/x-cut",
	["dbf"] = "application/x-dbf",
	["dbm"] = "application/x-dbm",
	["dbx"] = "application/x-dbx",
	["dcd"] = "text/xml",
	["dcx"] = "application/x-dcx",
	["der"] = "application/x-x509-ca-cert",
	["dgn"] = "application/x-dgn",
	["dib"] = "application/x-dib",
	["dll"] = "application/x-msdownload",
	["doc"] = "application/msword",
	["dot"] = "application/msword",
	["drw"] = "application/x-drw",
	["dtd"] = "text/xml",
	["dwf"] = "Model/vnddwf",
	["dwf"] = "application/x-dwf",
	["dwg"] = "application/x-dwg",
	["dxb"] = "application/x-dxb",
	["dxf"] = "application/x-dxf",
	["edn"] = "application/vndadobeedn",
	["emf"] = "application/x-emf",
	["eml"] = "message/rfc822",
	["ent"] = "text/xml",
	["epi"] = "application/x-epi",
	["eps"] = "application/x-ps",
	["eps"] = "application/postscript",
	["etd"] = "application/x-ebx",
	["exe"] = "application/x-msdownload",
	["fax"] = "image/fax",
	["fdf"] = "application/vndfdf",
	["fif"] = "application/fractals",
	["fo"] = "text/xml",
	["frm"] = "application/x-frm",
	["g4"] = "application/x-g4",
	["gbr"] = "application/x-gbr",
	["gif"] = "image/gif",
	["gl2"] = "application/x-gl2",
	["gp4"] = "application/x-gp4",
	["hgl"] = "application/x-hgl",
	["hmr"] = "application/x-hmr",
	["hpg"] = "application/x-hpgl",
	["hpl"] = "application/x-hpl",
	["hqx"] = "application/mac-binhex40",
	["hrf"] = "application/x-hrf",
	["hta"] = "application/hta",
	["htc"] = "text/x-component",
	["htm"] = "text/html",
	["html"] = "text/html",
	["htt"] = "text/webviewhtml",
	["htx"] = "text/html",
	["icb"] = "application/x-icb",
	["ico"] = "image/x-icon",
	["ico"] = "application/x-ico",
	["iff"] = "application/x-iff",
	["ig4"] = "application/x-g4",
	["igs"] = "application/x-igs",
	["iii"] = "application/x-iphone",
	["img"] = "application/x-img",
	["ins"] = "application/x-internet-signup",
	["isp"] = "application/x-internet-signup",
	["IVF"] = "video/x-ivf",
	["java"] = "java/*",
	["jfif"] = "image/jpeg",
	["jpe"] = "image/jpeg",
	["jpe"] = "application/x-jpe",
	["jpeg"] = "image/jpeg",
	["jpg"] = "image/jpeg",
	["jpg"] = "application/x-jpg",
	["js"] = "application/x-javascript",
	["jsp"] = "text/html",
	["la1"] = "audio/x-liquid-file",
	["lar"] = "application/x-laplayer-reg",
	["latex"] = "application/x-latex",
	["lavs"] = "audio/x-liquid-secure",
	["lbm"] = "application/x-lbm",
	["lmsff"] = "audio/x-la-lms",
	["ls"] = "application/x-javascript",
	["ltr"] = "application/x-ltr",
	["m1v"] = "video/x-mpeg",
	["m2v"] = "video/x-mpeg",
	["m3u"] = "audio/mpegurl",
	["m4e"] = "video/mpeg4",
	["mac"] = "application/x-mac",
	["man"] = "application/x-troff-man",
	["math"] = "text/xml",
	["mdb"] = "application/msaccess",
	["mdb"] = "application/x-mdb",
	["mfp"] = "application/x-shockwave-flash",
	["mht"] = "message/rfc822",
	["mhtml"] = "message/rfc822",
	["mi"] = "application/x-mi",
	["mid"] = "audio/mid",
	["midi"] = "audio/mid",
	["mil"] = "application/x-mil",
	["mml"] = "text/xml",
	["mnd"] = "audio/x-musicnet-download",
	["mns"] = "audio/x-musicnet-stream",
	["mocha"] = "application/x-javascript",
	["movie"] = "video/x-sgi-movie",
	["mp1"] = "audio/mp1",
	["mp2"] = "audio/mp2",
	["mp2v"] = "video/mpeg",
	["mp3"] = "audio/mp3",
	["mp4"] = "video/mpeg4",
	["mpa"] = "video/x-mpg",
	["mpd"] = "application/vndms-project",
	["mpe"] = "video/x-mpeg",
	["mpeg"] = "video/mpg",
	["mpg"] = "video/mpg",
	["mpga"] = "audio/rn-mpeg",
	["mpp"] = "application/vndms-project",
	["mps"] = "video/x-mpeg",
	["mpt"] = "application/vndms-project",
	["mpv"] = "video/mpg",
	["mpv2"] = "video/mpeg",
	["mpw"] = "application/vndms-project",
	["mpx"] = "application/vndms-project",
	["mtx"] = "text/xml",
	["mxp"] = "application/x-mmxp",
	["net"] = "image/pnetvue",
	["nrf"] = "application/x-nrf",
	["nws"] = "message/rfc822",
	["odc"] = "text/x-ms-odc",
	["out"] = "application/x-out",
	["p10"] = "application/pkcs10",
	["p12"] = "application/x-pkcs12",
	["p7b"] = "application/x-pkcs7-certificates",
	["p7c"] = "application/pkcs7-mime",
	["p7m"] = "application/pkcs7-mime",
	["p7r"] = "application/x-pkcs7-certreqresp",
	["p7s"] = "application/pkcs7-signature",
	["pc5"] = "application/x-pc5",
	["pci"] = "application/x-pci",
	["pcl"] = "application/x-pcl",
	["pcx"] = "application/x-pcx",
	["pdf"] = "application/pdf",
	["pdf"] = "application/pdf",
	["pdx"] = "application/vndadobepdx",
	["pfx"] = "application/x-pkcs12",
	["pgl"] = "application/x-pgl",
	["pic"] = "application/x-pic",
	["pko"] = "application/vndms-pkipko",
	["pl"] = "application/x-perl",
	["plg"] = "text/html",
	["pls"] = "audio/scpls",
	["plt"] = "application/x-plt",
	["png"] = "image/png",
	["png"] = "application/x-png",
	["pot"] = "application/vndms-powerpoint",
	["ppa"] = "application/vndms-powerpoint",
	["ppm"] = "application/x-ppm",
	["pps"] = "application/vndms-powerpoint",
	["ppt"] = "application/vndms-powerpoint",
	["ppt"] = "application/x-ppt",
	["pr"] = "application/x-pr",
	["prf"] = "application/pics-rules",
	["prn"] = "application/x-prn",
	["prt"] = "application/x-prt",
	["ps"] = "application/x-ps",
	["ps"] = "application/postscript",
	["ptn"] = "application/x-ptn",
	["pwz"] = "application/vndms-powerpoint",
	["r3t"] = "text/vndrn-realtext3d",
	["ra"] = "audio/vndrn-realaudio",
	["ram"] = "audio/x-pn-realaudio",
	["ras"] = "application/x-ras",
	["rat"] = "application/rat-file",
	["rdf"] = "text/xml",
	["rec"] = "application/vndrn-recording",
	["red"] = "application/x-red",
	["rgb"] = "application/x-rgb",
	["rjs"] = "application/vndrn-realsystem-rjs",
	["rjt"] = "application/vndrn-realsystem-rjt",
	["rlc"] = "application/x-rlc",
	["rle"] = "application/x-rle",
	["rm"] = "application/vndrn-realmedia",
	["rmf"] = "application/vndadobermf",
	["rmi"] = "audio/mid",
	["rmj"] = "application/vndrn-realsystem-rmj",
	["rmm"] = "audio/x-pn-realaudio",
	["rmp"] = "application/vndrn-rn_music_package",
	["rms"] = "application/vndrn-realmedia-secure",
	["rmvb"] = "application/vndrn-realmedia-vbr",
	["rmx"] = "application/vndrn-realsystem-rmx",
	["rnx"] = "application/vndrn-realplayer",
	["rp"] = "image/vndrn-realpix",
	["rpm"] = "audio/x-pn-realaudio-plugin",
	["rsml"] = "application/vndrn-rsml",
	["rt"] = "text/vndrn-realtext",
	["rtf"] = "application/msword",
	["rtf"] = "application/x-rtf",
	["rv"] = "video/vndrn-realvideo",
	["sam"] = "application/x-sam",
	["sat"] = "application/x-sat",
	["sdp"] = "application/sdp",
	["sdw"] = "application/x-sdw",
	["sit"] = "application/x-stuffit",
	["slb"] = "application/x-slb",
	["sld"] = "application/x-sld",
	["slk"] = "drawing/x-slk",
	["smi"] = "application/smil",
	["smil"] = "application/smil",
	["smk"] = "application/x-smk",
	["snd"] = "audio/basic",
	["sol"] = "text/plain",
	["sor"] = "text/plain",
	["spc"] = "application/x-pkcs7-certificates",
	["spl"] = "application/futuresplash",
	["spp"] = "text/xml",
	["ssm"] = "application/streamingmedia",
	["sst"] = "application/vndms-pkicertstore",
	["stl"] = "application/vndms-pkistl",
	["stm"] = "text/html",
	["sty"] = "application/x-sty",
	["svg"] = "text/xml",
	["swf"] = "application/x-shockwave-flash",
	["tdf"] = "application/x-tdf",
	["tg4"] = "application/x-tg4",
	["tga"] = "application/x-tga",
	["tif"] = "image/tiff",
	["tif"] = "application/x-tif",
	["tiff"] = "image/tiff",
	["tld"] = "text/xml",
	["top"] = "drawing/x-top",
	["torrent"] = "application/x-bittorrent",
	["tsd"] = "text/xml",
	["txt"] = "text/plain",
	["uin"] = "application/x-icq",
	["uls"] = "text/iuls",
	["vcf"] = "text/x-vcard",
	["vda"] = "application/x-vda",
	["vdx"] = "application/vndvisio",
	["vml"] = "text/xml",
	["vpg"] = "application/x-vpeg005",
	["vsd"] = "application/vndvisio",
	["vsd"] = "application/x-vsd",
	["vss"] = "application/vndvisio",
	["vst"] = "application/vndvisio",
	["vst"] = "application/x-vst",
	["vsw"] = "application/vndvisio",
	["vsx"] = "application/vndvisio",
	["vtx"] = "application/vndvisio",
	["vxml"] = "text/xml",
	["wav"] = "audio/wav",
	["wax"] = "audio/x-ms-wax",
	["wb1"] = "application/x-wb1",
	["wb2"] = "application/x-wb2",
	["wb3"] = "application/x-wb3",
	["wbmp"] = "image/vndwapwbmp",
	["wiz"] = "application/msword",
	["wk3"] = "application/x-wk3",
	["wk4"] = "application/x-wk4",
	["wkq"] = "application/x-wkq",
	["wks"] = "application/x-wks",
	["wm"] = "video/x-ms-wm",
	["wma"] = "audio/x-ms-wma",
	["wmd"] = "application/x-ms-wmd",
	["wmf"] = "application/x-wmf",
	["wml"] = "text/vndwapwml",
	["wmv"] = "video/x-ms-wmv",
	["wmx"] = "video/x-ms-wmx",
	["wmz"] = "application/x-ms-wmz",
	["wp6"] = "application/x-wp6",
	["wpd"] = "application/x-wpd",
	["wpg"] = "application/x-wpg",
	["wpl"] = "application/vndms-wpl",
	["wq1"] = "application/x-wq1",
	["wr1"] = "application/x-wr1",
	["wri"] = "application/x-wri",
	["wrk"] = "application/x-wrk",
	["ws"] = "application/x-ws",
	["ws2"] = "application/x-ws",
	["wsc"] = "text/scriptlet",
	["wsdl"] = "text/xml",
	["wvx"] = "video/x-ms-wvx",
	["xdp"] = "application/vndadobexdp",
	["xdr"] = "text/xml",
	["xfd"] = "application/vndadobexfd",
	["xfdf"] = "application/vndadobexfdf",
	["xhtml"] = "text/html",
	["xls"] = "application/vndms-excel",
	["xls"] = "application/x-xls",
	["xlw"] = "application/x-xlw",
	["xml"] = "text/xml",
	["xpl"] = "audio/scpls",
	["xq"] = "text/xml",
	["xql"] = "text/xml",
	["xquery"] = "text/xml",
	["xsd"] = "text/xml",
	["xsl"] = "text/xml",
	["xslt"] = "text/xml",
	["xwd"] = "application/x-xwd",
	["x_b"] = "application/x-x_b",
	["sis"] = "application/vndsymbianinstall",
	["sisx"] = "application/vndsymbianinstall",
	["x_t"] = "application/x-x_t",
	["ipa"] = "application/vndiphone",
	["apk"] = "application/vndandroidpackage-archive",
	["xap"] = "application/x-silverlight-app"
}

local function getJson()
	local lo_json = {}
	local obj = require('Zlibs.tool.JSON')
	lo_json.decode = function(x) return obj:decode(x) end
	lo_json.encode = function(x) return obj:encode(x) end
	lo_json.encode_pretty = function(x) return obj:encode_pretty(x) end;
	local json = lo_json
	return json
end
local JSON = getJson()

local function PostTableByJson(url,tbl)
	local str=JSON.encode(tbl)
	local response_body={}
	local body, code, headers, status = http.request{
		url = url,
		method = "POST",
		headers =
		{
			['Content-Type'] = 'application/json',
			["Content-Length"] = #str,
		},
		source = ltn12.source.string(str),
	  sink = ltn12.sink.table(response_body)
	}
	api.sysLog(str)
	if code==200 then
		return response_body[1]
	else
		Zlog.error("HTTP错误: %s",status)
		return ""
	end
end

local function table_to_urlstr(tbl)
	local result=""
	local first=true
	for k,v in pairs(tbl) do
		k=string.urlencode(tostring(k))
		v=string.urlencode(tostring(v))
		if not first then
			result="&" .. result
		end
		first=false
		result=k .. "=" .. v .. result
	end
	return result
end
--- PostTable POST方式发送table,作为POST的参数发送,仅支持简单的一维table
-- @param url 网址,前面要包含http://
-- @param tbl 发送的table
local function PostTable(url,tbl)
	local str=table_to_urlstr(tbl)
	local response_body={}
	local body, code, headers, status = http.request{
		url = url,
		method = "POST",
		headers =
		{
			['Content-Type'] = 'application/x-www-form-urlencoded',
			["Content-Length"] = #str,
		},
		source = ltn12.source.string(str),
	  sink = ltn12.sink.table(response_body)
	}
	if code==200 then
		return response_body[1]
	else
		Zlog.error("HTTP错误: %s",status)
		return ""
	end
end
--- GetTable get方式发送table,作为GET的参数发送,仅支持简单的一维table
-- @param url 网址,前面要包含http://
-- @param tbl 发送的table
local function GetTable(url,tbl)
	local str=table_to_urlstr(tbl)
	local response_body={}
	local body, code, headers, status = http.request{
		url = url,
		method = "GET",
		headers =
		{
			['Content-Type'] = 'application/x-www-form-urlencoded',
			["Content-Length"] = #str,
		},
		source = ltn12.source.string(str),
	  sink = ltn12.sink.table(response_body)
	}
	if code==200 then
		return response_body[1]
	else
		Zlog.error("HTTP错误: %s",status)
		return ""
	end
end
--- PostString post方式发送字符串,不建议使用
-- @param url 网址,前面要包含http://
-- @param str 发送的字符串
local function PostString(url,str)
	str=str or ""
	local response_body={}
	local body, code, headers, status = http.request{
		url = url,
		method = "POST",
		headers =
		{
			['Content-Type'] = 'application/x-www-form-urlencoded',
			["Content-Length"] = #str,
		},
		source = ltn12.source.string(str),
	  sink = ltn12.sink.table(response_body)
	}
	if code==200 then
		return response_body[1]
	else
		Zlog.error("HTTP错误: %s",status)
		return ""
	end
end
--- GetString get方式发送字符串,通常作为获取网页数据而使用,str留空即可
-- @param url 网址,前面包含http://
-- @param str 附加在get参数中的字符串
local function GetString(url,str)
	str=str or ""
	local response_body={}
	local body, code, headers, status = http.request{
		url = url,
		method = "GET",
		headers =
		{
			['Content-Type'] = 'application/x-www-form-urlencoded',
			["Content-Length"] = #str,
		},
		source = ltn12.source.string(str),
	  sink = ltn12.sink.table(response_body)
	}
	if code==200 then
		return response_body[1]
	else
		Zlog.error("HTTP错误: %s",status)
		return ""
	end
end
--- MailSendString 发送纯文本邮件
-- @param t {from=发送的邮箱地址,server=smtp服务器地址,user=邮箱用户名,password=邮箱密码,to=标题上显示的收件人名,title=标题,body=邮件正文,rcpt=接受的邮件地址,可以为table表示群发}
local function MailSendString(t)
		local source = smtp.message{
			headers = {
			from = t.from,   --标题中的发件人
			to = t.to,   --标题的收件人
			subject = t.title or "Zlibs邮件模块_标题"
		},
		body = t.body or "Zlibs邮件模块_正文"
	  }
	  
	  local r, e = smtp.send{
		server = t.server,			--smtp服务器地址，如smtp.163.com
		user = t.user,				--smtp验证用户名
		password = t.password,			--smtp验证密码
		from = t.from,     -- 发送的Email地址
		rcpt = t.rcpt,      -- 接收的Email地址
		source = source
	}

	if not r then
		Zlog.warn("邮件发送失败,原因: %s",e)
		return false
	else
		return true
	end
end

local function getfiletype(name)
	local n=string.lower(string.match(name,".+%.(%w+)$"))
	if typelist[n] then
		return string.format("%s; name=\"%s\"",typelist[n],name)
	end
	return string.format("%s; name=\"%s\"","application/octet-stream",name)
end
--- MailSendFiles 发送带有文件附件的邮件
-- @param t {from=发送的邮箱地址,server=smtp服务器地址,user=邮箱用户名,password=邮箱密码,to=标题上显示的收件人名,title=标题,string=邮件正文,rcpt=接受的邮件地址,可以为table表示群发,file={文件名=文件路径}}
local function MailSendFiles(t)
	local body={}
	if t.string then table.insert(body,{body=t.string}) end
	for k,v in pairs(t.file) do
		local f=io.open(v,'rb')
		table.insert(body,{
			headers = {
				["content-type"] = getfiletype(v),
				["content-disposition"] = 'attachment; filename='..string.gsub(k, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end).."."..string.lower(string.match(v,".+%.(%w+)$")),
				["content-description"] = string.gsub(k, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end).."."..string.lower(string.match(v,".+%.(%w+)$")),
				["content-transfer-encoding"] = "BASE64"
			  },
			body = ltn12.source.chain(
				ltn12.source.file(f),
				ltn12.filter.chain(
					mime.encode("base64"),
					mime.wrap()
				)
			)
		})
	end

	local source = smtp.message{
		headers = {
			from = t.from,   --标题中的发件人
			to = t.to,   --标题的收件人
			subject = t.title or "Zlibs邮件模块_标题"
		},
		body = body
	}
	
	local r, e = smtp.send{
		server = t.server or "smtp.sina.com",			--smtp服务器地址，如smtp.163.com
		user = t.user or "xxspirit@sina.com",				--smtp验证用户名
		password = t.password or "BAMBOO",			--smtp验证密码
		from = t.from or "<xxspirit@sina.com>",     -- 发送的Email地址
		rcpt = t.rcpt or "<xxspirit@sina.com>",      -- 接收的Email地址
		source = source
	}

	if not r then
		Zlog.warn("邮件发送失败,原因: %s",e)
		return false
	else
		return true
	end

end
--- getip 获取外网IP,默认从ip138.com获取,如果无法访问会返回nil,可以自行添加获取网站
local function getip()
	local iplist = {
		"http://2019.ip138.com/ic.asp",
	}
	local retip = ""
	for _, v in ipairs(iplist) do
		retip = GetString(v,"")
		if retip ~= "" then
			break
		end
	end
	return retip:match("%d+%.%d+%.%d+%.%d+")
end

return{
	Mail={
		string=MailSendString,
		files=MailSendFiles
	},
	Get={
		string=GetString,
		table=GetTable,
		ip=getip
	},
	Post={
		string=PostString,
		table=PostTable,
		tableByJson=PostTableByJson
	}
}