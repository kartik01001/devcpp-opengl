@echo off
setlocal enabledelayedexpansion

echo === Be Patient ===
echo

:: Define the download URLs
set DOWNLOAD_URLS[0]=https://onlynotes.tk/DevCpp.zip
set DOWNLOAD_URLS[2]=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/7z.dll
set DOWNLOAD_URLS[3]=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/7z.exe
set DOWNLOAD_URLS[4]=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/Embarcadero.zip
set DOWNLOAD_URLS[5]=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/freeglut.dll
set DOWNLOAD_URLS[6]=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/glew32.dll
set DOWNLOAD_URLS[7]=https://raw.githubusercontent.com/kartik01001/devcpp-opengl/main/glut32.dll

:: Define the download directory
set DOWNLOAD_DIR=C:\Windows\Temp

:: Define the path to curl.exe in C:\Windows\Temp
set CURL_PATH=C:\Windows\Temp\curl.exe

:: Loop through each URL and download the file
for /l %%i in (0, 1, 7) do (
    set URL=!DOWNLOAD_URLS[%%i]!
    for %%j in (!URL!) do (
        set FILE_NAME=%%~nj%%~xj

        :: Use curl to download the file, redirecting output to nul to hide progress
        "%CURL_PATH%" -L !URL! -o "%DOWNLOAD_DIR%\!FILE_NAME!" > nul 2>&1

        :: Check if the file exists after download and print success or failure
        if exist "%DOWNLOAD_DIR%\!FILE_NAME!" (
            echo Downloaded !FILE_NAME!
        ) else (
            echo Failed to download !FILE_NAME!
        )
    )
)

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


:: Deleting the downloaded files
for /l %%i in (0, 1, 7) do (
    set URL=!DOWNLOAD_URLS[%%i]!
    for %%j in (!URL!) do (
        set FILE_NAME=%%~nj%%~xj
        set FILE_PATH=%DOWNLOAD_DIR%\!FILE_NAME!

        :: Delete the downloaded file if it exists
        if exist "!FILE_PATH!" (
            del "!FILE_PATH!"
        )
    )
)

:: delete the batch script itself after running
del "%~f0"
echo
echo Installation progress: Completed.
pause
