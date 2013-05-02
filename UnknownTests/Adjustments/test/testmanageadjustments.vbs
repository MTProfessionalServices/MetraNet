dim ac
dim pc
Dim aj

Set ac = CreateObject("MetraTech.Adjustments.AdjustmentCatalog")
Set pc = CreateObject("MetraTech.MTProductCatalog")

Dim login
Set login = CreateObject("Metratech.MTLoginContext")
Dim ctx
' set ctx = login.Login("su", "system_user", "su123")
set ctx = login.Login("jcsr", "system_user", "csr123")

ac.Initialize(ctx)
pc.SetSessionContext(ctx)


Dim ajtype
Dim pitype
dim trxset
dim rs
Set ajtype = ac.GetAdjustmentTypeByName("ConnectionFlatAdjustment")
Set pitype = pc.GetPriceableItemTypeByName("AudioConfConn")


wscript.echo "selecting adjusted records"
Set rs = ac.GetAdjustedTransactionsAsRowset(nothing)
dumprs(rs)

Dim trxs
Dim sessions

  
  set rs = CreateObject("MTSQLRowset.MTSqlRowset")
  rs.Init("queries\database")
  rs.SetQueryString "select top 5 * from t_acc_usage au inner join t_pi_template pit" & vbNewLine &_
                    " ON au.id_pi_template = pit.id_template where pit.id_pi = " & pitype.ID
  rs.Execute
  set sessions = CreateObject("MetraTech.MTCollectionEx")
  dim i
  rs.MoveFirst
  for i = 0 to rs.RecordCount -1
    call sessions.Add(CLng(rs.Value("id_sess")))
    rs.MoveNext
  next


'wscript.echo "approving adjustments"

'Set trxset = ac.CreateAdjustmentTransactions(sessions)
'set rs = trxset.ApproveAndSave(nothing)
'dumprs(rs)


wscript.echo "deleting adjustments"

Set trxset = ac.CreateAdjustmentTransactions(sessions)
set rs = trxset.DeleteAndSave(nothing)
dumprs(rs)




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
	if(rs.RecordCount > 0) then
	rs.MoveFirst()
	end if
end function
