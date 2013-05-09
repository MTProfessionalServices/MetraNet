Dim regex
Dim match
Dim matches

Set regex = New Regexp

regex.IgnoreCase = true
regex.Pattern = "/metratech/engineering/development/raju/blah"

wscript.echo("Executing")
Set matches = regex.Execute("/metratech/engineering/development/*")
wscript.echo matches.count

For each match in matches
	wscript.echo match.Value
Next
