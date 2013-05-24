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
  using MTCollection = MetraTech.Interop.MTProductCatalog;

  using System;
  using System.Collections;
  using System.Diagnostics;
  using System.Text;
  
 	[ComVisible(true)]
  [Guid("BF5D0EF4-D6CA-4045-89D2-1DD670877525")]
  public interface IUnsubscribeWriter
  {}
  
 
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("AC69CFF1-C516-4e30-91C4-9E98A14CD171")]
  public class UnsubscribeWriter : ServicedComponent, IUnsubscribeWriter
  {
    public UnsubscribeWriter()
    { 
    }

    [AutoComplete]
    internal void ProcessSubscriptions(IMTSession session, 
                                        Interfaces interfaces, 
                                        int accountID, 
                                        DateTime terminateDate, 
                                        bool CanSubscribe, 
                                        bool CanParticipateInGSub)
    {
      IMTSessionContext ctx = session.SessionContext;
      interfaces.ProdCat.SetSessionContext((PC.IMTSessionContext)ctx);
      
      PC.IMTPCAccount acc = null;

      acc = interfaces.ProdCat.GetAccount(accountID);

      DateTime OneSecondBefore = terminateDate.AddSeconds(-1);
      if (CanSubscribe)
      {
        foreach(PC.IMTSubscription sub in acc.GetSubscriptions())
        {
          DateTime enddate = sub.EffectiveDate.EndDate;
          DateTime startdate = sub.EffectiveDate.StartDate;
    
          if ((sub.EffectiveDate.EndDate > terminateDate) && (sub.EffectiveDate.StartDate <= terminateDate))
          {
            acc.Unsubscribe(sub.ID, terminateDate, PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE);
          }
          else if ((sub.EffectiveDate.EndDate > terminateDate) && (sub.EffectiveDate.StartDate > terminateDate))
          {
            acc.RemoveSubscription(sub.ID);
          }

        }
       
      }
      if (CanParticipateInGSub)
      {
        foreach(PC.IMTGroupSubscription gsub in acc.GetGroupSubscriptions())
        {
          DateTime enddate = gsub.EffectiveDate.EndDate;
          DateTime startdate = gsub.EffectiveDate.StartDate;
  
          if((gsub.EffectiveDate.EndDate > terminateDate) && (gsub.EffectiveDate.StartDate > terminateDate))
          {
            // System.Reflection.Missing date is the only way to pass
            // an optional variant and it means that I want to remove all participation
            // records for this account in this group subscription
            gsub.DeleteMember(accountID, System.Reflection.Missing.Value);
          }
          else if ((gsub.EffectiveDate.EndDate > terminateDate) && (gsub.EffectiveDate.StartDate <= terminateDate))
          {
            PC.IMTGSubMember gsmember = new PC.MTGSubMemberClass();
            gsmember.AccountID = accountID;
            gsmember.EndDate = OneSecondBefore;

            gsub.UnsubscribeMember((PC.MTGSubMember)gsmember);
          }
 
        }
      }

    }

  }
  
  
 
  [Guid("61E283A8-7F81-4a9b-A054-91556575A7E0")]
  [ClassInterface(ClassInterfaceType.None)]
  public class Unsubscribe : IMTPipelinePlugIn
  {
    public Unsubscribe()
    {
    }

    public void Configure(object systemContext,
                          MetraTech.Interop.MTPipelineLib.IMTConfigPropSet propSet)
    {
      mInterfaces            = new Interfaces();
      mInterfaces.ProdCat    = new PC.MTProductCatalogClass();
      mInterfaces.EnumConfig = (IEnumConfig)systemContext;
      mInterfaces.Logger     = new Logger((MetraTech.Interop.SysContext.IMTLog) systemContext);

      Debug.Assert(mInterfaces.EnumConfig != null);

      IMTNameID nameID = (IMTNameID) systemContext;

      mlAccountIDID            = nameID.GetNameID("_AccountID");
      mlActionTypeID           = nameID.GetNameID("ActionType");
      mlOperationID            = nameID.GetNameID("operation");
      mlCanSubscribeID         = nameID.GetNameID("b_cansubscribe");
      mlCanParticipateInGSubID = nameID.GetNameID("b_CanParticipateInGSub");
      mlHierarchyStartDateID   = nameID.GetNameID("hierarchy_startdate");
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
          int accountID;
          int ActionType;
          int Operation;
          bool CanSubscribe;
          bool CanParticipateInGSub;
          DateTime terminateDate = DateTime.MinValue;
           
          accountID = session.GetLongProperty(mlAccountIDID);

          //check if operation is update, else skip
          //check if actiontype is account or both, else skip
          //make sure atleast one of b_cansubscribe and b_canparticipateingsub is true, else skip

          Operation = session.GetEnumProperty(mlOperationID);
          int op = System.Convert.ToInt32(mInterfaces.EnumConfig.GetEnumeratorValueByID(Operation));
          if (op != 1) //not update skip
          { 
            mInterfaces.Logger.LogWarning(string.Format("Skipping terminating subscriptions on account {0}, operation is not update", accountID));
            continue;
          }

          ActionType = session.GetEnumProperty(mlActionTypeID);
          int action = System.Convert.ToInt32(mInterfaces.EnumConfig.GetEnumeratorValueByID(ActionType));
          if (action == 1) //action type is contact, skip
          {
            mInterfaces.Logger.LogWarning(string.Format("Skipping terminating subscriptions on account {0}, actiontype is contact", accountID));
            continue;
          }

          CanSubscribe = session.GetBoolProperty(mlCanSubscribeID);
          CanParticipateInGSub = session.GetBoolProperty(mlCanParticipateInGSubID);

          if (!CanSubscribe && !CanParticipateInGSub)
          {
            mInterfaces.Logger.LogWarning(string.Format("Skipping terminating subscriptions on account {0}, account type does not support subscriptions", accountID));
            continue;
          }

          terminateDate = (DateTime)session.GetOLEDateProperty(mlHierarchyStartDateID);
          System.TimeSpan oneSec = new System.TimeSpan(0,0,0,1);
          System.TimeSpan oneDay = new System.TimeSpan(1,0,0,0);

          DateTime unsubscribeDate = ((terminateDate.Date).Add(oneDay)).Subtract(oneSec);

          //we have checked all the conditions and have the two properties (accountid and hierarchy_startdate) that
          //we absolutely need from the session.
          try
          {
            MetraTech.Interop.MTPipelineLib.IMTTransaction transaction = session.GetTransaction(false);

            UnsubscribeWriter writer;

            if(transaction == null)
              writer = new UnsubscribeWriter();
            else
              writer = (UnsubscribeWriter)BYOT.CreateWithTransaction(
                transaction.GetTransaction(), typeof(UnsubscribeWriter));


            writer.ProcessSubscriptions(session, mInterfaces, accountID, unsubscribeDate, CanSubscribe, CanParticipateInGSub);
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

    private Interfaces      mInterfaces;
    private AccountTypeCollection mAccountTypes = new AccountTypeCollection();
    private int mlAccountIDID;
    private int mlActionTypeID;
    private int mlOperationID;
    private int mlCanSubscribeID;
    private int mlCanParticipateInGSubID;
    private int mlHierarchyStartDateID;
  }
}

 