dim rpthelper
dim timeslice
dim accslice
dim productslice

dim sessslice
Dim idparent

set sessslice = CreateObject("MTHierarchyReports.RootSessionSlice")


Set rpthelper = CreateObject("MTHierarchyReports.ReportHelper")
call rpthelper.Initialize(nothing, 840, nothing)

'search based on usage interval
'Set timeslice = CreateObject("MTHierarchyReports.UsageIntervalSlice")
'timeslice.IntervalID = 23085

Set timeslice = CreateObject("MTHierarchyReports.DateRangeSlice")
timeslice.Begin = Cdate("9/14/2002")
timeslice.End = Cdate("10/01/2004")


Set accslice = CreateObject("MTHierarchyReports.PayerSlice")
accslice.PayerID = 123

'search knowing the product offering (PI instance)
Set productslice = CreateObject("MTHierarchyReports.PriceableItemInstanceSlice")
productslice.ViewID = 4
productslice.InstanceID = 117

'search knowing pi template (instance has to be NULL)
'Set productslice = CreateObject("MTHierarchyReports.PriceableItemTemplateSlice")
'productslice.ViewID = 4
'productSlice.TemplateID = 55


'search knowing only pi type (hence the view id) The search will not include non PC data
'Set productslice = CreateObject("MTHierarchyReports.ProductViewSlice")
'productslice.ViewID = 4

'search knowing only pi type (hence the view id). Search will include all the data for
'the product view: non PC as well as PC
Set productslice = CreateObject("MTHierarchyReports.ProductViewAllUsageSlice")
productslice.ViewID = 4




' for non PO usage use the below object
' Set productslice = CreateObject("MTHierarchyReports.ProductViewSlice")
' productslice.ViewID = 4


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

wscript.echo "Getting usage details for conf call"
Set rs = rpthelper.GetUsageDetail(productslice, sessslice, accslice, timeslice, "")
dumprs(rs)
rs.MoveFirst
set sessslice = nothing
set sessslice = CreateObject("MTHierarchyReports.SessionChildrenSlice")

'just get the first record of the rowset
idparent = CLng(rs.Value(1))
sessSlice.ParentID = idparent


wscript.echo "Getting usage summary for children of conf call"
Set rs = rpthelper.GetUsageSummary(sessslice, accslice, timeslice)
dumprs(rs)
rs.MoveFirst

'STDMETHODIMP CReportHelper::GetUsageSummary(IViewSlice *pViewSlice, IAccountSlice *pAccountSlice, ITimeSlice *pTimeSlice, IMTSQLRowset **pRowset)

wscript.echo "Now Getting usage details for conf call children of type ConfCallConnection"
wscript.echo "Hardcode ViewID for no. Later get it from selected adjustment type"


set productslice = nothing
Set productslice = CreateObject("MTHierarchyReports.ProductViewAllUsageSlice")
productslice.ViewID = 5 'confcallconnection
Set rs = rpthelper.GetUsageDetail(productslice, sessslice, accslice, timeslice, "")
dumprs(rs)
rs.MoveFirst




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