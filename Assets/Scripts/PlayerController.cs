using UnityEngine;
using DG.Tweening;
using System.Collections.Generic;

public class PlayerController : MonoBehaviour
{
    [SerializeField] Transform LeftPosition;
    [SerializeField] Transform MiddlePosition;
    [SerializeField] Transform RightPosition;
    [SerializeField] Rigidbody rb;
    [SerializeField] float moveDuration = 0.5f; // Duration of the movement
    [SerializeField] Ease ease = Ease.InOutQuad;
    [SerializeField] List<GameObject> shapes = new List<GameObject>();

    private int currentShapeIndex = 0;

    private Vector3 _leftPosition;
    private Vector3 _middlePosition;
    private Vector3 _rightPosition;
    private enum Position { Left, Middle, Right }
    private Position currentPosition = Position.Middle;

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

    void ActivateShape(int index)
    {
        for (int i = 0; i < shapes.Count; i++)
        {
            shapes[i].SetActive(i == index);
        }
    }

    void OnRightMovement()
    {
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
                // If already at Right, do nothing
        }
    }

    void OnLeftMovement()
    {
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
                // If already at Left, do nothing
        }
    }

    void MoveToPosition(Vector3 targetPosition)
    {
        rb.DOMove(targetPosition, moveDuration).SetEase(ease);
    }
}
