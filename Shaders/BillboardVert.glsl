////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2018 Michele Morrone
//  All rights reserved.
//
//  mailto:me@michelemorrone.eu
//  mailto:brutpitt@gmail.com
//  
//  https://github.com/BrutPitt
//
//  https://michelemorrone.eu
//  https://BrutPitt.com
//
//  This software is distributed under the terms of the BSD 2-Clause license:
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//   
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
////////////////////////////////////////////////////////////////////////////////

// #version dynamically inserted

layout(std140) uniform;

layout (location = 0) in vec4 a_ActualPoint;
//layout (location = 0) in vec4 a_PrevPoint;

LAYUOT_BINDING(0) uniform sampler2D paletteTex;

LAYUOT_BINDING(2) uniform _particlesData {
    vec3  lightDir;
    float lightDiffInt;
    vec3  lightColor; 
    float lightSpecInt;
    vec2  scrnRes;
    float lightAmbInt ;
    float lightShinExp;
    float sstepColorMin;
    float sstepColorMax;
    float pointSize;
    float pointDistAtten;
    float alphaDistAtten;
    float alphaSkip;
    float alphaK;
    float colIntensity;
    float clippingDist;
    float zNear;
    float zFar;
    float velIntensity;
    float ySizeRatio;
    float ptSizeRatio;
    float pointspriteMinSize;
    bool  lightActive;
} u;

 
LAYUOT_BINDING(4) uniform _tMat {
    mat4 pMatrix;
    mat4 mvMatrix;
    mat4 mvpMatrix;
} m;


out gl_PerVertex
{
	vec4 gl_Position;
    float gl_PointSize;
};


out float pointDist;
out vec4 vertParticleColor;


//#define USE_HLS_INTERNAL

#ifdef USE_HLS_INTERNAL
#define dueterzi 2./3.
#define unsesto  1./6.
#define unterzo  1./3.


float hue2rgb(float p, float q, float t)
{
    if(t < 0.) t += 1.;
    if(t > 1.) t -= 1.;
 
    if(t < unsesto) return p + (q - p) * 6. * t;
    if(t < .5) return q;
    if(t < dueterzi) return p + (q - p) * (dueterzi - t) * 6.;
    return p;
}


vec3 HLStoRGB( vec3 HLS)
{
   
    if(HLS.z==0.0) { return HLS.yyy; }

	float v2;
    
    if(HLS.z>1) HLS.z = 1;

	if(HLS.y>1) {
		HLS.y = 1.f;
		v2 = (HLS.y+HLS.z) - HLS.y*HLS.z;
	} else 
		v2 = (HLS.y < 0.5) ? HLS.y*(1.0+HLS.z) : (HLS.y+HLS.z) - HLS.y*HLS.z;
	
    float v1 = 2.0*HLS.y - v2;    

    return vec3 ( hue2rgb(v1, v2, HLS.x+unterzo), 
                  hue2rgb(v1, v2, HLS.x), 
                  hue2rgb(v1, v2, HLS.x-unterzo)
                );

 }
 


vec4 HLStoRGB( vec4 HLS)
{

    return vec4(HLStoRGB(HLS.rgb), HLS.a);

}
#endif


void main(void)
{

    gl_Position = m.mvMatrix * vec4(a_ActualPoint.xyz,1.f);
    float vel = a_ActualPoint.w*u.velIntensity;

#ifdef USE_HLS_INTERNAL
    vec4 cOut = HLStoRGB(vec4(vel,.5f,.99f, 1.0));
#else
    vec4 cOut = vec4(texture(paletteTex, vec2(vel,0.f)).rgb,1.0);

#endif
    pointDist = length(gl_Position.xyz); 

    float ptAtten = exp(-0.01*sign(pointDist)*pow(abs(pointDist)+1.f, u.pointDistAtten*.1));
    gl_PointSize = u.pointSize/u.scrnRes.y * ptAtten * u.ySizeRatio;

    vertParticleColor = cOut;

// Load OBJ
/*
    uint packCol = floatBitsToUint(a_ActualPoint.w);
    vec4 col = unpackUnorm4x8(packCol);

    particleColor = col;
*/
}
