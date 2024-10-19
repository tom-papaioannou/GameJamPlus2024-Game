using UnityEngine;

public class GameManager : MonoBehaviour
{
    [SerializeField] private GameObject[] enemies;
    [SerializeField] private Transform enemySpawnPosition;
    private GameObject currentEnemy;
    private int _points = 0;

    void Start()
    {
        SpawnRandomEnemy();
    }

    private void OnEnable()
    {
        PlayerController.OnPlayerGotPoint += AddPoint;
        PlayerController.OnPlayerHitWall += GameOver;
    }

    private void OnDisable()
    {
        PlayerController.OnPlayerGotPoint -= AddPoint;
        PlayerController.OnPlayerHitWall -= GameOver;
    }

    private void AddPoint()
    {
        _points++;
    }

    private void GameOver()
    {
        Debug.Log("GameOver");
        Debug.Log("Final points: " + _points);
        Time.timeScale = 0.0f;
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
