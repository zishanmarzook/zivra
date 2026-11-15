local Tween=game:GetService('TweenService')
local T=require(game.ReplicatedStorage.ZIVRA.Theme)
local U={Colors={BG=T.Background,Panel=T.Surface,Raised=T.Raised,Accent=T.Blue,Cyan=T.Cyan,Text=T.Text,White=T.Text,Muted=T.Muted}}

function U.Frame(parent,name,size,pos,color)
 local f=Instance.new('Frame');f.Name=name;f.Size=size;f.Position=pos or UDim2.new();f.BackgroundColor3=color or U.Colors.Panel;f.BorderSizePixel=0;f.Parent=parent;return f
end
function U.Text(parent,text,size,pos,fontSize,color)
 local t=Instance.new('TextLabel');t.Size=size;t.Position=pos or UDim2.new();t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color or U.Colors.Text;t.TextSize=fontSize or 15;t.Font=Enum.Font.Gotham;t.TextXAlignment=Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.TextWrapped=true;t.Parent=parent;return t
end
function U.Button(parent,text,size,pos,callback,primary)
 local b=Instance.new('TextButton');b.Name=text;b.Text=text;b.Size=size;b.Position=pos or UDim2.new();b.BackgroundColor3=primary and U.Colors.Accent or U.Colors.Raised;b.BorderSizePixel=0;b.TextColor3=U.Colors.Text;b.Font=Enum.Font.GothamBold;b.TextSize=14;b.TextWrapped=true;b.AutoButtonColor=false;b.Selectable=true;b.Parent=parent
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,T.Radius);corner.Parent=b
 local outline=Instance.new('UIStroke');outline.Color=U.Colors.Cyan;outline.Transparency=1;outline.Parent=b
 local function highlight(on) Tween:Create(outline,TweenInfo.new(T.Transition),{Transparency=on and 0.1 or 1}):Play() end
 b.MouseEnter:Connect(function() highlight(true) end);b.MouseLeave:Connect(function() highlight(false) end)
 b.SelectionGained:Connect(function() highlight(true) end);b.SelectionLost:Connect(function() highlight(false) end)
 b.Activated:Connect(callback);return b
end
function U.List(parent)
 local s=Instance.new('ScrollingFrame');s.Name='Content';s.BackgroundTransparency=1;s.BorderSizePixel=0;s.Size=UDim2.fromScale(1,1);s.ScrollBarThickness=4;s.AutomaticCanvasSize=Enum.AutomaticSize.Y;s.CanvasSize=UDim2.new();s.Parent=parent
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,9);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=s
 local pad=Instance.new('UIPadding');pad.PaddingRight=UDim.new(0,8);pad.Parent=s
 return s
end
return U