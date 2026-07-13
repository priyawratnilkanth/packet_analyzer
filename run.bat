@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion
title DPI Engine - Run

echo Current folder: %cd%
echo.

if not exist src (
    echo [ERROR] "src" folder not found here.
    echo This script must sit inside the folder that contains src, include, CMakeLists.txt.
    pause
    exit /b 1
)

REM ---- Build if exe missing ----
if not exist dpi_engine.exe (
    echo dpi_engine.exe not found, building it now...
    g++ -std=c++17 -pthread -O2 -I include -o dpi_engine.exe src/dpi_mt.cpp src/pcap_reader.cpp src/packet_parser.cpp src/sni_extractor.cpp src/types.cpp
    if errorlevel 1 (
        echo [FAILED] Build failed. See errors above.
        pause
        exit /b 1
    )
    echo [OK] Build successful.
    echo.
)

REM ---- Generate test data if missing ----
if not exist test_dpi.pcap (
    echo test_dpi.pcap not found, generating it...
    python generate_test_pcap.py
    echo.
)

:menu
echo ============================================
echo   1. Run NORMAL  (no blocking - baseline)
echo   2. Run BLOCKED (YouTube, TikTok, IP, facebook blocked)
echo   3. Compare output file sizes
echo   4. Rebuild
echo   0. Exit
echo ============================================
set /p choice="Enter choice: "

if "%choice%"=="1" (
    dpi_engine.exe test_dpi.pcap output_normal.pcap
    echo.
    pause
    goto menu
)
if "%choice%"=="2" (
    dpi_engine.exe test_dpi.pcap output_blocked.pcap --block-app YouTube --block-app TikTok --block-ip 192.168.1.50 --block-domain facebook
    echo.
    pause
    goto menu
)
if "%choice%"=="3" (
    dir output_normal.pcap output_blocked.pcap
    echo.
    pause
    goto menu
)
if "%choice%"=="4" (
    g++ -std=c++17 -pthread -O2 -I include -o dpi_engine.exe src/dpi_mt.cpp src/pcap_reader.cpp src/packet_parser.cpp src/sni_extractor.cpp src/types.cpp
    echo.
    pause
    goto menu
)
if "%choice%"=="0" exit /b 0

goto menu
