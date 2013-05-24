using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Collections;
using System.Reflection;
using System.ServiceModel;
using System.Workflow.ComponentModel;
using MetraTech;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Activities;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.IMTAccountType;
using IMTSessionContext=MetraTech.Interop.MTProductCatalog.IMTSessionContext;
using IMTSQLRowset=MetraTech.Interop.IMTAccountType.IMTSQLRowset;
using YAAC = MetraTech.Interop.MTYAAC;

namespace MetraCareWorkflowLibrary
{
    public class TemplateWorkflow : MTStateMachineWorkflowActivity
    {

        #region DepedencyProperties
        private static MetraTech.Accounts.Type.AccountTypeCollection m_AccountTypesCollection = null;
        public static DependencyProperty AccountIdentifierProperty = DependencyProperty.Register("AccountIdentifier", typeof(AccountIdentifier), typeof(TemplateWorkflow));
        public static DependencyProperty TemplateListProperty = DependencyProperty.Register("TemplateList", typeof(List<AccountTemplateDef>), typeof(TemplateWorkflow));
        public static DependencyProperty TemplateResultsListProperty = DependencyProperty.Register("TemplateResultsList", typeof(MTList<AccountTemplateSession>), typeof(TemplateWorkflow));
        public static DependencyProperty AccountTypesProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AccountTypes", typeof(ArrayList), typeof(TemplateWorkflow));
        public static DependencyProperty SessionIdProperty = DependencyProperty.Register("SessionId", typeof(string), typeof(MetraCareWorkflowLibrary.TemplateWorkflow));
        public static DependencyProperty SessionIdInstanceProperty = DependencyProperty.Register("SessionIdInstance", typeof(int), typeof(TemplateWorkflow));
        public static DependencyProperty DetailsListProperty = DependencyProperty.Register("DetailsList", typeof(MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.AccountTemplateSessionDetail>), typeof(MetraCareWorkflowLibrary.TemplateWorkflow));
        public static DependencyProperty GroupSubscriptionListProperty = DependencyProperty.Register("GroupSubscriptionList", typeof(MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.GroupSubscription>), typeof(MetraCareWorkflowLibrary.TemplateWorkflow));
        public static DependencyProperty ProductOfferingsListProperty = DependencyProperty.Register("ProductOfferingsList", typeof(MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.ProductOffering>), typeof(MetraCareWorkflowLibrary.TemplateWorkflow));
        public static DependencyProperty SelectedAccountTypeProperty = DependencyProperty.Register("SelectedAccountType", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty TempAccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("TempAccount", typeof(Account), typeof(TemplateWorkflow));
        public static DependencyProperty EffectiveTimeProperty = DependencyProperty.Register("EffectiveTime", typeof(DateTime), typeof(TemplateWorkflow));
        public static DependencyProperty InheritParentPropertiesProperty = DependencyProperty.Register("InheritParentProperties", typeof(bool), typeof(TemplateWorkflow));
        public static DependencyProperty AccountTemplateInstanceProperty = DependencyProperty.Register("AccountTemplateInstance", typeof(AccountTemplate), typeof(TemplateWorkflow));
        public static DependencyProperty AccountTemplateInstanceSubscriptionListProperty = DependencyProperty.Register("AccountTemplateInstanceSubscriptionList", typeof(List<AccountTemplateSubscription>), typeof(TemplateWorkflow));
        public static DependencyProperty ProductOfferingIDsProperty = DependencyProperty.Register("ProductOfferingIDs", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty GroupIDProperty = DependencyProperty.Register("GroupID", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty POIDProperty = DependencyProperty.Register("POID", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty GroupIDsProperty = DependencyProperty.Register("GroupIDs", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty InheritParentTemplateStringProperty = DependencyProperty.Register("InheritParentTemplateString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty AccountTemplatePropertiesListProperty = DependencyProperty.Register("AccountTemplatePropertiesList", typeof(List<AccountTemplateKeyValue>), typeof(TemplateWorkflow));
        public static DependencyProperty EndConflictingSubscriptionsProperty = DependencyProperty.Register("EndConflictingSubscriptions", typeof(System.Boolean), typeof(MetraCareWorkflowLibrary.TemplateWorkflow));
        public static DependencyProperty SubscriptionDatesProperty = DependencyProperty.Register("SubscriptionDates", typeof(MetraTech.DomainModel.BaseTypes.ProdCatTimeSpan), typeof(MetraCareWorkflowLibrary.TemplateWorkflow));
        public static DependencyProperty ApplySubscriptionsListProperty = DependencyProperty.Register("ApplySubscriptionsList", typeof(System.Collections.Generic.List<MetraTech.DomainModel.ProductCatalog.AccountTemplateSubscription>), typeof(MetraCareWorkflowLibrary.TemplateWorkflow));
        public static DependencyProperty ApplyPropertiesListProperty = DependencyProperty.Register("ApplyPropertiesList", typeof(System.Collections.Generic.List<System.String>), typeof(MetraCareWorkflowLibrary.TemplateWorkflow));
        public static DependencyProperty ApplyTemplateScopeProperty = DependencyProperty.Register("ApplyTemplateScope", typeof(MetraTech.DomainModel.ProductCatalog.AccountTemplateScope), typeof(MetraCareWorkflowLibrary.TemplateWorkflow));
        public static DependencyProperty ApplyPropertiesStringProperty = DependencyProperty.Register("ApplyPropertiesString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty ApplySubscriptionsStringProperty = DependencyProperty.Register("ApplySubscriptionsString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty ApplyDefaultSecurityStringProperty = DependencyProperty.Register("ApplyDefaultSecurityString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty ApplyAllDescendentsStringProperty = DependencyProperty.Register("ApplyAllDescendentsString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty ApplyStartDateStringProperty = DependencyProperty.Register("ApplyStartDateString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty ApplyEndDateStringProperty = DependencyProperty.Register("ApplyEndDateString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty ApplyStartNextBillingPeriodStringProperty = DependencyProperty.Register("ApplyStartNextBillingPeriodString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty ApplyEndNextBillingPeriodStringProperty = DependencyProperty.Register("ApplyEndNextBillingPeriodString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty ApplyEndConflictingSubscriptionsStringProperty = DependencyProperty.Register("ApplyEndConflictingSubscriptionsString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty MoveAccountsStringProperty = DependencyProperty.Register("MoveAccountsString", typeof(string), typeof(TemplateWorkflow));
        public static DependencyProperty MovedTypesProperty = DependencyProperty.Register("MovedTypes", typeof(ArrayList), typeof(TemplateWorkflow));
        public static DependencyProperty PageStateGuidProperty = DependencyProperty.Register("PageStateGuid", typeof(System.Guid), typeof(TemplateWorkflow));
    public static DependencyProperty NumRetriesProperty = DependencyProperty.Register("NumRetries", typeof(int), typeof(TemplateWorkflow));

        #endregion

        #region enums
        public enum TEMPLATE_MODE
        {
            Add,
            Edit,
            Apply,
            Move
        }
        #endregion

        #region Properties

        [Description("This stores the page state guid for the SetState Event")]
        [Category("Input")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        [EventInputArg("SetStateEvent")]
        public Guid PageStateGuid
        {
            get
            {
                return ((System.Guid)(base.GetValue(TemplateWorkflow.PageStateGuidProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.PageStateGuidProperty, value);
            }
        }

        [DescriptionAttribute("MovedTypes")]
        [CategoryAttribute("MovedTypes Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [StateInitOutput("TemplateSummary")]
        public ArrayList MovedTypes
        {
            get
            {
                return ((ArrayList)(base.GetValue(TemplateWorkflow.MovedTypesProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.MovedTypesProperty, value);
            }
        }
        [DescriptionAttribute("MoveAccountsString")]
        [CategoryAttribute("MoveAccountsString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("StartMove_TemplateWorkflow")]
        public string MoveAccountsString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.MoveAccountsStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.MoveAccountsStringProperty, value);
            }
        }

        [DescriptionAttribute("ApplyEndConflictingSubscriptionsString")]
        [CategoryAttribute("ApplyEndConflictingSubscriptionsString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_ApplyTemplate")]
        public string ApplyEndConflictingSubscriptionsString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ApplyEndConflictingSubscriptionsStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ApplyEndConflictingSubscriptionsStringProperty, value);
            }
        }

        [DescriptionAttribute("ApplyEndNextBillingPeriodString")]
        [CategoryAttribute("ApplyEndNextBillingPeriodString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_ApplyTemplate")]
        public string ApplyEndNextBillingPeriodString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ApplyEndNextBillingPeriodStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ApplyEndNextBillingPeriodStringProperty, value);
            }
        }
        [DescriptionAttribute("ApplyStartNextBillingPeriodString")]
        [CategoryAttribute("ApplyStartNextBillingPeriodString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_ApplyTemplate")]
        public string ApplyStartNextBillingPeriodString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ApplyStartNextBillingPeriodStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ApplyStartNextBillingPeriodStringProperty, value);
            }
        }

        [DescriptionAttribute("ApplyEndDateString")]
        [CategoryAttribute("ApplyEndDateString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_ApplyTemplate")]
        public string ApplyEndDateString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ApplyEndDateStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ApplyEndDateStringProperty, value);
            }
        }

        [DescriptionAttribute("ApplyStartDateString")]
        [CategoryAttribute("ApplyStartDateString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_ApplyTemplate")]
        public string ApplyStartDateString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ApplyStartDateStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ApplyStartDateStringProperty, value);
            }
        }


        [DescriptionAttribute("ApplyAllDescendentsString")]
        [CategoryAttribute("ApplyAllDescendentsString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_ApplyTemplate")]
        public string ApplyAllDescendentsString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ApplyAllDescendentsStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ApplyAllDescendentsStringProperty, value);
            }
        }

        [DescriptionAttribute("InheritParentTemplateString")]
        [CategoryAttribute("InheritParentTemplateString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_AddTemplate")]
        public string InheritParentTemplateString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.InheritParentTemplateStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.InheritParentTemplateStringProperty, value);
            }
        }

        [DescriptionAttribute("SessionIdInstance")]
        [CategoryAttribute("SessionIdInstance Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [StateInitOutput("TemplateHistory")]
        public int SessionIdInstance
        {
            get
            {
                return ((int)(base.GetValue(TemplateWorkflow.SessionIdInstanceProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.SessionIdInstanceProperty, value);
            }
        }
        [DescriptionAttribute("ApplyDefaultSecurityString")]
        [CategoryAttribute("ApplyDefaultSecurityString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_ApplyTemplate")]
        public string ApplyDefaultSecurityString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ApplyDefaultSecurityStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ApplyDefaultSecurityStringProperty, value);
            }
        }

        [DescriptionAttribute("ApplyPropertiesString")]
        [CategoryAttribute("ApplyPropertiesString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_ApplyTemplate")]
        public string ApplyPropertiesString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ApplyPropertiesStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ApplyPropertiesStringProperty, value);
            }
        }

        [DescriptionAttribute("ApplySubscriptionsString")]
        [CategoryAttribute("ApplySubscriptionsString Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_ApplyTemplate")]
        public string ApplySubscriptionsString
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ApplySubscriptionsStringProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ApplySubscriptionsStringProperty, value);
            }
        }
        [DescriptionAttribute("AccountTemplatePropertiesList")]
        [CategoryAttribute("AccountTemplatePropertiesList Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("GetPropertiesList_ApplyTemplate")]
        [EventOutputArg("GetPropertiesList_ApplyTemplate")]
        public List<AccountTemplateKeyValue> AccountTemplatePropertiesList
        {
            get
            {
                return ((List<AccountTemplateKeyValue>)(base.GetValue(TemplateWorkflow.AccountTemplatePropertiesListProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.AccountTemplatePropertiesListProperty, value);
            }
        }

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public List<AccountTemplateSubscription> ApplySubscriptionsList
        {
            get
            {
                return ((System.Collections.Generic.List<MetraTech.DomainModel.ProductCatalog.AccountTemplateSubscription>)(base.GetValue(MetraCareWorkflowLibrary.TemplateWorkflow.ApplySubscriptionsListProperty)));
            }
            set
            {
                base.SetValue(MetraCareWorkflowLibrary.TemplateWorkflow.ApplySubscriptionsListProperty, value);
            }
        }

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public List<string> ApplyPropertiesList
        {
            get
            {
                return ((System.Collections.Generic.List<string>)(base.GetValue(MetraCareWorkflowLibrary.TemplateWorkflow.ApplyPropertiesListProperty)));
            }
            set
            {
                base.SetValue(MetraCareWorkflowLibrary.TemplateWorkflow.ApplyPropertiesListProperty, value);
            }
        }

        [DescriptionAttribute("GroupIDs")]
        [CategoryAttribute("GroupIDs Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_SelectGroupSubscriptions")]
        public string GroupIDs
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.GroupIDsProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.GroupIDsProperty, value);
            }
        }

        [DescriptionAttribute("POID")]
        [CategoryAttribute("POID Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("DeleteSubscription_EditTemplate")]
        public string POID
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.POIDProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.POIDProperty, value);
            }
        }

        [DescriptionAttribute("GroupID")]
        [CategoryAttribute("GroupID Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("DeleteSubscription_EditTemplate")]
        public string GroupID
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.GroupIDProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.GroupIDProperty, value);
            }
        }

        [DescriptionAttribute("ProductOfferingIDs")]
        [CategoryAttribute("ProductOfferingIDs Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_SelectSubscriptions")]
        public string ProductOfferingIDs
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.ProductOfferingIDsProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.ProductOfferingIDsProperty, value);
            }
        }

        [DescriptionAttribute("AccountTemplateInstanceSubscriptionList")]
        [CategoryAttribute("AccountTemplateInstanceSubscriptionList Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("GetSubscriptionsList_EditTemplate")]
        [EventOutputArg("GetSubscriptionsList_EditTemplate")]
        [EventInputArg("GetSubscriptionsList_ApplyTemplate")]
        [EventOutputArg("GetSubscriptionsList_ApplyTemplate")]
        public List<AccountTemplateSubscription> AccountTemplateInstanceSubscriptionList
        {
            get
            {
                return ((List<AccountTemplateSubscription>)(base.GetValue(TemplateWorkflow.AccountTemplateInstanceSubscriptionListProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.AccountTemplateInstanceSubscriptionListProperty, value);
            }
        }

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        [StateInitOutput("EditTemplate")]
        [EventInputArg("OK_EditTemplate")]
        [EventInputArg("SaveAndApply_EditTemplate")]
        [EventInputArg("AddSubscription_EditTemplate")]
        [EventInputArg("AddGroupSubscription_EditTemplate")]
        public Account TempAccount
        {
            get
            {
                return ((Account)(base.GetValue(TemplateWorkflow.TempAccountProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.TempAccountProperty, value);
            }
        }

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


        [DescriptionAttribute("AccountIdentifier")]
        [CategoryAttribute("AccountIdentifier Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("Start_TemplateWorkflow")]
        [EventInputArg("StartMove_TemplateWorkflow")]
        public AccountIdentifier AccountIdentifier
        {
            get
            {
                return ((AccountIdentifier)(base.GetValue(TemplateWorkflow.AccountIdentifierProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.AccountIdentifierProperty, value);
            }
        }


        [DescriptionAttribute("TemplateList")]
        [CategoryAttribute("TemplateList Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("GetTemplateList_TemplateSummary")]
        [EventOutputArg("GetTemplateList_TemplateSummary")]
        public List<AccountTemplateDef> TemplateList
        {
            get
            {
                return ((List<AccountTemplateDef>)(base.GetValue(TemplateWorkflow.TemplateListProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.TemplateListProperty, value);
            }
        }


        [DescriptionAttribute("TemplateResultsList")]
        [CategoryAttribute("TemplateResultsList Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("GetTemplateResults_TemplateHistory")]
        [EventOutputArg("GetTemplateResults_TemplateHistory")]
        public MTList<AccountTemplateSession> TemplateResultsList
        {
            get
            {
                return ((MTList<AccountTemplateSession>)(base.GetValue(TemplateWorkflow.TemplateResultsListProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.TemplateResultsListProperty, value);
            }
        }

        [DescriptionAttribute("SelectedAccountType")]
        [CategoryAttribute("SelectedAccountType Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [EventInputArg("OK_AddTemplate")]
        [EventInputArg("Delete_TemplateSummary")]
        [EventInputArg("Edit_TemplateSummary")]
        [EventInputArg("Apply_TemplateSummary")]
        public string SelectedAccountType
        {
            get
            {
                return ((string)(base.GetValue(TemplateWorkflow.SelectedAccountTypeProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.SelectedAccountTypeProperty, value);
            }
        }


        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        [StateInitOutput("AddTemplate")]
        public ArrayList AccountTypes
        {
            get
            {
                return ((ArrayList)(base.GetValue(TemplateWorkflow.AccountTypesProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.AccountTypesProperty, value);
            }
        }


        [DescriptionAttribute("EffectiveTime")]
        [CategoryAttribute("EffectiveTime Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        public DateTime EffectiveTime
        {
            get
            {
                return ((DateTime)(base.GetValue(TemplateWorkflow.EffectiveTimeProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.EffectiveTimeProperty, value);
            }
        }


        [DescriptionAttribute("InheritParentProperties")]
        [CategoryAttribute("InheritParentProperties Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        public bool InheritParentProperties
        {
            get
            {
                return ((bool)(base.GetValue(TemplateWorkflow.InheritParentPropertiesProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.InheritParentPropertiesProperty, value);
            }
        }


        [DescriptionAttribute("AccountTemplateInstance")]
        [CategoryAttribute("AccountTemplateInstance Category")]
        [BrowsableAttribute(true)]
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [StateInitOutput("EditTemplate")]
        [StateInitOutput("ApplyTemplate")]
        [EventInputArg("OK_EditTemplate")]
        [EventInputArg("SaveAndApply_EditTemplate")]
        [EventInputArg("OK_ApplyTemplate")]
        [EventInputArg("AddSubscription_EditTemplate")]
        [EventInputArg("AddGroupSubscription_EditTemplate")]
        public AccountTemplate AccountTemplateInstance
        {
            get
            {
                return ((AccountTemplate)(base.GetValue(TemplateWorkflow.AccountTemplateInstanceProperty)));
            }
            set
            {
                base.SetValue(TemplateWorkflow.AccountTemplateInstanceProperty, value);
            }
        }

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public bool EndConflictingSubscriptions
        {
            get
            {
                return ((bool)(base.GetValue(MetraCareWorkflowLibrary.TemplateWorkflow.EndConflictingSubscriptionsProperty)));
            }
            set
            {
                base.SetValue(MetraCareWorkflowLibrary.TemplateWorkflow.EndConflictingSubscriptionsProperty, value);
            }
        }

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public ProdCatTimeSpan SubscriptionDates
        {
            get
            {
                return ((MetraTech.DomainModel.BaseTypes.ProdCatTimeSpan)(base.GetValue(MetraCareWorkflowLibrary.TemplateWorkflow.SubscriptionDatesProperty)));
            }
            set
            {
                base.SetValue(MetraCareWorkflowLibrary.TemplateWorkflow.SubscriptionDatesProperty, value);
            }
        }

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        [EventInputArg("TemplateResults_TemplateHistory")]
        public string SessionId
        {
            get
            {
                return ((string)(base.GetValue(MetraCareWorkflowLibrary.TemplateWorkflow.SessionIdProperty)));
            }
            set
            {
                base.SetValue(MetraCareWorkflowLibrary.TemplateWorkflow.SessionIdProperty, value);
            }
        }

    [DescriptionAttribute("NumRetries")]
    [CategoryAttribute("NumRetries Category")]
    [BrowsableAttribute(true)]
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [EventInputArg("TemplateResults_TemplateHistory")]
    [StateInitOutput("TemplateResults")]
    public int NumRetries
    {
        get
        {
            return ((int)(base.GetValue(TemplateWorkflow.NumRetriesProperty)));
        }
        set
        {
            base.SetValue(TemplateWorkflow.NumRetriesProperty, value);
        }
    }

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        [EventInputArg("GetTemplateDetails_TemplateResults")]
        [EventOutputArg("GetTemplateDetails_TemplateResults")]
        public MTList<AccountTemplateSessionDetail> DetailsList
        {
            get
            {
                return ((MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.AccountTemplateSessionDetail>)(base.GetValue(MetraCareWorkflowLibrary.TemplateWorkflow.DetailsListProperty)));
            }
            set
            {
                base.SetValue(MetraCareWorkflowLibrary.TemplateWorkflow.DetailsListProperty, value);
            }
        }

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        [EventInputArg("GetGroupSubscriptionsList_SelectGroupSubscriptions")]
        [EventOutputArg("GetGroupSubscriptionsList_SelectGroupSubscriptions")]
        public MTList<GroupSubscription> GroupSubscriptionList
        {
            get
            {
                return ((MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.GroupSubscription>)(base.GetValue(MetraCareWorkflowLibrary.TemplateWorkflow.GroupSubscriptionListProperty)));
            }
            set
            {
                base.SetValue(MetraCareWorkflowLibrary.TemplateWorkflow.GroupSubscriptionListProperty, value);
            }
        }

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        [EventInputArg("GetSubscriptionsList_SelectSubscriptions")]
        [EventOutputArg("GetSubscriptionsList_SelectSubscriptions")]
        public MTList<ProductOffering> ProductOfferingsList
        {
            get
            {
                return ((MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.ProductCatalog.ProductOffering>)(base.GetValue(MetraCareWorkflowLibrary.TemplateWorkflow.ProductOfferingsListProperty)));
            }
            set
            {
                base.SetValue(MetraCareWorkflowLibrary.TemplateWorkflow.ProductOfferingsListProperty, value);
            }
        }

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public AccountTemplateScope ApplyTemplateScope
        {
            get
            {
                return ((MetraTech.DomainModel.ProductCatalog.AccountTemplateScope)(base.GetValue(MetraCareWorkflowLibrary.TemplateWorkflow.ApplyTemplateScopeProperty)));
            }
            set
            {
                base.SetValue(MetraCareWorkflowLibrary.TemplateWorkflow.ApplyTemplateScopeProperty, value);
            }
        }

        #endregion

        #region Code Activities
        /// <summary>
        /// Fill AccountTypes propery with the list of possible account types that 
        /// we do not yet have a template for.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void GetPossibleAccountTypesActivity_ExecuteCode(object sender, EventArgs e)
        {
            AccountTypes = new ArrayList();

            // Create account type exclude list
            List<string> excludeList = new List<string>();
            foreach (AccountTemplateDef def in TemplateList)
            {
                excludeList.Add(def.AccountType.ToLower());
            }
            excludeList.Add("root");
            excludeList.Add("systemaccount");

            // Loop around all possible descendent account types
            AccountTypeManager accountTypeManager = new AccountTypeManager();
            YAAC.MTYAAC yaac = new YAAC.MTYAAC();
            yaac.InitAsSecuredResource((int)AccountIdentifier.AccountID, GetSessionContext(),
                                       MetraTime.Now);
            IMTAccountType accType = accountTypeManager.GetAccountTypeByID((IMTSessionContext)GetSessionContext(),
                                                                           yaac.AccountTypeID);
            
            string allTypesName =
              MetraTech.Core.Services.AccountTemplateService.Config.AllTypesAccountTypeName;

            /* Check if account templates type isn't independent account templates then add to list all posible account types.
             * Otherwise add only "AllTypes" account type
             */
            if (yaac.GetAccountTemplateType() == 0)
            {
              // Add current account type to support Current Node feature
              if (!excludeList.Contains(accType.Name.ToLower()))
              {
                AccountTypes.Add(accType.Name);
              }

              excludeList.Add(allTypesName.ToLower());
              IMTSQLRowset rs = accType.GetAllDescendentAccountTypesAsRowset();
              if (rs != null)
              {
                rs.MoveFirst();
                while (!Convert.ToBoolean(rs.EOF))
                {
                  // Remove account types that we already have templates for
                  if (excludeList.Contains(rs.get_Value("DescendentTypeName").ToString().ToLower()))
                  {
                    rs.MoveNext();
                    continue;
                  }
                  else
                  {
                    AccountTypes.Add(rs.get_Value("DescendentTypeName").ToString());
                  }
                  rs.MoveNext();
                }
              }
            }
            else
            {
              if (!excludeList.Contains(allTypesName.ToLower()))
              {
                AccountTypes.Add(allTypesName);
              }
            }
        }

        /// <summary>
        /// Return session context
        /// </summary>
        /// <returns></returns>
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

        public void SetDefaultTemplateValues_ExecuteCode(object sender, EventArgs e)
        {
            EffectiveTime = MetraTime.Now;
            if (!String.IsNullOrEmpty(InheritParentTemplateString))
            {
                InheritParentProperties = bool.Parse(InheritParentTemplateString);
            }
            else
            {
                InheritParentProperties = false;
            }
        }


        public void NewTempAccount_ExecuteCode(object sender, EventArgs e)
        {
            TempAccount = Account.CreateAccount(SelectedAccountType);
            AccountTemplateInstance.ApplyTemplatePropsToAccount(TempAccount);
        }

        public void InitNewAccount_ExecuteCode(object sender, EventArgs e)
        {
            TempAccount = Account.CreateAccountWithViews(SelectedAccountType);

            try
            {
                // Try to get the first ContactView and set it to Bill To
                foreach (ContactView v in (List<ContactView>)TempAccount.GetValue("LDAP"))
                {
                    v.ContactType = ContactType.Bill_To;
                    break;
                }
            }
            catch (Exception)
            {
                // Account types don't have to have a contact view
            }

            AccountTemplateInstance.ApplyTemplatePropsToAccount(TempAccount);
        }

        /// <summary>
        /// Get the list of subscriptions off the template instance
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void GetSubscriptionsList_ExecuteCode(object sender, EventArgs e)
        {
            if (AccountTemplateInstanceSubscriptionList == null)
            {
                AccountTemplateInstanceSubscriptionList = AccountTemplateInstance.Subscriptions;

                if (AccountTemplateInstanceSubscriptionList == null)
                {
                    AccountTemplateInstanceSubscriptionList = new List<AccountTemplateSubscription>();
                }
            }
        }

        /// <summary>
        /// Place selected subscriptions into the AccountTemplateInstance.Subscriptions collection.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void SelectSubscriptionsActivity_ExecuteCode(object sender, EventArgs e)
        {
            string[] poids = ProductOfferingIDs.Split(new char[] { ',' });
            List<string> ids = new List<string>(poids);

            foreach (ProductOffering po in ProductOfferingsList.Items)
            {
                if (ids.Contains(po.ProductOfferingId.ToString()))
                {
                    AccountTemplateSubscription itm = new AccountTemplateSubscription();
                    itm.ProductOfferingId = po.ProductOfferingId;
                    if (po.AvailableTimeSpan.StartDate == null)
                    {
                        itm.StartDate = MetraTime.Min;
                    }
                    else
                    {
                        itm.StartDate = (DateTime)po.AvailableTimeSpan.StartDate;
                    }

                    if (po.AvailableTimeSpan.EndDate == null)
                    {
                        itm.EndDate = MetraTime.Max;
                    }
                    else
                    {
                        itm.EndDate = (DateTime)po.AvailableTimeSpan.EndDate;
                    }
                    itm.PODisplayName = po.DisplayName;
                    AccountTemplateInstance.Subscriptions.Add(itm);
                }
            }

        }

        /// <summary>
        /// Place selected group subscriptions into the AccountTemplateInstance.Subscriptions collection.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void SelectGroupSubscriptionsActivity_ExecuteCode(object sender, EventArgs e)
        {
            string[] groupIds = GroupIDs.Split(new char[] { ',' });
            List<string> ids = new List<string>(groupIds);

            foreach (GroupSubscription gSub in GroupSubscriptionList.Items)
            {
                if (ids.Contains(gSub.GroupId.ToString()))
                {
                    AccountTemplateSubscription itm = new AccountTemplateSubscription();
                    //itm.ProductOfferingId = gSub.ProductOfferingId;
                    if (gSub.SubscriptionSpan.StartDate == null)
                    {
                        itm.StartDate = MetraTime.Min;
                    }
                    else
                    {
                        itm.StartDate = (DateTime)gSub.SubscriptionSpan.StartDate;
                    }

                    if (gSub.SubscriptionSpan.EndDate == null)
                    {
                        itm.EndDate = MetraTime.Max;
                    }
                    else
                    {
                        itm.EndDate = (DateTime)gSub.SubscriptionSpan.EndDate;
                    }
                    itm.PODisplayName = gSub.ProductOffering.DisplayName;
                    itm.GroupSubName = gSub.Name;
                    itm.GroupID = gSub.GroupId;
                    AccountTemplateInstance.Subscriptions.Add(itm);
                }
            }
        }

        /// <summary>
        /// Get all dirty properties from TempAccount and set the name value pairs
        /// in the AccountTemplateInstance.Properties bag.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void PopulateAccountTemplateInstance_ExecuteCode(object sender, EventArgs e)
        {
            // Force template properties on the ContactView to be Bill To.
            try
            {
                foreach (ContactView v in (List<ContactView>)TempAccount.GetValue("LDAP"))
                {
                    v.ContactType = ContactType.Bill_To;
                    break;
                }
            }
            catch (Exception exp)
            {
                Logger logger = new Logger("[PopulateAccountTemplate]");
                logger.LogWarning(exp.ToString());
            }

            AccountTemplateInstance.GetTemplatePropsFromAccount(TempAccount);
            AccountTemplateInstance.Subscriptions = AccountTemplateInstanceSubscriptionList;
        }

        public void InitTempAccount_ExecuteCode(object sender, EventArgs e)
        {
            TempAccount = null;
        }

        /// <summary>
        /// Remove a subscription from the AccountTemplateInstance.Subscriptions based on POID and Group ID.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void DeleteSubscriptionFromTemplate_ExecuteCode(object sender, EventArgs e)
        {
            for (int i = 0; i < AccountTemplateInstanceSubscriptionList.Count; i++)
            {
                AccountTemplateSubscription sub = AccountTemplateInstanceSubscriptionList[i];
                if (sub.ProductOfferingId.ToString() == POID || sub.GroupID.ToString() == GroupID)
                {
                    AccountTemplateInstanceSubscriptionList.Remove(sub);
                }
            }
        }

        /// <summary>
        /// Returns a display name for provided enum instance in the current locale
        /// </summary>
        /// <param name="enumInstance"></param>
        /// <returns></returns>
        protected string GetEnumInstanceDisplayName(object enumInstance)
        {
            if (enumInstance == null || (enumInstance.GetType().BaseType != typeof(Enum)))
            {
                return string.Empty;
            }

            Type enumType = enumInstance.GetType();

            List<EnumData> enums = BaseObject.GetEnumData(enumType);

            if ((enums != null) && (enums.Count > 0))
            {
                foreach (EnumData enumData in enums)
                {
                    if (enumData.EnumInstance.ToString() == enumInstance.ToString())
                    {
                        return enumData.DisplayName;
                    }
                }
            }

            return string.Empty;
        }

        public void GetPropertiesList_ExecuteCode(object sender, EventArgs e)
        {
            // create an instance of this account type so we can pull DisplayNames off it
            Account acc = Account.CreateAccountWithViews(AccountTemplateInstance.AccountType);
            Dictionary<string, string> propToValMap = new Dictionary<string, string>();
            ParseObjectForValues(acc, "", propToValMap);

            AccountTemplatePropertiesList = new List<AccountTemplateKeyValue>();
            foreach (KeyValuePair<string, object> kvp in this.AccountTemplateInstance.Properties)
            {
                AccountTemplateKeyValue kv = new AccountTemplateKeyValue();
                kv.Key = kvp.Key;
                try
                {
                    kv.Name = kvp.Key.Substring(kvp.Key.LastIndexOf('.') + 1);
                }
                catch (Exception)
                {
                    kv.Name = kvp.Key;
                }

                // Get DisplayName
                string displayKey = kv.Key.Replace("Account.", "").Replace("LDAP[ContactType=Bill_To].", "LDAP[0].") + "DisplayName";
                if (propToValMap.ContainsKey(displayKey))
                {
                    kv.DisplayName = propToValMap[displayKey];
                }

                if (kvp.Value != null)
                {                 
                    if (kvp.Value.GetType().IsEnum)
                    {
                        kv.Value = GetEnumInstanceDisplayName(kvp.Value);
                    }
                    else
                    {
                        kv.Value = kvp.Value.ToString();
                    }
                }
                else
                {
                    kv.Value = "";
                }

                CheckEmptyOrNullValues(kv, propToValMap);              

                
            }
        }

        public void SetDefaultsBeforeApply_ExecuteCode(object sender, EventArgs e)
        {
            /* Properties Needed for Apply Service:
                    accountType = SelectedAccountType
                    effectiveDate = MetraTime.Now
                    endConflictingSubscriptions
                    propNames
                    subscriptionDates
                    subscriptions
                    templateOwner
                    templateScope
            */

            EffectiveTime = MetraTime.Now;

            // Add selected properties
            ApplyPropertiesList = new List<string>();
            if (!String.IsNullOrEmpty(ApplyPropertiesString))
            {
                foreach (string key in ApplyPropertiesString.Split(new char[] { ',' }))
                {
                    ApplyPropertiesList.Add(key);
                }
            }

            // Add selected subscriptions
            ApplySubscriptionsList = new List<AccountTemplateSubscription>();
            if (!String.IsNullOrEmpty(ApplySubscriptionsString))
            {
                foreach (string ids in ApplySubscriptionsString.Split(new char[] { ',' }))
                {
                    string[] id = ids.Split(new char[] { ':' });
                    string poId = id[0];
                    string groupId = id[1];

                    foreach (AccountTemplateSubscription subscription in AccountTemplateInstanceSubscriptionList)
                    {
                        if (subscription.ProductOfferingId.ToString() == poId || subscription.GroupID.ToString() == groupId)
                        {
                            ApplySubscriptionsList.Add(subscription);
                            break;
                        }
                    }
                }
            }

            // End Conflicting Subscriptions
            EndConflictingSubscriptions = bool.Parse(ApplyEndConflictingSubscriptionsString);

            // Sub Start Date
            SubscriptionDates = new ProdCatTimeSpan();
            if (String.IsNullOrEmpty(ApplyStartDateString))
            {
                SubscriptionDates.StartDate = MetraTime.Min;
            }
            else
            {
                SubscriptionDates.StartDate = DateTime.Parse(ApplyStartDateString);
            }

            if (bool.Parse(ApplyStartNextBillingPeriodString))
            {
                SubscriptionDates.StartDateType = ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
            }
            else
            {
                SubscriptionDates.StartDateType = ProdCatTimeSpan.MTPCDateType.SubscriptionRelative;
            }

            // Sub End Date
            if (String.IsNullOrEmpty(ApplyEndDateString))
            {
                SubscriptionDates.EndDate = MetraTime.Max;
            }
            else
            {
                SubscriptionDates.EndDate = DateTime.Parse(ApplyEndDateString);
            }

            if (bool.Parse(ApplyEndNextBillingPeriodString))
            {
                SubscriptionDates.EndDateType = ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
            }
            else
            {
                SubscriptionDates.EndDateType = ProdCatTimeSpan.MTPCDateType.SubscriptionRelative;
            }

            // Scope
            ApplyTemplateScope = bool.Parse(ApplyAllDescendentsString) ? AccountTemplateScope.ALL_DESCENDENTS : AccountTemplateScope.DIRECT_DESCENDENTS;
        }


        public void GetTemplateResults_ExecuteCode(object sender, EventArgs e)
        {
            SessionIdInstance = int.Parse(SessionId);
        }

        public void ClearSessionId_ExecuteCode(object sender, EventArgs e)
        {
            SessionIdInstance = 0;
        }

        public void SetMovedTypes_ExecuteCode(object sender, EventArgs e)
        {
            MovedTypes = new ArrayList();
            string[] types = MoveAccountsString.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string s in types)
            {
                MovedTypes.Add(s.Trim());
            }
        }

        public void ClearTypeFromMovedAccountList_ExecuteCode(object sender, EventArgs e)
        {
            if (ApplyTemplateScope == AccountTemplateScope.ALL_DESCENDENTS)
            {
                if (MovedTypes != null && MovedTypes.Count > 0)
                {
                    MovedTypes.Remove(SelectedAccountType);
                }
            }
        }

        // This is used to put back values from the workflow.  These get overwritten by the pages viewstate.
        public void SyncSubscriptions_ExecuteCode(object sender, EventArgs e)
        {
            AccountTemplateInstance.Subscriptions = AccountTemplateInstanceSubscriptionList;
        }

        public void CheckEmptyOrNullValues(AccountTemplateKeyValue kv, Dictionary<string, string> propToValMap)
        {
          if (!(kv.Value.ToString().Equals(String.Empty)) && !(kv.Value.Equals(null)))
          {
            AccountTemplatePropertiesList.Add(kv);
          }
        }

        public void FilterBillingCycleProperties(string usageCycleType, Dictionary<string, string> propToValMap)
        {
          foreach (KeyValuePair<string, object> keyValPair in this.AccountTemplateInstance.Properties)
          {
            AccountTemplateKeyValue keyVal = new AccountTemplateKeyValue();
            keyVal.Key = keyValPair.Key;

            try
            {
              keyVal.Name = keyValPair.Key.Substring(keyValPair.Key.LastIndexOf('.') + 1);
            }
            catch (Exception)
            {
              keyVal.Name = keyValPair.Key;
            }

            // Get DisplayName
            string displayKey2 = keyVal.Key.Replace("Account.", "").Replace("LDAP[ContactType=Bill_To].", "LDAP[0].") + "DisplayName";
            if (propToValMap.ContainsKey(displayKey2))
            {
              keyVal.DisplayName = propToValMap[displayKey2];
            }

            if (keyValPair.Value != null)
            {
              if (keyValPair.Value.GetType().IsEnum)
              {
                keyVal.Value = GetEnumInstanceDisplayName(keyValPair.Value);
              }
              else
              {
                keyVal.Value = keyValPair.Value.ToString();
              }
            }
            else
            {
              keyVal.Value = "";
            }


            if ((keyVal.Key.ToString().Equals("Account.DayOfMonth")))
            {
              if (!(keyVal.Value.ToString().Equals(String.Empty)) && !(keyVal.Value.Equals(null)))
              {
                if (usageCycleType == "Monthly")
                {
                  AccountTemplatePropertiesList.Add(keyVal);
                }

              }
            }
            else if ((keyVal.Key.ToString().Equals("Account.DayOfWeek")))
            {
              if (!(keyVal.Value.ToString().Equals(String.Empty)) && !(keyVal.Value.Equals(null)))
              {
                if (usageCycleType == "Weekly")
                {
                  AccountTemplatePropertiesList.Add(keyVal);
                }
              }
            }
            else if ((keyVal.Key.ToString().Equals("Account.FirstDayOfMonth")) || (keyVal.Key.ToString().Equals("Account.SecondDayOfMonth")))
            {
              if (!(keyVal.Value.ToString().Equals(String.Empty)) && !(keyVal.Value.Equals(null)))
              {
                if (usageCycleType == "Semi-monthly")
                {
                  AccountTemplatePropertiesList.Add(keyVal);
                }
              }
            }
            else if ((keyVal.Key.ToString().Equals("Account.StartDay")) || (keyVal.Key.ToString().Equals("Account.StartMonth")))
            {
              if (!(keyVal.Value.ToString().Equals(String.Empty)) && !(keyVal.Value.Equals(null)))
              {
                if ((usageCycleType == "Quarterly") || (usageCycleType == "Annual") || (usageCycleType == "Semi-Annual") || (usageCycleType == "Bi-weekly"))
                {
                  AccountTemplatePropertiesList.Add(keyVal);
                }
              }
            }
           /* else if ((keyVal.Key.ToString().Equals("Account.StartYear")))
            {
              if (!(keyVal.Value.ToString().Equals(String.Empty)) && !(keyVal.Value.Equals(null)))
              {
                if (usageCycleType == "Annual")
                {
                  AccountTemplatePropertiesList.Add(keyVal);
                }
              }
            }*/
          }
        }
        #endregion

        #region Duplicate code from CDT - (Circular dependency could not be fixed, if you can fix it, I will buy you a beer.) - KAB

        /// <summary>
        /// Build up a list of PropertyInfo objects, and Property names with dot notation for binding and creating controls.
        /// </summary>
        /// <example>
        /// <![CDATA[
        ///     List<PropertyInfo> fullPropList = new List<PropertyInfo>();
        ///     List<string> propListNames = new List<string>();
        ///     GenericObjectParser.ParseType(objectType, "", fullPropList, propListNames);
        /// ]]>
        /// </example>
        /// <param name="t"></param>
        /// <param name="propPath"></param>
        /// <param name="fullPropList"></param>
        /// <param name="propListNames"></param>
        static public void ParseType(Type t, string propPath, List<PropertyInfo> fullPropList, List<string> propListNames)
        {
            // object[] attributes;

            // Get the property list by executing GetProperties() method on current type 
            if (propPath != "")
            {
                propPath = propPath + ".";
            }

            foreach (PropertyInfo pi in t.GetProperties())
            {
                if ((pi.PropertyType.BaseType != null) &&
                    (pi.PropertyType.BaseType.Name.ToLower() == "view")) // account views
                {
                    ParseType(pi.PropertyType, propPath + pi.Name, fullPropList, propListNames);
                }
                else if ((pi.PropertyType.IsGenericType) && (pi.PropertyType.Name == "List`1"))  // For generic types, get the actual type and feed it in
                {
                    Type[] internalTypes = pi.PropertyType.GetGenericArguments();
                    for (int i = 0; i < internalTypes.Length; i++)
                    {
                        ParseType(internalTypes[i], propPath + pi.Name + "[" + i + "]", fullPropList, propListNames);
                    }
                }
                else
                {
                    // Skip the dirty flags by extracting only the properties with MTDataMember attributes
                    //attributes = pi.GetCustomAttributes(typeof(MTDataMemberAttribute), false);

                    //if ((attributes != null) && (attributes.Length == 1))
                    // {
                    if (!propListNames.Contains(propPath + pi.Name))
                    {
                        propListNames.Add(propPath + pi.Name);
                        fullPropList.Add(pi);
                    }

                    // Recurse if any other properties on type and if not a value type
                    if (!pi.PropertyType.IsValueType &&
                        pi.PropertyType.Name != "String" &&
                        pi.PropertyType.GetProperties().Length > 0)
                    {
                        ParseType(pi.PropertyType, propPath + pi.Name, fullPropList, propListNames);
                    }

                    //}
                }
            }

        }

        /// <summary>
        /// Parses an object and returns a dictionary of dotted notation keys and values
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="propPath"></param>
        /// <param name="values"></param>
        static public void ParseObjectForValues(object obj, string propPath, Dictionary<string, string> values)
        {
            Type t = obj.GetType();
            List<PropertyInfo> fullPropList = new List<PropertyInfo>();
            List<string> propListNames = new List<string>();

            ParseType(t, propPath, fullPropList, propListNames);
            foreach (var name in propListNames)
            {
                var val = MetraTech.UI.Tools.Utils.GetPropertyEx(obj, name);
                if (val != null)
                {
                    values.Add(name, val.ToString());
                }
                else
                {
                    values.Add(name, null);
                }
            }
        }
        #endregion
    }
}
