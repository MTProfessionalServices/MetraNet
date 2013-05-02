dim ac
dim pc
Dim aj

Set ac = CreateObject("MetraTech.Adjustments.AdjustmentCatalog")
Set pc = CreateObject("MetraTech.MTProductCatalog")
Dim login
Set login = CreateObject("Metratech.MTLoginContext")
Dim ctx
set ctx = login.Login("su", "system_user", "su123")

ac.Initialize(ctx)
pc.SetSessionContext(ctx)

wscript.echo "Testing Percent adjustment for conference call"

Dim ajtype
Dim pitype
dim trxset
Set ajtype = ac.GetAdjustmentTypeByName("CallPercentAdjustment")
Set pitype = pc.GetPriceableItemTypeByName("AudioConfCall")
wscript.echo "get transaction records for 1 parent record"

Dim trxs
Dim sessions
Set sessions = CreateObject("MetraTech.MTCollection")
dim rs
  set rs = CreateObject("MTSQLRowset.MTSqlRowset")
  rs.Init("queries\database")
  rs.SetQueryString "select top 1 * from t_acc_usage au inner join t_pi_template pit" & vbNewLine &_
                    " ON au.id_pi_template = pit.id_template where pit.id_pi = " & pitype.ID
  rs.Execute
  set sessions = CreateObject("MetraTech.MTCollectionEx")
  dim i
  rs.MoveFirst
  for i = 0 to rs.RecordCount -1
    call sessions.Add(CLng(rs.Value("id_sess")))
    rs.MoveNext
  next

'get three connections

wscript.echo "creating adjustment transactions"
Set trxset = ajtype.CreateAdjustmentTransactions(sessions)


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

inputs("UnusedPortChargesPercent") = 10
inputs("OverusedPortChargesPercent") = 10
inputs("CancelChargesPercent") = 10
inputs("ReservationChargesPercent") = 10


wscript.echo "calculating adjustments"

Set warnings = trxset.CalculateAdjustments(nothing)

wscript.echo "There were " & warnings.RecordCount & " warnings during calculation"
dumprs(warnings)

wscript.echo "Calculated output properties for each session: "
wscript.echo  "There are " & trxset.GetAdjustmentTransactions().Count & "Adjusted Transactions"
for each sess in trxset.GetAdjustmentTransactions()
  if (sess.IsAdjustable = true) Then
    wscript.echo "Session With ID " & sess.SessionID
    set outputs = sess.Outputs
    for each op in outputs
      wscript.echo "Name: " & op.Name & "Value: " & op.Value
    Next
  End If
Next



 
wscript.echo "saving adjustments"

trxset.SaveAdjustments(nothing)



wscript.echo "Done with Call"



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
