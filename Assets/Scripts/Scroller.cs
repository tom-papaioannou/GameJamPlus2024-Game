using UnityEngine;

public class Scroller : MonoBehaviour
{
    public float moveSpeed = 1f;

    private void Start()
    {
        moveSpeed = GameData.Instance.objectSpeed;
    }

    void Update()
    {
        transform.Translate(0, 0, -moveSpeed * Time.deltaTime, Space.World);

        if (transform.position.z <= -40.0)
        {
            transform.position = new Vector3(0.0f, transform.position.y, 40.0f);
        }
    }
}
