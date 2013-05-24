@ECHO OFF
CLS
Echo -- W3Runner Builder --

Call install\RegisterDLL.bat

REM Echo W3Wiper.exe
REM Cd W:\app\W3Wiper
REM Del W3Wiper.compile.error.log
REM vb6.exe  /m W3Wiper.vbp /out W3Wiper.compile.error.log /outdir "%OUTDIR%\debug\bin"
REM Type W3Wiper.compile.error.log
REM Cd W:\
REM Echo .


Echo www.w3runner.com.monitor
Cd W:\app\w3monitor
Del W3Monitor.compile.error.log
vb6.exe  /m W3Monitor.vbp /out W3Monitor.compile.error.log /outdir "%OUTDIR%\debug\bin"
Type W3Monitor.compile.error.log
Cd W:\
Echo .

Echo Soap Demo COM Object
Cd W:\Dll\SoapComObjects\Calc
Del CalcSvcRpcVb.compile.error.log
vb6.exe  /m CalcSvcRpcVb.vbp /out CalcSvcRpcVb.compile.error.log /outdir "%OUTDIR%\debug\bin"
Type CalcSvcRpcVb.compile.error.log
Cd W:\
Echo .

Echo ActiveX Control Demo
Cd W:\Test\ActiveX
Del W3RunnerAXDemo.compile.error.log
vb6.exe  /m W3RunnerAXDemo.vbp /out W3RunnerAXDemo.compile.error.log /outdir "%OUTDIR%\debug\bin"
Type W3RunnerAXDemo.compile.error.log
Cd W:\
Echo .



Echo Build W3Runner DLL
Cd Dll
Del W3RunnerDLL.compile.error.log
vb6.exe  /m W3RunnerDLL.vbp /out W3RunnerDLL.compile.error.log /outdir "%OUTDIR%\debug\bin"
Type W3RunnerDLL.compile.error.log
Echo .
Cd ..

Echo Build Setup1.exe
cd Install
cd setup.source
Del SETUP1.compile.error.log
vb6.exe  /m SETUP1.vbp /out SETUP1.compile.error.log /outdir .
Type SETUP1.compile.error.log
Echo .
cd ..
cd ..


Echo Building W3RunnerRT
cd
Del W3RunnerRT.compile.error.log
vb6.exe  /m W3RunnerRT.vbp /out W3RunnerRT.compile.error.log /outdir "%OUTDIR%\debug\bin"
Type W3RunnerRT.compile.error.log
Echo .


Echo Building W3Runner
cd
Del W3Runner.compile.error.log
vb6.exe  /m W3Runner.vbp /out W3Runner.compile.error.log /outdir "%OUTDIR%\debug\bin"
Type W3Runner.compile.error.log
Echo .



call UpdateOutPutDir.bat

Echo W3Runner Build Done
Pause


