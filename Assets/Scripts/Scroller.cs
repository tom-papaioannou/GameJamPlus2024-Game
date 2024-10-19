using UnityEngine;

public class Scroller : MonoBehaviour
{
    public float moveSpeed = 1f;

    void Update()
    {
        transform.Translate(0, 0, -moveSpeed * Time.deltaTime, Space.World);

        if (transform.position.z <= -40.0)
        {
            transform.position = new Vector3(0.0f, transform.position.y, 40.0f);
        }
    }
}
