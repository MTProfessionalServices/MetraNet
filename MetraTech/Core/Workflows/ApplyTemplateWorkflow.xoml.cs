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
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTYAAC;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;
using System.Collections.Generic;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.Accounts.Type;
using System.ServiceModel;
using MetraTech.DomainModel.Common;
using MetraTech.Interop.Subscription;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DomainModel.BaseTypes;



namespace MetraTech.Core.Workflows
{
  public partial class ApplyTemplateWorkflow
  {
    #region Members
    public AccountTemplate m_TemplateDefinition = new MetraTech.DomainModel.ProductCatalog.AccountTemplate();
    public IMTYAAC m_RootYAAC = null;
    public YAAC.IMTCollection m_Accounts = null;
    public List<MetraTech.DomainModel.BaseTypes.Account> m_UpdatedAccounts = new List<MetraTech.DomainModel.BaseTypes.Account>();
    public List<MetraTech.DomainModel.BaseTypes.Account>.Enumerator m_UpdatedAccountsIter;
    public MetraTech.DomainModel.BaseTypes.Account m_CurrentAccount = null;
    #endregion

    #region RootAccount
    public static DependencyProperty RootAccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("RootAccount", typeof(AccountIdentifier), typeof(ApplyTemplateWorkflow));
    public static DependencyProperty whileActivity1_Condition1Event;

    [Description("This is the root account, to whose descendents the template will be applied")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [Input]
    public AccountIdentifier RootAccount
    {
      get
      {
        return ((AccountIdentifier)(base.GetValue(ApplyTemplateWorkflow.RootAccountProperty)));
      }
      set
      {
        base.SetValue(ApplyTemplateWorkflow.RootAccountProperty, value);
      }
    }
    #endregion

    #region AccountType
    public static DependencyProperty AccountTypeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AccountType", typeof(string), typeof(ApplyTemplateWorkflow));

    [Description("This is the type of descendent account to which the template will be applied")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [Input]
    public string AccountType
    {
      get
      {
        return ((string)(base.GetValue(ApplyTemplateWorkflow.AccountTypeProperty)));
      }
      set
      {
        base.SetValue(ApplyTemplateWorkflow.AccountTypeProperty, value);
      }
    }
    #endregion

    #region TemplateScope
    public static DependencyProperty TemplateScopeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("TemplateScope", typeof(AccountTemplateScope), typeof(ApplyTemplateWorkflow));

    [Description("This determines which descendent accounts will get the template")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [Input]
    public AccountTemplateScope TemplateScope
    {
      get
      {
        return ((AccountTemplateScope)(base.GetValue(ApplyTemplateWorkflow.TemplateScopeProperty)));
      }
      set
      {
        base.SetValue(ApplyTemplateWorkflow.TemplateScopeProperty, value);
      }
    }
    #endregion

    #region EffectiveDate
    public static DependencyProperty EffectiveDateProperty = System.Workflow.ComponentModel.DependencyProperty.Register("EffectiveDate", typeof(DateTime), typeof(ApplyTemplateWorkflow));

    [Description("This is the effective date of the template application")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [Input]
    public DateTime EffectiveDate
    {
      get
      {
        return ((DateTime)(base.GetValue(ApplyTemplateWorkflow.EffectiveDateProperty)));
      }
      set
      {
        base.SetValue(ApplyTemplateWorkflow.EffectiveDateProperty, value);
      }
    }
    #endregion

    #region PropertyNames
    public static DependencyProperty PropertyNamesProperty = System.Workflow.ComponentModel.DependencyProperty.Register("PropertyNames", typeof(List<string>), typeof(ApplyTemplateWorkflow));

    [Description("This is the list of template properties to be applied")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [Input]
    public List<string> PropertyNames
    {
      get
      {
        return ((List<string>)(base.GetValue(ApplyTemplateWorkflow.PropertyNamesProperty)));
      }
      set
      {
        base.SetValue(ApplyTemplateWorkflow.PropertyNamesProperty, value);
      }
    }
    #endregion

    #region Subscriptions
    public static DependencyProperty SubscriptionsProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Subscriptions", typeof(List<AccountTemplateSubscription>), typeof(ApplyTemplateWorkflow));

    [Description("This is the list of subscriptions to be applied")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [Input]
    public List<AccountTemplateSubscription> Subscriptions
    {
      get
      {
        return ((List<AccountTemplateSubscription>)(base.GetValue(ApplyTemplateWorkflow.SubscriptionsProperty)));
      }
      set
      {
        base.SetValue(ApplyTemplateWorkflow.SubscriptionsProperty, value);
      }
    }
    #endregion

    #region SubscriptionSpan
    public static DependencyProperty SubscriptionSpanProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SubscriptionSpan", typeof(ProdCatTimeSpan), typeof(ApplyTemplateWorkflow));

    [Description("This defines the date ranges for all the new subscritions")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [Input]
    public ProdCatTimeSpan SubscriptionSpan
    {
      get
      {
        return ((ProdCatTimeSpan)(base.GetValue(ApplyTemplateWorkflow.SubscriptionSpanProperty)));
      }
      set
      {
        base.SetValue(ApplyTemplateWorkflow.SubscriptionSpanProperty, value);
      }
    }
    #endregion

    #region EndConflictingSubscriptions
    public static DependencyProperty EndConflictingSubscriptionsProperty = System.Workflow.ComponentModel.DependencyProperty.Register("EndConflictingSubscriptions", typeof(bool), typeof(ApplyTemplateWorkflow));

    [Description("This determines what to do if there are conflicting subscriptions")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    [Input]
    public bool EndConflictingSubscriptions
    {
      get
      {
        return ((bool)(base.GetValue(ApplyTemplateWorkflow.EndConflictingSubscriptionsProperty)));
      }
      set
      {
        base.SetValue(ApplyTemplateWorkflow.EndConflictingSubscriptionsProperty, value);
      }
    }
    #endregion

    private void codeActivity1_ExecuteCode(object sender, EventArgs e)
    {
      YAAC.IMTSessionContext sessionContext = (YAAC.IMTSessionContext)GetSessionContext();
      MetraTech.Interop.IMTAccountType.IMTAccountType accType = null;

      int rootAccountId = AccountIdentifierResolver.ResolveAccountIdentifier(RootAccount);

      ValidateAccountTemplateInfo(rootAccountId, AccountType, EffectiveDate, out m_RootYAAC, out accType);
    }

    private void ValidateAccountTemplateInfo(int templateAcctId, string accountType, DateTime effectiveDate, out IMTYAAC templateYAAC, out MetraTech.Interop.IMTAccountType.IMTAccountType accType)
    {
      templateYAAC = new MTYAACClass();
      templateYAAC.InitAsSecuredResource(templateAcctId, (YAAC.IMTSessionContext)GetSessionContext(), effectiveDate);

      AccountType acctType = new AccountType();
      acctType.InitializeByID(templateYAAC.AccountTypeID);

      if (!acctType.CanHaveTemplates)
      {
        throw new MASBasicException("The account type for the specified account can not have templates");
      }

      AccountTypeCollection accountTypeCol = new AccountTypeCollection();
      accType = accountTypeCol.GetAccountType(accountType);

      if (accType == null)
      {
        throw new MASBasicException("Invalid account type specified");
      }

      YAAC.IMTSQLRowset rs = (YAAC.IMTSQLRowset)acctType.GetDescendentAccountTypesAsRowset();
      YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
      filter.Add("DescendentAccountTypeName", YAAC.MTOperatorType.OPERATOR_TYPE_EQUAL, accountType);

      rs.Filter = filter;

      if (rs.RecordCount == 0)
      {
        throw new MASBasicException("The specified account type is not a valid descendent account type for the specified account");
      }
    }

    protected YAAC.IMTSessionContext GetSessionContext()
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

    private void GetDescendentsAndPrepareUpdates_ExecuteCode(object sender, EventArgs e)
    {
      m_Accounts = (YAAC.IMTCollection)new MetraTech.Interop.GenericCollection.MTCollectionClass();
      YAAC.IMTCollection accountTypeCol = (YAAC.IMTCollection)new MetraTech.Interop.GenericCollection.MTCollectionClass();

      accountTypeCol.Add(AccountType);

      YAAC.MTHierarchyPathWildCard wildCard = ((YAAC.MTHierarchyPathWildCard)((int)TemplateScope));
      m_RootYAAC.GetDescendents(m_Accounts, EffectiveDate, wildCard, true, accountTypeCol);

      MetraTech.DomainModel.BaseTypes.Account updatedAccount;
      object value;
      foreach (int id_acc in m_Accounts)
      {
        updatedAccount = MetraTech.DomainModel.BaseTypes.Account.CreateAccount(AccountType);

        updatedAccount._AccountID = id_acc;

        foreach (string propName in PropertyNames)
        {
          if (m_TemplateDefinition.Properties.ContainsKey(propName))
          {
            value = m_TemplateDefinition.Properties[propName];

            updatedAccount.SetValue(propName, value);
          }
          else
          {
            throw new MASBasicException(string.Format("Property {0} not found in template definition", propName));
          }
        }

        m_UpdatedAccounts.Add(updatedAccount);
      }

      m_UpdatedAccountsIter = m_UpdatedAccounts.GetEnumerator();
    }

    private bool WhileCondition()
    {
      bool retval = m_UpdatedAccountsIter.MoveNext();

      if (retval)
      {
        m_CurrentAccount = m_UpdatedAccountsIter.Current;
      }

      return retval;
    }

    private void ApplySubscriptions_ExecuteCode(object sender, EventArgs e)
    {
      IMTSubscriptionCatalog subCatalog = new MTSubscriptionCatalogClass();
      IMTProductCatalog prodCatalog = new MTProductCatalogClass();
      IMTGroupSubscription groupSub = null;
      IMTSubInfo subInfo;

      subCatalog.SetSessionContext(((MetraTech.Interop.Subscription.IMTSessionContext)GetSessionContext()));
      prodCatalog.SetSessionContext(((MetraTech.Interop.MTProductCatalog.IMTSessionContext)GetSessionContext()));

      foreach (AccountTemplateSubscription templateSub in Subscriptions)
      {
        MetraTech.Interop.Subscription.IMTCollection subCol = ((MetraTech.Interop.Subscription.IMTCollection)new MetraTech.Interop.GenericCollection.MTCollectionClass());
      
        if (templateSub.GroupID != -1)
        {
          groupSub = prodCatalog.GetGroupSubscriptionByID(templateSub.GroupID);
        }

        foreach (int id_acc in m_Accounts)
        {
          subInfo = new MTSubInfoClass();

          subInfo.AccountID = id_acc;
          subInfo.ProdOfferingID = templateSub.ProductOfferingId;

          if (groupSub != null)
          {
            subInfo.CorporateAccountID = groupSub.CorporateAccount;
            subInfo.GroupSubID = groupSub.GroupID;
          }

          subInfo.SubsStartDate = SubscriptionSpan.StartDate.Value;
          subInfo.SubsStartDateType = (MTPCDateType)SubscriptionSpan.StartDateType;

          if (SubscriptionSpan.IsEndDateDirty)
          {
            subInfo.SubsEndDate = SubscriptionSpan.EndDate.Value;
          }
          else
          {
            subInfo.SubsEndDate = MetraTime.Max;
          }

          if (SubscriptionSpan.IsEndDateTypeDirty)
          {
            subInfo.SubsEndDateType = (MTPCDateType)SubscriptionSpan.EndDateType;
          }

          subCol.Add(subInfo);
        }

        bool bDateModified;
        MetraTech.Interop.Subscription.IMTRowSet errors;
        if (groupSub == null)
        {
          errors = subCatalog.SubscribeAccounts(subCol, null, EndConflictingSubscriptions, out bDateModified, null);
        }
        else
        {
          errors = subCatalog.SubscribeToGroups(subCol, null, EndConflictingSubscriptions, out bDateModified, null);
        }

        if (errors.RecordCount != 0)
        {
          MASBasicException mas = new MASBasicException("Errors applying subscription to accounts");

          errors.MoveFirst();

          while (!((bool)errors.EOF))
          {
            mas.AddErrorMessage(((string)errors.get_Value(0)));

            errors.MoveNext();
          }

          throw mas;
        }

        groupSub = null;
      }
    }
  }

}
