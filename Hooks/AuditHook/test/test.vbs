
on error resume next
Set mConfig = CreateObject("MetraTech.MTConfig.1")
if err then
    wscript.echo "1: error occurred: " & err.description
else
    wscript.echo "1: Successful"    
end if


set aPropSet = mConfig.ReadConfigurationFromString("<xmlconfig><hook>MetraHook.AuditHook.1</hook></xmlconfig>",false)
if err then
    wscript.echo "2: error occurred: " & err.description
else
    wscript.echo "2: Successful"    
end if

set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
if err then
    wscript.echo "3: error occurred: " & err.description
else
    wscript.echo "3: Successful"    
end if

call aHookHandler.Read(aPropSet)
if err then
    wscript.echo "4: error occurred: " & err.description
else
    wscript.echo "4: Successful"    
end if


call aHookHandler.ExecuteAllHooks("",0)
if err then
    wscript.echo "5: error occurred: " & err.description
else
    wscript.echo "5: Successful"    
end if