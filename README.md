# gaming-cafe-setup

One-click setup for a gaming cafe PC. Run `GamingCafe-Setup.cmd` to:

- open Dark Reader, uBlock Origin Lite, RivalsData (player and stats), RivalsMeta characters (rank 6+) and Peni maps in one Chrome window
- start the GitHub Desktop download and open the Claude Desktop download page
- start the Marvel Rivals Tracker download and open the installer from Downloads once it finishes
- set the Windows pointer speed and dark mode
- set Marvel Rivals graphics to Low (patches `%LocalAppData%\Marvel\Saved\Config\Windows\GameUserSettings.ini`; applies the Low preset values and a 240 FPS limit; keeps a `.bak`; skipped if the file is missing)
- set the Steam overlay shortcut to Shift+F2 (closes Steam and patches each account's `localconfig.vdf`; keeps a `.bak`)
- optionally launch Marvel Rivals through Steam and press LAUNCH in its launcher (asks first, defaults to No)
- set Logitech G HUB DPI levels (patches `%LocalAppData%\LGHUB\settings.db`; the first run keeps a `.bak`)

Edit the `set` lines at the top of each section to change the values.
