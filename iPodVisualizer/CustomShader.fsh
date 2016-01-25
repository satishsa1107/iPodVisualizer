precision mediump float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform float colorDistortion;
uniform float fisheyeDistortion;
uniform float audioPowerDistortion;

const float PI = 3.1415926535;

float wave(float color, float scale) {
    return (abs(sin(color * scale)));
}

// FishEye Effect
vec2 fisheye(float audioPower) {
    float apertureDistortion = (fisheyeDistortion-1.)/9.;
    float apertureScale = (2. - (audioPower * apertureDistortion / 0.5));
    float aperture = 178.0;
    float apertureHalf = 0.5 * aperture * (PI / 180.0);
    float maxFactor = sin(apertureHalf)*apertureScale;
    
    vec2 uv;
    vec2 xy = 2.0 * textureCoordinate.xy - 1.0;
    float d = length(xy);
    
    if (d < (2.0-maxFactor))
    {
        d = length(xy * maxFactor);
        float z = sqrt(1.0 - d * d);
        float r = atan(d, z) / PI;
        float phi = atan(xy.y, xy.x);
        
        uv.x = r * cos(phi) + 0.5;
        uv.y = r * sin(phi) + 0.5;
    }
    else
    {
        uv = textureCoordinate.xy;
    }
    return uv;
}

void main()
{
    float audioPower = audioPowerDistortion;
    
    vec2 fisheye_pix = fisheye(audioPower);
    
    vec4 color = texture2D(inputImageTexture, fisheye_pix);
    
    if (colorDistortion > 1.73)
    {
        color.r = wave(color.r, colorDistortion * max(1.,audioPower+1.));
        color.g = wave(color.g, colorDistortion * max(1.,audioPower+1.));
        color.b = wave(color.b, colorDistortion * max(1.,audioPower+1.));
        color.a = 1.;
    }

    gl_FragColor = color;
}