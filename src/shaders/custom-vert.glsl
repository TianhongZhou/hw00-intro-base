#version 300 es
precision highp float;

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;

uniform float u_Time;   
uniform float u_Amp;    
uniform float u_Freq; 

in vec4 vs_Pos;
in vec4 vs_Nor;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;      
out vec3 vWorldPos;  

void main() {
  vec4 worldPos = u_Model * vs_Pos;
  vec3 n = normalize((u_ModelInvTr * vec4(vs_Nor.xyz, 0.0)).xyz);

  float disp =
      u_Amp *
      sin(u_Freq * worldPos.x + u_Time) *
      cos(0.7 * u_Freq * worldPos.z - 0.5 * u_Time);

  vec3 displacedPos = worldPos.xyz + n * disp;

  vec3 lightPos = vec3(5.0, 5.0, 5.0);

  vWorldPos   = displacedPos;
  fs_Nor      = vec4(n, 0.0);
  fs_LightVec = vec4(lightPos - displacedPos, 0.0);
  fs_Col      = vec4(1.0);

  gl_Position = u_ViewProj * vec4(displacedPos, 1.0);
}