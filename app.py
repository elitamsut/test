from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World From Reference!'
    # This is  Eli migdal task comment for testing purposes final
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

