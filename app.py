from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'
<<<<<<< HEAD
=======

>>>>>>> origin/Reference

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, ssl_context=('wildcard-cert.pem', 'wildcard-key.pem'))
