using System;
using System.ServiceModel;
using System.Web.Security;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTServerAccess;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;

public partial class SelectBillEntryPoint : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      string selector = Request["Redirect"];
      string userName = "";
      string nameSpace = "";
      string ownerUserName = "";

      // ticket into the desired account via the auth service.  If we are ticketing into the user,
      // then use the owner credentials.  If we are going back to the select bill, then use superuser.
      AuthServiceClient client = new AuthServiceClient();
      if (!String.IsNullOrEmpty(selector))
      {
        string[] ownerDetails = ((string) Session["IsOwner"]).Split(':');
        userName = ownerDetails[0];
        nameSpace = ownerDetails[1];
        IMTServerAccessDataSet sa = new MTServerAccessDataSet();
        sa.Initialize();
        IMTServerAccessData suCredentials = sa.FindAndReturnObject("SuperUser");
        client.ClientCredentials.UserName.UserName = suCredentials.UserName;
        client.ClientCredentials.UserName.Password = suCredentials.Password;
        
        ownerUserName = userName;
      }
      else
      {
        ownerUserName = UI.User.UserName;
        userName = Request["UserName"];
        nameSpace = Request["NameSpace"];
        client.ClientCredentials.UserName.UserName = ownerUserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;        
      }

      string sessionContext = "";
      string ticket = "";

      try
      {
        client.TicketToAccountWithAdditionalData(nameSpace, userName, 20, ownerUserName, "MetraView", out ticket, out sessionContext);
        IMTSessionContext context = new MTSessionContext();
        context.FromXML(sessionContext);

        // reset ui as we are coming in as the new user now
        UI = new UIManager();
        // Setup user data
        UI.User.UserName = userName;
        UI.User.NameSpace = nameSpace;
        UI.User.AccountId = context.AccountID;
        UI.User.SessionContext = context;
        UI.User.Ticket = ticket;
        
        // Load the logged in account as the subscriber
        Account acc = AccountLib.LoadAccount(UI.User.AccountId, UI.User, MetraTech.MetraTime.Now);
        if (acc != null)
        {
          UI.Subscriber.SelectedAccount = acc;
        }

        // Load User Profile (SiteConfig.Profile)
        Session["UserProfile"] = BusinessEntityHelper.LoadUserProfile(acc);

        // Logon was valid.
        FormsAuthentication.SetAuthCookie(Request.ApplicationPath + userName, false);
        Logger.LogInfo(String.Format("{0} logged into {1}.", userName, Request.ApplicationPath));
        Auditor auditor = new Auditor();
        auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_LOGIN_SUCCESS,
                              context.AccountID,
                              (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                              -1,
                              String.Format("Login successful for username={0} namespace={1}", userName, nameSpace),
                              context.LoggedInAs,
                              context.ApplicationName);

        Session["Username"] = userName;

        ClearSessionData(userName, nameSpace, context);
        // Logon was valid.
        Session["IsTicketed"] = true;
        FormsAuthentication.SetAuthCookie(userName, false);
        Logger.LogDebug("Account " + UI.User.AccountId.ToString() + " logged into MetraNet.");

        if (String.IsNullOrEmpty(selector))
          Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());
        else
          Response.Redirect(UI.DictionaryManager["SelectBillPage"].ToString());

        Session[SiteConstants.ActiveMenu] = "Home";
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        lblErrorMessage.Text = ex.Detail.ErrorMessages[0];
      }
      catch (Exception exp)
      {
        lblErrorMessage.Text = exp.Message;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }      
    }

    private void ClearSessionData(string userName, string nameSpace, IMTSessionContext sessionContext)
    {
      Session[SiteConstants.View] = null;
      Session[SiteConstants.ActiveMenu] = null;
      Session[SiteConstants.StartDate] = null;
      Session[SiteConstants.EndDate] = null;
      Session[SiteConstants.Intervals] = null;
      Session[SiteConstants.IntervalQueryString] = null;
      Session[SiteConstants.Interval] = null;
      Session[SiteConstants.SelectedIntervalId] = null;
      Session[SiteConstants.ReportParameters] = null;
      Session[SiteConstants.InvoiceReport] = null;
      Session[SiteConstants.DefaultInvoiceReport] = null;
      Session[SiteConstants.Payment] = null;
      Session[SiteConstants.ReportLevel] = null;
      Session[SiteConstants.ReportView] = null;
      Session[SiteConstants.InvoiceAccount] = null;
      Session[SiteConstants.REPORT_DICTIONARY] = null;
      Session[SiteConstants.LocaleTransator] = null;
      Session[SiteConstants.LastActiveInterval] = null;
      Session[SiteConstants.PaymentInformation] = null;
      Session[SiteConstants.OwnedAccount] = null;
    }
}