--[[
	数据解析器
]]

local ChatDataParser = class("ChatDataParser")
local ChatServiceTool = import(".ChatServiceTool")
local BitTools
if Util:checkUpdatePackage() then
	BitTools = import(".bytearray.init")
end
ChatDataParser.TAG = "ChatDataParser"

local OPTIONAL_VAL = 1    --数值(optional int32,string...)
local OPTIONAL_MSG = 2    --结构(optional message)
local REPEATED_VAL = 3    --数值数组(repeated int32,string...)
local REPEATED_MSG = 4    --结构数组(repeated message)

function ChatDataParser:ctor( ... )
	self.INT_SIZE = 4
	self.tools = ChatServiceTool.new()
end

-- 目前来看就是四个字节
function ChatDataParser:initHeader( ... )
	local head = {}
	head.boxSize = { value = 0, length = self.INT_SIZE}
	return head
end

function ChatDataParser:getHeaderSize(header)
	local headerSize = 0
	for _,v in pairs(header) do
		headerSize = headerSize + v.length
	end
	return headerSize
end

function ChatDataParser:getHeaderPropertyList( ... )
	return {"boxSize"}
end

function ChatDataParser:getBoxSize(header, bodyBuffer)
	local boxSize = self:getHeaderSize(header)
	if bodyBuffer then
		boxSize = boxSize + string.len(bodyBuffer)
	end
	return boxSize
end

--[[
	bodyArrayBuffer 二进制数据
	1.增加header 里面包含长度信息
	-- return 封包后的二进制数据流字符串
]]
function ChatDataParser:packBox(bodyArrayBuffer)
	local header = self:initHeader()
	local boxSize = self:getBoxSize(header, bodyArrayBuffer)
	print("【ChatDataParser】 packBox ===== boxSize ===== " .. boxSize)
	header.boxSize.value = boxSize

	local headerPropertyList = self:getHeaderPropertyList()
	-- 需要用大端模式塞头的长度
	local boxDataView = BitTools.tool.ByteArray.new(BitTools.tool.ByteArray.ENDIAN_BIG)
	local pos = 0
	local propLen = #headerPropertyList
	for i = 1, propLen do
		local propObj = header[headerPropertyList[i]]
		pos = pos + propObj.length
		if propObj.length == self.INT_SIZE then
			logi(" ===== 头的值是多少 ===== " .. propObj.value)
			--先把长度变成4个字节的byte
			boxDataView:writeInt(propObj.value)
		end
		boxDataView:setPos(pos)
	end
	pos = pos + 1
	boxDataView:setPos(pos)
	boxDataView:writeStringBytes(bodyArrayBuffer)
	logi(" ===== 所有的包体长度 == " .. boxDataView:getLen())
	return boxDataView:getPack(1, boxDataView:getLen())
end

--[[
	bodyArrayBuffer 二进制数据
	1.从二进制数据中读取body数据包长度
	-- return 封包后的二进制流字符串
]]
function ChatDataParser:unpackBox(boxArrayBuffer)
	--解头部包体获取body长度
	local header = self:initHeader();
	local headerSize = self:getHeaderSize(header)
	local bodyDataView = BitTools.tool.ByteArray.new()
	local headerPropertyList = self.getHeaderPropertyList()
	local propLen = #headerPropertyList
	local pos = 0
	for i = 1, propLen do
		local propObj = header[headerPropertyList[i]]
		pos = pos + propObj.length
		if propObj.length == self.INT_SIZE then
			propObj.value = self.tools:bufToInt32(boxArrayBuffer[1], boxArrayBuffer[2], boxArrayBuffer[3], boxArrayBuffer[4])
		end
	end
	local bodySize = header.boxSize.value
	-- logi("【ChatDataParser】】 包体的长度 ==== " .. bodySize)
	local pos = headerSize + 1
	for i = pos, #boxArrayBuffer do
		bodyDataView:setPos(pos)
		bodyDataView:writeUByte(boxArrayBuffer[i])
		pos = pos + 1
	end
	-- logi("【ChatDataParser】 unpackBox ====== 头部长度 = " .. headerSize .. "   body长度 = " .. bodySize)
	local ret = {}
	ret.body = bodyDataView:getPack(headerSize + 1, bodySize)
	return ret
end

function ChatDataParser:packMsg(pbName, bodyBuff)
	--这里是业务逻辑
	local model = pb.new(pbName)
	if not model then
		loge(string.format("【ChatDataParser】packMesg error , pbName = %s not find!", pbName))
		return
	end
	logi("【ChatDataParser】 packMsg 封包为二进制数据")
	--包装头部信息
	local IMMsgBoxModel = pb.new("IMMessage")
	IMMsgBoxModel.message_head.cid = tonumber(Cache.user.uin) or 0
	IMMsgBoxModel.message_head.message_body_name = pbName or ""
	IMMsgBoxModel.message_head.app_flag = 1
	IMMsgBoxModel.message_body = pb.serializeToString(bodyBuff)
	-- print("【ChatDataParser】 packMsg protoBufStr \n" .. pb.tostring(IMMsgBoxModel))
	return self:packBox(pb.serializeToString(IMMsgBoxModel))
end

function ChatDataParser:unpackMsg(data)
	--解出包体
	local boxData = self:unpackBox(data)
	if not boxData.body then
		print("【ChatDataParser】 unpackMsg error, body is fail!")
		return
	end
	--先去解head
	local headModel = pb.new("IMMessage")
	pb.parseFromString(headModel, boxData.body)
	if not headModel then
		loge("【ChatDataParser】 unpackMsg error, paser head fail!")
		return nil
	end
	if not headModel.message_head["message_body_name"] then
		loge("【ChatDataParser】 unpackMsg error, paser message_head_name is nil!")
		return nil
	end
	local messageBodyName = headModel.message_head.message_body_name
	if messageBodyName == "" then
		loge("【ChatDataParser】 unpackMsg error, paser message_body_name is nil!")
		return nil
	end
	local bodyModel = pb.new(messageBodyName)
	print("【ChatDataParser】 unpackMsg response pname: " .. messageBodyName)
	pb.parseFromString(bodyModel, headModel.message_body)
	local ret = {}
	ret.name = messageBodyName
	ret.model = bodyModel or nil
	
	return ret
end

--PB包装
function ChatDataParser:packPB(_m,_t)
	for k, v in pairs(_t) do
		local data_type = self:getDataType(v)
		if data_type == OPTIONAL_MSG then
			self:packPB(_m[k], v)
		elseif data_type == REPEATED_MSG then
			for key, value in pairs(v) do
				self:packPB(_m[k]:add(), value)
			end
		elseif data_type == OPTIONAL_VAL then
			_m[k] = v
		elseif data_type == REPEATED_VAL then
			for key, value in pairs(v) do
				_m[k]:add(value)
			end
		end
	end
end

--获取数据类型
function ChatDataParser:getDataType(m)
    if type(m) == "table" then
        if m[1] ~= nil then
            if type(m[1]) == "table" then
                return REPEATED_MSG
            else
                return REPEATED_VAL
            end
        else
            return OPTIONAL_MSG
        end
    else
        return OPTIONAL_VAL
    end
end

return ChatDataParser