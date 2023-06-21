local Time = {}


local function Format(Int: number)
	return string.format("%02i", Int)
end

function Time.convertToHMS(Seconds: number)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60
	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60
	return Format(Hours) .. ":" .. Format(Minutes) .. ":" .. Format(Seconds)
end

function Time:Suffixe(Value: number)
	if Value  < 1000 then
		return Value
	elseif Value >= 1000 then
		local Index = 1
		local Suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc, No", "De", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Oc", "Nd",
			"V", "Uv", "Dv", "Tv", "Qav", "Qiv", "Sxv", "Spv", "Ov", "Nv", "Tg", "Ut", "Dt", "Tt", "Qat", "Qit", "Sxt", "Spt", "Ot", "Nt", "Qd",
			"Uqd", "Dqd", "Tqd", "Qaqd", "Qiqd", "Sxqd", "Spqd", "Oqd", "Nqd", "Qng", "Uqn", "Dqn", "Tqn", "Qaqn", "Qiqn", "Sxqn", "Spqn", "Oqn",
			"Nqn", "Sxg", "Usx", "Dsx", "Tsx", "Qasx", "Qisx", "Sxsx", "Osx", "Nsx", "Spg", "Usp", "Dsp", "Tsp", "Qasp", "Qisp", "Sxsp", "Spsp",
			"Osp", "Nsp", "Og", "Uo", "Do", "To", "Qao", "Qio", "Sxo", "Spo", "Oo", "Nog", "Ng", "Un", "Dn", "Tn", "Qan", "Qin", "Sxn", "On", "Nn",
			"Ce", "Uce", "Dce", "Inf"}	
		while Value >= 1000 and Index <= #Suffixes do
			Value = Value / 1000
			Index += 1
		end	
		local _format = string.format("%.2f", Value)	
		if _format == "1000.00" and Index < #Suffixes then
			_format = "1.00"
			Index += 1
		end
		return _format .. Suffixes[Index]
	end
end

function Time:Timer(Seconds: number)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	if Hours <= 0 then
		return string.format("%02i", Minutes)..":"..string.format("%02i", Seconds)
	elseif Hours > 0 then
		return string.format("%02i", Hours).. ":" ..string.format("%02i", Minutes)..":"..string.format("%02i", Seconds)
	end
end

function Time:Speech(Object: TextLabel, Text: string)
	local function Dialog(SelectedText)
		SelectedText = SelectedText:gsub("<br%s*/>", "\n")
		SelectedText:gsub("<[^<>]->", "")
		Object.Text = Text
		
		local index = 0
		for _, _ in utf8.graphemes(SelectedText)do
			index = index + 1
			Object.MaxVisibleGraphemes = index
			wait(0.02)
		end
	end
	return Dialog(Text)
end

function Time:RichCustomize(Table)
	local Text = tostring(Table[1])
	
	local Color = ""
	local Size = ""
	local Face = ""
	local Weight = ""
	local Transparency = ""	
	local Stroke = ""
	
	local BoldStart, BoldEnd = "", ""
	local ItalicStart, ItalicEnd = "", ""
	local UnderlinedStart, UnderlinedEnd = "", ""
	local StrikethroughStart, StrikethroughEnd = "", ""
	local UppercaseStart, UppercaseEnd = "", ""
	local SmallcapsStart, SmallcapsEnd = "", ""
	
	local Break = ""
	
	if Table.Color then
		Color = [[color="]].. Table.Color.. [[" ]]
	end
	if Table.Size then
		Size = [[size="]].. Table.Size.. [[" ]]
	end
	if Table.Face then
		Face = [[face="]].. Table.Face.. [[" ]]
	end
	if Table.Weight then
		Weight = [[weight="]].. Table.Weight.. [[" ]]
	end
	if Table.Transparency then
		Transparency = [[transparency="]].. Table.Transparency.. [[" ]]
	end
	if Table.Stroke then
		Stroke = [[color="]].. Table.Stroke[1].. [[" ]].. [[joins="]].. Table.Stroke[2].. [[" ]].. [[thickness="]].. Table.Stroke[3].. [[" ]].. [[transparency="]].. Table.Stroke[4].. [[" ]]
	elseif not Table.Stroke then
		Stroke =[[transparency="1" ]]
	end
	
	if Table.Bold then
		BoldStart = [[<b>]]
		BoldEnd = [[</b>]]
	end
	if Table.Italic then
		ItalicStart = [[<i>]]
		ItalicEnd = [[</i>]]
	end
	if Table.Underlined then
		UnderlinedStart = [[<u>]]
		UnderlinedEnd = [[</u>]]
	end
	if Table.Strikethrough then
		StrikethroughStart = [[<s>]]
		StrikethroughEnd = [[</s>]]
	end
	if Table.Uppercase then
		UppercaseStart = [[<uc>]]
		UppercaseEnd = [[</uc>]]
	end
	if Table.Smallcaps then
		SmallcapsStart = [[<sc>]]
		SmallcapsEnd = [[</sc>]]
	end
	
	if Table.Break then
		Break = [[<br />]]
	end
	
	return BoldStart.. ItalicStart.. UnderlinedStart.. StrikethroughStart.. UppercaseStart.. SmallcapsStart.. [[ <font ]].. Color.. Size.. Face.. Weight.. Transparency.. [[>]].. [[<stroke ]].. Stroke.. [[>]].. Break.. Text.. [[</stroke> ]].. [[</font>]].. SmallcapsEnd.. UppercaseEnd.. StrikethroughEnd.. UnderlinedEnd.. ItalicEnd.. BoldEnd
end

return Time