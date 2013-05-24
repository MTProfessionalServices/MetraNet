@echo off

set branch=E:\Builds\6.7.0-Trunk

Echo Stopping all services
call stopallservices

Echo Updating %branch%
svn update %branch%

echo Building %branch$
call makeitall

Echo Building test harness
s:
cd s:\shared\testharness
call make.bat

Echo Building Unit tests for %branch%
c:
cd %branch%\UnitTests\MetraTech
call %branch%\UnitTests\MetraTech\BuildUT.bat

Echo Copying unit tests to bin directory
call xcopy o:\UnitTests o:\debug\bin /Y /S /I /C

Echo Setting up machine
call setupmachine

Echo Running smoke tests
call UISmokes.bat
Echo Done.

