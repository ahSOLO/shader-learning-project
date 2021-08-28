Shader"Unlit/UnlitShaderLearningReference"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader // Subshader tags go below
    {
        Tags { "RenderType"="Opaque"}
                // "RenderType" = "Transparent"
                // "Queue" = "Transparent" // changes render order
        LOD 100

        Pass // Pass tags go below
        {
            // Cull Off / Back / Front // Face Culling

            // ZWrite off // Turn off writing to depth buffer
            // ZTest LEqual / Always / GEqual - draw items when they are in front of something, behind something, or always
            
            // Blend One One // additive
            // Blend DstColor Zero // multiply

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #define TAU = 6.28318530718 // preprocessor constant

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                // float3 normals: NORMAL; // local space normals
                // float4 tangent: TANGENT; // tangent direction (xyz) sign (w)
                // float4 color: COLOR; // vertex colors
            };

            struct v2f // data passed from vertex to fragment shader
            {
                float2 uv : TEXCOORD0; // texcoords don't have to specifically refer to UV channels
                //float3 normal : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION; // clip space position
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Scale;

            // Vertex shader - loops over each vertex - optimization tip: do as much as possible in vertex shader unless you have many models in the far distance to render
            // if sampling in vertex shader, always use tex2Dlod instead of tex2D as you must provide a mip level
            v2f vert (MeshData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex + float4(sin(_Time.xxx * 20), 1)); // convert local space to clip space
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.worldPos = mul(UNITY_MATRIX_M, v.vertex); // object to world space
                UNITY_TRANSFER_FOG(o,o.vertex);
                //o.normal = v.normals;
                return o;
            }

            // Normals between vertices are interpolated
            // Only data available to fragment shader is interpolated data, no direct access to vertices
            
            // float - 32 bit float
            // half - 16 bit float
            // fixed - ~12 bit float, lower precision
            // half/fixed may not be supported / compiled away on PC, but important for mobile

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                // topDownProjection = i.worldPos.xz;
                return col;
            }
            ENDCG
        }
    }
}
