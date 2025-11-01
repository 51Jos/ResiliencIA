@echo off
echo ========================================
echo  Sistema de Psicologia UCSS - Web Dev
echo ========================================
echo.

echo [1/3] Cerrando Chrome existente...
taskkill /F /IM chrome.exe 2>nul
if %errorlevel% == 0 (
    echo Chrome cerrado correctamente
) else (
    echo Chrome no estaba abierto
)
echo.

echo [2/3] Esperando 2 segundos...
timeout /t 2 /nobreak > nul
echo.

echo [3/3] Iniciando Chrome sin CORS...
start chrome --disable-web-security --user-data-dir="%TEMP%\chrome_dev_ucss" --disable-site-isolation-trials http://localhost:52000
echo.

echo ========================================
echo  Ahora ejecuta: flutter run -d chrome
echo ========================================
echo.
echo NOTA: Este Chrome NO es seguro.
echo      Solo usar para desarrollo.
echo.
pause
