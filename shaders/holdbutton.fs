#version 330
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;

uniform sampler2D mainTex;
uniform float objectGlow;

// 20Hz flickering. 0 = Miss, 1 = Inactive, 2 & 3 = Active alternating.
uniform int hitState;

void main()
{
	float s = float(hitState);
	vec4 color = texture(mainTex, vec2(fsTex.x, s / 4 + fsTex.y / 4));
	target = color;
}