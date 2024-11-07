Shader "Custom/CheiderWazaSpecular"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}                  // Textura de la bandera
        _WindStrength("Wind Strength", Range(0, 1)) = 0.5     // Fuerza del viento
        _WindSpeed("Wind Speed", Range(0.1, 10.0)) = 1.0      // Velocidad del viento
        _WindFrequency("Wind Frequency", Range(0.1, 10.0)) = 2.0 // Frecuencia de la onda del viento
        _CustomSpecColor("Specular Color", Color) = (1, 1, 1, 1) // Color especular
        _AmbientColor("Ambient Color", Color) = (0.5, 0.5, 0.5, 1) // Color ambiental
        _Shininess("Shininess", Range(1, 128)) = 32            // Brillo para la especularidad
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
                    float3 viewDir : TEXCOORD2;
                    float2 uv : TEXCOORD3;
                };

                sampler2D _MainTex;
                float4 _CustomSpecColor;
                float4 _AmbientColor;
                float _Shininess;
                float _WindStrength;
                float _WindSpeed;
                float _WindFrequency;

                v2f vert(appdata v)
                {
                    v2f o;

                    // Animación de la bandera afectada por el viento
                    float wave = sin(_Time.x * _WindSpeed + v.vertex.x * _WindFrequency) * _WindStrength;
                    v.vertex.z += wave;

                    o.pos = UnityObjectToClipPos(v.vertex);

                    // Cálculo de la normal y la posición en el espacio mundial
                    o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                    // Dirección de la vista desde el espacio mundial
                    o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);

                    // Pasar las coordenadas UV
                    o.uv = v.uv;

                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    // Obtener el color de la textura
                    float4 texColor = tex2D(_MainTex, i.uv);

                    // Cálculo de la iluminación difusa
                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    float NdotL = max(0, dot(i.worldNormal, lightDir));
                    float3 diffuse = texColor.rgb * _LightColor0.rgb * NdotL;

                    // Cálculo del componente especular
                    float3 reflectDir = reflect(-lightDir, i.worldNormal);
                    float specFactor = pow(max(dot(reflectDir, i.viewDir), 0), _Shininess);
                    float3 specular = _CustomSpecColor.rgb * specFactor;

                    // Luz ambiental
                    float3 ambient = texColor.rgb * _AmbientColor.rgb;

                    // Color final
                    float3 finalColor = ambient + diffuse + specular;
                    return float4(finalColor, texColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
