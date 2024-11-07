Shader "Unlit/NewCheider6"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _WindStrength("Wind Strength", Range(0, 1)) = 0.5
        _WindSpeed("Wind Speed", Range(0.1, 10.0)) = 1.0
        _WindFrequency("Wind Frequency", Range(0.1, 10.0)) = 2.0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 pos : SV_POSITION;
                };

                sampler2D _MainTex;
                fixed _WindStrength;
                fixed _WindSpeed;
                fixed _WindFrequency;

                v2f vert(appdata v)
                {
                    v2f o;

                    float wave = sin(_Time.x * _WindSpeed + v.vertex.x * _WindFrequency) * _WindStrength;
                    v.vertex.z += wave;

                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    return tex2D(_MainTex, i.uv);
                }
                ENDCG
            }
        }
}