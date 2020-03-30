local ZipDownloader = class("ZipDownloader")



ZipDownloader.ready = 1123  --就绪
ZipDownloader.duang = 1124  --下载中
ZipDownloader.status = ZipDownloader.ready
ZipDownloader.queue = {} 	-- 下载队列
ZipDownloader.TAG = "ZipDownloader"

function ZipDownloader:ctor()
	assetsManager = cc.AssetsManager:new("nil","nil","nil")
	assetsManager:retain()
    assetsManager:setDelegate(handler(self,self.onError), cc.ASSETSMANAGER_PROTOCOL_ERROR )
    assetsManager:setDelegate(handler(self,self.onProgress), cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    assetsManager:setDelegate(handler(self,self.onSuccess), cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    assetsManager:setConnectionTimeout(5)
    self.asm = assetsManager
end



--[[
errorcb
successcb
progresscb
zipurl
versionurl
path
]]

function ZipDownloader:addTask(paras)
	table.insert(self.queue,1,paras)
	if self.status == self.ready then self:run() end
end

function ZipDownloader:run()
	if #self.queue == 0 then
		self.status = self.ready
		logd(" ----- ZipDownloader all done ----- ",self.TAG)
		return
	end

	local args = self.queue[#self.queue]

	self.queue[#self.queue] = nil  --删除最后一个元素
	self.asm:setPackageUrl(args.zipurl)
	self.asm:setVersionFileUrl(args.versionurl)
	--这里需要注意，如果直接在热更新目录操作的话，会直接覆盖
	self.asm:setStoragePath(args.path)
	self:cleanDownload()
	logd("---- current-version-code -- "..cc.UserDefault:getInstance():getStringForKey(SKEY.ZIP_CURRENT_VERSION))
	logd("---- downloaded-version-code -- "..cc.UserDefault:getInstance():getStringForKey(SKEY.ZIP_DOWNLOAD_VERSION))
	self.asm:update()
	self.args = args
end


function ZipDownloader:cleanDownload()
	--随机下载的版本号
	cc.UserDefault:getInstance():setStringForKey(SKEY.ZIP_CURRENT_VERSION,math.random().."")
	cc.UserDefault:getInstance():setStringForKey(SKEY.ZIP_DOWNLOAD_VERSION,math.random().."")
	cc.UserDefault:getInstance():flush()
end
function ZipDownloader:onProgress(percent)
	if self.args.progresscb then self.args.progresscb(percent) end
end

function ZipDownloader:onError(errorCode)

	-- if self.args.errorcb then self.args.errorcb(errorCode) end
	-- if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then

 --    elseif errorCode == cc.ASSETSMANAGER_NETWORK then

 --    end

 --    self:run()

    if self.args.errorcb then self.args.errorcb(errorCode) end
	logd("--- ZipDownloader error ---- , what happed ----"..errorCode,self.TAG)
    self:run()
end

function ZipDownloader:onSuccess()
	logd(" ---- ZipDownloader onSuccess --- " , self.TAG)
	if self.args.successcb then self.args.successcb() end
	self:run()
end


ZD = ZipDownloader.new()