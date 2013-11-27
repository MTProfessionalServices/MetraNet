using System;
using System.Collections.Generic;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.PageNav.ClientProxies;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

// SECENG: CORE-4848 Modify security questions (password hint)
// Provides the possibility to edit the account security data.
public partial class AccountSecurity : MTAccountPage
{
	private bool isDataValid;

  protected void Page_Load(object sender, EventArgs e)
  {
		if (SiteConfig.Settings.BillSetting.AllowSelfCare == false)
		{
			return;
		}

		Session["ActiveMenu"] = "AccountSecurity";

		if (!IsPostBack)
		{
			Account = UI.Subscriber.SelectedAccount;

			if (Internal == null)
			{
				var accountSecurity = new InternalView() { SecurityQuestion = SecurityQuestion.None };
				Account.AddView(accountSecurity, "Internal");
			}

			MTGenericForm1.RenderObjectType = Internal.GetType();
			MTGenericForm1.RenderObjectInstanceName = "Internal";
            MTGenericForm1.TemplateName = "MetraViewSecurity";
            MTGenericForm1.TemplatePath = TemplatePath;
            MTGenericForm1.ReadOnly = false;

			if (!MTDataBinder1.DataBind())
			{
				Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
			}
		}
  }

	public override void Validate()
	{
		base.Validate();

		MTDropDown ddSecurityQuestion = FindControlRecursive(this, "ddSecurityQuestion") as MTDropDown;
		MTTextBoxControl tbSecurityQuestionText = FindControlRecursive(this, "tbSecurityQuestionText") as MTTextBoxControl;
		MTTextBoxControl tbSecurityAnswer = FindControlRecursive(this, "tbSecurityAnswer") as MTTextBoxControl;

		if (ddSecurityQuestion == null || tbSecurityQuestionText == null || tbSecurityAnswer == null)
		{
			Logger.LogError("Form's metadata has been changed. Please check it from ICE.");
			throw new ApplicationException(Resources.ErrorMessages.ERROR_UPDATING_ACCOUNT);
		}
		
		isDataValid = true;

		if (ddSecurityQuestion.SelectedIndex <= 1 && String.IsNullOrWhiteSpace(tbSecurityQuestionText.Text))
		{
			if (!String.IsNullOrWhiteSpace(tbSecurityAnswer.Text))
			{
				SetError(Resources.ErrorMessages.ERROR_SECURITY_ANSWER_INVALID);
				isDataValid = false;
			}
		}
		else
		{
			if (ddSecurityQuestion.SelectedIndex > 1 && !String.IsNullOrWhiteSpace(tbSecurityQuestionText.Text))
			{
				SetError(Resources.ErrorMessages.ERROR_SECURITY_QUESTION_INVALID);
				isDataValid = false;
			}

			if (String.IsNullOrWhiteSpace(tbSecurityAnswer.Text))
			{
				SetError(Resources.ErrorMessages.ERROR_SECURITY_ANSWER_INVALID);
				isDataValid = false;
			}
		}
	}

  protected void btnOK_Click(object sender, EventArgs e)
  {
	Page.Validate();
	if (Page.IsValid && isDataValid)
    {
      MTDataBinder1.Unbind();

		try
		{
			var update = new AccountCreation_UpdateAccount_Client();
			update.In_Account = Account;
			update.UserName = UI.User.UserName;
			update.Password = UI.User.SessionPassword;
			update.Invoke();

			UI.Subscriber.SelectedAccount = Account;
			Response.Redirect(UI.DictionaryManager["AccountInfoSuccessPage"].ToString(), false);
		}
		catch (Exception ex)
		{
			Session[Constants.ERROR] = Resources.ErrorMessages.ERROR_UPDATING_ACCOUNT;
			Logger.LogError(ex.Message);
		}

    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
		Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());
  }
}
