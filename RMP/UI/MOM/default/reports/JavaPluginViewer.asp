<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<%
'SECENG: Prevent application users from making direct requests to this ASP file
SafeForIncludesOnly("JavaPluginViewer.asp")
%>
<html>
<head>
<title>Seagate Java Viewer using Java Plug-in</title>
</head>
<body bgcolor=C6C6C6>

<P align="center">
<object
	classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93"
	width=100%
	height=100%
	codebase="/mci/viewer/JavaPlugin/Win32/jre1_2_2-win.exe#Version=1,2,2,0">
<param name=type value="application/x-java-applet;version=1.2.2">
<param name=code value="com.seagatesoftware.img.ReportViewer.ReportViewer">
<param name=codebase value="/mci/viewer/javaviewer/">
<param name=archive value="ReportViewer.jar">
<param name=Language value="en">
<param name=ReportName value="/mci/mtreports/rptserver.asp">
<param name=ReportParameter value="">
<param name=HasGroupTree value="false">
<param name=ShowGroupTree value="false">
<param name=HasRefreshButton value="false">
<param name=HasPrintButton value="false">
<param name=HasExportButton value="true">
<param name=HasTextSearchControls value="true">
<param name=CanDrillDown value="false">
<param name=HasZoomControl value="true">
<param name=PromptOnRefresh value="false">
<comment>
<embed
	width=100%
	height=90%
	type="application/x-java-applet;version=1.2.2"
	pluginspage="/mci/viewer/JavaPlugin/Win32/jre1_2_2-win.exe"
	java_code="com.seagatesoftware.img.ReportViewer.ReportViewer"
	java_codebase="/mci/viewer/javaviewer/"
	java_archive="ReportViewer.jar"
Language="en"
ReportName="/mci/mtreports/rptserver.asp"
ReportParameter=""
HasGroupTree="true"
ShowGroupTree="true"
HasRefreshButton="true"
HasPrintButton="true"
HasExportButton="true"
HasTextSearchControls="true"
CanDrillDown="true"
HasZoomControl="true"
PromptOnRefresh="true"
></embed>
</comment>
</object>
</p>
</body>
</html>
