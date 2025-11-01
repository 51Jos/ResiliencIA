@echo off
color 0A
cls
echo.
echo  ╔═══════════════════════════════════════════════════╗
echo  ║                                                   ║
echo  ║     SISTEMA DE PSICOLOGIA UCSS - WINDOWS APP     ║
echo  ║                                                   ║
echo  ╚═══════════════════════════════════════════════════╝
echo.
echo  ✅ Esta version SI funciona con Web Scraping UCSS
echo  ✅ No hay problemas de CORS
echo  ✅ Listo para probar el registro!
echo.
echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo  [INICIANDO...]
echo.
timeout /t 2 /nobreak > nul

echo  → Ejecutando en Windows Desktop...
echo.
flutter run -d windows

pause
