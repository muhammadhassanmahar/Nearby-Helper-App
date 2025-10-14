from pydantic import BaseModel
from typing import Optional, List

class Comment(BaseModel):
    id: Optional[str] = None
    author: str
    message: str

class HelpRequest(BaseModel):
    id: Optional[str] = None
    name: str
    title: Optional[str] = None
    description: str
    location: Optional[str] = None
    phone_number: Optional[str] = None
    status: str = "pending"
    comments: List[Comment] = []  # ✅ Comments list added
