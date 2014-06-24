using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.Accounts.Type;
using MetraTech.Interop.IMTAccountType;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Controls;
using MetraTech.Approvals;
using MetraTech.Core.Services.ClientProxies;

public partial class Account_UpdateAccount : MTAccountPage
{
  //Approval Framework Code Starts Here 
  public int? bAccountUpdateApprovalsEnabled
  {
    get { return ViewState["bAccountUpdateApprovalsEnabled"] as int?; }
    set { ViewState["bAccountUpdateApprovalsEnabled"] = value; }
  } //so we can read it any time in the session

  public bool bAllowMoreThanOnePendingChange { get; set; }
  public bool bAccountHasPendingChange { get; set; }
  public string strChangeType { get; set; }
  //Approval Framework Code Ends Here 

  /// <summary>
  /// Returns JSON string with mapping of account attributes to JavaScript client-side controls
  /// </summary>
  public string JSControlMapping
  {
    get
    {
      var sb = new StringBuilder();

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
    try
    {
      if (!IsPostBack)
      {
        Account = (Account)PageNav.Data.Out_StateInitData["Account"];

        tbAuthenticationType.Text = BaseObject.GetDisplayName(Account.AuthenticationType);

        MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
        if (BillTo == null)
        {
          BillTo = new ContactView();
        }
        MTGenericForm1.RenderObjectType = typeof(ContactView);
        MTGenericForm1.RenderObjectInstanceName = "BillTo";
        MTGenericForm1.TemplatePath = TemplatePath;
        MTGenericForm1.ReadOnly = false;

        MTGenericFormTax.DataBinderInstanceName = "MTDataBinder1";
        MTGenericFormTax.RenderObjectType = Internal.GetType();
        MTGenericFormTax.RenderObjectInstanceName = "Internal";
        MTGenericFormTax.TemplateName = "TaxTemplate";
        MTGenericFormTax.TemplatePath = TemplatePath;
        MTGenericFormTax.ReadOnly = false;

        PopulatePresentationNameSpaceList(ddBrandedSite);

        //CORE-7585 Fix, new logic to read branded site for an account
        string ddFindByText = PopulateAccountBrandedSite(Convert.ToInt32(UI.Subscriber.SelectedAccount._AccountID));
        ddBrandedSite.SelectedValue = ddBrandedSite.Items.FindByText(ddFindByText).Value;

        PriceListCol = PageNav.Data.Out_StateInitData["PriceListColl"] as List<PriceList>;
        PopulatePriceList(ddPriceList);
        PartitionLibrary.PopulatePriceListDropdown(ddPriceList);
        if (((InternalView)Account.GetInternalView()).PriceList != null)
        {
          var priceList = ((InternalView) Account.GetInternalView()).PriceList;
          int? selPriceList = null;
          if (priceList != null)
            selPriceList = priceList.Value;
          ddPriceList.SelectedValue = selPriceList.ToString();
        }
        else
        {
          ddPriceList.SelectedIndex = 0;
        }


        // Set display rules based on the account type metadata.
        var accountTypeManager = new AccountTypeManager();
        IMTAccountType accountType =
            accountTypeManager.GetAccountTypeByName(
                (MetraTech.Interop.MTProductCatalog.IMTSessionContext)UI.SessionContext, Account.AccountType);

        if (!accountType.IsVisibleInHierarchy)
        {
          cbBillable.ReadOnly = true;
          tbAncestorAccount.ReadOnly = true;
          Account.AncestorAccountID = 1;
          tbPayer.ReadOnly = true;
          cbApplyTemplate.Visible = false;
        }

        if (accountType.IsCorporate)
        {
          tbAncestorAccount.ReadOnly = true;
          tbPayer.ReadOnly = true;
          cbApplyTemplate.Visible = false;
        }

        tbSecurityQuestionText.Visible = (Account.AuthenticationType == AuthenticationType.MetraNetInternal);
        tbSecurityAnswer.Visible = (Account.AuthenticationType == AuthenticationType.MetraNetInternal);
        ddSecurityQuestion.Visible = (Account.AuthenticationType == AuthenticationType.MetraNetInternal);

        if (accountType.Name == "Endpoint")
        {
          cbBillable.Checked = false;
          cbBillable.ReadOnly = true;
          cbBillable.Visible = true;
          //Payer is required 
          tbPayer.AllowBlank = false;
        }

        if (!MTDataBinder1.DataBind())
        {
          Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
        }

        //Approval Framework Code Starts Here 
        var client = new ApprovalManagementServiceClient();

        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        strChangeType = "AccountUpdate";
        bAccountHasPendingChange = false;
        bAccountUpdateApprovalsEnabled = 0;

        var mactc = new MTList<ChangeTypeConfiguration>();

        client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

        if (mactc.Items[0].Enabled)
        {
          bAccountUpdateApprovalsEnabled = 1; // mactc.Items[0].Enabled; 
        }

        if (bAccountUpdateApprovalsEnabled == 1)
        {
          bAllowMoreThanOnePendingChange = mactc.Items[0].AllowMoreThanOnePendingChange;

          List<int> pendingchangeids;
          string straccountid = UI.Subscriber.SelectedAccount._AccountID.ToString();

          client.GetPendingChangeIdsForItem(strChangeType, straccountid, out pendingchangeids);

          if (pendingchangeids.Count != 0)
          {
            bAccountHasPendingChange = true;
          }

          if (!bAllowMoreThanOnePendingChange)
          {
            if (bAccountHasPendingChange)
            {
              //todo potential localization issue
              SetError("This account already has Account Update type pending change. This type of change does not allow more than one pending changes.");
              Logger.LogError(string.Format("The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.",
                      UI.Subscriber.SelectedAccount.UserName, "AccountUpdate"));
              btnOk.Visible = false;
              client.Abort();
            }
          }

          if (bAccountHasPendingChange)
          {
            //todo potential localization issue
            const string approvalframeworkmanagementurl = "<a href='/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING'</a>";
            const string strPendingChangeWarning = "This account already has pending change in the approval framework queue. " + approvalframeworkmanagementurl + " Click here to view pending changes.";
            divLblMessage.Visible = true;
            lblMessage.Text = strPendingChangeWarning;
          }
        }
        //Approval Framework Code Ends Here 
      }
    }
    catch (Exception ex)
    {
      Logger.LogException("Error loading UpdateAccount", ex);
    }
  }

  public override void Validate()
  {
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

    //if (((MTDropDown)FindControlRecursive(Page, "ddSecurityQuestion")).SelectedIndex <= 1)
    //{
    //  if (((MTTextBoxControl)FindControlRecursive(Page, "tbSecurityAnswer")).Text != String.Empty)
    //  {
    //    throw new ApplicationException(Resources.ErrorMessages.ERROR_SECURITY_ANSWER_INVALID);
    //  }
    //}
    //else
    //{
    //    if (((MTTextBoxControl) FindControlRecursive(Page, "tbSecurityAnswer")).Text == String.Empty)
    //    {
    //      throw new ApplicationException(Resources.ErrorMessages.ERROR_SECURITY_ANSWER_INVALID);
    //    }
    //}

    if (tbAncestorAccount.AccountID == "")
    {
      throw new ApplicationException(Resources.ErrorMessages.ERROR_PARENT_ACCOUNT_INVALID);
    }

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
    var accountTypeManagerEndpoint = new AccountTypeManager();

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
      Page.Validate();

      MTDataBinder1.Unbind();

      if (ddPriceList.SelectedValue == "")
      {
        ((InternalView)Account.GetInternalView()).PriceList = null;
      }

      var update = new UpdateAccountEvents_UpdateAccount_Client
        {
          In_Account = Account,
          In_AccountId = new AccountIdentifier(UI.User.AccountId),
          In_ApplyAccountTemplates = cbApplyTemplate.Checked,
          In_LoadTime = ApplicationTime,
          In_IsApprovalEnabled = bAccountUpdateApprovalsEnabled == 1
        };


      PageNav.Execute(update);
    }
    catch (Exception exp)
    {
      SetError(exp.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    var cancel = new UpdateAccountEvents_CancelUpdateAccount_Client
      {
        In_AccountId = new AccountIdentifier(UI.User.AccountId)
      };
    PageNav.Execute(cancel);
  }

}
