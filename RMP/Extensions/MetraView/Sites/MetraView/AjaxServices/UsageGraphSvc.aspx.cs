using System;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class AjaxServices_UsageGraphSvc : MTPage
{
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
    billManager.ReportParams.ReportView = ReportViewType.Interactive;
    var defaultIntervalSlice = new UsageIntervalSlice { UsageInterval = billManager.GetOpenIntervalWithoutSettingItAsCurrentOnTheUI().ID };
    billManager.ReportParams.DateRange = defaultIntervalSlice;
    billManager.ReportParams.UseSecondPassData = false;  // show first pass data on usage graph
    billManager.GetInvoiceReport(true);

    ReportLevel = billManager.GetByFolderReport((int)UI.Subscriber.SelectedAccount._AccountID, null);

    int acc = 0;
    if (ReportLevel.FolderSlice != null)
    {
      acc = (int) ((PayeeAccountSlice) ReportLevel.FolderSlice).PayeeID.AccountID;
    }

    var sb = new StringBuilder();
    var childrenLevels = new MTList<ReportLevel>();
    childrenLevels.SortCriteria.Add(new SortCriteria("Amount", SortType.Descending));
    
    childrenLevels = billManager.GetByFolderChildrenReport(null, null, 1, 10, childrenLevels);
    sb.Append("{\"TotalRows\":");
    sb.Append(childrenLevels.Items.Count);
    sb.Append(", \"Items\":[ ");

    if(childrenLevels.Items.Count == 0)
    {
      sb.Append("{\"category\":\"");
      sb.Append("No transactions.");
      sb.Append("\",\"total\":");
      sb.Append(0.00);
      sb.Append(",\"totalAsString\":\"");
      sb.Append("");
      sb.Append("\"}");
    }

    int i = 0;
    foreach (var childrenLevel in childrenLevels.Items)
    {
      sb.Append("{\"category\":\"");
      sb.Append(childrenLevel.Name.ToSmallString().Replace("\"", "\\\""));
      sb.Append("\",\"total\":");
      sb.Append(childrenLevel.DisplayAmount);
      sb.Append(",\"totalAsString\":\"");
      sb.Append(childrenLevel.DisplayAmountAsString);
      sb.Append("\"}");
     
      i++;
      if(i < childrenLevels.Items.Count)
        sb.Append(",");
    }
    sb.Append("], \"CurrentPage\":1, \"PageSize\":10, \"SortProperty\":null, \"SortDirection\":\"Ascending\"}");

    Response.Write(sb.ToString());
    Response.End();
  }
}
