from flask import Flask
from flask_cors import CORS

import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[1] / "backend"
sys.path.insert(0, str(BACKEND_DIR))

from app.routes.items import items_bp


app = Flask(__name__)
CORS(app)
app.register_blueprint(items_bp, url_prefix="/items")


@app.route("/health", methods=["GET"])
def health_check():
    return "UniGuide items backend is alive and running!"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
