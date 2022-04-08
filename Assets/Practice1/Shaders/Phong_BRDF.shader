Shader "Unlit/Phong_BRDF"
{
	Properties
	{

		//Crear 3 parametros que se puedan modificar dependiendo el componente del BDRF que vaya a utilizar
		//The Bidirectional Reflectance Distribution Functions gives us a a probabilistic distribution of how a surface behaves
		//when exposed to light given the vectors V, L& N

		//F(l,h): is the Fresnel function, given the light vector and the view vector
		//G(l,v,h) : is the geometry function, given the light, view& half vector
		//D : is the Distribution function, given the half vector
		_MainTex("MainTex",2D) = "white"{}
		_Smoothness("Smoothness",Range(0.0,0.9999)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_SpecularFactor("SpecularFactor",Range(0.0,5.0)) = 1.0
		
		
		 _objectColor("Main color",Color) = (0,0,0,1)
		 _ambientInt("Ambient int", Range(0,1)) = 0.25
		 _ambientColor("Ambient Color", Color) = (0,0,0,1)

		 _diffuseInt("Diffuse int", Range(0,1)) = 1
		_scecularExp("Specular exponent",Float) = 2.0

		_pointLightPos("Point light Pos",Vector) = (0,0,0,1)
		_pointLightColor("Point light Color",Color) = (0,0,0,1)
		_pointLightIntensity("Point light Intensity",Float) = 1

		_directionalLightDir("Directional light Dir",Vector) = (0,1,0,1)
		_directionalLightColor("Directional light Color",Color) = (0,0,0,1)
		_directionalLightIntensity("Directional light Intensity",Float) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile __ POINT_LIGHT_ON 
			#pragma multi_compile __ DIRECTIONAL_LIGHT_ON
            #include "UnityCG.cginc"
			#include "Lighting.cginc"

			#define Pi 3.1415


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
				float3 wPos : TEXCOORD2;
				float3 normal: TEXTCOORD1;
				
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.uv;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

			sampler2D _MainTex;
			samplerCUBE _Cubemap;

			//Componentes del BDRF
			float _Smoothness;
			float _Metallic;
			float _DiffuseFactor;
			float _SpecularFactor;

			fixed4 _objectColor;
			
			float _ambientInt;//How strong it is?
			fixed4 _ambientColor;
			float _diffuseInt;
			float _scecularExp;

			float4 _pointLightPos;
			float4 _pointLightColor;
			float _pointLightIntensity;

			float4 _directionalLightDir;
			float4 _directionalLightColor;
			float _directionalLightIntensity;

			struct Output
			{
				float3 Albedo;
				float3 normalDir;
				float3 halfDir; //Mitad del vector
				float Metallic;
				float Smoothness;
				float3 viewDir;
				float3 lightDir;

			};

			//cuadrado para saber el valor de la superficie
			float sqr(float value) {
				return value * value;
			}

			// Funcion de Fresnel
			float3 Fresnel_term(float3 Normal, float ViewDirH) {
				return Normal + (1 - Normal) * pow(1 - ViewDirH, 5);
			}

			// Funcion de distribucion
			float Distribution(float roughness, float Dir_value) {
				float alpha = sqr(roughness);
				float denominator = sqr(Dir_value) * (alpha - 1.0) + 1.0f;
				return alpha / (Pi * sqr(denominator));
			}
			
			// Funcion de geometria
			float Geometry(float roughness, float Dir_and_lightDir_value, float Normal_and_view_value) {
				float alpha = sqr(roughness);
				float DirV = Dir_and_lightDir_value * sqrt((-Normal_and_view_value * alpha + Normal_and_view_value) * Normal_and_view_value + alpha);
				float DirL = Normal_and_view_value * sqrt((-Dir_and_lightDir_value * alpha + Dir_and_lightDir_value) * Dir_and_lightDir_value + alpha);
				return 0.5 / (DirL + DirV + 0.00001);
			}

			float4 BRDF(Output o, float3 SpecularColor, float oneMinusReflectivity)
			{
					float roughness = 1 - o.Smoothness;

					//Igualar los valores
					float Dir_and_half_value = saturate(dot(o.normalDir, o.halfDir));
					float Lightdir_and_half_value = saturate(dot(o.lightDir, o.halfDir));
					float Dir_and_lightDir_value = saturate(dot(o.normalDir, o.lightDir));
					float VdotH = saturate(dot(o.viewDir, o.halfDir));
					float Normal_and_view_value = abs(dot(o.normalDir, o.viewDir));

					float V = Geometry(roughness, Dir_and_lightDir_value, Normal_and_view_value);
					float D_1 = Distribution(roughness, Dir_and_half_value);

					float specularTerm = V * D_1 * Pi;
					specularTerm = max(0, specularTerm * Dir_and_lightDir_value);

					float Fresnel = Fresnel_term(SpecularColor, Lightdir_and_half_value);
					float surfaceReduction = 1.0 / (roughness * roughness + 1.0);
					specularTerm *= any(SpecularColor) ? 1.0 : 0.0;

					float grazingTerm = saturate(o.Smoothness + (1 - oneMinusReflectivity));	
					float3 color = o.Albedo * (_LightColor0.rgb * _diffuseInt + 0.5) + specularTerm * _LightColor0.rgb * Fresnel * _SpecularFactor + 0.5 * surfaceReduction ;
					return float4(color, 1);
			}

			float4 LightingStandard(Output o)
			{
				// unity_ColorSpaceDielectricSpec contiene la reflectividad dieléctrica seleccionada por Unity, y el canal alfa es 1-dielectricSpec
				float3 specColor = lerp(unity_ColorSpaceDielectricSpec.rgb, o.Albedo, o.Metallic);
				float3 oneMinusReflectivity = unity_ColorSpaceDielectricSpec.a * (1 - o.Metallic);
				o.Albedo = o.Albedo * oneMinusReflectivity;
				return BRDF(o, specColor, oneMinusReflectivity);
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float3 worldNormalDir = normalize(i.normal);
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
				float3 worldHalfDir = normalize(worldLightDir + worldViewDir);

				//3 phong model light components
                //We assign color to the ambient term		
				fixed4 ambientComp = _ambientColor * _ambientInt;//We calculate the ambient term based on intensity
				fixed4 finalColor = ambientComp;
				
				float3 viewVec;
				float3 halfVec;
				float3 difuseComp = float4(0, 0, 0, 1);
				float3 specularComp = float4(0, 0, 0, 1);
				float3 lightColor;
				float3 lightDir;
#if DIRECTIONAL_LIGHT_ON

				//Directional light properties
				lightColor = _directionalLightColor.xyz;
				lightDir = normalize(_directionalLightDir);

				//Diffuse componenet
				difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.worldNormal),0,1);

				//Specular component	
				viewVec = normalize(_WorldSpaceCameraPos - i.wPos);

				//Specular component
				//phong
				//float3 halfVec = reflect(-lightDir, i.worldNormal);
				//fixed4 specularComp = lightColor * pow(clamp(dot(halfVec, viewVec),0,1), _scecularExp);
				
				//blinnPhong
				halfVec = normalize(viewVec + lightDir);
				specularComp = lightColor * pow(max(dot(halfVec, i.worldNormal),0), _scecularExp);

				//Sum
				finalColor += clamp(float4(_directionalLightIntensity*(difuseComp+specularComp),1),0,1);

				//Mostrar resultados de los valores
				Output o;
				o.Albedo = tex2D(_MainTex, i.uv);
				o.Metallic = _Metallic;
				o.Smoothness = _Smoothness;
				o.normalDir = worldNormalDir;
				o.viewDir = worldViewDir;
				o.lightDir = worldLightDir;
				o.halfDir = worldHalfDir;
				return LightingStandard(o);
#endif
#if POINT_LIGHT_ON
				//Point light properties
				lightColor = _pointLightColor.xyz;
				lightDir = _pointLightPos - i.wPos;
				float lightDist = length(lightDir);
				lightDir = lightDir / lightDist;
				//lightDir *= 4 * 3.14;

				//Diffuse componenet
				difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.worldNormal), 0, 1)/ lightDist;

				//Specular component	
				viewVec = normalize(_WorldSpaceCameraPos - i.wPos);

				//Specular component
				//phong
				//float3 halfVec = reflect(-lightDir, i.worldNormal);
				//fixed4 specularComp = lightColor * pow(clamp(dot(halfVec, viewVec),0,1), _scecularExp);

				//blinnPhong
				halfVec = normalize(viewVec + lightDir);
				specularComp = lightColor * pow(max(dot(halfVec, i.worldNormal), 0), _scecularExp) / lightDist;

				//Sum
				finalColor += clamp(float4(_pointLightIntensity*(difuseComp + specularComp),1),0,1);
				
				
				o.Albedo = tex2D(_MainTex, i.uv);
				o.Metallic = _Metallic;
				o.Smoothness = _Smoothness;
				o.normalDir = worldNormalDir;
				o.viewDir = worldViewDir;
				o.lightDir = worldLightDir;
				o.halfDir = worldHalfDir;
				return LightingStandard(o);
				
#endif
				//pointLight
                
				return finalColor * _objectColor;
            }

			
            ENDCG
        }
    }
}
