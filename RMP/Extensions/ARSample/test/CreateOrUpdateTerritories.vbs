' --------------------------------------------------------------------------------------------------------------------------------------------
' script that creates or updates territories in AR
' uses file CreateOrUpdateTerritories.xml
' --------------------------------------------------------------------------------------------------------------------------------------------

const xmlFile = "CreateOrUpdateTerritories.xml"

Dim configState
Dim arInterfaceConfigObj
Dim arInterfaceWriterObj
Dim domDoc


wscript.echo "Configuring AR interface"

Set arInterfaceConfigObj = CreateObject("MetraTech.MTARConfig")
Set configState = arInterfaceConfigObj.Configure

wscript.echo "Loading XML file: " & xmlFile
Set domDoc = CreateObject("MSXML2.DOMDocument.4.0") 

domDoc.Load xmlFile
If domDoc.parseError Then 
  wscript.echo "Failed to load " & xmlFile & ":  PARSE ERROR: " & domDoc.parseError.reason
Else   
  wscript.echo "Calling AR Interface CreateOrUpdateTerritories"

  Set arInterfaceWriterObj = CreateObject("MetraTech.MTARWriter")
  Call arInterfaceWriterObj.CreateOrUpdateTerritories(domDoc.xml, configState)

  wscript.echo "CreateOrUpdateTerritories succeeded"
End If     
