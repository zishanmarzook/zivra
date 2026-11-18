-- Server validation owns permission to sprint/slide; client predicts immediately.
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local Shared=game.ReplicatedStorage:WaitForChild('ZIVRAMovement')
local C=require(Shared.Config);local M=require(Shared.MotionMath)
local Remote=Shared.Request
local records={}
local launch=require(game.ReplicatedStorage.ZIVRA.Config).Launch1v1
local function active(player)
 local mode=player:GetAttribute('ZIVRACombatMode') or 'Lobby'
 return mode=='Duel' and player:GetAttribute('ZIVRADuelPhase')=='Active' or not launch and mode=='Lobby'
end
local allowed={Walk=true,Sprint=true,Crouch=true,Slide=true,SlideJump=true,EndSlide=true}
local function bind(player,character)
 local h=character:WaitForChild('Humanoid',10);local root=character:WaitForChild('HumanoidRootPart',10)
 if not h or not root or player.Character~=character then return end
 if h.RigType~=Enum.HumanoidRigType.R15 then character:SetAttribute('ZIVRAMovementSupported',false);return end
 if not h:FindFirstChildOfClass('Animator') then Instance.new('Animator',h) end
 character:SetAttribute('ZIVRAMovementSupported',true)
 character:SetAttribute('ZIVRAMovement','Idle')
 h.UseJumpPower=true;h.JumpPower=C.JumpPower
 records[player]={character=character,h=h,root=root,intent='Walk',slideEnd=0,lastSlide=-math.huge,lastRequest=0,tokens=24,sequence=0,airUntil=0,spawn=os.clock(),lastPosition=root.Position,travel=0,window=0}
 h.Died:Connect(function() if records[player] and records[player].character==character then records[player]=nil end end)
end
local function added(p)
 p.CharacterAdded:Connect(function(c) task.spawn(bind,p,c) end)
 if p.Character then task.spawn(bind,p,p.Character) end
end
Players.PlayerAdded:Connect(added);Players.PlayerRemoving:Connect(function(p) records[p]=nil end)
for _,p in Players:GetPlayers() do added(p) end
Remote.OnServerEvent:Connect(function(player,action,sequence,direction)
 if not active(player) then return end
 local s=records[player];if not s or not allowed[action] then return end
 local now=os.clock()
 s.tokens=math.min(24,s.tokens+(now-s.lastRequest)*14);s.lastRequest=now
 if s.tokens<1 then return end;s.tokens-=1
 if type(sequence)~='number' or sequence~=sequence or sequence%1~=0 or sequence<=s.sequence or sequence>s.sequence+1000 then return end
 s.sequence=sequence
 local h,root=s.h,s.root
 if h.Health<=0 or h.Sit or root.Anchored then return end
 local grounded=h.FloorMaterial~=Enum.Material.Air
 local accepted=true
 if action=='Slide' then
  accepted=s.intent=='Sprint' and grounded and M.Horizontal(root.AssemblyLinearVelocity).Magnitude>=C.WalkSpeed*0.65 and now-s.lastSlide>=C.SlideCooldown and M.Finite(direction) and math.abs(direction.Y)<0.1 and direction.Magnitude>0.9 and direction.Magnitude<1.1
  if accepted then
   s.slideEnd=now+C.SlideDuration;s.lastSlide=now
   s.slideDirection=M.Horizontal(direction).Unit
  end
 elseif action=='SlideJump' then
  accepted=s.slideEnd>now and grounded
  if accepted then s.slideEnd=0;s.airUntil=now+1.4 end
 elseif action=='EndSlide' then s.slideEnd=0
 else s.intent=action end
 if action=='Slide' or action=='SlideJump' then Remote:FireClient(player,sequence,accepted) end
end)
local accumulator=0
RunService.Heartbeat:Connect(function(dt)
 accumulator+=dt;if accumulator<0.1 then return end
 local elapsed=accumulator;accumulator=0;local now=os.clock()
 for player,s in pairs(records) do
  local h,root=s.h,s.root
  if not active(player) then
   s.lastPosition=root.Position;s.window=0;s.travel=0;s.slideEnd=0;s.intent='Walk';s.airUntil=0
   if h.Parent and player:GetAttribute('ZIVRACombatMode')=='Lobby' then h.WalkSpeed=C.WalkSpeed end
   s.character:SetAttribute('ZIVRAMovement','Idle')
   continue
  end
  if not root.Parent or player.Character~=s.character then records[player]=nil;continue end
  local traversal=s.character:GetAttribute('ZIVRATraversing')
  if traversal then s.character:SetAttribute('ZIVRAMovement',traversal);s.lastPosition=root.Position;continue end
  local state=h:GetState()
  if h.Sit or root.Anchored or state==Enum.HumanoidStateType.Swimming or state==Enum.HumanoidStateType.Climbing or state==Enum.HumanoidStateType.Physics then
   s.slideEnd=0;s.lastPosition=root.Position;s.window=0;s.travel=0;continue
  end
  local slide=s.slideEnd>now
  local maxSpeed=slide and C.SlideSpeed or s.airUntil>now and C.AirSpeedCap or s.intent=='Sprint' and C.SprintSpeed or s.intent=='Crouch' and C.CrouchSpeed or C.WalkSpeed
  local velocity=root.AssemblyLinearVelocity;local flat=M.Horizontal(velocity)
  local platformAllowance=0
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={s.character};params.RespectCanCollide=true
  local floor=workspace:Raycast(root.Position,Vector3.new(0,-6,0),params)
  if floor then platformAllowance=M.Horizontal(floor.Instance.AssemblyLinearVelocity).Magnitude end
  -- Bounded correction with grace for moving platforms, spawn and external knockback.
  local exempt=(s.character:GetAttribute('ZIVRAMovementExemptUntil') or 0)>workspace:GetServerTimeNow()
  if now-s.spawn>2 and not exempt and flat.Magnitude>maxSpeed+platformAllowance+12 then
   root.AssemblyLinearVelocity=flat.Unit*(maxSpeed+platformAllowance)+Vector3.new(0,velocity.Y,0)
  end
  local delta=M.Horizontal(root.Position-s.lastPosition).Magnitude
  s.travel+=delta;s.window+=elapsed
  if s.window>=1 then
   if not exempt and now-s.spawn>3 and s.travel>(C.SlideSpeed+platformAllowance+18)*s.window then
    root.CFrame=CFrame.new(s.lastPosition)*root.CFrame.Rotation
    root.AssemblyLinearVelocity=Vector3.zero
   end
   s.window=0;s.travel=0
  end
  s.lastPosition=root.Position
  h.WalkSpeed=slide and C.SlideEndSpeed or s.intent=='Sprint' and C.SprintSpeed or s.intent=='Crouch' and C.CrouchSpeed or C.WalkSpeed
  local grounded=h.FloorMaterial~=Enum.Material.Air
  local visual=slide and 'Slide' or not grounded and (velocity.Y>1 and 'Jump' or 'Fall') or s.intent=='Crouch' and (flat.Magnitude>1 and 'CrouchWalk' or 'Crouch') or flat.Magnitude<1 and 'Idle' or s.intent=='Sprint' and 'Sprint' or 'Walk'
  s.character:SetAttribute('ZIVRAMovement',visual)
 end
end)