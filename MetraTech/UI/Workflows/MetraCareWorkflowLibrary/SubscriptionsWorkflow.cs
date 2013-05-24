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
using MetraTech.ActivityServices.Activities;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;

namespace MetraCareWorkflowLibrary
{
  public class SubscriptionsWorkflow : MTStateMachineWorkflowActivity
	{
    public static DependencyProperty UDRCInstancesProperty = DependencyProperty.Register("UDRCInstances", typeof(System.Collections.Generic.List<UDRCInstance>), typeof(MetraCareWorkflowLibrary.SubscriptionsWorkflow));
  
    public enum MODE
    {
      Edit,
      New
    }


    public static DependencyProperty IsNewSubscriptionProperty = System.Workflow.ComponentModel.DependencyProperty.Register("IsNewSubscription", typeof(bool), typeof(SubscriptionsWorkflow));

    [Description("Property indicating a new subscription")]
    [Category("Ouitput")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("SaveSubscription")]
    public bool IsNewSubscription
    {
      get
      {
        return ((bool)(base.GetValue(SubscriptionsWorkflow.IsNewSubscriptionProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.IsNewSubscriptionProperty, value);
      }
    }

    public static DependencyProperty PageStateGuidProperty = System.Workflow.ComponentModel.DependencyProperty.Register("PageStateGuid", typeof(Guid), typeof(SubscriptionsWorkflow));

    [Description("This stores the page state guid for the SetState Event")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("SetStateEvent")]
    public Guid PageStateGuid
    {
      get
      {
        return ((Guid)(base.GetValue(SubscriptionsWorkflow.PageStateGuidProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.PageStateGuidProperty, value);
      }
    }

    public static DependencyProperty AccountIdentifierProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AccountIdentifier", typeof(AccountIdentifier), typeof(SubscriptionsWorkflow));

    [Description("The Account Identifier for the subscriber account")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("Start_Subscriptions")]
    public AccountIdentifier AccountIdentifier
    {
      get
      {
        return ((AccountIdentifier)(base.GetValue(SubscriptionsWorkflow.AccountIdentifierProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.AccountIdentifierProperty, value);
      }
    }


    public static DependencyProperty SubscriptionsListProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SubscriptionsList", typeof(MTList<Subscription>), typeof(SubscriptionsWorkflow));

    
    [Description("A list of SubscribedProductOffering's")]
    [Category("InputOutput")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("GetSubscriptionsList_ManageSubscriptions")]
    [EventOutputArg("GetSubscriptionsList_ManageSubscriptions")]
    public MTList<Subscription> SubscriptionsList
    {
      get
      {
        return ((MTList<Subscription>)(base.GetValue(SubscriptionsWorkflow.SubscriptionsListProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.SubscriptionsListProperty, value);
      }
    }


    public static DependencyProperty POListProperty = System.Workflow.ComponentModel.DependencyProperty.Register("POList", typeof(MTList<ProductOffering>), typeof(SubscriptionsWorkflow));

    [Description("A list of available Product Offerings for Subscription")]
    [Category("InputOutput")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("GetPOList_SelectPO")]
    [EventOutputArg("GetPOList_SelectPO")]
    public MTList<ProductOffering> POList
    {
      get
      {
        return ((MTList<ProductOffering>)(base.GetValue(SubscriptionsWorkflow.POListProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.POListProperty, value);
      }
    }

    public static DependencyProperty SubscriptionIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SubscriptionId", typeof(int), typeof(SubscriptionsWorkflow));

    [Description("Subscription ID")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("Edit_ManageSubscriptions")]
    [EventInputArg("Delete_ManageSubscriptions")]
    [EventInputArg("Delete_DeleteSubscription")]
    [EventInputArg("Unsubscribe_ManageSubscriptions")]
    [EventInputArg("Rates_ManageSubscriptions")]
    public int SubscriptionId
    {
      get
      {
        return ((int)(base.GetValue(SubscriptionsWorkflow.SubscriptionIdProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.SubscriptionIdProperty, value);
      }
    }

    public static DependencyProperty ProductOfferingIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ProductOfferingId", typeof(int), typeof(SubscriptionsWorkflow));

    [Description("Product Offering ID")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("SubscribeToPO_SelectPO")]
    public int ProductOfferingId
    {
      get
      {
        return ((int)(base.GetValue(SubscriptionsWorkflow.ProductOfferingIdProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.ProductOfferingIdProperty, value);
      }
    }

    public static DependencyProperty SubscriptionInstanceProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SubscriptionInstance", typeof(Subscription), typeof(SubscriptionsWorkflow));

    [Description("Subscription Instance being worked on.")]
    [Category("InputOutput")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [StateInitOutput("SetSubscriptionDate")]
    [EventInputArg("OK_SetSubscriptionDate")]
    [StateInitOutput("SaveSubscription")]
    [StateInitOutput("DeleteSubscription")]
    [StateInitOutput("UnsubscribeSubscription")]
    [EventInputArg("Unsubscribe_UnsubscribeSubscription")]
    [StateInitOutput("RatesSubscription")]
    [StateInitOutput("SetUDRCValues")]
    [EventInputArg("OK_SetUDRCValues")]
    public Subscription SubscriptionInstance
    {
      get
      {
        return ((Subscription)(base.GetValue(SubscriptionsWorkflow.SubscriptionInstanceProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.SubscriptionInstanceProperty, value);
      }
    }

    public static DependencyProperty ModeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Mode", typeof(MODE), typeof(SubscriptionsWorkflow), new PropertyMetadata(MODE.New));

    [Description("Internal workflow property that tells us if we are doing an edit or new subscription")]
    [Category("Internal")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public MODE Mode
    {
      get
      {
        return ((MODE)(base.GetValue(SubscriptionsWorkflow.ModeProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.ModeProperty, value);
      }
    }

    public static DependencyProperty POEffectiveDateProperty = System.Workflow.ComponentModel.DependencyProperty.Register("POEffectiveDate", typeof(DateTime), typeof(SubscriptionsWorkflow));

    [Description("Effective start date of subscription")]
    [Category("Input")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [EventInputArg("GetPOList_SelectPO")]
    public DateTime POEffectiveDate
    {
      get
      {
        return ((DateTime)(base.GetValue(SubscriptionsWorkflow.POEffectiveDateProperty)));
      }
      set
      {
        base.SetValue(SubscriptionsWorkflow.POEffectiveDateProperty, value);
      }
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

    public void CreateNewSubscriptionFromPOID_ExecuteCode(object sender, EventArgs e)
    {
      SubscriptionInstance = new Subscription();
      SubscriptionInstance.ProductOfferingId = this.ProductOfferingId;
      SubscriptionInstance.SubscriptionSpan = new ProdCatTimeSpan();

      // Go get product offering from id, and set the instance
      foreach (ProductOffering po in this.POList.Items)
      {
        if (po.ProductOfferingId == this.ProductOfferingId)
        {
          SubscriptionInstance.ProductOffering = po;
          break;
        }
      }
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

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Misc")]
    [StateInitOutput("SetUDRCValues")]
    public System.Collections.Generic.List<UDRCInstance> UDRCInstances
    {
      get
      {
        return ((System.Collections.Generic.List<UDRCInstance>)(base.GetValue(MetraCareWorkflowLibrary.SubscriptionsWorkflow.UDRCInstancesProperty)));
      }
      set
      {
        base.SetValue(MetraCareWorkflowLibrary.SubscriptionsWorkflow.UDRCInstancesProperty, value);
      }
    }


	}
}
