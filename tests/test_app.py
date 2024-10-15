import pytest
from app import app as flask_app  # Import your Flask app from the app module

@pytest.fixture
def app():
    """Fixture for the Flask app."""
    return flask_app

@pytest.fixture
def client(app):
    """Fixture for the test client."""
    return app.test_client()

def test_hello_world(client):
    """Test the hello world route."""
    response = client.get('/')
    assert response.status_code == 200
    assert response.data == b'Hello, World!'
