from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from models.request_model import HelpRequest, Comment
import json, uuid, os

# ---------------------------
# ✅ Initialize FastAPI App
# ---------------------------
app = FastAPI(title="Nearby Helper API", version="1.3")

# ✅ Enable CORS for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict later to a specific frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------
# ✅ Data File Setup
# ---------------------------
DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
os.makedirs(DATA_DIR, exist_ok=True)
DATA_FILE = os.path.join(DATA_DIR, "requests.json")


# ---------------------------
# ✅ Helper Functions
# ---------------------------
def load_data():
    """Load all requests from JSON file"""
    try:
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return []


def save_data(data):
    """Save all requests to JSON file"""
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=4)


# ---------------------------
# ✅ Root Route
# ---------------------------
@app.get("/")
def root():
    return {"message": "Nearby Helper API running successfully 🚀"}


# ---------------------------
# ✅ CRUD Routes
# ---------------------------
@app.get("/requests")
def get_requests():
    """Get all help requests"""
    return load_data()


@app.post("/requests")
def add_request(request: HelpRequest):
    """Add a new help request"""
    data = load_data()

    request.id = str(uuid.uuid4())
    new_request = request.dict()

    # Ensure optional fields exist
    new_request.setdefault("phone_number", None)
    new_request.setdefault("comments", [])

    data.append(new_request)
    save_data(data)

    return {"message": "Request added successfully", "id": request.id}


@app.put("/requests/{request_id}")
def update_request(request_id: str, updated: HelpRequest):
    """Update an existing request"""
    data = load_data()
    for i, req in enumerate(data):
        if req["id"] == request_id:
            updated_dict = updated.dict()
            updated_dict["id"] = request_id
            updated_dict["comments"] = req.get("comments", [])
            updated_dict["phone_number"] = req.get("phone_number", None)
            data[i] = updated_dict
            save_data(data)
            return {"message": "Request updated successfully"}

    raise HTTPException(status_code=404, detail="Request not found")


@app.delete("/requests/{request_id}")
def delete_request(request_id: str):
    """Delete a help request"""
    data = load_data()
    new_data = [req for req in data if req["id"] != request_id]

    if len(new_data) == len(data):
        raise HTTPException(status_code=404, detail="Request not found")

    save_data(new_data)
    return {"message": "Request deleted successfully"}


# ---------------------------
# ✅ Comment System Routes
# ---------------------------
@app.post("/requests/{request_id}/comments")
def add_comment(request_id: str, comment: Comment):
    """Add a comment to a help request"""
    data = load_data()

    for req in data:
        if req["id"] == request_id:
            comment.id = str(uuid.uuid4())
            new_comment = comment.dict()

            # Ensure 'text' key exists to match Flutter payload
            if "text" not in new_comment:
                raise HTTPException(status_code=400, detail="Missing 'text' field in comment")

            req.setdefault("comments", []).append(new_comment)
            save_data(data)
            return {"message": "Comment added successfully", "comment": new_comment}

    raise HTTPException(status_code=404, detail="Request not found")


@app.get("/requests/{request_id}/comments")
def get_comments(request_id: str):
    """Get all comments for a help request"""
    data = load_data()
    for req in data:
        if req["id"] == request_id:
            return req.get("comments", [])
    raise HTTPException(status_code=404, detail="Request not found")
