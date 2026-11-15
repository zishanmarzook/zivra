-- Deliberately small test double: lifecycle tests, NOT Roblox geometry/physics validation.
local clock=10
local delayed={}
local realTypeof=typeof
local os={clock=function() return clock end}
local task={delay=function(seconds,fn) table.insert(delayed,{at=clock+seconds,fn=fn}) end}
local function advance(seconds)
	clock+=seconds
	local due=delayed; delayed={}
	for _,x in ipairs(due) do if x.at<=clock then x.fn() else table.insert(delayed,x) end end
end
local vectorMT={}
local Vector3={}
function Vector3.new(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0,_type="Vector3"},vectorMT) end
function vectorMT.__add(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
function vectorMT.__sub(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
function vectorMT.__mul(a,b) return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
function vectorMT.__index(a,k)
	if k=="Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
	if k=="Unit" then return a*(1/a.Magnitude) end
	if k=="Dot" then return function(a,b) return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
end
Vector3.zero=Vector3.new()
local function typeof(x) return type(x)=="table" and x._type or realTypeof(x) end
local cfMT={__mul=function(a,b) return a end}
local CFrame={lookAt=function(a,b) return setmetatable({LookVector=(b-a).Unit},cfMT) end,Angles=function() return {} end}
local Enum={RaycastFilterType={Exclude=1},Material={Air=1}}
local RaycastParams={new=function() return {} end}
local Random={new=function() return {NextNumber=function() return 0.5 end} end}
local workspace={Raycast=function() return nil end}
local Players={GetPlayers=function() return {} end,GetPlayerFromCharacter=function() return nil end}
local game={GetService=function(_,name) return name=="Players" and Players or {} end}
local script={Parent={HeldModels={}}}
local Held={equip=function() end}
local W=require("../src/shared/Weapons")
local R=require("../src/shared/Rules")
