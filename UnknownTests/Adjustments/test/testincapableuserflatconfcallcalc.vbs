dim ac
dim pc
Dim aj

Set ac = CreateObject("MetraTech.Adjustments.AdjustmentCatalog")
Set pc = CreateObject("MetraTech.MTProductCatalog")
Dim login
Set login = CreateObject("Metratech.MTLoginContext")
Dim ctx
set ctx = login.Login("csr1", "system_user", "csr123")

ac.Initialize(ctx)
pc.SetSessionContext(ctx)

wscript.echo "Testing Flat adjustment for conference call"

Dim ajtype
Dim ajtypes
Dim pitype
dim trxset
Set pitype = pc.GetPriceableItemTypeByName("AudioConfCall")
wscript.echo "get transaction records for 1 parent record"

Dim trxs
Dim sessions
Set sessions = CreateObject("MetraTech.MTCollection")
dim rs
dim pitemplate
  set rs = CreateObject("MTSQLRowset.MTSqlRowset")
  rs.Init("queries\database")
  rs.SetQueryString "select top 1 * from t_acc_usage au inner join t_pi_template pit" & vbNewLine &_
                    " ON au.id_pi_template = pit.id_template where pit.id_pi = " & pitype.ID
  rs.Execute
  set sessions = CreateObject("MetraTech.MTCollectionEx")
  dim i
  rs.MoveFirst
  for i = 0 to rs.RecordCount -1
    pitemplate = rs.Value("id_pi_template")
    call sessions.Add(CLng(rs.Value("id_sess")))
    rs.MoveNext
  next
  
wscript.echo "getting adjustment types available for " & pitemplate & " pi template"
Set ajtypes = ac.GetAdjustmentTypesForPITemplate(pitemplate, false)
wscript.echo "... There are " & ajtypes.Count

dim tmp
for each tmp in ajtypes
  if tmp.Name = "CallFlatAdjustment" then
   Set ajtype = tmp
  End If
Next

if ajtype is nothing then
  wscript.echo "CallFlatAdjustment type is not available for " & pitemplate & " pi template"
  return
end if

wscript.echo "creating adjustment transactions"
Set trxset = ajtype.CreateAdjustmentTransactions(sessions)

wscript.echo "Adjustment template id for <" & pitemplate & "> pi template is " & trxset.AdjustmentTemplateID

wscript.echo  "There are " & trxset.GetAdjustmentTransactions().Count & "Transactions selected for adjustment"
for each trx in trxset.GetAdjustmentTransactions()
  'wscript.echo trx.SessionID
  'wscript.echo trx.IsPrebilladjusted
  'wscript.echo trx.IsPostbilladjusted
Next

wscript.echo "setting inputs"
'there is  one required input - Minutes
'the rest is pulled from the product view record
'dim inputs
set inputs = trxset.Inputs
'for each ip in inputs

'  wscript.echo "Input property name: " & ip.Name
'  wscript.echo "Input property  display name: " & ip.DisplayName
'Next

inputs("UnusedPortChargesAdjustmentAmount") = 25
inputs("OverusedPortChargesAdjustmentAmount") = 25
inputs("CancelChargesAdjustmentAmount") = 25
inputs("ReservationChargesAdjustmentAmount") = 25


wscript.echo "calculating adjustments"

dim warnings


Set warnings = trxset.CalculateAdjustments(nothing)

wscript.echo "There were " & warnings.RecordCount & " warnings during calculation"
dumprs(warnings)


dim outputs
dim sess

wscript.echo "Calculated output properties for each session: "
wscript.echo  "There are " & trxset.GetAdjustmentTransactions().Count & "Adjusted Transactions"
for each op in trxset.Outputs
  wscript.echo "Name: " & op.Name & "Value: " & op.Value
Next

wscript.echo "Testing clear outputs bug"

Set warnings = trxset.CalculateAdjustments(nothing)

wscript.echo "There were " & warnings.RecordCount & " warnings during calculation"
dumprs(warnings)


wscript.echo "Calculated output properties for each session: "
wscript.echo  "There are " & trxset.GetAdjustmentTransactions().Count & "Adjusted Transactions"
for each op in trxset.Outputs
  wscript.echo "Name: " & op.Name & "Value: " & op.Value
Next

 
wscript.echo "reason code"
trxset.ReasonCode = trxset.GetApplicableReasonCodes()(1)

wscript.echo "saving adjustments"

trxset.SaveAdjustments(nothing)


wscript.echo "Done with testing flat call calculations"



'for each trx in trxset.GetAdjustmentTransactions()
'  wscript.echo trx.SessionID
'  wscript.echo trx.IsPrebill
'Next

'trxset.Inputs("Minutes") = 5
'trxset.CalculateAdjustments(nothing)

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

