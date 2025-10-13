from pydantic import BaseModel
from typing import Optional

class HelpRequest(BaseModel):
    id: Optional[str] = None
    name: str
    title: Optional[str] = None
    description: str
    location: Optional[str] = None
    status: str = "pending"
