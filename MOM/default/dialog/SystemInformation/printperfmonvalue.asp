<%
'  On error resume next
  
	Dim mstrServerName ' as object
  Dim bOdd ' as boolean
  
  ' get server name
  mstrServerName = request.ServerVariables("SERVER_NAME")
	
  bOdd = true
  
' ------------------------------------------------------------------------------------------  
' PrintPerfMonValue
' Description:  PrintPerfMonValue prints a table row for a performance monitor query
' Parameters:  description of query, perfmon query, low value, high value
' Note:  prints out value in red if it is not in the valid range
' ------------------------------------------------------------------------------------------  
sub PrintPerfMonValue(strHeader, strPerfMonQuery, strGoodLow, strGoodHigh)
  on error resume next 
  
  Dim objMonitor ' as object
  Dim strValue ' as string
  Dim strValueCommas ' as string
  Dim strClass
  Dim bRetVal

  ' create service monitoring object
  set objMonitor = CreateObject("ServiceMonitor.PerfMon")  
  
  if err then
    WriteErrorObject(err)
  end if
 
  ' initialize monitor
  bRetVal = objMonitor.Init(strPerfMonQuery)

  if err then
    WriteErrorObject(err)
  end if
  ' get value

  strValue = CStr(objMonitor.GetValue())
  strValueCommas =  FormatNumber(strValue,0,,,true)
  
  'initialize strClass
  strClass = "clsPerfmonRow"

  '  response.write "* " & strHeader & " : " & strGoodLow & " : " & strValue & " : " & strGoodHigh & "<br>" 
  ' check for valid range   
  if strGoodHigh <> "" then
    if strGoodLow <> "" then
      if strGoodHigh <> "INFINITY" then
        if CLng(strValue) > CLng(strGoodHigh) then
          strClass = "clsPerfmonAlert"
        Elseif CLng(strValue) < CLng(strGoodLow) then
          strClass = "clsPerfmonAlert"
        end if
      Elseif CLng(strValue) < CLng(strGoodLow) then
          strClass = "clsPerfmonAlert"
      end if
    end if
  end if  

  ' write result
  response.write "      <tr>" & vbNewline

  if bOdd = true then  
    response.write "        <td class = ""clsTableTextOddLabel"">" & strHeader & "</td>" & vbNewline
    response.write "        <td align=""right"" class = """ & strClass & "Odd"">" & strValueCommas & "</td>" & vbNewline
  else
    response.write "        <td class = ""clsTableTextEvenLabel"">" & strHeader & "</td>" & vbNewline
    response.write "        <td align =""right"" class=""" & strClass & "Even"">" & strValueCommas & "</td>" & vbNewline
  end if

  response.write "      </tr>" & vbNewline  

  bOdd = not bOdd
  
  objMonitor.CloseQuery
	Set objMonitor = Nothing

end sub

%>