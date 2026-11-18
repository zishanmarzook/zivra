-- Original silhouettes. Runs of equal-color pixels share one UI rectangle.
local Icons = {}
local colors = {
	K = Color3.fromRGB(16, 23, 30),
	D = Color3.fromRGB(63, 77, 86),
	S = Color3.fromRGB(172, 191, 198),
	T = Color3.fromRGB(190, 142, 78),
	C = Color3.fromRGB(88, 182, 192),
	W = Color3.fromRGB(222, 231, 233),
	R = Color3.fromRGB(215, 85, 86),
}
local sprites = {
	assault_rifle = {
		"......KKKK..........",
		".....KCCCK..........",
		"KKKKKKKKKKKKKK......",
		"KDDKTTTTTTDDDDKKKKKK",
		"KKKKTTTTTTTKKKSSSSSK",
		"...KKKDKKKK...KKKKKK",
		".....KDK.KDK........",
		".....KK..KDK........",
		".........KKK........",
	},
	sniper_rifle = {
		".......KKKKKK.......",
		"......KCSCCCCK......",
		".......KKKKKK.......",
		"KKKKKKKKKKKKKKKKKKKK",
		"KDSKSSSSDDDSSSSSSSSK",
		"KKKKSCCDKKKKKKKKKKKK",
		"....KDK.KDK.........",
		"....KK..KKK.........",
	},
	shotgun = {
		".............KK.....",
		"KKKKKKKKKKKKKKKKKKKK",
		"KTTKKSSSSDDDDSSSSSSK",
		"KKKKTSSSSKTTTTTKKKKK",
		"...KKDKKKKKKKKK.....",
		"....KDK.............",
		"....KKK.............",
	},
	revolver = {
		"......KKKK..........",
		".....KSSSSKKKKKKK...",
		"....KDSSSDSSSSSSK...",
		"...KDKSSSKKKKKKKK...",
		"..KTTKKKKK..........",
		"..KTTK..............",
		"..KKKK..............",
	},
	handgun = {
		"..............KK....",
		"....KKKKKKKKKKKKK...",
		"....KSSSSSSSSSSSK...",
		"....KDDCCDDDDDDDK...",
		"....KDDDKKKKKKKKK...",
		"...KDDDK............",
		"...KDDDK............",
		"...KKKKK............",
	},
	knife = {
		"..............KKK...",
		"...........KKKSSK...",
		"....KKKKKKKSSSSK....",
		"..KKDDDDKSSSSKK.....",
		"..KDDDDDKKKKK.......",
		"..KKKKKKK...........",
	},
	medkit = {
		".......KKKKKK.......",
		"......KDKKKKDK......",
		"....KKKKKKKKKKKK....",
		"...KWWWWRRWWWWWWK...",
		"...KWWRRRRRRWWWWK...",
		"...KWWRRRRRRWWWWK...",
		"...KWWWWRRWWWWWWK...",
		"...KWWWWWWWWWWWWK...",
		"....KKKKKKKKKKKK....",
	},
}

function Icons.draw(parent, id, position, size)
	local rows = sprites[id]
	if not rows then return end
	local canvas = Instance.new("Frame")
	canvas.BackgroundTransparency = 1
	canvas.Position = position
	canvas.Size = size
	canvas.ZIndex = parent.ZIndex
	canvas.Parent = parent
	for y, row in ipairs(rows) do
		local x = 1
		while x <= #row do
			local code = row:sub(x, x)
			local nextX = x + 1
			while nextX <= #row and row:sub(nextX, nextX) == code do nextX += 1 end
			local color = colors[code]
			if color then
				local run = Instance.new("Frame")
				run.BorderSizePixel = 0
				run.BackgroundColor3 = color
				run.Position = UDim2.fromScale((x-1)/20, (y-1)/10)
				run.Size = UDim2.fromScale((nextX-x)/20, 1/10)
				run.ZIndex = parent.ZIndex + 1
				run.Parent = canvas
			end
			x = nextX
		end
	end
end

return Icons
