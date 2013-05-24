using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using MetraTech;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Core.Services;
using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Activities;
using MetraTech.Accounts.Type;
using System.ServiceModel;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTYAAC;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Security;
using System.Reflection;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using IMTAccountType=MetraTech.Interop.IMTAccountType.IMTAccountType;
using IMTSessionContext=MetraTech.Interop.MTProductCatalog.IMTSessionContext;
using IMTSQLRowset=MetraTech.Interop.IMTAccountType.IMTSQLRowset;

namespace MetraCareWorkflowLibrary
{
  public class AddAccountWorkflow : MTStateMachineWorkflowActivity
  {
    #region Account Type Constants used for Case statement
    public const string CONST_SystemAccount = "SystemAccount";
    public const string CONST_CoreSubscriber = "CoreSubscriber";
    public const string CONST_IndependentAccount = "IndependentAccount";
    public const string CONST_DepartmentAccount = "DepartmentAccount";
    public const string CONST_CorporateAccount = "CorporateAccount";
    #endregion

    #region StartAddAccount

    public static DependencyProperty PriceListCollProperty = DependencyProperty.Register("PriceListColl", typeof(System.Collections.Generic.List<PriceList>), typeof(MetraCareWorkflowLibrary.AddAccountWorkflow));
    public static DependencyProperty TemplateEffectiveDateProperty = DependencyProperty.Register("TemplateEffectiveDate", typeof(System.DateTime), typeof(MetraCareWorkflowLibrary.AddAccountWorkflow));
    public static DependencyProperty TemplateAccountProperty = DependencyProperty.Register("TemplateAccount", typeof(MetraTech.ActivityServices.Common.AccountIdentifier), typeof(MetraCareWorkflowLibrary.AddAccountWorkflow));
    public static DependencyProperty AccountTemplateProperty = DependencyProperty.Register("AccountTemplate", typeof(MetraTech.DomainModel.ProductCatalog.AccountTemplate), typeof(MetraCareWorkflowLibrary.AddAccountWorkflow));
    public static DependencyProperty ApplyAccountTemplatesProperty = DependencyProperty.Register("ApplyAccountTemplates", typeof(bool), typeof(AddAccountWorkflow));
    public static DependencyProperty TemplatesAppliedProperty = DependencyProperty.Register("TemplatesApplied", typeof(bool), typeof(AddAccountWorkflow));

    [DescriptionAttribute("ApplyAccountTemplates")]
    [CategoryAttribute("ApplyAccountTemplates Category")]
    [BrowsableAttribute(true)]
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [EventInputArg("OK_AddAccount")]
    public bool ApplyAccountTemplates
    {
      get
      {
        return ((bool)(base.GetValue(AddAccountWorkflow.ApplyAccountTemplatesProperty)));
      }
      set
      {
        base.SetValue(AddAccountWorkflow.ApplyAccountTemplatesProperty, value);
      }
    }

    [DescriptionAttribute("ApplyAccountTemplates")]
    [CategoryAttribute("ApplyAccountTemplates Category")]
    [BrowsableAttribute(true)]
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("AddAccount")]
    public bool TemplatesApplied
    {
      get
      {
        return ((bool)(base.GetValue(AddAccountWorkflow.TemplatesAppliedProperty)));
      }
      set
      {
        base.SetValue(AddAccountWorkflow.TemplatesAppliedProperty, value);
      }
    }


    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [StateInitOutput("AddAccount")]
    [StateInitOutput("GenericAddAccount")]
    public List<PriceList> PriceListColl
    {
      get
      {
        return ((System.Collections.Generic.List<PriceList>)(base.GetValue(MetraCareWorkflowLibrary.AddAccountWorkflow.PriceListCollProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.AddAccountWorkflow.PriceListCollProperty, value);
      }
    }
      

    public static DependencyProperty SendEmailProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SendEmail", typeof(bool), typeof(AddAccountWorkflow));
    
    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("OK_AddAccount")]
    public bool SendEmail
    {
      get
      {
        return ((bool)(base.GetValue(AddAccountWorkflow.SendEmailProperty)));
      }
      set
      {
        base.SetValue(AddAccountWorkflow.SendEmailProperty, value);
      }
    }
    

    public static DependencyProperty PageStateGuidProperty = DependencyProperty.Register("PageStateGuid", typeof(System.Guid), typeof(MetraCareWorkflowLibrary.AddAccountWorkflow));

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Inputs")]
    [EventInputArg("SetStateEvent")]
    public Guid PageStateGuid
    {
      get
      {
        return ((System.Guid)(base.GetValue(MetraCareWorkflowLibrary.AddAccountWorkflow.PageStateGuidProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.AddAccountWorkflow.PageStateGuidProperty, value);
      }
    }

    public static DependencyProperty AccountTypesProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AccountTypes", typeof(ArrayList), typeof(AddAccountWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("SelectAccountType")]
    public ArrayList AccountTypes
    {
      get
      {
        return ((ArrayList)(base.GetValue(AddAccountWorkflow.AccountTypesProperty)));
      }
      set
      {
        base.SetValue(AddAccountWorkflow.AccountTypesProperty, value);
      }
    }

    public void GetAccountTypes_ExecuteCode(object sender, EventArgs e)
    {
      AccountTypes = new ArrayList();
      string allTypes = (AccountTemplateService.Config.AllTypesAccountTypeName ?? "alltypes").ToLower();
      if (this.TemplateAccount == null)
      {
        foreach (string accountTypeName in AccountTypesCollection.Names)
        {
          // show all account types except for root and system, since we don't our ancestor yet
          if ((accountTypeName.ToLower() == "root") ||
              (accountTypeName.ToLower() == allTypes) ||
              (accountTypeName.ToLower() == "systemaccount"))
          {
            continue;
          }
          else
          {
            AccountTypes.Add(accountTypeName);
          }
        }
      }
      else
      {
        // only show direct descendent account types that support the add operation
        try
        {
          AccountTypeManager accountTypeManager = new AccountTypeManager();
          YAAC.MTYAAC yaac = new MTYAAC();
          yaac.InitAsSecuredResource((int)TemplateAccount.AccountID, this.GetSessionContext(), MetraTime.Now);
          IMTAccountType accType = accountTypeManager.GetAccountTypeByID((IMTSessionContext)GetSessionContext(), yaac.AccountTypeID);
          IMTSQLRowset rs = accType.GetDirectDescendentsWithOperationAsRowset("metratech.com/accountcreation/operation/Add");
          for (int i = 0; i < rs.RecordCount; i++)
          {
            string accountTypeName = Convert.ToString(rs.get_Value("AccountTypeName"));
            if (accountTypeName.ToLower() != allTypes)
            {
              AccountTypes.Add(accountTypeName);
            }
            rs.MoveNext();
          }
        }
        catch (Exception exp)
        {
          Logger logger = new Logger("[AddAccountWorkflow]");
          logger.LogException("Unable to load account at the time specified time.", exp);

          // don't crash the UI, but load all possible types
          foreach (string accountTypeName in AccountTypesCollection.Names)
          {
            string accTypeNameLower = accountTypeName.ToLower();
            // show all account types except for root and system, since we don't our ancestor yet
            if ((accTypeNameLower == "root") ||
                (accTypeNameLower == allTypes) ||
                (accTypeNameLower == "systemaccount"))
            {
              continue;
            }
            else
            {
              AccountTypes.Add(accountTypeName);
            }
          }
        }

      }
    }
    #endregion

    #region SelectAccountType
    public static DependencyProperty SelectedAccountTypeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SelectedAccountType", typeof(string), typeof(AddAccountWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("OK_SelectAccountType")]
    [EventInputArg("Start_AddAccountOfType")]
    public string SelectedAccountType
    {
      get
      {
        string tmp = ((string)(base.GetValue(AddAccountWorkflow.SelectedAccountTypeProperty)));
        if (String.IsNullOrEmpty(tmp))
        {
          tmp = CONST_CoreSubscriber;
        }
        return tmp;
      }
      set
      {
        base.SetValue(AddAccountWorkflow.SelectedAccountTypeProperty, value);
      }
    }

    public static DependencyProperty AccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Account", typeof(Account), typeof(AddAccountWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("AddAccount")]
    [StateInitOutput("AddSystemUser")]
    [StateInitOutput("GenericAddAccount")]
    [StateInitOutput("AccountCreated")]
    [EventInputArg("OK_AddAccount")]
    public Account Account
    {
      get
      {
        return ((Account)(base.GetValue(AddAccountWorkflow.AccountProperty)));
      }
      set
      {
        base.SetValue(AddAccountWorkflow.AccountProperty, value);
      }
    }

    public void GetAccountType_ExecuteCode(object sender, EventArgs e)
    {
      Account = Account.CreateAccount(SelectedAccountType);
      View view = View.CreateView("metratech.com/contact");
      if (view is ContactView)
      {
        ((ContactView)view).ContactType = ContactType.Bill_To;
      }

      Account.AddView(view, "LDAP");
      view = View.CreateView("metratech.com/internal");
      Account.AddView(view, "Internal");

      ApplyTemplateProperties();
    }



    public void GetGenericAccountType_ExecuteCode(object sender, EventArgs e)
    {
      Account = Account.CreateAccountWithViews(SelectedAccountType);
      View view = View.CreateView("metratech.com/contact");

      try
      {
        if (view is ContactView)
        {
          ((ContactView)view).ContactType = ContactType.Bill_To;
        }

        // Check for LDAP property
        PropertyInfo propertyInfo = Account.GetType().GetProperty("LDAP");
        if (propertyInfo != null)
        {
          Account.AddView(view, "LDAP");
        }
      }
      catch
      {
        // hmmm... if there is no contact view we skip it and do what we can.
      }

      view = View.CreateView("metratech.com/internal");
      Account.AddView(view, "Internal");

      ApplyTemplateProperties();
    }
    #endregion

    #region AddAccount

    
  public static DependencyProperty PriceListsProperty = System.Workflow.ComponentModel.DependencyProperty.Register("PriceLists", typeof(List<MetraTech.Interop.MTProductCatalog.MTPriceList>), typeof(AddAccountWorkflow));
  
  [Description("This is the description which appears in the Property Browser")]
  [Category("This is the category which will be displayed in the Property Browser")]
  [Browsable(true)]
  [EventInputArg("OK_AddAccount")]
  
  public List<MetraTech.Interop.MTProductCatalog.MTPriceList> PriceLists
  {
	  get 
    { 
      return ((List<MetraTech.Interop.MTProductCatalog.MTPriceList>)(base.GetValue(AddAccountWorkflow.PriceListsProperty))); 
    }
    set 
    { 
      base.SetValue(AddAccountWorkflow.PriceListsProperty, value); 
    }
  }



    public static DependencyProperty PasswordProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Password", typeof(string), typeof(AddAccountWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventOutputArg("GeneratePassword_AddAccount")]
    public string Password
    {
      get
      {
        return ((string)(base.GetValue(AddAccountWorkflow.PasswordProperty)));
      }
      set
      {
        base.SetValue(AddAccountWorkflow.PasswordProperty, value);
      }
    }

    public static DependencyProperty NewAccountIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("NewAccountId", typeof(int), typeof(AddAccountWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventOutputArg("OK_AddAccount")]
    [StateInitOutput("AccountCreated")]
    public int NewAccountId
    {
      get
      {
        return ((int)(base.GetValue(AddAccountWorkflow.NewAccountIdProperty)));
      }
      set
      {
        base.SetValue(AddAccountWorkflow.NewAccountIdProperty, value);
      }
    }

    #endregion

    #region CodeActivities
    public void SetOutAccountID_ExecuteCode(object sender, EventArgs e)
    {
      if (Account._AccountID.HasValue)
      {
        this.NewAccountId = Account._AccountID.Value;
      }
      else
      {
        this.NewAccountId = 0;
      }

    }

    public void SetDefaultProperties_ExecuteCode(object sender, EventArgs e)
    {
      Account.AccountStatus = AccountStatus.Active;
      SetFolderProperty();
    }

    public void SetDefaultProperties_SystemUser_ExecuteCode(object sender, EventArgs e)
    {
      Account.AccountStatus = AccountStatus.Active;
      SetFolderProperty();
      ((InternalView)Account.GetInternalView()).Billable = true;
      ((InternalView)Account.GetInternalView()).UsageCycleType = UsageCycleType.Monthly;
      Account.DayOfMonth = 31;
      ((InternalView)Account.GetInternalView()).Currency = "USD";

      Account.Name_Space = "system_user";
      ((SystemAccount)Account).LoginApplication = LoginApplication.CSR;
    }

    public void SetGenericAccountDefaults_ExecuteCode(object sender, EventArgs e)
    {
      Account.AccountStatus = AccountStatus.Active;
      SetFolderProperty();
      ((InternalView)Account.GetInternalView()).Billable = true;
      ((InternalView)Account.GetInternalView()).UsageCycleType = UsageCycleType.Monthly;
      Account.DayOfMonth = 31;
      ((InternalView)Account.GetInternalView()).Currency = "USD";
    }

    public void GeneratePassword_ExecuteCode(object sender, EventArgs e)
    {
      Password = RandomPassword.Generate();
    }

    #endregion

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("Start_AddAccountWithTemplate")]
    public DateTime TemplateEffectiveDate
    {
      get
      {
        return ((System.DateTime)(base.GetValue(MetraCareWorkflowLibrary.AddAccountWorkflow.TemplateEffectiveDateProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.AddAccountWorkflow.TemplateEffectiveDateProperty, value);
      }
    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("Start_AddAccountWithTemplate")]
    public AccountIdentifier TemplateAccount
    {
      get
      {
        return ((AccountIdentifier)(base.GetValue(TemplateAccountProperty)));
      }
      set
      {
        base.SetValue(TemplateAccountProperty, value);
      }
    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    public AccountTemplate AccountTemplate
    {
      get
      {
        return ((MetraTech.DomainModel.ProductCatalog.AccountTemplate)(base.GetValue(MetraCareWorkflowLibrary.AddAccountWorkflow.AccountTemplateProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.AddAccountWorkflow.AccountTemplateProperty, value);
      }
    }

    public YAAC.IMTSessionContext GetSessionContext()
    {
      YAAC.IMTSessionContext retval = null;

      CMASClientIdentity identity = null;
      try
      {
        identity = (CMASClientIdentity)ServiceSecurityContext.Current.PrimaryIdentity;

        retval = (YAAC.IMTSessionContext)identity.SessionContext;
      }
      catch (Exception)
      {
        throw new MASBasicException("Service security identity is of improper type");
      }

      return retval;
    }

    public void SetFolderProperty()
    {
      AccountTypeManager accountTypeManager = new AccountTypeManager();
      IMTAccountType accType = accountTypeManager.GetAccountTypeByName((IMTSessionContext)GetSessionContext(), Account.AccountType);
      IMTSQLRowset rs = accType.GetAllDescendentAccountTypesAsRowset();
      if (rs != null)
      {
        if (rs.RecordCount > 0)
        {
          ((InternalView)Account.GetInternalView()).Folder = true;
        }
        else
        {
          ((InternalView)Account.GetInternalView()).Folder = false;
        }
      }
    }

    public void ApplyTemplateProperties()
    { 
      if(TemplateAccount != null)
      {
        Account.AncestorAccountID = TemplateAccount.AccountID;
      }

      TemplatesApplied = false;

      // Apply account template if any
      if (AccountTemplate != null)
      {
        if (AccountTemplate.Properties.Count > 0)
        {
          TemplatesApplied = true;
        }

        AccountTemplate.ApplyTemplatePropsToAccount(Account);
      }
    }

    public static DependencyProperty BillToContactViewProperty = System.Workflow.ComponentModel.DependencyProperty.Register("BillToContactView", typeof(ContactView), typeof(AddAccountWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public ContactView BillToContactView
    {
      get
      {
        return GetBillToContactView();
      }
      set
      {
        bool foundView = false;
        if (Account == null)
        {
          return;
        }
        Dictionary<string, List<View>> viewDictionary = Account.GetViews();
        foreach (List<View> views in viewDictionary.Values)
        {
          foreach (View view in views)
          {
            ContactView cv = view as ContactView;
            if (cv != null && cv.ContactType == MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.ContactType.Bill_To)
            {
              cv = value;
              foundView = true;
              break;
            }

            if (foundView == true)
            {
              break;
            }
          }

          if (foundView == true)
          {
            break;
          }
        }

        if (foundView == false)
        {
          throw new ApplicationException("Unable to find Bill-To ContactView in Account");
        }
      }
    }

    private ContactView GetBillToContactView()
    {
      ContactView contactView = null;
      bool foundView = false;
      if (Account == null)
      {
        return null;
      }
      Dictionary<string, List<View>> viewDictionary = Account.GetViews();
      foreach (List<View> views in viewDictionary.Values)
      {
        foreach (View view in views)
        {
          ContactView cv = view as ContactView;
          if (cv != null && cv.ContactType == MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.ContactType.Bill_To)
          {
            contactView = cv;
            foundView = true;
            break;
          }

          if (foundView == true)
          {
            break;
          }
        }

        if (foundView == true)
        {
          break;
        }
      }

      return contactView;
    }

    private static MetraTech.Accounts.Type.AccountTypeCollection m_AccountTypesCollection = null;// = new AccountTypeCollection();

    private AccountTypeCollection AccountTypesCollection
    {
      get
      {
        if (m_AccountTypesCollection == null)
        {
          m_AccountTypesCollection = new AccountTypeCollection();
        }

        return m_AccountTypesCollection;
      }
    }
  }
}
