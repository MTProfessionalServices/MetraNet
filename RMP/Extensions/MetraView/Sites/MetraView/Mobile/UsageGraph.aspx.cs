using System;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class AjaxServices_UsageGraph : MTPage
{
  public string ChartData
  {
      get { return ViewState["ChartData"] as string; }
      set { ViewState["ChartData"] = value; }
  }

  public ReportLevel ReportLevel
  {
    get { return ViewState[SiteConstants.ReportLevel] as ReportLevel; }
    set { ViewState[SiteConstants.ReportLevel] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if(UI.Subscriber.SelectedAccount == null)
      return;

    var billManager = new BillManager(UI);
    billManager.ReportParams.ReportView = ReportViewType.OnlineBill;
    var defaultIntervalSlice = new UsageIntervalSlice { UsageInterval = int.Parse(Request["intervalId"]) };
    billManager.ReportParams.DateRange = defaultIntervalSlice;
    billManager.ReportParams.UseSecondPassData = true;  
    billManager.GetInvoiceReport(true);

    ReportLevel = billManager.GetByFolderReport((int)UI.Subscriber.SelectedAccount._AccountID, null);

    int acc = 0;
    if (ReportLevel.FolderSlice != null)
    {
      acc = (int) ((PayerAndPayeeSlice) ReportLevel.FolderSlice).PayerAccountId.AccountID;
    }

    var childrenLevels = new MTList<ReportLevel>();
    childrenLevels.SortCriteria.Add(new SortCriteria("Amount", SortType.Descending));
    
    childrenLevels = billManager.GetByFolderChildrenReport(acc, ReportLevel.AccountEffectiveDate, 1, 10, childrenLevels);
  
    var sb = new StringBuilder();
    foreach (var childrenLevel in childrenLevels.Items)
    {
            sb.Append("['");
            sb.Append(Server.HtmlEncode(childrenLevel.Name.ToSmallString().Replace("\"", "\\\"")));
            sb.Append("', ");
            sb.Append(childrenLevel.DisplayAmount);
            sb.Append("],");
    }
    ChartData = sb.ToString().Trim(new[] { ',' });

  }

}
