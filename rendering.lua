function generateVisible()
  local tw,th      = 8,8
  local px,py      = 1,1
  local radius     = 20
  local radius_type= 'square'
  local perm       = 5
  local angle      = 0
  local angle_size = 360
  local delta      = 5
  local width      = 800
  local height     = 800
  local player = global.multiverse[global.currentUniverse].actors[global.currentActor]
  local collisionMap = global.multiverse[global.currentUniverse].collisionMap
  visible = {}
	
local isTransparent = function(x,y)
    local position = vector(x,y,player.position.z):__tostring()
    local blocked = false
    if collisionMap[position] then
      for _,object in pairs(collisionMap[position]) do
        if object.flags["blocks"] then
          blocked = true
        end
      end
      if blocked then 
      else
        return true
      end
    else
      return true
    end
	end
	
	local onVisible = function(x,y)
		local dx,dy = x-px,y-py
		if (dx*dx + dy*dy) > radius*radius + radius and radius_type == 'circle' then 
			return 
		end
		
		visible[vector(x,y,player.position.z):__tostring()]    = visible[vector(x,y,player.position.z):__tostring()] or {}
		visible[vector(x,y,player.position.z):__tostring()] = 1
	end
		
	fov(player.position.x,player.position.y,radius,isTransparent,onVisible,math.rad(angle-angle_size/2),math.rad(angle+angle_size/2),perm)

end
colors = {}
colors.BLUESKY = {25,178,255}