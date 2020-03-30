require("src.framework.functions")
require("src.framework.log.Analyse")

local M = {}

M.log = import(".log.Log").new()

function logd(msg,tag) M.log:d(msg,tag) end
function logw(msg,tag) M.log:w(msg,tag) end
function logi(msg,tag) M.log:i(msg,tag) end
function loge(msg,tag) M.log:e(msg,tag) end
function loga(msg) M.log:adaptLog(msg) end
M.event = import(".event.GameEvent").new()

M.json = {}
M.json.encode = require("json").encode
M.json.decode = require("json").decode

M.time = {}
M.time.getTime = require("socket").gettime

M.controller = import(".vc.Controller")
M.view = import(".vc.View")
M.device = import(".device")
M.downloader = import(".downloader.Downloader").new("download/image", 500, 10)
math.randomseed(M.time.getTime())  -- 随机化种子

qf = M
