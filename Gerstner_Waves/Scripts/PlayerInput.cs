using UnityEngine;

public class PlayerInput : MonoBehaviour
{   
    [HideInInspector] public Vector2 MoveInput { get; set; }
    [HideInInspector] public Vector2 LookInput { get; set; }
    [HideInInspector] public float ScrollInput { get; set; }

    private Input input;

    private void OnEnable()
    {
        if (input == null)
        {
            input = new Input();

            input.Gameplay.Move.performed += i => MoveInput = i.ReadValue<Vector2>();
            input.Gameplay.Look.performed += i => LookInput = i.ReadValue<Vector2>();
            input.Gameplay.Scroll.performed += i => ScrollInput = i.ReadValue<float>();
        }

        input.Enable();
    }
    private void OnDisable() => input.Disable();
}
