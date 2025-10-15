from pydantic import BaseModel
from typing import Optional, List


class Comment(BaseModel):
    id: Optional[str] = None
    author: Optional[str] = "Anonymous"   # ✅ Default author if not provided
    message: Optional[str] = None         # ✅ Backend field name
    text: Optional[str] = None            # ✅ Flutter sends {"text": "comment"}

    def dict(self, *args, **kwargs):
        """
        Ensure compatibility with Flutter's JSON:
        Converts {"text": "..."} → {"message": "..."}
        """
        data = super().dict(*args, **kwargs)
        if data.get("text") and not data.get("message"):
            data["message"] = data["text"]
        return data


class HelpRequest(BaseModel):
    id: Optional[str] = None
    name: str
    title: Optional[str] = None
    description: str
    location: Optional[str] = None
    phone_number: Optional[str] = None
    status: str = "pending"
    comments: List[Comment] = []  # ✅ Always include comments list
