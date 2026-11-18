local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local GuiService=game:GetService("GuiService")
local Weapons=require(game.ReplicatedStorage.ZIVRA.Weapons)
local Models=require(game.ReplicatedStorage.ZIVRA.Models)
local T=require(game.ReplicatedStorage.ZIVRA.Theme)
local Icons=require(script.Parent.WeaponIcons)
local UI={category=1,selected={},menu=false,cards={},tabPreviews={},touch={},settings={},hudLayout={}}
local function make(class,parent,props)
	local x=Instance.new(class)
	for k,v in pairs(props or {}) do x[k]=v end
	x.Parent=parent; return x
end
local function round(x,r) make("UICorner",x,{CornerRadius=UDim.new(0,r or 6)}) end
local function stroke(x,color,width) return make("UIStroke",x,{Color=color or T.Line,Thickness=width or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function label(parent,text,size,pos,dim,color)
	return make("TextLabel",parent,{BackgroundTransparency=1,Text=text,TextColor3=color or T.Text,Font=T.Font,TextSize=size,
		TextXAlignment=Enum.TextXAlignment.Left,Position=pos or UDim2.new(),Size=dim or UDim2.fromScale(1,1),TextTruncate=Enum.TextTruncate.AtEnd})
end
local function button(parent,text,pos,dim,fn)
	if dim.Y.Scale==0 and dim.Y.Offset>0 then dim=UDim2.new(dim.X.Scale,dim.X.Offset,0,math.max(44,dim.Y.Offset)) end
	local b=make("TextButton",parent,{Text=text,TextSize=13,Font=T.Bold,TextColor3=T.Text,BackgroundColor3=T.Raised,
		AutoButtonColor=false,Position=pos,Size=dim,BorderSizePixel=0})
	round(b,6); stroke(b)
	b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(50,54,66)}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=T.Raised}):Play() end)
	if fn then b.Activated:Connect(fn) end
	return b
end
local function viewport(parent,d,pos,size)
	local v=make("ViewportFrame",parent,{BackgroundTransparency=1,Position=pos,Size=size,Ambient=Color3.fromRGB(180,185,200),LightColor=Color3.new(1,0.95,0.85),LightDirection=Vector3.new(-1,-2,-2)})
	local world=make("WorldModel",v); local m=Models.build(d,false); m.Parent=world
	local cf,ext=m:GetBoundingBox(); local length=math.max(ext.X,ext.Y,ext.Z)
	local cam=make("Camera",v,{FieldOfView=32}); cam.CFrame=CFrame.lookAt(cf.Position+Vector3.new(1,0.5,-1.4).Unit*length*2,cf.Position)
	v.CurrentCamera=cam; return v
end
function UI.notice(text)
	UI.toast.Text=text; UI.toast.Visible=true; UI.toastUntil=os.clock()+3
end
function UI.setMenu(open,screen)
	if open and not UI.state then UI.notice("Loading profile..."); return end
	UI.menu=open; UI.overlay.Visible=open; UI.onMenu(open)
	UI.touchLayer.Visible=not open and UIS.TouchEnabled and UI.state and UI.state.mode~="Lobby"
	UI.reticle.Visible=not open and UI.state and UI.state.mode~="Lobby"
	if open then UI.reloadTrack.Visible=false;UI.damageDirection.Visible=false end
	TweenService:Create(UI.blur,TweenInfo.new(0.18),{Size=open and UI.settings.quality~="Low" and 14 or 0}):Play()
	UI.weaponPanel.Visible=open and (screen==nil or screen=="Weapons")
	UI.options.Visible=open and screen=="Settings"; UI.tasks.Visible=open and screen=="Tasks"
	UI.invites.Visible=open and screen=="Invites"
	if UI.invites.Visible then UI.rebuildInvites() end
	if open and UI.weaponPanel.Visible then UI.rebuild() end
	if UIS.GamepadEnabled then GuiService.SelectedObject=open and (UI.options.Visible and UI.qualityButton or UI.equip) or nil end
end
function UI.rebuildInvites()
	for _,x in ipairs(UI.playerList:GetChildren()) do if x:IsA("GuiObject") then x:Destroy() end end
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=Players.LocalPlayer then
			button(UI.playerList,p.DisplayName.."  /  INVITE",UDim2.new(),UDim2.new(1,-8,0,40),function() UI.send("Invite",p.UserId) end)
		end
	end
end
function UI.rebuild()
	if not UI.state then return end
	for _,x in ipairs(UI.grid:GetChildren()) do if x:IsA("GuiObject") then x:Destroy() end end
	UI.cards={}
	for i,b in ipairs(UI.tabs) do
		b.UIStroke.Color=i==UI.category and T.Text or T.Line; b.UIStroke.Thickness=i==UI.category and 2 or 1
	end
	local valid={}
	for _,d in ipairs(Weapons.List) do if d.slot==UI.category and (UI.state.mode=="Range" or UI.state.owned[d.id]) then table.insert(valid,d) end end
	local random=button(UI.grid,"RANDOM",UDim2.new(),UDim2.new(),function()
		if #valid==0 then return end
		local choices={}; for _,d in ipairs(valid) do if d.id~=UI.state.loadout[UI.category] then table.insert(choices,d) end end
		if #choices==0 then choices=valid end
		UI.choose(choices[math.random(#choices)].id)
	end)
	random.BackgroundColor3=Color3.fromRGB(10,11,15); random.LayoutOrder=0
	label(random,"/  /",30,UDim2.fromScale(0.15,0.12),UDim2.fromScale(0.7,0.45),T.Muted).TextXAlignment=Enum.TextXAlignment.Center
	for order,d in ipairs(Weapons.List) do
		if d.slot==UI.category and (Weapons.Launch[d.id] or UI.state and UI.state.mode=='Range') then
			local b=button(UI.grid,"",UDim2.new(),UDim2.new(),function() UI.choose(d.id) end); b.LayoutOrder=order
			if d.rarity=="Signature" then b.UIStroke.Color=T.Gold end
			viewport(b,d,UDim2.fromScale(0,-0.03),UDim2.fromScale(1,0.78))
			label(b,d.name,13,UDim2.fromScale(0.07,0.72),UDim2.fromScale(0.88,0.18)).Font=T.Bold
			local owned=UI.state.owned[d.id]
			local status=UI.state.loadout[d.slot]==d.id and "EQUIPPED" or not owned and (UI.state.mode=="Range" and "TRIAL" or "LOCKED") or "OWNED"
			label(b,status,10,UDim2.fromScale(0.07,0.9),UDim2.fromScale(0.88,0.1),status=="EQUIPPED" and T.Cyan or T.Muted)
			UI.cards[d.id]=b
		end
	end
	UI.highlight()
end
function UI.highlight()
	local id=UI.selected[UI.category] or UI.state.loadout[UI.category]
	for key,b in pairs(UI.cards) do b.UIStroke.Thickness=key==id and 2 or 1; b.UIStroke.Color=key==id and T.Text or T.Line end
	local d=Weapons.ById[id]; if not d then return end
	UI.detail.Text=d.name.."  /  "..d.kind:upper().."  /  "..(d.magazine and tostring(d.magazine).." ROUNDS" or d.heal and "HEAL "..d.heal or tostring(d.damage).." DAMAGE")
	UI.equip.Text=UI.state.mode=="Range" and "TRY WEAPON" or UI.state.owned[id] and "EQUIP" or "RANGE TRIAL ONLY"
end
function UI.choose(id)
	local d=Weapons.ById[id]; UI.selected[d.slot]=id; UI.highlight()
	if UI.state.mode=="Range" then UI.send("Equip",id) end
end
function UI.resize()
	local width=UI.grid.AbsoluteSize.X
	local columns=width>=600 and 5 or width>=420 and 4 or 3
	local size=math.floor((width-(columns-1)*8)/columns)
	UI.gridLayout.CellSize=UDim2.fromOffset(size,size); UI.gridLayout.CellPadding=UDim2.fromOffset(8,8)
	local phone=UI.root.AbsoluteSize.Y<500 or UI.root.AbsoluteSize.X<600
	UI.title.TextSize=phone and 15 or 20
	UI.subtitle.Visible=not phone
	UI.tabBar.Position=UDim2.fromOffset(0,phone and 40 or 64); UI.tabBar.Size=UDim2.new(1,0,0,phone and 62 or 86)
	for _,b in ipairs(UI.tabs) do b.Size=UDim2.fromOffset(phone and 62 or 86,phone and 62 or 86) end
	UI.ammo.Position=phone and UDim2.new(0,16,0,140) or UDim2.new(0.5,-150,1,-94)
 UI.health.Position=phone and UDim2.fromOffset(16,180) or UDim2.new(0,16,1,-42)
 UI.ammo.Size=UDim2.fromOffset(300,24); UI.ammo.TextXAlignment=phone and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
 UI.reloadTrack.AnchorPoint=Vector2.new(phone and 0 or 0.5,0)
 UI.reloadTrack.Position=phone and UDim2.new(0,16,0,168) or UDim2.new(0.5,0,1,-64)
	UI.applyLayout()
	UI.grid.Position=UDim2.fromOffset(0,phone and 112 or 162); UI.grid.Size=UDim2.new(1,0,1,phone and -176 or -226)
end
local defaults={Fire={x=0.88,y=0.42,size=76},Reload={x=0.73,y=0.59,size=52},Alt={x=0.76,y=0.33,size=52},
	Utility={x=0.88,y=0.64,size=56},Crouch={x=0.64,y=0.68,size=52},Sprint={x=0.62,y=0.43,size=48}}
function UI.applyLayout()
	for id,b in pairs(UI.touch) do
		local p=UI.hudLayout[id] or defaults[id]
		local available=UI.root.AbsoluteSize
		local scale=math.min(1,available.X/640,available.Y/360)
		local size=math.max(44,p.size*scale)
		b.Position=UDim2.fromScale(p.x,p.y); b.Size=UDim2.fromOffset(size,size)
	end
end
local function touching(a,b)
	local pa,pb=a.AbsolutePosition,b.AbsolutePosition; local sa,sb=a.AbsoluteSize,b.AbsoluteSize
	return pa.X<pb.X+sb.X+6 and pa.X+sa.X+6>pb.X and pa.Y<pb.Y+sb.Y+6 and pa.Y+sa.Y+6>pb.Y
end
function UI.init(send,onMenu,action)
	UI.send=send; UI.onMenu=onMenu; UI.action=action
	local player=Players.LocalPlayer
	UI.gui=make("ScreenGui",player:WaitForChild("PlayerGui"),{Name="ZIVRA_UI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=false,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,DisplayOrder=20})
	UI.root=make("Frame",UI.gui,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
	UI.blur=make("BlurEffect",Lighting,{Name="ZIVRA_MenuBlur",Size=0})
	UI.top=label(UI.root,"ZIVRA  /  HEADQUARTERS",13,UDim2.fromOffset(16,8),UDim2.new(0.6,0,0,24)); UI.top.Font=T.Bold
	UI.currency=label(UI.root,"",13,UDim2.new(1,-220,0,8),UDim2.fromOffset(204,24),T.Gold); UI.currency.TextXAlignment=Enum.TextXAlignment.Right
	UI.toast=label(UI.root,"",14,UDim2.fromScale(0.25,0.17),UDim2.fromScale(0.5,0.08)); UI.toast.TextXAlignment=Enum.TextXAlignment.Center; UI.toast.TextWrapped=true; UI.toast.Visible=false; UI.toast.ZIndex=60
	UI.health=make("Frame",UI.root,{Position=UDim2.new(0,16,1,-42),Size=UDim2.fromOffset(160,24),BackgroundColor3=T.Background,BorderSizePixel=0}); round(UI.health,4)
	UI.healthFill=make("Frame",UI.health,{Size=UDim2.fromScale(1,1),BackgroundColor3=T.Green,BorderSizePixel=0}); round(UI.healthFill,4)
	UI.healthText=label(UI.health,"100",12,UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0),T.Background); UI.healthText.Font=T.Bold
	UI.ammo=label(UI.root,"",16,UDim2.new(1,-240,1,-42),UDim2.fromOffset(220,24)); UI.ammo.TextXAlignment=Enum.TextXAlignment.Right
	UI.reloadTrack=make("Frame",UI.root,{Name="ReloadProgress",AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,1,-64),Size=UDim2.fromOffset(160,3),BackgroundColor3=T.Line,BorderSizePixel=0,Visible=false})
 UI.reloadFill=make("Frame",UI.reloadTrack,{Size=UDim2.fromScale(0,1),BackgroundColor3=T.Cyan,BorderSizePixel=0})
 UI.damageDirection=make("Frame",UI.root,{Name="DamageDirection",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(180,180),BackgroundTransparency=1,Visible=false})
 local arrow=label(UI.damageDirection,"^",26,UDim2.fromScale(0.5,0),UDim2.fromOffset(28,28),T.Red);arrow.AnchorPoint=Vector2.new(0.5,0);arrow.TextXAlignment=Enum.TextXAlignment.Center;arrow.Font=T.Bold
 UI.reticle=make("Frame",UI.root,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(2,2),BackgroundColor3=T.Text,BorderSizePixel=0})
	UI.cross={}; for i=1,4 do UI.cross[i]=make("Frame",UI.reticle,{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(i<=2 and 6 or 2,i<=2 and 2 or 6),BackgroundColor3=T.Text,BorderSizePixel=0}) end
	UI.hit=label(UI.root,"X",26,UDim2.fromScale(0.5,0.5),UDim2.fromOffset(30,30)); UI.hit.AnchorPoint=Vector2.new(0.5,0.5); UI.hit.TextXAlignment=Enum.TextXAlignment.Center; UI.hit.Visible=false
	UI.nav=make("Frame",UI.root,{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-68),Size=UDim2.new(0.94,0,0,40),BackgroundTransparency=1})
	make("UISizeConstraint",UI.nav,{MaxSize=Vector2.new(720,40)})
	make("UIListLayout",UI.nav,{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,Padding=UDim.new(0,8)})
	local links={
		{"WEAPONS",function() UI.setMenu(true,"Weapons") end}, {"RANGE",function() send("Range") end},
		{"DUELS",function() send("Queue") end}, {"TASKS",function() UI.setMenu(true,"Tasks") end}, {"SETTINGS",function() UI.setMenu(true,"Settings") end}}
	for _,link in ipairs(links) do local b=button(UI.nav,link[1],UDim2.new(),UDim2.new(0.2,-8,1,0),link[2]); b.TextSize=11 end
	UI.returnButton=button(UI.root,"LOBBY",UDim2.fromOffset(16,44),UDim2.fromOffset(88,32),function() send("Lobby") end)
	UI.inviteButton=button(UI.root,"INVITE",UDim2.fromOffset(16,44),UDim2.fromOffset(88,32),function() UI.setMenu(true,"Invites") end)
	UI.resetButton=button(UI.root,"RESET RANGE",UDim2.fromOffset(112,44),UDim2.fromOffset(110,32),function() send("ResetRange") end)
	UI.menuButton=button(UI.root,"SETTINGS",UDim2.new(1,-104,0,44),UDim2.fromOffset(88,32),function() UI.setMenu(not UI.menu,UI.state.mode=="Duel" and "Settings" or "Weapons") end)
	UI.rangeStats=label(UI.root,"",11,UDim2.fromOffset(16,96),UDim2.fromOffset(280,36),T.Muted); UI.rangeStats.TextWrapped=true
	UI.quickbar=make("Frame",UI.root,{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-12),Size=UDim2.new(0.44,0,0,42),BackgroundTransparency=1})
	make("UIListLayout",UI.quickbar,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4)})
	UI.quick={}
	for i=1,4 do
		UI.quick[i]=button(UI.quickbar,tostring(i),UDim2.new(),UDim2.new(0.25,-3,1,0),function() if UI.state then send("Equip",UI.state.loadout[i]) end end)
		UI.quick[i].TextSize=10; UI.quick[i].TextWrapped=true
	end
	UI.touchLayer=make("Frame",UI.root,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=UIS.TouchEnabled})
	for id,p in pairs(defaults) do
		local b=button(UI.touchLayer,id:upper(),UDim2.fromScale(p.x,p.y),UDim2.fromOffset(p.size,p.size),nil)
		b.AnchorPoint=Vector2.new(0.5,0.5); b.BackgroundTransparency=0.3; b.TextSize=10; b.UICorner.CornerRadius=UDim.new(1,0); UI.touch[id]=b
		local active,dragStart,old
		b.InputBegan:Connect(function(input)
			if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
			active=input
			if UI.editing then UI.selectedButton=id; dragStart=Vector2.new(input.Position.X,input.Position.Y); old=b.Position
			else action(id,true,input) end
		end)
		UIS.InputChanged:Connect(function(input)
			if UI.editing and active and (input==active or input.UserInputType==Enum.UserInputType.MouseMovement) then
				local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart; local size=UI.root.AbsoluteSize
				b.Position=UDim2.fromScale(math.clamp(old.X.Scale+delta.X/size.X,0.52,0.94),math.clamp(old.Y.Scale+delta.Y/size.Y,0.2,0.75))
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input~=active then return end
			if UI.editing then
				for other,c in pairs(UI.touch) do if id~=other and touching(b,c) then b.Position=old; UI.notice("Keep action buttons separated"); break end end
				UI.hudLayout[id]={x=b.Position.X.Scale,y=b.Position.Y.Scale,size=b.AbsoluteSize.X}
			else action(id,false,input) end
			active=nil
		end)
	end
	UI.editDone=button(UI.root,"SAVE HUD",UDim2.fromScale(0.42,0.1),UDim2.fromOffset(100,36),function()
		UI.editing=false; UI.editDone.Visible=false; UI.smaller.Visible=false; UI.larger.Visible=false; send("Settings",{hud=UI.hudLayout}); UI.notice("HUD layout saved")
	end); UI.editDone.Visible=false
	local function resizeSelected(delta)
		local id=UI.selectedButton or "Fire"; local b=UI.touch[id]; local old=b.Size
		local size=math.clamp(b.AbsoluteSize.X+delta,44,88); b.Size=UDim2.fromOffset(size,size)
		for other,c in pairs(UI.touch) do if other~=id and touching(b,c) then b.Size=old; UI.notice("That size overlaps another control"); return end end
		UI.hudLayout[id]={x=b.Position.X.Scale,y=b.Position.Y.Scale,size=size}
	end
	UI.smaller=button(UI.root,"SIZE -",UDim2.fromScale(0.2,0.1),UDim2.fromOffset(72,36),function() resizeSelected(-4) end)
	UI.larger=button(UI.root,"SIZE +",UDim2.fromScale(0.65,0.1),UDim2.fromOffset(72,36),function() resizeSelected(4) end)
	UI.smaller.Visible=false; UI.larger.Visible=false
	UI.overlay=make("Frame",UI.root,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(23,25,35),BackgroundTransparency=0.35,BorderSizePixel=0,Visible=false})
	make("TextButton",UI.overlay,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",Modal=true,AutoButtonColor=false})
	UI.weaponPanel=make("Frame",UI.overlay,{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,8),Size=UDim2.new(0.86,0,1,-16),BackgroundTransparency=1})
	make("UISizeConstraint",UI.weaponPanel,{MaxSize=Vector2.new(1040,1400)})
	UI.title=label(UI.weaponPanel,"ZIVRA / WEAPON COLLECTION",20,UDim2.new(),UDim2.new(1,-40,0,28)); UI.title.Font=T.Bold
	UI.subtitle=label(UI.weaponPanel,"Test every weapon in the range. Keep your owned loadout for duels.",12,UDim2.fromOffset(0,30),UDim2.new(1,-40,0,22),T.Muted)
	button(UI.weaponPanel,"X",UDim2.new(1,-36,0,0),UDim2.fromOffset(36,36),function() UI.setMenu(false) end)
	UI.tabBar=make("Frame",UI.weaponPanel,{Position=UDim2.fromOffset(0,64),Size=UDim2.new(1,0,0,86),BackgroundTransparency=1})
	make("UIListLayout",UI.tabBar,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),HorizontalAlignment=Enum.HorizontalAlignment.Center})
	UI.tabs={}
	for i,name in ipairs(Weapons.Categories) do
		local b=button(UI.tabBar,"",UDim2.new(),UDim2.new(0.25,-6,1,0),function() UI.category=i; UI.rebuild() end)
		label(b,name:upper(),11,UDim2.new(0,8,1,-20),UDim2.new(1,-16,0,18)); UI.tabs[i]=b
	end
	UI.grid=make("ScrollingFrame",UI.weaponPanel,{Position=UDim2.fromOffset(0,162),Size=UDim2.new(1,0,1,-226),BackgroundTransparency=1,BorderSizePixel=0,
		CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=T.Muted,ScrollingDirection=Enum.ScrollingDirection.Y})
	UI.gridLayout=make("UIGridLayout",UI.grid,{SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
	UI.detail=label(UI.weaponPanel,"",12,UDim2.new(0,0,1,-54),UDim2.new(1,-190,0,46),T.Muted); UI.detail.TextWrapped=true
	UI.equip=button(UI.weaponPanel,"EQUIP",UDim2.new(1,-180,1,-50),UDim2.fromOffset(180,42),function()
		local id=UI.selected[UI.category] or UI.state.loadout[UI.category]
		if UI.state.mode=="Range" or UI.state.owned[id] then send("Equip",id) else UI.notice("Enter the range to try this locked item") end
	end)
	UI.options=make("ScrollingFrame",UI.overlay,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(0.82,0.88),BackgroundColor3=T.Surface,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,550),ScrollBarThickness=3,Visible=false})
	make("UISizeConstraint",UI.options,{MaxSize=Vector2.new(560,500)})
	label(UI.options,"SETTINGS",20,UDim2.fromOffset(20,16),UDim2.fromOffset(300,30)).Font=T.Bold
	button(UI.options,"X",UDim2.new(1,-52,0,12),UDim2.fromOffset(36,36),function() UI.setMenu(false) end)
	UI.qualityButton=button(UI.options,"VFX QUALITY",UDim2.fromOffset(20,64),UDim2.new(1,-40,0,40),function()
		local options={"Automatic","Low","Medium","High"}; local index=table.find(options,UI.settings.quality) or 1
		send("Settings",{quality=options[index%4+1]})
	end)
	UI.flashButton=button(UI.options,"REDUCED FLASH",UDim2.fromOffset(20,112),UDim2.new(1,-40,0,40),function() send("Settings",{reduceFlash=not UI.settings.reduceFlash}) end)
	UI.volumeLabel=label(UI.options,"",13,UDim2.fromOffset(20,168),UDim2.new(0.6,0,0,32))
	button(UI.options,"-",UDim2.new(1,-112,0,164),UDim2.fromOffset(40,36),function() send("Settings",{volume=(UI.settings.volume or 0.6)-0.1}) end)
	button(UI.options,"+",UDim2.new(1,-64,0,164),UDim2.fromOffset(40,36),function() send("Settings",{volume=(UI.settings.volume or 0.6)+0.1}) end)
	UI.sensitivityLabel=label(UI.options,"",13,UDim2.fromOffset(20,216),UDim2.new(0.6,0,0,32))
	button(UI.options,"-",UDim2.new(1,-112,0,212),UDim2.fromOffset(40,36),function() send("Settings",{sensitivity=(UI.settings.sensitivity or 1)-0.1}) end)
	button(UI.options,"+",UDim2.new(1,-64,0,212),UDim2.fromOffset(40,36),function() send("Settings",{sensitivity=(UI.settings.sensitivity or 1)+0.1}) end)
	button(UI.options,"MOVE TOUCH BUTTONS",UDim2.fromOffset(20,268),UDim2.new(1,-40,0,40),function()
		UI.setMenu(false); UI.editing=true; UI.editDone.Visible=true; UI.smaller.Visible=true; UI.larger.Visible=true; UI.touchLayer.Visible=true; UI.notice("Drag buttons, then save. Combat is paused locally.")
	end)
	button(UI.options,"RESET TOUCH LAYOUT",UDim2.fromOffset(20,316),UDim2.new(1,-40,0,40),function() UI.hudLayout={}; UI.applyLayout(); send("Settings",{hud={}}) end)
	UI.motionButton=button(UI.options,"",UDim2.fromOffset(20,366),UDim2.new(1,-40,0,44),function()
		send("Settings",{reducedMotion=not UI.settings.reducedMotion})
	end)
	UI.fovButton=button(UI.options,"",UDim2.fromOffset(20,417),UDim2.new(1,-40,0,44),function()
		local fov=UI.settings.fov or 74
		send("Settings",{fov=fov>=95 and 65 or fov+5})
	end)
	UI.sprintButton=button(UI.options,"",UDim2.fromOffset(20,468),UDim2.new(1,-40,0,44),function()
		send("Settings",{autoSprint=not UI.settings.autoSprint})
	end)
	UI.tasks=make("Frame",UI.overlay,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(0.84,0.85),BackgroundColor3=T.Surface,BorderSizePixel=0,Visible=false})
	make("UISizeConstraint",UI.tasks,{MaxSize=Vector2.new(560,360)})
	label(UI.tasks,"DAILY TASKS",20,UDim2.fromOffset(20,16),UDim2.new(1,-80,0,30)).Font=T.Bold
	button(UI.tasks,"X",UDim2.new(1,-52,0,12),UDim2.fromOffset(36,36),function() UI.setMenu(false) end)
	UI.taskRows={}
	for i,taskDef in ipairs({{"duels","Play duels",3},{"kills","Eliminations",15},{"wins","Win duels",2}}) do
		local key,title,goal=table.unpack(taskDef)
		local row=make("Frame",UI.tasks,{Position=UDim2.new(0,20,0.2+(i-1)*0.25,0),Size=UDim2.new(1,-40,0.2,0),BackgroundTransparency=1})
		local text=label(row,title,13,UDim2.new(),UDim2.new(1,-130,0,24))
		local track=make("Frame",row,{Position=UDim2.new(0,0,1,-12),Size=UDim2.new(1,-130,0,4),BackgroundColor3=T.Raised,BorderSizePixel=0})
		local fill=make("Frame",track,{Size=UDim2.fromScale(0,1),BackgroundColor3=i==1 and T.Green or T.Blue,BorderSizePixel=0})
		local claim=button(row,"100 CREDITS",UDim2.new(1,-112,0,0),UDim2.fromOffset(112,38),function() send("Claim",key) end)
		UI.taskRows[key]={label=text,fill=fill,claim=claim,title=title,goal=goal}
	end
	UI.invites=make("Frame",UI.overlay,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(0.84,0.88),BackgroundColor3=T.Surface,BorderSizePixel=0,Visible=false})
	make("UISizeConstraint",UI.invites,{MaxSize=Vector2.new(560,430)})
	label(UI.invites,"DUEL INVITATIONS",20,UDim2.fromOffset(20,16),UDim2.new(1,-80,0,30)).Font=T.Bold
	button(UI.invites,"X",UDim2.new(1,-52,0,12),UDim2.fromOffset(36,36),function() UI.setMenu(false) end)
	UI.inviteText=label(UI.invites,"Invite another player in the lobby.",13,UDim2.fromOffset(20,56),UDim2.new(1,-40,0,40),T.Muted)
	button(UI.invites,"ACCEPT",UDim2.fromOffset(20,100),UDim2.new(0.5,-24,0,36),function() send("AcceptInvite"); UI.invitationUntil=0; UI.setMenu(false) end)
	button(UI.invites,"DECLINE",UDim2.new(0.5,4,0,100),UDim2.new(0.5,-24,0,36),function() send("DeclineInvite"); UI.invitationUntil=0; UI.setMenu(false) end)
	UI.playerList=make("ScrollingFrame",UI.invites,{Position=UDim2.fromOffset(20,148),Size=UDim2.new(1,-40,1,-164),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3})
	make("UIListLayout",UI.playerList,{Padding=UDim.new(0,8)})
	UI.matchScore=label(UI.root,"",14,UDim2.new(0.5,0,0,7),UDim2.new(0.84,0,0,28),T.Text)
	UI.matchScore.AnchorPoint=Vector2.new(0.5,0)
	UI.matchScore.BackgroundColor3=T.Background
	UI.matchScore.BackgroundTransparency=0.12
	make("UISizeConstraint",UI.matchScore,{MaxSize=Vector2.new(490,28)})
	round(UI.matchScore,4)
	UI.headshot=label(UI.root,"HEADSHOT",11,UDim2.new(0.5,0,0.5,20),UDim2.fromOffset(128,24),T.Gold)
	UI.headshot.AnchorPoint=Vector2.new(0.5,0)
	UI.headshot.TextXAlignment=Enum.TextXAlignment.Center
	UI.headshot.Font=T.Bold
	UI.headshot.Visible=false
	UI.matchScore.Name="DuelScore"
	UI.matchScore.TextXAlignment=Enum.TextXAlignment.Center
	UI.matchScore.Font=T.Bold
	UI.matchScore.Visible=false
	UI.matchCard=make("Frame",UI.root,{Name="DuelCard",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.48),Size=UDim2.new(0.88,0,0,176),BackgroundColor3=T.Surface,BorderSizePixel=0,Visible=false,ZIndex=5})
	make("UISizeConstraint",UI.matchCard,{MaxSize=Vector2.new(470,176)})
	round(UI.matchCard)
	stroke(UI.matchCard)
	UI.matchTitle=label(UI.matchCard,"",26,UDim2.fromOffset(16,10),UDim2.new(1,-32,0,42),T.Text)
	UI.matchDetail=label(UI.matchCard,"",14,UDim2.fromOffset(16,53),UDim2.new(1,-32,0,60),T.Muted)
	UI.matchDetail.TextWrapped=true
	for _, item in ipairs({UI.matchTitle,UI.matchDetail}) do
		item.ZIndex=6
		item.TextXAlignment=Enum.TextXAlignment.Center
	end
	UI.rematchButton=button(UI.matchCard,"REMATCH",UDim2.new(0,12,1,-56),UDim2.new(0.5,-18,0,44),function() send("Rematch") end)
	UI.resultLobby=button(UI.matchCard,"RETURN TO LOBBY",UDim2.new(0.5,6,1,-56),UDim2.new(0.5,-18,0,44),function() send("Lobby") end)
	for _, item in ipairs({UI.rematchButton,UI.resultLobby}) do item.ZIndex=6;item.Modal=true end
	UI.initDuelLoadout(send)
	UI.flash=make("Frame",UI.root,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(130,143,158),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=50})
	UI.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(UI.resize)
	UI.grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(UI.resize)
	UI.resize(); UI.applyLayout()
end
local function weaponStats(weapon)
	if weapon.kind=="heal" then return string.format("+%d HP  ·  %.0fs use",weapon.heal,weapon.windup) end
	if weapon.kind=="melee" then return string.format("%d damage  ·  %.2fs recovery",weapon.damage,weapon.interval) end
	if weapon.pellets then return string.format("%.0f damage max  ·  %d pellets",weapon.damage*weapon.pellets,weapon.pellets) end
	return string.format("%d body  ·  %d RPM",weapon.damage,math.floor(60/weapon.interval+0.5))
end

function UI.initDuelLoadout(send)
	local backdrop=make("Frame",UI.root,{Name="PreRoundLoadout",Size=UDim2.fromScale(1,1),BackgroundColor3=T.Background,BackgroundTransparency=0.18,Visible=false,ZIndex=10})
	make("TextButton",backdrop,{Text="",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Modal=true,ZIndex=10})
	local panel=make("Frame",backdrop,{Size=UDim2.new(0.9,0,0.92,0),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),BackgroundColor3=T.Surface,BorderSizePixel=0,ZIndex=11})
	make("UISizeConstraint",panel,{MaxSize=Vector2.new(610,490)})
	round(panel)
	stroke(panel)
	local title=label(panel,"MATCH LOADOUT",20,UDim2.fromOffset(15,8),UDim2.new(1,-30,0,27),T.Text)
	title.Font=T.Bold
	title.ZIndex=12
	local status=label(panel,"",12,UDim2.fromOffset(15,37),UDim2.new(1,-30,0,18),T.Muted)
	status.ZIndex=12
	local list=make("ScrollingFrame",panel,{Position=UDim2.fromOffset(15,62),Size=UDim2.new(1,-30,1,-125),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,ZIndex=12})
	make("UIListLayout",list,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
	local confirm=button(panel,"CONFIRM LOADOUT",UDim2.new(0,15,1,-54),UDim2.new(1,-30,0,44),function()
		local duel=UI.state and UI.state.duel
		if duel and duel.phase=="Loadout" and not duel.confirmed and workspace:GetServerTimeNow()<duel.deadline then
			send("ConfirmLoadout",table.clone(UI.duelSelection))
		end
	end)
	confirm.ZIndex=12
	UI.duelLoadout={frame=backdrop,list=list,status=status,confirm=confirm,rows={}}
	for order,weapon in ipairs(Weapons.List) do
		if not Weapons.Launch[weapon.id] then continue end
		local row=button(list,"",UDim2.new(),UDim2.new(1,-10,0,48),function()
			local duel=UI.state and UI.state.duel
			if duel and duel.phase=="Loadout" and not duel.confirmed and workspace:GetServerTimeNow()<duel.deadline then
				UI.duelSelection[weapon.slot]=weapon.id
				UI.highlightDuelLoadout()
			end
		end)
		row.Name=weapon.id
		row.ZIndex=13
		row.LayoutOrder=100*weapon.slot+order
		Icons.draw(row,weapon.id,UDim2.fromOffset(8,10),UDim2.fromOffset(60,30))
		local name=label(row,weapon.name,14,UDim2.fromOffset(76,4),UDim2.new(1,-85,0,20),T.Text)
		local detail=label(row,Weapons.Categories[weapon.slot].."  ·  "..weaponStats(weapon),11,UDim2.fromOffset(76,24),UDim2.new(1,-85,0,19),T.Muted)
		name.ZIndex=14
		detail.ZIndex=14
		detail.TextTruncate=Enum.TextTruncate.AtEnd
		UI.duelLoadout.rows[weapon.id]=row
	end
end

function UI.highlightDuelLoadout()
	for id,row in pairs(UI.duelLoadout.rows) do
		local selected=UI.duelSelection[Weapons.ById[id].slot]==id
		row.UIStroke.Color=selected and T.Cyan or T.Line
		row.BackgroundColor3=selected and T.Raised or T.Surface
	end
end

function UI.update(state)
	local old=UI.state; UI.state=state; UI.settings=state.settings
	local duel=state.duel
	local active=not duel or duel.phase=="Active"
	local selecting=duel and duel.phase=="Loadout"
	UI.duelLoadout.frame.Visible=selecting==true
	if selecting then
		if not old or not old.duel or old.duel.phase~="Loadout" then
			UI.duelSelection=table.clone(duel.loadout or state.loadout)
			UI.duelLoadout.list.CanvasPosition=Vector2.zero
		elseif duel.confirmed then
			UI.duelSelection=table.clone(duel.loadout)
		end
		for id,row in pairs(UI.duelLoadout.rows) do row.Visible=state.owned[id]==true; row.Active=not duel.confirmed end
		UI.duelLoadout.confirm.Active=not duel.confirmed
		UI.duelLoadout.confirm.Text=duel.confirmed and "LOADOUT LOCKED" or "CONFIRM LOADOUT"
		UI.highlightDuelLoadout()
	end
	UI.matchScore.Visible=duel~=nil
	UI.matchCard.Visible=duel~=nil and not active and not selecting and not UI.menu
	UI.top.Text="ZIVRA  /  "..state.mode:upper()..(state.queued and " / QUEUED" or "")
	UI.currency.Text=tostring(state.currency).." CREDITS"..(state.offline and " / UNSAVED" or "")
	UI.inviteButton.Visible=state.mode=="Lobby"; UI.nav.Visible=state.mode=="Lobby"; UI.returnButton.Visible=state.mode~="Lobby" and active; UI.resetButton.Visible=state.mode=="Range"
	UI.rangeStats.Visible=state.mode=="Range"; UI.reticle.Visible=state.mode~="Lobby" and active and not UI.menu
	UI.quickbar.Visible=state.mode~="Lobby" and active; UI.touchLayer.Visible=(UIS.TouchEnabled and state.mode~="Lobby" and active or UI.editing) and not UI.menu
	local d=Weapons.ById[state.loadout[state.slot]]
	UI.ammo.Text=d.name.."  "..(d.magazine and (state.ammo[d.id] or 0).." / "..(state.reserve[d.id] or 0) or d.charges and tostring(state.charges[d.id] or 0).." USES" or "")
	if state.reloading then UI.ammo.Text..="  RELOADING" elseif state.busy>0.1 then UI.ammo.Text..="  READYING" end
	UI.reloadTrack.Visible=state.reloading==true and state.mode~="Lobby" and not UI.menu
	UI.reloadFill.Size=UDim2.fromScale(d.reload and math.clamp(1-state.busy/d.reload,0,1) or 0,1)
	if d.heatPerShot then UI.ammo.Text..=string.format("  HEAT %d%%",state.heat*100) end
	UI.ammo.TextColor3=d.magazine and (state.ammo[d.id] or 0)==0 and T.Red or T.Text
	for i,b in ipairs(UI.quick) do b.Text=i.."  "..Weapons.ById[state.loadout[i]].name; b.UIStroke.Color=i==state.slot and T.Text or T.Line end
	local rs=state.stats; local seconds=rs.started and math.max(1,state.serverTime-rs.started) or 1
	UI.rangeStats.Text=string.format("%d SHOTS   %d HITS   %.0f DAMAGE\n%.1f DAMAGE / SEC",rs.shots,rs.hits,rs.damage,rs.damage/seconds)
	UI.qualityButton.Text="VFX QUALITY  /  "..state.settings.quality:upper()
	UI.flashButton.Text="REDUCED FLASH  /  "..(state.settings.reduceFlash and "ON" or "OFF")
	UI.motionButton.Text="REDUCED MOTION  /  "..(state.settings.reducedMotion and "ON" or "OFF")
	UI.fovButton.Text="FIELD OF VIEW  /  "..tostring(state.settings.fov or 74)
	UI.sprintButton.Text="AUTO SPRINT  /  "..(state.settings.autoSprint and "ON" or "OFF")
	UI.volumeLabel.Text=string.format("VOLUME  %d%%",math.floor(state.settings.volume*100+0.5))
	UI.sensitivityLabel.Text=string.format("AIM SENSITIVITY  %.1f",state.settings.sensitivity or 1)
	if not UI.editing then UI.hudLayout=state.settings.hud or {}; UI.applyLayout() end
	local cooldown=math.max(0,(state.cooldowns[state.loadout[4]] or 0)-state.serverTime)
	UI.touch.Utility.Text=cooldown>0 and string.format("%.1fs",cooldown) or "UTILITY"
	for key,row in pairs(UI.taskRows) do
		local value=state.daily[key]; row.label.Text=row.title.."  "..math.min(value,row.goal).." / "..row.goal
		row.fill.Size=UDim2.fromScale(math.min(1,value/row.goal),1); row.claim.Text=state.daily.claimed[key] and "CLAIMED" or "100 CREDITS"
		row.claim.TextColor3=value>=row.goal and T.Gold or T.Muted
	end
	for i,b in ipairs(UI.tabs) do
		local previous=UI.tabPreviews[i]
		if not previous or previous.id~=state.loadout[i] then
			if previous then previous.frame:Destroy() end
			UI.tabPreviews[i]={id=state.loadout[i],frame=viewport(b,Weapons.ById[state.loadout[i]],UDim2.fromScale(0.12,0),UDim2.fromScale(0.76,0.7))}
		end
	end
	local changed=not old or old.mode~=state.mode
	if old then for i=1,4 do if old.loadout[i]~=state.loadout[i] then changed=true end end end
	if UI.menu and UI.weaponPanel.Visible and changed then UI.rebuild() end
	if state.message then
        UI.notice(state.message)
        if state.message=="Elimination +10" then UI.hitUntil=os.clock()+0.4;UI.hit.TextColor3=T.Gold end
    end
end
function UI.showDamage(from)
 if typeof(from)~="Vector3" then return end
 UI.damageFrom=from;UI.damageUntil=os.clock()+0.7
end
function UI.showHit(headshot)
	UI.hitUntil=os.clock()+0.16
	UI.hit.TextColor3=headshot and T.Gold or T.Text
	UI.headshotUntil=headshot and os.clock()+0.42 or UI.headshotUntil
end
local function updateMatch(duel)
	local count=math.max(0,math.ceil(duel.deadline-workspace:GetServerTimeNow()))
	local timer=duel.phase=="Active" and string.format("  %d:%02d",math.floor(count/60),count%60) or ""
	UI.matchScore.Text=string.format("%s  %d / %d  %s%s",duel.name,duel.score,duel.opponentScore,duel.opponent,timer)
	UI.rematchButton.Visible=duel.phase=="Result" and duel.rematchAllowed==true
	UI.resultLobby.Visible=duel.phase=="Result"
	UI.resultLobby.Position=UDim2.new(UI.rematchButton.Visible and 0.5 or 0.25,6,1,-56)
	UI.rematchButton.Text=duel.rematch and "WAITING FOR OPPONENT" or "REMATCH"
	if duel.phase=="Versus" then
		UI.matchTitle.Text="ZIVRA ARENA"
		UI.matchDetail.Text=duel.name.."  VS  "..duel.opponent
	elseif duel.phase=="Loadout" then
		UI.duelLoadout.status.Text=string.format("%ds  ·  %s",count,duel.opponentConfirmed and "OPPONENT READY" or "SELECT YOUR EQUIPMENT")
	elseif duel.phase=="Countdown" then
		UI.matchTitle.Text=tostring(math.max(1,count))
		UI.matchDetail.Text=string.format("ROUND %d",duel.round)
	elseif duel.phase=="RoundEnd" then
		UI.matchTitle.Text=duel.roundDecided and (duel.roundWon and "ROUND WON" or "ROUND LOST") or "ROUND DRAW"
		UI.matchDetail.Text=duel.reason or ""
	elseif duel.phase=="Result" then
		UI.matchTitle.Text=duel.decided and (duel.won and "VICTORY" or "DEFEAT") or (duel.reason=="Draw limit" and "DRAW" or "DUEL ENDED")
		UI.matchDetail.Text=string.format("%d / %d   ·   %d ELIMINATIONS\n%s",duel.score,duel.opponentScore,duel.eliminations,duel.reason or "")
	end
	UI.matchTitle.TextColor3=duel.phase=="Result" and duel.decided and (duel.won and T.Cyan or T.Red) or T.Text
end
function UI.step(humanoid,spread)
 if UI.state and UI.state.duel then updateMatch(UI.state.duel) end
 UI.damageDirection.Visible=not UI.menu and UI.state and UI.state.mode~="Lobby" and os.clock()<(UI.damageUntil or 0) or false
 if UI.damageDirection.Visible then
  local cam=workspace.CurrentCamera
  local direction=cam.CFrame:VectorToObjectSpace(UI.damageFrom-cam.CFrame.Position)
  UI.damageDirection.Rotation=math.deg(math.atan2(direction.X,-direction.Z))
 end
	if humanoid then
		local ratio=humanoid.Health/math.max(1,humanoid.MaxHealth)
		UI.healthFill.Size=UI.healthFill.Size:Lerp(UDim2.fromScale(ratio,1),0.15)
		UI.healthFill.BackgroundColor3=ratio>0.5 and T.Green or ratio>0.25 and T.Gold or T.Red
		UI.healthText.Text=tostring(math.ceil(humanoid.Health))
	end
	UI.cross[1].Position=UDim2.fromOffset(-spread,0); UI.cross[2].Position=UDim2.fromOffset(spread,0)
	UI.cross[3].Position=UDim2.fromOffset(0,-spread); UI.cross[4].Position=UDim2.fromOffset(0,spread)
	UI.toast.Visible=os.clock()<(UI.toastUntil or 0)
	UI.hit.Visible=not UI.menu and os.clock()<(UI.hitUntil or 0)
	UI.headshot.Visible=not UI.menu and os.clock()<(UI.headshotUntil or 0)
    UI.hit.TextTransparency=math.clamp(1-((UI.hitUntil or 0)-os.clock())/0.13,0,1)
	if UI.invitationUntil and os.clock()>=UI.invitationUntil then UI.inviteText.Text="Invite another player in the lobby."; UI.invitationUntil=nil end
end
function UI.flashScreen(intensity,duration)
	UI.flash.BackgroundTransparency=1-math.clamp(intensity,0,1)*(UI.settings.reduceFlash and 0.25 or 0.65)
	TweenService:Create(UI.flash,TweenInfo.new(duration),{BackgroundTransparency=1}):Play()
end
return UI
