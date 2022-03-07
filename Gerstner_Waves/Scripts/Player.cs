using UnityEngine;
using UnityEditor;

public class Player : MonoBehaviour
{
    [InspectorName("Settings")]
    [SerializeField] private Camera cameraObject;
    [SerializeField] [Range(0.01f, 1f)] private float sensitivity;
    [SerializeField] private float speed;
    [SerializeField] private float acceleration;

    #region Non Serialized
    private PlayerInput input;
    private Vector3 velocity;
    private int speedMultiplier = 1; 
    #endregion  

    private void Awake()
    {
        input = GetComponent<PlayerInput>();

        //GameManager.OnFOVChange += () => cameraObject.fieldOfView = GameManager.Instance.TargetFOV;
    }
    private void Update() => Move();
    private void LateUpdate() => Look();

    private void Look()
    {
        transform.rotation *= Quaternion.AngleAxis(-input.LookInput.y * sensitivity, Vector3.right);
        transform.rotation = Quaternion.Euler(transform.eulerAngles.x, transform.eulerAngles.y + input.LookInput.x * sensitivity, transform.eulerAngles.z);
    }
    private void Move()
    {
        if (input.ScrollInput > 0)
        {
            speedMultiplier += 1;
        }
        else if (input.ScrollInput < 0)
        {
            speedMultiplier = Mathf.Max(speedMultiplier - 1, 1);
        }

        Vector3 worldSpaceMoveInput = speed * speedMultiplier * transform.TransformVector(input.MoveInput.x, 0f, input.MoveInput.y);
        velocity = Vector3.Lerp(velocity, worldSpaceMoveInput, acceleration * Time.deltaTime);

        transform.position += velocity * Time.deltaTime;
    }
}
[CustomEditor(typeof(Player))]
public class PlayerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        Player Player = (Player)target;

        EditorGUILayout.LabelField("General", EditorStyles.miniButtonMid);
        EditorGUILayout.PropertyField(serializedObject.FindProperty("cameraObject"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("sensitivity"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("speed"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("acceleration"));
        EditorGUILayout.Space();

        serializedObject.ApplyModifiedProperties();
    }
}