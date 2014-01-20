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
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.Common;
using MetraTech.UI.Controls;

public partial class Subscriptions_SelectPO : MTPage
{
  protected override void OnLoadComplete(EventArgs e)
  {
    MTGridDataBindingArgument arg = new MTGridDataBindingArgument("POEffectiveDate", ApplicationTime.ToString());
    this.MyGrid1.DataBinder.Arguments.Add(arg);
    base.OnLoadComplete(e);
  }

}