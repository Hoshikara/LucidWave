#version 330
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 texVp;
layout(location=0) out vec4 target;

uniform ivec2 screenCenter;
// x = bar time
// y = object glow
// z = real time since song start
uniform vec3 timing;
uniform ivec2 viewport;
uniform float objectGlow;
// bg_texture.png
uniform sampler2D mainTex;
uniform sampler2D fb_tex;
uniform float tilt;
uniform float clearTransition;

#define PI 3.14159265359
#define TWO_PI 6.28318530718


float gapWidth = 0.6;
float boost = 2;
float post_boost = 3;
float boost_exponent = 1.3;
float scan_curve = 0.8;
float lines = 320;
vec2 blue_green_shift = vec2(0.0005 , 0.0);
void main()
{
    //target = vec4(0);
    //return;
    vec2 uv = vec2(texVp) / viewport;
    uv.y = 1.0 - uv.y;
    float scanline = (0.5 * sin(uv.y * TWO_PI * lines) + 0.5 - gapWidth) / (2.0 - gapWidth);
    scanline = max(0., scanline);
    scanline = pow(scanline, scan_curve);
    target.r = texture(fb_tex, uv).r * scanline * (1.0 + boost);
    target.g = texture(fb_tex, uv - blue_green_shift).g * scanline * (1.0 + boost);
    target.b = texture(fb_tex, uv + blue_green_shift).b * scanline * (1.0 + boost);
    target.r = pow(target.r, boost_exponent);
    target.g = pow(target.g, boost_exponent);
    target.b = pow(target.b, boost_exponent);
    target *= post_boost;

    target.a = 1.0;
}
