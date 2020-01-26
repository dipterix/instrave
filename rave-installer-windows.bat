
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
  powershell -Command "Invoke-WebRequest %GITBASHUTL% -OutFile %TEMP%/git.exe"
  "%TEMP%\git.exe"
  ECHO Installing Git Bash to download RAVE from Github. 
  SET /p=Press Enter/Return once installation is finished: 
)

powershell -Command "Invoke-WebRequest %RAVEINSTSCRIPT% -OutFile %TEMP%\RAVE.sh"
%GITPATH% %TEMP%\RAVE.sh

pause

