local Context=game:GetService("ContextActionService")
local GuiService=game:GetService("GuiService")
local Input=game:GetService("UserInputService")
local Theme=require(game.ReplicatedStorage.ZIVRA.Theme)

local Menu={}
Menu.__index=Menu

local function make(class,name,parent,properties)
	local object=Instance.new(class)
	object.Name=name
	for key,value in pairs(properties) do object[key]=value end
	object.Parent=parent
	return object
end

local function text(parent,name,value,pos,size,fontSize,color)
	return make("TextLabel",name,parent,{Text=value,BackgroundTransparency=1,
		TextSize=fontSize,Font=Theme.Font,TextColor3=color or Theme.Text,
		Position=pos,Size=size,TextXAlignment=Enum.TextXAlignment.Left,
		TextTruncate=Enum.TextTruncate.AtEnd})
end

local function button(parent,name,value,pos,size,primary,action)
	local base=primary and Theme.Cyan or Theme.Surface
	local item=make("TextButton",name,parent,{Text=value,TextSize=13,Font=Theme.Bold,
		TextColor3=primary and Theme.Background or Theme.Text,BackgroundColor3=base,
		BorderSizePixel=0,Position=pos,Size=size,AutoButtonColor=false})
	make("UICorner","Corner",item,{CornerRadius=UDim.new(0,4)})
	if not primary then make("UIStroke","Border",item,{Color=Theme.Line,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
	item.MouseEnter:Connect(function() item.BackgroundColor3=base:Lerp(Theme.Text,0.14) end)
	item.MouseLeave:Connect(function() item.BackgroundColor3=base end)
	item.Activated:Connect(action)
	return item
end

function Menu.new(player,send,setNative,openEquipment)
	local self=setmetatable({player=player,send=send,setNative=setNative,openEquipment=openEquipment},Menu)
	local gui=make("ScreenGui","ZIVRAHeadquarters",player:WaitForChild("PlayerGui"),{
		ResetOnSpawn=false,DisplayOrder=12,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,Enabled=false})
	self.gui=gui
	local root=make("Frame","Root",gui,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
	local identity=make("Frame","Identity",root,{Position=UDim2.fromOffset(16,12),Size=UDim2.fromOffset(188,45),
		BackgroundColor3=Theme.Background,BackgroundTransparency=0.14,BorderSizePixel=0})
	make("ImageLabel","Emblem",identity,{Position=UDim2.fromOffset(8,7),Size=UDim2.fromOffset(32,32),
		BackgroundTransparency=1,Image="rbxassetid://129565854362406",ScaleType=Enum.ScaleType.Fit})
	text(identity,"Wordmark","ZIVRA",UDim2.fromOffset(49,3),UDim2.fromOffset(130,22),18).Font=Theme.Bold
	text(identity,"Location","HEADQUARTERS",UDim2.fromOffset(50,24),UDim2.fromOffset(130,15),10,Theme.Muted)
	local actions=make("Frame","Actions",root,{Size=UDim2.new(0.90,0,0,46),
		Position=UDim2.new(0.5,0,1,-16),AnchorPoint=Vector2.new(0.5,1),BackgroundTransparency=1})
	make("UISizeConstraint","Maximum",actions,{MaxSize=Vector2.new(438,46)})
	self.primary=button(actions,"Play","PLAY 1V1",UDim2.new(),UDim2.new(0.4,-4,1,0),true,function()
		self:setOpen(true)
	end)
	button(actions,"Loadout","LOADOUT",UDim2.fromScale(0.4,0),UDim2.new(0.3,-4,1,0),false,function() openEquipment("Weapons") end)
	button(actions,"Settings","SETTINGS",UDim2.fromScale(0.7,0),UDim2.fromScale(0.3,1),false,function() openEquipment("Settings") end)
	self.queueBanner=text(root,"QueueBanner","",UDim2.new(0.5,0,0,17),UDim2.new(0.44,0,0,34),12,Theme.Cyan)
	self.queueBanner.AnchorPoint=Vector2.new(0,0)
	self.queueBanner.TextXAlignment=Enum.TextXAlignment.Right
	self.queueBanner.Font=Theme.Bold

	local modal=make("Frame","Matchmaking",root,{BackgroundColor3=Theme.Background,BackgroundTransparency=0.28,
		Size=UDim2.fromScale(1,1),Visible=false})
	self.modal=modal
	make("TextButton","Backdrop",modal,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",Modal=true,AutoButtonColor=false,Selectable=false})
	local panel=make("Frame","QueuePanel",modal,{Size=UDim2.new(0.9,0,1,-16),Position=UDim2.fromScale(0.5,0.5),
		AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Theme.Surface,BorderSizePixel=0,ClipsDescendants=true})
	make("UISizeConstraint","Maximum",panel,{MaxSize=Vector2.new(545,275)})
	make("UICorner","Corner",panel,{CornerRadius=UDim.new(0,5)})
	make("UIStroke","PanelBorder",panel,{Color=Theme.Line})
	make("ImageLabel","ArenaArtwork",panel,{Position=UDim2.new(0.58,0,0,0),Size=UDim2.new(0.42,0,1,0),
		Image="rbxassetid://78032110481735",ImageTransparency=0.24,BackgroundTransparency=1,ScaleType=Enum.ScaleType.Crop,
		ZIndex=1})
	make("Frame","Rule",panel,{Size=UDim2.fromOffset(3,40),Position=UDim2.fromOffset(0,18),
		BackgroundColor3=Theme.Cyan,BorderSizePixel=0,ZIndex=2})
	text(panel,"Mode","PLAY 1V1",UDim2.fromOffset(19,15),UDim2.new(0.56,-16,0,39),29).Font=Theme.Bold
	text(panel,"Format","FIRST TO THREE",UDim2.fromOffset(20,56),UDim2.new(0.56,-16,0,22),12,Theme.Muted)
	self.status=text(panel,"QueueStatus","Ready to queue",UDim2.new(0,20,1,-105),UDim2.new(0.56,-20,0,40),14)
	self.status.TextWrapped=true
	self.status.TextTruncate=Enum.TextTruncate.None
	self.confirm=button(panel,"QueueAction","FIND OPPONENT",UDim2.new(0,20,1,-57),UDim2.new(0.54,-20,0,44),true,function()
		if not self.state or self.state.mode~="Lobby" or self.pending then return end
		self.pending=true
		send(self.state.queued and "QueueCancel" or "QueueJoin")
		self.confirm.Text="CONNECTING"
		task.delay(1.5,function()
			if self.pending then self.pending=false; self:update(self.state,self.equipmentOpen) end
		end)
	end)
	local close=button(panel,"Close","CLOSE",UDim2.new(1,-74,0,10),UDim2.fromOffset(64,44),false,function() self:setOpen(false) end)
	close.ZIndex=3
	Context:BindAction("ZIVRA_HeadquartersMenu",function(_,inputState)
		if not gui.Enabled or Input:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
		if inputState==Enum.UserInputState.Begin then self:setOpen(not modal.Visible) end
		return Enum.ContextActionResult.Sink
	end,false,Enum.KeyCode.M)
	return self
end

function Menu:setOpen(value)
	value=value and self.gui.Enabled
	if self.modal.Visible==value then return end
	self.modal.Visible=value
	self.setNative(value)
	if Input.GamepadEnabled then GuiService.SelectedObject=value and self.confirm or nil end
end

function Menu:update(state,equipmentOpen)
	local before=self.state and self.state.queued
	self.state=state
	self.equipmentOpen=equipmentOpen
	local inLobby=state and state.mode=="Lobby"
	if not inLobby or equipmentOpen then self:setOpen(false) end
	self.gui.Enabled=inLobby and not equipmentOpen or false
	if not inLobby then return end
	if before~=state.queued then self.pending=false end
	self.queueBanner.Visible=state.queued
	self.queueBanner.Text=state.queued and "SEARCHING FOR OPPONENT" or ""
	self.status.Text=state.queued and "Waiting for a player in this server" or "Ready to queue"
	self.primary.Text=state.queued and "VIEW QUEUE" or "PLAY 1V1"
	self.confirm.Text=self.pending and "CONNECTING" or state.queued and "CANCEL QUEUE" or "FIND OPPONENT"
end

return Menu
