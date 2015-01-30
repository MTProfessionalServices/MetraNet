using System;
using System.Text;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;

public partial class UserControls_ProductUsageGraph : System.Web.UI.UserControl
{
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }

  public string ChartData
  {
    get { return ViewState["ChartData"] as string; }
    set { ViewState["ChartData"] = value; }
  }

  public string ChartLabels
  {
    get { return ViewState["ChartLabels"] as string; }
    set { ViewState["ChartLabels"] = value; }
  }

  public ReportLevel ReportLevel
  {
    get { return ViewState[SiteConstants.ReportLevel] as ReportLevel; }
    set { ViewState[SiteConstants.ReportLevel] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (UI.Subscriber.SelectedAccount == null)
      return;

    var billManager = new BillManager(UI);
    billManager.ReportParams.ReportView = ReportViewType.Interactive;

    // ESR-5331 - UDRCs error MetraView
    // Checking for null was added.
    Interval openedInterval = billManager.GetOpenIntervalWithoutSettingItAsCurrentOnTheUI();
	if (openedInterval == null)
	{
		return;
	}

    var defaultIntervalSlice = new UsageIntervalSlice { UsageInterval = openedInterval.ID };
    billManager.ReportParams.DateRange = defaultIntervalSlice;
    billManager.ReportParams.UseSecondPassData = false;  // show first pass data on usage graph
    billManager.GetInvoiceReport(true);

    ReportLevel = billManager.GetByProductReport();
    if (ReportLevel == null) return;

    var count = 0;
    if (ReportLevel.ProductOfferings != null)
    {
      count += ReportLevel.ProductOfferings.Count;
    }
    if (ReportLevel.Charges != null)
    {
      count += ReportLevel.Charges.Count;
    }

    var sb = new StringBuilder();
    var sbLabels = new StringBuilder();

    int i = 0;
    if (ReportLevel.ProductOfferings != null && ReportLevel.ProductOfferings.Count > 0)
    {
      foreach (var reportProductOffering in ReportLevel.ProductOfferings)
      {
        if (reportProductOffering.Charges != null && reportProductOffering.Charges.Count > 0)
        {
          foreach (var charge in reportProductOffering.Charges)
          {
            sbLabels.Append("'");
            sbLabels.Append(charge.DisplayName.Replace("\"", "\\\"").Replace("'", "\'"));
            sbLabels.Append("'");
            sb.Append(charge.DisplayAmount.ToString().Replace(",","."));

            sbLabels.Append(",");
            sb.Append(",");
            i++;
          }
        }
      }
    }

    if (ReportLevel.Charges != null && ReportLevel.Charges.Count > 0)
    {
      i = 0;
      foreach (var charge in ReportLevel.Charges)
      {
        sbLabels.Append("'");
        sbLabels.Append(charge.DisplayName.Replace("\"", "\\\"").Replace("'", "\'"));
        sbLabels.Append("'");
        sb.Append(charge.DisplayAmount.ToString().Replace(",", "."));

        sbLabels.Append(",");
        sb.Append(",");
        i++;
      }
    }

    ChartData = sb.ToString().Trim(new[] { ',' });
    ChartLabels = sbLabels.ToString().Trim(new[] { ',' });

    // Any cached user control (i.e., with an OutputCache directive) that should NOT be cached 
    // while in DemoMode should call DisableUserControlCachingInDemoMode() at the end of Page_Load().
    WebUtils.DisableUserControlCachingInDemoMode(this);
  }

  protected string GetGraphText()
  {
    var sb = new StringBuilder();
    sb.Append("<div><p>");
    sb.Append(GetLocalResourceObject("ProductUsageGraphText.Text"));
    sb.Append(" <a href=\"Usage.aspx?view=summary\">");
    sb.Append(GetLocalResourceObject("Here.Text"));
    sb.Append("</a>");
    sb.Append(GetLocalResourceObject("Period.Text"));
    sb.Append("</p></div>");
    return sb.ToString().Replace("'", "\\'");
  }
}
