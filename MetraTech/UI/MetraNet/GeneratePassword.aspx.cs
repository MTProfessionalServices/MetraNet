using System;
using System.Transactions;
using MetraTech;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Common;
using MetraTech.UI.Tools;
using System.Collections.Generic;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.Security;
using MetraTech.DomainModel.BaseTypes;

public partial class GeneratePassword : MTPage
{
  #region Properties
  public Account ActiveAccount
  {
    get
    {
      return UI.Subscriber.SelectedAccount;
    }
  }

  public InternalView Internal
  {
    get { return Utils.GetProperty(ActiveAccount, "Internal") as InternalView; }
    set { Internal = value; }
  }

  public ContactView BillTo
  {
    get
    {
      foreach (ContactView v in (List<ContactView>)Utils.GetProperty(ActiveAccount, "LDAP"))
      {
        if (v.ContactType == ContactType.Bill_To)
        {
          return v;
        }
      }
      List<ContactView> contacts = Utils.GetProperty(ActiveAccount, "LDAP") as List<ContactView>;
      ContactView contact = new ContactView();
      if (contacts != null) contacts.Add(contact);
      return contact;
    }
    set
    {
      foreach (ContactView v in (List<ContactView>)Utils.GetProperty(ActiveAccount, "LDAP"))
      {
        if (v.ContactType == ContactType.Bill_To)
        {
          BillTo = value;
        }
      }
    }
  }
  #endregion

  protected void Page_Load(object sender, EventArgs e)
  {
    string msg;
    if(String.IsNullOrEmpty(BillTo.Email))
    {
      msg = GetLocalResourceObject("TEXT_NO_EMAIL").ToString();
      btnOK.Visible = false;
    }
    else
    {
      msg = String.Format(GetLocalResourceObject("TEXT_GENERATE_PASSWORD").ToString(), BillTo.Email);
    }
    lblMessage.Text = msg;
    
		if (!MTDataBinder1.DataBind())
		{
			Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
		}

		lblSecurityQuestion.Visible = String.IsNullOrWhiteSpace(lblSecurityQuestionText.Text);
		lblSecurityQuestionText.Visible = !lblSecurityQuestion.Visible;
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                           new TransactionOptions(),
                                                           EnterpriseServicesInteropOption.Full))
      {
        // Generate and change password
        Auth auth = new Auth();
        auth.Initialize(ActiveAccount.UserName, ActiveAccount.Name_Space);
        string newPassword = auth.GeneratePassword();
        auth.UpdatePassword(newPassword, UI.SessionContext);

        // Send Email
        auth.EmailPasswordUpdate(BillTo.Email, BillTo.FirstName, BillTo.LastName, newPassword, ApplicationTime,
                                            Internal.Language.ToString(), UI.SessionContext);

        scope.Complete();
      }
    }
    catch (Exception exp)
    {
      Session[Constants.ERROR] = exp.Message;
      return;
    }

    // Password change successful (redirect outside of try block)
    ConfirmMessage(GetLocalResourceObject("TEXT_PASSWORD_GENERATED_TITLE").ToString(), GetLocalResourceObject("TEXT_SUCCESS").ToString());
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
  }
}