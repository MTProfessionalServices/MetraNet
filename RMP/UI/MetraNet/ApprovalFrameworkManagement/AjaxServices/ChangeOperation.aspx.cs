using System;
using System.ComponentModel;
using System.ServiceModel;
using System.Text;
using MetraTech;
using MetraTech.Account.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Enums;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;
using MetraTech.Approvals;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

public partial class ApprovalFrameworkManagement_AjaxServices_ChangeOperation : MTPage
{
  private string strincomingchangeid;
  private int intincomingchangeid;
  private String strincomingcomment;
  private String strincomingaction;
  private bool UpdatedItemRequested = false;

  protected void SendResult(bool success, string msg, ChangeSummary updatedItem)
  {
    string strResponse = "{success: " + success.ToString().ToLower() + ", message:'" + msg + "'";

    if (updatedItem != null)
    {
      JavaScriptSerializer jss = new JavaScriptSerializer();
      strResponse += ", updatedItem:" + jss.Serialize(updatedItem);
    }

    strResponse += "}";

    Response.Write(strResponse);
    Response.End();
  }

  protected void Page_Load(object sender, EventArgs e)
  {

      strincomingchangeid = Request["changeid"];
      intincomingchangeid = System.Convert.ToInt32(strincomingchangeid);

      strincomingcomment = Request["comment"].ToString();
      strincomingaction = Request["action"].ToString().ToLower();

    if (!string.IsNullOrEmpty(Request["ReturnUpdatedItem"]))
    {
      UpdatedItemRequested = Boolean.Parse(Request["ReturnUpdatedItem"]);
    }

    ChangeSummary updatedItem = null;

    // Now call the operation based on the action 
    try
    {
        ApprovalManagementServiceClient operateonchange = new ApprovalManagementServiceClient();

        operateonchange.ClientCredentials.UserName.UserName = UI.User.UserName;
        operateonchange.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        if (strincomingaction == "approve")
        {
            operateonchange.ApproveChange(intincomingchangeid, strincomingcomment);
        }

        if (strincomingaction == "deny")
        {
            operateonchange.DenyChange(intincomingchangeid, strincomingcomment);
        }
        
        if (strincomingaction == "dismiss")
        {
            operateonchange.DismissChange(intincomingchangeid, strincomingcomment);
        }

        if (strincomingaction == "resubmit")
        {
            MTList<int> mychangeid = new MTList<int>();
            mychangeid.Items.Add(intincomingchangeid);

            operateonchange.ResubmitFailedChanges(mychangeid);
        }

        if (UpdatedItemRequested)
        {
          MTList<ChangeSummary> items = new MTList<ChangeSummary>();
          items.Filters.Add(new MTFilterElement("Id", MTFilterElement.OperationType.Equal, intincomingchangeid));
          operateonchange.GetChangesSummary(ref items);
          if (items.Items.Count == 1)
          {
            updatedItem = items.Items[0];
          }
          else
          {
            throw new Exception("Change Id " + strincomingchangeid + " was updated but the change could not be retrieved. GetChangeSummary returned " + items.Items.Count + " items");
          }
        }
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      Logger.LogException("Change Id " + strincomingchangeid + " failed to " + strincomingaction , ex);
      StringBuilder sb = new StringBuilder();
      foreach (string err in ex.Detail.ErrorMessages)
      {
        sb.Append(err);
        sb.Append("; ");
      }
      //SendResult(false, sb.ToString().Replace("'", "\\'"));
      SendResult(false, sb.ToString().EncodeForJavaScript(), updatedItem);
    }
    catch (Exception ex)
    {
      Logger.LogException("Change Id " + strincomingchangeid + " failed to " + strincomingaction, ex);
      //SendResult(false, ex.Message.Replace("'", "\\'"));
      SendResult(false, ex.Message.EncodeForJavaScript(), updatedItem);
      return;
    }

    SendResult(true, "", updatedItem);
  }
}
