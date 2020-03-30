local CustomTabViewCell = class("CustomTabViewCell", function(paras)
    return paras.node
end)
CustomTabViewCell.TAG = "CustomTabViewCell"

function CustomTabViewCell:ctor(paras)
	self.data = {}
	self.updata = nil
	self.index = -1

	if paras then
		self.data = paras.data
		self.updata = paras.updata
	end
	-- if self.data then
	self:updataCell(self.data)
	-- end
end

function CustomTabViewCell:updataCell(data)
	self.data = data
	if self.data then
		self.updata(data,self)
		self:setVisible(true)
	else
		self:setVisible(false)
	end
end


return CustomTabViewCell