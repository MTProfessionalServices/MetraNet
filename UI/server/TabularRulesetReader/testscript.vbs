
on error resume next

dim objTRReader
set objTRReader = createobject("MTTabRulesetReader.RulesetHandler")

if err then
	wscript.echo "err during object creation: " & err.description
else
	wscript.echo "created the object"
end if


call objTRReader.initialize("")


wscript.echo "ServiceDefinition: " & objTRReader.service
if err then
	wscript.echo "err during help file call: " & err.description
end if


wscript.echo "Help file: " & objTRReader.HelpFile
if err then
	wscript.echo "err during help file call: " & err.description
end if


wscript.echo "Help file: " & objTRReader.HelpFile
if err then
	wscript.echo "err during help file call: " & err.description
end if


wscript.echo "Help file: " & objTRReader.HelpFile
if err then
	wscript.echo "err during help file call: " & err.description
end if


wscript.echo "Help file: " & objTRReader.HelpFile
if err then
	wscript.echo "err during help file call: " & err.description
end if


wscript.echo "Help file: " & objTRReader.HelpFile
if err then
	wscript.echo "err during help file call: " & err.description
end if


wscript.echo "Help file: " & objTRReader.HelpFile
if err then
	wscript.echo "err during help file call: " & err.description
end if

