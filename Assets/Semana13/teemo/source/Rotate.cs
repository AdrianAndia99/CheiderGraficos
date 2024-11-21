using UnityEngine;

public class Rotate : MonoBehaviour
{
    public float rotationSpeed = 100.0f;

    void Update()
    {
        // Rotar el objeto alrededor del eje Y
        transform.Rotate(Vector3.up * rotationSpeed * Time.deltaTime);
    }
}