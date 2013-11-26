using System;
using System.Collections.Generic;
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
using MetraTech;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Activities;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Common;
using MetraTech.Approvals;



namespace MetraCareWorkflowLibrary
{
  public class GroupSubscriptionsWorkflow : MTStateMachineWorkflowActivity
  {
    public static DependencyProperty PageStateGuidProperty = System.Workflow.ComponentModel.DependencyProperty.Register("PageStateGuid", typeof(Guid), typeof(GroupSubscriptionsWorkflow));
    public static DependencyProperty AccountTypeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AccountType", typeof(string), typeof(GroupSubscriptionsWorkflow));
    public static DependencyProperty AccountIdentifierProperty = DependencyProperty.Register("AccountIdentifier", typeof(MetraTech.ActivityServices.Common.AccountIdentifier), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    public static DependencyProperty CorporateAccountIdentifierProperty = DependencyProperty.Register("CorporateAccountIdentifier", typeof(MetraTech.ActivityServices.Common.AccountIdentifier), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    public static DependencyProperty GroupSubscriptionListProperty = DependencyProperty.Register("GroupSubscriptionList", typeof(MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.GroupSubscription>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    public static DependencyProperty GroupSubscriptionInstanceProperty = DependencyProperty.Register("GroupSubscriptionInstance", typeof(MetraTech.DomainModel.ProductCatalog.GroupSubscription), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    public static DependencyProperty EffectiveStartDateProperty = DependencyProperty.Register("EffectiveStartDate", typeof(System.DateTime), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    public static DependencyProperty ProductOfferingListProperty = DependencyProperty.Register("ProductOfferingList", typeof(MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.ProductOffering>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));

    public static DependencyProperty ChangeRequestProperty = DependencyProperty.Register("ChangeRequest", typeof(Change), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));

    [Description("ChangeRequest")]
    [Category("ChangeRequest Category")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Change ChangeRequest
    {
      get
      {
        return ((Change)(base.GetValue(GroupSubscriptionsWorkflow.ChangeRequestProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.ChangeRequestProperty, value);
      }
    }


    public enum MODE
    {
      Edit,
      New
    }

    [Description("This stores the page state guid for the SetState Event")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("SetStateEvent")]
    public Guid PageStateGuid
    {
      get
      {
        return ((Guid)(base.GetValue(GroupSubscriptionsWorkflow.PageStateGuidProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.PageStateGuidProperty, value);
      }
    }

    [Description("This stores the account type for the selected account")]
    [Category("InputOutput")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("Start_GroupSubscriptions")]
    public string AccountType
    {
      get
      {
        return ((string)(base.GetValue(GroupSubscriptionsWorkflow.AccountTypeProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.AccountTypeProperty, value);

      }
    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("Start_GroupSubscriptions")]
    [EventInputArg("Edit_ManageGroupSubscriptions")]
    [EventInputArg("Delete_ManageGroupSubscriptions")]
    [EventInputArg("Members_ManageGroupSubscriptions")]
    [EventInputArg("Members_GroupSubscriptionJoin")]

    public MetraTech.ActivityServices.Common.AccountIdentifier AccountIdentifier
    {
      get
      {
        return ((MetraTech.ActivityServices.Common.AccountIdentifier)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.AccountIdentifierProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.AccountIdentifierProperty, value);
      }
    }


    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("Start_GroupSubscriptions")]
    public MetraTech.ActivityServices.Common.AccountIdentifier CorporateAccountIdentifier
    {
      get
      {
        return ((MetraTech.ActivityServices.Common.AccountIdentifier)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.CorporateAccountIdentifierProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.CorporateAccountIdentifierProperty, value);
      }
    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("GetGroupSubscriptionList_ManageGroupSubscriptions")]
    [EventOutputArg("GetGroupSubscriptionList_ManageGroupSubscriptions")]
    [EventInputArg("GetJoinGroupSubscriptionList")]
    [EventOutputArg("GetJoinGroupSubscriptionList")]
    public MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.GroupSubscription> GroupSubscriptionList
    {
      get
      {
        return ((MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.GroupSubscription>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubscriptionListProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubscriptionListProperty, value);
      }
    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("InputOutput")]
    [StateInitOutput("SetGroupSubscriptionDate")]
    [EventInputArg("OK_SetGroupSubscriptionDate")]
    [StateInitOutput("SaveGroupSubscription")]
    [StateInitOutput("DeleteGroupSubscription")]
    [EventInputArg("OK_SetUDRCInstanceValue")]
    [StateInitOutput("SetUDRCInstanceValue")]
    [EventInputArg("GetUDRCInstanceValues")]
    [StateInitOutput("SetUDRCAccount")]
    [EventInputArg("OK_SetUDRCAccount")]
    [StateInitOutput("SetFlatRateRCAccount")]
    [EventInputArg("OK_SetFlatRateRCAccount")]
    [StateInitOutput("AddEdit_UDRCInstanceValues")]
    [EventInputArg("OK_AddEditUDRCValues")]
    [StateInitOutput("SetUDRCValues")]
    [EventInputArg("Save_SetUDRCValues")]


    public MetraTech.DomainModel.ProductCatalog.GroupSubscription GroupSubscriptionInstance
    {
      get
      {
        return ((MetraTech.DomainModel.ProductCatalog.GroupSubscription)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubscriptionInstanceProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubscriptionInstanceProperty, value);
      }
    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("GetGroupPOList_SelectProductOffering")]
    public DateTime EffectiveStartDate
    {
      get
      {
        return ((System.DateTime)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.EffectiveStartDateProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.EffectiveStartDateProperty, value);
      }
    }

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("GetGroupPOList_SelectProductOffering")]
    [EventOutputArg("GetGroupPOList_SelectProductOffering")]
    public MTList<ProductOffering> ProductOfferingList
    {
      get
      {
        return ((MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.ProductOffering>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.ProductOfferingListProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.ProductOfferingListProperty, value);
      }
    }

    public static DependencyProperty ProductOfferingIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ProductOfferingId", typeof(int), typeof(GroupSubscriptionsWorkflow));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("OK_SelectProductOffering")]
    public int ProductOfferingId
    {
      get
      {
        return ((int)(base.GetValue(GroupSubscriptionsWorkflow.ProductOfferingIdProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.ProductOfferingIdProperty, value);
      }
    }

    public static DependencyProperty ModeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Mode", typeof(MODE), typeof(GroupSubscriptionsWorkflow), new PropertyMetadata(MODE.New));

    [Description("Internal workflow property that tells us if we are doing an edit or new subscription")]
    [Category("Internal")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public MODE Mode
    {
      get
      {
        return ((MODE)(base.GetValue(GroupSubscriptionsWorkflow.ModeProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.ModeProperty, value);
      }
    }

    public static DependencyProperty GroupSubscriptionIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("GroupSubscriptionId", typeof(int), typeof(GroupSubscriptionsWorkflow));

    [Description("Group Subscription ID")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("Edit_ManageGroupSubscriptions")]
    [EventInputArg("Delete_ManageGroupSubscriptions")]
    [EventInputArg("OK_DeleteGroupSubscription")]
    [EventInputArg("Members_ManageGroupSubscriptions")]
    [EventInputArg("Members_GroupSubscriptionJoin")]
    [EventInputArg("Edit_GroupSubscriptionMembers")]
    [EventInputArg("OK_AddGroupSubscriptionMembers")]
    [EventInputArg("OK_GroupSubscriptionJoin")]
    [StateInitOutput("SetGroupSubscriptionJoin")]


    public int GroupSubscriptionId
    {
      get
      {
        return ((int)(base.GetValue(GroupSubscriptionsWorkflow.GroupSubscriptionIdProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.GroupSubscriptionIdProperty, value);
      }
    }


    public static DependencyProperty CurrentGroupSubscriptionProperty = System.Workflow.ComponentModel.DependencyProperty.Register("CurrentGroupSubscription", typeof(GroupSubscription), typeof(GroupSubscriptionsWorkflow));

    [Description("Current Group Subscription")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("AddGroupSubscriptionMembers")]
    [StateInitOutput("UnsubscribeGroupSubscriptionMembers")]
    [StateInitOutput("DeleteGroupSubscriptionMembers")]
    [StateInitOutput("SetGroupSubscriptionMember")]
    [StateInitOutput("GroupSubscriptionMembers")]
    [StateInitOutput("DeleteGroupSubscription")]
    [StateInitOutput("SetUDRCInstanceValue")]
    [StateInitOutput("SetGroupSubscriptionJoin")]

    public GroupSubscription CurrentGroupSubscription
    {
      get
      {
        return ((GroupSubscription)(base.GetValue(GroupSubscriptionsWorkflow.CurrentGroupSubscriptionProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.CurrentGroupSubscriptionProperty, value);
      }
    }


    public static DependencyProperty SelectedAccountIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SelectedAccountId", typeof(int), typeof(GroupSubscriptionsWorkflow));

    [Description("Selected Group Subscription Member ID")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("Edit_GroupSubscriptionMembers")]

    public int SelectedAccountId
    {
      get
      {
        return ((int)(base.GetValue(GroupSubscriptionsWorkflow.SelectedAccountIdProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.SelectedAccountIdProperty, value);
      }
    }

    public static DependencyProperty MemberIdCollProperty = System.Workflow.ComponentModel.DependencyProperty.Register("MemberIdColl", typeof(string), typeof(GroupSubscriptionsWorkflow));

    [Description("Collection of Selected Group Subscription Member IDs")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("Delete_GroupSubscriptionMembers")]
    [EventInputArg("Unsubscribe_GroupSubscriptionMembers")]
    [EventInputArg("OK_AddGroupSubscriptionMembers")]

    public string MemberIdColl
    {
      get
      {
        return ((string)(base.GetValue(GroupSubscriptionsWorkflow.MemberIdCollProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.MemberIdCollProperty, value);
      }
    }



    public static DependencyProperty IsNewSubscriptionProperty = System.Workflow.ComponentModel.DependencyProperty.Register("IsNewSubscription", typeof(bool), typeof(GroupSubscriptionsWorkflow));

    [Description("Property indicating a new subscription")]
    [Category("Output")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("SaveGroupSubscription")]
    public bool IsNewSubscription
    {
      get
      {
        return ((bool)(base.GetValue(GroupSubscriptionsWorkflow.IsNewSubscriptionProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.IsNewSubscriptionProperty, value);
      }
    }


    public static DependencyProperty GroupSubscriptionMemberListProperty = DependencyProperty.Register("GroupSubscriptionMemberList", typeof(MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("InputOutput")]
    [EventInputArg("GetMembersList_GroupSubscriptionMembers")]
    [EventOutputArg("GetMembersList_GroupSubscriptionMembers")]
    [EventInputArg("Unsubscribe_GroupSubscriptionMembers")]
    public MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember> GroupSubscriptionMemberList
    {
      get
      {
        return ((MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubscriptionMemberListProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubscriptionMemberListProperty, value);
      }
    }


    public static DependencyProperty SelectedGroupSubscriptionMemberListProperty = DependencyProperty.Register("SelectedGroupSubscriptionMemberList", typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("OK_AddGroupSubscriptionMembers")]
    [EventInputArg("OK_SetGroupSubscriptionJoin")]
    public List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember> SelectedGroupSubscriptionMemberList
    {
      get
      {
        return (List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.SelectedGroupSubscriptionMemberListProperty));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.SelectedGroupSubscriptionMemberListProperty, value);
      }
    }


    public static DependencyProperty SelectedGroupSubscriptionMemberListWithScopeProperty = DependencyProperty.Register("SelectedGroupSubscriptionMemberListWithScope", typeof(Dictionary<AccountIdentifier, AccountTemplateScope>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("OK_AddGroupSubscriptionMembers")]
    public Dictionary<AccountIdentifier, AccountTemplateScope> SelectedGroupSubscriptionMemberListWithScope
    {
      get
      {
        return (Dictionary<AccountIdentifier, AccountTemplateScope>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.SelectedGroupSubscriptionMemberListWithScopeProperty));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.SelectedGroupSubscriptionMemberListWithScopeProperty, value);
      }
    }


    public static DependencyProperty GroupSubTimeSpanProperty = System.Workflow.ComponentModel.DependencyProperty.Register("GroupSubTimeSpan", typeof(MetraTech.DomainModel.BaseTypes.ProdCatTimeSpan), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("OK_AddGroupSubscriptionMembers")]
    public ProdCatTimeSpan GroupSubTimeSpan
    {
      get
      {
        return (ProdCatTimeSpan)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubTimeSpanProperty));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubTimeSpanProperty, value);
      }
    }


    public static DependencyProperty GroupSubscriptionMemberProperty = System.Workflow.ComponentModel.DependencyProperty.Register("GroupSubscriptionMember", typeof(MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember), typeof(GroupSubscriptionsWorkflow));

    [Description("Group Subscription Member")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("SetGroupSubscriptionMember")]
    [EventInputArg("OK_SetGroupSubscriptionMember")]
    [EventInputArg("OK_AddGroupSubscriptionMembers")]
    [EventInputArg("OK_UnsubscribeGroupSubscriptionMembers")]


    public MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember GroupSubscriptionMember
    {
      get
      {
        return ((MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember)(base.GetValue(GroupSubscriptionsWorkflow.GroupSubscriptionMemberProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.GroupSubscriptionMemberProperty, value);
      }
    }

    public static DependencyProperty UDRCInstancesProperty = DependencyProperty.Register("UDRCInstances", typeof(System.Collections.Generic.List<UDRCInstance>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [StateInitOutput("SetUDRCValues")]

    public System.Collections.Generic.List<UDRCInstance> UDRCInstances
    {
      get
      {
        return ((System.Collections.Generic.List<UDRCInstance>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.UDRCInstancesProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.UDRCInstancesProperty, value);
      }
    }


    public static DependencyProperty UDRCInstanceListProperty = DependencyProperty.Register("UDRCInstanceList", typeof(System.Collections.Generic.List<UDRCInstance>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("GetUDRCInstances")]
    [EventOutputArg("GetUDRCInstances")]
    public System.Collections.Generic.List<UDRCInstance> UDRCInstanceList
    {
      get
      {
        return ((System.Collections.Generic.List<UDRCInstance>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.UDRCInstanceListProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.UDRCInstanceListProperty, value);
      }
    }


    public static DependencyProperty FlatRateRCInstancesProperty = DependencyProperty.Register("FlatRateRCInstances", typeof(System.Collections.Generic.List<FlatRateRecurringChargeInstance>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [StateInitOutput("SetUDRCValues")]
    public System.Collections.Generic.List<FlatRateRecurringChargeInstance> FlatRateRCInstances
    {
      get
      {
        return ((System.Collections.Generic.List<FlatRateRecurringChargeInstance>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.FlatRateRCInstancesProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.FlatRateRCInstancesProperty, value);
      }
    }

    public static DependencyProperty SelectedUDRCInstanceIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SelectedUDRCInstanceId", typeof(int), typeof(GroupSubscriptionsWorkflow));

    [Description("Selected UDRC Instance ID")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("AddEditUDRCValues")]
    [EventInputArg("Edit_GroupSubscriptionUDRCChargeAccount")]

    public int SelectedUDRCInstanceId
    {
      get
      {
        return ((int)(base.GetValue(GroupSubscriptionsWorkflow.SelectedUDRCInstanceIdProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.SelectedUDRCInstanceIdProperty, value);
      }
    }


    public static DependencyProperty CurrentUDRCInstanceProperty = DependencyProperty.Register("CurrentUDRCInstance", typeof(MetraTech.DomainModel.ProductCatalog.UDRCInstance), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("InputOutput")]
    [StateInitOutput("SetUDRCInstanceValue")]
    [EventInputArg("GetUDRCInstanceValues")]
    [StateInitOutput("SetUDRCAccount")]
    [StateInitOutput("AddEdit_UDRCInstanceValues")]
    [EventInputArg("OK_SetUDRCAccount")]

    public MetraTech.DomainModel.ProductCatalog.UDRCInstance CurrentUDRCInstance
    {
      get
      {
        return (MetraTech.DomainModel.ProductCatalog.UDRCInstance)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.CurrentUDRCInstanceProperty));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.CurrentUDRCInstanceProperty, value);
      }
    }

    public static DependencyProperty UDRCInstanceValuesProperty = DependencyProperty.Register("UDRCInstanceValues", typeof(System.Collections.Generic.List<UDRCInstanceValue>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("GetUDRCInstanceValues")]
    [EventOutputArg("GetUDRCInstanceValues")]
    [StateInitOutput("AddEdit_UDRCInstanceValues")]
    public System.Collections.Generic.List<UDRCInstanceValue> UDRCInstanceValues
    {
      get
      {
        return ((System.Collections.Generic.List<UDRCInstanceValue>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.UDRCInstanceValuesProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.UDRCInstanceValuesProperty, value);
      }
    }

    public static DependencyProperty FlatRateRCInstanceListProperty = DependencyProperty.Register("FlatRateRCInstanceList", typeof(System.Collections.Generic.List<FlatRateRecurringChargeInstance>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("GetFlatRateRCInstances")]
    [EventOutputArg("GetFlatRateRCInstances")]
    public System.Collections.Generic.List<FlatRateRecurringChargeInstance> FlatRateRCInstanceList
    {
      get
      {
        return ((System.Collections.Generic.List<FlatRateRecurringChargeInstance>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.FlatRateRCInstanceListProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.FlatRateRCInstanceListProperty, value);
      }
    }


    public static DependencyProperty CurrentFlatRateRCInstanceProperty = DependencyProperty.Register("CurrentFlatRateRCInstance", typeof(MetraTech.DomainModel.ProductCatalog.FlatRateRecurringChargeInstance), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("InputOutput")]
    [StateInitOutput("SetFlatRateRCAccount")]

    public MetraTech.DomainModel.ProductCatalog.FlatRateRecurringChargeInstance CurrentFlatRateRCInstance
    {
      get
      {
        return (MetraTech.DomainModel.ProductCatalog.FlatRateRecurringChargeInstance)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.CurrentFlatRateRCInstanceProperty));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.CurrentFlatRateRCInstanceProperty, value);
      }
    }

    public static DependencyProperty SelectedFlatRateRCInstanceIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SelectedFlatRateRCInstanceId", typeof(int), typeof(GroupSubscriptionsWorkflow));

    [Description("Selected Flat Rate Recurring Charge Instance ID")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("Edit_GroupSubscriptionFlatRateRecChargeAccount")]

    public int SelectedFlatRateRCInstanceId
    {
      get
      {
        return ((int)(base.GetValue(GroupSubscriptionsWorkflow.SelectedFlatRateRCInstanceIdProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.SelectedFlatRateRCInstanceIdProperty, value);
      }
    }

    public static DependencyProperty SelectedUDRCValueIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SelectedUDRCValueId", typeof(int), typeof(GroupSubscriptionsWorkflow));

    [Description("Selected UDRC Value ID")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("Set_UDRCInstanceValue")]

    public int SelectedUDRCValueId
    {
      get
      {
        return ((int)(base.GetValue(GroupSubscriptionsWorkflow.SelectedUDRCValueIdProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.SelectedUDRCValueIdProperty, value);
      }
    }

    public static DependencyProperty CurrentUDRCValueProperty = DependencyProperty.Register("CurrentUDRCValue", typeof(MetraTech.DomainModel.ProductCatalog.UDRCInstanceValue), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("InputOutput")]
    [StateInitOutput("AddEdit_UDRCInstanceValues")]

    public MetraTech.DomainModel.ProductCatalog.UDRCInstanceValue CurrentUDRCValue
    {
      get
      {
        return (MetraTech.DomainModel.ProductCatalog.UDRCInstanceValue)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.CurrentUDRCValueProperty));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.CurrentUDRCValueProperty, value);
      }
    }

    public static DependencyProperty udrcValuesCollProperty = DependencyProperty.Register("udrcValuesColl", typeof(Dictionary<string, List<UDRCInstanceValue>>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("InputOutput")]
    [StateInitOutput("AddEdit_UDRCInstanceValues")]
    [EventInputArg("OK_AddEditUDRCValues")]

    public Dictionary<string, List<UDRCInstanceValue>> udrcValuesColl
    {
      get
      {
        return (Dictionary<string, List<UDRCInstanceValue>>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.udrcValuesCollProperty));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.udrcValuesCollProperty, value);
      }
    }


    public static DependencyProperty GroupSubUDRCInstancesProperty = DependencyProperty.Register("GroupSubUDRCInstances", typeof(System.Collections.Generic.List<UDRCInstance>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("GetGroupSubscriptionUDRCInstances")]
    [EventOutputArg("GetGroupSubscriptionUDRCInstances")]
    public System.Collections.Generic.List<UDRCInstance> GroupSubUDRCInstances
    {
      get
      {
        return ((System.Collections.Generic.List<UDRCInstance>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubUDRCInstancesProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubUDRCInstancesProperty, value);
      }
    }


    public static DependencyProperty GroupSubFRRCInstancesProperty = DependencyProperty.Register("GroupSubFRRCInstances", typeof(System.Collections.Generic.List<FlatRateRecurringChargeInstance>), typeof(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow));
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [EventInputArg("GetGroupSubscriptionFlatRateRCInstances")]
    [EventOutputArg("GetGroupSubscriptionFlatRateRCInstances")]
    public System.Collections.Generic.List<FlatRateRecurringChargeInstance> GroupSubFRRCInstances
    {
      get
      {
        return ((System.Collections.Generic.List<FlatRateRecurringChargeInstance>)(base.GetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubFRRCInstancesProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.GroupSubscriptionsWorkflow.GroupSubFRRCInstancesProperty, value);
      }
    }

    public static DependencyProperty IsApprovalEnabledProperty = DependencyProperty.Register("IsApprovalEnabled", typeof(bool), typeof(GroupSubscriptionsWorkflow));

    [Description("Whether Approval Enabled")]
    [Category("Approvals")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("OK_AddGroupSubscriptionMembers")]
    [EventInputArg("OK_DeleteGroupSubscriptionMembers")]
    [EventInputArg("OK_UnsubscribeGroupSubscriptionMembers")]
    [EventInputArg("OK_SetGroupSubscriptionMember")]
    [EventInputArg("OK_SetGroupSubscriptionJoin")]
    public bool IsApprovalEnabled
    {
      get
      {
        return ((bool)(base.GetValue(GroupSubscriptionsWorkflow.IsApprovalEnabledProperty)));
      }
      set
      {
        base.SetValue(GroupSubscriptionsWorkflow.IsApprovalEnabledProperty, value);
      }
    }


    //Submit Add Member Hierarchies GS (Add Member Hierarchies) change to Approval Framework  
    public void ApprovalSetupAMH_ExecuteCode(object sender, EventArgs e)
    {
      // APPROVALS

      var change = new Change
      {
        ChangeType = "GroupSubscription.AddMemberHierarchies",
        UniqueItemId = GroupSubscriptionId.ToString(),
        ItemDisplayName = CurrentGroupSubscription.Name,

      };
      
      var help = new ChangeDetailsHelper();
      
      help["accounts"] = SelectedGroupSubscriptionMemberListWithScope;
      help["groupSubscriptionId"] = GroupSubscriptionId;
      help["subscriptionSpan"] = GroupSubTimeSpan;

      change.ChangeDetailsBlob = help.ToXml();

      ChangeRequest = change;
    }

    //Submit Delete Group Subscription Member (Delete Members)change to Approval Framework
    public void ApprovalSetupDGSM_ExecuteCode(object sender, EventArgs e)
    {
      // APPROVALS

      var change = new Change
      {
        ChangeType = "GroupSubscription.DeleteMembers",
        UniqueItemId = GroupSubscriptionId.ToString(),
        ItemDisplayName = CurrentGroupSubscription.Name,

      };

      var help = new ChangeDetailsHelper();
      help["groupSubscriptionMembers"] = SelectedGroupSubscriptionMemberList; //GroupSubscriptionMember;
      help["groupSubscriptionId"] = GroupSubscriptionId;

      change.ChangeDetailsBlob = help.ToXml();
      ChangeRequest = change;
    }

    //Submit Unsubscribe Group Subscription Members (Unsubscribe Members)change to Approval Framework
    public void ApprovalSetupUGSM_ExecuteCode(object sender, EventArgs e)
    {
      // APPROVALS

      var change = new Change
      {
        ChangeType = "GroupSubscription.UnsubscribeMembers",
        UniqueItemId = GroupSubscriptionId.ToString(),
        ItemDisplayName = CurrentGroupSubscription.Name,

      };

      var help = new ChangeDetailsHelper();
      help["groupSubscriptionMembers"] = SelectedGroupSubscriptionMemberList;// GroupSubscriptionMember;
      help["groupSubscriptionId"] = GroupSubscriptionId;
      help["subscriptionSpan"] = GroupSubTimeSpan;

      change.ChangeDetailsBlob = help.ToXml();
      ChangeRequest = change;
    }

    //Submit Add Set Group Subscription Member (Update Member)change to Approval Framework
    public void ApprovalSetupSGSM_ExecuteCode(object sender, EventArgs e)
    {
      // APPROVALS

      var change = new Change
      {
        ChangeType = "GroupSubscription.UpdateMember",
        UniqueItemId = GroupSubscriptionId.ToString(),
        ItemDisplayName = CurrentGroupSubscription.Name,

      };

      var help = new ChangeDetailsHelper();
      help["groupSubscriptionMember"] = GroupSubscriptionMember;
      help["groupSubscriptionId"] = GroupSubscriptionId;
      help["subscriptionSpan"] = GroupSubTimeSpan;

      change.ChangeDetailsBlob = help.ToXml();
      ChangeRequest = change;
    }

    //Submit Add Set Group Subscription Join (Add Single Member) change to Approval Framework
    public void ApprovalSetupSGSJ_ExecuteCode(object sender, EventArgs e)
    {
      // APPROVALS

      var change = new Change
      {
        ChangeType = "GroupSubscription.AddMembers",
        UniqueItemId = GroupSubscriptionId.ToString(),
        ItemDisplayName = CurrentGroupSubscription.Name,

      };

      var help = new ChangeDetailsHelper();
      help["groupSubscriptionMembers"] = SelectedGroupSubscriptionMemberList; //GroupSubscriptionMember;
      help["groupSubscriptionId"] = GroupSubscriptionId;
      help["subscriptionSpan"] = GroupSubTimeSpan;

      change.ChangeDetailsBlob = help.ToXml();
      ChangeRequest = change;
    }

    
    public void GetGroupSubscriptionInstance_ExecuteCode(object sender, EventArgs e)
    {
      GroupSubscriptionInstance = new GroupSubscription();
      GroupSubscriptionInstance.ProductOfferingId = this.ProductOfferingId;
      GroupSubscriptionInstance.ProductOffering = new ProductOffering();
      GroupSubscriptionInstance.ProductOffering.EffectiveTimeSpan = new ProdCatTimeSpan();
      GroupSubscriptionInstance.SubscriptionSpan = new ProdCatTimeSpan();

      // Go get product offering from id, and set the instance
      foreach (ProductOffering po in this.ProductOfferingList.Items)
      {
        if (po.ProductOfferingId == this.ProductOfferingId)
        {
          GroupSubscriptionInstance.ProductOffering = po;
          break;
        }
      }
      GroupSubscriptionInstance.SupportsGroupOperations = true;
      
    }

    public void SetModeToNewSubscription_ExecuteCode(object sender, EventArgs e)
    {
      Mode = MODE.New;
    }

    public void SetModeToEdit_ExecuteCode(object sender, EventArgs e)
    {
      Mode = MODE.Edit;
    }

    public void ValidateSubscription_ExecuteCode(object sender, EventArgs e)
    {
      //TODO:  validate subscription object off domain model.
    }


    public void SetIsNewSubscription_ExecuteCode(object sender, EventArgs e)
    {
      if (this.Mode == MODE.New)
      {
        IsNewSubscription = true;
      }
      else
      {
        IsNewSubscription = false;
      }
    }

    public void GetSelectedGroupSubscriptionMember_ExecuteCode(object sender, EventArgs e)
    {
      foreach (GroupSubscriptionMember gsm in GroupSubscriptionMemberList.Items)
      {
        if (gsm.AccountId.Value == SelectedAccountId)
        {
          GroupSubscriptionMember = gsm;
        }
      }
    }

    public void GetSelectedGroupSubscriptionMemberList_ExecuteCode(object sender, EventArgs e)
    {
      string[] MemberIds = MemberIdColl.Split(',');
      SelectedGroupSubscriptionMemberList = new List<GroupSubscriptionMember>();

      foreach (GroupSubscriptionMember gsm in this.GroupSubscriptionMemberList.Items)
      {
        for (int i = 0; i < MemberIds.Length; i++)
        {
          if (gsm.AccountId.Value == Convert.ToInt32(MemberIds[i]))
          {
            SelectedGroupSubscriptionMemberList.Add(gsm);

          }
        }
      }
    }

    public void GetCurrentGroupSubscription_ExecuteCode(object sender, EventArgs e)
    {
      CurrentGroupSubscription = new GroupSubscription();

      foreach (GroupSubscription grpSub in this.GroupSubscriptionList.Items)
      {
        if (grpSub.GroupId.Value == GroupSubscriptionId)
        {
          CurrentGroupSubscription = grpSub;
        }
      }
    }

    public void CreateGroupSubscriptionMemberList_ExecuteCode(object sender, EventArgs e)
    {/*
      SelectedGroupSubscriptionMemberList = new List<GroupSubscriptionMember>();

      string[] MemberIds = MemberIdColl.Split(',');
      
      for (int i = 0; i < MemberIds.Length; i++)
      {
        GroupSubscriptionMember gsmInstance = new MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember();
        gsmInstance.AccountId = Convert.ToInt32(MemberIds[i]);
        gsmInstance.AccountName = CurrentGroupSubscription.Name;
        gsmInstance.GroupId = CurrentGroupSubscription.GroupId.Value;
        gsmInstance.MembershipSpan = new ProdCatTimeSpan();
        gsmInstance.MembershipSpan.StartDate = GroupSubscriptionMember.MembershipSpan.StartDate;
        gsmInstance.MembershipSpan.EndDate = GroupSubscriptionMember.MembershipSpan.EndDate;
        SelectedGroupSubscriptionMemberList.Add(gsmInstance);

      }
      */

      //set the timespan
      GroupSubTimeSpan = new ProdCatTimeSpan();
      GroupSubTimeSpan.StartDate = GroupSubscriptionMember.MembershipSpan.StartDate;
      GroupSubTimeSpan.EndDate = GroupSubscriptionMember.MembershipSpan.EndDate;

      SelectedGroupSubscriptionMemberListWithScope = new Dictionary<AccountIdentifier, AccountTemplateScope>();

      //each item should be in form   ACCID:SCOPE
      string[] accIDScopeArr = MemberIdColl.Split(',');

      for (int i = 0; i < accIDScopeArr.Length; i++)
      {
        string[] parts = accIDScopeArr[i].Split(':');

        int accID = int.Parse(parts[0]);
        string scope = (parts.Length == 2) ? parts[1] : "0";
        AccountTemplateScope objScope = (AccountTemplateScope)int.Parse(scope);

        SelectedGroupSubscriptionMemberListWithScope.Add(new AccountIdentifier(accID), objScope);
      }

      this.GroupSubscriptionId = CurrentGroupSubscription.GroupId.Value;
    }


    public void UnsubscribeGroupSubscriptionMemberList_ExecuteCode(object sender, EventArgs e)
    {
      string[] MemberIds = MemberIdColl.Split(',');
      SelectedGroupSubscriptionMemberList = new List<GroupSubscriptionMember>();

      foreach (GroupSubscriptionMember gsm in this.GroupSubscriptionMemberList.Items)
      {
        for (int i = 0; i < MemberIds.Length; i++)
        {
          if (gsm.AccountId.Value == Convert.ToInt32(MemberIds[i]))
          {
            gsm.MembershipSpan.EndDate = GroupSubscriptionMember.MembershipSpan.EndDate;
            SelectedGroupSubscriptionMemberList.Add(gsm);

          }
        }
      }
    }


    public void GetUDRCInstances_ExecuteCode(object sender, EventArgs e)
    {
      UDRCInstanceList = new List<UDRCInstance>();
      UDRCInstanceList.AddRange(UDRCInstances);
    }

    public void GetFlatRateRCInstances_ExecuteCode(object sender, EventArgs e)
    {
      FlatRateRCInstanceList = new List<FlatRateRecurringChargeInstance>();
      foreach (FlatRateRecurringChargeInstance frrc in FlatRateRCInstances)
      {
        if (!frrc.ChargePerParticipant)
        {
          FlatRateRCInstanceList.Add(frrc);
        }
        else
        {
          GroupSubscriptionInstance.FlatRateRecurringChargeInstances = new List<FlatRateRecurringChargeInstance>();
          GroupSubscriptionInstance.FlatRateRecurringChargeInstances.Add(frrc);
        }
      }

    }

    public void GetCurrentUDRCInstance_ExecuteCode(object sender, EventArgs e)
    {
      CurrentUDRCInstance = new UDRCInstance();
      foreach (UDRCInstance urdcInstance in GroupSubUDRCInstances)
      {
        if (urdcInstance.ID == SelectedUDRCInstanceId)
        {
          CurrentUDRCInstance = urdcInstance;
        }
      }
    }

    public void GetUDRCInstanceValues_ExecuteCode(object sender, EventArgs e)
    {
      UDRCInstanceValues = new List<UDRCInstanceValue>();
      if ((GroupSubscriptionInstance.UDRCValues == null) || (GroupSubscriptionInstance.UDRCValues.Count == 0))
      {

      }
      else
      {
        foreach (KeyValuePair<string, List<UDRCInstanceValue>> kvp in GroupSubscriptionInstance.UDRCValues)
        {
          MTTemporalList<UDRCInstanceValue> temporalList = new MTTemporalList<UDRCInstanceValue>("StartDate",
                                                                                                 "EndDate");
          foreach (UDRCInstanceValue udrcInstanceValue in kvp.Value)
          {
            if (udrcInstanceValue.UDRC_Id == SelectedUDRCInstanceId)
            {
              UDRCInstanceValues.Add(udrcInstanceValue);
            }
          }
        }
      }
    }


    public void GetSelectedFlatRateRCInstance_ExecuteCode(object sender, EventArgs e)
    {
      CurrentFlatRateRCInstance = new FlatRateRecurringChargeInstance();
      foreach (FlatRateRecurringChargeInstance frrcInstance in GroupSubFRRCInstances)
      {
        if (frrcInstance.ID == SelectedFlatRateRCInstanceId)
        {
          CurrentFlatRateRCInstance = frrcInstance;
        }
      }
    }


    public void GetSelectedUDRCValue_ExecuteCode(object sender, EventArgs e)
    {
      CurrentUDRCValue = new UDRCInstanceValue();
      foreach (UDRCInstanceValue udrcValue in UDRCInstanceValues)
      {
        if (udrcValue.UDRC_Id == SelectedUDRCValueId)
        {
          CurrentUDRCValue = udrcValue;
        }
      }
    }

    public void GetCurrentGroupSubscriptionUDRCInstances_ExecuteCode(object sender, EventArgs e)
    {
      if ((GroupSubscriptionInstance.UDRCInstances == null) || (GroupSubscriptionInstance.UDRCInstances.Count == 0))
      {
        GroupSubscriptionInstance.UDRCInstances = new List<UDRCInstance>();
        GroupSubscriptionInstance.UDRCInstances.AddRange(UDRCInstances);
      }

      GroupSubUDRCInstances = new List<UDRCInstance>();
      GroupSubUDRCInstances.AddRange(GroupSubscriptionInstance.UDRCInstances);
    }



    public void GetCurrentGroupSubscriptionFRRCInstances_ExecuteCode(object sender, EventArgs e)
    {
      /*GroupSubFRRCInstances = new List<FlatRateRecurringChargeInstance>();

      if ((GroupSubscriptionInstance.FlatRateRecurringChargeInstances == null) || (GroupSubscriptionInstance.FlatRateRecurringChargeInstances.Count == 0))
      {
        foreach (FlatRateRecurringChargeInstance frrc in FlatRateRCInstances)
        {
          GroupSubFRRCInstances.Add(frrc);
        }
      }
      else
      {
        GroupSubFRRCInstances.AddRange(GroupSubscriptionInstance.FlatRateRecurringChargeInstances);
        /*foreach (FlatRateRecurringChargeInstance frrc in FlatRateRCInstances)
        {
          foreach (FlatRateRecurringChargeInstance gsfrrc in GroupSubscriptionInstance.FlatRateRecurringChargeInstances)
          {
            if ((gsfrrc.ID != frrc.ID)) //&& (!frrc.ChargePerParticipant))
            {              
                GroupSubFRRCInstances.Add(frrc);              
            }
          }
        }*/


      if ((GroupSubscriptionInstance.FlatRateRecurringChargeInstances == null) || (GroupSubscriptionInstance.FlatRateRecurringChargeInstances.Count == 0))
      {
        GroupSubscriptionInstance.FlatRateRecurringChargeInstances = new List<FlatRateRecurringChargeInstance>();
        GroupSubscriptionInstance.FlatRateRecurringChargeInstances.AddRange(FlatRateRCInstances);
      }

      GroupSubFRRCInstances = new List<FlatRateRecurringChargeInstance>();
      GroupSubFRRCInstances.AddRange(GroupSubscriptionInstance.FlatRateRecurringChargeInstances);
    }
      
    


  }
}
