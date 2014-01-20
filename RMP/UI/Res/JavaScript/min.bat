s:
cd s:\metratech\ui\metracare\javascript
for %%i in (*.js) do java -jar S:\Thirdparty\yuicompressor-2.4.2\build\yuicompressor-2.4.2.jar --nomunge -o %%i.min.js %%i
