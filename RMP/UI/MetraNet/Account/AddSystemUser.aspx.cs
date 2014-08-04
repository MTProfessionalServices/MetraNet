using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using System.Text.RegularExpressions;
using MetraTech.UI.Controls;
using MetraTech.ActivityServices.Common;

public partial class AddSystemUser : MTAccountPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      Account = PageNav.Data.Out_StateInitData["Account"] as Account;
      if (!IsPostBack)
      {
        MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
        MTGenericForm1.RenderObjectType = BillTo.GetType();
        MTGenericForm1.RenderObjectInstanceName = "BillTo";
        MTGenericForm1.TemplatePath = TemplatePath;
        MTGenericForm1.ReadOnly = false;
        ddAuthenticationType.Items.Clear();
        // ReSharper disable LocalizableElement
        ddAuthenticationType.EnumSpace = "metratech.com/accountcreation";
        ddAuthenticationType.EnumType = "AuthenticationType";
        // ReSharper restore LocalizableElement

        var enumType = EnumHelper.GetGeneratedEnumType(ddAuthenticationType.EnumSpace, ddAuthenticationType.EnumType,
              System.IO.Path.GetDirectoryName(new Uri(GetType().Assembly.CodeBase).AbsolutePath));

        if (enumType != null)
        {
          List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(enumType);

          foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enums)
          {
            var itm = new ListItem(enumData.DisplayName /*localized*/, enumData.EnumInstance.ToString());
            ddAuthenticationType.Items.Add(itm);
          }
        }
      }

      // set some defaults for the page
      Internal.Billable = true;
      Internal.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;
      Internal.Language = LanguageCode.US;

      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }
    }
  }

  public override void Validate()
  {
    // password
    if (tbPassword.Text != tbConfirmPassword.Text)
    {
      throw new ApplicationException(Resources.ErrorMessages.ERROR_PASSWORDS_DO_NOT_MATCH);
    }

    // email
    if (cbEmailNotification.Checked)
    {
      if (((MTTextBoxControl)FindControlRecursive(Page, "tbEmail")).Text == String.Empty)
      {
        throw new ApplicationException(Resources.ErrorMessages.ERROR_EMAIL_REQUIRED);
      }
    }

    // user name
    var RegexPattern = new Regex(ConfigurationManager.AppSettings["AcctUserNameRegex"]);
    if (!RegexPattern.IsMatch(tbUserName.Text))
    {
      tbUserName.Text = "";
      throw new ApplicationException(Resources.ErrorMessages.ERROR_USERNAME_INVALID);
    }

    // SECENG: CORE-4848 Modify security questions (password hint)
    // Changed the security question/answer validation
    if (ddSecurityQuestion.SelectedIndex <= 1 && String.IsNullOrWhiteSpace(tbSecurityQuestionText.Text))
    {
      if (!String.IsNullOrWhiteSpace(tbSecurityAnswer.Text))
      {
        throw new ApplicationException(Resources.ErrorMessages.ERROR_SECURITY_ANSWER_INVALID);
      }
    }
    else
    {
      if (ddSecurityQuestion.SelectedIndex > 1 && !String.IsNullOrWhiteSpace(tbSecurityQuestionText.Text))
      {
        throw new ApplicationException(Resources.ErrorMessages.ERROR_SECURITY_QUESTION_INVALID);
      }

      if (String.IsNullOrWhiteSpace(tbSecurityAnswer.Text))
      {
        throw new ApplicationException(Resources.ErrorMessages.ERROR_SECURITY_ANSWER_INVALID);
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      Account.AuthenticationType = (AuthenticationType)EnumHelper.GetGeneratedEnumByEntry(typeof(AuthenticationType), ddAuthenticationType.SelectedValue);
      Page.Validate();

      MTDataBinder1.Unbind();

      // default for system user
      ((InternalView)Account.GetInternalView()).PriceList = null;

      var add = new AddAccountEvents_AddAccount_Client
        {
          In_Account = Account,
          In_AccountId = new AccountIdentifier(UI.User.AccountId),
          In_SendEmail = cbEmailNotification.Checked
        };
      PageNav.Execute(add);
    }
    catch (Exception exp)
    {
      SetError(exp.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    var cancel = new AddAccountEvents_CancelAddAccount_Client {In_AccountId = new AccountIdentifier(UI.User.AccountId)};
    PageNav.Execute(cancel);
  }


}
