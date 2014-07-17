using System;
using System.Collections.Generic;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.BaseTypes;

public partial class ManageAccount : MTPage
{

  private string mAccountJson;
  public string AccountJson
  {
    get { return mAccountJson; }
    set { mAccountJson = value; }
  }

  private string mAccountTypeTpl;
  public string AccountTypeTpl
  {
    get { return mAccountTypeTpl; }
    set { mAccountTypeTpl = value; }
  }

  private string mUrl;
  public string Url
  {
    get { return mUrl; }
    set { mUrl = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!String.IsNullOrEmpty(Request["URL"]))
    {
      Url = UI.DictionaryManager["AccountSummaryPage"].ToString();
    }

    // Clear old menu that may be cached
    Session[Constants.ACCOUNT_MENU] = null;

    AccountTypeTpl = "Tpl";
    AccountJson = "{}";

    int id;
    if (Request["id"] != null)
    {
      id = int.Parse(Request["id"]);
    }
    else
    {

      if (!String.IsNullOrEmpty(UI.Subscriber["_AccountID"]))
      {
        id = int.Parse(UI.Subscriber["_AccountID"]);
      }
      else
      {
        // No account to manage
        Response.End();
        return;
      }
    }

    if (Request["page"] != null)
    {
      Url = Request["page"];
    }


    Account acc = AccountLib.LoadAccount(id, UI.User, ApplicationTime);
    if (acc != null)
    {
      UI.Subscriber.SelectedAccount = acc;
      AccountTypeTpl = acc.AccountType + "Tpl"; // setup template name for JavaScript

      // Create the recent account list in Session, and add the new account to that list
      if (Session[Constants.RECENT_ACCOUNT_LIST] == null)
      {
        Session[Constants.RECENT_ACCOUNT_LIST] = new RecentAccounts();
      }
      RecentAccounts recentAccounts = Session[Constants.RECENT_ACCOUNT_LIST] as RecentAccounts;
      RecentAccount recentAccount = null;
      InternalView internalView = (InternalView)acc.GetInternalView();
      ContactView contactView = AccountLib.LoadContactView(acc, ContactType.Bill_To);
      string accStatus = EnumHelper.GetValueByEnum(acc.AccountStatus).ToString();
      if (contactView != null)
      {
        bool folder = internalView.Folder.HasValue ? internalView.Folder.Value : false;
        recentAccount = new RecentAccount(acc.UserName, contactView.FirstName, contactView.LastName, acc.AccountType,
                                          accStatus, folder, acc._AccountID.ToString());
      }
      else
      {
        try
        {
          ContactView c = new ContactView();
          //c.Country = CountryName.USA;
          c.ContactType = ContactType.Bill_To;
          ((List<ContactView>) Utils.GetProperty(UI.Subscriber.SelectedAccount, "LDAP")).Add(c);
        }
        catch (Exception)
        {
          Logger.LogInfo("Unable to set LDAP property, maybe the account type does not have a contact type.");
        }
        bool folder = internalView.Folder.HasValue ? internalView.Folder.Value : false;
        recentAccount = new RecentAccount(acc.UserName, null, null, acc.AccountType, accStatus, folder,
                                          acc._AccountID.ToString());
      }
      recentAccounts.Add(recentAccount);

      string loadFrame = Request["LoadFrame"] ?? "true";
      if (loadFrame.ToLower() == "false")
      {
        Response.Redirect(Url);
      }
      else
      {
      // Run JSON serializer
      JavaScriptSerializer jss = new JavaScriptSerializer();
      AccountJson = jss.Serialize(acc);
    }
    }

  }

}
