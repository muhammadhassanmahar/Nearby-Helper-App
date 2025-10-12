from fastapi import FastAPI, HTTPException
from models.request_model import HelpRequest
import json, uuid, os

app = FastAPI(title="Nearby Helper API", version="1.0")

DATA_FILE = os.path.join(os.path.dirname(__file__), "data", "requests.json")

def load_data():
    try:
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return []

def save_data(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=4)

@app.get("/")
def root():
    return {"message": "Nearby Helper API running successfully 🚀"}

@app.get("/requests")
def get_requests():
    return load_data()

@app.post("/requests")
def add_request(request: HelpRequest):
    data = load_data()
    request.id = str(uuid.uuid4())
    data.append(request.dict())
    save_data(data)
    return {"message": "Request added successfully", "id": request.id}

@app.put("/requests/{request_id}")
def update_request(request_id: str, updated: HelpRequest):
    data = load_data()
    for i, req in enumerate(data):
        if req["id"] == request_id:
            data[i] = updated.dict()
            save_data(data)
            return {"message": "Request updated successfully"}
    raise HTTPException(status_code=404, detail="Request not found")

@app.delete("/requests/{request_id}")
def delete_request(request_id: str):
    data = load_data()
    new_data = [req for req in data if req["id"] != request_id]
    save_data(new_data)
    return {"message": "Request deleted successfully"}
