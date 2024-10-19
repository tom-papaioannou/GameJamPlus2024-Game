using System.Collections;
using UnityEngine;
using UnityEngine.Pool;

public class GenericCreature : MonoBehaviour
{
    [SerializeField] private float destroyTime = 3.0f;
    private ObjectPool<GenericCreature> _pool;
    Coroutine destroyOnTime;
    private void OnEnable()
    {
        destroyOnTime = StartCoroutine(DestroyOnTime());
    }

    IEnumerator DestroyOnTime()
    {
        yield return new WaitForSeconds(destroyTime);

        _pool.Release(this);
    }

    public void SetPool(ObjectPool<GenericCreature> pool)
    {
        _pool = pool;
    }

    public void ReleaseCreature()
    {
        _pool.Release(this);
    }
}
