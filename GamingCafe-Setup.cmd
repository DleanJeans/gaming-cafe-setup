@echo off
setlocal
title Gaming Cafe Setup

rem Official Chrome Web Store listings.
set "DARK_READER=https://chromewebstore.google.com/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh?hl=en"
set "UBLOCK_ORIGIN_LITE=https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh?hl=en"

rem Official Tracker.gg Windows download.
set "MARVEL_RIVALS_TRACKER=https://download.overwolf.com/install/Download?ExtensionId=cbalplcokeaonnkeckofomheibnkijnbloilkjhh&partnerId=4504&utm_campaign=none"

rem Official GitHub Desktop Windows download (starts the installer download) and Claude Desktop download page.
set "GITHUB_DESKTOP=https://central.github.com/deployments/desktop/desktop/latest/win32"
set "CLAUDE_DESKTOP=https://claude.com/download"

rem Marvel Rivals player stats.
set "RIVALS_DATA=https://rivalsdata.com/player/520435205"

rem %% in the RivalsMeta URL escapes the percent sign for batch.
set "RIVALS_STATS=https://rivalsdata.com/stats"
set "RIVALS_META=https://rivalsmeta.com/characters?rank=6%%2B"

rem Peni maps.
set "PENI_MAPS=https://pgc-talha.github.io/Peni/#/maps"

set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%LocalAppData%\Google\Chrome\Application\chrome.exe"

echo Opening the official setup pages...
if not exist "%CHROME%" goto :no_chrome
start "" "%CHROME%" "%UBLOCK_ORIGIN_LITE%" "%DARK_READER%" "%RIVALS_DATA%" "%RIVALS_STATS%" "%RIVALS_META%" "%PENI_MAPS%"
goto :pages_done
:no_chrome
start "" "%UBLOCK_ORIGIN_LITE%"
start "" "%DARK_READER%"
start "" "%RIVALS_DATA%"
start "" "%RIVALS_STATS%"
start "" "%RIVALS_META%"
start "" "%PENI_MAPS%"
:pages_done

rem Installers the script opens once downloaded. Older copies are removed first so the wait below only sees new downloads.
set "TRACKER_INSTALLER=%USERPROFILE%\Downloads\Marvel Rivals Tracker - Installer.exe"
set "GITHUB_INSTALLER=%USERPROFILE%\Downloads\GitHubDesktopSetup-x64.exe"
set "CLAUDE_INSTALLER=%USERPROFILE%\Downloads\Claude Setup.exe"
if exist "%TRACKER_INSTALLER%" del "%TRACKER_INSTALLER%"
if exist "%GITHUB_INSTALLER%" del "%GITHUB_INSTALLER%"
if exist "%CLAUDE_INSTALLER%" del "%CLAUDE_INSTALLER%"

echo Starting the GitHub Desktop download and opening the Claude Desktop download page...
start "" "%GITHUB_DESKTOP%"
start "" "%CLAUDE_DESKTOP%"

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

rem Marvel Rivals graphics to Low and max FPS 240 (FrameRateLimit): the exact [ScalabilityGroups] values the game writes for its Low preset.
rem Missing keys are added (the game omits them until a preset is applied); other settings are untouched.
rem Skipped if the file is missing, so run the game once first. Close the game before running.
set "RIVALS_INI=%LocalAppData%\Marvel\Saved\Config\Windows\GameUserSettings.ini"
if not exist "%RIVALS_INI%" goto :skip_graphics
echo Setting Marvel Rivals graphics to Low...
rem Keep the first backup; later runs would overwrite it with already-patched settings.
if not exist "%RIVALS_INI%.bak" copy "%RIVALS_INI%" "%RIVALS_INI%.bak" >nul
powershell -NoProfile -Command "$p=$env:RIVALS_INI;$lines=New-Object Collections.Generic.List[string];$lines.AddRange([string[]](Get-Content -LiteralPath $p));$h=$lines.IndexOf('[ScalabilityGroups]');if($h -lt 0){$lines.Add('');$lines.Add('[ScalabilityGroups]');$h=$lines.Count-1};$m=$lines.IndexOf('[/Script/Marvel.MarvelGameUserSettings]');if($m -lt 0){$lines.Add('');$lines.Add('[/Script/Marvel.MarvelGameUserSettings]');$m=$lines.Count-1};$v=[ordered]@{ViewDistanceQuality=1;ShadowQuality=0;PostProcessQuality=0;TextureQuality=0;EffectsQuality=0;FoliageQuality=0;ShadingQuality=0;ReflectionQuality=1;GlobalIlluminationQuality=1};foreach($k in $v.Keys){$s='sg.'+$k+'=';$newline=$s+$v[$k];$i=-1;for($j=0;$j -lt $lines.Count;$j++){if($lines[$j].StartsWith($s)){$i=$j;break}};if($i -ge 0){$lines[$i]=$newline}else{$lines.Insert($h+1,$newline)}};$f=-1;for($j=0;$j -lt $lines.Count;$j++){if($lines[$j].StartsWith('FrameRateLimit=')){$f=$j;break}};if($f -ge 0){$lines[$f]='FrameRateLimit=240.000000'}else{$m=$lines.IndexOf('[/Script/Marvel.MarvelGameUserSettings]');$lines.Insert($m+1,'FrameRateLimit=240.000000')};[IO.File]::WriteAllLines($p,$lines)"
if errorlevel 1 (echo   Graphics patch failed, settings left unchanged.) else (echo   Graphics set to Low.)
:skip_graphics

rem G HUB DPI for the active profile's mouse (cafe uses G102/G203 LIGHTSYNC).
set "DPI_LEVELS=1200,1600,2000,2400,3200"
set "DPI_DEFAULT=1600"
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

rem Steam overlay shortcut (default Shift+Tab clashes with in-game keys). Edits every account's localconfig.vdf under the Steam folder.
rem Steam must be closed to keep the edit, so this closes it (the Steam launch below reopens it). Keeps a .bak next to each file.
set "OVERLAY_MOD=Shift"
set "OVERLAY_KEY=KEY_F2"
set "STEAM_DIR="
for /f "tokens=2,*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul') do set "STEAM_DIR=%%b"
if not defined STEAM_DIR goto :skip_overlay
set "STEAM_DIR=%STEAM_DIR:/=\%"
echo Setting Steam overlay shortcut to %OVERLAY_MOD%+%OVERLAY_KEY%...
powershell -NoProfile -Command "$d=$env:STEAM_DIR;$q=[char]34;$t=[char]9;$newline=$t+$t+$q+'InGameOverlayShortcutKey'+$q+$t+$t+$q+$env:OVERLAY_MOD+$t+$env:OVERLAY_KEY+$q;$s=Get-Process steam -ErrorAction SilentlyContinue;if($s){& ($d+'\steam.exe') -shutdown;$s|Wait-Process -Timeout 30 -ErrorAction SilentlyContinue;if(Get-Process steam -ErrorAction SilentlyContinue){exit 1}};foreach($f in Get-ChildItem ($d+'\userdata\*\config\localconfig.vdf')){$b=$f.FullName+'.bak';if(-not(Test-Path $b)){Copy-Item $f.FullName $b};$lines=New-Object Collections.Generic.List[string];$lines.AddRange([string[]][IO.File]::ReadAllLines($f.FullName));$i=-1;for($j=0;$j -lt $lines.Count;$j++){if($lines[$j] -like '*InGameOverlayShortcutKey*'){$i=$j;break}};if($i -ge 0){$lines[$i]=$newline}else{$h=$lines.IndexOf($t+$q+'system'+$q);if($h -lt 0){exit 1};$lines.Insert($h+2,$newline)};[IO.File]::WriteAllLines($f.FullName,$lines)}"
if errorlevel 1 (echo   Steam overlay patch failed, settings left unchanged.) else (echo   Steam overlay shortcut set.)
:skip_overlay

rem Optional: launch Marvel Rivals through Steam (app id 2767030). Asked at run time since the PCs are shared; defaults to No after 10 seconds.
rem Runs last so the graphics settings above are written before the game starts.
choice /c YN /t 10 /d N /m "Launch Marvel Rivals through Steam now"
if errorlevel 2 goto :skip_launch
echo Launching Marvel Rivals through Steam...
start "" "steam://rungameid/2767030"
rem Click LAUNCH in the game launcher: waits up to 90s for a window titled "Launcher", then clicks the button
rem at 83% across and 89% down the window (position taken from a screenshot). Fails quietly if it never appears.
echo Waiting for the launcher, then pressing LAUNCH...
powershell -NoProfile -Command "$sig='[StructLayout(LayoutKind.Sequential)] public struct RECT{public int L,T,R,B;} [DllImport(\"user32.dll\")] public static extern bool GetWindowRect(IntPtr h,out RECT r); [DllImport(\"user32.dll\")] public static extern bool SetForegroundWindow(IntPtr h); [DllImport(\"user32.dll\")] public static extern bool SetCursorPos(int x,int y); [DllImport(\"user32.dll\")] public static extern void mouse_event(uint f,uint x,uint y,uint d,UIntPtr e);';Add-Type -Name U -Namespace L -UsingNamespace System.Runtime.InteropServices -MemberDefinition $sig;$w=$null;for($n=0;$n -lt 90;$n++){$w=Get-Process|Where-Object{$_.MainWindowTitle -eq 'Launcher'}|Select-Object -First 1;if($w){break};Start-Sleep 1};if(-not $w){exit 1};Start-Sleep 3;$r=New-Object 'L.U+RECT';[void][L.U]::GetWindowRect($w.MainWindowHandle,[ref]$r);[void][L.U]::SetForegroundWindow($w.MainWindowHandle);Start-Sleep -Milliseconds 500;$x=[int]($r.L+0.83*($r.R-$r.L));$y=[int]($r.T+0.894*($r.B-$r.T));[void][L.U]::SetCursorPos($x,$y);[L.U]::mouse_event(2,0,0,0,[UIntPtr]::Zero);Start-Sleep -Milliseconds 100;[L.U]::mouse_event(4,0,0,0,[UIntPtr]::Zero)"
if errorlevel 1 (echo   Launcher window not found, press LAUNCH yourself.) else (echo   LAUNCH pressed.)
:skip_launch

rem Open each installer once its download has finished (waits up to 120s in total for the files to stop growing).
rem The Claude installer only downloads after you click Download for Windows on the Claude page.
echo Waiting for the installer downloads (Tracker, GitHub Desktop, Claude Desktop)...
powershell -NoProfile -Command "$fs=@($env:TRACKER_INSTALLER,$env:GITHUB_INSTALLER,$env:CLAUDE_INSTALLER);$p=@{};$sz=@{};for($i=0;$i -lt 120 -and $p.Count -lt $fs.Count;$i++){foreach($f in $fs){if($p[$f]){continue};if(Test-Path -LiteralPath $f){$n=(Get-Item -LiteralPath $f).Length;if($n -gt 0 -and $sz[$f] -eq $n){Start-Process -FilePath $f;$p[$f]=1}else{$sz[$f]=$n}}};Start-Sleep 1};if($p.Count -lt $fs.Count){exit 1}"
if errorlevel 1 (echo   Some installers were not found in Downloads, run those yourself once downloaded.) else (echo   Installers opened.)

echo.
echo Next steps:
echo   1. Click "Add to Chrome" on the Dark Reader tab.
echo   2. Click "Add to Chrome" on the uBlock Origin Lite tab.
echo   3. Check your Marvel Rivals stats on the RivalsData tab.
echo   4. Check the maps on the Peni tab.
echo   5. Check the RivalsData stats and RivalsMeta characters tabs.
echo   6. Click Download for Windows on the Claude page if it has not downloaded yet.
echo   7. Click through the installer windows that opened: Tracker, GitHub Desktop, Claude Desktop (if the cafe allows it).
echo.
echo The browser extensions install only after Chrome asks for your confirmation.
pause