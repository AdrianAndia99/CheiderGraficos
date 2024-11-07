Shader "Custom/CheiderWazaLambert"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}                     // Textura de la bandera
        _WindStrength("Wind Strength", Range(0, 1)) = 0.5        // Fuerza del viento
        _WindSpeed("Wind Speed", Range(0.1, 10.0)) = 1.0         // Velocidad del viento
        _WindFrequency("Wind Frequency", Range(0.1, 10.0)) = 2.0 // Frecuencia de la onda del viento
        _Color("Color", Color) = (1,1,1,1)                       // Color base
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
                #include "Lighting.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float3 worldNormal : TEXCOORD0;
                    float3 worldPos : TEXCOORD1;
                    float2 uv : TEXCOORD2;
                };

                sampler2D _MainTex;
                float4 _Color;                // Color base
                float _WindStrength;          // Fuerza del viento
                float _WindSpeed;             // Velocidad del viento
                float _WindFrequency;         // Frecuencia del viento

                v2f vert(appdata v)
                {
                    v2f o;

                    // Aplicar el movimiento de onda de la bandera debido al viento
                    float wave = sin(_Time.x * _WindSpeed + v.vertex.x * _WindFrequency) * _WindStrength;
                    v.vertex.z += wave;

                    o.pos = UnityObjectToClipPos(v.vertex);

                    // Calcular la normal y posición en espacio mundial
                    o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                    // Pasar las coordenadas UV para la textura
                    o.uv = v.uv;

                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    // Color de la textura
                    float4 texColor = tex2D(_MainTex, i.uv) * _Color;

                    // Cálculo de iluminación difusa usando el modelo Lambert
                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                    float NdotL = max(0, dot(i.worldNormal, lightDir));

                    // Componente de iluminación difusa
                    float3 diffuse = texColor.rgb * _LightColor0.rgb * NdotL;

                    // Color final
                    return float4(diffuse, texColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}