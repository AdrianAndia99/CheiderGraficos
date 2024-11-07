Shader "Custom/SpecularMap"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}      // Textura principal
        _NormalMap("Normal Map", 2D) = "bump" {}       // Mapa de normales
        _SpecularMap("Specular Map", 2D) = "white" {}  // Mapa especular
        _Color("Tint Color", Color) = (1, 1, 1, 1)     // Color base
        _Shininess("Shininess", Range(1, 128)) = 32    // Factor de brillo especular
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 300

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
                    float4 tangent : TANGENT;   // Tangente para el normal mapping
                    float2 uv : TEXCOORD0;      // Coordenadas UV para la textura
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float3 worldNormal : TEXCOORD0;
                    float3 worldTangent : TEXCOORD1;
                    float3 worldBinormal : TEXCOORD2;
                    float3 viewDir : TEXCOORD3;
                    float2 uv : TEXCOORD4;
                };

                sampler2D _MainTex;
                sampler2D _NormalMap;
                sampler2D _SpecularMap;
                float4 _Color;
                float _Shininess;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);

                    // Transforma la normal, tangente y binormal al espacio mundial
                    float3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                    float3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                    float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                    // Pasar las coordenadas al fragment shader
                    o.worldNormal = worldNormal;
                    o.worldTangent = worldTangent;
                    o.worldBinormal = worldBinormal;
                    o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
                    o.uv = v.uv;
                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    // Obtener el color de la textura y aplicar el color base
                    float4 texColor = tex2D(_MainTex, i.uv) * _Color;

                    // Obtener el valor del normal map y remapearlo de [0,1] a [-1,1]
                    float3 normalMap = tex2D(_NormalMap, i.uv).rgb * 2.0 - 1.0;

                    // Construir la matriz TBN (Tangente, Binormal, Normal)
                    float3x3 TBN = float3x3(i.worldTangent, i.worldBinormal, i.worldNormal);

                    // Calcular la normal perturbada en el espacio mundial
                    float3 disturbedNormal = normalize(mul(TBN, normalMap));

                    // Calcular la iluminaci�n difusa con la normal perturbada
                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    float NdotL = max(0, dot(disturbedNormal, lightDir));
                    float3 diffuse = texColor.rgb * _LightColor0.rgb * NdotL;

                    // Obtener el valor del mapa especular
                    float specularIntensity = tex2D(_SpecularMap, i.uv).r; // Solo el canal R para intensidad especular

                    // Calcular la iluminaci�n especular con la normal perturbada
                    float3 reflectDir = reflect(-lightDir, disturbedNormal);
                    float specFactor = pow(max(dot(reflectDir, normalize(i.viewDir)), 0), _Shininess) * specularIntensity;
                    float3 specular = _LightColor0.rgb * specFactor;

                    // Combinar iluminaci�n difusa y especular
                    return float4(diffuse + specular, texColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}