' //==========================================================================
' // @doc $Workfile$
' //
' // Copyright 2000 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //
' // Created by: Kevin A. Boucher
' // ----------------------------------------------------------------------------
' // ValidateXML: Takes in a base directory, and validates all XML files under
' //              it, and sub directories
' //
' // $Date$
' // $Author$
' // $Revision$
' //==========================================================================
On Error Resume Next

Dim objXMLDoc   ' as object
Dim strDir      ' as string
Dim strFileList ' as string
Dim arrFileList ' as array
Dim i           ' as integer
Dim bResult     ' as boolean

Set objXMLDoc= CreateObject("Microsoft.XMLDOM")

' Get Arguments
strDir = wscript.arguments(0)

if strDir = "" then
   wscript.echo "************************************************" & vbNewline
   wscript.echo "USAGE:  validateXML [root directory]"             & vbNewline
   wscript.echo "************************************************" & vbNewline & vbNewline
else
  wscript.echo "Validating all XML files under:  " & strDir & " Please wait..."

  ' setup XMLDoc object
  objXMLDoc.validateOnParse = true
  objXMLDoc.async = false
       
  ' Get a list of XML files to validate
  strFileList = GetXMLFiles(strDir)
  arrFileList = Split(strFileList, ",")
  
  for i=0 to UBound(arrFileList) - 1
    
  '  wscript.echo arrFileList(i) & ":  "
    bResult = objXMLDoc.Load(arrFileList(i))
    if InStr(arrFileList(i), "\_config.xml") = 0 then  ' skip _config.xml files
      if bResult = False then
      	wscript.echo "ERROR:  " & arrFileList(i) & vbNewline & "Reason: " & objXMLDoc.parseError.reason & "Line:  " & objXMLDoc.parseError.line
      else
      	wscript.echo "VALID:  " & arrFileList(i) 
      end if
    end if
  next

end if

'----------------------------------------------------------------------------
' Description: GetXMLFiles - returns a string containg all xml files under
'              a directory and sub directories
' Parameters:  base directory name
' returns:  comma separated string holding xml file names
'----------------------------------------------------------------------------
Function GetXMLFiles(FolderName)
  Dim fso  'As New FileSystemObject
  Dim fold 'As Folder
  
  Dim subfolds 'As Folders
  Dim subfold  'As Folder
  
  Dim flist  'As Files
  Dim f      'As File
  Dim strReturn, strTemp
  Dim val
   
  set fso = createobject("Scripting.FileSystemObject")
   
  'Get a list of folders
  Set fold = fso.GetFolder(FolderName)
  Set subfolds = fold.SubFolders
  
  For Each subfold In subfolds
    strReturn = strReturn & GetXMLFiles(subfold)
    Set flist = subfold.Files
    For Each f In flist
      strTemp = f.Path
      val = InStrRev(strTemp, ".xml")
      If val <> 0 Then
        strReturn = strReturn & strTemp & ","
      End If 
    Next
  Next
  
  GetXMLFiles = strReturn
End Function
