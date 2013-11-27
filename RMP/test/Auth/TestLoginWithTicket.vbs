Dim c
Dim cb
Dim state
Dim s

Dim ta
Dim t
Dim lctx
Dim ctx
Set lctx = CreateObject("MetraTech.MTLoginContext")
Set ta = CreateObject("MetraTech.TicketAgent")
ta.Key = "sharedsecret"
t = ta.CreateTicket("mt", "demo", 0)
If Err Then
  wscript.echo "Failed to create ticket " & Err.Description
End If

Set ctx = lctx.LoginWithTicket("mt", t)
wscript.echo "Logged in with ticket, account is = " & ctx.SecurityContext.AccountID



