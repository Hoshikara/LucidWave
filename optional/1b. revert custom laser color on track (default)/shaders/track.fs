#version 330
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 fsTex;
layout(location=0) out vec4 target;

uniform sampler2D mainTex;
uniform vec4 lCol;
uniform vec4 rCol;
uniform float hidden;

void main()
{	
	vec4 mainColor = texture(mainTex, fsTex.xy);
    vec4 col = mainColor;

    if(fsTex.y > hidden * 1.0)
    {
    }
    else
    {
        col.xyz = vec3(0.);
        col.a = col.a > 0.0 ? 0.3 : 0.0;
    }
    target = col;
}