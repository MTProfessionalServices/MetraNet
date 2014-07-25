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
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Controls;

//TODO: Need to be ref-factoring on using the only AddAccount, after that AddAccountWorkflow and all other
//TODO: GenericAddAccount.aspx/GenericUpdateAccount.aspx/GenericAccountSummary.aspx can be thrown from MetraNet project
public partial class GenericAddAccount : MTAccountPage
{
  private readonly List<string> skipSections = new List<string>
  {
    "TEXT_LOGIN_INFORMATION",
    "TEXT_ACCOUNT_INFORMATION"
  };
  private readonly List<string> skipProperties = new List<string>();
  private static readonly AccountTypeCollection mAccountTypeCollection = new AccountTypeCollection();
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

  /// <summary>
  /// Returns JSON string with mapping of account attributes to JavaScript client-side controls
  /// </summary>
  public string JSControlMapping
  {
    get
    {
      var sb = new System.Text.StringBuilder();

      foreach (MTDataBindingItem itm in MTDataBinder1.DataBindingItems)
      {
        if (itm.ControlInstance != null)
        {
          string bSource = itm.BindingSource;
          if (bSource.StartsWith("Account."))
          {
            bSource = bSource.Substring(8);
          }
          sb.AppendFormat("{0}'{1}.{2}':'{3}'",
            sb.Length == 0 ? string.Empty : ",",
            (bSource == "BillTo") ? "LDAP[ContactType=Bill_To]" : bSource,
            itm.BindingSourceMember,
            itm.ControlInstance.ClientID);
        }
      }
      return string.Format("{{{0}}}", sb);
    }
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
      MTGenericForm1.IgnoreSectionsByLocalizationTag = skipSections;

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
    var regexPattern = new Regex(ConfigurationManager.AppSettings["AcctUserNameRegex"]);
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

    // TODO After fixing CORE-6642 validation of SemiMonthly Cycle is no longer required here. Before removing it:
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

        var add = new AddAccountEvents_AddAccount_Client
          {
            In_Account = Account,
            In_AccountId = new AccountIdentifier(UI.User.AccountId),
            In_SendEmail = cbEmailNotification.Checked,
            In_ApplyAccountTemplates = cbApplyTemplate.Checked
          };
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
    var cancel = new AddAccountEvents_CancelAddAccount_Client {In_AccountId = new AccountIdentifier(UI.User.AccountId)};
    if (PageNav != null) PageNav.Execute(cancel);
  }

  protected void setDefaultProperties(Account acct)
  {
    var internalView = (InternalView)acct.GetInternalView();

    if (internalView != null)
    {
      internalView.Billable = true;
      internalView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;
      internalView.Language = LanguageCode.US;
      internalView.UsageCycleType = UsageCycleType.Monthly;
    }

    const BindingFlags memberAccess = BindingFlags.Public | BindingFlags.NonPublic |
                                      BindingFlags.Static | BindingFlags.Instance | BindingFlags.IgnoreCase;

    var contactViews = Account.GetType().GetProperty("LDAP", memberAccess);
    if (contactViews != null)
    {
      var views = contactViews.GetValue(Account, null) as List<ContactView>;

      try
      {
        foreach (ContactView view in views)
          if (view.ContactType == null)
          {
            view.ContactType = ContactType.Bill_To;
          }
      }
      catch
      {
        //if there is no contact view we skip it and do what we can.
      }
    }
  }


}
