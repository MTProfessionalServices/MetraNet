'**************************************************************************
' * @doc
' *
' * Copyright 2000 by MetraTech Corporation
' * All rights reserved.
' *
' * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' * example, but not limitation, MetraTech Corporation MAKES NO
' * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' *
' * Title to copyright in this software and any associated
' * documentation shall at all times remain with MetraTech Corporation,
' * and USER agrees to preserve the same.
' *
' * Created by: Carl Shimer
' *
' * This module provides a number of exported function for use by 
' * InstallShield
' *
' * $Date: 1/7/2001 11:56:54 AM$
' * $Author: Carl Shimer$
' * $Revision: 1$

option explicit

' global objects
dim aRCD,objComSecureStore,aDOMObject
' global properties
dim bEncrypt,OpType,OpsFolder,UserName,Password

set aRCD = CreateObject("Metratech.RCD.1")
set objComSecureStore = CreateObject("COMSecureStore.GetProtectedProperty.1")
set aDOMObject = CreateObject("Microsoft.XMLDOM")

' main execution
CheckArgs()
PerformAction()

sub printUsage()
  wscript.echo "usage: " & wscript.fullname & " " & wscript.scriptfullname & vbcrlf _
   & "-encrypt" 
  wscript.quit(-1)
end sub


' step : create objects

sub CheckArgs()

  if wscript.arguments.count < 1 then
    wscript.echo "Not enough arguments."
    printUsage()
  else
    
    ' check the first arg

    OpType = wscript.arguments(0)
    if OpType <> "-encrypt" And OpType <> "-decrypt" then
      wscript.echo "argument " & OpType & " not understood."
      printUsage()
    end If
    If OpType = "-encrypt" Then
      bEncrypt = True
    Else
      bEncrypt = False
    End If
  end if
end sub


sub PerformAction()
  
  aDOMObject.async = false
  aDOMObject.validateOnParse = false
  aDOMObject.preserveWhiteSpace = false
  aDOMObject.resolveExternals = false

  ' properties
  dim file

  Dim objTools
  set objTools = CreateObject("MTMSIX.MSIXTOOLS")
  file = objTools.GetMTConfigDir() & "\serveraccess\servers.xml"
  wscript.echo "Loading file: " & file
  aDOMObject.Load(file)

  if aDOMObject.parseError.errorCode <> 0 then
    wscript.echo ("Error: " & aDOMObject.parseError.reason & " on line " & aDOMObject.parseError.line)
    wscript.Quit(aDOMObject.parseError.errorCode)
  end If

  call EncryptServerAccess(aDOMObject, bEncrypt)
  ' step : save the file
  
  aDOMObject.save(file)
end sub


Function EncryptServerAccessNode(objServerNode)
  Dim objPasswordNode, objEncryptionAttribute
  Dim strServerName

  Set objPasswordNode = objServerNode.selectsinglenode("password")
  If objPasswordNode Is Nothing Then
    wscript.echo "skipping server with no password"
    Exit Function
  End If
  
  Set objEncryptionAttribute = objPasswordNode.attributes.getNamedItem("encrypted")
  strServerName = objServerNode.selectsinglenode("servertype").text
  If Not objEncryptionAttribute Is Nothing  Then
    If LCase(objEncryptionAttribute.text) = "true" Then
      wscript.echo "password for server " & strServerName & " already encrypted, skipping..."
      Exit Function
    Else
      objServerNode.attributes.removeNamedItem("encrypted")
    End If
  End If

  wscript.echo "encrypting password for server '" & strServerName & "'"
  
  ' Encrypt the password and set the encryption attribute
  Set objEncryptionAttribute = aDOMObject.createAttribute("encrypted")
  objEncryptionAttribute.value = "true"
  objPasswordNode.attributes.setNamedItem(objEncryptionAttribute)
  objPasswordNode.text = objComSecureStore.EncryptString(objPasswordNode.text)

  EncryptServerAccessNode = true
End Function

Function DecryptServerAccessNode(objServerNode)
  Dim objPasswordNode, objEncryptionAttribute
  Dim strServerName

  Set objPasswordNode = objServerNode.selectsinglenode("password")
  If objPasswordNode Is Nothing Then
    wscript.echo "skipping server with no password"
    Exit Function
  End If
  
  Set objEncryptionAttribute = objPasswordNode.attributes.getNamedItem("encrypted")
  strServerName = objServerNode.selectsinglenode("servertype").text
  If objEncryptionAttribute Is Nothing  Then
      wscript.echo "password for server " & strServerName & " not encrypted, skipping..."
      Exit Function
  End If

  If LCase(objEncryptionAttribute.text) <> "true" Then
      wscript.echo "password for server " & strServerName & " not encrypted, skipping..."
      Exit Function
  End If
  
  wscript.echo "decrypting password for server '" & strServerName & "'"
  
  ' Decrypt the password and set the encryption attribute
  objEncryptionAttribute.value = "false"
  objPasswordNode.text = objComSecureStore.DecryptString(objPasswordNode.text)

  DecryptServerAccessNode = true
End Function

function EncryptServerAccess(aDomXmlFile, bEncrypt)

  'objects
  Dim objServerNodes, objServerNode, objCOMSecureStore
  'props


  set objServerNodes = aDomXmlFile.selectnodes("/xmlconfig/server")
dim servertype
  For Each objServerNode in objServerNodes
    If bEncrypt Then
servertype = objServerNode.selectsinglenode("servertype").text
if servertype = "SuperUser" then
	wscript.echo "Encrypting " &  servertype & " Node"
      EncryptServerAccessNode(objServerNode)
end if
    Else
      DecryptServerAccessNode(objServerNode)
    End If
  Next

  EncryptServerAccess = true

end function


