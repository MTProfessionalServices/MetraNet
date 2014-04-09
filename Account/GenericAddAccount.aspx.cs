using System;
using System.Collections.Generic;
using System.Configuration;
using System.Reflection;
using System.Text.RegularExpressions;
using MetraTech.Accounts.Type;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.Interop.IMTAccountType;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Controls;

public partial class GenericAddAccount : MTAccountPage
{
  private List<string> skipProperties = new List<string>();
  private static AccountTypeCollection mAccountTypeCollection = new AccountTypeCollection();
  private void SetupSkipProperties()
  {

    skipProperties.Add("username");
    skipProperties.Add("ancestoraccountid");
    skipProperties.Add("password_");
    skipProperties.Add("accountstartdate");
    skipProperties.Add("name_space");
    skipProperties.Add("applydefaultsecuritypolicy");
    skipProperties.Add("internal.timezoneid");
    skipProperties.Add("payerid");
    skipProperties.Add("accountstartdate");
    skipProperties.Add("internal.language");    
  }


  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      Account = PageNav.Data.Out_StateInitData["Account"] as Account;
      setDefaultProperties(Account);
      if (Account != null)
      {
        Account.AccountStartDate = DateTime.Now;
        // For UX reasons, if the settings are not there, lets not confuse the user with
        // settings which have no affect... plus I hate researching bugs due to bad config...
        var accountType = mAccountTypeCollection.GetAccountType(Account.AccountType);
        if (!(accountType.CanBePayer || accountType.CanSubscribe || accountType.CanParticipateInGSub))
        {
          ddCurrency.Visible = false;
          cbBillable.Visible = false;
          ddPaperInvoice.Visible = false;
          MTBillingCycleControl1.CycleList.Visible = false;
          MTBillingCycleControl1.Weekly.Visible = false;
          MTBillingCycleControl1.Quarterly_Month.Visible = false;
          MTBillingCycleControl1.Quarterly_Day.Visible = false;
          MTBillingCycleControl1.Monthly.Visible = false;
          MTBillingCycleControl1.SemiMonthly_First.Visible = false;
          MTBillingCycleControl1.SemiMonthly_Second.Visible = false;
          MTBillingCycleControl1.StartYear.Visible = false;
        }
      }

      PopulatePresentationNameSpaceList(ddBrandedSite);
      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      if (Account != null) MTGenericForm1.RenderObjectType = Account.GetType();
      MTGenericForm1.RenderObjectInstanceName = "Account";
      MTGenericForm1.TemplatePath = TemplatePath;
      MTGenericForm1.ReadOnly = false;
      SetupSkipProperties();
      //PriceListCol = PageNav.Data.Out_StateInitData["PriceListColl"] as List<PriceList>;
      MTGenericForm1.IgnoreProperties = skipProperties;

      //PopulatePriceList(ddPriceList);

      PartitionLibrary.PopulatePriceListDropdown(ddPriceList);
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
    Regex regexPattern = new Regex(ConfigurationManager.AppSettings["AcctUserNameRegex"]);
    if (!regexPattern.IsMatch(tbUserName.Text))
    {
      tbUserName.Text = "";
      throw new ApplicationException(Resources.ErrorMessages.ERROR_USERNAME_INVALID);
    }

    // DO GENERIC ACCOUNT TYPES HAVE TO HAVE AN ANCESTOR?
    //    if (tbAncestorAccountID.bAncestorAccountID.AccountID.Equals(""))
    //    {
    //      throw new ApplicationException(Resources.ErrorMessages.ERROR_PARENT_ACCOUNT_INVALID);
    //    }

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

    // [TODO] After fixing CORE-6642 validation of SemiMonthly Cycle is no longer required here. Before removing it:
    // Use localized "Resources.ErrorMessages.ERROR_ENDDOM_INVALID"(see below) instead of unlocalized INVALID_FIRST_DAY in S:\MetraTech\DomainModel\Validators\AccountValidator.cs

    // Validate the semi-monthly selected days if semi-monthly defined.
    if (((MTBillingCycleControl)FindControlRecursive(Page, "MTBillingCycleControl1")).CycleList.SelectedValue.ToLower().Equals("semi_monthly"))
    {
      int startDay = Int32.Parse(MTBillingCycleControl1.SemiMonthly_First.SelectedValue);
      int endDay = Int32.Parse(MTBillingCycleControl1.SemiMonthly_Second.SelectedValue);
      if (endDay <= startDay)
      {
        throw new ApplicationException(Resources.ErrorMessages.ERROR_ENDDOM_INVALID);
      }
    } // end if semi-monthly validation
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      Page.Validate();

      if (Page.IsValid)
      {
        MTDataBinder1.Unbind();

        AddAccountEvents_AddAccount_Client add = new AddAccountEvents_AddAccount_Client();
        add.In_Account = Account;
        add.In_AccountId = new AccountIdentifier(UI.User.AccountId);
        add.In_SendEmail = cbEmailNotification.Checked;
        add.In_ApplyAccountTemplates = cbApplyTemplate.Checked;
        PageNav.Execute(add);
      }
    }
    catch (Exception exp)
    {
      SetError(exp.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    AddAccountEvents_CancelAddAccount_Client cancel = new AddAccountEvents_CancelAddAccount_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    if (PageNav != null) PageNav.Execute(cancel);
  }

  protected void setDefaultProperties(Account acct)
  {
    InternalView internalView = (InternalView)acct.GetInternalView();

    if (internalView != null)
    {
      internalView.Billable = true;
      internalView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;
      internalView.Language = LanguageCode.US;
      internalView.UsageCycleType = UsageCycleType.Monthly;
    }

    BindingFlags memberAccess = BindingFlags.Public | BindingFlags.NonPublic |
         BindingFlags.Static | BindingFlags.Instance | BindingFlags.IgnoreCase;

    var contactViews = Account.GetType().GetProperty("LDAP", memberAccess);
    if (contactViews != null)
    {
      List<ContactView> views = contactViews.GetValue(Account, null) as List<ContactView>;

      try
      {
        foreach (ContactView view in views)
          if (view.ContactType == null)
          {
            ((ContactView)view).ContactType = ContactType.Bill_To;
          }
      }
      catch
      {
        //if there is no contact view we skip it and do what we can.
      }
    }
  }


}
