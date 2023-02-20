sky = love.graphics.newShader[[
const float weight[10] = float[] (0.1845, 0.1790, 0.1624, 0.1384, 0.1125, 0.0849, 0.0590, 0.0406, 0.0240, 0.0148);
extern vec2 image_size;
extern bool horizontal;  
  
vec4 effect(vec4 color, Image image, vec2 texture_coords, vec2 _) {
  vec2 tex_offset = 1.0 / image_size;
  vec3 result = Texel(image, texture_coords).rgb * weight[0];
  
  if(horizontal) {
    for(int i = 1; i < 10; ++i) {
    result += Texel(image, texture_coords + vec2(tex_offset.x * i, 0.0)).rgb * weight[i] / 2; //Pixels to the right
    result += Texel(image, texture_coords - vec2(tex_offset.x * i, 0.0)).rgb * weight[i] / 2; //Pixels to the left
    }
  }else {
    for(int i = 1; i < 10; i++) {
    result += Texel(image, texture_coords + vec2(0.0, tex_offset.y * i)).rgb * weight[i] / 2; //Pixels to the down
    result += Texel(image, texture_coords - vec2(0.0, tex_offset.y * i)).rgb * weight[i] / 2; //Pixels to the up
    }
  }  
  if( color.a == 0) {discard;}
  return vec4(result, 1.0);
}
]]