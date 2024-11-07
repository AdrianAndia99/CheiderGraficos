Shader "Custom/5en1"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _SpecularMap("Specular Map", 2D) = "white" {}
        _EmissionMap("Emission Map", 2D) = "black" {}
        _HeightMap("Height Map", 2D) = "black" {}
        _Color("Tint Color", Color) = (1, 1, 1, 1)
        _EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Range(1, 128)) = 32
        _HeightScale("Height Scale", Range(0, 0.1)) = 0.05
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

                sampler2D _MainTex;
                sampler2D _NormalMap;
                sampler2D _SpecularMap;
                sampler2D _EmissionMap;
                sampler2D _HeightMap;

                fixed4 _Color;
                fixed4 _EmissionColor;
                float _Shininess;
                float _HeightScale;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                    float3 viewDir : TEXCOORD1;
                    float3 tangent : TANGENT;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float3 viewDir : TEXCOORD1;
                    float3 worldPos : TEXCOORD2;
                    float3 worldNormal : TEXCOORD3;
                    float4 pos : SV_POSITION;
                };

                v2f vert(appdata v)
                {
                    v2f o;
                    o.uv = v.uv;

                    // Convert to world space
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);

                    // Calculate view direction
                    float3 viewDirection = normalize(UnityWorldSpaceViewDir(o.worldPos));
                    o.viewDir = viewDirection;

                    o.pos = UnityObjectToClipPos(v.vertex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    // Parallax Mapping (Height Map)
                    float height = tex2D(_HeightMap, i.uv).r;
                    float2 parallaxOffset = height * _HeightScale * normalize(i.viewDir).xy;
                    float2 uv = i.uv + parallaxOffset;

                    // Diffuse Texture
                    fixed4 texColor = tex2D(_MainTex, uv) * _Color;
                    fixed3 albedo = texColor.rgb;

                    // Normal Mapping
                    fixed3 normalMap = tex2D(_NormalMap, uv).rgb * 2.0 - 1.0;
                    normalMap = normalize(normalMap);

                    // Transform normal to world space
                    float3 worldNormal = normalize(i.worldNormal + normalMap);

                    // Lighting Calculation
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    float diff = max(dot(worldNormal, lightDir), 0.0);

                    // Specular Mapping
                    float specularIntensity = tex2D(_SpecularMap, uv).r;
                    float3 reflectDir = reflect(-lightDir, worldNormal);
                    float3 viewDir = normalize(i.viewDir);
                    float spec = pow(max(dot(viewDir, reflectDir), 0.0), _Shininess) * specularIntensity;

                    // Emission Mapping
                    fixed3 emission = tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb;

                    // Final Color
                    fixed3 color = albedo * diff + spec + emission;
                    return fixed4(color, texColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
