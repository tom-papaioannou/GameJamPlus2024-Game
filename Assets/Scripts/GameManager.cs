using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    [SerializeField] private GameObject[] enemies;
    [SerializeField] private Transform enemySpawnPosition;
    [SerializeField] private TMP_Text _pointsText;
    [SerializeField] private GameObject _gameOverPanel;
    [SerializeField] private GameObject _player;
    private GameObject currentEnemy;
    private int _points = 0;
    private bool gameOver = false;

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
        _pointsText.SetText("Points: " + _points);
        GameData.Instance.objectSpeed++;
    }

    private void GameOver()
    {
        _gameOverPanel.SetActive(true);
        Destroy(_player);
        gameOver = true;
    }

    public void RestartClicked()
    {
        SceneManager.LoadScene(0);
    }

    public void ExitClicked()
    {
        Application.Quit();
    }

    void Update()
    {

        if (currentEnemy != null && currentEnemy.transform.position.z <= -30)
        {
            Destroy(currentEnemy.gameObject);
            if(!gameOver)
                SpawnRandomEnemy();
        }
    }

    private void SpawnRandomEnemy()
    {
        int index = Random.Range(0, enemies.Length);
        currentEnemy = Instantiate(enemies[index], enemySpawnPosition);
    }
}
