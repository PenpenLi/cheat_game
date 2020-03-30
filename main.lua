require("Cocos2d")


local function main()
    --avoid mem leak -- 
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
        collectgarbage("collect")
        --print("  --- lua mem useage -- " .. collectgarbage("count") .. "Kbytes", "GAME")
    end,30,false)
   require("src.hotupdate.init") -- 先进入更新模块
end


main()
