using UnityEngine;

public class GameManager : MonoBehaviour
{
    [SerializeField] private GameObject[] enemies;
    [SerializeField] private Transform enemySpawnPosition;
    private GameObject currentEnemy;

    void Start()
    {
        SpawnRandomEnemy();
    }

    void Update()
    {

        if (currentEnemy.transform.position.z <= -30)
        {
            Destroy(currentEnemy.gameObject);
            SpawnRandomEnemy();
        }
    }

    private void SpawnRandomEnemy()
    {
        int index = Random.Range(0, enemies.Length);
        currentEnemy = Instantiate(enemies[index], enemySpawnPosition);
    }
}
