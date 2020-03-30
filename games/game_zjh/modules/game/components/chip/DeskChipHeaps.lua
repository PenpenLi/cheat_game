--[[
    底池筹码堆组件.
    由于不在200版本计划内,时间紧张,本组件属于暴力拆解出来的一组算法的集合，不是一个独立的node，有待优化
--]]
local DeskChipHeaps = class("DeskChipHeaps")
local Chip = import(".Chip")
local ChipUtil = import(".ChipUtil")

DeskChipHeaps.TAG = "DeskChipHeaps"


function DeskChipHeaps:ctor(paras)
    self._chipHeaps = {}
    self.root = paras.root
    self.gui = paras.gui
    self.deskCache = paras.cache
end

function DeskChipHeaps:initPosData(paras)
    self.DESK_CHIPS_POSX = paras.x
    self.DESK_CHIPS_POSY = paras.y
    self.CHIP_HEAP_Z = paras.chipheap_z
    self.HEAP_SEQ = paras.heap_gap
    self.seatLimit = paras.seat_limit
    self.winSize = paras.winSize
end

function DeskChipHeaps:clear()
    for k, heap in pairs(self._chipHeaps) do
        if not tolua.isnull(heap) then
            heap:removeFromParent(true)
        end
    end
    self._chipHeaps = {}
end

function DeskChipHeaps:getLastHeapPos()
    self._chipHeaps = self._chipHeaps or {}
    return self:fixHeapPosition(self._chipHeaps[#self._chipHeaps])
end

function DeskChipHeaps:fixHeapPosition(chipHeap)
    if chipHeap == nil or tolua.isnull(chipHeap) then
        local x, y = self.DESK_CHIPS_POSX, self.DESK_CHIPS_POSY
        return x, y
    else
        local x, y = chipHeap:getPosition()
        local size = chipHeap:getRealContentSize()
        local chip_x, chip_y = chipHeap:getHeapTopCenter()    --顶部筹码在筹码堆中的内部坐标
        return x + chip_x, y + chip_y
    end
end

function DeskChipHeaps:putDeskChipsToUser(user,model)
    if user == nil then return end
    local function flyChips (index,number,last)
        local heapUtil = self._chipHeaps[index]
        if heapUtil == nil then
            loge( "wrong heap util ".. tostring(index) , self.TAG)
            return
        end
       -- MusicPlayer:playMyEffect("CHIP_FLY")
        if last then
            number = heapUtil.number
        end
        heapUtil:setLocalZOrder(self.CHIP_HEAP_Z)
        local heapSprites,realNumber = ChipUtil:getHeapTable(number)
        heapUtil:update({number=-number+realNumber})  --因为筹码动画带的价格不高，所以先减去误差值
        local nHeapSprites, nRealy = table.nums(heapSprites), 0
        local startPos = cc.p(self:fixHeapPosition(heapUtil))
        local endPos = cc.p(user:getPosition())
        for hk,hv in pairs(heapSprites) do
            nRealy = nRealy + 1
            local ok = nRealy == nHeapSprites
            self.root:addChild(hv, 0)
            hv:setVisible(false)
            ChipUtil:moveChipToPos(hv, startPos, endPos, function( sender )
                if self._chipHeaps[index] and not tolua.isnull(heapUtil) then 
                    heapUtil:update({number = -sender.value}) 
                end
                if not tolua.isnull(user) then
                    user:updateBaseInfo({})
                end
                if ok and not tolua.isnull(user) then
                    user:showVictoryPartical(number)
                end
                sender:removeFromParent(true)
            end, {delay = hk*0.06, moveDelay = 0.2})
        end
    end
    
    local rlist = self.deskCache:getResult() --取result数组
    for k,v in pairs(rlist) do 
        local j = 1

        for i = 1, GameConstants.FORCE_TIME do
            if j > #v.settle then
                break
            end
            local c = v.settle[j]
            if c.uin == model.uin and c.chips > 0 then
                flyChips(k,c.chips,j==#v.settle)
                c.chips = -1
                table.remove(v.settle,j)
            else
                j = j+1
            end
        end
    end
end

function DeskChipHeaps:adjustChipHeaps ()
    local lastHeap = self._chipHeaps[#self._chipHeaps]
    local heapNumber = #self._chipHeaps
    local cs = self.winSize
    local tcds = self.deskCache.total_chips_detail
    if #tcds <= heapNumber then return  end  --不需要分堆

    local beforelen = 0
    local turnAround = 0
    local heapPoint = {}
    if self.seatLimit == 9 then
        turnAround = 5
        heapPoint = {{0, GameConstants.LAYOUT_9.DESK_CHIPS_LINE1_Y}
            , {0, GameConstants.LAYOUT_9.DESK_CHIPS_LINE1_Y}
            , {0, GameConstants.LAYOUT_9.DESK_CHIPS_LINE1_Y}
            , {0, GameConstants.LAYOUT_9.DESK_CHIPS_LINE1_Y}
            , {0, GameConstants.LAYOUT_9.DESK_CHIPS_LINE2_Y}
            , {0, GameConstants.LAYOUT_9.DESK_CHIPS_LINE2_Y}
            , {0, GameConstants.LAYOUT_9.DESK_CHIPS_LINE2_Y}
            , {0, GameConstants.LAYOUT_9.DESK_CHIPS_LINE2_Y}
            , {0, GameConstants.LAYOUT_9.DESK_CHIPS_LINE2_Y}
        }
    else
        turnAround = 6
        heapPoint = {{0, self.DESK_CHIPS_POSY}
            , {0, self.DESK_CHIPS_POSY}
            , {0, self.DESK_CHIPS_POSY}
            , {0, self.DESK_CHIPS_POSY}
            , {0, self.DESK_CHIPS_POSY}
        }
    end

    for i = heapNumber + 1,#tcds do
        local chip = Chip.new()
        
        -- 第二行筹码Z要高1，盖住桌牌
        local z = self.CHIP_HEAP_Z - 1
        if i >= turnAround then z = self.CHIP_HEAP_Z end

        self.gui:addChild(chip, z)
        self._chipHeaps[i] = chip

        chip:update({number=tcds[i].chips}) -- 初始化长度
        chip:hideContent()
    end

    for k,v in pairs(self._chipHeaps) do
        if k<turnAround then
            beforelen = beforelen + v:getLen() + self.HEAP_SEQ
        end
    end
    local tempLen = 0
    for k,v in pairs(self._chipHeaps) do
        if k<turnAround then
            heapPoint[k][1] = (cs.width/2 - beforelen/2 + 15)+tempLen
        else
            heapPoint[k][1] = (cs.width/2 - beforelen/2 + 15)+tempLen
        end
        tempLen = tempLen + v:getLen() + self.HEAP_SEQ
        if (k==(turnAround-1)) then
            tempLen = 0
        end
    end
    for k,v in pairs(self._chipHeaps) do
        if k <= heapNumber then 
            v:runAction(cc.MoveTo:create(0.2,cc.p(heapPoint[k][1],heapPoint[k][2])))
        else
            v:setPosition(heapPoint[k][1],heapPoint[k][2])
        end
    end
    local function flyChips(paras) --调整数值
        if lastHeap == nil then return end
        local st = paras.st
        local vl = paras.vl
        local hp = paras.hp

        local moveAction = cc.MoveTo:create(0.3,cc.p(hp:getPosition()))
        st:setPosition(lastHeap:getPosition())
        st.k = k  
        st.chips = vl
        st:setVisible(false)
        self.root:addChild(st,0)
        st:runAction(cc.Sequence:create(cc.DelayTime:create(0.2)
            , cc.CallFunc:create(function( sender )
                sender:setVisible(true)
            end)
            , moveAction
            , cc.CallFunc:create(function( sender )
                hp:update({number=-hp.number + sender.chips})
                hp:showContent()
                sender:removeFromParent(true)
            end)))
    end

    for i = heapNumber + 1,#tcds do
        local chip = self._chipHeaps[i]
        local hh = ChipUtil:getHeap(tcds[i].chips)
        flyChips({st=hh,vl=tcds[i].chips,hp=chip,k=i})
    end
end

function DeskChipHeaps:updateChipHeap ( paras ) 
    if self._chipHeaps == nil then self._chipHeaps = {} end

    if self._chipHeaps[1] == nil then
        local c = Chip.new()
        c:setPosition(self.DESK_CHIPS_POSX, self.DESK_CHIPS_POSY)
        self.gui:addChild(c,self.CHIP_HEAP_Z-1)
        self._chipHeaps[1] = c
    end

    local index = #self._chipHeaps
    local heap = self._chipHeaps[index]
    local number = paras.number
    if self.deskCache.total_chips_detail[index] then
        number = self.deskCache.total_chips_detail[index].chips
        self._chipHeaps[index]:update({number=-heap.number + number})
    else
        self._chipHeaps[index]:update({number=number})
    end
    
    -- 延迟调整堆
    self.root:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function()
            self:adjustChipHeaps()
        end)
    ))
end

function DeskChipHeaps:getValue()
    local chips_num = 0
    for k, v in pairs(self._chipHeaps) do
        local heap_num = v:isVisible() and v:getValue() or 0
        chips_num = chips_num + heap_num
    end
    return chips_num
end

function DeskChipHeaps:setValue()

end


return DeskChipHeaps