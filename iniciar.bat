@echo off
REM ======================================================================
REM  BuildZone - inicia la aplicacion completa (front-end + API) con un clic
REM
REM    iniciar.bat          -> perfil dev: H2 en memoria, no necesita XAMPP
REM    iniciar.bat mysql    -> base de datos MySQL/MariaDB "buildzone" (XAMPP)
REM
REM  Cuando aparezca "Started BuildzoneApiApplication" abra:
REM    http://localhost:8080
REM  Para detener el servidor: Ctrl + C en esta ventana.
REM ======================================================================
title BuildZone - http://localhost:8080
cd /d "%~dp0"

where mvn >nul 2>nul
if errorlevel 1 (
  echo [ERROR] No se encontro Maven ^(mvn^) en el PATH.
  echo Instale Maven 3.9+ o abra la carpeta en NetBeans/IntelliJ y ejecute BuildzoneApiApplication.
  pause
  exit /b 1
)

REM Abre el navegador unos segundos despues, cuando el servidor ya este arriba.
start "" /min cmd /c "timeout /t 25 /nobreak >nul & start http://localhost:8080"

if /i "%~1"=="mysql" (
  echo Iniciando BuildZone con MySQL/MariaDB ^(XAMPP^) en http://localhost:8080 ...
  call mvn spring-boot:run
) else (
  echo Iniciando BuildZone en modo dev ^(H2 en memoria^) en http://localhost:8080 ...
  call mvn spring-boot:run -Dspring-boot.run.profiles=dev
)
pause
