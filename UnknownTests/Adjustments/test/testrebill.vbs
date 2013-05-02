dim ac
Dim pc
Dim aj


dim proxy
'Set proxy = CreateObject("MetraTech.Adjustments.AdjustmentCatalog")
Set ac = CreateObject("MetraTech.Adjustments.AdjustmentCatalog")
Set pc = CreateObject("MetraTech.MTProductCatalog")

Dim login
Set login = CreateObject("Metratech.MTLoginContext")
Dim ctx
set ctx = login.Login("su", "system_user", "su123")
ac.Initialize(ctx)

'Dim ar
'Set ar = CreateObject("MetraTech.AR.Reporting.PreviousChargesReport")
'ar.Init 123, 23086, 840
'wscript.echo ar.GetPreviousChargesXml()

dim pitype
Set pitype = pc.GetPriceableItemTypeByName("AudioConfCall")

dim rs
  set rs = CreateObject("MTSQLRowset.MTSqlRowset")
  rs.Init("queries\database")
  rs.SetQueryString "select top 1 * from t_acc_usage au inner join t_pi_template pit" & vbNewLine &_
                    " ON au.id_pi_template = pit.id_template where pit.id_pi = " & pitype.ID
  rs.Execute

wscript.echo "creating rebilltransaction"

dim rebilltrx
Set rebillTrx = ac.CreateRebillTransaction(CLng(rs.Value("id_sess")))
wscript.echo "IdentifiedByAccount: " & rebillTrx.IdentifiedByAccount
wscript.echo "IdentifiedByServiceEndpoint: " & rebillTrx.IdentifiedByServiceEndpoint


dim id

wscript.echo " Account Identifiers"
for each id in rebillTrx.AccountIdentifiers
  wscript.echo id.Name
Next

wscript.echo " SE Identifiers"
for each seid in rebillTrx.ServiceEndpointIdentifiers
  wscript.echo seid.Name
Next
dim ids

Set ids = rebillTrx.AccountIdentifiers

wscript.echo "Number of Applicable Reason Codes: " & rebilltrx.GetApplicableReasonCodes().Count

ids("payer") = "boris"
rebillTrx.ReasonCode =  rebilltrx.GetApplicableReasonCodes().Item(1)
' rebillTrx.AccountID = 158
dim dum
set dum = CreateObject("Metratech.adjustments.rebillwriter")
 wscript.echo "Saving async"
' rebillTrx.SaveAsynchronously(nothing)
rebillTrx.Save(nothing)
 wscript.echo "Async Call returned"

while rebilltrx.IsComplete() = false
 wscript.echo "Waiting for work completion"
sleep(2000)

wend


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
