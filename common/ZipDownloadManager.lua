
-- zip下载
-- 纯下载解压

local ZipDownloadManager = class("ZipDownloadManager")
ZipDownloadManager.queue = {} 	-- 下载队列

function ZipDownloadManager:ctor( ... )
	dump("=====>>>>>ZipDownloadManager:ctor")
end

function ZipDownloadManager:startTask(paras)
	local downloader = self:setUpDownloader(paras)
	if not downloader then
		loge("参数错误，下载失败")
		return
	end
	self.queue[downloader.zipurl] = downloader
	downloader.curlDown:downStart()
end

-- 拼装下载参数
-- curlDown
-- path
-- fileName
-- zipurl
-- progresscb
-- successcb

function ZipDownloadManager:setUpDownloader(paras)
	local downloader = {}
	if not paras or not paras.path or not paras.zipurl then return nil end
	
	local fileName = paras.fileName or ""
	local curlDown = cc.CurlDown:new()
	curlDown.bFinish = false
	curlDown:setFileInfo(paras.path, fileName, paras.zipurl)
	curlDown:registerScriptCurlDownHandler(function (state)
		if state == "progress" then
			local percent = curlDown:getFileDownPercent()
			if paras.progresscb then
				paras.progresscb(percent)
			end
			-- 去解压
			if percent == 100 then
				if not curlDown.bFinish and curlDown then
					curlDown.bFinish = curlDown:unCompress(paras.path .. fileName, nil)
					print("--------->>>>>> 解压成功  bFinished = " .. tostring(bFinish))
					if curlDown.bFinish then
	                    self:removeTask(downloader.zipurl)
						if paras.successcb then
							paras.successcb(curlDown:isDownLoadFinish())
						end
					end
				end
			end
		end
	end)
	downloader.curlDown = curlDown
	downloader.zipurl = paras.zipurl
	downloader.fileName = fileName
	downloader.path = paras.path
	downloader.progresscb = paras.progresscb
	downloader.successcb = paras.successcb
	return downloader
end

function ZipDownloadManager:getTask(url)
	if self.queue[url] then
		return self.queue[url]
	end
	return nil
end

function ZipDownloadManager:removeTask(url)
	if self.queue[url] then
		self.queue[url].curlDown:stop()
		self.queue[url] = nil
	end
end

ZipDownload = ZipDownloadManager.new()