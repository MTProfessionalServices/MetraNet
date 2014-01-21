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

    protected override void OnLoadComplete(EventArgs e)
    {
        //GroupSubscriptionChangeDetails.Title = "This Change is in " + strcurrentstate + " State";

        //Response.Write("<b>Default Dump Of Change Details From Database</b><br>");
        //Response.Write("<textarea rows='20' cols='100'>" + GetChangeDetails(iChangeId) + "</textarea>");

        base.OnLoadComplete(e);
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!UI.CoarseCheckCapability("Allow ApprovalsView"))
          Response.End();

        strchangeid = Request.QueryString["changeid"];
        iChangeId = Convert.ToInt32(strchangeid);
        Session["intchangeid"] = iChangeId;

        //strcurrentstate = Request.QueryString["currentstate"];
        //strincomingshowchangestate = Request.QueryString["showchangestate"];

    }

    protected string GetChangeDetails(int changeId)
    {
      ApprovalManagementServiceClient client = null;
      string gschangedetailsblob = String.Empty;
      string retVal = gschangedetailsblob;
      try
      {
        client = new ApprovalManagementServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;


        ///*string gschangedetailsblob = String.Empty;*/
        client.GetChangeDetails(changeId, ref gschangedetailsblob);
        retVal = gschangedetailsblob;
        //ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
        //changeDetailsIn.KnownTypes.AddRange(MetraTech.DomainModel.BaseTypes.Account.KnownTypes());
        //changeDetailsIn.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.ProductOffering));
        //changeDetailsIn.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember));
        //changeDetailsIn.KnownTypes.Add(typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>));
        //changeDetailsIn.KnownTypes.Add(typeof(Dictionary<AccountIdentifier, MetraTech.DomainModel.ProductCatalog.AccountTemplateScope>));
        //changeDetailsIn.KnownTypes.Add(typeof(AccountIdentifier));
        //changeDetailsIn.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.AccountTemplateScope));
        //changeDetailsIn.KnownTypes.Add(typeof(ProdCatTimeSpan));
        //changeDetailsIn.FromXml(gschangedetailsblob);

        //// Once you get the change details blob, you can now parse it for the property name and updated value, Key-Value Pair. 
        //Object o = changeDetailsIn["groupSubscriptionId"];
        //int gsId = (int)o;
        //o = changeDetailsIn["accounts"];
        //var accounts = o as Dictionary<AccountIdentifier, MetraTech.DomainModel.ProductCatalog.AccountTemplateScope>;
        //foreach (var pair in accounts)
        //{
        //  retVal += pair.Key.AccountID.ToString() + ",";
        //}
        //o = changeDetailsIn["subscriptionSpan"];
        //ProdCatTimeSpan timeSpan = o as ProdCatTimeSpan;

        //client.Close();
      }
      catch (Exception ex)
      {
        if (client != null)
        {
          client.Abort();
        }
        return "An unknown exception occurred. Please check system logs: " + ex;
      }

      return retVal;
    }
}