using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Common;

public partial class AccountNavigation : MTPage
{
  protected override void OnLoadComplete(EventArgs e)
  {
    GridRenderer.AddAccountTypeFilter(MyGrid1);
    GridRenderer.AddPriceListFilter(MyGrid1, UI);
    base.OnLoadComplete(e);
  }
}
