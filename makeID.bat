@echo off
cls

echo START LOG > makeID.log

set "source=%~n1"
if defined source goto :main

call :log "Asking for mod type..."
set /p "source=Enter mod type (1 for Armor, 2 for Sword): " || call :sub_error "Wrong mod type.*" && goto:eof

if %source% equ 1 (set "source=pl226") else (if %source% equ 2 (set "source=S_Swd059") else (call :sub_error "Wrong mod type." && goto:eof))

:main

if "%source%"=="pl226" (set "scode=pl") else (if "%source%"=="S_Swd059" (set "scode=S_Swd") else (call :sub_error "Wrong source folder." && goto:eof))

if not exist %source%\ (call :sub_error "Missing %source% folder. Make sure the folder is within the same directory of this script." && goto:eof)
call :log "%source% folder found. Proceding..."

set "files2process="

set /a "nf2p=0"
call :log "Processing files within %source% folder..."
for /f "tokens=*" %%a in ('dir /b /a:-d "%source%"') do (
    set "test=%%a"
    set "test=%test:.mdf=%"
    set "test=%test:.mesh=%"
    set "test=%test:.chain=%"
    set "test=%test:.user=%"
    if not "%%a"=="%test%" (
        call :log "Found %%a. Adding to list of files to process..."
        call :set_for files2process "%%a"
        call :inc nf2p
    )
)

if "%source%"=="pl226" (if %nf2p% neq 9 call :sub_error "Incorrect asset files. There should be 9 files that are .mdf, .mesh, .chain, or. user." && goto:eof) else (if %nf2p% neq 3 call :sub_error "Incorrect asset files. There should be 3 files that are .mdf or .mesh" && goto:eof)

call :log "Asking for desired new ID..."
set /p "id=Enter desired new ID (e.g. pl001 or S_Swd001, enter 001): "|| set "id=0"
call :configure_id id || goto:eof

if exist %scode%%id%\ (call :exists || goto:eof)

call :print "Creating folder: [%scode%%id%/]..."
md %scode%%id% 2>nul
for %%a in (%files2process%) do call :copy %%a

call :print "Finished."
pause

echo END LOG >> makeID.log
goto:eof

:configure_id
call set "content=%%%1%%"
call :isnumber %content% || exit /b 1
if %content% equ 0 (call :sub_error "Make sure to enter a correct id" && exit /b 1)
set "delzero=1"
if %content:~0,1% equ 0 (set "content=%content:~1%") else (set "delzero=")
if defined delzero if %content:~0,1% equ 0 set "content=%content:~1%"
set /a "content=%content%"
if %content% lss 1 (call :sub_error "Make sure to enter a correct id" && exit /b 1)
if %content% gtr 999 (call :sub_error "Make sure to enter a correct id" && exit /b 1)
set /a "content+=1000"
set "content=%content:~1%"
set "%1=%content%"
exit /b 0

:print 
echo %~1
call :log "%~1" "%~2"
exit /b

:log 
set "type=ERROR"
if [%~2]==[] set "type=INFO"
echo [%type%] %~1 >> makeID.log
exit /b

:copy
set "item=%1"
call set sid=%%source:%scode%=%%
call set "item=%%item:%sid%=%id%%%"
call :print "Copying [%source%/%1] to [%scode%%id%] as [%item%]..."
for /r "%source%" %%x in (%1) do copy /y /v "%%x" "%scode%%id%\%item%" > nul 2>&1
exit /b

:exists
setlocal
call :log "Confirming to overwrite desired ID folder..."
set /p "confirm=Desired ID folder already exists. Overwrite (Y/N)? " || set "confirm=n"
if /i "%confirm:~0,1%"=="n" (
    call :log "Overwriting was declined."
    call :print "Exiting..."
    endlocal
    exit /b 1
)
call :log "Overwriting was accepted."
endlocal
exit /b 0

:sub_error
call :print "An error occured." err
call :print "%~1" err
call notepad.exe makeID.log
pause
exit /b 0

:inc
set "snd=%2"
if not defined snd set "snd=1"
set /a %1+=%snd%
exit /b

:set_for
call set "%1=%%%1%% %~2"
exit /b

:isnumber
if 1%1 neq +1%1 call :sub_error "Make sure to enter a correct id" && exit /b 1
exit /b 0
