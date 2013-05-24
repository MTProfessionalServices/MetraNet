@echo off
REM To call postBuild.bat from a project use the following syntax:
REM %ROOTDIR%\MetraTech\postBuild.bat $(ProjectDir) $(ConfigurationName)

echo Changing to project output directory %1bin\%2
cd %1bin\%2

echo Removing tlb files
del *.tlb /Q

echo Copying files to %MTOUTDIR%\%2\bin 
cp *.* %MTOUTDIR%\%2\bin

REM echo Deleting temp build files from %1
REM del *.* /Q
REM cd ..\..\obj\%2
REM del *.* /Q

