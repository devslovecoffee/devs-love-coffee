#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

vec3 circle(in vec3 _center, in float _radius, in float _thickness){
    float d = length( _center );
    return vec3( step(_radius-_thickness,d) * step(d,_radius + _thickness));
}

vec3 smoothCircle(in vec3 _center, in float _radius, in float _thickness){
    float d = length( _center );
    return vec3(smoothstep(_radius+_thickness, d, _radius-_thickness))
    +
    vec3(smoothstep(_radius-_thickness, d, _radius+_thickness));
}

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    vec3 c = vec3(abs(st)-0.5, 0.3);
    float thickness = .01;
    float tB = 2.3;
    float tD = 0.03;

    float abSin = abs(sin(u_time / 2.));

    vec3 kr = circle(c, (1. / (tB-tD)), thickness);
    vec3 kg = circle(c, (1. / tB), thickness);
    vec3 kb = circle(c, (1. / (tB+tD)), thickness);
    vec3 col = vec3(kr.r, kg.g, kb.b);

    vec3 skr = smoothCircle(c, (1. / (tB-tD)), thickness);
    vec3 skg = smoothCircle(c, (1. / tB), thickness);
    vec3 skb = smoothCircle(c, (1. / (tB+tD)), thickness);
    vec3 scol = vec3(skr.r, skg.g, skb.b);

    vec3 finalCol = mix(col, scol, abSin);

    gl_FragColor = vec4(finalCol, 1.);
}
