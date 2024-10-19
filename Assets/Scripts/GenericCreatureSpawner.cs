using UnityEngine;
using UnityEngine.Pool;

public class GenericCreatureSpawner : MonoBehaviour
{
    public ObjectPool<GenericCreature> _pool;

    [SerializeField] private GenericCreature _genericCreaturePrefab;

    private void Start()
    {
        _pool = new ObjectPool<GenericCreature>(CreateGenericCreature, OnTakeGenericCreatureFromPool, OnReturnGenericCreatureToPool, OnDestroyGenericCreature, true);

    }

    private GenericCreature CreateGenericCreature()
    {
        //Spawn new instance of a projectile

        GenericCreature genericCreature = Instantiate(_genericCreaturePrefab, transform.position, Quaternion.identity);

        //Assign the card projectile's pool

        genericCreature.SetPool(_pool);

        return genericCreature;
    }

    private void OnTakeGenericCreatureFromPool(GenericCreature genericCreature)
    {

        genericCreature.gameObject.SetActive(true);

        //genericProjectile._particleSystem.Play(true);
    }

    private void OnReturnGenericCreatureToPool(GenericCreature genericCreature)
    {
        genericCreature.gameObject.SetActive(false);
    }

    private void OnDestroyGenericCreature(GenericCreature genericCreature)
    {
        Destroy(genericCreature.gameObject);
    }
}
