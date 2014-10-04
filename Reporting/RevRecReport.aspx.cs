using System;
using System.Threading;
using System.Web.UI.WebControls;
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
    var accountCycleId = "";
    foreach (var cycle in ReportingtHelper.GetAccountingCycles())
    {
      accCycle.Items.Add(new ListItem(cycle.Name, cycle.Id.ToString()));
      if(cycle.IsDefault)
        accountCycleId = cycle.Id.ToString();
    }
    if (String.IsNullOrEmpty(accountCycleId))
      accountCycleId = accCycle.Items[0].Value;
    TableHeaders = String.Join(",", ReportingtHelper.GetRevRecReportHeaders(accountCycleId));
  }
}
