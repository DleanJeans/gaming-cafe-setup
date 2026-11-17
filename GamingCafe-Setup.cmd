@echo off
setlocal
title Gaming Cafe Setup

rem Official Chrome Web Store listings.
set "DARK_READER=https://chromewebstore.google.com/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh?hl=en"
set "UBLOCK_ORIGIN_LITE=https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh?hl=en"

rem Official Tracker.gg Windows download.
set "MARVEL_RIVALS_TRACKER=https://download.overwolf.com/install/Download?ExtensionId=cbalplcokeaonnkeckofomheibnkijnbloilkjhh&partnerId=4504&utm_campaign=none"

rem Marvel Rivals player stats.
set "RIVALS_DATA=https://rivalsdata.com/player/520435205"

rem Tracker.gg live match.
set "TRACKER_LIVE=https://tracker.gg/marvel-rivals/matches/live/ign/DleanJeans"

rem Peni maps.
set "PENI_MAPS=https://pgc-talha.github.io/Peni/#/maps"

set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%LocalAppData%\Google\Chrome\Application\chrome.exe"

echo Opening the official setup pages...
if exist "%CHROME%" (
    start "" "%CHROME%" "%UBLOCK_ORIGIN_LITE%" "%DARK_READER%" "%RIVALS_DATA%" "%TRACKER_LIVE%" "%PENI_MAPS%"
) else (
    start "" "%UBLOCK_ORIGIN_LITE%"
    start "" "%DARK_READER%"
    start "" "%RIVALS_DATA%"
    start "" "%TRACKER_LIVE%"
    start "" "%PENI_MAPS%"
)

echo Starting the official Marvel Rivals Tracker download...
start "" "%MARVEL_RIVALS_TRACKER%"

rem Windows pointer speed: 1-20 on the Settings slider (default 10).
set "MOUSE_SPEED=5"
echo Setting Windows pointer speed to %MOUSE_SPEED%...
rem SPI_SETMOUSESPEED (0x71) applies now; flag 3 also saves it to the registry and notifies apps.
powershell -NoProfile -Command "Add-Type -Name M -Namespace W -MemberDefinition '[DllImport(\"user32.dll\")] public static extern bool SystemParametersInfo(uint a, uint b, IntPtr c, uint d);'; [void][W.M]::SystemParametersInfo(0x71, 0, [IntPtr]%MOUSE_SPEED%, 3)"

rem Windows dark mode for apps and the taskbar/Start (0 = dark, 1 = light).
echo Setting Windows dark mode...
set "PERSONALIZE=HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
reg add "%PERSONALIZE%" /v AppsUseLightTheme /t REG_DWORD /d 0 /f >nul
reg add "%PERSONALIZE%" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f >nul

rem G HUB DPI for the active profile's mouse (cafe uses G102/G203 LIGHTSYNC).
set "DPI_LEVELS=1200,1600,2000,2400,3200"
set "DPI_DEFAULT=1200"
set "SQLITE_ZIP=https://www.sqlite.org/2026/sqlite-tools-win-x64-3540100.zip"
set "LGHUB_DB=%LocalAppData%\LGHUB\settings.db"
set "SQLITE=%TEMP%\sqlite3.exe"
if not exist "%LGHUB_DB%" goto :skip_dpi

echo Setting G HUB DPI to %DPI_LEVELS%...
if not exist "%SQLITE%" curl -sL -o "%TEMP%\sqlite.zip" "%SQLITE_ZIP%" && tar -xf "%TEMP%\sqlite.zip" -C "%TEMP%" sqlite3.exe
taskkill /f /im lghub.exe /im lghub_agent.exe /im lghub_system_tray.exe >nul 2>&1
timeout /t 2 /nobreak >nul
rem Keep the first backup; later runs would overwrite it with already-patched settings.
if not exist "%LGHUB_DB%.bak" copy "%LGHUB_DB%" "%LGHUB_DB%.bak" >nul
rem Step 1: if the mouse uses G HUB's read-only default settings, add an editable copy and point the profile at it.
rem Step 2: set DPI on the editable settings; fails safely (no write) if none is found.
rem Only the first profile with mouse settings is handled; the cafe has just the default profile.
"%SQLITE%" "%LGHUB_DB%" "UPDATE data SET file = COALESCE(CAST((SELECT json_set(json_insert(CAST(data.file AS TEXT), '$.cards.cards[#]', json_object('attribute', 'MOUSE_SETTINGS', 'id', 'd9100000-0000-4000-8000-00000000d910', 'mouseSettings', json(json_extract(c.value, '$.mouseSettings')), 'name', 'DEFAULT_CARD_NAME_MOUSE_SETTINGS', 'profileId', json_extract(p.value, '$.id'))), '$.profiles.profiles[' || p.key || '].assignments[' || a.key || '].cardId', 'd9100000-0000-4000-8000-00000000d910') FROM json_each(CAST(data.file AS TEXT), '$.cards.cards') c, json_each(CAST(data.file AS TEXT), '$.profiles.profiles') p, json_each(p.value, '$.assignments') a WHERE json_extract(a.value, '$.slotId') LIKE '%%mouse_settings' AND json_extract(a.value, '$.cardId') = json_extract(c.value, '$.id') AND json_extract(c.value, '$.readOnly') IS 1 LIMIT 1) AS BLOB), file) WHERE _id = 1;" "UPDATE data SET file = CAST((SELECT json_set(CAST(data.file AS TEXT), '$.cards.cards[' || c.key || '].mouseSettings.dpiTable', json_object('activeDpi', %DPI_DEFAULT%, 'defaultDpi', %DPI_DEFAULT%, 'shiftDpi', %DPI_DEFAULT%, 'levels', json_array(%DPI_LEVELS%))) FROM json_each(CAST(data.file AS TEXT), '$.cards.cards') c, json_each(CAST(data.file AS TEXT), '$.profiles.profiles') p, json_each(p.value, '$.assignments') a WHERE json_extract(a.value, '$.slotId') LIKE '%%mouse_settings' AND json_extract(a.value, '$.cardId') = json_extract(c.value, '$.id') AND json_extract(c.value, '$.readOnly') IS NOT 1 LIMIT 1) AS BLOB) WHERE _id = 1;"
if errorlevel 1 (echo   DPI patch failed, G HUB settings left unchanged.) else (echo   DPI set.)
rem The G HUB window needs the agent (websocket on port 9010) running first.
start "" "%ProgramFiles%\LGHUB\lghub_agent.exe"
timeout /t 3 /nobreak >nul
start "" "%ProgramFiles%\LGHUB\lghub.exe"
:skip_dpi

echo.
echo Next steps:
echo   1. Click "Add to Chrome" on the Dark Reader tab.
echo   2. Click "Add to Chrome" on the uBlock Origin Lite tab.
echo   3. Check your Marvel Rivals stats on the RivalsData tab.
echo   4. Check your live match on the Tracker.gg tab.
echo   5. Check the maps on the Peni tab.
echo   6. Run the Tracker installer after it finishes downloading, if the cafe allows it.
echo.
echo The browser extensions install only after Chrome asks for your confirmation.
pause