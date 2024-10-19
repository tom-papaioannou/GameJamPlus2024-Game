using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioManager : SingletonNotHide<AudioManager>
{
    [SerializeField] private AudioSource audioSourcePrefab;
    
    private int lastPlayedIndex = 0;
    private AudioSource audioSource;
    private AudioSource previousAudioSource;


    //IEnumerator Start()
    //{
    //    PlayAudio("WhispersandIsland");
    //    yield return new WaitForSeconds(4);
    //    PlayAudio("WhispersandIsland");
    //}
    public void PlayAudio(string refName)
    {
        if (string.IsNullOrEmpty(refName)) return;

        StartCoroutine(LoadAndPlayAudio(refName));

    }

    private IEnumerator LoadAndPlayAudio(string refName)
    {
        // Load the AudioSO asset asynchronously
        ResourceRequest loadRequest = Resources.LoadAsync<AudioSO>("Audio/SO/" + refName);
        yield return loadRequest;

        AudioSO audioSO = loadRequest.asset as AudioSO;
        if (audioSO == null)
        {
            Debug.LogError("Failed to load AudioSO: " + refName);
            yield break;
        }

        // If there is a previous audio source, fade it out over 1 second
        if (previousAudioSource != null && !audioSO.isSFX)
        {
            AudioSource tempAudioSource = previousAudioSource;
            previousAudioSource.DOFade(0, 1).OnComplete(() =>
            {
                tempAudioSource.DOKill();
                if (tempAudioSource.gameObject != gameObject) Destroy(tempAudioSource.gameObject);
                else Destroy(tempAudioSource);
            });
        }

        // Create a new audio source for the new audio clip
        audioSource = gameObject.AddComponent<AudioSource>();

        audioSource.clip = audioSO.audioClip;
        audioSource.volume = 0;
        audioSource.pitch = audioSO.pitch;
        audioSource.loop = audioSO.loop;
        audioSource.playOnAwake = false;
        

        if (!audioSO.isSFX)
        {
            DOTween.Sequence()
                .AppendInterval(1)
                .Append(audioSource.DOFade(audioSO.volume, 1)).OnComplete(() =>
                {
                    if (audioSource.loop) previousAudioSource = audioSource;
                });
        }
        else audioSource.volume = audioSO.volume;
        audioSource.Play();

        float clipLength = audioSource.clip.length;
        if (!audioSO.loop)
        {
            DOTween.Sequence()
                .AppendInterval(clipLength).OnComplete(() =>
                {
                    previousAudioSource = audioSource;
                    Destroy(audioSource);
                });
        }
        else
        {
            previousAudioSource = audioSource;
        }
    }


    public void PlayAudioAtLocation(string refName, Vector3 position)
    {
        if (string.IsNullOrEmpty(refName)) return;

        StartCoroutine(LoadAndPlayAudioAtLocation(refName, position));

    }

    private IEnumerator LoadAndPlayAudioAtLocation(string refName, Vector3 position)
    {
        ResourceRequest loadRequest = Resources.LoadAsync<AudioSO>("Audio/SO/" + refName);
        yield return loadRequest;

        AudioSO audioSO = loadRequest.asset as AudioSO;
        if (audioSO == null)
        {
            Debug.LogError("Failed to load AudioSO: " + refName);
            yield break;
        }

        if (previousAudioSource != null && !audioSO.isSFX)
        {
            AudioSource tempAudioSource = previousAudioSource;
            previousAudioSource.DOFade(0, 1).OnComplete(() =>
            {
                tempAudioSource.DOKill();
                if (tempAudioSource.gameObject != gameObject) Destroy(tempAudioSource.gameObject);
                else Destroy(tempAudioSource);
            });
        }

        audioSource = Instantiate(audioSourcePrefab, position, Quaternion.identity);

        audioSource.clip = audioSO.audioClip;
        audioSource.volume = 0;
        audioSource.pitch = audioSO.pitch;
        audioSource.loop = audioSO.loop;
        audioSource.playOnAwake = false;
        

        if (!audioSO.isSFX)
        {
            DOTween.Sequence()
            .AppendInterval(1)
            .Append(audioSource.DOFade(audioSO.volume, 1)).OnComplete(() =>
            {
                if (audioSource.loop) previousAudioSource = audioSource;
            });
        }
        else audioSource.volume = audioSO.volume;
        audioSource.Play();

        float clipLength = audioSource.clip.length;
        if (!audioSO.loop)
        {
            DOTween.Sequence()
            .AppendInterval(clipLength).OnComplete(() =>
            {
                previousAudioSource = audioSource;
                Destroy(audioSource);
            });
        }
        else
        {
            previousAudioSource = audioSource;
        }
    }

    public void PlayerRoundRobinAudioAtLocation(List<string> refNames, Vector3 position)
    {
        StartCoroutine(LoadAndPlayerRoundRobinAudioAtLocation(refNames, position));

    }

    private IEnumerator LoadAndPlayerRoundRobinAudioAtLocation(List<string> refNames, Vector3 position)
    {
        lastPlayedIndex = (lastPlayedIndex + 1) % refNames.Count;

        string refName = refNames[lastPlayedIndex];

        ResourceRequest loadRequest = Resources.LoadAsync<AudioSO>("Audio/SO/" + refName);
        yield return loadRequest;

        AudioSO audioSO = loadRequest.asset as AudioSO;
        if (audioSO == null)
        {
            Debug.LogError("Failed to load AudioSO: " + refName);
            yield break;
        }

        if (previousAudioSource != null && !audioSO.isSFX)
        {
            AudioSource tempAudioSource = previousAudioSource;
            previousAudioSource.DOFade(0, 1).OnComplete(() =>
            {
                tempAudioSource.DOKill();
                if (tempAudioSource.gameObject != gameObject) Destroy(tempAudioSource.gameObject);
                else Destroy(tempAudioSource);
            });
        }

        audioSource = Instantiate(audioSourcePrefab, position, Quaternion.identity);

        audioSource.clip = audioSO.audioClip;
        audioSource.volume = 0;
        audioSource.pitch = audioSO.pitch;
        audioSource.loop = audioSO.loop;
        audioSource.playOnAwake = false;
        
        if (!audioSO.isSFX)
        {
            DOTween.Sequence()
            .AppendInterval(1)
            .Append(audioSource.DOFade(audioSO.volume, 1)).OnComplete(() =>
            {
                if (audioSource.loop) previousAudioSource = audioSource;
            });
        }
        else audioSource.volume = audioSO.volume;
        audioSource.Play();

        float clipLength = audioSource.clip.length;
        if (!audioSO.loop)
        {
            DOTween.Sequence()
            .AppendInterval(clipLength).OnComplete(() =>
            {
                previousAudioSource = audioSource;
                Destroy(audioSource);
            });
        }
        else
        {
            previousAudioSource = audioSource;
        }
    }

    public void StopCurrentAudio()
    {
       
        if (previousAudioSource != null)
        {
            AudioSource tempAudioSource = previousAudioSource;
            previousAudioSource.DOFade(0, 1).OnComplete(() =>
            {
                tempAudioSource.DOKill();
                if (tempAudioSource.gameObject != gameObject) Destroy(tempAudioSource.gameObject);
                else Destroy(tempAudioSource);
                previousAudioSource.Stop();
                audioSource = null;
                previousAudioSource = null;
            });
        }
    }

    public void PauseAudio()
    {
        if(audioSource!= null) audioSource.Pause();
    }

    public void ResumeAudio()
    {
        if (audioSource != null) audioSource.UnPause();
    }

    private void OnDestroy()
    {
        if (audioSource != null)
        {
            if (previousAudioSource != null)
            {
                previousAudioSource.DOKill();
                if (!previousAudioSource.gameObject.GetComponent<AudioManager>()) Destroy(previousAudioSource.gameObject);
            }
            audioSource.DOKill();
            if (!audioSource.gameObject.GetComponent<AudioManager>()) Destroy(audioSource.gameObject);
            audioSource = null;
        }
        
    }

}
