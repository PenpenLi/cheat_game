local Calcniu = class("Calcniu")
local Card    =  import("src.games.game_niuniu.modules.game.components.card.Card")

function Calcniu:ctor(paras)
	-- body
	self._calc_panel = paras.calc
	self._cards      = paras.cards
	self.wuniu       = paras.wuniu
	self.youniu      = paras.youniu
	self.ifniu_flag       = false

	self:ifNiu()
	self:init()
	self._chose_cout = 0

	self.wuniu:setVisible(true)
	self.youniu:setVisible(true)
	self.now_niu = 0
	self.is_disable = false
end


function Calcniu:init()
	-- body
	self._num_1 = ccui.Helper:seekWidgetByName(self._calc_panel,"num_1"):getChildByName("num")
	self._num_2 = ccui.Helper:seekWidgetByName(self._calc_panel,"num_2"):getChildByName("num")
	self._num_3 = ccui.Helper:seekWidgetByName(self._calc_panel,"num_3"):getChildByName("num")
	self._result = ccui.Helper:seekWidgetByName(self._calc_panel,"num_4"):getChildByName("num")

	for k,v in pairs(self._cards) do
		v:addTouchListener(function ()
            -- body
            if  not self.is_disable then
				local y = v:getPositionY()
				local x = v:getPositionX()
				if  not self._cards[k]['chose'] then
					if self._chose_cout >= 3 then
						qf.event:dispatchEvent(Niuniu_ET.KAN_CALC_NOTICE,{type=4})
	            		return false
	            	else
	            		MusicPlayer:playMyEffectGames(Niuniu_Games_res,"COU_PAI")
	            		self._cards[k]['chose'] = 1
						v:setPosition(cc.p(x,y+40))
						self._chose_cout = self._chose_cout +1
	        		end
				else
					MusicPlayer:playMyEffectGames(Niuniu_Games_res,"COU_PAI")
					self._cards[k]['chose'] = nil
					v:setPosition(cc.p(x,y-40))
					self._chose_cout = self._chose_cout -1
					if self._chose_cout < 0 then
						self._chose_cout = 0
					end
				end
	            self:showNum()
        	end
		end)
	end

 	addButtonEventMusic(self.youniu,"GEN_ALL",function ( ... )
            -- body
        if self._chose_cout ~= 3 then
        	qf.event:dispatchEvent(Niuniu_ET.KAN_CALC_NOTICE,{type=2})
        	return false
        else
        	if self.now_niu ~= 10 then
        		qf.event:dispatchEvent(Niuniu_ET.KAN_CALC_NOTICE,{type=3})
        		return false
        	end

        	self:send()
        end
    end)


 	addButtonEventMusic(self.wuniu,"GEN_ALL",function ( ... )
            -- body
  
    	if self.ifniu_flag then
    		qf.event:dispatchEvent(Niuniu_ET.KAN_CALC_NOTICE,{type=1})
    		return false
    	end

    	self:send()
      
    end)

end

--显示选择的牛的数量
function Calcniu:showNum()
	local i = 1
	local all = 0 
	self.now_niu = 0
	self._num_1:setString("")
	self._num_2:setString("")
	self._num_3:setString("")	
	self._result:setString("")
	for k,v in pairs(self._cards) do
		if v['chose'] == 1 then
			local value      = v:getCardValue()
			local num_text   = self["_num_"..tostring(i)]

			local real_value = value
			if value > 10 then
				real_value = 10
			end

			all = all + real_value
			num_text:setString(real_value)

			i = i + 1
		end
	end

	if self._chose_cout == 3 then
		local less = math.modf(all%10)
		local re   = all
		if less == 0 then
			re = 10
		end

		self.now_niu = re
		self._result:setString(all)
	end
end


--算一下是否有牛
function  Calcniu:ifNiu()
	-- body
	for i =1,5 do
		for j=i+1,5 do
			for h=j+1,5 do
				if self and self._cards and self._cards[i] and self._cards[j] and self._cards[h] then
					local value1 = self._cards[i]:getCardValue() > 10 and 10 or self._cards[i]:getCardValue()
					local value2 = self._cards[j]:getCardValue() > 10 and 10 or self._cards[j]:getCardValue()
					local value3 = self._cards[h]:getCardValue() > 10 and 10 or self._cards[h]:getCardValue()
					local all    = value1 + value2 +value3
					local less   = math.modf(all%10)
					if less == 0 then
						self.ifniu_flag = true
						break
					end
				end
			end
		end
	end
end



--排列出有牛的牌
function Calcniu:rankCards(cards)
	-- body
	local tmp = {}
	self.ifniu_flag = false
	local flag_table = {}
	for i =1,#cards do
		for j=i+1,#cards do
			for h=j+1,#cards do
				if self.ifniu_flag == false then
					flag_table   = {}
					local value1 = Card.new({value=cards[i]}):getCardValue() > 10 and 10 or Card.new({value=cards[i]}):getCardValue()
					local value2 = Card.new({value=cards[j]}):getCardValue() > 10 and 10 or Card.new({value=cards[j]}):getCardValue()
					local value3 = Card.new({value=cards[h]}):getCardValue() > 10 and 10 or Card.new({value=cards[h]}):getCardValue()
					local all    = value1 + value2 +value3
					local less   = math.modf(all%10)
					if less == 0 then
						self.ifniu_flag = true
						table.insert( tmp, cards[i] )
						table.insert( tmp, cards[j])
						table.insert( tmp, cards[h] )
						flag_table[cards[i]] = 1
						flag_table[cards[j]] = 1
						flag_table[cards[h]] = 1
						break
					end
				end
			end
		end
	end

	if #tmp > 0  then
		for k,v in pairs(cards) do
			if not flag_table[v] then
				table.insert(tmp,v)
			end
		end

		return tmp
	else
		return cards
	end

end


--出牌
function Calcniu:send()
	GameNet:send({cmd=Niuniu_CMD.USER_REQ_SEND_CARD,body={uin=Cache.user.uin}})
end

--
function Calcniu:resume()
	-- body
	self.is_disable = true
	if not self._cards then return end
	for k,v in pairs(self._cards) do
		if tolua.isnull(v) == true then
			return
		end
		local y = v:getPositionY()
		local x = v:getPositionX()
		if   self._cards[k]['chose'] then
			v:setPosition(cc.p(x,y-40))
		else
		end
	end
	self.wuniu:setVisible(false)
	self.youniu:setVisible(false)
	self._calc_panel:setVisible(false)

	 self._num_1:setString("")
	 self._num_2:setString("")
	 self._num_3:setString("")
	 self._result:setString("")
	
end

return Calcniu