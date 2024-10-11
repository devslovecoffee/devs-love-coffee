#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

vec3 circle(in vec3 _center, in float _radius, in float _thickness){
    float d = length( _center );
    return vec3(smoothstep(_radius+_thickness, d, _radius-_thickness))
    +
    vec3(smoothstep(_radius-_thickness, d, _radius+_thickness));
}

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    vec3 c = vec3(abs(st)-0.5, 0.3);
    float abSin =  abs(sin(u_time));
    float thickness = .01;
    float tB = 2.;
    float tD = 0.04;
    vec3 kr = circle(c, (abSin / (tB-tD)), thickness);
    vec3 kg = circle(c, (abSin / tB), thickness);
    vec3 kb = circle(c, (abSin / (tB+tD)), thickness);
    vec3 col = vec3(kr.r, kg.g, kb.b);
    gl_FragColor = vec4(col, 1);
}
