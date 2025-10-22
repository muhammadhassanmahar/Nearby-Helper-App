from pydantic import BaseModel, Field
from typing import Optional, List


class Comment(BaseModel):
    id: Optional[str] = Field(default=None)
    author: str = Field(default="Anonymous", description="Default author if not provided")
    message: Optional[str] = Field(default=None, description="Backend field name")
    text: Optional[str] = Field(default=None, description="Used by Flutter client")

    def dict(self, *args, **kwargs):
        """
        Ensure compatibility with Flutter's JSON:
        Converts {"text": "..."} → {"message": "..."}
        """
        data = super().dict(*args, **kwargs)
        # Convert Flutter 'text' to backend 'message'
        if data.get("text") and not data.get("message"):
            data["message"] = data["text"]
        return data


class HelpRequest(BaseModel):
    id: Optional[str] = Field(default=None)
    name: str
    title: Optional[str] = None
    description: str
    location: Optional[str] = None
    phone_number: Optional[str] = None
    status: str = Field(default="pending", description="Current request status")
    comments: List[Comment] = Field(default_factory=list, description="List of comments")

    class Config:
        schema_extra = {
            "example": {
                "name": "Muhammad Hassan",
                "title": "Need help fixing a road",
                "description": "There’s a broken road near Karachi University.",
                "location": "Karachi",
                "phone_number": "03001234567",
                "status": "pending",
                "comments": [
                    {
                        "author": "Ahmed",
                        "message": "I can help with this!",
                    }
                ],
            }
        }
