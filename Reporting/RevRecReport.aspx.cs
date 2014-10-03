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
    var startDate = DateTime.Today;
    foreach (var cycle in ReportingtHelper.GetAccountingCycles())
    {
      accCycle.Items.Add(new ListItem(cycle.Name, cycle.Id.ToString()));
      if(cycle.IsDefault)
        startDate = ReportingtHelper.GetCycleStartDate(cycle);
    }
    var headers = new string[13];
    for(var i = 0; i < headers.Length; i++)
    {
      headers[i] = startDate.AddMonths(i).ToString("d MMM yyyy", Thread.CurrentThread.CurrentUICulture);
    }
    TableHeaders = String.Join(",", headers);
  }
}
