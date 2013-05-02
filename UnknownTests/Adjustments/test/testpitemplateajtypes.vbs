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

wscript.echo "Testing calculation for parent adjustment types"



wscript.echo "Testing minutes adjustment for conference leg"

Dim ajtype
Dim pitype
dim trxset
Set pitype = pc.GetPriceableItemTypeByName("AudioConfCall")

Dim trxs
Dim sessions

  dim rs
  set rs = CreateObject("MTSQLRowset.MTSqlRowset")
  rs.Init("queries\database")
  rs.SetQueryString "select top 1 * from t_pi_template pit where pit.id_pi = " & pitype.ID
  rs.Execute
  set sessions = CreateObject("MetraTech.MTCollectionEx")
  dim i
  rs.MoveFirst

dim ajtypes

Set ajtypes = ac.GetAdjustmentTypesForPITemplate(rs.Value("id_template"), false)

for each ajtype in ajtypes
	wscript.echo ajtype.Name
Next


