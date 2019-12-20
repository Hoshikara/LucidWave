#version 330
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;

uniform sampler2D frame;
uniform sampler2D jacket;
uniform float time;
uniform float selected;

void main()
{
	vec4 jacket = texture(jacket, fsTex);
	vec4 frame = texture(frame, fsTex);
	float a = max(max(frame.x, frame.y), frame.z);
	float pulse = cos(time*2) * 0.25 + 0.25;
	a = a * 0.5 + pulse * selected;
	target = jacket * (0.3f + 0.7f * selected) * (1-a) + frame * a;
	target.a = frame.a;
}