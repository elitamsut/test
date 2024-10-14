import pytest
from app import app  # Assuming your app.py is in the same directory

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_hello_world(client):
    """Test the hello world route."""
    response = client.get('/')
    assert response.status_code == 200
    assert response.data == b'Hello, World!'

