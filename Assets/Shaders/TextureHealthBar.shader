Shader"Unlit/TextureHealthBar"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Health ("Health", Range(0, 1)) = 1
    }
    SubShader // Subshader tags go below
    {
        Tags {"RenderType" = "Opaque"}
        LOD 100

        Pass // Pass tags go below
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define TAU 6.28318530718 // preprocessor constant

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f // data passed from vertex to fragment shader
            {
                float4 vertex : SV_POSITION; // clip space position
                float2 uv : TEXCOORD0; // texcoords don't have to specifically refer to UV channels
            };

            sampler2D _MainTex;
            float _Health;

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }
            
            // Vertex shader - loops over each vertex - optimization tip: do as much as possible in vertex shader unless you have many models in the far distance to render
            v2f vert (MeshData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // convert local space to clip space
                o.uv = v.uv;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, float2(_Health, i.uv.y));
                float healthBarMask = _Health > i.uv.x; // bools can be cast to floats
                // clip(healthBarMask - 0.5); // remove backgound in opaque shader
                
                // Flash if health is less than 20%
                if (_Health < 0.2)
                {
                    float3 flash = 1 + (sin(_Time.y * 8)/5);
                    col.xyz *= float4(flash, 1);
                }
                
                return col * healthBarMask;
            }
            ENDCG
        }
    }
}
