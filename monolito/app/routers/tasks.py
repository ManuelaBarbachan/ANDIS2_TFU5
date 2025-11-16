from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..models import Task, TaskActivity, Project, User
from ..schemas import TaskCreate, TaskUpdate, TaskResponse

router = APIRouter()

@router.post("/", response_model=TaskResponse, status_code=201)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    """
    Crear tarea con actividad inicial - TRANSACCIÓN ACID
    VENTAJA MONOLITO: Todo en una sola transacción sin coordinación distribuida
    """
    # verificar que el proyecto existe (acceso directo, sin HTTP)
    project = db.query(Project).filter(Project.id == task.project_id).first()
    if not project:
        raise HTTPException(status_code=400, detail="Project not found")
    
    # verificar assignee si se proporciona
    if task.assignee_user_id:
        assignee = db.query(User).filter(User.id == task.assignee_user_id).first()
        if not assignee:
            raise HTTPException(status_code=400, detail="Assignee user not found")
    
    # TRANSACCIÓN ACID: Crear task + activity en una sola transacción
    try:
        # creo la tarea
        db_task = Task(**task.model_dump())
        db.add(db_task)
        db.flush()  # Obtener ID sin commit
        
        # se crea la actividad inicial (misma transacción)
        activity = TaskActivity(
            task_id=db_task.id,
            action="CREATED",
            details=f"Task '{db_task.title}' created in project {task.project_id}"
        )
        db.add(activity)
        
        # un coommit atomico de ambos
        db.commit()
        db.refresh(db_task)
        
        return db_task
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Transaction failed: {str(e)}")

@router.get("/", response_model=List[TaskResponse])
def list_tasks(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    tasks = db.query(Task).offset(skip).limit(limit).all()
    return tasks

@router.get("/{task_id}", response_model=TaskResponse)
def get_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@router.put("/{task_id}", response_model=TaskResponse)
def update_task(task_id: int, task_update: TaskUpdate, db: Session = Depends(get_db)):
    """Actualizar tarea y registrar actividad - TRANSACCIÓN ACID"""
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    try:
        update_data = task_update.model_dump(exclude_unset=True)
        changes = []
        
        for key, value in update_data.items():
            old_value = getattr(task, key)
            if old_value != value:
                changes.append(f"{key}: {old_value} -> {value}")
                setattr(task, key, value)
        
        if changes:
            # registramos si hay actividad de cambio
            activity = TaskActivity(
                task_id=task.id,
                action="UPDATED",
                details="; ".join(changes)
            )
            db.add(activity)
        
        db.commit()
        db.refresh(task)
        return task
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Transaction failed: {str(e)}")

@router.delete("/{task_id}", status_code=204)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    db.delete(task)
    db.commit()
    return None

@router.get("/{task_id}/activities")
def get_task_activities(task_id: int, db: Session = Depends(get_db)):
    """Obtener historial de actividades de una tarea"""
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    activities = db.query(TaskActivity).filter(TaskActivity.task_id == task_id).all()
    return activities