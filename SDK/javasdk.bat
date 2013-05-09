rem You are in C:\JavaSDK folder.  Folder contains this script + source for 
rem MetraTech JAVA SDK.
rem 
rem C:\packages\java should contain the jclark xml parser stuff.
rem C:\javaoutput should contain the output classes  
rem 
rem Now, you are ready to compile
rem To compile you need to do the following things:
rem 1. set CLASSPATH=.;c:\JavaSDK;c:\packages\java;c:\javaoutput;C:\j2sdk1.4.1_01\lib
rem 2. set OUTDIR to C:\javaoutput

@echo on
pushd .
set oldpath=%CLASSPATH%
set OUT=%OUTDIR%\java


rem build output directories
rmdir /s /q %OUT%
mkdir %OUT%

cd %ROOTDIR%\Java\Thirdparty\com\jclark\xml\parse
javac -d %OUT% *.java
cd %ROOTDIR%\Java\Thirdparty\com\jclark\xml\parse\io
javac -d %OUT% *.java
cd %ROOTDIR%\Java\Thirdparty\com\jclark\xml\parse\base
javac -d %OUT% *.java
cd %ROOTDIR%\Java\Thirdparty\com\jclark\xml\tok
javac -d %OUT% *.java
cd %ROOTDIR%\Java\Thirdparty\com\jclark\util\
javac -d %OUT% *.java

cd %ROOTDIR%\Java\SDK\com\metratech\sdk\base
javac -d %OUT% *.java
cd %ROOTDIR%\Java\SDK\com\metratech\sdk\utils
javac -d %OUT% *.java
cd %ROOTDIR%\Java\SDK\com\metratech\sdk\samples
javac -d %OUT% *.java

:doc
mkdir %OUT%\doc
javadoc -d %OUT%\doc %ROOTDIR%\Java\SDK\com\metratech\sdk\base\*.java %ROOTDIR%\Java\SDK\com\metratech\sdk\utils\*.java

:samples
copy %ROOTDIR%\Java\SDK\com\metratech\sdk\samples\*.java %OUT%\com\metratech\sdk\samples\
copy %ROOTDIR%\Java\SDK\Version.txt %OUT%\doc

:jar
%OUTDIR%
set OUT=%OUTDIR%\java
cd %OUT%
jar cvf mtsdk.jar com 

set CLASSPATH=%oldpath%
popd
