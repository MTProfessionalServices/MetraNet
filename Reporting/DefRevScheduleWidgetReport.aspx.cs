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
    if (IsPostBack) return;
    accntCycleDd.Label = GetLocalResourceObject("AccountCycle_Caption").ToString();
    accntCycleDd.Items.AddRange(GetCycles());
    currencyDd.Label = GetLocalResourceObject("Currency_Caption").ToString();
    currencyDd.Items.AddRange(GetCurrencies());
    productDd.Label = GetLocalResourceObject("Product_Caption").ToString();
    productDd.Items.Add(new ListItem(GetLocalResourceObject("Option_All_Text").ToString(), "0"));
    productDd.Items.AddRange(GetProducts());
    applyBtn.Text = GetLocalResourceObject("ApplyFilterBtn_Caption").ToString();
  }

  private static ListItem[] GetCycles()
  {
    //return new[] { new ListItem {Text = "Monthly 31", Value = "31Monthly", Selected = true},
    //                                    new ListItem() {Text = "Monthly 15", Value = "15Monthly"}
    //                                  };
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
