using UnityEngine;

[CreateAssetMenu(fileName = "GameAudio", menuName = "Audio/GameAudio")]
[System.Serializable]
public class AudioSO : ScriptableObject
{
    public string audioName;
    public string refName;
    public AudioClip audioClip;
    [Range(0f, 1f)]
    public float volume = 1;
    [Range(.1f, 3f)]
    public float pitch = 1;

    public bool loop;

    [HideInInspector]
    public AudioSource source;
    public bool isSFX;

}
