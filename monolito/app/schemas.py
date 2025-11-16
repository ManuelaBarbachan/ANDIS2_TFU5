from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# ========== USER SCHEMAS ==========
class UserBase(BaseModel):
    name: str
    email: str

class UserCreate(UserBase):
    pass

class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None

class UserResponse(UserBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

# ========== PROJECT SCHEMAS ==========
class ProjectBase(BaseModel):
    name: str
    description: Optional[str] = None
    owner_user_id: int

class ProjectCreate(ProjectBase):
    pass

class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None

class ProjectResponse(ProjectBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

# ========== TASK SCHEMAS ==========
class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    project_id: int
    assignee_user_id: Optional[int] = None

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    assignee_user_id: Optional[int] = None

class TaskActivityResponse(BaseModel):
    id: int
    task_id: int
    action: str
    details: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

class TaskResponse(TaskBase):
    id: int
    status: str
    created_at: datetime
    updated_at: Optional[datetime] = None
    activities: List[TaskActivityResponse] = []
    
    class Config:
        from_attributes = True