#version 330
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;

uniform sampler2D mainTex;
uniform vec4 color;

void main()
{
	float alpha = texelFetch(mainTex, ivec2(fsTex), 0).a;
	target = vec4(color.xyz, alpha * color.a);
}