Attribute VB_Name = "MTGreatPlainsUtil"
Option Explicit

Public Function GetConnectionStringFromDocument(ByRef oInputXML As MSXML2.DOMDocument40, ByVal configState As Variant) As String

    Dim sExternalNamespace As String
    Dim sTemp As String
    
    sExternalNamespace = GetExternalNamespaceFromDocument(oInputXML)
    sTemp = configState.GetConnectionString(sExternalNamespace)

   If Len(sTemp) = 0 Then
      Err.Raise 8, "GetConnectionStringFromDocument", "Unable to retrieve an eConnect connection string for the AR namespace [" & sExternalNamespace & "]. Please check the gpconfig.xml, servers.xml and the ExtNamespace attribute on the document being processed."
   End If
   GetConnectionStringFromDocument = sTemp
End Function

'Added this function for GreatPlains 10. Specifying the 'Provider' is no longer allowed in the connection string (eConnect rejects it) although it is
'still needed for when we connect using directly to execute a stored procedure
Public Function GetStoredProcedureConnectionStringFromDocument(ByRef oInputXML As MSXML2.DOMDocument40, ByVal configState As Variant) As String
  GetStoredProcedureConnectionStringFromDocument = GetStoredProcedureConnectionString(GetConnectionStringFromDocument(oInputXML, configState))
End Function

Public Function GetStoredProcedureConnectionString(ByRef ConnectionString As String) As String
  GetStoredProcedureConnectionString = "Provider=SQLOLEDB.1;" & ConnectionString
End Function

Public Function GetExternalNamespaceFromDocument(ByRef oInputXML As MSXML2.DOMDocument40) As String
    Dim strExtNamespace As String
    If oInputXML.selectSingleNode("//ARDocuments").Attributes.getNamedItem("ExtNamespace") Is Nothing Then
      TRACE "The <ARDocuments> tag does not contain a ExtNamespace attribute for the AR Operating Company", "MTGreatPlainsUtil", "GetConnectionStringFromDocument"
      strExtNamespace = "mt"
    Else
      strExtNamespace = oInputXML.selectSingleNode("//ARDocuments").Attributes.getNamedItem("ExtNamespace").Text
    End If
    
    GetExternalNamespaceFromDocument = strExtNamespace
    
End Function

Function SandR(ByVal SearchString As String, ByVal LookFor As String, ByVal ReplaceWith As String) As String
    Rem +-----------------------------------------------------------------------+
    Rem |    SearchString    =   String to search.                              |
    Rem |    LookFor         =   String to look for within SearchString         |
    Rem |    ReplaceWith     =   What to replace SearchString                   |
    Rem |                                                                       |
    Rem |    Test=SandR("Mary Had a little lamb","a","aa")                      |
    Rem |                would return:                                          |
    Rem |            Maary Haad aa little laamb                                 |
    Rem |                                                                       |
    Rem |   Compatibility: Visual Basic 2.0                                     |
    Rem |                                                                       |
    Rem |       Programmed by: JamesTracy95820@hotmail.com                      |
    Rem |                                                                       |
    Rem +-----------------------------------------------------------------------+
    Rem +-----------------------------------+
    Rem |       Declair variables           |
    Rem +-----------------------------------+
    Dim LeftPart As String
    Dim RightPart As String
    Dim Location As Integer
    Dim LeftLocation As Integer
    Dim RightLocation As Integer
    Rem +-------------------------------+
    Rem |       Initilize variables     |
    Rem +-------------------------------+
    LeftPart = ""
    RightPart = ""
    Location = 0
    Rem ==========================================================
    If Len(LookFor) = 0 Then
        LeftPart = SearchString
    Else
        If LookFor = ReplaceWith Then
            LeftPart = SearchString
        Else
            If Len(SearchString) = 0 Then
                LeftPart = SearchString
            Else
                LeftPart = ""
                RightPart = SearchString
                Rem ============================================
                Do
                    Location = InStr(1, RightPart, LookFor, 0)  '   Case INsensitive
                    If Location = 0 Then
                        LeftPart = LeftPart + RightPart
                    Else
                        If Location = 1 Then
                            LeftPart = LeftPart + ReplaceWith
                            RightLocation = Location + Len(LookFor)
                            If RightLocation > Len(RightPart) Then
                                RightPart = ""
                            Else
                                RightPart = Mid(RightPart, RightLocation)
                            End If
                        Else
                            If Location >= 2 Then
                                LeftLocation = Location - 1
                                RightLocation = Location + Len(LookFor)
                                LeftPart = LeftPart + Left(RightPart, LeftLocation) + ReplaceWith
                                If RightLocation > Len(RightPart) Then
                                    RightPart = ""
                                Else
                                    RightPart = Mid(RightPart, RightLocation)
                                End If
                            End If
                        End If
                    End If
                Loop Until Location = 0
            End If
        End If
    End If
    SandR = LeftPart   '   Return string
End Function


