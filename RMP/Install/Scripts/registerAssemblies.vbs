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
'* Name:        registerAssemblies.vbs
'* Created By:  Mike Pento
'* Description: Register .NET assemblies with type libraries.
'*
'*******************************************************************************

' Require explicit declarations
option explicit

Function registerAssemblies()
	Dim sRegAsm
	Dim sOptions
	Dim sCmd
	Dim sInstallDir
	Dim sAssembly
	Dim sTypeLib
	Dim oWshell
	Dim aData
	Dim nRetVal, i, pos
	
	' fill array with CA data
	aData = Split(session.Property("CustomActionData"),";")
	if UBound(aData) < 1 then
		exit function ' too few args, nothing passed
	end if
		
	' init
	sRegAsm = "C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\RegAsm.exe"
	sOptions = " /codebase /tlb:"
	
	' [INSTALLDIR] is always passed as first argument
	sInstallDir = aData(0)
	
	' create shell object
	set oWshell = CreateObject("WScript.Shell")
	
	' register the assemblies
	for i=1 to UBound(aData)
		' build path to assembly
		sAssembly = sInstallDir & "RMP\Bin\" & aData(i)
		
		' get filename without extension
		pos = InStrRev(aData(i),".",len(aData(i)),1)
		sTypeLib = mid(aData(i),1,pos)
				
		' build command line options
		sCmd = sRegAsm & sOptions & chr(34) & sTypeLib & "tlb" & chr(34) &_
		 " " & chr(34) & sAssembly & chr(34)	
		 
		 ' register the assembly
		 nRetVal = oWshell.Run(sCmd,0,True)				 
	Next	                                 	
	
End Function