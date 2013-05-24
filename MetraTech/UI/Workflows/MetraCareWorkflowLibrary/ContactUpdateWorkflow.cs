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
using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Activities;
using System.Collections.Generic;
using System.Reflection;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech;
using MetraTech.Approvals;

namespace MetraCareWorkflowLibrary
{
  public class ContactUpdateWorkflow : MetraTech.ActivityServices.Activities.MTStateMachineWorkflowActivity
	{

    public static DependencyProperty ChangeRequestProperty = DependencyProperty.Register("ChangeRequest", typeof(Change), typeof(ContactUpdateWorkflow));

    [Description("ChangeRequest")]
    [Category("ChangeRequest Category")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Change ChangeRequest
    {
      get
      {
        return ((Change)(base.GetValue(ContactUpdateWorkflow.ChangeRequestProperty)));
      }
      set
      {
        base.SetValue(ContactUpdateWorkflow.ChangeRequestProperty, value);
      }
    }

 
    public static DependencyProperty UpdateAccountIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("UpdateAccountId", typeof(AccountIdentifier), typeof(ContactUpdateWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [EventInputArg("Start_ContactUpdate")]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public AccountIdentifier UpdateAccountId
    {
      get
      {
        return ((AccountIdentifier)(base.GetValue(ContactUpdateWorkflow.UpdateAccountIdProperty)));
      }
      set
      {
        base.SetValue(ContactUpdateWorkflow.UpdateAccountIdProperty, value);
      }
    }

    public static DependencyProperty AccountContactListProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AccountContactList", typeof(ArrayList), typeof(ContactUpdateWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventOutputArg("Get_ContactList")]
    public ArrayList AccountContactList
    {
      get
      {
        return ((ArrayList)(base.GetValue(ContactUpdateWorkflow.AccountContactListProperty)));
      }
      set
      {
        base.SetValue(ContactUpdateWorkflow.AccountContactListProperty, value);
      }
    }

    public static DependencyProperty ContactTypeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ContactType", typeof(int), typeof(ContactUpdateWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("SelectContact_ContactList")]
    public int? ContactType
    {
      get
      {
        return ((int)(base.GetValue(ContactUpdateWorkflow.ContactTypeProperty)));
      }
      set
      {
        base.SetValue(ContactUpdateWorkflow.ContactTypeProperty, value);
      }
    }

    public void ProcessLoadedContacts_ExecuteCode(object sender, EventArgs e)
    {
      // Store contacts in ArrayList
      AccountContactList = new ArrayList();
      AccountContactList.AddRange(LoadedAccountContacts);
    }

    public static DependencyProperty SelectedContactProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SelectedContact", typeof(ContactView), typeof(ContactUpdateWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("UpdateContact")]
    [EventInputArg("OK_UpdateContact")]
    public ContactView SelectedContact
    {
      get
      {
        return ((ContactView)(base.GetValue(ContactUpdateWorkflow.SelectedContactProperty)));
      }
      set
      {
        base.SetValue(ContactUpdateWorkflow.SelectedContactProperty, value);
      }
    }

    public static DependencyProperty AccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Account", typeof(Account), typeof(ContactUpdateWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Account Account
    {
      get
      {
        return ((Account)(base.GetValue(ContactUpdateWorkflow.AccountProperty)));
      }
      set
      {
        base.SetValue(ContactUpdateWorkflow.AccountProperty, value);
      }
    }

    public void ApprovalSetup_ExecuteCode(object sender, EventArgs e)
    {
      // APPROVALS

      var change = new Change
      {
        ChangeType = "AccountUpdate",
        UniqueItemId = Account._AccountID.ToString(),
        ItemDisplayName = Account.UserName,
      };

      var help = new ChangeDetailsHelper();
      help["Account"] = Account;
      change.ChangeDetailsBlob = help.ToXml();
      ChangeRequest = change;
    }

    
    
    public void UpdateContactInfo_ExecuteCode(object sender, EventArgs e)
    {
      BindingFlags memberAccess = BindingFlags.Public | BindingFlags.NonPublic |
          BindingFlags.Static | BindingFlags.Instance | BindingFlags.IgnoreCase;
      List<ContactView> views = Account.GetType().GetProperty("LDAP", memberAccess).GetValue(Account, null) as List<ContactView>;
      int i = 0;
      bool isMatch = false;
      foreach (ContactView view in views)
      {
        if (view.ContactType == (MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.ContactType?)ContactType)
        {
          isMatch = true;
          break;
        }
        i++;
      }

      if (isMatch)
      {
        views[i] = SelectedContact;
      }
      else
      {
        views.Add(SelectedContact);
      }
    }

    public List<View> LoadedAccountContacts = new System.Collections.Generic.List<View>();
    public DateTime LoadAccount_Timestamp = default(System.DateTime);

    public void SetTimestamp_ExecuteCode(object sender, EventArgs e)
    {
      LoadAccount_Timestamp = MetraTime.Now;
    }

    public static DependencyProperty PageStateGuidProperty = DependencyProperty.Register("PageStateGuid", typeof(System.Guid), typeof(MetraCareWorkflowLibrary.ContactUpdateWorkflow));

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Inputs")]
    [EventInputArg("SetStateEvent")]
    public Guid PageStateGuid
    {
      get
      {
        return ((System.Guid)(base.GetValue(MetraCareWorkflowLibrary.ContactUpdateWorkflow.PageStateGuidProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.ContactUpdateWorkflow.PageStateGuidProperty, value);
      }
    }

    public void NewContactView_ExecuteCode(object sender, EventArgs e)
    {
      SelectedContact = new ContactView();
    }

    public void SelectContact_ExecuteCode(object sender, EventArgs e)
    {
      foreach (ContactView contact in AccountContactList)
      {
        if (contact.ContactType == (ContactType?)ContactType)
        {
          SelectedContact = contact;
          break;
        }
      }
    }
	}

}
