@echo off
setlocal
title Tally Desk Auto
cd /d "%~dp0"
set "TALLY=C:\Program Files\TallyPrime\tally.exe"
set "TPORT=9000"
set "BPORT=9190"
echo.
echo  Tally Desk Auto - connects Tally Desk (the HTML file) to TallyPrime on this PC only (127.0.0.1).
echo  One file, nothing to install (the bridge is built into this .bat). Concept by Avinash G.
echo.
if /i "%~1"=="doctor" goto doctor
if /i "%~1"=="install" goto install
if /i "%~1"=="uninstall" goto uninstall

rem ---- 1. TallyPrime: start it if it is not running ----
tasklist /fi "imagename eq tally.exe" | find /i "tally.exe" >nul
if errorlevel 1 (
  if exist "%TALLY%" (
    echo  Starting TallyPrime...
    start "" "%TALLY%"
  ) else (
    echo  TallyPrime not found at %TALLY% - start it yourself.
  )
) else (
  echo  TallyPrime is running.
)
rem ---- 2. Open Tally Desk if the HTML sits next to this file or one folder up ----
for %%F in ("%~dp0*Tally_Desk*.html" "%~dp0..\*Tally_Desk*.html") do if exist "%%~F" ( start "" "%%~F" & goto bridge )
:bridge
echo.
echo  Keep this window open while you use Tally Desk. It reconnects by itself; Ctrl+C to stop.
echo  TallyPrime setting (once): F1 Help ^> Settings ^> Connectivity ^> Client/Server: TallyPrime acts as Both or Server, port %TPORT%.
echo.
:loop
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText('%~f0'); iex $t.Substring($t.LastIndexOf('#'+'##BRIDGE###'))"
echo  Bridge stopped - restarting in 3 seconds (close this window to quit)...
timeout /t 3 >nul
goto loop

:doctor
echo  Checks:
if exist "%TALLY%" (echo   [ok] TallyPrime found: %TALLY%) else (echo   [!!] TallyPrime not at %TALLY% - edit TALLY= in this .bat)
tasklist /fi "imagename eq tally.exe" | find /i "tally.exe" >nul && (echo   [ok] TallyPrime is running) || (echo   [!!] TallyPrime is not running)
powershell -NoProfile -Command "try{$r=Invoke-WebRequest -UseBasicParsing -TimeoutSec 4 -Method Post -Uri http://127.0.0.1:%TPORT% -Body '<ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Function</TYPE><ID>$$String</ID></HEADER><BODY><DESC><FUNCPARAMLIST><PARAM>##SVCurrentCompany</PARAM></FUNCPARAMLIST></DESC></BODY></ENVELOPE>'; Write-Host ('   [ok] Tally answers on port %TPORT%: ' + ([regex]::Match($r.Content,'<RESULT[^>]*>(.*?)</RESULT>').Groups[1].Value))}catch{Write-Host '   [!!] Tally does not answer on port %TPORT% - set F1 > Settings > Connectivity > Client/Server: Both, port %TPORT%'}"
powershell -NoProfile -Command "try{Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 http://127.0.0.1:%BPORT%/api/ping | Out-Null; Write-Host '   [ok] Bridge already running on %BPORT%'}catch{Write-Host '   [--] Bridge not running (double-click this .bat to start it)'}"
pause
goto :eof

:install
powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Startup')+'\Tally Desk Auto.lnk'); $s.TargetPath='%~f0'; $s.WorkingDirectory='%~dp0'; $s.WindowStyle=7; $s.Save()"
echo  Added to Windows startup: the bridge now starts minimised when you log in.
pause
goto :eof

:uninstall
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Tally Desk Auto.lnk" 2>nul
echo  Removed from Windows startup.
pause
goto :eof

###BRIDGE###
# Tally Desk local bridge — Concept by Avinash G
# Forwards browser requests to TallyPrime's HTTP port with CORS headers. Listens on 127.0.0.1 only.
$Port=[int]$env:BPORT; $TallyPort=[int]$env:TPORT; $ImportFile=""
$tally = "http://127.0.0.1:$TallyPort"
function Send-Tally([string]$body, [int]$tp = $TallyPort) {
  $bytes = [Text.Encoding]::UTF8.GetBytes($body)
  return (Invoke-WebRequest -Uri "http://127.0.0.1:$tp" -Method Post -Body $bytes -ContentType 'text/xml; charset=utf-8' -UseBasicParsing -TimeoutSec 180).Content
}
if ($ImportFile) {
  $xml = Get-Content -Raw -Encoding UTF8 $ImportFile
  $resp = Send-Tally $xml
  Write-Host $resp
  exit
}
# Clicking inside this window must never pause the bridge (Windows "Select" / QuickEdit mode freezes it)
try { Add-Type -Namespace TD -Name Con -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int h); [DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m); [DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);'
      $h = [TD.Con]::GetStdHandle(-10); $m = 0; [void][TD.Con]::GetConsoleMode($h, [ref]$m); [void][TD.Con]::SetConsoleMode($h, (($m -band (-bnot 0x40)) -bor 0x80)) } catch {}
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
try { $listener.Start() } catch {
  Write-Host "Tally Desk Auto is already running in another window (port $Port is taken). Close the extra window - only one is needed." -ForegroundColor Yellow
  Start-Sleep -Seconds 15; exit 1 }
Write-Host "Tally Desk bridge running on http://127.0.0.1:$Port  ->  TallyPrime $tally   (Ctrl+C to stop)" -ForegroundColor Green
while ($listener.IsListening) {
  $ctx = $listener.GetContext(); $req = $ctx.Request; $res = $ctx.Response
  # Only this file (Origin: null) or localhost pages may use the bridge — websites cannot write to your Tally
  $origin = $req.Headers['Origin']
  $allowed = (-not $origin) -or ($origin -eq 'null') -or ($origin -match '^https?://(localhost|127\.0\.0\.1)(:\d+)?$') -or ($origin -eq 'https://g-avinash21.github.io')
  if ($origin -and $allowed) { $res.Headers.Add('Access-Control-Allow-Origin', $origin); $res.Headers.Add('Vary', 'Origin') }
  $res.Headers.Add('Access-Control-Allow-Headers', 'Content-Type, X-Tally-Port')
  $res.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
  if ($allowed) { $res.Headers.Add('Access-Control-Allow-Private-Network', 'true') }
  $code = 200; $ctype = 'application/json'; $out = ''
  try {
    $path = $req.Url.AbsolutePath
    if (-not $allowed) { $code = 403; $out = '{"error":"origin not allowed"}' }
    elseif ($req.HttpMethod -eq 'OPTIONS') { $out = '' }
    elseif ($path -eq '/api/tally' -and $req.HttpMethod -eq 'POST') {
      $reader = New-Object System.IO.StreamReader($req.InputStream, [Text.Encoding]::UTF8)
      # several TallyPrime instances: the page names the port (9000-9099 on this PC only)
      $tp = $TallyPort; $hp = $req.Headers['X-Tally-Port']; if ($hp -match '^90\d\d$') { $tp = [int]$hp }
      $out = Send-Tally ($reader.ReadToEnd()) $tp; $ctype = 'text/xml; charset=utf-8'
      Write-Host ("[{0}] Forwarded voucher XML to Tally" -f (Get-Date -Format 'HH:mm:ss'))
    }
    elseif ($path -eq '/api/ping') { $out = '{"ok":true}' }
    elseif ($path -eq '/api/status') {
      try { $c = Send-Tally '<ENVELOPE><HEADER><VERSION>1</VERSION><TALLYREQUEST>Export</TALLYREQUEST><TYPE>Function</TYPE><ID>$$String</ID></HEADER><BODY><DESC><FUNCPARAMLIST><PARAM>##SVCurrentCompany</PARAM></FUNCPARAMLIST></DESC></BODY></ENVELOPE>'
            $name = ([regex]::Match($c, '<RESULT[^>]*>(.*?)</RESULT>')).Groups[1].Value
            $out = '{"ok":true,"tally":true,"company":"' + ($name -replace '"', "'") + '"}' }
      catch { $out = '{"ok":true,"tally":false}' }
    }
    elseif ($path -eq '/api/drafts') { $out = '{"drafts":[]}' }
    else { $code = 404; $out = '{"error":"not found"}' }
  } catch {
    $code = 502; $out = '{"error":"' + ($_.Exception.Message -replace '"', "'") + '"}'
  }
  $buf = [Text.Encoding]::UTF8.GetBytes($out)
  $res.StatusCode = $code; $res.ContentType = $ctype; $res.ContentLength64 = $buf.Length
  # the page may have given up (timeout / closed tab): never let that stop the bridge
  try { $res.OutputStream.Write($buf, 0, $buf.Length); $res.Close() } catch { try { $res.Abort() } catch {} }
}
