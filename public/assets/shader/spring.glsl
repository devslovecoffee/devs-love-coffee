#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

uniform float u_progress;

vec3 circle(in vec3 _center, in float _radius, in float _thickness){
    float d = length( _center );
    return vec3(
    smoothstep(
        _radius+_thickness,
        pow(d, 2.),
        _radius-_thickness
    )
    )
    +
    vec3(
    smoothstep(
        _radius-_thickness,
        pow(d, 2.),
        _radius+_thickness
    )
    );
}

void main(){
    vec2 st = gl_FragCoord.xy / u_resolution.xy;

    vec3 c = vec3(abs(st) - 0.5, 0.38);
    float thickness = .01;
    float tB = 1.2;
    float tD = 0.03;

    vec3 kr = circle(c, (u_progress / (tB - tD)), thickness);
    vec3 kg = circle(c, (u_progress / tB), thickness);
    vec3 kb = circle(c, (u_progress / (tB+tD)), thickness);

    vec3 col = vec3(kr.r, kg.g, kb.b);

    gl_FragColor = vec4(col, 1.);
}
