local HeadMaskInfo = class("HeadMaskInfo")

HeadMaskInfo.TAG = "HeadMaskInfo"

function HeadMaskInfo:ctor() 
    self:init()
end

function HeadMaskInfo:init() 
    self.headMaskList = {}
    self.userHeadMaskList = {}
end

function HeadMaskInfo:saveHeadMaskListConfig(model)
    if not model then return end
    self:init()
    self.userChooseIndex = Cache.user.number
    for i=1,model.frame_list:len() do
		local headMaskModel = model.frame_list:get(i)
		local headMask = {}
		headMask.number = headMaskModel.number
		headMask.gold = headMaskModel.gold
		headMask.days = headMaskModel.days
		headMask.name = headMaskModel.name
		headMask.bCloud = 0
		self.headMaskList[headMask.number] = headMask
	end

	if #self.headMaskList > 0 then
		for i=1,model.buy_list:len() do
			local userheadMaskModel = model.buy_list:get(i)
			local userheadMask = {}
			userheadMask.number = userheadMaskModel.number
			userheadMask.name = self.headMaskList[userheadMaskModel.number].name
			userheadMask.days = self.headMaskList[userheadMaskModel.number].days
			userheadMask.left_time = userheadMaskModel.left_time
			if self.headMaskList[userheadMaskModel.number] and userheadMask.left_time > 0 then
				self.headMaskList[userheadMaskModel.number].bCloud = 1
			end

			table.insert(self.userHeadMaskList, userheadMask)
		end
	end
end

function HeadMaskInfo:clear( ... )
    self:init() 
end

return HeadMaskInfo