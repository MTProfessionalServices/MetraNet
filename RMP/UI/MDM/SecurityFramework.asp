<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' NAME                  : ASP interface to the Security Framework
' AUTHOR                : Kyle C. Quest
' DESCRIPTION           : Connects the classic ASP code with the Security Framework.
' ----------------------------------------------------------------------------------------------------------------------------------------

'We can't store objects in the ASP Application object :-(
'The reason is decribed here: http://support.microsoft.com/kb/194397
'The next best thing is to use the ASP Session object

On Error resume Next

SafeForIncludesOnly("SecurityFramework.asp")

PUBLIC Function SafeAuthenticatedOnly(redirectTo)
  If(session("isAuthenticated")<>TRUE) Then
	If Len(redirectTo&"") <> 0 Then
		response.redirect(redirectTo)
		SafeAuthenticatedOnly = FALSE
		Exit Function		
	End If	
	Response.Status = "404 Not Found" 
	Response.end  
	SafeAuthenticatedOnly = FALSE
	Exit Function
  end if
  SafeAuthenticatedOnly = TRUE
End Function

PUBLIC Function SafeForIncludesOnly(fileName)
  Dim reqPath
  'Dim pathParts
  Dim reqPathFileName
  Dim startLoc
  reqPath = Request.ServerVariables("URL")
  'pathParts = split(reqPath,"/")
  'reqPathFileName = pathParts(ubound(pathParts))
  startLoc = instrRev(reqPath,"/")
  reqPathFileName = mid(reqPath, startLoc+1, len(reqPath) - startLoc) 
  If LCase(reqPathFileName&"") = LCase(fileName&"") Then
	'Response.Write "Direct access to include files is not allowed<br/>" & vbNewLine
	Response.Status = "404 Not Found"
	Response.end  
  End If
  SafeForIncludesOnly = TRUE
End Function

PUBLIC Function SafeForLocation(location,errorMessage)
'1. ensure it's not an absolute location (very primitive check for now; encoding tricks might be a problem
'2. ensure that the path has no directory traversals (very primitive check for now)
    location = LTrim(location)
	location = LCase(location)
	If Left(location,2) = "//" Or InStr(location, "http://") <> 0 Or InStr(location, "https://") <> 0 Or InStr(location, "..") <> 0 Then
		If Len(errorMessage&"") <> 0 Then
			Response.Write errorMessage
			Response.end
		End If
		SafeForLocation = FALSE
		Exit Function
    End If
	SafeForLocation = TRUE
End Function

PRIVATE FUNCTION EnsureSecurityFramework() 
	Dim sfo, rcd, fso
	If IsEmpty(Session("SF.Runtime")) Then 
		set sfo = CreateObject("MetraTech.SecurityFramework.SFCOM")	
		set rcd = CreateObject("MetraTech.Rcd.1")
		set fso = server.createobject("Scripting.FilesystemObject")
		If IsEmpty(sfo) or IsEmpty(rcd) or IsEMpty(fso) Then
			EnsureSecurityFramework = FALSE
		Else
			Dim winPath
			Dim sfPath
			'SECENG: ESR-4767
			'We don't have to rely on environment variables and we have to get path to config files using RCD object
			sfPath = fso.BuildPath(rcd.ConfigDir, "Security/Validation/MtSfConfigurationLoader.xml")
			sfo.Initialize(sfPath)
			set Session("SF.Runtime") = sfo
			EnsureSecurityFramework = TRUE
		End If	
	Else
		EnsureSecurityFramework = TRUE
	End If
END FUNCTION


PRIVATE FUNCTION ExcludeBinaryReads() 
	Dim url
	Dim loadPageValue
	Dim brPages(2) 
	Dim brIndPages(1)
  Dim urlPath
	
	brPages(0) = LCase("/MOM/default/dialog/BillingGroupPullListFromFileUpload.asp")
	brPages(1) = LCase("/MPTE/us/GenericTabRulesetExport.asp")
	brPages(2) = LCase("/MPTE/us/GenericTabRulesetExportImportExcelUpload.asp")
	
	brIndPages(0) = LCase("/MAM/default/dialog/gotoPopup.asp")
	brIndPages(1) = LCase("/MCM/default/dialog/gotoPopup.asp")
		
	urlPath = LCase(Request.ServerVariables("URL"))
	
	Dim i
	for i = 0 to 2
		If brPages(i) = urlPath Then
			ExcludeBinaryReads = TRUE
			Exit Function
		End If
	Next
	
	for i = 0 to 1
		If brIndPages(i) = urlPath Then
			loadPageValue = Request.QueryString("loadpage")
			If Len(loadPageValue&"") <> 0 Then
				If (UCase(loadPageValue) = "GENERICTABRULESETEXPORTIMPORTEXCELUPLOAD.ASP" Or UCase(loadPageValue) = "GENERICTABRULESETEXPORT.ASP") Then
					ExcludeBinaryReads = TRUE
					Exit Function				
				End If
			End If
		End If
	Next	

	ExcludeBinaryReads = FALSE	
END FUNCTION

'Request processing functions:
'Returns an empty string if the request is safe
'To delegate error response generation provide a non-empty 'errorMessage'
'Otherwise the caller is responsible for generating a response

PUBLIC FUNCTION RunSafeInputFilter(errorMessage) 
	Dim sfo
	Dim result
	Dim mode
	Dim paramName
	Dim paramValue
	
	If ExcludeBinaryReads() Then	
		RunSafeInputFilter = "SF_EXCLUDE"
		Exit Function	
	End If
	
	If Not EnsureSecurityFramework() Then
		RunSafeInputFilter = "SF_LOAD_FAILURE"
		Exit Function
	Else
		set sfo = Session("SF.Runtime")	
		mode = sfo.InspectMode()		
		If mode&"" = "full" Then
			result = sfo.ProcessWebRequest( _
				Request.ServerVariables("REQUEST_METHOD"), _
				Request.ServerVariables("HTTPS"), _
				Request.ServerVariables("SERVER_NAME"), _
				Request.ServerVariables("URL"), _
				Request.QueryString, _
				Request.Form, _
				Request.Cookies, _
				Request.ServerVariables("REMOTE_ADDR"), _
				Request.ServerVariables("HTTP_USER_AGENT"), _
				Request.TotalBytes)
			If Len(result&"") <> 0 Then
				If Len(errorMessage&"") <> 0 Then
					Response.Write errorMessage
					Response.end
				End If
				RunSafeInputFilter = result
				Exit Function
			End If
		Else
			Dim appPath
			Dim resourceName
			Dim resourceExt
			Dim rawUrl
			Dim remoteAddr
			Dim userAgent
			Dim referer
			Dim pid
			appPath = "/"
			resourceName = lcase(Request.ServerVariables("URL"))
			rawUrl = lcase(Request.ServerVariables("UNENCODED_URL"))
			remoteAddr = lcase(Request.ServerVariables("REMOTE_ADDR"))
			userAgent = lcase(Request.ServerVariables("HTTP_USER_AGENT"))
			referer = lcase(Request.ServerVariables("HTTP_REFERER"))
			resourceExt = ".asp"
			pid = sfo.LookupWebProcessorId(appPath,resourceName,resourceExt)
			If Len(pid&"") <> 0 Then
				For Each paramName in Request.QueryString
					paramValue = Request.QueryString(paramName)
					If Len(paramValue&"") <> 0 Then
						result = sfo.ProcessWebRequestParam(pid,"qs",paramName, paramValue,resourceName,rawUrl,remoteAddr,userAgent,referer)
					Else
					    result = sfo.ProcessWebRequestParam(pid,"qs",paramName, paramName,resourceName,rawUrl,remoteAddr,userAgent,referer)	
					End If
					
					If Len(result&"") <> 0 Then
							If Len(errorMessage&"") <> 0 Then
								Response.Write errorMessage
								Response.end
							End If
							RunSafeInputFilter = result
							Exit Function
						End If
				Next
				For Each paramName in Request.Form
					paramValue = Request.Form(paramName)
					If Len(paramValue&"") <> 0 Then
						result = sfo.ProcessWebRequestParam(pid,"form",paramName, paramValue,resourceName,rawUrl,remoteAddr,userAgent,referer)
						If Len(result&"") <> 0 Then
							If Len(errorMessage&"") <> 0 Then
								Response.Write errorMessage
								Response.end
							End If					
							RunSafeInputFilter = result
							Exit Function
						End If
					End If				
				Next
			End If
		End If
	End If 
	RunSafeInputFilter = ""
END FUNCTION

'Input data processing functions:

PUBLIC Function SafeInReqParam(name)
  Dim param
  param = Request(name)
  SafeInReqParam = param
End Function

PUBLIC Function SafeInQueryStringParam(name)
  Dim param
  param = Request.QueryString(name)
  SafeInQueryStringParam = param
End Function

PUBLIC Function SafeInFormParam(name)
  Dim param
  param = Request.Form(name)
  SafeInFormParam = param
End Function

PUBLIC Function SafeInServerParam(name)
  Dim param
  param = request.ServerVariables(name)
  SafeInServerParam = param
End Function

'Output data processing functions:

PUBLIC Function SafeForUrl(param)
  Dim sfo
  Dim val
  
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForUrl = Server.URLEncode(param)
		Exit Function
	Else
		Err.Clear
		set sfo = Session("SF.Runtime")
		val = sfo.ForUrl(param)
		If Err.Number <> 0 Then
			SafeForUrl = Server.URLEncode(param)
		Else
			If Len(val&"") <> 0 Then
				SafeForUrl = val
			Else
				SafeForUrl = Server.URLEncode(param)
			End If
		End If
		On Error GoTo 0			
	End If
  Else
	SafeForUrl = param
  End If   
End Function

PUBLIC Function SafeForHtml(param)
  Dim sfo
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForHtml = Server.HTMLEncode(param)
		Exit Function
	Else
		Err.Clear
		set sfo = Session("SF.Runtime")
		val = sfo.ForHtml(param)
		If Err.Number <> 0 Then
			SafeForHtml = Server.HTMLEncode(param)
		Else
			If Len(val&"") <> 0 Then
				SafeForHtml = val
			Else
				SafeForHtml = Server.HTMLEncode(param)
			End If			
		End If
		On Error GoTo 0		
	End If
  Else
	SafeForHtml = param
  End If     
End Function

PUBLIC Function SafeForHtmlAttr(param)
  Dim sfo
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForHtmlAttr = Server.HTMLEncode(param)
		Exit Function
	Else
		Err.Clear
		set sfo = Session("SF.Runtime")
		val = sfo.ForHtmlAttr(param)
		If Err.Number <> 0 Then
			SafeForHtmlAttr = Server.HTMLEncode(param)
		Else
			If Len(val&"") <> 0 Then
				SafeForHtmlAttr = val
			Else
				SafeForHtmlAttr = Server.HTMLEncode(param)
			End If	
		End If
		On Error GoTo 0
	End If
  Else
	SafeForHtmlAttr = param
  End If   
End Function

PUBLIC Function SafeForJs(param)
  Dim sfo
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForJs = Server.HTMLEncode(param)
		Exit Function
	Else
		Err.Clear
		set sfo = Session("SF.Runtime")
		val = sfo.ForJs(param)
		If Err.Number <> 0 Then
			SafeForJs = Server.HTMLEncode(param)
		Else
			If Len(val&"") <> 0 Then
				SafeForJs = val
			Else
				SafeForJs = Server.HTMLEncode(param)
			End If	
		End If
		On Error GoTo 0			
	End If
  Else
	SafeForJs = param
  End If   
End Function

PUBLIC Function SafeForVbs(param)
  Dim sfo
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForVbs = Server.HTMLEncode(param)
		Exit Function
	Else
		Err.Clear
		set sfo = Session("SF.Runtime")
		val = sfo.ForVbs(param)
		If Err.Number <> 0 Then
			SafeForVbs = Server.HTMLEncode(param)
		Else
			If Len(val&"") <> 0 Then
				SafeForVbs = val
			Else
				SafeForVbs = Server.HTMLEncode(param)
			End If
		End If
		On Error GoTo 0			
	End If
  Else
	SafeForVbs = param
  End If   
End Function

PUBLIC Function SafeForCss(param)
  Dim sfo
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForCss = Server.HTMLEncode(param)
		Exit Function
	Else
		Err.Clear
		set sfo = Session("SF.Runtime")
		val = sfo.ForCss(param)
		If Err.Number <> 0 Then
			SafeForCss = Server.HTMLEncode(param)
		Else
			If Len(val&"") <> 0 Then
				SafeForCss = val
			Else
				SafeForCss = Server.HTMLEncode(param)
			End If
		End If
		On Error GoTo 0			
	End If
  Else
	SafeForCss = param
  End If   
End Function

PUBLIC Function SafeForXml(param)
  Dim sfo
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForXml = Server.HTMLEncode(param)
		Exit Function
	Else
		Err.Clear
		set sfo = Session("SF.Runtime")
		val = sfo.ForXml(param)
		If Err.Number <> 0 Then
			SafeForXml = Server.HTMLEncode(param)
		Else
			If Len(val&"") <> 0 Then
				SafeForXml = val
			Else
				SafeForXml = Server.HTMLEncode(param)
			End If			
		End If
		On Error GoTo 0		
	End If
  Else
	SafeForXml = param
  End If     
End Function

PUBLIC Function SafeForXmlAttr(param)
  Dim sfo
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForXmlAttr = Server.HTMLEncode(param)
		Exit Function
	Else
		Err.Clear
		set sfo = Session("SF.Runtime")
		val = sfo.ForXmlAttr(param)
		If Err.Number <> 0 Then
			SafeForXmlAttr = Server.HTMLEncode(param)
		Else
			If Len(val&"") <> 0 Then
				SafeForXmlAttr = val
			Else
				SafeForXmlAttr = Server.HTMLEncode(param)
			End If	
		End If
		On Error GoTo 0
	End If
  Else
	SafeForXmlAttr = param
  End If   
End Function

'Get ORM value on key
PUBLIC Function SafeForORM(param)
  Dim SFCOM
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForORM = ""
		Exit Function
	Else
		Err.Clear
		set SFCOM = Session("SF.Runtime")
		val = SFCOM.FromToken(param)
		If Err.Number <> 0 Then
			SafeForORM = ""
		Else
			If Len(val&"") <> 0 Then
				SafeForORM = val
			Else
				SafeForORM = ""
			End If	
		End If
		On Error GoTo 0
	End If
  Else
	SafeForORM = ""
  End If   
End Function

PUBLIC Function SafeForUrlAC(param)
  Dim SFCOM
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForUrlAC = false
		Exit Function
	Else
        Err.Clear
		set SFCOM = Session("SF.Runtime")
		val = SFCOM.ForUrlAccessController(param)
		If Err.Number <> 0 Then
			SafeForUrlAC = false
		Else
			SafeForUrlAC = val
		End If
		On Error GoTo 0
	End If
  Else
	SafeForUrlAC = true
  End If
End Function

PUBLIC Function Validate(param, id)
  Dim SFCOM
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		Validate = false
		Exit Function
	Else
		Err.Clear
		set SFCOM = Session("SF.Runtime")
		val = SFCOM.ForValidator(param, id)
		If Err.Number <> 0 Then
			Validate = false
		Else
			Validate = true
		End If
		On Error GoTo 0
	End If
  Else
	Validate = false
  End If
End Function

PUBLIC Function ValidateXML(param)
  Dim engineId
  engineId = "XMLString.Default"
  ValidateXML = Validate(param, engineId) 
End Function

PUBLIC Function Detect(param, id)
  Dim SFCOM
  Dim val
  If Len(param&"") <> 0 Then
	If Not EnsureSecurityFramework() Then
		SafeForDetector = false
		Exit Function
	Else
		Err.Clear
		set SFCOM = Session("SF.Runtime")
		val = SFCOM.ForDetector(param, id)
		If Err.Number <> 0 Then
			SafeForDetector = false
		Else
			SafeForDetector = val
		End If
		On Error GoTo 0
	End If
  Else
	SafeForDetector = false
  End If
End Function

PUBLIC Function SafeOutQueryStringForUrl()  
  SafeOutQueryStringForUrl = SafeForUrl(Request.QueryString)
End Function

PUBLIC Function SafeOutQueryStringForHtml()  
  SafeOutQueryStringForUrl = SafeForHtml(Request.QueryString)
End Function

PUBLIC Function SafeOutReqParamForUrl(name)
  SafeOutReqParamForUrl = SafeForUrl(Request(name))  
End Function

PUBLIC Function SafeOutReqParamForHtml(name)
  SafeOutReqParamForHtml = SafeForHtml(Request(name))    
End Function

PUBLIC Function SafeOutReqParamForHtmlAttr(name)
  SafeOutReqParamForHtmlAttr = SafeForHtmlAttr(Request(name))  
End Function

PUBLIC Function SafeOutReqParamForJs(name)
  SafeOutReqParamForJs = SafeForJs(Request(name))  
End Function

PUBLIC Function SafeOutQueryStringParamForUrl(name)  
  SafeOutQueryStringParamForUrl = SafeForUrl(Request.QueryString(name))
End Function

PUBLIC Function SafeOutQueryStringParamForHtml(name)
  SafeOutQueryStringParamForHtml = SafeForHtml(Request.QueryString(name))
End Function

PUBLIC Function SafeOutQueryStringParamForHtmlAttr(name)
  SafeOutQueryStringParamForHtmlAttr = SafeForHtmlAttr(Request.QueryString(name))
End Function

PUBLIC Function SafeOutQueryStringParamForJs(name)
  SafeOutQueryStringParamForJs = SafeForJs(Request.QueryString(name))
End Function

PUBLIC Function SafeOutFormParamForUrl(name)
  SafeOutFormParamForUrl = SafeForUrl(Request.Form(name))
End Function

PUBLIC Function SafeOutFormParamForHtml(name)
  SafeOutFormParamForHtml = SafeForHtml(Request.Form(name))
End Function

PUBLIC Function SafeOutFormParamForHtmlAttr(name)
  SafeOutFormParamForHtmlAttr = SafeForHtmlAttr(Request.Form(name))
End Function

PUBLIC Function SafeOutFormParamForJs(name)
  SafeOutFormParamForJs = SafeForJs(Request.Form(name))
End Function

PUBLIC Function SafeOutServerParamForUrl(name)
  SafeOutServerParamForUrl = SafeForUrl(request.ServerVariables(name))
End Function

PUBLIC Function SafeOutServerParamForHtml(name)
  SafeOutServerParamForHtml = SafeForHtml(request.ServerVariables(name))
End Function

PUBLIC Function SafeOutServerParamForHtmlAttr(name)
  SafeOutServerParamForHtmlAttr = SafeForHtmlAttr(request.ServerVariables(name))
End Function

PUBLIC Function SafeOutServerParamForJs(name)
  SafeOutServerParamForJs = SafeForJs(request.ServerVariables(name))
End Function

'Function is used to detect is the input value looks like a file name allowed to dislay in help window.
PUBLIC Function SafeForHelp(fileName)
	if InStr(1, UCase(fileName), "RMP\UI") > 1 then
		SafeForHelp = fileName
	else
		SafeForHelp = ""
		Response.Clear
		Response.Status = 403
		Response.End
	end if
End Function

' SECENG: Fix CORE-4827 CLONE - MSOL BSS 18388 Metracare: No clickjacking protection (SecEx, Public-beta, 3)
PUBLIC Function CjProtectionCode()
  CjProtectionCode = "<style type='text/css'>html{display:none;}</style><script type='text/javascript'>var A;try {A = top.location.href;} catch (ex) {}if (!A) {window.location='/MetraNet/noframes.html';}else {document.documentElement.style.display = 'block';}</script>"
End Function

%>
