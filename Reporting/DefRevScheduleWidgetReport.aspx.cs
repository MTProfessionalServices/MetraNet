using System;
using System.Globalization;
using System.Web.UI.WebControls;
using System.Linq;
using MetraNet;
using MetraTech.UI.Common;

public partial class DefRevScheduleWidgetReport : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Create CSR Accounts"))
      Response.End();

    if (IsPostBack) return;
    accntCycleDd.Label = GetGlobalResourceObject("Reports", "TEXT_ACCOUNTING_CYCLE").ToString();
    accntCycleDd.Items.AddRange(GetCycles());
    currencyDd.Label = GetGlobalResourceObject("Reports", "TEXT_CURRENCY").ToString();
    currencyDd.Items.AddRange(GetCurrencies());
    revCodeInp.Label = GetGlobalResourceObject("Reports", "TEXT_REVENUE_CODE").ToString();
    defRevCodeInp.Label = GetGlobalResourceObject("Reports", "TEXT_DEFERRED_REVENUE_CODE").ToString();
    productDd.Label = GetGlobalResourceObject("Reports", "TEXT_PRICEABLE_ITEM").ToString();
    productDd.Items.Add(new ListItem(GetLocalResourceObject("Option_All_Text").ToString(), "0"));
    productDd.Items.AddRange(GetProducts());
    applyBtn.Text = GetLocalResourceObject("ApplyFilterBtn_Caption").ToString();
  }

  private static ListItem[] GetCycles()
  {
    return ReportingtHelper.GetAccountingCycles().Select(x => new ListItem(x.Name, x.Id.ToString())).ToArray();
  }

  private static ListItem[] GetCurrencies()
  {
    return ReportingtHelper.GetCurrencies().Select(x => new ListItem(x)).ToArray();
  }

  private static ListItem[] GetProducts()
  {
    return ReportingtHelper.GetProducts().Select(x => new ListItem(x.Value, x.Key.ToString(CultureInfo.InvariantCulture))).ToArray();
  }
}
