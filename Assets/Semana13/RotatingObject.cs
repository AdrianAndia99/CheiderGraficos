using UnityEngine;

public class RotatingObject : MonoBehaviour
{
    public float rotationSpeed = 50f; // Velocidad de rotación predeterminada
    public bool rotateX = false; // Rotar en el eje X
    public bool rotateY = false; // Rotar en el eje Y
    public bool rotateZ = false; // Rotar en el eje Z

    // Método Update se llama una vez por fotograma
    void Update()
    {
        if (rotateX)
            transform.Rotate(Vector3.right, rotationSpeed * Time.deltaTime);

        if (rotateY)
            transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);

        if (rotateZ)
            transform.Rotate(Vector3.forward, rotationSpeed * Time.deltaTime);
    }

    // Método para cambiar la velocidad de rotación
    public void ChangeRotationSpeed(float newSpeed)
    {
        rotationSpeed = newSpeed;
    }

    // Métodos para cambiar la dirección de rotación
    public void SetRotateX(bool rotate)
    {
        rotateX = rotate;
    }

    public void SetRotateY(bool rotate)
    {
        rotateY = rotate;
    }

    public void SetRotateZ(bool rotate)
    {
        rotateZ = rotate;
    }
}
    
