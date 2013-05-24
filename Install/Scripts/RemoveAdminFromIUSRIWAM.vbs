' The goal of this script is to determine if there is a IUSR/IWAM account
' then look at the accounts and inspect for admin rights
' then remove them in the following fashion
' #net localgroup Administrators IUSR_<machinename> /delete
' #net localgroup Administrators IUSR_<machinename> /delete

Set objNetwork = CreateObject("Wscript.Network")
strComputer = objNetwork.ComputerName
Set colAccounts = GetObject("WinNT://" & strComputer & "")
colAccounts.Filter = Array("user")
For Each objUser In colAccounts
	' Test to determine if it is the IUSER account
	Set regEx = New RegExp
	regEx.IgnoreCase = False
	regEx.Pattern = "(IUSR_|IWAM_)"
	' Do the search test.
	retVal = regEx.Test(objUser.Name)
	If retVal Then
        Wscript.Echo "Match found in : " & objUser.Name
		set myshell = CreateObject("Wscript.Shell")
		cmd="net localgroup Administrators " & objUser.Name & " /delete"
		myshell.Run cmd
	End If
Next
