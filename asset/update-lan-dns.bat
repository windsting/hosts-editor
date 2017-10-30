
@echo off
setlocal enabledelayedexpansion

SET GitlabAddr=http://192.168.8.172
SET NodejsMsi=node-v8.8.1-x64.msi
SET NodejsUrlBase=https://nodejs.org/dist/v8.8.1/

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
  pause
  GOTO:eof
)

REM Check the installation for 'npm'
where %NPM%m
if %errorlevel%==1 (
  echo %NPM% installation failed!
  echo Please install it manually: https://nodejs.org/en/download/
  pause
  GOTO:eof
)

REM Try install hosts-edit
where hosts-edit
if %errorlevel%==1 (
  call npm install -g https://github.com/windsting/hosts-editor
)

REM Check the installation for 'hosts-edit'
where hosts-edit
if %errorlevel%==1 (
  echo hosts-edit installation failed! try again later.
  pause
  GOTO:eof
)

REM Download hosts entry list.
set EntryListAddr='%GitlabAddr%/wangg/hosts-editor/raw/feature/quying-dns/asset/entry_list'
set SaveName='%CWD%\entry_list.txt'
call:download %EntryListAddr% %SaveName%

REM add all entries into hosts
for /F "tokens=*" %%A in (entry_list.txt) do (
   call hosts-edit %%A
)

echo.&pause&goto:eof

:: Functions definition below here

:download
@echo off
powershell -command "$req=(new-object System.Net.WebClient); $req.headers['User-Agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.40 Safari/537.17'; $req.DownloadFile(%~1, %~2)"
GOTO:EOF