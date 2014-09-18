using System;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;

public partial class UserControls_UsageGraph : System.Web.UI.UserControl
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

    if (UI.Subscriber.SelectedAccount._AccountID != null)
      ReportLevel = billManager.GetByFolderReport(UI.Subscriber.SelectedAccount._AccountID, null);

    int? acc = null;
    var slice = ReportLevel.FolderSlice as PayeeAccountSlice;
    if (slice != null)
    {
      var accountId =  slice.PayeeID.AccountID;
      if (accountId != null)
        acc = accountId;
    }

    var childrenLevels = new MTList<ReportLevel>();
    var sortCriteria = new SortCriteria("Amount", SortType.Descending);
    childrenLevels.SortCriteria.Add(sortCriteria);

    childrenLevels = billManager.GetByFolderChildrenReport(acc, ReportLevel.AccountEffectiveDate, 1, 5, childrenLevels);
    
    var sb = new StringBuilder();

    foreach (var childrenLevel in childrenLevels.Items)
    {
      sb.Append("['");
      // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
      // Added JavaScript encoding
      //sb.Append(Server.HtmlEncode(childrenLevel.Name.ToSmallString().Replace("\"", "\\\"").Replace("'", "\\'") + " " + childrenLevel.DisplayAmountAsString.Replace(" ", "")));
      sb.Append((childrenLevel.Name.ToSmallString().EncodeForJavaScript() + " " + childrenLevel.DisplayAmountAsString.Replace(" ", "")));
      sb.Append("', ");
      sb.Append(childrenLevel.DisplayAmount.ToString().Replace(",", "."));
      sb.Append("],");
    }
    ChartData = sb.ToString().Trim(new[] { ',' });

    // Any cached user control (i.e., with an OutputCache directive) that should NOT be cached 
    // while in DemoMode should call DisableUserControlCachingInDemoMode() at the end of Page_Load().
    WebUtils.DisableUserControlCachingInDemoMode(this);
  }

  protected string GetGraphText()
  {
    var sb = new StringBuilder();
    sb.Append("<div><p>");
    sb.Append(GetLocalResourceObject("UsageGraphText.Text"));
    sb.Append(" <a href=\"Usage.aspx?view=details\">");
    sb.Append(GetLocalResourceObject("HereText.Text"));
    sb.Append("</a>");
    sb.Append(GetLocalResourceObject("Period.Text"));
    sb.Append("</p></div>");
    return sb.ToString().Replace("'", "\\'");
  }


}
