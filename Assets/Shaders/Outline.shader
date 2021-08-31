Shader"Unlit/Outline"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,0,1)
    }
    SubShader // Subshader tags go below
    {
        Tags { "RenderType"="Opaque"}
                // "RenderType" = "Transparent"
                // "Queue" = "Transparent" // changes render order
        LOD 100

        Pass // Pass tags go below
        {
            Cull Front
            ZTest LEqual
            
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
            };

            struct v2f // data passed from vertex to fragment shader
            {
                float4 vertex : SV_POSITION; // clip space position
            };

            float4 _Color;

            // Vertex shader - loops over each vertex - optimization tip: do as much as possible in vertex shader unless you have many models in the far distance to render
            // if sampling in vertex shader, always use tex2Dlod instead of tex2D as you must provide a mip level
            v2f vert (MeshData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex * 1.1); // convert local space to clip space
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
                float4 col = _Color;
                return col;
            }
            ENDCG
        }
    }
}
