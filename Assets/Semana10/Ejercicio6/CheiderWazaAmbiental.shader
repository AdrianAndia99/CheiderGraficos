Shader "Custom/CheiderWazaAmbiental"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}                     // Textura de la bandera
        _WindStrength("Wind Strength", Range(0, 1)) = 0.5        // Fuerza del viento
        _WindSpeed("Wind Speed", Range(0.1, 10.0)) = 1.0         // Velocidad del viento
        _WindFrequency("Wind Frequency", Range(0.1, 10.0)) = 2.0 // Frecuencia de la onda del viento
        _Color("Color", Color) = (1, 1, 1, 1)                    // Color base
        _AmbientColor("Ambient Color", Color) = (0.5, 0.5, 0.5, 1) // Luz ambiental
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 10

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                };

                sampler2D _MainTex;
                float4 _Color;                // Color base
                float4 _AmbientColor;         // Luz ambiental
                float _WindStrength;          // Fuerza del viento
                float _WindSpeed;             // Velocidad del viento
                float _WindFrequency;         // Frecuencia del viento

                v2f vert(appdata v)
                {
                    v2f o;

                    // Animación de la bandera afectada por el viento
                    float wave = sin(_Time.x * _WindSpeed + v.vertex.x * _WindFrequency) * _WindStrength;
                    v.vertex.z += wave;

                    o.pos = UnityObjectToClipPos(v.vertex);

                    // Pasar las coordenadas UV
                    o.uv = v.uv;

                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    // Obtener el color de la textura
                    float4 texColor = tex2D(_MainTex, i.uv);

                    // Aplicar la luz ambiental al color de la textura
                    float3 ambient = texColor.rgb * _Color.rgb * _AmbientColor.rgb;

                    // Devolver el color final con la luz ambiental aplicada
                    return float4(ambient, texColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}