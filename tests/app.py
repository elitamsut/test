from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
<<<<<<< HEAD
    return 'Hello, World from Reference!'  # Update this line to match the expected response

if __name__ == '__main__':
    # Use your wildcard SSL certificate and key
    app.run(host='0.0.0.0', port=8080, ssl_context=('wildcard-cert.pem', 'wildcard-key.pem'))
=======
    return 'Hello, World!'
    # This is  Eli migdal version 18 testing   task comment for testing purposes final
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
>>>>>>> Reference

