import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# paara detectar ambiente: si hay DATABASE_URL usa PostgreSQL, sino SQLite
DATABASE_URL = os.getenv("DATABASE_URL", None)

if DATABASE_URL:
    # producción/Docker: PostgreSQL
    engine = create_engine(DATABASE_URL)
    print(f"Conectado a PostgreSQL: {DATABASE_URL}")
else:
    # desarrollo local: SQLite
    SQLITE_URL = "sqlite:///./monolith.db"
    engine = create_engine(SQLITE_URL, connect_args={"check_same_thread": False})
    print(f"Usando SQLite local: {SQLITE_URL}")

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()