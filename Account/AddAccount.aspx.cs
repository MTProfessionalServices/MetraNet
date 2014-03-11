using System;
using System.Configuration;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Accounts.Type;
using MetraTech.Interop.IMTAccountType;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Controls;
using MetraTech.ActivityServices.Common;

public partial class AddAccount : MTAccountPage
{
  /// <summary>
  /// Returns JSON string with mapping of account attributes to JavaScript client-side controls
  /// </summary>
  public string JSControlMapping
  {
    get
    {
      StringBuilder sb = new StringBuilder();

      foreach (MTDataBindingItem itm in MTDataBinder1.DataBindingItems)
      {
        if (itm.ControlInstance != null)
        {
            sb.AppendFormat("{0}'{1}.{2}':'{3}'", sb.Length == 0 ? string.Empty : ",", (itm.BindingSource == "BillTo") ? "LDAP[ContactType=Bill_To]" : itm.BindingSource, itm.BindingSourceMember, itm.ControlInstance.ClientID);
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
            if (!IsPostBack)
            {
      if (Account != null)
      {
          Account.AccountStartDate = DateTime.Now;
      }
      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";       
      MTGenericForm1.RenderObjectType = BillTo.GetType();
      MTGenericForm1.RenderObjectInstanceName = "BillTo";
      MTGenericForm1.TemplatePath = TemplatePath;        
      MTGenericForm1.ReadOnly = false;

      MTGenericFormTax.DataBinderInstanceName = "MTDataBinder1";
      MTGenericFormTax.RenderObjectType = Internal.GetType();
      MTGenericFormTax.RenderObjectInstanceName = "Internal";
      MTGenericFormTax.TemplateName = "TaxTemplate";
      MTGenericFormTax.TemplatePath = TemplatePath;
      MTGenericFormTax.ReadOnly = false;
            }

      //PriceListCol = PageNav.Data.Out_StateInitData["PriceListColl"] as List<PriceList>;
      PopulatePresentationNameSpaceList(ddBrandedSite);

            // For Partition users, only allow them to use their own namespace
            if (PartitionLibrary.IsPartition)
            {
                string PartitionAccountsNameSpace = PartitionLibrary.PartitionData.PartitionUserName;
                ListItem PartitionBrandedSiteListItem = null;
                foreach (ListItem brandedSiteListItem in ddBrandedSite.Items)
                {
                    if (string.Compare(brandedSiteListItem.Value, PartitionAccountsNameSpace, true) == 0)
                    {
                        brandedSiteListItem.Selected = true;
                        PartitionBrandedSiteListItem = brandedSiteListItem;
                        continue;
                    }
                }

                ddBrandedSite.Items.Clear();
                if (PartitionBrandedSiteListItem != null)
                {
                    ddBrandedSite.Items.Add(PartitionBrandedSiteListItem);
                }
                ddBrandedSite.ReadOnly = true;
            }
            else
            {
                // Default to "mt" namespace
                foreach (ListItem brandedSiteListItem in ddBrandedSite.Items)
                {
                    if (string.Compare(brandedSiteListItem.Value, "mt", true) == 0)
                    {
                        brandedSiteListItem.Selected = true;
                        continue;
                    }
                }
            }

      bool templatesApplied = (bool)PageNav.Data.Out_StateInitData["TemplatesApplied"];
      if (!templatesApplied)
      {
        // Set defaults for the page
        Internal.Billable = true;
        Internal.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;
        Internal.Language = LanguageCode.US;
        Internal.UsageCycleType = UsageCycleType.Monthly;
      }

      // Set display rules based on the account type metadata.
      AccountTypeManager accountTypeManager = new AccountTypeManager();
      if (Account != null)
      {
        IMTAccountType accountType = accountTypeManager.GetAccountTypeByName((MetraTech.Interop.MTProductCatalog.IMTSessionContext)UI.SessionContext, Account.AccountType);

        if (!accountType.IsVisibleInHierarchy)
        {
          cbBillable.ReadOnly = true;
          tbPayer.Visible = false;
          tbAncestorAccount.ReadOnly = true;
          Account.AncestorAccountID = 1;
                    cbApplyTemplate.Visible = false;
          tbAncestorAccount.AllowBlank = true;
        }

        if (accountType.IsCorporate)
        {
          tbAncestorAccount.ReadOnly = false;      
                    // Account.AncestorAccountID = 1;
                    cbApplyTemplate.Visible = false;
          tbAncestorAccount.AllowBlank = false;
        }

        if (accountType.Name == "Endpoint")
        {
          cbBillable.Checked = false;
          cbBillable.ReadOnly = true;
          cbBillable.Visible = true;
          //Payer is required 
          tbPayer.AllowBlank = false;
        }


      }
     
      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }
      
            // PriceListCol = PageNav.Data.Out_StateInitData["PriceListColl"] as List<PriceList>;
            // PopulatePriceList(ddPriceList);
            PartitionLibrary.PopulatePriceListDropdown(ddPriceList);

      ddAuthenticationType.Items.Clear();
      ddAuthenticationType.EnumSpace = "metratech.com/accountcreation";
      ddAuthenticationType.EnumType = "AuthenticationType";

      var enumType = MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType(ddAuthenticationType.EnumSpace,
                                                                                 ddAuthenticationType.EnumType,
                                                                                 System.IO.Path.GetDirectoryName(
                                                                                   new Uri(
                                                                                     this.GetType().Assembly.CodeBase)
                                                                                     .AbsolutePath));

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

    if(tbAncestorAccount.AccountID == "")
    {
      throw new ApplicationException(Resources.ErrorMessages.ERROR_PARENT_ACCOUNT_INVALID);
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

	//if (((MTDropDown)FindControlRecursive(Page, "ddSecurityQuestion")).SelectedIndex <= 1 ||
	//    !String.IsNullOrWhiteSpace(((MTTextBoxControl)FindControlRecursive(Page, "tbSecurityQuestionText")).Text))
	//{
	//  if (String.IsNullOrWhiteSpace(((MTTextBoxControl)FindControlRecursive(Page, "tbSecurityAnswer")).Text))
	//  {
	//    throw new ApplicationException(Resources.ErrorMessages.ERROR_SECURITY_ANSWER_INVALID);
	//  }
	//}
	//else
	//{
	//  if (((MTTextBoxControl)FindControlRecursive(Page, "tbSecurityAnswer")).Text == String.Empty)
	//  {
	//    throw new ApplicationException(Resources.ErrorMessages.ERROR_SECURITY_ANSWER_INVALID);
	//  }
	//}


  // [TODO] After fixing CORE-6642 validation of SemiMonthly Cycle is no longer required here. Before removing it:
  // Use localized "Resources.ErrorMessages.ERROR_ENDDOM_INVALID"(see below) instead of unlocalized INVALID_FIRST_DAY in S:\MetraTech\DomainModel\Validators\AccountValidator.cs

    // Validate the semi-monthly selected days if semi-monthly defined.
    if (((MTBillingCycleControl)FindControlRecursive(Page, "MTBillingCycleControl1")).CycleList.SelectedValue.ToLower()
        == "semi_monthly")
    {
        int startDay = Int32.Parse(MTBillingCycleControl1.SemiMonthly_First.SelectedValue);
        int endDay = Int32.Parse(MTBillingCycleControl1.SemiMonthly_Second.SelectedValue);
        if (endDay <= startDay)
        {
            throw new ApplicationException(Resources.ErrorMessages.ERROR_ENDDOM_INVALID);

        }
    } // end if semi-monthly validation
  
    //Payer is mandatory for Endpoint account type
    AccountTypeManager accountTypeManagerEndpoint = new AccountTypeManager();

    IMTAccountType accountTypeEp = accountTypeManagerEndpoint.GetAccountTypeByName((MetraTech.Interop.MTProductCatalog.IMTSessionContext)UI.SessionContext, Account.AccountType);
    
    if ((accountTypeEp.Name == "Endpoint") && (tbPayer.Text == ""))
    {
      throw new ApplicationException(Resources.ErrorMessages.ERROR_PAYER_ID_IS_REQUIRED);
    }

  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try 
    {
      Account.AuthenticationType = (AuthenticationType)EnumHelper.GetGeneratedEnumByEntry(typeof(AuthenticationType), ddAuthenticationType.SelectedValue);

      Page.Validate();

      MTDataBinder1.Unbind();
      AddAccountEvents_AddAccount_Client add = new AddAccountEvents_AddAccount_Client();
      add.In_Account = Account;
      add.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      add.In_SendEmail = cbEmailNotification.Checked;
            add.In_ApplyAccountTemplates = cbApplyTemplate.Checked;
      PageNav.Execute(add);
     
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
    PageNav.Execute(cancel);
  }

}
