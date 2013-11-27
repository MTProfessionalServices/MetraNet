<%
' //==========================================================================
' // Copyright 1998-2000 by MetraTech Corporation
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
' //==========================================================================

  Option Explicit
  On Error Resume Next
%>
<%
  Dim objFSO
  Dim objStream
  Dim intTimeout
  
  intTimeout = Server.ScriptTimeout
  Server.ScriptTimeout = 3600   ' let this try to run for an hour download
  
  Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
  Set objStream = objFSO.OpenTextFile(request.queryString("Filename"))
  
  if Err then
    response.write Err.description
  end if
  
	response.contentType = "application/save"
	response.addheader "Content-disposition", "filename=MTLog_" & request.servervariables("SERVER_NAME") & ".log"
	    
  do while not objStream.atEndOfStream
    response.write objStream.readline & vbnewline
  loop
      
  objStream.close

  set objStream = nothing
  Server.ScriptTimeout = intTimeout
%>
