
  dim sAccountNamespace
  dim sAccountId
  dim iExpirationOffset
  
  sAccountNamespace="mt"
  sAccountId="123"
  iExpirationOffset = 1 '60*10  '10 Minutes
  
  wscript.echo "Creating Ticket Agent Object"
	dim objTicketAgent
	set objTicketAgent = createObject("MetraTech.TicketAgent.1")
  
  wscript.echo "Setting Encryption Key"
  objTicketAgent.Key = "sharedsecret"
  
  wscript.echo "Creating Ticket"
	dim sTicket
	sTicket=objTicketAgent.CreateTicket(sAccountNamespace,sAccountId,iExpirationOffset)

  wscript.echo "Created Ticket [" & sTicket & "]"
  
  'objTicketAgent.Key = ""
  
  wscript.echo "Retrieving properties from created ticket"
  dim objTicket
  set objTicket=objTicketAgent.RetrieveTicketProperties(sTicket)
  
  wscript.echo "Retrieved Account[" & objTicket.AccountIdentifier & "] Namespace [" & objTicket.Namespace & "] from ticket"
  