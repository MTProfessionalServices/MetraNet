using System;
using System.Text;
using MetraTech;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.Accounts.Type;
using MetraTech.Interop.MTYAAC;
using YAAC = MetraTech.Interop.MTYAAC;
using IMTSessionContext = MetraTech.Interop.MTProductCatalog.IMTSessionContext;
using IMTAccountType = MetraTech.Interop.IMTAccountType.IMTAccountType;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.ActivityServices.Common;
using System.Reflection;
using System.Collections.Generic;

public partial class UserControls_PayerInfo : System.Web.UI.UserControl
{
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }

  public InvoiceReport invoiceReport
  {
    get { return ViewState[SiteConstants.InvoiceReport] as InvoiceReport; }
    set { ViewState[SiteConstants.InvoiceReport] = value; }
  }

  public InvoiceAccount invoiceAccount
  {
    get { return ViewState[SiteConstants.InvoiceAccount] as InvoiceAccount; }
    set { ViewState[SiteConstants.InvoiceAccount] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (SiteConfig.Settings.BillSetting.AllowSelfCare == false)
    {
      CorpEditPanel.Visible = false;
    }

    if (!IsPostBack)
    {
      var billManger = new BillManager(UI);
      if (billManger.InvoiceReport == null)
      {
        invoiceReport = billManger.GetInvoiceReport(true);
      }
      else
      {
        invoiceReport = billManger.InvoiceReport;
      }
      if(invoiceReport != null)
        invoiceAccount = invoiceReport.InvoiceHeader.PayeeAccount;

      /*
      AccountTypeManager accountTypeManager = new AccountTypeManager();
      MTYAAC yaac = new MTYAAC();
      yaac.InitAsSecuredResource((int)UI.Subscriber.SelectedAccount._AccountID,
                                 (MetraTech.Interop.MTYAAC.IMTSessionContext)UI.SessionContext,
                                 MetraTime.Now);
      IMTAccountType accType = accountTypeManager.GetAccountTypeByID((IMTSessionContext)UI.SessionContext,
                                                                     yaac.AccountTypeID);

      // Corporate accounts need the update capability for the account info menu option
      if (accType.IsCorporate)
      {
        if (!UI.CoarseCheckCapability("Update corporate accounts"))
        {
          CorpEditPanel.Visible = false;
        }
      }
      */ 
    }
  }

  protected string GetPayingAccountAddress()
  {
    var sb = new StringBuilder();
    if (invoiceAccount != null)
    {
      sb.Append(String.IsNullOrEmpty(invoiceAccount.FirstName) ? "" : Server.HtmlEncode(invoiceAccount.FirstName) + "&nbsp;");
      sb.Append(String.IsNullOrEmpty(invoiceAccount.MiddleInitial) ? "" : Server.HtmlEncode(invoiceAccount.MiddleInitial) + "&nbsp;");
      sb.Append(String.IsNullOrEmpty(invoiceAccount.LastName) ? "" : Server.HtmlEncode(invoiceAccount.LastName) + "<br />");
      sb.Append(String.IsNullOrEmpty(invoiceAccount.Company) ? "" : Server.HtmlEncode(invoiceAccount.Company) + "<br />");
      sb.Append(String.IsNullOrEmpty(invoiceAccount.Address1) ? "" : Server.HtmlEncode(invoiceAccount.Address1) + "<br />");
      sb.Append(String.IsNullOrEmpty(invoiceAccount.Address2.Trim()) ? "" : Server.HtmlEncode(invoiceAccount.Address2) + "<br />");
      sb.Append(String.IsNullOrEmpty(invoiceAccount.Address3.Trim()) ? "" : Server.HtmlEncode(invoiceAccount.Address3) + "<br />");
      sb.Append(String.IsNullOrEmpty(invoiceAccount.City) ? "" : Server.HtmlEncode(invoiceAccount.City) + ",&nbsp;");
      sb.Append(String.IsNullOrEmpty(invoiceAccount.State) ? "" : Server.HtmlEncode(invoiceAccount.State) + "&nbsp;&nbsp;");
      sb.Append(String.IsNullOrEmpty(invoiceAccount.Zip) ? "" : Server.HtmlEncode(invoiceAccount.Zip) + "<br />");
      //sb.Append(String.IsNullOrEmpty(invoiceAccount.CountryValueDisplayName) ? "" : Server.HtmlEncode(invoiceAccount.CountryValueDisplayName));
    }

    else
    {
      var client = new AccountServiceClient();
      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      MTList<MetraTech.DomainModel.BaseTypes.Account> items = new MTList<MetraTech.DomainModel.BaseTypes.Account>();
      items.Filters.Add(new MTFilterElement("_AccountID", MTFilterElement.OperationType.Equal, UI.User.AccountId));
      items.PageSize = 1;
      items.CurrentPage = 1;
      client.GetAccountList(MetraTime.Now, ref items, false);
      if (items.Items.Count > 0)
      {
        MetraTech.DomainModel.BaseTypes.Account acct = items.Items[0];
        PropertyInfo pi = acct.GetType().GetProperty("LDAP");
        if (pi != null)
        {
          var viewsDictionary = acct.GetViews();
          if (viewsDictionary != null)
          {
            foreach (var key in viewsDictionary.Keys)
            {
              if (key == "LDAP")
              {
                var contactViewList = viewsDictionary[key];

                foreach (ContactView cv in contactViewList)
                {
                  if (cv.ContactType.HasValue && cv.ContactType.Value == ContactType.Bill_To)
                  {
                    sb.Append(String.IsNullOrEmpty(cv.FirstName) ? "" : Server.HtmlEncode(cv.FirstName) + "&nbsp;");
                    sb.Append(String.IsNullOrEmpty(cv.MiddleInitial) ? "" : Server.HtmlEncode(cv.MiddleInitial) + "&nbsp;");
                    sb.Append(String.IsNullOrEmpty(cv.LastName) ? "" : Server.HtmlEncode(cv.LastName) + "<br />");
                    sb.Append(String.IsNullOrEmpty(cv.Company) ? "" : Server.HtmlEncode(cv.Company) + "<br />");
                    sb.Append(String.IsNullOrEmpty(cv.Address1) ? "" : Server.HtmlEncode(cv.Address1) + "<br />");
                    sb.Append(String.IsNullOrEmpty(cv.Address2) ? "" : Server.HtmlEncode(cv.Address2) + "<br />");
                    sb.Append(String.IsNullOrEmpty(cv.Address3) ? "" : Server.HtmlEncode(cv.Address3) + "<br />");
                    sb.Append(String.IsNullOrEmpty(cv.City) ? "" : Server.HtmlEncode(cv.City) + ",&nbsp;");
                    sb.Append(String.IsNullOrEmpty(cv.State) ? "" : Server.HtmlEncode(cv.State) + "&nbsp;&nbsp;");
                    sb.Append(String.IsNullOrEmpty(cv.Zip) ? "" : Server.HtmlEncode(cv.Zip) + "<br />");
                  }
                }
              }
            }
          }

        }
      }
    }
    return sb.ToString();
  }
}
