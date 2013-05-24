<!--
This script saves the received file to the directory
/upload under the Web's root. It makes use of a COM
component aspSmartUpload. There are also solutions
around doing this by hand
-->

<HTML> <BODY>  

<H1>File Upload via HTTP</H1> 
<HR>  

<% 

'Variables 
Dim mySmartUpload    
Dim intCount          

'Object creation 
Set mySmartUpload = Server.CreateObject("aspSmartUpload.SmartUpload")  

'Upload 
mySmartUpload.Upload  

'Save the files with their original names in a virtual path of the web server 
intCount = mySmartUpload.Save("/upload")    

'sample with a physical path     
' intCount = mySmartUpload.Save("c:\temp\")  

'Display the number of files uploaded 
Response.Write(intCount & " file(s) uploaded.") 

%> 

</BODY> </HTML> 
