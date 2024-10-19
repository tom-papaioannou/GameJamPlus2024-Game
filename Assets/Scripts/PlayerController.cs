using UnityEngine;
using DG.Tweening;
using System.Collections.Generic;
using System;
using System.Collections;
using Unity.Cinemachine;
using TMPro;

public class PlayerController : MonoBehaviour
{
    public static Action OnPlayerGotPoint, OnPlayerHitWall;

    [SerializeField] Transform LeftPosition;
    [SerializeField] Transform MiddlePosition;
    [SerializeField] Transform RightPosition;
    [SerializeField] float moveDuration = 0.5f; // Duration of the movement
    [SerializeField] Ease ease = Ease.InOutQuad;
    [SerializeField] List<GameObject> shapes = new List<GameObject>();
    [SerializeField] private CinemachineMixingCamera cameraParent;
    private bool cameraOrtho = true;
    private float _timeFactor = 1.0f;
    private int _timeLeft = 5;
    private int initialTime = 5;
    private int currentShapeIndex = 0;
    [SerializeField] private GameObject _timePanel;
    [SerializeField] private TMP_Text _timeText;

    private Vector3 _leftPosition;
    private Vector3 _middlePosition;
    private Vector3 _rightPosition;
    private enum Position { Left, Middle, Right }
    private Position currentPosition = Position.Middle;
    private bool _playerMoving = false;

    void Start()
    {
        _leftPosition = LeftPosition.position;
        _middlePosition = MiddlePosition.position;
        _rightPosition = RightPosition.position;
        // Ensure the player starts at the middle position
        transform.position = _middlePosition;

        // Initialize shapes
        if (shapes.Count > 0)
        {
            ActivateShape(0);
        }

        AudioManager.Instance.PlayAudio("Ambient");
    }

    private void ChangeCamera()
    {
        if (cameraOrtho)
        {
            cameraOrtho = !cameraOrtho;
            DOTween.To(() => cameraParent.Weight0, x => cameraParent.Weight0 = x, 0, 1);
            DOTween.To(() => cameraParent.Weight1, x => cameraParent.Weight1 = x, 1, 1);
            StartCoroutine(AdvanceTime());
        }
    }

    void OnInteract()
    {
        if (shapes.Count == 0) return;

        // Deactivate the current shape
        shapes[currentShapeIndex].SetActive(false);

        // Move to the next shape
        currentShapeIndex = (currentShapeIndex + 1) % shapes.Count;

        // Activate the new current shape
        ActivateShape(currentShapeIndex);
    }

    private IEnumerator AdvanceTime()
    {
        _timeText.text = _timeLeft.ToString();
        _timePanel.SetActive(true);
        while (!cameraOrtho)
        {
            yield return new WaitForSeconds(_timeFactor);
            _timeLeft--;
            _timeText.text = _timeLeft.ToString();
            if (_timeLeft <= 0)
            {
                _timeLeft = initialTime;
                cameraOrtho = true;
            }
        }
        _timePanel.SetActive(false);
        DOTween.To(() => cameraParent.Weight0, x => cameraParent.Weight0 = x, 1, 1);
        DOTween.To(() => cameraParent.Weight1, x => cameraParent.Weight1 = x, 0, 1);
    }

    void ActivateShape(int index)
    {
        for (int i = 0; i < shapes.Count; i++)
        {
            shapes[i].SetActive(i == index);
        }
    }

    void OnRightMovement()
    {
        if (!_playerMoving)
        {
            _playerMoving = true;
            switch (currentPosition)
            {
                case Position.Left:
                    currentPosition = Position.Middle;
                    MoveToPosition(_middlePosition);
                    break;
                case Position.Middle:
                    currentPosition = Position.Right;
                    MoveToPosition(_rightPosition);
                    break;
                case Position.Right:
                    _playerMoving = false;
                    break;
            }
        }
    }

    void OnLeftMovement()
    {
        if (!_playerMoving)
        {
            _playerMoving = true;
            switch (currentPosition)
            {
                case Position.Right:
                    currentPosition = Position.Middle;
                    MoveToPosition(_middlePosition);
                    break;
                case Position.Middle:
                    currentPosition = Position.Left;
                    MoveToPosition(_leftPosition);
                    break;
                case Position.Left:
                    _playerMoving = false;
                    break;
            }
        }
    }

    void MoveToPosition(Vector3 targetPosition)
    {
        transform.DOMove(targetPosition, moveDuration).SetEase(ease).OnComplete(
            () =>
            {
                switch (currentPosition)
                {
                    case Position.Left:
                        transform.position = new Vector3(-6.0f, transform.position.y, transform.position.z);
                        break;
                    case Position.Middle:
                        transform.position = new Vector3(0.0f, transform.position.y, transform.position.z);
                        break;
                    case Position.Right:
                        transform.position = new Vector3(6.0f, transform.position.y, transform.position.z);
                        break;
                }
                _playerMoving = false;
            });
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag.Equals("Enemy"))
        {
            OnPlayerHitWall?.Invoke();
        }
        else if (other.tag.Equals("Point"))
        {
            OnPlayerGotPoint?.Invoke();
            Destroy(other.gameObject);
        }
        else if (other.tag.Equals("Collectible"))
        {
            ChangeCamera();
            Destroy(other.gameObject);
        }
    }
}
