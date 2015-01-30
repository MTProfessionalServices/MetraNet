using System;
using System.Web;
using MetraTech.UI.Common;
using MetraTech.DomainModel.ProductCatalog;

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
    string replaceWith = Convert.ToString('"');
    if (PageNav.Data == null)
      return;

    var groupSubscription = PageNav.Data.Out_StateInitData["CurrentGroupSubscription"] as GroupSubscription;
    if (groupSubscription == null || groupSubscription.GroupId == null)
      return;

    CurrentGroupSubscription = groupSubscription;
    GroupSubMemGrid.Title = HttpUtility.HtmlEncode(String.Format((string)GetLocalResourceObject("Grid.Title"), CurrentGroupSubscription.Name).Replace("'", replaceWith));
    
    GroupSubMemGrid.Elements[0].IsColumn = true;
  }
}
