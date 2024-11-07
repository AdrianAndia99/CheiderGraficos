Shader "Unlit/NewCheider5"
{
    Properties
    {
        _Texture1("Texture 1", 2D) = "white" {}
        _Texture2("Texture 2", 2D) = "white" {}
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

            sampler2D _Texture1;
            sampler2D _Texture2;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texColor1 = tex2D(_Texture1, i.uv);
                fixed4 texColor2 = tex2D(_Texture2, i.uv);
                return texColor1 * texColor2;
            }
            ENDCG
        }
    }
}