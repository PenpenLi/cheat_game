
--[[
	数据缓存
]]

Cache = Cache or {}


--Base组件
local Desk = import(".desk.Desk")
local Config = import(".base.Config")
local DeskAssemble = import(".desk.Assemble")
local BjlDesk = import(".desk.BjlDesk")
local User = import(".base.User")
--模块组件
local RewardInfo = import(".other.RewardInfo")
local RankInfo = import(".other.RankInfo")
local BeautyInfo = import(".other.BeautyInfo")
local GameChest = import(".other.GameChest")
local WordMsg = import(".other.WordMsg")
local GiftInfo = import(".other.GiftInfo")
local MailInfo = import(".other.MailInfo")
local Jackpot = import(".other.Jackpot")
local GamesRecord = import(".other.GamesRecord")
local ActivityInfo = import(".other.ActivityInfo")
local MammonInfo = import(".other.MammonInfo")
local AgencyInfo = import(".other.AgencyInfo")
local RetMoneyInfo = import(".other.RetMoneyInfo")
local PacketInfo = import(".other.PacketInfo")
local CustomInfo = import(".other.CustomInfo")
local DeskListInfo = import(".other.DeskListInfo")
local WalletInfo = import(".other.WalletInfo")
local HongbaoInfo = import(".other.HongbaoInfo")
local HeadMaskInfo = import(".other.HeadMaskInfo")
local PayManager = import(".pay.PayManager")
local CustomerChatInfo = import(".chat.Chat")

Cache.activityInfo = ActivityInfo.new()
Cache.RewardInfo = RewardInfo.new()
Cache.BeautyInfo = BeautyInfo.new()
Cache.GameChest = GameChest.new()
Cache.brdesk = Desk.new()
Cache.bjldesk = BjlDesk.new()
Cache.Config = Config.new()
Cache.DeskAssemble = DeskAssemble.new()
Cache.desk = Desk.new()
Cache.rank = RankInfo.new()
Cache.giftInfo = GiftInfo.new()
Cache.mailInfo = MailInfo.new()
Cache.mammonInfo = MammonInfo.new()
Cache.agencyInfo = AgencyInfo.new()
Cache.packetInfo = PacketInfo.new()
Cache.customInfo = CustomInfo.new()
Cache.deskListInfo = DeskListInfo.new()
Cache.walletInfo = WalletInfo.new()
Cache.retmoneyInfo = RetMoneyInfo.new()
Cache.wordMsg = WordMsg.new()
Cache.jackpot = Jackpot.new()
Cache.gamesRecord = GamesRecord.new()
Cache.user = User.new()
Cache.cusChatInfo = CustomerChatInfo:new()
Cache.hongbaoInfo = HongbaoInfo:new()
Cache.headMaskInfo = HeadMaskInfo:new()
Cache.friend = {}
Cache.chat = {}

--商城支付
Cache.PayManager = PayManager.new()
Cache.clear = function ( ... )
	if Cache.mailInfo then
		Cache.mailInfo:clear()
	end
	if Cache.cusChatInfo then
		Cache.cusChatInfo:clear()
	end
	if Cache.user then
		Cache.user:clear()
	end
	if Cache.mammonInfo then
		Cache.mammonInfo:clear()
	end
	if Cache.headMaskInfo then
		Cache.headMaskInfo:clear()
	end
end