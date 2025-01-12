@echo off
setlocal enabledelayedexpansion

:: Define the download URLs
set DOWNLOAD_URLS_0="https://drive.usercontent.google.com/download?id=16PkVHdBSIrYGqEL9nTBaOUTaSQy5tC3Y&export=download&confirm=t?\DevCpp.zip"
set DOWNLOAD_URLS_1=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/7z.dll
set DOWNLOAD_URLS_2=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/7z.exe
set DOWNLOAD_URLS_3=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/Embarcadero.zip
set DOWNLOAD_URLS_4=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/freeglut.dll
set DOWNLOAD_URLS_5=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/glew32.dll
set DOWNLOAD_URLS_6=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/glut32.dll

set TEMP_DIR=C:\Windows\Temp
set CURL_PATH=C:\Windows\Temp\curl.exe

if 1==1 (
        echo === Be Patient ===
        echo.
)

:: Loop through download URLs
for /l %%i in (0, 1, 6) do (
    set URL=!DOWNLOAD_URLS_%%i!
    
    if %%i==0 (
        set FILE_NAME=DevCpp.zip
    ) else (
        for %%j in ("!URL!") do (
            set FILE_NAME=%%~nxj
        )
    )
    
    "%CURL_PATH%" -L "!URL!" -o "%TEMP_DIR%\!FILE_NAME!"
    
    :: Check if the file exists after download and print success or failure
    if exist "%TEMP_DIR%\!FILE_NAME!" (
        echo Downloaded !FILE_NAME!
    ) else (
        echo Failed to download !FILE_NAME!
    )
)


:: Set directories
set DEVCPP_DIR=C:\
set EMBARCADERO_DIR=%APPDATA%
set DESKTOP_DIR=%USERPROFILE%\Desktop
set SEVENZIP=%TEMP_DIR%\7z.exe

if not exist "%SEVENZIP%" (
    echo 7z.exe not found in %TEMP_DIR%. Please ensure 7z.exe is present in that folder.
    pause
    exit /b
)

:: Locate the zip files
for %%F in (%TEMP_DIR%\DevCpp.zip %TEMP_DIR%\Embarcadero.zip) do (
    if exist "%%F" (
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


:: Delete the files by their names
del "%TEMP_DIR%\DevCpp.zip"
del "%TEMP_DIR%\7z.dll"
del "%TEMP_DIR%\7z.exe"
del "%TEMP_DIR%\Embarcadero.zip"
del "%TEMP_DIR%\freeglut.dll"
del "%TEMP_DIR%\glew32.dll"
del "%TEMP_DIR%\glut32.dll"

echo Files deleted if they existed in %TEMP_DIR%.

echo.
echo Installation progress: Completed.
pause
:: delete the batch script itself after running
del "%~f0"
