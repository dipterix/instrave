
@echo off

SET GITBASHUTL="https://github.com/git-for-windows/git/releases/download/v2.25.0.windows.1/Git-2.25.0-64-bit.exe"
SET GITPATH="C:\Program Files\Git\bin\bash.exe"
SET RAVEINSTSCRIPT="https://raw.githubusercontent.com/dipterix/instrave/master/rave-installer-windows.sh"

REM "Check git bash"


if exist %GITPATH% (
  ECHO Git Bash found installed
) else (
  echo Cannot find Git Bash installed at "%GITPATH%"
  ECHO Downloading Git Bash from https://git-scm.com/download/win
  ECHO Installing Git Bash to download RAVE from Github. 
  ECHO Once Bash is installed, you might want to close this window and restart batch
  powershell -Command "Invoke-WebRequest %GITBASHUTL% -OutFile %TEMP%/git.exe"
  "%TEMP%\git.exe"
  SET /p=Press Enter/Return once installation is finished: 
)

SETLOCAL ENABLEEXTENSIONS
SET RKEY=
SET RPATH=
FOR /F "tokens=* skip=2" %%L IN ('reg.exe QUERY HKLM\Software\R-core\R /f * /k ^| sort') DO (
    IF NOT "%%~L"=="" SET "RKEY=%%~L"
)
IF NOT DEFINED RKEY (
    ECHO Unable to locate registry key HKLM\Software\Rcore\R
    EXIT /B 1
)
FOR /F "tokens=2* skip=2" %%A IN ('REG QUERY %RKEY% /v "installPath"') DO (
    IF NOT "%%~B"=="" SET "RPATH=%%~B"
)
IF NOT DEFINED RPATH (
    ECHO Unable to query registry value %RKEY%\installPath
    EXIT /B 2
)
IF NOT EXIST "%RPATH%" (
    ECHO Found path for R (%RPATH%^) does not exist
    EXIT /B 3
)
IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    SET "PATH=%RPATH%\bin\x64;C:\Rtools\bin;%PATH%"
) ELSE (
    SET "PATH=%RPATH%\bin\i386;C:\Rtools\bin;%PATH%"
)

SET RAVE_RUNNING_OS=windows


SETLOCAL ENABLEEXTENSIONS
SET HOMESTR=%HOMEPATH%\Documents


FOR /F "tokens=3* delims= " %%L IN ('reg.exe QUERY "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal') DO (
    IF NOT "%%~L"=="" SET "HOMESTR=%%~L"
)

echo %HOMESTR%

REM %GITPATH% --login rave-installer-windows.sh

if exist %TEMP%\RAVE.sh rm %TEMP%\RAVE.sh

powershell -Command "Invoke-WebRequest %RAVEINSTSCRIPT% -OutFile %TEMP%\RAVE.sh"

@echo on

%GITPATH% --login %TEMP%\RAVE.sh


pause

