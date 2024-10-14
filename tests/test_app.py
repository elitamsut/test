def test_hello_world(client):
    """Test the hello world route."""
    response = client.get('/')
    assert response.status_code == 200
    assert response.data == b'Hello, World from Reference!'

