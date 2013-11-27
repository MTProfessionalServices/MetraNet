<%
    On Error Resume Next

    dim stream
    dim intTimeout
    intTimeout = Server.ScriptTimeout
    Server.ScriptTimeout = 3600   ' let this try to run for an hour download
    
    set stream = Server.createObject("Scripting.FileSystemObject").OpenTextFile(request.queryString("Filename"))
    
    if Err then
      response.write Err.description
    end if
    
  	response.contentType = "application/save"
  	response.addheader "Content-disposition", "filename=MTLog_" & request.servervariables("SERVER_NAME") & ".log"
  	    
    do while not stream.atEndOfStream
      response.write stream.readline & vbnewline
    loop
        
    stream.close
    set stream = nothing
    Server.ScriptTimeout = intTimeout
%>
