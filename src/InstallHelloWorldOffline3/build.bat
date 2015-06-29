@echo off

REM ------------------------------------------
REM オンラインかオフラインかを決定


if '%2'=='offline' goto OFFLINE
goto ONLINE

:OFFLINE
echo offline
set OFFLINE=--offline-only
goto ARCH

:ONLINE
echo online
set OFFLINE=
goto ARCH



REM ------------------------------------------
REM アーキテクチャを決定
:ARCH

if '%1'=='x86' goto X86
if '%1'=='x64' goto X64


echo "build.bat x86|x64 [offline]"

goto QUIT


REM ------------------------------------------
REM アーキテクチャごとの処理

REM ------------------------------------------
:X86
echo x86
C:\Qt\QtIFW-2.0-32\bin\binarycreator.exe %OFFLINE% -c config\config.xml -p packages HelloSetup.exe

goto QUIT


REM ------------------------------------------
:X64
echo x64
C:\Qt\QtIFW-2.0-64\bin\binarycreator.exe %OFFLINE% -c config\config.xml -p packages HelloSetup.exe

goto QUIT


REM ------------------------------------------
REM 終了
:QUIT

