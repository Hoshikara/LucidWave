#version 330
#extension GL_ARB_separate_shader_objects : enable
layout(location=0) in vec3 inPos;
layout(location=1) in vec4 inColor;
layout(location=2) in vec4 inParams;

out gl_PerVertex
{
	vec4 gl_Position;
};
layout(location=1) out vec4 fsColor;
layout(location=2) out vec4 fsParams;

void main()
{
	fsColor = inColor;
	fsParams = inParams;
	gl_Position = vec4(inPos,1);
}