<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>

<%
Select Case UCase(Request.QueryString("loadpage"))

	Case "GENERICEDITRULESET.ASP"
  		Server.Execute "GenericEditRulesetInclude.asp"
      
	Case "GENERICTABRULESETFILTER.ASP"
  		Server.Execute "GenericTabRulesetFilterInclude.asp" 

	Case "GENERICTABRULESETEXPORT.ASP"
  		Server.Execute "GenericTabRulesetExportInclude.asp" 		

	Case "GENERICTABRULESETEXPORTIMPORTEXCEL.ASP"
  		Server.Execute "GenericTabRulesetExportImportExcelInclude.asp" 		

	Case "GENERICTABRULESETEXPORTIMPORTEXCELUPLOAD.ASP"
  		Server.Execute "GenericTabRulesetExportImportExcelUploadInclude.asp" 
      
	Case else
		Server.Execute Request.QueryString("loadpage")
			
End Select

%>
