dim rpthelper
dim timeslice
dim accslice
dim productslice

dim sessslice

set sessslice = CreateObject("MTHierarchyReports.SessionChildrenSlice")
sessslice.ParentID = 10000


Set rpthelper = CreateObject("MTHierarchyReports.ReportHelper")
call rpthelper.Initialize(nothing, 840, nothing)

Set timeslice = CreateObject("MTHierarchyReports.UsageIntervalSlice")
timeslice.IntervalID = 23088

Set accslice = CreateObject("MTHierarchyReports.PayerSlice")
accslice.PayerID = 123

'only do for instance now
'That assumes that we already know PO iD
Set productslice = CreateObject("MTHierarchyReports.PriceableItemInstanceSlice")
productslice.ViewID = 5
productslice.InstanceID = 397


' for non PO usage use the below object
'Set productslice = CreateObject("MTHierarchyReports.ProductViewSlice")
'productslice.ViewID = 5


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

Set rs = rpthelper.GetAdjustmentDetail(productslice, sessslice, accslice, timeslice, "")
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