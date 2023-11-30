#version 330
in vec2 texcoord;             // texture coordinate of the fragment

#define TWO_PI 6.28318530718
uniform float time;
uniform sampler2D tex;        // texture of the window
float border_size = 5;
float offset = 0; // x+y offset of the border. pretty ugly and useless
float top_border_ratio =1.; //make the top border a bit bigger -- useless
float rainbow_freq = 2;  // frequency per revolution around the window of the color generating sine wave.
vec3 saturation =vec3(0.8); // the max brightness value of the border colour
vec3 clr_brightness =vec3(0.3); //the lowest brightness value of the border colour
float time_slow = -time/13000; // amount to slow down the movement of the color border.



ivec2 full_screen = ivec2(1920,1080);

//vec4 glow_color

vec4 default_post_processing(vec4 border_color);
ivec2 window_size = textureSize(tex, 0);


// define border on window coordinates
vec4 border = vec4( 
		border_size + offset,  					// .x = left border 
		window_size.x -border_size + offset, 			// .y = right border
		(border_size+offset)*top_border_ratio,			// .z = top border
		window_size.y -border_size + offset			// .w = bottom border

);
 // check if given pixel coordinates are inside border.   
float border_check(in vec2 texcoord, in vec4 border) {
  
float is_border =  step(1,1-step(border.x, texcoord.x) 
		     +step(border.y, texcoord.x)
		     +1-step(border.z, texcoord.y)
		     +step(border.w, texcoord.y))
;
return float (is_border);
}

//percentage value of coordinates
vec2 coord_pct = texcoord/window_size;

//convert coordinates to polar coordinates
  vec2 toCenter = vec2(0.5)-coord_pct;
    float angle = atan(toCenter.y,toCenter.x);
    float radius = length(toCenter)*2.0;





////displace rgb values in a three phase sine depending on the distance from polar axis, and displace phase of all sines depending on time.

vec3 rgb_sine ( in vec3 c ){
		float red_sine =0.5+ 0.5* sin(((2.*3.14)/1.* (c.x + c.z)));
		float green_sine =0.5+ 0.5* sin(((2.*3.14)/1. * (c.x + 1.3333 + c.z)));
		float blue_sine =0.5+ 0.5*  sin(((2.*3.14)/1. * (c.x+ 2.6667 + c.z)));
   		 vec3 d =vec3(red_sine, green_sine,blue_sine);
    return vec3 (vec3(red_sine, green_sine,blue_sine));
}








//determine color of pixel inside border
vec3 border_color = mix(clr_brightness, saturation, vec3(rgb_sine(vec3((angle/TWO_PI)*rainbow_freq, radius,time_slow))
			 ));





//find pixel distance from border start.

float border_distance =min(
   min(texcoord.x -border.x, border.y - texcoord.x),
   min(texcoord.y - border.z, border.w - texcoord.y));
// percentage value of pixel between border start and window edge


float border_normalized = length(border_distance) / border_size; 



float is_border = border_check(texcoord, border);


//find alpha value for border pixel, +1depending on pixels distance from border start
float border_fade= mix(0, 1 , sqrt(border_normalized));


// Default window shader:
// 1) fetch the specified pixel
// 2) apply default post-processing



vec4 window_shader() {

//check if window is full screened.
float is_fullscreen = step(2, step(full_screen.x,window_size.x)+ step(full_screen.y,window_size.y));

  
  
vec4 c = texelFetch(tex, ivec2(texcoord), 0);

  
//draw window pixel, or border pixel, depending on wether the pixel is inside border, and not fullscreened.    
vec4 a = mix(vec4(c.r,c.g,c.b,1),

vec4(vec3(border_color)*1-border_normalized,1-border_fade),1- step(1,1-is_border+is_fullscreen));
    	     
    return default_post_processing(a);

   
 }  
