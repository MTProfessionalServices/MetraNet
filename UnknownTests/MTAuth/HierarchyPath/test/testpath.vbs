Dim objPath

Set objPath = CreateObject("Metratech.MTHierarchyPath")


objPath.Pattern = "/metratech/engineering/-"


if(objPath.Implies("/metratech/engineering/development/raju")) Then
	wscript.echo(objPath.Pattern & " implies /metratech/engineering/development/raju - OK")
else
	wscript.echo(objPath.Pattern & " does not imply /metratech/engineering/development/raju - ERROR")
end if 

if(objPath.Implies("/metratech/scott")) Then
	wscript.echo(objPath.Pattern & " implies /metratech/scott - ERROR")
else
	wscript.echo(objPath.Pattern & " does not imply /metratech/scott - OK")
end if 


if(objPath.Implies("/metratech/engineering/*")) Then
	wscript.echo(objPath.Pattern & " implies /metratech/engineering/* - OK")
else
	wscript.echo(objPath.Pattern & " does not imply /metratech/engineering/* - ERROR")
end if 

if(objPath.Implies("/metratech/*")) Then
	wscript.echo(objPath.Pattern & " implies /metratech/* - ERROR")
else
	wscript.echo(objPath.Pattern & " does not imply /metratech/* - OK")
end if 

if(objPath.Implies("/metratech/sales/SalesPeon")) Then
	wscript.echo(objPath.Pattern & " implies /metratech/sales/SalesPeon - ERROR")
else
	wscript.echo(objPath.Pattern & " does not imply /metratech/sales/SalesPeon - OK")
end if 



objPath.Pattern = "/metratech/engineering/development/raju"

if(objPath.Implies("/metratech/sales/SalesPeon")) Then
	wscript.echo(objPath.Pattern & " implies /metratech/sales/SalesPeon - ERROR")
else
	wscript.echo(objPath.Pattern & " does not imply /metratech/sales/SalesPeon - OK")
end if 

if(objPath.Implies("/metratech/engineering/qa/Anagha")) Then
	wscript.echo(objPath.Pattern & " implies /metratech/engineering/qa/Anagha - ERROR")
else
	wscript.echo(objPath.Pattern & " does not imply /metratech/engineering/qa/Anagha - OK")
end if 

if(objPath.Implies("/metratech/engineering/development/raju")) Then
	wscript.echo(objPath.Pattern & " implies /metratech/engineering/development/raju - OK")
else
	wscript.echo(objPath.Pattern & " does not imply /metratech/engineering/development/raju - ERROE")
end if 
