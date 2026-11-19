# gaming-cafe-setup

One-click setup for a gaming cafe PC. Run `GamingCafe-Setup.cmd` to:

- open Dark Reader, uBlock Origin Lite, RivalsData and Peni maps in Chrome, plus RivalsData stats and RivalsMeta characters (rank 6+) in two side-by-side windows
- start the Marvel Rivals Tracker download
- set the Windows pointer speed and dark mode
- set Marvel Rivals graphics to Low (patches `%LocalAppData%\Marvel\Saved\Config\Windows\GameUserSettings.ini`; applies the Low preset values and a 240 FPS limit; keeps a `.bak`; skipped if the file is missing)
- set the Steam overlay shortcut to Shift+F2 (closes Steam and patches each account's `localconfig.vdf`; keeps a `.bak`)
- optionally launch Marvel Rivals through Steam and press LAUNCH in its launcher (asks first, defaults to No)
- set Logitech G HUB DPI levels (patches `%LocalAppData%\LGHUB\settings.db`; the first run keeps a `.bak`)

Edit the `set` lines at the top of each section to change the values.
