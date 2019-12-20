#version 330
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;

uniform sampler2D mainTex;
uniform vec4 lCol;
uniform vec4 rCol;
uniform float hidden;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{	
	vec4 mainColor = texture(mainTex, vec2(fsTex.x, 0.01 + fsTex.y * 0.8));
	vec4 tintColor = texture(mainTex, vec2(fsTex.x, 0.51 + fsTex.y * 0.8));
    
    vec3 col = vec3(0);
    float hueOffset = tintColor.g * 0.1;

    col += lCol.rgb * tintColor.b;
    col += rCol.rgb * tintColor.r;

    vec3 colHsv = rgb2hsv(col);
    colHsv.r -= hueOffset;

    mainColor.rgb += hsv2rgb(colHsv);
    mainColor.a += tintColor.a;

    target = mainColor;
}