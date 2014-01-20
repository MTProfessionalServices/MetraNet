'*******************************************************************************
'*
'* Copyright 2000-2009 by MetraTech Corp.
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corp. MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corp. MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corp.,
'* and USER agrees to preserve the same.
'*
'* Name:        cryptoUtils.vbs
'* Created By:  Mike Pento
'* Description: Functions related to MetraTech cryptography
'*
'*******************************************************************************

' require explicit declarations
option explicit

function GenerateSessionKeys()
	dim objCrypto
	dim asMasterArray
	dim asKeyClassNames
	dim asKeyClassKeys
	dim i
	
	' create the cryptoinstall instance
	set objCrypto = CreateObject("MetraTech.Security.Crypto.CryptoInstall")
	if Err then
		msgbox "Error: " & Err.number & " Description: " & Err.description 
		exit function
	end if
		
	' store key/value lists as separate elements in the master array.
	asMasterArray = Split(session.Property("CustomActionData"), ";*;")
	
	' element 0 of the master array contains the key class names
	asKeyClassNames = Split(asMasterArray(0), ";")
	
	' element 1 of the master array contains the key class keys
	asKeyClassKeys = Split(asMasterArray(1), ";")
			
	' pass both arrays to the crypto instance
	objCrypto.GenerateSessionKeys (asKeyClassNames), (asKeyClassKeys), True
	if Err then
		msgbox "Error: " & Err.number & " Description: " & Err.description 
		exit function
	end if			
end function

function UpdateKMSConfig()
	dim objCrypto
	dim asMasterArray
	dim asKMSConfig
	dim asKeyClassNames
	dim asKeyClassKeys
	dim sKMSServer
	dim sClientCertFile
	dim sClientCertPwd
	dim sTicketingKey
	dim i
	
	' create the cryptoinstall instance
	set objCrypto = CreateObject("MetraTech.Security.Crypto.CryptoInstall")
	
	' store key/value lists as separate elements in the master array.
	asMasterArray = Split(session.Property("CustomActionData"), ";*;")
	
	' KMS server config info
	asKMSConfig = Split(asMasterArray(0),";")
	
	' assign settings
	sKMSServer = asKMSConfig(0)		
	sClientCertFile = asKMSConfig(1)		
	sClientCertPwd = asKMSConfig(2)		
	sTicketingKey = asKMSConfig(3)
	
	' key class names
	asKeyClassNames = Split(asMasterArray(1), ";")
		
	' key class keys
	asKeyClassKeys = Split(asMasterArray(2), ";")
			
	' write config
	objCrypto.UpdateKMSConfig sKMSServer, sClientCertFile, sClientCertPwd, (asKeyClassNames), (asKeyClassKeys), sTicketingKey, True
	if Err then
		msgbox "Error: " & Err.number & " Description: " & Err.description
		exit function
	end if
			
end function	