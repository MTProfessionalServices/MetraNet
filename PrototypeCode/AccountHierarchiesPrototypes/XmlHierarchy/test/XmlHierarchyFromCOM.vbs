set obj = CreateObject("XmlHierarchy.XmlHierarchy")
call obj.Init()
wscript.echo obj.GenerateFragment(1)
wscript.echo obj.GenerateFragmentByName("Account Hierarchy Root")