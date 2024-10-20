using DG.Tweening;
using System.Collections;
using UnityEngine;

public class FlappingBirdSpawner : MonoBehaviour
{
    [SerializeField] GenericCreatureSpawner _spawner;

    public float spawnInterval = 1.5f; // Time interval between spawns
    public float xMin = -8f;           // Minimum x value for spawning (clamp)
    public float xMax = 8f;            // Maximum x value for spawning (clamp)
    public float moveDuration = 5f;    // Duration for the bird to move from bottom to top of the screen
    public float yStart = -6f;         // Starting y position (bottom of screen)
    public float yEnd = 6f;            // Ending y position (top of screen)

    private float screenWidthHalf;
    private float initialInterval;
    void Start()
    {
        initialInterval = spawnInterval;
        // Start the spawning coroutine
        StartCoroutine(SpawnBirds());
        
    }

    IEnumerator SpawnBirds()
    {
        yield return new WaitForEndOfFrame();

        while (true)
        {
            SpawnBird();
            spawnInterval = Random.Range(initialInterval, initialInterval+3);
            yield return new WaitForSeconds(spawnInterval); // Delay before spawning the next bird
        }
    }

    void SpawnBird()
    {
        // Random x position clamped between min and max
        float randomX = Random.Range(xMin, xMax);

        // Spawn the bird at a random x position at the bottom of the screen (yStart)
        Vector3 spawnPosition = new Vector3(randomX, yStart, 0);

        // Instantiate the bird
        GenericCreature bird = _spawner._pool.Get();
        bird.transform.position = spawnPosition;
        bird.transform.localEulerAngles = new Vector3(90, 0, 0);
        // Move the bird using DOTween from bottom to top of the screen
        MoveBird(bird.gameObject);
    }

    void MoveBird(GameObject bird)
    {
        // Move the bird to the top of the screen (yEnd) over a duration
        bird.transform.DOMoveZ(yEnd, moveDuration).SetEase(Ease.Linear).OnComplete(() =>
        {
            Destroy(bird); // Destroy the bird once it reaches the top of the screen
        });
    }
}
