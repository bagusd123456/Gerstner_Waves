using UnityEngine;
using UnityEditor;

public class WaterManager : MonoSingleton<WaterManager>
{
	public enum Preset
    {
		Calm,
		Wavy,
		Custom
    };

	[SerializeField] private Material material;
	[SerializeField] [Range(16, 255)] private int resolution = 255;
	[SerializeField] private Vector3 scaleCustom;

	public bool RealTimeEdit;
	public Preset WavePreset;

	[SerializeField] private WaveData WaveA;
	[SerializeField] private WaveData WaveB;
	[SerializeField] private WaveData WaveC;
	[SerializeField] private WaveData WaveD;
	[SerializeField] private WaterData Water;

	#region Non Serialized
	private GameObject waterObject;
	private MeshFilter waterMeshFilter;
	private MeshRenderer waterMeshRenderer;
	private Mesh waterMesh;

	private WaveData calmA;
	private WaveData calmB;
	private WaveData calmC;
	private WaveData calmD;

	private WaveData wavyA;
	private WaveData wavyB;
	private WaveData wavyC;
	private WaveData wavyD;
	#endregion

	private void OnValidate()
    {
		scaleCustom.x = Mathf.Max(0.0001f, scaleCustom.x);
		scaleCustom.y = Mathf.Max(0.0001f, scaleCustom.y);

        switch (WavePreset)
        {
            case Preset.Calm:
                if (WaveA == calmA && WaveA == calmB && WaveA == calmC && WaveA == calmD)
                {
					return;
                }

				calmA = new WaveData(new Vector2(0.45f, 1f), 0.05f, 5f);
				calmB = new WaveData(new Vector2(1f, 5f), 0.05f, 5f);
				calmC = new WaveData(new Vector2(0.5f, 0.75f), 0.05f, 5f);
				calmD = new WaveData(new Vector2(0.45f, 0.3f), 0.05f, 5f);

				WaveA = calmA;
				WaveB = calmB;
				WaveC = calmC;
				WaveD = calmD;
				break;
            case Preset.Wavy:
				if (WaveA == wavyA && WaveA == wavyB && WaveA == wavyC && WaveA == wavyD)
				{
					return;
				}

				wavyA = new WaveData(new Vector2(0.45f, 0.25f), 0.15f, 17f);
				wavyB = new WaveData(new Vector2(1f, -1f), 0.05f, 5f);
				wavyC = new WaveData(new Vector2(0.65f, 0.75f), 0.35f, 25f);
				wavyD = new WaveData(new Vector2(0.45f, 0.3f), 0.05f, 5f);

				WaveA = wavyA;
				WaveB = wavyB;
				WaveC = wavyC;
				WaveD = wavyD;
				break;
        }

        if (RealTimeEdit)
        {
			SetData();
		}
    }

    public void GenerateMesh()
    {
		int[] meshTriangles = new int[resolution * resolution * 6];
		Vector3[] meshVertices = new Vector3[(resolution + 1) * (resolution + 1)];
		Vector2[] meshUV = new Vector2[meshVertices.Length];
		Vector4[] meshTangents = new Vector4[meshVertices.Length];

		int tris = 0;
		int vert = 0;

		for (int y = 0, i = 0; y <= resolution; y++)
		{
			for (int x = 0; x <= resolution; x++, i++)
			{
				meshVertices[i] = new Vector3(x, 0, y);
				meshUV[i] = new Vector2((float)x / resolution, (float)y / resolution);
				meshTangents[i] = new Vector4(1f, 0f, 0f, -1f);
			}
		}
		for (int y = 0; y < resolution; y++)
		{
			for (int x = 0; x < resolution; x++)
			{
				meshTriangles[tris + 0] = vert + 0;
				meshTriangles[tris + 1] = vert + resolution + 1;
				meshTriangles[tris + 2] = vert + 1;
				meshTriangles[tris + 3] = vert + 1;
				meshTriangles[tris + 4] = vert + resolution + 1;
				meshTriangles[tris + 5] = vert + resolution + 2;
				vert++;
				tris += 6;
			}
			vert++;
		}

        if (transform.childCount == 0)
        {
			if (waterObject == null)
			{
				waterObject = new GameObject
				{
					name = "Water_Plane"
				};

				waterObject.transform.parent = this.transform;
			}
		}

		waterObject.transform.localScale = scaleCustom;

		waterMesh = new Mesh()
		{
			name = "Procedural Mesh"
		};
		waterMesh.vertices = meshVertices;
		waterMesh.uv = meshUV;
		waterMesh.triangles = meshTriangles;
		waterMesh.tangents = meshTangents;
		waterMesh.RecalculateBounds();
		waterMesh.RecalculateNormals();

		if (waterObject.TryGetComponent(out MeshFilter meshFilter))
		{
			waterMeshFilter = meshFilter;
		}
		else
		{
			waterMeshFilter = waterObject.AddComponent<MeshFilter>();
		}
		if (waterObject.TryGetComponent(out MeshRenderer meshRenderer))
		{
			waterMeshRenderer = meshRenderer;
		}
		else
		{
			waterMeshRenderer = waterObject.AddComponent<MeshRenderer>();
		}

		waterMeshFilter.sharedMesh = waterMesh;
		waterMeshRenderer.sharedMaterial = material;
		waterMeshRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
	}
	public void GetData()
    {
        if (material == null)
        {
			Debug.LogError("Material not found !");
			return;
        }

		WaveA = new WaveData(material.GetVector("Wave_A"), material.GetVector("Wave_A").z, material.GetVector("Wave_A").w);
		WaveB = new WaveData(material.GetVector("Wave_B"), material.GetVector("Wave_B").z, material.GetVector("Wave_B").w);
		WaveC = new WaveData(material.GetVector("Wave_C"), material.GetVector("Wave_C").z, material.GetVector("Wave_C").w);
		WaveD = new WaveData(material.GetVector("Wave_D"), material.GetVector("Wave_D").z, material.GetVector("Wave_D").w);

		Water = new WaterData
			(material.GetColor("TopColor"), material.GetColor("BottomColor"), material.GetColor("ShallowColor"),
			material.GetFloat("DepthColorFade"), material.GetFloat("DepthColorOffset"), material.GetFloat("DepthDistance"),
			material.GetFloat("_Specular"), material.GetFloat("Smoothness"), material.GetTexture("NormalMap"),
			material.GetFloat("NormalStrength"), material.GetFloat("NormalTiling_A"), material.GetFloat("NormalTiling_B"),
			material.GetFloat("NormalPanningSpeed"), material.GetVector("NormalPanningDirection_A"), material.GetVector("NormalPanningDirection_B"),
			material.GetFloat("RefractionStrength"), material.GetFloat("RefractionSpeed"), material.GetFloat("RefractionScale"),
			material.GetTexture("FoamTexture"), material.GetVector("FoamTextureSpeed"), material.GetFloat("FoamDistance"),
			material.GetFloat("FoamStrength"), material.GetFloat("FoamTiling"), material.GetFloat("FoamTextureTiling"),
			material.GetFloat("FoamTextureHeight"), material.GetFloat("FoamTextureBlendPower")
			);
	}
	public void SetData()
    {
		if (material == null)
		{
			Debug.LogError("Material not found !");
			return;
		}

		material.SetVector("Wave_A", new Vector4(WaveA.Direction.x, WaveA.Direction.y, WaveA.Steepness, WaveA.Wavelength));
		material.SetVector("Wave_B", new Vector4(WaveB.Direction.x, WaveB.Direction.y, WaveB.Steepness, WaveB.Wavelength));
		material.SetVector("Wave_C", new Vector4(WaveC.Direction.x, WaveC.Direction.y, WaveC.Steepness, WaveC.Wavelength));
		material.SetVector("Wave_D", new Vector4(WaveD.Direction.x, WaveD.Direction.y, WaveD.Steepness, WaveD.Wavelength));

		material.SetColor("TopColor", Water.TopColor); material.SetColor("BottomColor", Water.BottomColor); material.SetColor("ShallowColor", Water.ShallowColor);
		material.SetFloat("DepthColorFade", Water.DepthColorFade); material.SetFloat("DepthColorOffset", Water.DepthColorOffset); material.SetFloat("DepthDistance", Water.DepthDistance);
		material.SetFloat("_Specular", Water.Specular); material.SetFloat("Smoothness", Water.Smoothness); material.SetTexture("NormalMap", Water.NormalMap);
		material.SetFloat("NormalStrength", Water.NormalStrength); material.SetFloat("NormalTiling_A", Water.NormalTilingA); material.SetFloat("NormalTiling_B", Water.NormalTilingB);
		material.SetFloat("NormalPanningSpeed", Water.NormalSpeed); material.SetVector("NormalPanningDirection_A", Water.NormalDirectionA); material.SetVector("NormalPanningDirection_B", Water.NormalDirectionB);
		material.SetFloat("RefractionStrength", Water.RefractionStrength); material.SetFloat("RefractionSpeed", Water.RefractionSpeed); material.SetFloat("RefractionScale", Water.RefractionScale);
		material.SetTexture("FoamTexture", Water.FoamDiffuse); material.SetVector("FoamTextureSpeed", Water.FoamSpeed); material.SetFloat("FoamDistance", Water.FoamLineDistance);
		material.SetFloat("FoamStrength", Water.FoamLineStrength); material.SetFloat("FoamTiling", Water.FoamLineTiling); material.SetFloat("FoamTextureTiling", Water.FoamWaveTiling);
		material.SetFloat("FoamTextureHeight", Water.FoamWaveHeight); material.SetFloat("FoamTextureBlendPower", Water.FoamWaveBlend);
	}
	public float GetWaveHeight(Vector3 position)
	{
		float time = Time.timeSinceLevelLoad;
		Vector3 currentPosition = GetWaveAddition(position, time);

		for (int i = 0; i < 3; i++)
		{
			Vector3 diff = new Vector3(position.x - currentPosition.x, 0, position.z - currentPosition.z);
			currentPosition = GetWaveAddition(diff, time);
		}

		return currentPosition.y;
	}
	private Vector3 GetWaveAddition(Vector3 position, float timeSinceStart)
	{
		Vector3 result = new Vector3();

		result += GerstnerWave(position, WaveA.Direction, WaveA.Steepness, WaveA.Wavelength, timeSinceStart);
		result += GerstnerWave(position, WaveB.Direction, WaveB.Steepness, WaveB.Wavelength, timeSinceStart);
		result += GerstnerWave(position, WaveC.Direction, WaveC.Steepness, WaveC.Wavelength, timeSinceStart);
		result += GerstnerWave(position, WaveD.Direction, WaveD.Steepness, WaveD.Wavelength, timeSinceStart);

		return result;
	}
	private Vector3 GerstnerWave(Vector3 position, Vector2 Direction, float Steepness, float Wavelength, float timeSinceStart)
	{
		Vector2 normalizedDirection = Direction.normalized;
		float k = 2 * Mathf.PI / Wavelength;	
		float c = Mathf.Sqrt(9.8f / k);
		float f = k * (Vector2.Dot(normalizedDirection, new Vector2(position.x, position.z)) - c * timeSinceStart);
		float a = Steepness / k;

		return new Vector3(normalizedDirection.x * a * Mathf.Cos(f), a * Mathf.Sin(f), normalizedDirection.y * a * Mathf.Cos(f));
	}

	[System.Serializable]
	public class WaveData
	{
		public Vector2 Direction;
		[Range(-1.0f, 1.0f)] public float Steepness;
		public float Wavelength;

		public WaveData(Vector2 direction, float steepness, float wavelength)
		{
			Direction = direction;
			Steepness = steepness;
			Wavelength = wavelength;
		}
	}
    [System.Serializable]
    public class WaterData
    {
		[Header("Color")]
        public Color TopColor;
        public Color BottomColor;
        public Color ShallowColor;
		public float DepthColorFade;
		public float DepthColorOffset;
		public float DepthDistance;
		[Range(0.0f, 1.0f)] public float Specular;
		[Range(0.0f, 1.0f)] public float Smoothness;

		[Header("Normal")]
		public Texture NormalMap;
		public float NormalStrength;
		public float NormalTilingA;
		public float NormalTilingB;
		public float NormalSpeed;
		public Vector2 NormalDirectionA;
		public Vector2 NormalDirectionB;

		[Header("Refraction")]
		public float RefractionStrength;
		public float RefractionSpeed;
		public float RefractionScale;

		[Header("Foam")]
		public Texture FoamDiffuse;
		public Vector2 FoamSpeed;
		public float FoamLineDistance;
		public float FoamLineStrength;
		public float FoamLineTiling;
		public float FoamWaveTiling;
		public float FoamWaveHeight;
		public float FoamWaveBlend;

        public WaterData
			(Color topColor, Color bottomColor, Color shallowColor, 
			float depthColorFade, float depthColorOffset, float depthDistance, 
			float specular, float smoothness, Texture normalMap, 
			float normalStrength, float normalTilingA, float normalTilingB, 
			float normalSpeed, Vector2 normalDirectionA, Vector2 normalDirectionB, 
			float refractionStrength, float refractionSpeed, float refractionScale,
			Texture foamDiffuse, Vector2 foamSpeed, float foamLineDistance, 
			float foamLineStrength, float foamLineTiling, float foamWaveTiling, 
			float foamWaveHeight, float foamWaveBlend)
        {
            TopColor = topColor;
            BottomColor = bottomColor;
            ShallowColor = shallowColor;
            DepthColorFade = depthColorFade;
            DepthColorOffset = depthColorOffset;
            DepthDistance = depthDistance;
            Specular = specular;
            Smoothness = smoothness;
            NormalMap = normalMap;
            NormalStrength = normalStrength;
            NormalTilingA = normalTilingA;
            NormalTilingB = normalTilingB;
            NormalSpeed = normalSpeed;
            NormalDirectionA = normalDirectionA;
            NormalDirectionB = normalDirectionB;
            RefractionStrength = refractionStrength;
            RefractionSpeed = refractionSpeed;
            RefractionScale = refractionScale;
            FoamDiffuse = foamDiffuse;
            FoamSpeed = foamSpeed;
            FoamLineDistance = foamLineDistance;
            FoamLineStrength = foamLineStrength;
            FoamLineTiling = foamLineTiling;
            FoamWaveTiling = foamWaveTiling;
            FoamWaveHeight = foamWaveHeight;
            FoamWaveBlend = foamWaveBlend;
        }
    }
}
[CustomEditor(typeof(WaterManager))]
public class WaterEditor : Editor
{
	public override void OnInspectorGUI()
	{
		WaterManager Water = (WaterManager)target;

		EditorGUILayout.LabelField("General", EditorStyles.miniButtonMid);

		GUILayout.BeginVertical("box");
        {
			EditorGUILayout.PropertyField(serializedObject.FindProperty("material"));
			EditorGUILayout.PropertyField(serializedObject.FindProperty("resolution"));
			EditorGUILayout.PropertyField(serializedObject.FindProperty("scaleCustom"));
			EditorGUILayout.PropertyField(serializedObject.FindProperty("RealTimeEdit"));
			EditorGUILayout.PropertyField(serializedObject.FindProperty("WavePreset"));
		}
		GUILayout.EndVertical();

		EditorGUILayout.Space();
		GUILayout.BeginVertical("box");
		{
			if (GUILayout.Button("Generate Mesh"))
			{
				Water.GenerateMesh();
			}
			if (GUILayout.Button("Get Material Data"))
			{
				Water.GetData();
			}
            if (!Water.RealTimeEdit)
            {
				if (GUILayout.Button("Set Material Data"))
				{
					Water.SetData();
				}
			}
		}
		GUILayout.EndVertical();
		EditorGUILayout.Space();

        if (Water.WavePreset == WaterManager.Preset.Custom)
        {
			EditorGUILayout.PropertyField(serializedObject.FindProperty("WaveA"));
			EditorGUILayout.PropertyField(serializedObject.FindProperty("WaveB"));
			EditorGUILayout.PropertyField(serializedObject.FindProperty("WaveC"));
			EditorGUILayout.PropertyField(serializedObject.FindProperty("WaveD"));
		}

		EditorGUILayout.PropertyField(serializedObject.FindProperty("Water"));
		EditorGUILayout.Space();

		serializedObject.ApplyModifiedProperties();
	}
}