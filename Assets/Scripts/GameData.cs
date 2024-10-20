using UnityEngine;

public class GameData : MonoBehaviour
{
    public static GameData Instance;
    public int objectSpeed = 5;

    private void Awake()
    {
        if(Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

}
