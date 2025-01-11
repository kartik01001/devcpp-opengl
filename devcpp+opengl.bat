@echo off
setlocal enabledelayedexpansion

:: Set directories
set TEMP_DIR=C:\Windows\Temp
set DEVCPP_DIR=C:\
set EMBARCADERO_DIR=%APPDATA%
set DESKTOP_DIR=%USERPROFILE%\Desktop

:: Set the path to 7z.exe in the Temp folder
set SEVENZIP=%TEMP_DIR%\7z.exe

:: Check if 7z.exe exists in the Temp folder
if not exist "%SEVENZIP%" (
    echo 7z.exe not found in %TEMP_DIR%. Please ensure 7z.exe is present in that folder.
    pause
    exit /b
)

:: Locate the zip files
for %%F in (%TEMP_DIR%\DevCpp.zip %TEMP_DIR%\Embarcadero.zip) do (
    if exist "%%F" (
        echo Found zip file: %%F
        :: Unzip the DevCpp.zip to C:\
        if "%%~nxF"=="DevCpp.zip" (
            echo Unzipping DevCpp.zip to C:\
            "%SEVENZIP%" x "%%F" -o"%DEVCPP_DIR%\DevCpp" -y >nul 2>&1
        )
        :: Unzip the Embarcadero.zip to %APPDATA%
        if "%%~nxF"=="Embarcadero.zip" (
            echo Unzipping Embarcadero.zip to %APPDATA%
            "%SEVENZIP%" x "%%F" -o"%EMBARCADERO_DIR%\Embarcadero" -y >nul 2>&1
        )
    ) else (
        echo File not found: %%F
    )
)

:: Create shortcut for DevCpp on Desktop
set EXE_PATH=%DEVCPP_DIR%\DevCpp\devcpp.exe
set SHORTCUT_PATH=%DESKTOP_DIR%\DevCpp.lnk

if exist "%EXE_PATH%" (
    echo Creating shortcut for DevCpp on Desktop...
    powershell -command ^
    "$WshShell = New-Object -ComObject WScript.Shell;" ^
    "$Shortcut = $WshShell.CreateShortcut('%SHORTCUT_PATH%');" ^
    "$Shortcut.TargetPath = '%EXE_PATH%';" ^
    "$Shortcut.WorkingDirectory = '%DEVCPP_DIR%\DevCpp';" ^
    "$Shortcut.IconLocation = '%EXE_PATH%';" ^
    "$Shortcut.Save()" >nul 2>&1
) else (
    echo devcpp.exe not found at %EXE_PATH%.
)

:: Copy DLL files to System32 and SysWOW64
echo Copying DLL files to System32 and SysWOW64...

set DLLS=glut32.dll freeglut.dll glew32.dll
set SYS32=C:\Windows\System32
set SYS64=C:\Windows\SysWOW64

for %%D in (%DLLS%) do (
    if exist "%TEMP_DIR%\%%D" (
        echo Copying %%D to System32 and SysWOW64...
        copy "%TEMP_DIR%\%%D" "%SYS32%\%%D" >nul 2>&1
        copy "%TEMP_DIR%\%%D" "%SYS64%\%%D" >nul 2>&1
    ) else (
        echo %%D not found in %TEMP_DIR%.
    )
)

echo Installation progress: Completed.
pause
