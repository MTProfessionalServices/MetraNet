
'on error resume next
Sub PrintUsage()
	wscript.echo "Usage: LoadInternalAccountData -accountID [-timezone] [-IsFolder Y/N] "
	wscript.echo ""
End Sub

Public Function Main() ' As Boolean
	numargs = 0
	if wscript.arguments.length = 0 then
		PrintUsage
		Exit Function
	end if

	'wscript.echo "-- Creating NameID object --"
	dim aNameID 
	set aNameID = CreateObject("MetraPipeline.MTNameID.1")
	if err then
    	wscript.echo "ERROR:" & err.description 
	end if
	dim accountID
  dim isfolder

	' set default values
	dim tzid
  tzid = aNameID.GetNameID("Global/TimezoneID/(GMT-05:00) Eastern Time (US & Canada)")
  isfolder = "N"
	

	while numargs < wscript.arguments.length
		arg = wscript.arguments(numargs)
	
		'wscript.echo "numargs --> " &numargs
		'wscript.echo "wscript.arguments.length --> " &wscript.arguments.length
	
		Select Case arg
			case "-accountID"
				numargs = numargs + 1
				if numargs >= wscript.arguments.length then
					PrintUsage
					Exit Function
				end if
				accountID = wscript.arguments(numargs)
	
			case "-timezone"
				numargs = numargs + 1
				if numargs >= wscript.arguments.length then
					PrintUsage
					Exit Function
				end if
	
				dim timezoneinput
				timezoneinput = wscript.arguments(numargs)
				'wscript.echo "-- Setting timezone rules --"
				if timezoneinput = "gmt" then
					tzid = aNameID.GetNameID("Global/TimezoneID/(GMT) Monrovia, Casablanca")
				end if
      case "-IsFolder"
				numargs = numargs + 1
				if numargs >= wscript.arguments.length then
					PrintUsage
					Exit Function
				end if
				isfolder = wscript.arguments(numargs)
        
		end Select
		numargs = numargs + 1
	wend
	
	'wscript.echo "-- Creating Account Adapter --"
	dim acc_adapter 
	set acc_adapter = CreateObject("MTAccount.MTAccountServer.1")
	if err then
    	wscript.echo "ERROR:" & err.description 
	end if
	
	if acc_adapter is nothing then
    	wscript.echo "Object is nothing"
	end if
	
	'wscript.echo "-- initializing account server --"
	acc_adapter.initialize("Internal")
	if err then
    	wscript.echo "ERROR:" & err.description 
	end if
	
	'wscript.echo "-- Creating account property collection --"
	set acc_prop_coll = CreateObject("MTAccount.MTAccountPropertyCollection.1")
	If Err Then
    	wscript.echo "ERROR:" & Err.Description
	End If
	
	'wscript.echo "-- Set up data for these accounts --"
	dim acctype 
	acctype = aNameID.GetNameID("metratech.com/accountcreation/AccountType/Bill-To")
	
	dim accstatus
	accstatus = aNameID.GetNameID("metratech.com/accountcreation/AccountStatus/Active")
	
	dim secq
	secq = aNameID.GetNameID("metratech.com/accountcreation/SecurityQuestion/Pin")
	
	dim invmethod 
	invmethod = aNameID.GetNameID("metratech.com/accountcreation/InvoiceMethod/None")
	
	dim uctype
	uctype = aNameID.GetNameID("metratech.com/BillingCycle/UsageCycleType/Monthly")
	
	dim langcode
	langcode = aNameID.GetNameID("Global/LanguageCode/US")
	
	dim tariffid
	tariffid = aNameID.GetNameID("metratech.com/tariffs/TariffID/Default")
	
	dim taxexempt
	taxexempt = "Y"
	
	dim paymethod
	paymethod = aNameID.GetNameID("metratech.com/accountcreation/PaymentMethod/CashOrCheck")
	
	dim	streason
	streason = aNameID.GetNameID("metratech.com/accountcreation/StatusReason/AccountTerminated")
	
	acc_prop_coll.Add "id_acc", clng(accountID)
	acc_prop_coll.Add "tariffID", clng(tariffID)
	acc_prop_coll.Add "taxexempt", cstr(taxexempt)
	acc_prop_coll.Add "timezoneID", clng(tzid)
	acc_prop_coll.Add "PaymentMethod", clng(paymethod)
	acc_prop_coll.Add "AccountStatus", clng(accstatus)
	acc_prop_coll.Add "SecurityQuestion", clng(secq)
	acc_prop_coll.Add "InvoiceMethod", clng(invmethod)
	acc_prop_coll.Add "UsageCycleType", clng(uctype)
	acc_prop_coll.Add "Language", clng(langcode)
	acc_prop_coll.Add "SecurityAnswer", "None"
	acc_prop_coll.Add "StatusReasonOther", "No other reason"
	acc_prop_coll.Add "TaxExemptID", "1234567"
	acc_prop_coll.Add "StatusReason", clng(streason)
	acc_prop_coll.Add "currency", "USD"
	acc_prop_coll.Add "folder", cstr(isfolder)
	acc_prop_coll.Add "billable","Y"
			
	acc_adapter.AddData "Internal", acc_prop_coll
	if err then
   	wscript.echo "ERROR:" & err.description 
	end if
	
	if len(timezoneinput) = 0 then
		wscript.echo "Loaded internal account data for <" & accountID & ">"
	else
		wscript.echo "Loaded internal account data for <" & accountID & "> and with timezone <" & timezoneinput & ">"
	end if

	wscript.echo "-------------------------------------------------------------"
	Main = TRUE
End Function
' --------------- Account Adapter Stuff -----------------------------'

Main
