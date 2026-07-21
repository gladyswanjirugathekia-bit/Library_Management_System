@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Book Manager One-Click Startup
chcp 65001 >nul

set "APP_URL=http://localhost:8080/login"
set "DB_NAME=book_manager"
set "DB_USER=root"
set "DB_PASSWORD=123456"
set "DB_HOST=127.0.0.1"
set "DB_PORT=3306"
set "DOCKER_CONTAINER=book_manager_mysql"
set "PROJECT_DIR=%~dp0"
set "SQL_FILE=%PROJECT_DIR%sql\init.sql"
set "DATA_DIR=%PROJECT_DIR%data"
set "H2_DB_BASE=%DATA_DIR%\book_manager"
set "H2_DB_FILE=%DATA_DIR%\book_manager.mv.db"
set "LOG_DIR=%PROJECT_DIR%target"
set "APP_LOG=%LOG_DIR%\book-manager-app.log"
set "RUNNER_FILE=%LOG_DIR%\run-book-manager.bat"
set "APP_ARTIFACT=%LOG_DIR%\book-manager-1.0.0.war"
set "MVN_CMD="
set "MYSQL_CMD="
set "MYSQLADMIN_CMD="
set "DOCKER_CMD="
set "DB_MODE="

cd /d "%PROJECT_DIR%"

echo ============================================================
echo  Book Manager One-Click Startup
echo ============================================================
echo.

if /I "%~1"=="--check" goto :check_only

call :prepare
if errorlevel 1 goto :failed

call :prepare_database
if errorlevel 1 goto :failed

call :initialize_database
if errorlevel 1 goto :failed

call :start_application
if errorlevel 1 goto :failed

call :wait_for_application
if errorlevel 1 goto :failed

echo.
echo Opening login page...
start "" "%APP_URL%"
echo.
echo ============================================================
echo  Startup completed.
echo  Login page: %APP_URL%
echo  Default account: admin
echo  Default password: 123456
echo ============================================================
echo.
echo Keep the server window open while using the system.
pause
exit /b 0

:check_only
call :prepare
if errorlevel 1 exit /b 1
call :configure_application_environment
call :write_runner
echo Environment check passed.
exit /b 0

:prepare
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>nul

echo Checking required tools...

where java >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Java is not available.
    echo Please install JDK 8 or newer and add java.exe to PATH.
    exit /b 1
)
echo Java found.

if exist "%APP_ARTIFACT%" (
    echo Packaged application found.
) else (
    call :resolve_maven
    if errorlevel 1 (
        echo [ERROR] Maven is not available and packaged application was not found.
        echo Please keep target\book-manager-1.0.0.war in the package, or install Maven.
        exit /b 1
    )
)

if not exist "%SQL_FILE%" (
    echo [ERROR] Database script was not found:
    echo %SQL_FILE%
    exit /b 1
)

call :resolve_docker
if not errorlevel 1 (
    set "DB_MODE=docker"
    echo Docker found. Database mode: Docker MySQL.
    exit /b 0
)

call :resolve_mysql
if not errorlevel 1 (
    set "DB_MODE=local"
    echo MySQL client found. Database mode: Local MySQL.
    exit /b 0
)

set "DB_MODE=h2"
echo No external database runtime was found.
echo Database mode: Embedded H2.
exit /b 0

:resolve_maven
set "MVN_CMD="
for %%M in (mvn.cmd mvn.bat mvn.exe mvn) do (
    if not defined MVN_CMD (
        for /f "delims=" %%P in ('where %%M 2^>nul') do (
            if not defined MVN_CMD set "MVN_CMD=%%P"
        )
    )
)

if not defined MVN_CMD (
    for /f "usebackq delims=" %%P in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$cmd = Get-Command mvn -ErrorAction SilentlyContinue; if ($cmd) { $cmd.Source }"`) do (
        if not defined MVN_CMD set "MVN_CMD=%%P"
    )
)

if not defined MVN_CMD exit /b 1
echo Maven command: %MVN_CMD%
exit /b 0

:resolve_docker
set "DOCKER_CMD="
for /f "delims=" %%P in ('where docker.exe 2^>nul') do (
    if not defined DOCKER_CMD set "DOCKER_CMD=%%P"
)
if not defined DOCKER_CMD exit /b 1
"%DOCKER_CMD%" info >nul 2>nul
if errorlevel 1 exit /b 1
exit /b 0

:resolve_mysql
set "MYSQL_CMD="
set "MYSQLADMIN_CMD="

for /f "delims=" %%P in ('where mysql.exe 2^>nul') do (
    if not defined MYSQL_CMD set "MYSQL_CMD=%%P"
)
for /f "delims=" %%P in ('where mysqladmin.exe 2^>nul') do (
    if not defined MYSQLADMIN_CMD set "MYSQLADMIN_CMD=%%P"
)

if not defined MYSQL_CMD (
    for %%D in (
        "%ProgramFiles%\MySQL\MySQL Server 8.4\bin"
        "%ProgramFiles%\MySQL\MySQL Server 8.0\bin"
        "%ProgramFiles%\MySQL\MySQL Server 5.7\bin"
        "%ProgramFiles(x86)%\MySQL\MySQL Server 8.0\bin"
        "%ProgramFiles(x86)%\MySQL\MySQL Server 5.7\bin"
    ) do (
        if not defined MYSQL_CMD if exist "%%~D\mysql.exe" set "MYSQL_CMD=%%~D\mysql.exe"
        if not defined MYSQLADMIN_CMD if exist "%%~D\mysqladmin.exe" set "MYSQLADMIN_CMD=%%~D\mysqladmin.exe"
    )
)

if not defined MYSQL_CMD exit /b 1
if not defined MYSQLADMIN_CMD exit /b 1
echo MySQL command: %MYSQL_CMD%
exit /b 0

:prepare_database
echo.
if "%DB_MODE%"=="docker" goto :prepare_docker_mysql
if "%DB_MODE%"=="local" goto :prepare_local_mysql
if "%DB_MODE%"=="h2" goto :prepare_h2
echo [ERROR] Database mode is not set.
exit /b 1

:prepare_docker_mysql
echo Preparing Docker MySQL container...
"%DOCKER_CMD%" ps -a --format "{{.Names}}" | findstr /I /X "%DOCKER_CONTAINER%" >nul 2>nul
if errorlevel 1 (
    echo Creating MySQL container...
    "%DOCKER_CMD%" run -d --name "%DOCKER_CONTAINER%" -e MYSQL_ROOT_PASSWORD=%DB_PASSWORD% -p %DB_PORT%:3306 mysql:8.0 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci >nul
    if errorlevel 1 (
        echo [ERROR] Failed to create Docker MySQL container.
        echo Port 3306 may already be in use, or Docker cannot pull mysql:8.0.
        exit /b 1
    )
) else (
    echo Starting existing MySQL container...
    "%DOCKER_CMD%" start "%DOCKER_CONTAINER%" >nul 2>nul
)

echo Waiting for Docker MySQL...
for /L %%I in (1,1,60) do (
    "%DOCKER_CMD%" exec "%DOCKER_CONTAINER%" mysqladmin ping -uroot -p%DB_PASSWORD% --silent >nul 2>nul
    if not errorlevel 1 (
        echo Docker MySQL is ready.
        exit /b 0
    )
    timeout /t 2 /nobreak >nul
)

echo [ERROR] Docker MySQL did not become ready in time.
exit /b 1

:prepare_local_mysql
echo Checking local MySQL connection...
"%MYSQLADMIN_CMD%" ping -h %DB_HOST% -u%DB_USER% -p%DB_PASSWORD% --silent >nul 2>nul
if not errorlevel 1 (
    echo Local MySQL is already running.
    exit /b 0
)

echo Trying to start common MySQL services...
for %%S in (MySQL84 MySQL80 MySQL MySQL57 MySQL56 mysql) do (
    net start %%S >nul 2>nul
)

timeout /t 3 /nobreak >nul
"%MYSQLADMIN_CMD%" ping -h %DB_HOST% -u%DB_USER% -p%DB_PASSWORD% --silent >nul 2>nul
if not errorlevel 1 (
    echo Local MySQL service started.
    exit /b 0
)

echo.
echo The default MySQL password did not work, or MySQL is not running.
set /p "DB_PASSWORD=Enter MySQL root password: "
"%MYSQLADMIN_CMD%" ping -h %DB_HOST% -u%DB_USER% -p%DB_PASSWORD% --silent >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Cannot connect to local MySQL.
    exit /b 1
)

echo Local MySQL is ready.
exit /b 0

:prepare_h2
echo Preparing embedded H2 database...
if not exist "%DATA_DIR%" mkdir "%DATA_DIR%" >nul 2>nul
if exist "%H2_DB_FILE%" (
    echo Embedded H2 database already exists.
) else (
    echo Embedded H2 database will be created on first application start.
)
exit /b 0

:initialize_database
echo.
if "%DB_MODE%"=="h2" (
    echo Embedded H2 initialization is handled by Spring Boot.
    exit /b 0
)

echo Checking database "%DB_NAME%"...
set "TABLE_COUNT="

if "%DB_MODE%"=="docker" (
    for /f "delims=" %%C in ('"%DOCKER_CMD%" exec "%DOCKER_CONTAINER%" mysql -uroot -p%DB_PASSWORD% -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='%DB_NAME%' AND table_name='user';" 2^>nul') do (
        set "TABLE_COUNT=%%C"
    )
) else (
    for /f "delims=" %%C in ('"%MYSQL_CMD%" -h %DB_HOST% -u%DB_USER% -p%DB_PASSWORD% -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='%DB_NAME%' AND table_name='user';" 2^>nul') do (
        set "TABLE_COUNT=%%C"
    )
)

if "%TABLE_COUNT%"=="1" (
    echo Database already exists. Initialization skipped.
    exit /b 0
)

echo Initializing database "%DB_NAME%" for the first run...
if "%DB_MODE%"=="docker" (
    "%DOCKER_CMD%" exec -i "%DOCKER_CONTAINER%" mysql -uroot -p%DB_PASSWORD% --default-character-set=utf8mb4 < "%SQL_FILE%"
) else (
    "%MYSQL_CMD%" -h %DB_HOST% -u%DB_USER% -p%DB_PASSWORD% --default-character-set=utf8mb4 < "%SQL_FILE%"
)
if errorlevel 1 (
    echo [ERROR] Database initialization failed.
    exit /b 1
)

echo Database is ready.
exit /b 0

:start_application
echo.
echo Starting Spring Boot application...
echo Log file: %APP_LOG%

call :configure_application_environment
call :write_runner
if errorlevel 1 exit /b 1

start "Book Manager Server" cmd /k "target\run-book-manager.bat"
exit /b 0

:configure_application_environment
set "SPRING_DATASOURCE_USERNAME=%DB_USER%"
set "SPRING_DATASOURCE_PASSWORD=%DB_PASSWORD%"
set "SPRING_DATASOURCE_URL=jdbc:mysql://localhost:%DB_PORT%/%DB_NAME%?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf-8"
set "SPRING_DATASOURCE_DRIVER_CLASS_NAME=com.mysql.cj.jdbc.Driver"
set "SPRING_SQL_INIT_MODE=never"
set "SPRING_SQL_INIT_SCHEMA_LOCATIONS="
set "SPRING_SQL_INIT_DATA_LOCATIONS="

if "%DB_MODE%"=="h2" (
    set "DB_USER=sa"
    set "DB_PASSWORD="
    set "SPRING_DATASOURCE_USERNAME=sa"
    set "SPRING_DATASOURCE_PASSWORD="
    set "SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.h2.Driver"
    set "SPRING_DATASOURCE_URL=jdbc:h2:file:%H2_DB_BASE%;MODE=MySQL;DATABASE_TO_LOWER=TRUE;CASE_INSENSITIVE_IDENTIFIERS=TRUE;NON_KEYWORDS=USER;DB_CLOSE_DELAY=-1"
    if exist "%H2_DB_FILE%" (
        set "SPRING_SQL_INIT_MODE=never"
    ) else (
        set "SPRING_SQL_INIT_MODE=always"
    )
    set "SPRING_SQL_INIT_SCHEMA_LOCATIONS=classpath:schema-h2.sql"
    set "SPRING_SQL_INIT_DATA_LOCATIONS=classpath:data-h2.sql"
)
exit /b 0

:write_runner
(
    echo @echo off
    echo set "RUNNER_DIR=%%~dp0"
    echo for %%%%I in ^("%%RUNNER_DIR%%.."^) do cd /d "%%%%~fI"
    echo echo Starting Book Manager...
    if exist "%APP_ARTIFACT%" (
        echo java -jar "target\book-manager-1.0.0.war" ^> "target\book-manager-app.log" 2^>^&1
    ) else (
        echo "%MVN_CMD%" spring-boot:run -q ^> "target\book-manager-app.log" 2^>^&1
    )
    echo echo.
    echo echo Server stopped. Check the log file:
    echo echo "target\book-manager-app.log"
    echo pause
) > "%RUNNER_FILE%"
exit /b 0

:wait_for_application
echo.
echo Waiting for application to start...
for /L %%I in (1,1,60) do (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:8080/login' -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
    if not errorlevel 1 (
        echo Application is ready.
        exit /b 0
    )
    timeout /t 2 /nobreak >nul
    echo Waiting... %%I
)

echo [ERROR] Application did not start in time.
echo Please check this log file:
echo %APP_LOG%
exit /b 1

:failed
echo.
echo ============================================================
echo  Startup failed.
echo ============================================================
echo.
echo If you need help, send this window text and this log file:
echo %APP_LOG%
echo.
pause
exit /b 1
