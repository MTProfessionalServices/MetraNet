dim formula
dim ar
dim ac
Set ar = CreateObject("MetraTech.Adjustments.ApplicabilityRule")
Set ac = CreateObject("MetraTech.Adjustments.AdjustmentCatalog")
Dim pc
Set pc = CreateObject("MetraTech.MTProductCatalog")
Dim login
Set login = CreateObject("Metratech.MTLoginContext")
Dim ctx
set ctx = login.Login("su", "system_user", "su123")


ac.Initialize(ctx)
pc.SetSessionContext(ctx)

dim ajtype
Set ajtype = ac.GetAdjustmentTypeByName("ConnectionMinutesAdjustment")
dim pitype
Set pitype = pc.GetPriceableItemTypeByName("AudioConfConn")



ar.Formula.Text = "CREATE PROCEDURE ApplicabilityRule" & vbNewLine &_
    "--inputs" & vbNewLine &_
    "@id_sess INTEGER" & vbNewLine &_
    "--outputs" & vbNewLine &_
    "@IsApplicable BOOLEAN OUTPUT" & vbNewLine &_
    "AS" & vbNewLine &_
    "DECLARE @sPrebill VARCHAR(1);" & vbNewLine &_
    "SELECT IsPrebillTransaction INTO @sPrebill FROM VW_ADJUSTMENT_SUMMARY" & vbNewLine &_
    "WHERE id_sess = @id_sess" & vbNewLine &_
    "SET @IsApplicable = CASE WHEN (@sPrebill = 'Y') THEN TRUE ELSE FALSE END;"
    
ar.Formula.EngineType = 1
ar.Initialize()


 dim rs
  set rs = CreateObject("MTSQLRowset.MTSqlRowset")
  rs.Init("queries\database")
  rs.SetQueryString "select top 5 * from t_acc_usage au inner join t_pi_template pit" & vbNewLine &_
                    " ON au.id_pi_template = pit.id_template where pit.id_pi = " & pitype.ID
  rs.Execute
  set sessions = CreateObject("MetraTech.MTCollection")
  dim i
  rs.MoveFirst
  for i = 0 to rs.RecordCount -1
    call sessions.Add(CLng(rs.Value("id_sess")))
    rs.MoveNext
  next

Set trxset = ajtype.CreateAdjustmentTransactions(sessions)
wscript.echo trxset.GetAdjustmentTransactions().Count

dim trx
for each trx in trxset.GetAdjustmentTransactions()
 IF (ar.IsApplicable(trx) = true) THEN
  wscript.echo "I am applicable"
 else
  wscript.echo "I am not applicable"
 End if
Next


