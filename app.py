"""A small Flask web server for practicing HTTP tests and CI."""

from flask import Flask, request

app = Flask(__name__)


@app.get("/")
def home():
    return """<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>Flask CI Practice</title></head>
<body>
  <h1>Hello from Flask!</h1>
  <p>A small web server tested with Robot Framework and GitHub Actions.</p>
  <ul>
    <li><a href="/health">Health check</a></li>
    <li><a href="/hello?name=Robot">Say hello to Robot</a></li>
  </ul>
</body>
</html>"""


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/hello")
def hello():
    name = request.args.get("name", "World").strip()
    if not name:
        return {"error": "Name must not be empty"}, 400
    return {"message": f"Hey, {name}!"}


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5001, debug=False)
