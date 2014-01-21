option explicit
dim wsh, env, fso, doc, nm, args, a, nib
dim af, cf, sf, of   	' filenames
dim ad, cd, sd, od		' xml docs
dim node
dim tags
set wsh = CreateObject("Wscript.Shell")
set env = wsh.environment("process")
set fso  = createobject("scripting.filesystemobject")
set tags = createobject("scripting.dictionary")
nib = "."

'reference to named args
set args = wscript.arguments

' load the queryadapter.xml file
af = "queryadapter.xml"
if args.named.exists("a") then 
	af = args.named.item("a")
	if af = "" then af = "n/a"
end if

set doc = docfromfile(af)

set cf = doc.selectsinglenode("//common_query_file")
if cf is nothing then cf = "" else cf = cf.text
if wscript.arguments.named.exists("c") then
	cf = wscript.arguments.named.item("c") 
end if
if cf = "" then cf = "n/a"
if cf <> "n/a" then 
	' sometimes there isn't a common query file
	set cd = docfromfile(cf)
	for each node in cd.selectnodes("//query_tag")
		tags.add node.text, array("c", nib, nib)
	next
else
	cf = "n/a"
end if

set sf = doc.selectsinglenode("//sql_server_query_file") 
if sf is nothing then sf = "" else sf = sf.text
if wscript.arguments.named.exists("s") then
	sf = wscript.arguments.named.item("s") 
end if
if sf = "" then sf = "n/a"
if sf <> "n/a" then
	set sd = docfromfile(sf)
	for each node in sd.selectnodes("//query_tag")
		if tags.exists(node.text) then
			a = tags.item(node.text)
			a(1) = "s"
			tags.item(node.text) = a
		else
			tags.add node.text, array(nib, "s", nib)
		end if
	next
end if

set of = doc.selectsinglenode("//oracle_query_file")
if of is nothing then of = "" else of = of.text
if wscript.arguments.named.exists("o") then
	of = wscript.arguments.named.item("o") 
end if
if of = "" then of = "n/a"
if of <> "n/a" then
	set od = docfromfile(of)
	for each node in od.selectnodes("//query_tag")
		if tags.exists(node.text) then
			a = tags.item(node.text)
			a(2) = "o"
			tags.item(node.text) = a
		else
			tags.add node.text, array(nib, nib, "o")
		end if
	next
end if

showhash tags

'wscript.echo "done."
wscript.echo 
wscript.echo "Files:"
wscript.echo "  Adapter:    " & af
wscript.echo "  Common:     " & cf
wscript.echo "  Sql Server: " & sf
wscript.echo "  Oracle:     " & of
wscript.quit

'load xml file
serversxml = env("rootdir") & "\..\RMP\config\ServerAccess\servers.xml"
loadxmldoc doc, serversxml

' end script
wscript.echo "done."

function loadcommon
	dim f
	set f = fso.opentextfile(env("rootdir") & "\install\scripts\common.vbs")
	executeglobal f.readall()
	f.close
end function

function docfromfile(file)
	dim doc

  set doc = createobject("msxml2.domdocument.4.0")
  set docfromfile = doc

  doc.async              = false
  doc.validateonparse    = false
  doc.preservewhitespace = true
  doc.resolveexternals   = false

  doc.load(file)

  if doc.parseerror.errorcode <> 0 then
		with doc.parseerror
			wscript.echo "loadxml file: " _
				& file & "(" & .line & "," & .linepos & ") " _
				& doc.parseerror.reason 
		end with
		wscript.quit
  end if

end function

function showhash(h)
	dim k
	
	for each k in h.keys
		wscript.echo showflags(h.item(k)) & "  " & k
	next

end function

function showflags(a)
	dim x
	
  for each x in a
		showflags = showflags & lcase(x)
  next

end function

