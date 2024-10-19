using UnityEngine;
using DG.Tweening;

public class PlayerController : MonoBehaviour
{
    [SerializeField] Transform LeftPosition;
    [SerializeField] Transform MiddlePosition;
    [SerializeField] Transform RightPosition;
    [SerializeField] Rigidbody rb;
    [SerializeField] float moveDuration = 0.5f; // Duration of the movement
    [SerializeField] Ease ease = Ease.InOutQuad;

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
