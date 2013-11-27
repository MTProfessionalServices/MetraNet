using System;
using System.Collections.Generic;
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
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Controls;


public partial class GroupSubscriptions_GroupSubscriptionMembers : MTPage
{
  public string MetraTimeNow
  {
    get { return ApplicationTime.ToShortDateString(); }
  }

  public GroupSubscription CurrentGroupSubscription
  {
    get { return ViewState["CurrentGroupSubscription"] as GroupSubscription; }
    set { ViewState["CurrentGroupSubscription"] = value; }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    if (PageNav.Data != null)
    {
      CurrentGroupSubscription = PageNav.Data.Out_StateInitData["CurrentGroupSubscription"] as GroupSubscription;
      this.GroupSubMemGrid.Title = HttpUtility.HtmlEncode(String.Format((string)GetLocalResourceObject("Grid.Title"), CurrentGroupSubscription.Name).Replace("'", "\\'"));
      this.GroupSubMemGrid.Elements[0].IsColumn = true;
    }
  }

}
