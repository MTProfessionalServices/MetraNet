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

dim id
for each id in rebillTrx.AccountIdentifiers
  wscript.echo id.Name
Next

dim ids

Set ids = rebillTrx.AccountIdentifiers

ids("payer") = "demo"
rebillTrx.Save(nothing)
