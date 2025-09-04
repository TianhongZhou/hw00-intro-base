#version 300 es
precision highp float;

uniform vec4  u_Color;     
uniform float u_Time;      
uniform float u_NoiseScale; 
uniform float u_NoiseAmp;  

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;    
in vec3 vWorldPos;

out vec4 out_Col;

float hash(vec3 p) {
  return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

float valueNoise(vec3 x) {
  vec3 i = floor(x);
  vec3 f = fract(x);

  vec3 u = f * f * (3.0 - 2.0 * f);

  float n000 = hash(i + vec3(0.0, 0.0, 0.0));
  float n100 = hash(i + vec3(1.0, 0.0, 0.0));
  float n010 = hash(i + vec3(0.0, 1.0, 0.0));
  float n110 = hash(i + vec3(1.0, 1.0, 0.0));
  float n001 = hash(i + vec3(0.0, 0.0, 1.0));
  float n101 = hash(i + vec3(1.0, 0.0, 1.0));
  float n011 = hash(i + vec3(0.0, 1.0, 1.0));
  float n111 = hash(i + vec3(1.0, 1.0, 1.0));

  float nx00 = mix(n000, n100, u.x);
  float nx10 = mix(n010, n110, u.x);
  float nx01 = mix(n001, n101, u.x);
  float nx11 = mix(n011, n111, u.x);

  float nxy0 = mix(nx00, nx10, u.y);
  float nxy1 = mix(nx01, nx11, u.y);

  return mix(nxy0, nxy1, u.z);
}

float fbm(vec3 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 5; ++i) {
    v += a * valueNoise(p);
    p = p * 2.0 + vec3(37.1, 17.3, 51.7); 
    a *= 0.5;
  }
  return v;
}

void main() {
  vec3 N = normalize(fs_Nor.xyz);
  vec3 L = normalize(fs_LightVec.xyz);

  float diffuseTerm = max(dot(N, L), 0.0);
  float ambientTerm = 0.2;
  float lightIntensity = diffuseTerm + ambientTerm;

  vec3 p = u_NoiseScale * vWorldPos + vec3(0.10 * u_Time, 0.0, -0.07 * u_Time);
  float n = fbm(p);               
  float boost = 0.75 + n * u_NoiseAmp;

  vec3 base = u_Color.rgb;     
  vec3 shaded = base * boost * lightIntensity;

  out_Col = vec4(shaded, u_Color.a);
}