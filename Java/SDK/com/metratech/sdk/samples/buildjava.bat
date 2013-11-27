@echo on
pushd .
set OUT=%OUTDIR%\java
javac -d %OUT% -g *.java

popd



