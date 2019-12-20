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
	vec4 mainColor = texture(mainTex, fsTex.xy);
	target = mainColor;
	target.xyz = target.xyz * (1.0f + objectGlow * 0.6f);
	target.a = min(1, target.a + target.a * objectGlow * 0.4);
}