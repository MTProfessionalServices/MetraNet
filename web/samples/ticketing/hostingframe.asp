<%
dim errorcode
errorcode = Request("errorcode")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Untitled</title>
  <style type="text/css">
    body {
      background-color: white;
      margin: 10px;
    }
  </style>
</head>
<body bgcolor = "white">
<p>
<%
If errorcode = "" then
  response.write "Hosting frame"
Else
  response.write "The server responded with error code " & errorcode
  Select Case errorcode
    Case 3
      response.write " (Account is pending)"
    Case 4
      response.write " (Account is inactive)"
    Case Else
      response.write " (Unknown error)"
  End Select
End if
%>
</p>
</body>
</html>
