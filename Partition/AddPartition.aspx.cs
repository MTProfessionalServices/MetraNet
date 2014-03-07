using System;
using System.Configuration;
using System.Collections.Generic;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using System.Text.RegularExpressions;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Accounts.Type;
using MetraTech.Interop.IMTAccountType;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Controls;
using MetraTech.ActivityServices.Common;
using System.Web.UI.WebControls;

public partial class AddPartition : MTAccountPage
{
    private List<string> ContainerNamesList;

    protected void Page_Load(object sender, EventArgs e)
    {
        ContainerNamesList = new List<string>();
        ContainerNamesList.Add("Retail");
        ContainerNamesList.Add("Resellers");
        ContainerNamesList.Add("Vendors");
        ContainerNamesList.Add("Channels");
        ContainerNamesList.Add("System Users");

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

                MTGenericFormTax.DataBinderInstanceName = "MTDataBinder1";
                MTGenericFormTax.RenderObjectType = Internal.GetType();
                MTGenericFormTax.RenderObjectInstanceName = "Internal";
                MTGenericFormTax.TemplateName = "TaxTemplate";
                MTGenericFormTax.TemplatePath = TemplatePath;
                MTGenericFormTax.ReadOnly = false;
            }

            PopulatePresentationNameSpaceList(ddBrandedSite);

            // Default to "mt" namespace
            foreach (ListItem brandedSiteListItem in ddBrandedSite.Items)
            {
                if (brandedSiteListItem.Value == "mt")
                {
                    brandedSiteListItem.Selected = true;
                    continue;
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
                // Partition Ancestor should alwasys be "root"
                Account.AncestorAccountID = 1;
                tbAncestorAccount.AllowBlank = false;
                tbAncestorAccount.ReadOnly = true;
                cbApplyTemplate.Visible = false;

                // Initialize Account Start Date to Metra-today (with no time)
                Account.AccountStartDate = MetraTech.MetraTime.Now.Date;
            }

            cbSystemUsers.Checked = true;
            cbSystemUsers.Enabled = false;

            // MOCK DATA
            //if (false)
            //{
            //    Account.UserName = "Bane";
            //    Account.Password_ = "123";
            //    tbConfirmPassword.Text = Account.Password_;
            //    Account.AccountStartDate = new DateTime(2013, 1, 1);
            //    Internal.Currency = "USD";
            //    BillTo.FirstName = "Backup";
            //    BillTo.MiddleInitial = "";
            //    BillTo.LastName = "Nebula";
            //    BillTo.Email = "info@bane.com";
            //    BillTo.Company = "BaNe Corp";
            //    BillTo.Address1 = "123 BaNe St";
            //    BillTo.Address2 = "2dn Floor";
            //    BillTo.City = "Waltham";
            //    BillTo.State = "MA";
            //    BillTo.Country = CountryName.USA;
            //    BillTo.PhoneNumber = "781-839-8300";
            //    BillTo.FacsimileTelephoneNumber = "781-839-8301";

            //    cbRetail.Checked = true;
            //    cbResellers.Checked = true;
            //    cbSystemUsers.Checked = true;
            //}

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


            // Create controls within MTPanelContainerList
            /*short tabIndex = 246;

            foreach (string containerName in ContainerNamesList)
            {
                string internalName = containerName.Replace(" ", "");

                MTCheckBoxControl cbContainer = new MTCheckBoxControl();
                cbContainer.ID = string.Format("cb{0}", internalName);
                cbContainer.BoxLabel = containerName;
                cbContainer.Text = containerName;
                cbContainer.Value = internalName;
                cbContainer.TabIndex = tabIndex++;
                cbContainer.ControlWidth = "200";
                cbContainer.Checked = false;
                cbContainer.HideLabel = false;
                cbContainer.ReadOnly = false;
                cbContainer.XType = "Checkbox";
                cbContainer.XTypeNameSpace = "form";

                MTPanelContainerListLeftColumn.Controls.Add(cbContainer);
            }
            */
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


        // Check whether Partition user name contains any of these characters , \, ?, ;, :, @, &, =, +, $, ,, |, ", <, >, *.
        
        string[] specchars = new string[] { ";", ":","@","&","=","+","$","|","<",">","*"," ","\\"};
        foreach (string specchar in specchars)
        {
            if (tbUserName.Text.Contains(specchar))
            {
                tbUserName.Text = "";
                throw new ApplicationException(Resources.ErrorMessages.ERROR_USERNAME_INVALID);
            }
        }
     
      
      if (tbAncestorAccount.AccountID == "")
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
    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
        try
        {
            Account.AuthenticationType = (AuthenticationType)EnumHelper.GetGeneratedEnumByEntry(typeof(AuthenticationType), ddAuthenticationType.SelectedValue);

            // "System Users" container must always be created
            cbSystemUsers.Enabled = false; //Fix for CORE-7387 we don't want the user to select or deselect this check box 
            cbSystemUsers.Checked = true;

            Page.Validate();  
          
            MTDataBinder1.Unbind();
            AddPartitionEvents_AddPartition_Client add = new AddPartitionEvents_AddPartition_Client();
            add.In_Account = Account;
            add.In_AccountId = new AccountIdentifier(UI.User.AccountId);
            add.In_SendEmail = cbEmailNotification.Checked;
            add.In_ApplyAccountTemplates = cbApplyTemplate.Checked;
            
            // Add all checked containers to the list that is passed to the PageNav workflow
            add.In_ContainerNamesCol = new List<string>();
            foreach (string containerName in ContainerNamesList)
            {
                string controlName = string.Format("cb{0}", containerName.Replace(" ", ""));
                MTCheckBoxControl cb = (MTCheckBoxControl)FindControlRecursive(Page, controlName);
                if ((cb != null) && (cb.Checked))
                {
                    add.In_ContainerNamesCol.Add(containerName);
                }
            }
            PageNav.Execute(add);

        }
        catch (Exception exp)
        {
            SetError(exp.Message);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        AddPartitionEvents_CancelAddPartition_Client cancel = new AddPartitionEvents_CancelAddPartition_Client();
        cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
        PageNav.Execute(cancel);
    }

}
