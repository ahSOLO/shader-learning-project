Shader "Custom/SimpleLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Glossiness", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // diffuse lighting
                float3 N = normalize(i.normal); // normalize because interpolated normals between vertices aren't guaranteed to have a length of 1
                float3 L = _WorldSpaceLightPos0.xyz; // first pass is always directional light, meaning this gives us a direction and not a point
                
                float3 diffuseLight = saturate(dot(N, L)) * _LightColor0.xyz; // saturate probably faster than max

                // specular lighting;
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 R = reflect(-L, N);
                float3 specularLight = saturate(dot(V, R)) * _LightColor0.xyz;
                specularLight = pow(specularLight, _Gloss); // apply gloss (specular exponent)
                
                float4 lighting = float4(diffuseLight, 1) + float4(specularLight, 1);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col * lighting;
            }
            ENDCG
        }
    }
}
