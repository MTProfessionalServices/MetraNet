using System;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Approvals;
using MetraTech.Approvals.ChangeTypes;

public partial class ApprovalFrameworkManagement_ViewSubscriptionChangeDetails : MTPage
{
  public int ChangeId { get; set; }
  public string ChangeType { get; set; }

  #region Event Listeners

  protected void Page_Load(object sender, EventArgs e)
  {
    ChangeId = Convert.ToInt32(Request.QueryString["changeid"]);
    var currState = Request.QueryString["currentstate"];

    var subStored = GetSubscritionByChangeId(ChangeId);
    // [TODO] Retrieve the change not the sub object
    SubscriptionChange subChange;

    if (subStored.SubscriptionId.HasValue)
    {
      // update
      ChangeType = "UPDATE";
    }
    else
    {
      // new subscription
      ChangeType = "NEW";
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    Response.Write("<div id='xmlPretty' class='x-hide-display'>" + ChangeType + "</div>");
    Response.Write("<div id='xmlRaw' class='x-hide-display'><textarea rows='20' cols='80'>" + ChangeType + "</textarea>" +
                   "</div>");

    base.OnLoadComplete(e);
  }

  #endregion

  #region Private Methods

  private Subscription GetSubscritionByChangeId(int changeId)
  {
    var changeDetailsIn = new ChangeDetailsHelper();
    var changeDetailsString = String.Empty;

    using (var client = new ApprovalManagementServiceClient())
    {
      SetCredantional(client.ClientCredentials);
      client.GetChangeDetails(changeId, ref changeDetailsString);
    }

    changeDetailsIn.FromBuffer(changeDetailsString);
    return changeDetailsIn[SubscriptionChangeType.SubscriptionKey] as Subscription;
  }
  
  private void SetCredantional(System.ServiceModel.Description.ClientCredentials clientCredentials)
  {
    if (clientCredentials == null)
      throw new InvalidOperationException("Client credentials is null");

    clientCredentials.UserName.UserName = UI.User.UserName;
    clientCredentials.UserName.Password = UI.User.SessionPassword;
  }
  
  #endregion
}

