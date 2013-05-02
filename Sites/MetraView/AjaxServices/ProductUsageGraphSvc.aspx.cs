using System;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class AjaxServices_ProductUsageGraphSvc : MTPage
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

    ReportLevel = billManager.GetByProductReport();

    var count = 0;
    if (ReportLevel.ProductOfferings != null)
    {
      count += ReportLevel.ProductOfferings.Count;
    }
    if(ReportLevel.Charges != null)
    {
      count += ReportLevel.Charges.Count;
    }

    var sb = new StringBuilder();
    sb.Append("{\"TotalRows\":");
    sb.Append(count);
    sb.Append(", \"Items\":[ ");

    if (ReportLevel.ProductOfferings == null && ReportLevel.Charges == null)
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
    if (ReportLevel.ProductOfferings != null && ReportLevel.ProductOfferings.Count > 0)
    {
      foreach (var reportProductOffering in ReportLevel.ProductOfferings)
      {
        if (reportProductOffering.Charges != null && reportProductOffering.Charges.Count > 0)
        {
          foreach (var charge in reportProductOffering.Charges)
          {
            sb.Append("{\"category\":\"");
            sb.Append(charge.DisplayName.ToSmallString().Replace("\"", "\\\""));
            sb.Append("\",\"total\":");
            sb.Append(charge.Amount);
            sb.Append(",\"totalAsString\":\"");
            sb.Append(charge.AmountAsString);
            sb.Append("\"}");

            i++;
            if (i < ReportLevel.ProductOfferings.Count)
              sb.Append(",");
          }
        }
      }
    }

    if (ReportLevel.Charges != null && ReportLevel.Charges.Count > 0)
    {
      if (ReportLevel.ProductOfferings != null && ReportLevel.ProductOfferings.Count > 0)
      {
        sb.Append(",");
      }
      i = 0;
      foreach (var charge in ReportLevel.Charges)
      {
        sb.Append("{\"category\":\"");
        sb.Append(charge.DisplayName.ToSmallString().Replace("\"", "\\\""));
        sb.Append("\",\"total\":");
        sb.Append(charge.Amount);
        sb.Append(",\"totalAsString\":\"");
        sb.Append(charge.AmountAsString);
        sb.Append("\"}");

        i++;
        if (i < ReportLevel.Charges.Count)
          sb.Append(",");
      }
    }

    sb.Append("], \"CurrentPage\":1, \"PageSize\":10, \"SortProperty\":null, \"SortDirection\":\"Ascending\"}");

    Response.Write(sb.ToString());
    Response.End();
  }
}
