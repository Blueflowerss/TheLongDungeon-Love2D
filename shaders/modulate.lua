modulate = love.graphics.newShader[[
    extern number r;
    extern number g;
    extern number b;
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
      vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
      
      pixel.r *= r;
      pixel.g *= g;
      pixel.b *= b;
      return pixel;
    }
]]