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
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.UI.Controls;
using System.Globalization;
using System.Reflection;
using System.Resources;
using System.Collections.Generic;

using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Approvals;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;

public partial class ApprovalFrameworkManagement_ViewGroupSubscriptionMemberUpdateDetails : MTPage
{

    public string strchangeid { get; set; }
    public int iChangeId { get; set; }
    public string strcurrentstate { get; set; }
    public string strincomingshowchangestate { get; set; }   
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UI.CoarseCheckCapability("Allow ApprovalsView"))
          Response.End();

        strchangeid = Request.QueryString["changeid"];
        iChangeId = Convert.ToInt32(strchangeid);
        Session["intchangeid"] = iChangeId;
    }
    protected override void OnLoadComplete(EventArgs e)
    {
      GroupSubscriptionChangeDetails.Title = Request.QueryString["changetype"];
      base.OnLoadComplete(e);
    }  
    protected string GetChangeDetails(int changeId)
    {
      ApprovalManagementServiceClient client = null;
      
      string retVal = String.Empty;
      bool gotException = true;
      try
      {
        client = new ApprovalManagementServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        client.GetChangeDetails(changeId, ref retVal);

        ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
        changeDetailsIn.FromBuffer(retVal);

        return changeDetailsIn.ToStringDictionary();
      }
      catch (Exception ex)
      {       
        gotException = true;
        return "An unknown exception occurred.  Please check system logs: " + ex;
        throw;
      }
      finally
      {
        if (client != null)
        {
          if (gotException)
            client.Abort();
          else
            client.Close();
        }
      }

    }
}