using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using MetraTech.Approvals;
using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Activities;
using MetraTech.ActivityServices.Common;
using System.Collections.Generic;
using System.Reflection;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using MetraTech;

namespace MetraCareWorkflowLibrary
{
  public class UpdateAccountWorkflow : MetraTech.ActivityServices.Activities.MTStateMachineWorkflowActivity
  {

    #region Account Type Constants used for Case statement
    public const string CONST_SystemAccount = "SystemAccount";
    public const string CONST_CoreSubscriber = "CoreSubscriber";
    public const string CONST_IndependentAccount = "IndependentAccount";
    public const string CONST_DepartmentAccount = "DepartmentAccount";
    public const string CONST_CorporateAccount = "CorporateAccount";
    #endregion

    public static DependencyProperty ChangeRequestProperty = DependencyProperty.Register("ChangeRequest", typeof(Change), typeof(UpdateAccountWorkflow));

    [Description("ChangeRequest")]
    [Category("ChangeRequest Category")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Change ChangeRequest
    {
      get
      {
        return ((Change)(base.GetValue(UpdateAccountWorkflow.ChangeRequestProperty)));
      }
      set
      {
        base.SetValue(UpdateAccountWorkflow.ChangeRequestProperty, value);
      }
    }


    public static DependencyProperty IsApprovalEnabledProperty = DependencyProperty.Register("IsApprovalEnabled", typeof(bool), typeof(UpdateAccountWorkflow));

    [Description("Whether Approval Enabled")]
    [Category("Approvals")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("OK_UpdateAccount")]
    public bool IsApprovalEnabled
    {
      get
      {
        return ((bool)(base.GetValue(UpdateAccountWorkflow.IsApprovalEnabledProperty)));
      }
      set
      {
        base.SetValue(UpdateAccountWorkflow.IsApprovalEnabledProperty, value);
      }
    }

    public static DependencyProperty ApplyAccountTemplatesProperty = DependencyProperty.Register("ApplyAccountTemplates", typeof(bool), typeof(UpdateAccountWorkflow));

    [DescriptionAttribute("ApplyAccountTemplates")]
    [CategoryAttribute("ApplyAccountTemplates Category")]
    [BrowsableAttribute(true)]
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [EventInputArg("OK_UpdateAccount")]
    public bool ApplyAccountTemplates
    {
      get 
      {
        return ((bool)(base.GetValue(UpdateAccountWorkflow.ApplyAccountTemplatesProperty)));
      }
      set
      {
        base.SetValue(UpdateAccountWorkflow.ApplyAccountTemplatesProperty, value);
      }
    }

    public static DependencyProperty PriceListCollProperty = DependencyProperty.Register("PriceListColl", typeof(System.Collections.Generic.List<PriceList>), typeof(MetraCareWorkflowLibrary.UpdateAccountWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [StateInitOutput("UpdateAccount")]
    [StateInitOutput("GenericUpdateAccount")]
    public List<PriceList> PriceListColl
    {
      get
      {
        return ((System.Collections.Generic.List<PriceList>)(base.GetValue(MetraCareWorkflowLibrary.UpdateAccountWorkflow.PriceListCollProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.UpdateAccountWorkflow.PriceListCollProperty, value);
      }
    }

    public static DependencyProperty UpdateAccountIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("UpdateAccountId", typeof(AccountIdentifier), typeof(UpdateAccountWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("Start_UpdateAccount")]
    public AccountIdentifier UpdateAccountId
    {
      get
      {
        return ((AccountIdentifier)(base.GetValue(UpdateAccountWorkflow.UpdateAccountIdProperty)));
      }
      set
      {
        base.SetValue(UpdateAccountWorkflow.UpdateAccountIdProperty, value);
      }
    }

    public static DependencyProperty AccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Account", typeof(Account), typeof(UpdateAccountWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("UpdateAccount")]
    [StateInitOutput("GenericUpdateAccount")]
    [StateInitOutput("UpdateSystemAccount")]
    [EventInputArg("OK_UpdateAccount")]
    [StateInitOutput("AccountUpdated")]
    public Account Account
    {
      get
      {
        return ((Account)(base.GetValue(UpdateAccountWorkflow.AccountProperty)));
      }
      set
      {
        base.SetValue(UpdateAccountWorkflow.AccountProperty, value);
      }
    }

    public void LoadAccountActivity_ExecuteCode(object sender, EventArgs e)
    {
      LoadAccount_Timestamp = LoadTime;
 	  }

 	  public static DependencyProperty LoadTimeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("LoadTime", typeof(DateTime), typeof(UpdateAccountWorkflow));
 	
 	  [Description("This is the description which appears in the Property Browser")]
 	  [Category("This is the category which will be displayed in the Property Browser")]
 	  [Browsable(true)]
 	  [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
 	  [EventInputArg("Start_UpdateAccount")]
 	  [EventInputArg("OK_UpdateAccount")]
 	  public DateTime LoadTime
 	  {
 	    get
 	    {
 	      return ((DateTime)(base.GetValue(UpdateAccountWorkflow.LoadTimeProperty)));
 	    }
 	    set
 	    {
 	      base.SetValue(UpdateAccountWorkflow.LoadTimeProperty, value);
 	    }
 	  }
    
    public DateTime LoadAccount_Timestamp = default(System.DateTime);

    public static DependencyProperty PageStateGuidProperty = DependencyProperty.Register("PageStateGuid", typeof(System.Guid), typeof(MetraCareWorkflowLibrary.UpdateAccountWorkflow));

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Inputs")]
    [EventInputArg("SetStateEvent")]
    public Guid PageStateGuid
    {
      get
      {
        return ((System.Guid)(base.GetValue(MetraCareWorkflowLibrary.UpdateAccountWorkflow.PageStateGuidProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.UpdateAccountWorkflow.PageStateGuidProperty, value);
      }
    }

    public void ApprovalSetup_ExecuteCode(object sender, EventArgs e)
    {
      // APPROVALS

      var change = new Change {
        
        ChangeType = "AccountUpdate", 
        UniqueItemId = Account._AccountID.ToString(),
        ItemDisplayName = Account.UserName,
        
      };

      var help = new ChangeDetailsHelper();
      help["Account"] = Account;
      change.ChangeDetailsBlob = help.ToXml();
      ChangeRequest = change;
    }

    public void AddBillTo_ExecuteCode(object sender, EventArgs e)
    {
      try
      {
        List<ContactView> list = (List<ContactView>)Account.GetType().GetProperty("LDAP", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.Instance | BindingFlags.IgnoreCase).GetValue(Account, null);

        if (list.Count == 0)
        {
          ContactView c = new ContactView();
          //c.Country = CountryName.USA;
          c.ContactType = ContactType.Bill_To;
          ((List<ContactView>)Account.GetType().GetProperty("LDAP", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.Instance | BindingFlags.IgnoreCase).GetValue(Account, null)).Add(c);
        }
      }
      catch
      {
        // Maybe the account doesn't have an LDAP property.  So, we ignore it.
      }
    }

      public void PayerAndAncestorCheck1_ExecuteCode(object sender, EventArgs e)
      {
          if (Account.AncestorAccountID.HasValue)
          {
              Account.AncestorAccountNS = null;
              Account.AncestorAccount = null;
  }
          if (Account.PayerID.HasValue)
          {
              Account.PayerAccountNS = null;
              Account.PayerAccount = null;
          }
      }

      public static DependencyProperty BillToContactViewProperty = System.Workflow.ComponentModel.DependencyProperty.Register("BillToContactView", typeof(ContactView), typeof(UpdateAccountWorkflow));

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
          if (cv != null &&
              cv.ContactType == MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.ContactType.Bill_To)
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

  }
}
