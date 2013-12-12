@Set SubmodulePath=RMP/Extensions/coreQA_Source_Internal

@pushd %ROOTDIR%\..\..\..\..

@rem Check if the CoreQA submodule was initialized
@git config --list|grep submodule.*%SubmodulePath%>c1010e69-eac9-40c7-bcc7-ee49e0addbe4.txt
@Set /p SubmoduleStatus=<c1010e69-eac9-40c7-bcc7-ee49e0addbe4.txt
@del /F c1010e69-eac9-40c7-bcc7-ee49e0addbe4.txt
@if "%SubmoduleStatus%"=="" git submodule update --init %SubmodulePath%
@popd

@pushd %ROOTDIR%\..\..\coreQA_Source_Internal\Scripts
@call RunAcceptanceTests_DEV.bat
@popd
