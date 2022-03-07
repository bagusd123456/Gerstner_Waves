using UnityEngine;
using UnityEditor;

public class GameManager : MonoSingleton<GameManager>
{
    public delegate void SettingsChanged();
    public static event SettingsChanged OnFOVChange;
    public static event SettingsChanged OnFPSChange;

    [Range(24, 100)] public int TargetFPS;
    [Range(45, 100)] public float TargetFOV;
    public CursorLockMode CursorMode;
    public Audio GameAudio;   

    #region Non Serialized
    private int baseFPS;
    private float baseFOV;
    #endregion

    private void Awake()
    {
        QualitySettings.maxQueuedFrames = 0;
        Cursor.lockState = CursorLockMode.Locked;
        OnFOVChange += () => baseFOV = TargetFOV;
        OnFPSChange += () => Application.targetFrameRate = baseFPS = TargetFPS;    
    }
    private void Start()
    {
        OnFPSChange?.Invoke();
        OnFOVChange?.Invoke();
    }
    private void Update()
    {
        if (TargetFPS != baseFPS)
        {
            OnFPSChange?.Invoke();
        }
        if (TargetFOV != baseFOV)
        {
            OnFOVChange?.Invoke();
        }
        switch (CursorMode)
        {
            case CursorLockMode.None:
                if (Cursor.lockState != CursorLockMode.None)
                {
                    Cursor.lockState = CursorLockMode.None;
                }                          
                break;
            case CursorLockMode.Locked:
                if (Cursor.lockState != CursorLockMode.Locked)
                {
                    Cursor.lockState = CursorLockMode.Locked;
                }             
                break;
            case CursorLockMode.Confined:
                if (Cursor.lockState != CursorLockMode.Confined)
                {
                    Cursor.lockState = CursorLockMode.Confined;
                }             
                break;
        }
    }

    [System.Serializable]
    public class Audio
    {
        [SerializeField] private AudioSource effectSource;
        [SerializeField] private AudioSource musicSource;

        public void PlaySound(AudioClip clip)
        {
            if (clip == null)
            {
                return;
            }

            effectSource.PlayOneShot(clip);
        }
        public void PlayMusic(AudioClip clip)
        {
            if (clip == null)
            {
                return;
            }

            if (musicSource.isPlaying)
            {
                return;
            }

            musicSource.PlayOneShot(clip);
        }
        public void ChangeMasterVolume(float value)
        {
            if (value < 0)
            {
                Debug.LogError("Enter a valid value.");
                return;
            }

            AudioListener.volume = value;
        }
    }
}
[CustomEditor(typeof(GameManager))]
public class GameManagerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        GameManager Player = (GameManager)target;

        EditorGUILayout.LabelField("General", EditorStyles.miniButtonMid);
        EditorGUILayout.PropertyField(serializedObject.FindProperty("CursorMode"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("TargetFPS"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("TargetFOV"));        
        EditorGUILayout.Space();

        EditorGUILayout.LabelField("Audio", EditorStyles.miniButtonMid);
        EditorGUILayout.PropertyField(serializedObject.FindProperty("GameAudio"));
        EditorGUILayout.Space();

        serializedObject.ApplyModifiedProperties();
    }
}