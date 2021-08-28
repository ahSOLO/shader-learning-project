Shader"Unlit/RippleTexture"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        [NoScaleOffset] _RippleTex ("Ripple Texture", 2D) = "white" {}
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

            #include "UnityCG.cginc"

            #define TAU 6.28318530718 // preprocessor constant

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 ripple: TEXCOORD1;
            };

            struct v2f // data passed from vertex to fragment shader
            {
                float4 vertex : SV_POSITION; // clip space position
                float2 uv : TEXCOORD0; // texcoords don't have to specifically refer to UV channels
                float2 ripple : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _RippleTex;

            // Vertex shader - loops over each vertex - optimization tip: do as much as possible in vertex shader unless you have many models in the far distance to render
            v2f vert (MeshData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // convert local space to clip space
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.ripple = v.ripple;
                // o.worldPos = mul(UNITY_MATRIX_M, v.vertex); // object to world space
                //o.normal = v.normals;
                return o;
            }

            float GetWave(float coord)
            {
	            float wave = cos( (coord - _Time.y * 0.1) * TAU * 5 ) * 0.5 + 0.5;
	            wave *= 1 - coord;
	            return wave;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture 
                float4 mainTex = tex2D(_MainTex, i.uv);
                float4 rippleTex = tex2D(_RippleTex, i.ripple);
                float4 col = lerp(mainTex, float4(0, 0, 0, 1), GetWave(rippleTex));
                return col;
            }
            ENDCG
        }
    }
}
