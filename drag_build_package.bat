@echo off
setlocal enabledelayedexpansion

set REG_KEY=HKCU\Software\SublimePackager
set REG_VALUE=SevenZipPath

for /f "tokens=3*" %%a in ('reg query "%REG_KEY%" /v "%REG_VALUE%" 2^>nul') do set SEVENZIP=%%a %%b

if "!SEVENZIP!"=="" set SEVENZIP=C:\Program Files\PeaZip\res\7z\7z.exe

if "%~1"=="" (
    echo [!] Please drag plugin folders to this .bat file to run ^(multiple folders supported^)
    pause
    exit /b
)

set BAT_DIR=%~dp0
echo [*] Output directory: %BAT_DIR%

:check7z
if not exist "!SEVENZIP!" (
    echo [!] Cannot find 7z.exe at: !SEVENZIP!
    call :input_7z_path
    if !errorlevel! neq 0 goto check7z
)

goto process_plugins

:input_7z_path
set /p USER_INPUT=Please enter 7-Zip path ^(folder path or full 7z.exe path^):

set USER_INPUT=!USER_INPUT:"=!

if "!USER_INPUT!"=="" (
    echo [!] Input cannot be empty, please try again
    exit /b 1
)

if "!USER_INPUT:~255,1!" neq "" (
    echo [!] Path too long ^(exceeds 255 characters^), please enter a shorter path
    exit /b 1
)

if /i "!USER_INPUT:~-7!"=="\7z.exe" (
    set TEST_SEVENZIP=!USER_INPUT!
) else if /i "!USER_INPUT:~-6!"=="7z.exe" (
    set TEST_SEVENZIP=!USER_INPUT!
) else (
    set TEST_SEVENZIP=!USER_INPUT!\7z.exe
)

if not exist "!USER_INPUT!" (
    echo [!] Path does not exist: !USER_INPUT!
    exit /b 1
)

if not "!USER_INPUT:~-7!"=="\7z.exe" if not "!USER_INPUT:~-6!"=="7z.exe" (
    dir "!USER_INPUT!" >nul 2>nul
    if !errorlevel! neq 0 (
        echo [!] Specified path is not a valid folder: !USER_INPUT!
        exit /b 1
    )
)

if not exist "!TEST_SEVENZIP!" (
    echo [!] Cannot find 7z.exe at specified path: !TEST_SEVENZIP!
    echo [*] Please check the path or enter the full path to 7z.exe
    exit /b 1
)

"!TEST_SEVENZIP!" >nul 2>nul
if !errorlevel! gtr 1 (
    echo [!] 7z.exe cannot be executed: !TEST_SEVENZIP!
    exit /b 1
)

echo [*] 7z.exe verified successfully: !TEST_SEVENZIP!
set SEVENZIP=!TEST_SEVENZIP!

echo [*] Saving 7z.exe path to registry...
reg add "%REG_KEY%" /v "%REG_VALUE%" /t REG_SZ /d "!SEVENZIP!" /f >nul 2>&1
if !errorlevel! == 0 (
    echo [*] Path saved, will be automatically used next time
) else (
    echo [!] Failed to save to registry, but current session will work
)

exit /b 0

:process_plugins
:loop
if "%~1"=="" goto done

set PLUGIN_DIR=%~1
set PLUGIN_NAME=%~nx1
set OUTPUT_FILE=%BAT_DIR%\%PLUGIN_NAME%.sublime-package

echo.
echo [*] Packaging plugin: %PLUGIN_NAME%
echo [*] Plugin directory: %PLUGIN_DIR%
echo [*] Output file: %OUTPUT_FILE%
echo [*] Using 7z.exe: !SEVENZIP!

:generate_temp_name
set TEMP_ID=%RANDOM%
set EXCLUDE_FILE=%TEMP%\_exclude_list_%TEMP_ID%.txt
if exist "%EXCLUDE_FILE%" goto generate_temp_name

(
    echo .git
    echo .gitignore
) > "%EXCLUDE_FILE%"

if exist "%PLUGIN_DIR%\.gitignore" (
    echo [*] Reading .gitignore exclusion rules
    for /f "usebackq tokens=* delims=" %%i in ("%PLUGIN_DIR%\.gitignore") do (
        set line=%%i
        if not "!line!"=="" (
            if not "!line:~0,1!"=="#" (
                echo !line!>> "%EXCLUDE_FILE%"
            )
        )
    )
)

if exist "%OUTPUT_FILE%" (
    echo [*] Removing old package: %OUTPUT_FILE%
    del "%OUTPUT_FILE%"
)

pushd "%PLUGIN_DIR%"
echo [*] Starting packaging...
"!SEVENZIP!" a -tzip "%OUTPUT_FILE%" * -xr@"%EXCLUDE_FILE%"
set PACK_RESULT=!errorlevel!
popd

if exist "%EXCLUDE_FILE%" del "%EXCLUDE_FILE%"

if !PACK_RESULT! == 0 (
    echo [√] Packaging successful: %PLUGIN_NAME%.sublime-package
) else (
    echo [×] Packaging failed: %PLUGIN_NAME%
)

shift
goto loop

:done
echo.
echo [*] All plugins packaging completed!

call :cleanup_temp_files

pause
endlocal
exit /b

:cleanup_temp_files
echo [*] Cleaning up temporary files...

for %%f in ("%TEMP%\_exclude_list_*.txt") do (
    if exist "%%f" (
        del "%%f" 2>nul
        if exist "%%f" (
            echo [!] Cannot delete: %%f
        )
    )
)

echo [*] Temporary files cleanup completed
exit /b