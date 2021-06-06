// Author: Nikolai V. Chr.
// License: GPL v2
#version 120

varying vec3    VNormal;
varying vec3    eyeVec;

uniform sampler2D BaseTex;
uniform sampler2D dust_texture;
uniform float dirt_factor;
uniform float innerAngle;//inside this angle the display is perfect
uniform float outerAngle;//from inner to outer the display gets more color distorted.
uniform float blackAngle;//from outer to this angle the display gets more black. From this angle to 90 the display stays black.
uniform float contrast;//0.0001 - 255.0, 1.0 is normal
uniform int use_als;
uniform int use_filters;

const vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
const vec4  kRGBToI     = vec4 (0.596, -0.275, -0.321, 0.0);
const vec4  kRGBToQ     = vec4 (0.212, -0.523, 0.311, 0.0);

const vec4  kYIQToR   = vec4 (1.0, 0.956, 0.621, 0.0);
const vec4  kYIQToG   = vec4 (1.0, -0.272, -0.647, 0.0);
const vec4  kYIQToB   = vec4 (1.0, -1.107, 1.704, 0.0);

vec3 filter_combined (in vec3 color) ;

vec3 rotateHue (in vec4 color) {
    // Convert to YIQ
    float   YPrime  = dot (color, kRGBToYPrime);
    float   I      = dot (color, kRGBToI);
    float   Q      = dot (color, kRGBToQ);

    // Calculate the hue and chroma
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);

    // Make the adjustment
    hue += radians(180.0);
    YPrime = 1.0 - YPrime;

    // Convert back to YIQ
    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    // Convert back to RGB
    vec4    yIQ   = vec4 (YPrime, I, Q, 0.0);
    color.r = dot (yIQ, kYIQToR);
    color.g = dot (yIQ, kYIQToG);
    color.b = dot (yIQ, kYIQToB);

    // reduce contrast by alot
    color.rgb = ((color.rgb - 0.5) * 0.1) + 0.5;
    return color.rgb;
}

// todo: rembrandt and stuff

void main (void) {
    vec3 gamma      = vec3(1.0/2.2);// standard monitor gamma correction
    vec3 gammaInv   = vec3(2.2);
    vec4 texel      = texture2D(BaseTex, gl_TexCoord[0].st);    

    vec3 eye = normalize(-eyeVec);
    vec3 N  = normalize(VNormal);
    float angle = degrees(acos(dot(N,eye)));//angle between normal and viewer
    vec3 color = vec3(0.0,0.0,0.0);
    if (angle <= innerAngle) {
        color = texel.rgb;
    } else if (angle <= outerAngle) {
        vec3 hsl = rotateHue(texel);
        float amount = (angle - innerAngle)/(outerAngle-innerAngle);
        color = mix(texel.rgb, hsl, amount);
    } else if (angle <= blackAngle) {
        vec3 hsl = rotateHue(texel);
        float amount = (angle - outerAngle)/(blackAngle-outerAngle);
        color = mix(hsl, vec3(0,0,0), amount);
    }

    // apply contrast
    color.rgb = ((color.rgb - 0.5) * contrast) + 0.5;

    color = pow(color, gammaInv);
    color = color * gl_FrontMaterial.emission.rgb;

    float phong = 0.0;
    vec3 Lphong = normalize(gl_LightSource[0].position.xyz);
    if (dot(N, Lphong) > 0.0) {
        // lightsource is not behind
        vec3 Rphong = normalize(-reflect(Lphong,N));
        phong = pow(max(dot(Rphong,eye),0.0),gl_FrontMaterial.shininess);
        phong = clamp(phong, 0.0, 1.0);
    }
    vec4 specular = gl_FrontMaterial.specular * gl_LightSource[0].diffuse * phong;
    vec3 ambient = gl_FrontMaterial.ambient.rgb * gl_LightSource[0].ambient.rgb * gl_LightSource[0].ambient.rgb * 2.0;//hack but works, pitch black at night. :)

    vec3 L = normalize((gl_ModelViewMatrixInverse * gl_LightSource[0].position).xyz);
    N = normalize((gl_ModelViewMatrixTranspose * vec4(N,0.0)).xyz);
    float nDotVP = dot(N,L);
    nDotVP = max(0.0, nDotVP);
    vec3 diffuse = gl_FrontMaterial.diffuse.rgb * gl_LightSource[0].diffuse.rgb * nDotVP;

    color = clamp(color+specular.rgb+ambient+diffuse, 0.0, 1.0);

    vec4 dustTexel = texture2D(dust_texture, gl_TexCoord[0].st);
    dustTexel.rgb *= gl_LightSource[0].diffuse.rgb * nDotVP;
    dustTexel.a = clamp(dustTexel.a * dirt_factor * (1.0 - 0.4 * max(0.0,dot(normalize(VNormal), Lphong)))*(length(vec3(1.0))/1.76),0.0,1.0); 
    color.rgb =  mix(color.rgb, dustTexel.rgb,  dustTexel.a );
    //color.a = max(color.a, dustTexel.a);
    texel.a = max(texel.a, dustTexel.a);
    if (use_als > 0 && use_filters > 0) {
        gl_FragColor = vec4(filter_combined(pow(color,gamma)), texel.a);
    } else {
        gl_FragColor = vec4(pow(color,gamma), texel.a);
    }
}