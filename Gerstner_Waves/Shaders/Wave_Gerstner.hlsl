#ifndef MYHLSLINCLUDE_INCLUDED
#define MYHLSLINCLUDE_INCLUDED

void Wave_float(float4 In_Wave, float3 In_Pos, float3 In_Tangent, float3 In_Binormal, out float3 Out, out float3 Out_Tangent, out float3 Out_Binormal)
{
	float steepness = In_Wave.z;
	float wavelength = In_Wave.w;
	float k = 2 * PI / wavelength;
	float c = sqrt(9.8 / k);
	float2 d = normalize(In_Wave.xy);
	float f = k * (dot(d, In_Pos.xz) - c * _Time.y);
	float a = steepness / k;

	In_Tangent += float3(
		-d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)),
		-d.x * d.y * (steepness * sin(f))
	);
	Out_Tangent = In_Tangent;

	In_Binormal += float3(
		-d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		-d.y * d.y * (steepness * sin(f))
	);
	Out_Binormal = In_Binormal;

	Out = float3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	);
}
#endif