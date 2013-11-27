'*******************************************************************************
'*
'* Copyright 2004 by MetraTech Corporation
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corporation MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corporation,
'* and USER agrees to preserve the same.
'*
'* Created By: Marc Guyott
'*
'*******************************************************************************

'*******************************************************************************
'* This script is used to encrypt and insert a new password into a servers.xml
'* file for a single server.
'*
'* Usage: encrypt <serverType> <newPassword> [<serverXMLFileName>]
'*
'*  <serverType>        - The type of the server that this new password is to be
'*                        assigned too.  The server type is specified in the config
'*                        file using the <servertype> tag in each <server> section
'*                        of each servers.xml (<xmlconfig>) config file.
'*
'*                        <serverType> is case sensitive.
'*
'*  <newPassword>       - The unencrypted password to be encrypted and inserted into
'*                        the specified servers.xml file under the specified server.
'*
'*  <serverXMLFileName> - The name of the xml config file that contains the server
'*                        type definition that is to be updated.  This is almost
'*                        always "servers.xml".  If you are in the directory
'*                        containing the file you wish to update then you can
'*                        simply specify the file name.  In any other circumstance
'*                        it is best to specify the fully qualified path and file
'*                        name.  If this is not specified the config file is
'*                        assumed to be named "servers.xml" and reside in the
'*                        current directory.
'*
'* "encrypt" will fail in COMSecureStore.EncryptString() with error -2147352567
'* (0x80020009) if the file sessionkeyblob_dbaccess does not exist in your
'* RMP\config\ServerAccess directory.
'*******************************************************************************

Option Explicit

Const kRetVal_SUCCESS = 0
Const kRetVal_ERROR   = (-1)

Const XMLFILE_SERVERS   = "servers.xml"

'* File System Object (fso) Open Arguments.
Const ForReading        = 1
Const ForWriting        = 2
Const ForAppending      = 8  

Dim FileSysObject
Dim COMSecureStore

'*******************************************************************************
Function Main()

  wscript.Interactive = True

  Dim serverType
  Dim newPassword
  Dim fileName

  On Error Resume Next
  
  Main = kRetVal_ERROR

  Set FileSysObject = CreateObject("Scripting.FileSystemObject")

  If CheckErrors("CreateObject(Scripting.FileSystemObject) failed") Then
    Exit Function 
  End If

  If FileSysObject is Nothing Then
    wscript.echo "*** CreateObject(Scripting.FileSystemObject) failed."
    wscript.echo "*** A null pointer was returned."
    Exit Function
  End If

  Set COMSecureStore = CreateObject("COMSecureStore.GetProtectedProperty")

  If CheckErrors("CreateObject(COMSecureStore.GetProtectedProperty) failed") Then
    Exit Function 
  End If

  If COMSecureStore is Nothing Then
    wscript.echo "*** CreateObject(COMSecureStore.GetProtectedProperty) failed."
    wscript.echo "*** A null pointer was returned."
    Exit Function
  End If

  If ((wscript.arguments.length < 2) Or (wscript.arguments.length > 3)) Then
    wscript.echo "Usage: encrypt <serverType> <newPassword> [<serverXMLFileName>]"
    wscript.echo ""
    wscript.echo "       <serverType> is case sensitive."
    wscript.echo ""
    wscript.echo "       [<serverXMLFileName>] is optional.  If not specified"
    wscript.echo "           'servers.xml' from the current working directory is used."
    wscript.echo ""
    wscript.echo "       encrypt will fail in COMSecureStore.EncryptString() with"
    wscript.echo "       error -2147352567 (0x80020009) if the file sessionkeyblob_dbaccess"
    wscript.echo "       does not exist in your RMP\config\ServerAccess directory."
    Main = kRetVal_SUCCESS
    Exit Function
  End If

  serverType  = wscript.arguments(0)
  newPassword = wscript.arguments(1)

  If (wscript.arguments.length < 3) Then
    fileName = XMLFILE_SERVERS
  Else
    fileName = wscript.arguments(2)
  End If

  If (Not DoesFileExist(fileName)) Then
    wscript.echo "*** The specified server configuration file"
    wscript.echo "*** (" & fileName & ") could not be found."
    Exit Function
  End If

  If (Not Encrypt(serverType, newPassword, fileName)) Then
    Exit Function
  End If

  wscript.echo "Success: The new password for " & serverType & " has been set."

  Main = kRetVal_SUCCESS

End Function
'*******************************************************************************


'*******************************************************************************
Function CheckErrors(errText)

  If (Err.Number <> 0) Then

     '*** Log the error only if caller supplies text, otherwise
     '*** caller was just using this to test the results of an operation.
    If (errText <> "") Then  
      wscript.echo "*** " & errText & "."
      wscript.echo "*** Err.Number = " & Err.Number & " : Err.Desc = " & Err.Description
    End If

    Err.Clear
    CheckErrors = True
  Else
    CheckErrors = False
  End If

End Function
'*******************************************************************************


'*******************************************************************************
Function DoesFileExist(fileName)

  If (FileSysObject.FileExists(fileName)) Then
    DoesFileExist = True
  Else
    DoesFileExist = False
  End If
     
End Function
'*******************************************************************************


'*******************************************************************************
Function Encrypt(serverType, newPassword, fileName)

  Dim xmldomConfigFile

  On Error Resume Next

  Encrypt = False

  '* xmldomConfigFile is a DOMDocument.
  Set xmldomConfigFile = CreateObject("Microsoft.XMLDOM")
  If (CheckErrors("CreateObject(Microsoft.XMLDOM) failed")) Then
    Exit Function 
  End If

  xmldomConfigFile.async = False
  xmldomConfigFile.validateOnParse = False
  xmldomConfigFile.preserveWhiteSpace = False
  xmldomConfigFile.resolveExternals = False

  xmldomConfigFile.Load(fileName)

  If (xmldomConfigFile.parseError.errorCode <> 0) Then
    wscript.echo "*** XML Parsing Error in file"
    wscript.echo "***     " & fileName
    wscript.echo "*** Line " & xmldomConfigFile.parseError.line & ": " & xmldomConfigFile.parseError.reason
    Exit Function
  End If

  If (CheckErrors("xmldomConfigFile.Load(fileName) failed")) Then
    Exit Function 
  End If

  If (Not EncryptDbAccess(xmldomConfigFile, serverType, newPassword)) Then
    Exit Function
  End If

  '* Save the file.
  xmldomConfigFile.save(fileName)

  Encrypt = True

End Function
'*******************************************************************************


'*******************************************************************************
Function EncryptDbAccess(xmldomConfigFile, serverType, newPassword)

  Dim serverList
  Dim server

  On Error Resume Next

  EncryptDbAccess = False

  Set serverList = xmldomConfigFile.documentElement.selectNodes("/xmlconfig/server")

  For Each server in serverList

    Dim curServerType

    Set curServerType = server.selectSingleNode("servertype")

    If (curServerType is Nothing) Then
      wscript.echo "*** Invalid configuration file."
      wscript.echo "*** At least one entry is missing a servertype."
      Exit Function
    End If

    If (curServerType.text = serverType) Then

      If (Not encryptNode(xmldomConfigFile, server, newPassword)) then
        Exit Function
      End if

      '* If we allowed multiple instances of a server type then we could
      '* remove the following line and all instances of this server type
      '* would have thier password updated.  But since we only allow one
      '* instance of any server type we can save some time and exit now.

      EncryptDbAccess = True
      Exit Function

    End If

Next

'* If we changed the code above to allow for multiple entries for each
'* server type then getting here would no longer be an error.

wscript.echo "*** Specified servertype (" & serverType & ") not found."
wscript.echo "*** The servertype specified was not found in the config file specified."

End function
'*******************************************************************************


'*******************************************************************************
Function encryptNode(xmldomConfigFile, server, newPassword)

  Dim password
  Dim encrypted

  On Error Resume Next

  encryptNode = False

  Set password = server.selectSingleNode("password")

  If (password is Nothing) Then

    Err.Clear

    Dim serverType
    Set serverType = server.selectSingleNode("servertype")

    wscript.echo "*** The servertype specified (" & serverType.text & ")"
    wscript.echo "*** did not have a password property associated with it."

    Exit Function

  End If

  Set encrypted = password.selectSingleNode("@encrypted")

  If encrypted is Nothing then
    Set encrypted = xmldomConfigFile.createAttribute("encrypted")
  Else
    Set encrypted = password.attributes.removeNamedItem("encrypted")
  End if

  encrypted.text = "true"

  password.attributes.setNamedItem(encrypted)

  password.text = COMSecureStore.EncryptString(newPassword)

  If (CheckErrors("COMSecureStore.EncryptString() failed")) Then
    Exit Function 
  End If

  encryptNode = True

End Function
'*******************************************************************************

Main() '* Invoke this whole mess.
