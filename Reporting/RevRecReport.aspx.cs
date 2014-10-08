using System;
using System.Linq;
using MetraTech.UI.Common;
using MetraNet;

/// <summary>
/// 
/// </summary>
public partial class RevRecReport : MTPage
{
  public string TableHeaders { get; private set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (IsPostBack) return;
    var cycle = ReportingtHelper.GetAccountingCycles().FirstOrDefault(x => x.IsDefault);
    var accountCycleId = cycle == null ? String.Empty : cycle.Id.ToString();
    TableHeaders = String.Join(",", ReportingtHelper.GetRevRecReportHeaders(accountCycleId));
  }
}
