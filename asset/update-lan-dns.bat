
@echo off
setlocal enabledelayedexpansion

SET GitlabAddr=http://192.168.8.65:10080
SET NodejsMsi=node-v8.9.0-x64.msi
SET NodejsUrlBase=http://192.168.8.173:8000/

SET NodejsUrl='%NodejsUrlBase%%NodejsMsi%'
SET NodejsMsiSave='%NodejsMsi%'

REM Enter directory contains the batch file
SET mypath=%~dp0
cd %mypath%
SET CWD=%cd%
REM echo %CWD%

SET NPM=npm
REM Check existence of npm
where npm
if %errorlevel%==1 (echo.
  echo Downloading %NodejsMsi%, please be patient...
  call:download %NodejsUrl% %NodejsMsiSave%
  call %NodejsMsi%
  del %NodejsMsi%
  pause
  GOTO:eof
)

REM Check the installation for 'npm'
where %NPM%
if %errorlevel%==1 (
  echo %NPM% installation failed!
  echo Please install it manually: https://nodejs.org/en/download/
  pause
  GOTO:eof
)

REM Try install hosts-edit
where hosts-edit
if %errorlevel%==1 (
  REM call npm install -g https://github.com/windsting/hosts-editor
  call npm install -g hosts-edit
)

REM Check the installation for 'hosts-edit'
where hosts-edit
if %errorlevel%==1 (
  echo hosts-edit installation failed! try again later.
  pause
  GOTO:eof
)

REM Download hosts entry list.
set EntryListAddr='%GitlabAddr%/wangg/hosts-edit/raw/feature/quying-dns/asset/entry_list'
echo %EntryListAddr%
set SaveName='%CWD%\entry_list.txt'
call:download %EntryListAddr% %SaveName%

REM add all entries into hosts
for /F "tokens=*" %%A in (entry_list.txt) do (
   call hosts-edit %%A
)

del entry_list.txt

call ping gitlab.quying.local
if %errorlevel%==1 (echo.
  echo.&echo.&echo.
  echo Run with the account of Administrator, again.
  echo.&echo.
  pause
  GOTO:eof
)

echo.
echo.
echo.
echo It's done, go access: http://gitlab.quying.local
echo.
echo.

echo.&pause&goto:eof

:: Functions definition below here

:download
@echo off
powershell -command "$req=(new-object System.Net.WebClient); $req.headers['User-Agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.40 Safari/537.17'; $req.DownloadFile(%~1, %~2)"
GOTO:EOF