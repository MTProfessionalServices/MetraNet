using System.Runtime.InteropServices;
using System.EnterpriseServices;
using System.Collections;

namespace MetraTech.Accounts.PlugIns
{
  using MetraTech;
  using MetraTech.Xml;
  using MetraTech.Pipeline;
  using PC = MetraTech.Interop.MTProductCatalog;
  using YAAC = MetraTech.Interop.MTYAAC;
  using MetraTech.Accounts.Type;
  using MetraTech.Interop.IMTAccountType;

  using MetraTech.DataAccess;
  using MetraTech.Interop.MTPipelineLib;
  using MTCollection = MetraTech.Interop.GenericCollection;

  using System;
  using System.Collections;
  using System.Diagnostics;
  using System.Text;

  [Guid("33da79da-406e-4465-8b0c-012a60a982ef")]
  public interface IYAACReader
  {
    YAAC.IMTYAAC CreateYAAC(int aAccountAncestorID, IMTSessionContext aCtx, DateTime aStartDate);
  }

  [Transaction(TransactionOption.Supported, Isolation=TransactionIsolationLevel.Any)]
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("4d2b7eb2-115f-4176-882a-f12d9416528f")]
  public class YAACReader : ServicedComponent, IYAACReader
  {
    public YAACReader()
    { 
    }

    [AutoComplete]
    public YAAC.IMTYAAC CreateYAAC(int aAccountAncestorID, IMTSessionContext aCtx, DateTime aStartDate)
    {
      YAAC.IMTYAAC yaac = new YAAC.MTYAACClass();
      yaac.InitAsSecuredResource(aAccountAncestorID, (YAAC.IMTSessionContext)aCtx, aStartDate);
      return yaac;
    }
  }

  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("feea0a32-e163-448a-975d-652dd9771da0")]
  public class TemplateSubscriptionWriter : ServicedComponent, ITemplateSubscriptionWriter
  {
    public TemplateSubscriptionWriter()
    { 
    }

    [AutoComplete]
    internal void InitializeSubscriptionDates(ref DateTime        subStartDate,
                                              ref DateTime        subEndDate, 
                                                  IMTSession      aSession,
                                                  PipelinePropIDs ids,
                                                  bool            abNewAccount)
    {
      //figure out start date for subscriptions: If account Start Date is Set, then
      //that's what it's going to be, otherwise we know that AddNewAccount stored proc
      //uses dbo.mtstartofday(@p_systemdate) function, so do the same logic
      
      if(abNewAccount)
      {
        if(aSession.PropertyExists(ids.mlAccountStartDateID, MTSessionPropType.SESS_PROP_TYPE_DATE))
          subStartDate = (DateTime)aSession.GetOLEDateProperty(ids.mlAccountStartDateID);
        else
          subStartDate = MetraTime.Now.Date;

        if (aSession.PropertyExists(ids.mlAccountEndDateID, MTSessionPropType.SESS_PROP_TYPE_DATE))
          subEndDate = (DateTime)aSession.GetOLEDateProperty(ids.mlAccountEndDateID);
      }
      //in case of account updates we need to look at hierarchy start and end dates
      else
      {
        if(aSession.PropertyExists(ids.mlHierarchyStartDateID, MTSessionPropType.SESS_PROP_TYPE_DATE))
          subStartDate = (DateTime)aSession.GetOLEDateProperty(ids.mlHierarchyStartDateID);
        else
          subStartDate = MetraTime.Now.Date;

        if (aSession.PropertyExists(ids.mlHierarchyEndDateID, MTSessionPropType.SESS_PROP_TYPE_DATE))
          subEndDate = (DateTime)aSession.GetOLEDateProperty(ids.mlHierarchyEndDateID);
        else
          subEndDate = MetraTime.Max.Date;
      }
    }

    [AutoComplete]

    internal void ApplyAccountTemplateSubscriptions(
                          YAAC.IMTAccountTemplate              aTemplate, 
                      ref YAAC.IMTAccountTemplateSubscriptions aTemplateSubs, 
                      ref PC.IMTPCAccount                      aAccount, 
                          int                                  aAccountID, 
                          DateTime                             aStartDate, 
                          DateTime                             aEndDate, 
                          Interfaces                           interfaces)
    {
      interfaces.Logger.LogDebug(
        string.Format("Template on account {0}/{1} ({2}) has {3} subscriptions", 
        aTemplate.TemplateAccountName, aTemplate.TemplateAccountNameSpace,
        aTemplate.TemplateAccountID, aTemplateSubs.Count));

      foreach(YAAC.MTAccountTemplateSubscription sub in aTemplateSubs)
      {
        PC.IMTPCAccount acc = aAccount;

        if(sub.GroupSubscription)
        {
          this.JoinGroupSubscription(aAccountID, aStartDate, aEndDate, sub.GroupID, interfaces);
        }
        //regular subscription
        else
        {
          bool bModified;
          this.SubscribeAccount(ref acc, aStartDate, aEndDate, sub.ProductOfferingID, interfaces, out bModified);
        }
      }
    }

    [AutoComplete]

    internal void TruncateAccountTemplateSubscriptions(
                              ref MTCollection.IMTCollection   aGsubsToTruncate, 
                              ref MTCollection.IMTCollection   aSubsToTruncate, 
                              ref PC.IMTPCAccount aAccount, 
                                  DateTime        aEffectiveDate, 
                                  Interfaces      interfaces)
    {
      PC.IMTPCAccount acc = aAccount;
      
      foreach(PC.IMTGroupSubscription gsub in aGsubsToTruncate)
      {
        this.LeaveGroupSubscription(acc.AccountID, aEffectiveDate, gsub.GroupID, interfaces);
      }

      foreach(PC.IMTSubscription sub in aSubsToTruncate)
      {
        bool bModified = false;
        this.UnsubscribeAccount(ref acc, aEffectiveDate, sub, interfaces, out bModified);
      }

      return;
    }

    // Initialize subscriptions that should be truncated and
    // template subscriptions that should be re-applied
    //
    // Determine which subscriptions that already exist on the account
    // need to be truncated based on following rules:
    //
    // 1. For individual subscriptions truncate it if Account template does not contain
    //    subscriptions for the same product offering. If it does, then we don't truncate it, and we
    //    we don't try to subscribe an account to this product offering again later in 
    //    ApplyAccountTemplateSubscriptions method.
    //
    // 2. For group subscriptions, truncate all account group subscriptions.
    //
    // This method returns a list of AccountTemplateSubscription objects that actually
    // will be applied to this account.
    //
    internal void InitializeSubscriptions(ref YAAC.IMTAccountTemplate              aTemplate,
                                          ref PC.IMTPCAccount                      aAccount,
                                              DateTime                             aEffectiveDate,
                                              Interfaces                           interfaces,
                                              bool                                 abTruncateExistingSubs, 
                                          out MTCollection.IMTCollection                        oGSubsToTruncate, 
                                          out MTCollection.IMTCollection                        oSubsToTruncate, 
                                          out YAAC.IMTAccountTemplateSubscriptions oTemplateSubsToApply)
    {
      oGSubsToTruncate = (MTCollection.IMTCollection)new MTCollection.MTCollectionClass();
      oSubsToTruncate = (MTCollection.IMTCollection)new MTCollection.MTCollectionClass();
      oTemplateSubsToApply = new YAAC.MTAccountTemplateSubscriptions();

      YAAC.MTAccountTemplateSubscriptions subs = aTemplate.Subscriptions;
      PC.IMTPCAccount acc = aAccount;

      interfaces.Logger.LogDebug(
        string.Format("Template on account {0}/{1} ({2}) has {3} subscriptions", 
        aTemplate.TemplateAccountName, aTemplate.TemplateAccountNameSpace,
        aTemplate.TemplateAccountID, subs.Count));

      //2. build a quick map of account template subscriptions
      Hashtable templatesubs = new Hashtable();
      Hashtable templategsubs = new Hashtable();
      foreach(YAAC.MTAccountTemplateSubscription sub in subs)
      {
        if(!sub.GroupSubscription)
        {
          templatesubs.Add(sub.ProductOfferingID, sub);
        }
        else
          // Note that MTAccountTemplateSubscription API is misleading
          // ProductOfferingID property is really a GroupID if it's a group subscription
          templategsubs.Add(sub.GroupID, sub);
      }
      
      // CR 10764:
      // ALWAYS truncate/reapply a group subscription
      foreach(PC.IMTGroupSubscription gsub in aAccount.GetGroupSubscriptions())
      {
        // CR 13333
        // Only terminate group subscriptions that are active (current) or are in future
        if (gsub.EffectiveDate.EndDate > aEffectiveDate)
          oGSubsToTruncate.Add(gsub);
      }
      
      //3. Iterate through individual subscriptions on account
      //   For the ones that are associated with product offerings that are also on the template,
      //   leave them along (do not unsubscribe/rescubscribe)
      //   The ones that are associated with product offerings that ARE NOT contained in 
      //   template subscriptions will be truncated.
      foreach(PC.IMTSubscription sub in aAccount.GetSubscriptions())
      {
        // if subscription already ended as of account move date, 
        // then don't touch it
        if(sub.EffectiveDate.EndDate > aEffectiveDate)
        {
          if(!templatesubs.Contains(sub.ProductOfferingID))
          {
            oSubsToTruncate.Add(sub);
          }
          // if subscription with the same product offering id is there
          // then we won't reapply it
          // CR 10937: (abTruncateExistingSubs == true). If I am not going to truncate
          // existing subscriptions, then I want subscription to fail because I am already
          // subscribe. So, don't remove a subscription to sub.ProductOfferingID from the lst
          else if(abTruncateExistingSubs == true)
            templatesubs.Remove(sub.ProductOfferingID);
        }
      }

      // initialize a collection of template subscriptions to be reapplied
      // from what's left in the hashtables
      foreach(YAAC.MTAccountTemplateSubscription sub in templatesubs.Values)
      {
          oTemplateSubsToApply.Add(sub);
      }
      foreach(YAAC.MTAccountTemplateSubscription sub in templategsubs.Values)
      {
          oTemplateSubsToApply.Add(sub);
      }

      return;
    }

    [AutoComplete]
    internal void JoinGroupSubscription(int aAccountID, DateTime aStartDate, DateTime aEndDate, int aGroupID, Interfaces interfaces)
    {
      PC.IMTGroupSubscription gs = interfaces.ProdCat.GetGroupSubscriptionByID(aGroupID);
      PC.IMTGSubMember gsmember = new PC.MTGSubMemberClass();
      gsmember.AccountID = aAccountID;

      // Set membership date as Max of Account Start Date and Subscription Start Date
      // (We don't need to do this for end dates because they'll automatically be adjusted)
      DateTime realStartDate = aStartDate.CompareTo(gs.EffectiveDate.StartDate) > 0
                                                       ? aStartDate : gs.EffectiveDate.StartDate;

      // if real start date falls after account move/create time span ends, just return
      if(realStartDate > aEndDate)
        return;

      gsmember.StartDate = realStartDate;

      if(aEndDate != DateTime.MinValue)
        gsmember.EndDate = aEndDate;

      gs.AddAccount((PC.MTGSubMember)gsmember);
    }

    [AutoComplete]
    internal void LeaveGroupSubscription(int aAccountID, DateTime aEffDate, int aGroupID, Interfaces interfaces)
    {
      DateTime OneSecondBefore = aEffDate.AddSeconds(-1);
      PC.IMTGroupSubscription gs = interfaces.ProdCat.GetGroupSubscriptionByID(aGroupID);
      
      // if subscription starts in the future, then we need to call DeleteMember
      if(gs.EffectiveDate.StartDate > aEffDate)
      {
        // System.Reflection.Missing date is the only way to pass
        // an optional variant and it means that I want to remove all participation
        // records for this account in this group subscription
        gs.DeleteMember(aAccountID, System.Reflection.Missing.Value);
      }
      else
      {
        PC.IMTGSubMember gsmember = new PC.MTGSubMemberClass();
        gsmember.AccountID = aAccountID;
        gsmember.EndDate = OneSecondBefore;

        gs.UnsubscribeMember((PC.MTGSubMember)gsmember);
      }
    }

    [AutoComplete]
    internal void SubscribeAccount(ref PC.IMTPCAccount acc, DateTime aStartDate, DateTime aEndDate, int aPOID, Interfaces interfaces, out bool abModified)
    {
      PC.MTPCTimeSpan effdate = new PC.MTPCTimeSpanClass();

      // always absolute
      effdate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      effdate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;

      effdate.StartDate = aStartDate;
      if(aEndDate != DateTime.MinValue)
        effdate.EndDate = aEndDate;
      else
        effdate.SetEndDateNull();

      object bModified = false;
      acc.Subscribe(aPOID, effdate, out bModified);
      abModified = (bool)bModified;
    }

    [AutoComplete]
    internal void UnsubscribeAccount(ref PC.IMTPCAccount acc, DateTime aEffDate, PC.IMTSubscription aSub, Interfaces interfaces, out bool abModified)
    {
      object bModified = false;
      DateTime OneSecondBefore = aEffDate.AddSeconds(-1);

      // if subscription starts in the future, then we need to call RemoveSubscription
      if(aSub.EffectiveDate.StartDate >= aEffDate)
        acc.RemoveSubscription(aSub.ID);
      else
        bModified = acc.Unsubscribe(aSub.ID, OneSecondBefore, PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE);

      abModified = (bool)bModified;
    }

    [AutoComplete]
    internal void ProcessAccountTemplateSubscriptions(IMTSession      session,
                                                      PipelinePropIDs ids,
                                                      Interfaces      interfaces,
                                                      int accountTypeID)
    {
      int    lAccountID          = session.GetLongProperty(ids.mlAccountIDID);
      int    lAccountAncestorID  = session.GetLongProperty(ids.mlAncestorAccountIDID);
      string sAccountName = "";        
      if(session.PropertyExists(ids.mlUserNameID, MTSessionPropType.SESS_PROP_TYPE_STRING)) 
       sAccountName = session.GetStringProperty(ids.mlUserNameID);
      string sAccountNameSpace = "";   
      if (session.PropertyExists(ids.mlUserNameID, MTSessionPropType.SESS_PROP_TYPE_STRING))
       sAccountNameSpace = session.GetStringProperty(ids.mlNameSpaceID);
      int    lCorporateAccountID = session.GetLongProperty(ids.mlCorporateAccountIDID);

      if(lAccountAncestorID == 1)
      {
        interfaces.Logger.LogDebug(string.Format("Account {0} is topmost (corporate), nothing to do", lAccountID));
        return;
      }

      IMTSessionContext ctx = session.SessionContext;
      interfaces.ProdCat.SetSessionContext((PC.IMTSessionContext)ctx);

      // See if it's a new account or update
      int lOpID = session.GetEnumProperty(ids.mlOperationID);
      int lOp = System.Convert.ToInt32(interfaces.EnumConfig.GetEnumeratorValueByID(lOpID));
      bool bNewAccount = (lOp == 0);

      int lOldAncestorAccountID = -1;

      if(!bNewAccount)
      {
            lOldAncestorAccountID = session.GetLongProperty(ids.mlOldAncestorAccountIDID);
        int lNewAncestorAccountID = session.GetLongProperty(ids.mlAncestorAccountIDID);

        // If this is an update and the accounts ancestor did not change then we are done.
        if(lOldAncestorAccountID == lNewAncestorAccountID)
        {
          interfaces.Logger.LogDebug(
             @"Account ancestor did not change in this update session, " +
              "account template subscriptions will not be re-applied");
          return;
        }
        else
        {
          interfaces.Logger.LogDebug(
            string.Format(@"Account {0} was moved from {1} folder to {2} folder, "+
            "Account template subscriptions will be applied from new ancestor", lAccountID, lOldAncestorAccountID, lNewAncestorAccountID));
        }
      }

      DateTime subStartDate = DateTime.MinValue;
      DateTime subEndDate   = DateTime.MinValue;
      InitializeSubscriptionDates(ref subStartDate, ref subEndDate, session, ids, bNewAccount);

      // initialize template object, if we get here then this is
      // a new account or the ancestor changed on update
      interfaces.Logger.LogDebug(
        string.Format("Looking up account template for account {0}/{1} ({2})", sAccountName, sAccountNameSpace, lAccountID));

      YAAC.IMTAccountTemplate template = new YAAC.MTAccountTemplateClass();
      template.Initialize((YAAC.IMTSessionContext)ctx,
                          lAccountAncestorID,
                          lCorporateAccountID,
                          accountTypeID,
                          subStartDate);

      if(template.TemplateAccountID < 1)
      {
        interfaces.Logger.LogDebug
          (string.Format("None of the ancestors for account {0}/{1} ({2}) have templates, nothing to do", 
          sAccountName, sAccountNameSpace, lAccountID));
        return;
      }
      else
      {
        interfaces.Logger.LogDebug(
          string.Format("Closest ancestor with template for account {0}/{1}({2}) is {3}/{4}({5})", 
          sAccountName, sAccountNameSpace, lAccountID, 
          template.TemplateAccountName, template.TemplateAccountNameSpace, template.TemplateAccountID));
      }

      // if it's account move operation, then make sure that old and new ancestor don't
      // have the same 'templated' ancestor as the new ancestor, otherwise it's a NOP
      // the accountypeid in this function should be the same as before.. does not matter
      // if the account type of the ancestor is different
      if (!bNewAccount)
      {
        YAAC.IMTAccountTemplate newTemplate = new YAAC.MTAccountTemplateClass();
        newTemplate.Initialize((YAAC.IMTSessionContext)ctx,
                               lOldAncestorAccountID,
                               lCorporateAccountID,
                               accountTypeID,
                               subStartDate);

        if(newTemplate.TemplateAccountID == template.TemplateAccountID)
        {
          interfaces.Logger.LogDebug (string.Format(
            "Both new and old ancestor for account {0}/{1}({2}) share " +
            "template associated with {3}/{4}({5}), template subscriptions will not be re-applied.", 
            sAccountName, 
            sAccountNameSpace, 
            lAccountID, 
            template.TemplateAccountName, 
            template.TemplateAccountNameSpace, 
            template.TemplateAccountID));
          return;
        }
      }

      // truncate old subscriptions if TruncateSubscriptions
      // flag is set to true
      PC.IMTPCAccount acc = null;

      YAAC.IMTAccountTemplateSubscriptions SubsToApply = null;
      MTCollection.IMTCollection substotruncate = null;
      MTCollection.IMTCollection gsubstotruncate = null;
      bool bTruncateExistingSubs = false;

      if(!bNewAccount)
        bTruncateExistingSubs = ((session.PropertyExists(ids.mlTruncateSubsID, MTSessionPropType.SESS_PROP_TYPE_BOOL))
                              && (session.GetBoolProperty(ids.mlTruncateSubsID) == true));

      acc = interfaces.ProdCat.GetAccount(lAccountID);
      InitializeSubscriptions(ref template, ref acc, subStartDate, interfaces, bTruncateExistingSubs, 
                              out gsubstotruncate, out substotruncate, out SubsToApply);

      if(!bNewAccount)
      {
        // Look if TruncateSubscriptions property is in session and set to true
        if (bTruncateExistingSubs)
        {
          this.TruncateAccountTemplateSubscriptions(  ref gsubstotruncate, 
                                                      ref substotruncate, 
                                                      ref acc, 
                                                      subStartDate, 
                                                      interfaces);
        }
      }

      // subscribe it to
      // all template subscriptions as of account start date(or hierarchy start date in case of update); also
      // join all template group subs as of account start date (or hierarchy start date in case of update)
      ApplyAccountTemplateSubscriptions(template, ref SubsToApply, ref acc, lAccountID, subStartDate, subEndDate, interfaces);
    }
  }

  [Guid("3719b717-bce4-486b-aa3c-0353ed9f2a24")]
  [ClassInterface(ClassInterfaceType.None)]
  public class UpdateSubscriptions : IMTPipelinePlugIn
  {
    public UpdateSubscriptions()
    {
    }

    public void Configure(object                                           systemContext,
                          MetraTech.Interop.MTPipelineLib.IMTConfigPropSet propSet)
    {
      mInterfaces            = new Interfaces();
      mInterfaces.ProdCat    = new PC.MTProductCatalogClass();
      mInterfaces.EnumConfig = (IEnumConfig)systemContext;
      mInterfaces.Logger     = new Logger((MetraTech.Interop.SysContext.IMTLog) systemContext);

      Debug.Assert(mInterfaces.EnumConfig != null);

      IMTNameID nameID = (IMTNameID) systemContext;

      mProps = new PipelinePropIDs();
      mProps.mlOperationID            = nameID.GetNameID("operation");
      mProps.mlTruncateSubsID         = nameID.GetNameID("TruncateOldSubscriptions");
      mProps.mlAccountIDID            = nameID.GetNameID("_AccountID");
      mProps.mlAccountStartDateID     = nameID.GetNameID("accountstartdate");
      mProps.mlAccountEndDateID       = nameID.GetNameID("accountenddate");
      mProps.mlAncestorAccountIDID    = nameID.GetNameID("ancestorAccountID");
      mProps.mlAccountTypeID          = nameID.GetNameID("AccountType");
      mProps.mlUserNameID             = nameID.GetNameID("username");
      mProps.mlNameSpaceID            = nameID.GetNameID("name_space");
      mProps.mlOldAncestorAccountIDID = nameID.GetNameID("OldAncestorAccountID");
      mProps.mlHierarchyStartDateID   = nameID.GetNameID("hierarchy_startdate");
      mProps.mlHierarchyEndDateID     = nameID.GetNameID("hierarchy_enddate");
      mProps.mlCorporateAccountIDID   = nameID.GetNameID("CorporateAccountID");
    }

    void IMTPipelinePlugIn.Shutdown()
    { }

    void IMTPipelinePlugIn.ProcessSessions(IMTSessionSet sessions)
    {
      IEnumerator enumerator = sessions.GetEnumerator();

      try
      {
        while (enumerator.MoveNext())
        {
          IMTSession session = (IMTSession) enumerator.Current;
          try
          {
            MetraTech.Interop.MTPipelineLib.IMTTransaction transaction = session.GetTransaction(false);

            TemplateSubscriptionWriter templatewriter = null;

            if(transaction == null)
              templatewriter = new TemplateSubscriptionWriter();
            else
              templatewriter = (TemplateSubscriptionWriter)BYOT.CreateWithTransaction(
                transaction.GetTransaction(), typeof(TemplateSubscriptionWriter));

            //get the account type id.
            string accountTypeName = (string)session.GetStringProperty(mProps.mlAccountTypeID);
            int accountTypeID = mAccountTypes.GetAccountType(accountTypeName).ID;

            templatewriter.ProcessAccountTemplateSubscriptions(session, mProps, mInterfaces, accountTypeID);
          }
          finally
          {
            // Explicitly release our reference to the object
            Marshal.ReleaseComObject(session);
          }
        }
      }
      catch(Exception ex)
      {
        mInterfaces.Logger.LogError(ex.Message);
        throw;
      }
      finally
      {
        // important - explicitly release our reference to the object
        ICustomAdapter adapter = (ICustomAdapter)enumerator;
        Marshal.ReleaseComObject(adapter.GetUnderlyingObject());
        Marshal.ReleaseComObject(sessions);
      }
    }

    public int ProcessorInfo
    {
      get
      {
        int e_notimpl = -2147467263; //0x80004001
        throw new COMException("not implemented", e_notimpl);
      }
    }

    private PipelinePropIDs mProps;
    private Interfaces      mInterfaces;
    private AccountTypeCollection mAccountTypes = new AccountTypeCollection();
  }
}
