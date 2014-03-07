using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using MetraTech.UI.Common;
using MetraTech.UI.Controls;


public partial class Adjustments_ViewCreditNotesIssued : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {

  }

  protected override void OnLoadComplete(EventArgs e)
  {
    string accountsFilterValue = Request["Accounts"];

    if (!String.IsNullOrEmpty(accountsFilterValue))
    {
      if (accountsFilterValue == "ALL")
        MTFilterGrid1.DataSourceURL =
          @"/MetraNet/Adjustments/AjaxServices/LoadCreditNotesIssued.aspx?Accounts=ALL";
    }
  }
}