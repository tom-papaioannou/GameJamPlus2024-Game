using UnityEngine;

public class InteractionWall : MonoBehaviour
{
    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log("Wall Hit!");
    }
}
