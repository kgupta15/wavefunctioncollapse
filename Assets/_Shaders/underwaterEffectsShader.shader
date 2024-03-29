﻿Shader "PeerPlay/underwaterImageEffects"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", float) = 1
        _NoiseFrequency ("Noise Frequency", float) = 1
        _NoiseSpeed ("Noise Speed", float) = 1
        _PixelOffset ("Pixel Offset", float) = 0.005
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "noiseSimplex.cginc"
            #define M_PI 3.1415926535897932384626433832795

            uniform float _NoiseFrequency;
            uniform float _NoiseScale;
            uniform float _NoiseSpeed;
            uniform float _PixelOffset;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 scrpos : TEXCOORD1; 
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.scrpos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : COLOR
            {
                float3 spos = float3(i.scrpos.x, i.scrpos.y, 0) * _NoiseFrequency;
                spos.z += _Time.x * _NoiseSpeed;
                float noise = _NoiseScale * ((snoise(spos) + 1)/2);
               	float4 noise_to_dir = float4(cos(noise * M_PI * 2), sin(noise * M_PI * 2), 0, 0);  
                fixed4 col = tex2Dproj(_MainTex, i.scrpos + (normalize(noise_to_dir) * _PixelOffset));
                return col;
            }
            ENDCG
        }
    }
}
