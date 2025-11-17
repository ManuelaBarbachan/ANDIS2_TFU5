from fastapi import APIRouter, Request, Response
from spyne import Application, rpc, ServiceBase, Unicode, Integer, Iterable
from spyne.protocol.soap import Soap11
from spyne.server.wsgi import WsgiApplication
from io import BytesIO

from ..database import SessionLocal
from ..models import User, Project, Task

router = APIRouter()

# ========== SERVICIO SOAP ==========
class ProjectManagerService(ServiceBase):
    """Servicio SOAP para gestión de proyectos"""
    
    @rpc(Integer, _returns=Unicode)
    def GetUserById(ctx, user_id):
        """Obtener usuario por ID - Respuesta XML"""
        db = SessionLocal()
        try:
            user = db.query(User).filter(User.id == user_id).first()
            if user:
                return f"User: {user.name} ({user.email})"
            else:
                return "User not found"
        finally:
            db.close()
    
    @rpc(_returns=Iterable(Unicode))
    def ListAllUsers(ctx):
        """Listar todos los usuarios - Respuesta XML"""
        db = SessionLocal()
        try:
            users = db.query(User).all()
            result = []
            for user in users:
                result.append(f"ID: {user.id}, Name: {user.name}, Email: {user.email}")
            return result
        finally:
            db.close()
    
    @rpc(Integer, _returns=Unicode)
    def GetProjectById(ctx, project_id):
        """Obtener proyecto por ID - Respuesta XML"""
        db = SessionLocal()
        try:
            project = db.query(Project).filter(Project.id == project_id).first()
            if project:
                return f"Project: {project.name} (Owner ID: {project.owner_user_id})"
            else:
                return "Project not found"
        finally:
            db.close()
    
    @rpc(_returns=Iterable(Unicode))
    def ListAllProjects(ctx):
        """Listar todos los proyectos - Respuesta XML"""
        db = SessionLocal()
        try:
            projects = db.query(Project).all()
            result = []
            for project in projects:
                result.append(f"ID: {project.id}, Name: {project.name}")
            return result
        finally:
            db.close()
    
    @rpc(Integer, _returns=Iterable(Unicode))
    def GetTasksByProject(ctx, project_id):
        """Obtener tareas de un proyecto - Respuesta XML"""
        db = SessionLocal()
        try:
            tasks = db.query(Task).filter(Task.project_id == project_id).all()
            result = []
            for task in tasks:
                result.append(f"ID: {task.id}, Title: {task.title}, Status: {task.status}")
            return result
        finally:
            db.close()
    
    @rpc(Unicode, Unicode, _returns=Unicode)
    def CreateUser(ctx, name, email):
        """Crear usuario via SOAP - Respuesta XML"""
        db = SessionLocal()
        try:
            # Verificar email único
            existing = db.query(User).filter(User.email == email).first()
            if existing:
                return f"Error: Email {email} already registered"
            
            new_user = User(name=name, email=email)
            db.add(new_user)
            db.commit()
            db.refresh(new_user)
            return f"User created: ID={new_user.id}, Name={new_user.name}, Email={new_user.email}"
        except Exception as e:
            db.rollback()
            return f"Error: {str(e)}"
        finally:
            db.close()
    
    @rpc(_returns=Unicode)
    def GetServiceInfo(ctx):
        """Información del servicio SOAP"""
        return "ProjectManager SOAP Service v1.0 - Arquitectura monolitica"

# Crear aplicación Spyne SOAP
soap_app = Application(
    [ProjectManagerService],
    tns='http://monolito.projectmanager.soap',
    in_protocol=Soap11(validator='lxml'),
    out_protocol=Soap11()
)

wsgi_app = WsgiApplication(soap_app)

@router.post("/soap")
async def soap_endpoint(request: Request):
    """
    Endpoint SOAP principal
    Acepta requests XML SOAP y devuelve respuestas XML
    """
    # leemos body del request
    body = await request.body()
    
    # para crear ambiente WSGI simulado
    environ = {
        'REQUEST_METHOD': 'POST',
        'CONTENT_TYPE': request.headers.get('content-type', 'text/xml'),
        'CONTENT_LENGTH': str(len(body)),
        'PATH_INFO': '/soap',
        'QUERY_STRING': '',
        'SERVER_NAME': 'localhost',
        'SERVER_PORT': '8000',
        'wsgi.url_scheme': 'http',
        'wsgi.input': BytesIO(body),
        'wsgi.errors': BytesIO(),
    }
    
    # capturamos la response
    response_body = []
    response_headers = {}
    response_status = [None]
    
    def start_response(status, headers):
        response_status[0] = status
        response_headers.update(dict(headers))
    
    # procesamiento con Spyne
    result = wsgi_app(environ, start_response)
    for chunk in result:
        response_body.append(chunk)
    
    # devolvemos la response con XML
    xml_response = b''.join(response_body)
    
    return Response(
        content=xml_response,
        media_type="text/xml",
        headers={"Content-Type": "text/xml; charset=utf-8"}
    )

@router.get("/soap/wsdl")
async def get_wsdl():
    """Obtener WSDL del servicio SOAP"""
    # generamos WSDL
    from spyne.interface.wsdl import Wsdl11
    from lxml import etree
    
    wsdl = Wsdl11(soap_app.interface)
    wsdl.build_interface_document('http://localhost:8000/soap')
    wsdl_doc = wsdl.get_interface_document()
    
    return Response(
        content=etree.tostring(wsdl_doc, pretty_print=True),
        media_type="text/xml"
    )

