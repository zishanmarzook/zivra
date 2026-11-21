local M={}
function M.Horizontal(v) return Vector3.new(v.X,0,v.Z) end
function M.Approach(a,b,d) return a+math.clamp(b-a,-d,d) end
function M.Alpha(rate,dt) return 1-math.exp(-rate*math.min(dt,0.1)) end
function M.Finite(v)
 return typeof(v)=='Vector3' and v.X==v.X and v.Y==v.Y and v.Z==v.Z and math.max(math.abs(v.X),math.abs(v.Y),math.abs(v.Z))<1e6
end
function M.SlideSpeed(c,elapsed) return c.SlideSpeed+(c.SlideEndSpeed-c.SlideSpeed)*math.clamp(elapsed/c.SlideDuration,0,1) end
return M