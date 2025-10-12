from pydantic import BaseModel

class HelpRequest(BaseModel):
    id: str
    name: str
    title: str
    description: str
    location: str
    status: str = "pending"
