' Script file used to create, update, and populate materialized views

' Main entry into script.
Main

' Initialize globals
Dim bFullUpdate
bFullUpdate = false
Dim bDefUpdate
bDefUpdate = false
Dim bConfigUpdate
bConfigUpdate = false
Dim MVName
Dim username
Dim password
Dim ErrNum
ErrNum = -1

' Main implementation
Public Function main()

	' What do we want to do: process command line arguments
	ProcessCommands()

	' Exit on error.
	if (ErrNum = -1) then
		Exit Function
	End If

	' Update configuration.
	If bConfigUpdate then
		' Run Materialized View Hook instead of calling MV config update
		' directly because the hook does other things to prepare the
		' system for materialized view use.
		Dim objLoginContext, objSessionContext
		Set objLoginContext = CreateObject("Metratech.MTLoginContext")
		Set objSessionContext = objLoginContext.Login(username, "system_user", password)

		set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
		aHookHandler.SessionContext = objSessionContext
		call aHookHandler.RunHookWithProgid("MetraTech.Product.Hooks.MaterializedViewHook","")
		
		wscript.echo "Materialized View configuration update complete."
	End If

	' Initialize Materialized View Manager
	Dim aMVM
	set aMVM = CreateObject("MetraTech.DataAccess.MaterializedViews.Manager")
	aMVM.Initialize()

	' If support is enabled execute the request.
	If aMVM.IsMetraViewSupportEnabled() then
		' Output MV framework status.
		wscript.echo "Materialized View support is enabled."

		If bFullUpdate then
			' Run Full Update on all materialized views.
			if MVName = "*" then
				aMVM.DoFullMaterializedViewUpdateAll()
				wscript.echo "Updated all materialized views."
				
			' Run Full Update on specified materialized view.
			else
				aMVM.DoFullMaterializedViewUpdate(MVName)
				wscript.echo "Updated " + MVName + " materialized view."
			End If
		else
			if bDefUpdate then
				' Run Deferred Update on all materialized views.
				if MVName = "*" then
					aMVM.UpdateAllDeferredMaterializedViews()
					wscript.echo "Updated all deferred materialized views."
					
				' Run Deferred Update on specified materialized view.
				else
					aMVM.UpdateDeferredMaterializedView(MVName)
					wscript.echo "Updated " + MVName + " deferred materialized view."
				End If
			End If
		End If
	else
		' Output MV framework status.
		wscript.echo "Materialized View support is disabled."
	End If
End Function

' Procedure to get command line arguments
Sub ProcessCommands()
	dim found
	found = false
	dim numargs
	numargs = 0
	Dim arg
	while numargs < wscript.arguments.length
		arg = wscript.arguments(numargs)

        Select Case LCASE(arg)
        case "-full", "/full"
		    numargs = numargs + 1
	        if numargs >= wscript.arguments.length then
				Wscript.Echo "Missing Materialized View name."
				wscript.echo ""
				ErrNum = -1
			    Exit Sub
            end if
            bFullUpdate = true
            MVName = wscript.arguments(numargs)
			ErrNum = 0
			
        case "-def", "/def"
		    numargs = numargs + 1
	        if numargs >= wscript.arguments.length then
				Wscript.Echo "Missing Materialized View name."
				wscript.echo ""
				ErrNum = -1
			    Exit Sub
            end if
            bDefUpdate = true
            MVName = wscript.arguments(numargs)
			ErrNum = 0
			
		case "-update", "/update"
		    numargs = numargs + 1
	        if numargs >= wscript.arguments.length then
				Wscript.Echo "Missing system user name."
				wscript.echo ""
				ErrNum = -1
			    Exit Sub
            end if
			username = wscript.arguments(numargs)
		    numargs = numargs + 1
	        if numargs >= wscript.arguments.length then
				Wscript.Echo "Missing system user password."
				wscript.echo ""
				ErrNum = -1
			    Exit Sub
            end if
			password = wscript.arguments(numargs)

            bConfigUpdate = true
			ErrNum = 0
			
		case "-?", "/?", "-help"
			PrintUsage
			ErrNum = -1
		
		case else
			Wscript.Echo "Invalid argument specified."
			PrintUsage
			ErrNum = -1

		End select

        numargs = numargs + 1
	wend

if numargs = 0 then
	' Show help.
	PrintUsage
	ErrNum = -1
    Exit Sub
end if

End Sub

' Usage help
Sub PrintUsage()
    wscript.echo "Usage: cscript mvm.vbs with the following optional arguments :"
    wscript.echo ""
	Wscript.Echo "-? : This help"
	Wscript.Echo "-full [MaterializedViewName] : Run full update for materialized view"
	Wscript.Echo "-full [*] : Run full update for all materialized views"
	Wscript.Echo "-def [MaterializedViewName] : Run deferred update for materialized view"
	Wscript.Echo "-def [*] : Run deferred update for all materialized views"
	Wscript.Echo "-update [username] [password]: Update configuration, provide system user login info"
	wscript.echo ""
    wscript.echo "The following example updates the configuration then runs full"
    wscript.echo "update on all materialized views:"
    wscript.echo "     cscript mvm.vbs -update name pwd -full *"
    
End Sub

' EOF