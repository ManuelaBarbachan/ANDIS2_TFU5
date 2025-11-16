from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from .database import engine, Base
from .routers import users, projects, tasks, soap_service

@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield

app = FastAPI(
    title="Mini Gestor de Proyectos - Monolito",
    description="Aplicación monolítica con endpoints REST y SOAP",
    version="2.0.0",
    lifespan=lifespan
)

#CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

#routers REST
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(projects.router, prefix="/projects", tags=["Projects"])
app.include_router(tasks.router, prefix="/tasks", tags=["Tasks"])

#router SOAP
app.include_router(soap_service.router, tags=["SOAP"])

@app.get("/")
def root():
    return {
        "message": "Mini Gestor de Proyectos - Arquitectura Monolítica",
        "version": "2.0.0",
        "endpoints": {
            "rest": {
                "users": "/users",
                "projects": "/projects",
                "tasks": "/tasks"
            },
            "soap": "/soap",
            "docs": "/docs"
        }
    }

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "architecture": "monolithic",
        "services": {
            "users": "integrated",
            "projects": "integrated", 
            "tasks": "integrated",
            "soap": "integrated"
        }
    }