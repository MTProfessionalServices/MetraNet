dim rpthelper
dim timeslice
dim accslice
dim productslice

dim sessslice

set sessslice = CreateObject("MTHierarchyReports.RootSessionSlice")


Set rpthelper = CreateObject("MTHierarchyReports.ReportHelper")
call rpthelper.Initialize(nothing, 840, nothing)
' rpthelper.InlineAdjustments = false
' rpthelper.InteractiveReport = false

Set timeslice = CreateObject("MTHierarchyReports.UsageIntervalSlice")
timeslice.IntervalID = 23086

Set accslice = CreateObject("MTHierarchyReports.PayerSlice")
accslice.PayerID = 155

'only do for instance now
'That assumes that we already know PO iD
' Set productslice = CreateObject("MTHierarchyReports.PriceableItemTemplateWithInstanceSlice")
' productslice.TemplateID = 4
'productslice.InstanceID = 117


' for non PO usage use the below object
Set productslice = CreateObject("MTHierarchyReports.ProductViewAllUsageSlice")
productslice.ViewID = 4



' [id(18), helpstring("method GetUsageDetail")] HRESULT GetUsageDetail([in] ISingleProductSlice *pProductSlice, [in] IViewSlice *pViewSlice, [in] IAccountSlice *pAccountSlice, 
' [in] ITimeSlice *pTimeSlice, [in] BSTR aExtension, [out, retval] IMTSQLRowset **pRowset);

Dim rs
Dim objPV
Dim props
Dim prop
Set objPV = productslice.ProductView
  Set props = objPV.GetProperties()
  
  for each prop in props
    if prop.dn = "ConferenceID" Then
      call productslice.AddProductViewPropertyPredicate(prop, "199903195095819")
    End IF
  
  Next  

Set rs = rpthelper.GetUsageDetail(productslice, sessslice, accslice, timeslice, "")
dumprs(rs)

function dumprs(rowset)
	dim i,str,j,tempvar
	for i = 0 to rowset.recordcount -1
		str = ""
		for j = 0 to rowset.count -1
			tempvar = rowset.value(j)
				tempvar = rowset.value(j)
				if not IsObject(tempvar) then
					if not IsNull(tempvar) then
						str = str & CStr(rowset.value(j)) & " "
					end if
				end if
		next
		wscript.echo str
		rowset.MoveNext
	next
end function