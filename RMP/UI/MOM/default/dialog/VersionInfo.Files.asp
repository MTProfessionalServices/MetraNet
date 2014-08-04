<%response.buffer=false%>
    <HTML><HEAD><TITLE>MetraNet File Version Information</TITLE>
    
    <LINK rel='STYLESHEET' type='text/css' href='/mom/default/localized/en-us/styles/styles.css' />
    </HEAD>
    <BODY marginheight="0" marginwidth="0">
<%
response.write("<div name='InProgress' id='InProgress' align='center'><strong>Reading File Version Information</strong><BR><BR> <img src='../localized/en-us/images/working.gif' width='82' height='10' alt='' border='0'></div>")
  
Server.ScriptTimeout = 999

dim objXML, objXSL, strPathXML, strPathXSL, strPathHTML, strHTML
Set objXML = server.CreateObject("Microsoft.XMLDOM")
Set objXSL = server.CreateObject("Microsoft.XMLDOM")


strPathXSL = server.MapPath(Application("APP_HTTP_PATH") & "\default\dialog\VersionInfo.xsl")
'strPathXSL = "r:\UI\MOM\default\dialog\" & "VersionInfo.xsl"
'strPathHTML = server.MapPath(Application("APP_HTTP_PATH") & "data.htm")

'response.write ("Path is [" & strPathXSL & "]<BR>")
'response.end

dim objVersionInfo
set objVersionInfo= CreateObject("MetraTech.Statistics.VersionInfo")

dim strXML
dim sPath
    '// Determine if this is developer machine or production machine
    dim objSystemInfo
    set objSystemInfo=CreateObject("MetraTech.Statistics.SystemInfo")
    sPath = objSystemInfo.GetEnviromentVariable("outdir")
    if len(sPath)=0 then
      '//This is a production machine  
      sPath = session("INSTALL_DIR")
    else
      '//This is a developer machine
      sPath = sPath & "\debug\bin\"
    end if
strXML=objVersionInfo.GetFileVersionInfoAsXML(sPath,"\.dll$|\.exe$")
'wscript.echo("File Info is:" & sResult)

'response.write("<textarea cols='100' rows='100'>" & strXML & "</textarea>")
'response.end

Call objXML.LoadXML(strXML)
'Call objXML.Load(strPathXML)
Call objXSL.Load(strPathXSL)

'response.write "XML (" & strPathXML & "):<HR><form><textarea cols='100' rows='10'>" & objXML.xml & "</textarea></form>"
'response.end

strHTML = objXML.TransformNode(objXSL)

'dim objFSO, objHtmlFile
'set objFSO = CreateObject("Scripting.FileSystemObject")
'Set objHtmlFile = objFSO.CreateTextFile(strPathHTML, True, False)
'objHtmlFile.Write(strHTML)
%>
  <script>document.all('InProgress').style.display = 'none';</script>
<%
response.write(strHTML)

response.end
%>


</body>
</html>
