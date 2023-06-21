local module = {}


local base90Chars = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

local function compressBase90(str)
	str = game:GetService('HttpService'):JSONEncode(str)
	local encodedStr = ""
	local index = 1

	while index <= #str do
		local chunk = str:sub(index, index + 2)
		if #chunk < 3 then
			chunk = chunk .. string.rep("\0", 3 - #chunk)
		end
		local byte1, byte2, byte3 = chunk:byte(1, 3)
		local value = (byte1 * 65536) + (byte2 * 256) + byte3
		local char1 = base90Chars:sub(math.floor(value / 810000) + 1, math.floor(value / 810000) + 1)
		local char2 = base90Chars:sub(math.floor((value % 810000) / 900) + 1, math.floor((value % 810000) / 900) + 1)
		local char3 = base90Chars:sub((value % 900) + 1, (value % 900) + 1)
		encodedStr = encodedStr .. char1 .. char2 .. char3
		index = index + 3
	end

	return encodedStr
end


local function decompressBase90(encodedStr)
	-- Validate input string length
	if #encodedStr % 3 ~= 0 then
		error("Invalid input length")
	end

	local decodedStr = ""
	local index = 1

	while index <= #encodedStr do
		-- Validate input characters
		local char1 = base90Chars:find(encodedStr:sub(index, index))
		local char2 = base90Chars:find(encodedStr:sub(index + 1, index + 1))
		local char3 = base90Chars:find(encodedStr:sub(index + 2, index + 2))
		if not char1 or not char2 or not char3 then
			error("Invalid input characters")
		end

		local value = (char1 - 1) * 810000 + (char2 - 1) * 900 + (char3 - 1)
		local byte1 = math.floor(value / 65536)
		local byte2 = math.floor((value % 65536) / 256)
		local byte3 = value % 256

		-- Handle null padding at end of input string
		if byte2 == 0 then
			decodedStr = decodedStr .. string.char(byte1)
		else
			decodedStr = decodedStr .. string.char(byte1, byte2)
		end
		if byte3 ~= 0 then
			decodedStr = decodedStr .. string.char(byte3)
		end

		index = index + 3
	end

	return decodedStr
end
local function getNumberSize(num)
	local absNum = math.abs(num)
	return math.floor(math.log10(absNum)) + 1 + (num < 0 and 1 or 0)
end

local function getSizeInBytes(val)
	if type(val) == "string" then
		return string.len(val)
	elseif type(val) == "number" then
		local packedVal = string.pack("n", val)
		return string.len(packedVal)
	else
		error("Unsupported type: " .. type(val))
	end
end



function module.compress(str)
	local compressedStr = ""
	local lastChar = str:sub(1,1)
	local count = 1

	for i = 2, #str do
		local currentChar = str:sub(i, i)
		if currentChar == lastChar then
			count = count + 1
		else
			compressedStr = compressedStr .. lastChar .. count
			lastChar = currentChar
			count = 1
		end
	end

	compressedStr = compressedStr .. lastChar .. count

	return compressedStr
end

function module.decompress(compressedStr)
	local decompressedStr = ""
	local index = 1

	while index <= #compressedStr do
		local currentChar = compressedStr:sub(index, index)
		local count = tonumber(compressedStr:sub(index + 1, index + 1))

		if count then
			decompressedStr = decompressedStr .. string.rep(currentChar, count)
			index = index + 2
		else
			decompressedStr = decompressedStr .. currentChar
			index = index + 1
		end
	end

	return decompressedStr
end



local function huffman_encoding(str: string)

	local freq = {}
	for i = 1, #str do
		local char = string.sub(str, i, i)
		freq[char] = (freq[char] or 0) + 1
	end


	local queue = {}
	for char, count in pairs(freq) do
		table.insert(queue, {char = char, count = count})
	end
	table.sort(queue, function(a, b) return a.count < b.count end)

	while #queue > 1 do
		local node1 = table.remove(queue, 1)
		local node2 = table.remove(queue, 1)
		local combined_node = {left = node1, right = node2, count = node1.count + node2.count}
		table.insert(queue, combined_node)
		table.sort(queue, function(a, b) return a.count < b.count end)
	end


	local codes = {}
	local function traverse(node, code)
		if node.char then
			codes[node.char] = code
		else
			traverse(node.left, code .. "0")
			traverse(node.right, code .. "1")
		end
	end
	traverse(queue[1], "")


	local encoded_str = ""
	for i = 1, #str do
		local char = string.sub(str, i, i)
		encoded_str = encoded_str .. codes[char]
	end


	return encoded_str, codes
end

local function huffman_decoding(encoded_str: string, codes: {[string]: number})
	local decoded_str = ""
	local code_so_far = ""
	for i = 1, #encoded_str do
		code_so_far = code_so_far .. string.sub(encoded_str, i, i)
		for char, code in pairs(codes) do
			if code == code_so_far then
				decoded_str = decoded_str .. char
				code_so_far = ""
				break
			end
		end
	end
	return decoded_str
end

local function get_string_length_in_bytes(str)
	local len = string.len(str)
	local byte_len = 0
	for i = 1, len do
		local byte_value = string.byte(str, i)
		if byte_value <= 127 then
			byte_len = byte_len + 1
		elseif byte_value >= 194 and byte_value <= 223 then
			byte_len = byte_len + 2
		elseif byte_value >= 224 and byte_value <= 239 then
			byte_len = byte_len + 3
		elseif byte_value >= 240 and byte_value <= 244 then
			byte_len = byte_len + 4
		end
	end
	return byte_len
end

local function get_table_size_in_bytes(tab)
	local serialized_tab = game:GetService("HttpService"):JSONEncode(tab)
	local tab_size = 0
	for i = 1, #serialized_tab do
		local hex_string = string.format("%02x", string.byte(serialized_tab, i))
		tab_size = tab_size + string.len(hex_string) / 2
	end
	return tab_size
end

return module
