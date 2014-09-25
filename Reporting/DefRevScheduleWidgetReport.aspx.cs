using System;
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
    applyBtn.Text = GetLocalResourceObject("ApplyFilterBtn_Caption").ToString();
  }

  private static ListItem[] GetCycles()
  {
    //return new[] { new ListItem {Text = "31 Monthly", Value = "31Monthly", Selected = true},
    //                                    new ListItem() {Text = "15 Monthly", Value = "15Monthly"}
    //                                  };
    return ReportingtHelper.GetAccountingCycles().Select(x => new ListItem(x.Value, x.Key)).ToArray();
  }


  private static ListItem[] GetCurrencies()
  {
    //return new[] { new ListItem() {Text = "USD", Value = "USD", Selected = true},
    //               new ListItem() {Text = "JPY", Value = "JPY"}
    //             };
    return ReportingtHelper.GetCurrencies().Select(x => new ListItem(x)).ToArray();
  }

}
