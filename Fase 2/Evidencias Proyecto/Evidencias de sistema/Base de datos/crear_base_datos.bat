@echo off
chcp 65001 >nul
title TimeFlow - Creacion de Base de Datos
cd /d "%~dp0"

echo ============================================================
echo Creando base de datos 'teamflow_db' y tablas requeridas...
echo ============================================================

:: Detectar ruta del binario de MySQL
set "MYSQL_CMD=mysql"
where mysql >nul 2>&1
if %ERRORLEVEL% neq 0 (
    if exist "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" (
        set "MYSQL_CMD=C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
    ) else if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" (
        set "MYSQL_CMD=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
    ) else (
        echo hubo un error: no se encontro el ejecutable mysql en el sistema.
        pause
        exit /b 1
    )
)

:: Sentencias SQL
set "SQL_DB=CREATE DATABASE IF NOT EXISTS teamflow_db; USE teamflow_db;"
set "SQL_USR=CREATE TABLE IF NOT EXISTS usuarios (id BIGINT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(100) NOT NULL, email VARCHAR(100) UNIQUE NOT NULL, password_hash VARCHAR(255) NOT NULL, password VARCHAR(255) DEFAULT 'teamflow', rol VARCHAR(50) DEFAULT 'trabajador', estado VARCHAR(50) DEFAULT 'activo', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
set "SQL_INS_USR=INSERT IGNORE INTO usuarios (nombre, email, password_hash, password, rol, estado) VALUES ('Gabriel Chamorro', 'gabriel@teamflow.com', '$2b$10$CvX8FGVTbCyXoxAH/K6rnu8TePUN8glUuNBv4GzA2fnAXMGm/JiOK', 'teamflow', 'trabajador', 'activo'), ('Administrador Principal', 'admin@teamflow.com', '$2b$10$CvX8FGVTbCyXoxAH/K6rnu8TePUN8glUuNBv4GzA2fnAXMGm/JiOK', 'teamflow', 'admin', 'activo'), ('Andrea Ortega', 'andrea@teamflow.com', '$2b$10$CvX8FGVTbCyXoxAH/K6rnu8TePUN8glUuNBv4GzA2fnAXMGm/JiOK', 'teamflow', 'trabajador', 'activo'), ('María Silva', 'maria@teamflow.com', '$2b$10$CvX8FGVTbCyXoxAH/K6rnu8TePUN8glUuNBv4GzA2fnAXMGm/JiOK', 'teamflow', 'trabajador', 'activo'); UPDATE usuarios SET nombre='Gabriel Chamorro' WHERE email='gabriel@teamflow.com';"
set "SQL_TAR=CREATE TABLE IF NOT EXISTS tareas (id BIGINT AUTO_INCREMENT PRIMARY KEY, codigo VARCHAR(50) UNIQUE NOT NULL, nombre VARCHAR(255) NOT NULL, descripcion TEXT, tipo VARCHAR(50) DEFAULT 'Custom', asignado_a VARCHAR(100) NOT NULL, fecha_inicio VARCHAR(50), fecha_fin VARCHAR(50), fecha_limite VARCHAR(50), meta VARCHAR(255), meta_cumplida BOOLEAN DEFAULT FALSE, estado VARCHAR(50) DEFAULT 'En Progreso', bitacora TEXT, evidencia LONGTEXT);"
set "SQL_INS_TAR=INSERT IGNORE INTO tareas (codigo, nombre, descripcion, tipo, asignado_a, fecha_inicio, fecha_fin, fecha_limite, meta, meta_cumplida, estado, bitacora, evidencia) VALUES ('NODE-101', 'Diseño UI/UX en Figma', 'Creación de wireframes y prototipo.', 'Pre-establecida', 'Andrea Ortega', '08:30', '12:00', '13:00', 'Completar 10 pantallas', TRUE, 'Finalizada', 'Se finalizó el diseño y fue validado.', 'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=300'), ('NODE-102', 'Desarrollo de Módulo Frontend', 'Construcción de interfaz reactiva.', 'Custom', 'Gabriel Chamorro', '09:00', NULL, '18:00', 'Integrar vistas con Tailwind', FALSE, 'En Progreso', 'Estructurando layout principal y componentes.', NULL), ('NODE-103', 'Revisión y Testing de API', 'Validación de endpoints REST.', 'Pre-establecida', 'Gabriel Chamorro', '10:15', NULL, '17:00', 'Testear endpoints de autenticación', TRUE, 'En Revisión', 'Pruebas unitarias al 100%%. Esperando visto bueno.', NULL), ('NODE-104', 'Mantenimiento de Base de Datos', 'Optimización de índices.', 'Pre-establecida', 'María Silva', '11:00', NULL, '16:30', 'Generar DDL de migración', FALSE, 'En Progreso', 'Revisando consultas lentas.', NULL);"
set "SQL_TIP=CREATE TABLE IF NOT EXISTS tipos_tarea (id BIGINT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(100) UNIQUE NOT NULL, descripcion TEXT);"
set "SQL_INS_TIP=INSERT IGNORE INTO tipos_tarea (nombre, descripcion) VALUES ('Diseño UI/UX en Figma', 'Creación de wireframes, flujo de interacción y prototipado en alta fidelidad.'), ('Desarrollo de Módulo Frontend', 'Implementación de componentes visuales y conexión con lógica de cliente.'), ('Revisión y Testing de API', 'Validación de endpoints REST, pruebas unitarias y verificación de respuestas.'), ('Mantenimiento de Base de Datos', 'Revisión de consultas, índices, respaldos y optimización de tablas.');"
set "SQL_MSG=CREATE TABLE IF NOT EXISTS mensajes (id BIGINT AUTO_INCREMENT PRIMARY KEY, chat_id VARCHAR(50), recipient_id BIGINT, sender_id BIGINT NOT NULL, sender_name VARCHAR(100) NOT NULL, sender_avatar VARCHAR(50), sender_role VARCHAR(50) NOT NULL, text TEXT NOT NULL, timestamp VARCHAR(50) NOT NULL);"
set "SQL_INS_MSG=INSERT IGNORE INTO mensajes (id, chat_id, recipient_id, sender_id, sender_name, sender_avatar, sender_role, text, timestamp) VALUES (1, 'announcements', NULL, 2, 'Administrador Principal', 'AD', 'admin', 'Bienvenidos a TeamFlow. Recuerden registrar su Check-In al iniciar la jornada.', '08:00'), (2, 'general', NULL, 1, 'Gabriel Chamorro', 'GC', 'trabajador', 'Hola equipo, cualquier duda con los endpoints me avisan.', '09:05');"

:: Ejecucion en MySQL
"%MYSQL_CMD%" --default-character-set=utf8mb4 -u root -pTeamflow123! -e "%SQL_DB% %SQL_USR% %SQL_INS_USR% %SQL_TAR% %SQL_INS_TAR% %SQL_TIP% %SQL_INS_TIP% %SQL_MSG% %SQL_INS_MSG%"

if %ERRORLEVEL% equ 0 (
    echo.
    echo ============================================================
    echo [EXITO] Tablas usuarios, tareas, tipos_tarea y mensajes listas.
    echo ============================================================
) else (
    echo.
    echo ============================================================
    echo hubo un error: fallo la conexion o ejecucion en MySQL.
    echo ============================================================
)

pause