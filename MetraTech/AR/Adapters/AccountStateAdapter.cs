
using System;
using System.Xml;
using System.Diagnostics;
using System.Collections;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.AR;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;

namespace MetraTech.AR.Adapters
{

  /// <summary>
  /// Exports state changes to A/R. Imports state changes from A/R.
  ///
  /// Dependencies:
  /// To export the latest changes, this adapter should be run after adapters that modify
  /// the account state, they are:
  ///   MTChangeAccountState
  ///   MTChangeAccountStateFromPFBToClosed
  ///   
  /// Details:
  /// Run on a schedule (10 min – 1 day). Frequency should be configured based on the allowed
  /// latency between AR and MetraNet.
  /// The adapter works on the time span from the time it was run last until the current time.
  /// State changes effective during this time span are gathered from MetraNet and A/R, consolidated, 
  /// and applied to the other system.
  /// Consolidation rules are:
  ///  (1)	More recent state change overrides less recent change.
  ///  (2)	If an account state change in A/R cannot be applied to MetraNet because the account
  ///        has transitioned to an incompatible state in MetraNet, A/R will be set to the state 
  ///        in MetraNet.
  ///        This will record a warning in the adapter run details.
  ///        Example: One Account was changed in MetraNet from Active to Pending Final Bill
  ///        while it was changed in A/R from Active to Suspended. A/R will be set to Pending Final Bill,
  ///        since MetraNet cannot transition from PFB to Suspended (even if the change in A/R was more recent)
  /// Only the state at the time the adapter runs will be exported. A state change scheduled for the
  /// future will be exported when the adapter runs after the new state becomes effective.
  ///
  /// Back out:
  /// Back out is not supported since imports cannot be rolled back in A/R.
  /// </summary>
  public class AccountStateAdapter : MetraTech.UsageServer.IRecurringEventAdapter
  {
    // data
    private Logger mLogger = new Logger("[ARAccStateAdapter]");
    private int mSetSize = 0;
    private bool mExportStateChanges = false;
    private bool mImportStateChanges = false;
    private string mAccountNameSpace;
    private MetraTech.Interop.MTYAAC.IMTSessionContext mSessionContext;
    private MetraTech.Interop.MTYAAC.IMTAccountCatalog mAccountCatalog;
    private object mARConfigState;

    // adapter capabilities
    public bool SupportsScheduledEvents     { get { return true; }}
    public bool SupportsEndOfPeriodEvents   { get { return false; }}
    public ReverseMode Reversibility        { get { return ReverseMode.NotImplemented; }}
    public bool AllowMultipleInstances      { get { return false; }}

    private IRecurringEventRunContext mContext;

    public AccountStateAdapter()
    {
    }

    public void Initialize(string eventName, string configFile, IMTSessionContext sessionContext, bool limitedInit)
    {
      if (limitedInit)
      {
        mLogger.LogDebug("Intializing adapter (limited)");
      }
      else
      {
        mLogger.LogDebug("Intializing adapter");

        Debug.Assert(sessionContext != null);

        ReadConfig(configFile); 

        mAccountNameSpace = ARConfiguration.GetInstance().AccountNameSpace;

        mSessionContext = (MetraTech.Interop.MTYAAC.IMTSessionContext) sessionContext;

        //set up account catalog
        mAccountCatalog = new MetraTech.Interop.MTYAAC.MTAccountCatalogClass();
        mAccountCatalog.Init(mSessionContext);

        //configure ARInterface
        IMTARConfig ARConfig = new MTARConfigClass();
        mARConfigState = ARConfig.Configure("");
      }
    }

    public string Execute(IRecurringEventRunContext context)
    {
      mLogger.LogDebug("Executing ARAccStateAdapter in context: {0}",  context);
      
      mContext = context;

      int nNumStatesExported = 0;
      int nNumStatesImported = 0;
      int nNumStatesBounced = 0;

      //step: determine time of current run and last run
      DateTime currentRunTime = context.EndDate;
      
      // subtract 1 second from StartDate to get the time it was last run 
      DateTime lastRunTime = context.StartDate - new TimeSpan(0,0,1); 

      //set up consolidator helper object
      StateChangeConsolidator consolidator = new StateChangeConsolidator(
        mAccountNameSpace,
        mAccountCatalog,
        mLogger,
        currentRunTime,
        context);

      //step: get account state changes that occurred in MetraNet
      if (mExportStateChanges)
        GetStateChangesFromMetraNet(consolidator, lastRunTime, currentRunTime);

      //step: get account state changes that occured in AR
      IList ARChangeIDs = null;
      if (mImportStateChanges)
        ARChangeIDs = GetStateChangesFromAR(consolidator);
      
      //step: apply state changes to MetraNet
      if (mImportStateChanges)
      {
        // Here is the place where I would need to catch an exception when changing acc states in MN.
        // If the acc state chage fails in MN, then I need to force the MN state into AR.
        nNumStatesImported = ApplyStateChangesToMetraNet(consolidator, currentRunTime, ref nNumStatesBounced);

        //step: delete change records in A/R
        DeleteStateChangeRecordsInAR(ARChangeIDs);
      }
      
      //step: apply state changes to A/R (in sets)
      if (mExportStateChanges)
        nNumStatesExported = ApplyStateChangesToAR(consolidator) + nNumStatesBounced;;
    
			string detail;
      detail = String.Format(
        "Exported states for {0} account{1}, Imported states for {2} account{3}",
        nNumStatesExported,
        nNumStatesExported == 1 ? "" : "s",
        nNumStatesImported,
        nNumStatesImported == 1 ? "" : "s");

      mLogger.LogDebug(detail);

			return detail;
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      throw new ARException("backout not supported");
    }

    public void Shutdown()
    {
    }

    private void ReadConfig(string configFile)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);

      mSetSize = doc.GetNodeValueAsInt("//SetSize", 500);
      mExportStateChanges = doc.GetNodeValueAsBool("//ExportStateChanges");
      mImportStateChanges = doc.GetNodeValueAsBool("//ImportStateChanges");;
    }

    private void GetStateChangesFromMetraNet(
      StateChangeConsolidator consolidator,
      DateTime lastRunTime,
      DateTime currentRunTime)
    {
      mLogger.LogDebug("Getting state changes from MetraNet");

      // get status of all account at currentRunTime
      // where the status has changed since lastRunTime
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", "__GET_CHANGED_ACCOUNT_STATUS__"))
          {
              stmt.AddParam("%%NAME_SPACE%%", mAccountNameSpace);
              stmt.AddParam("%%LAST_RUN_TIME%%", lastRunTime);
              stmt.AddParam("%%CURRENT_RUN_TIME%%", currentRunTime);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  //Loop over result and add state change to consolidator
                  while (reader.Read())
                  {
                      string extAccountID = reader.GetString("ExtAccountID");
                      string status = reader.GetString("Status");
                      DateTime timeChanged = reader.GetDateTime("tt_start");

                      consolidator.AddStateChangeForAR(extAccountID, status, timeChanged);
                  }
              }
          }
      }
    }

    private IList GetStateChangesFromAR(StateChangeConsolidator consolidator)
    {
      mLogger.LogDebug("Getting state changes from AR");

      // store time AR interface was called, since interface only returns timediff in SecondsAgo
      // (to account for different system times on both systems)
      DateTime timeInterfaceCalled = MetraTech.MetraTime.Now;

      //get all account status changes from A/R (since last time adapter was called)
        
      IMTARReader ARReader = new MTARReaderClass();
      string xml = ARReader.GetAccountStatusChanges( mARConfigState );

      MTXmlDocument ARChangesDoc = new MTXmlDocument();
      ARChangesDoc.LoadXml(xml);

      IList ARChangeIDs = new ArrayList();

      //parse out changes and add to consolidator
      XmlNodeList changeNodes = ARChangesDoc.SelectNodes("//GetAccountStatusChange");
  
      foreach (XmlNode changeNode in changeNodes)
      {
        string extAccountID = MTXmlDocument.GetNodeValueAsString(changeNode, "ExtAccountID");
        string status = MTXmlDocument.GetNodeValueAsString(changeNode, "Status");
        
        int secondsAgo = MTXmlDocument.GetNodeValueAsInt(changeNode, "SecondsAgo");
        DateTime timeChanged = timeInterfaceCalled - new TimeSpan(0,0,secondsAgo);
        
        string changedBy = MTXmlDocument.GetNodeValueAsString(changeNode, "UserID");
        consolidator.AddAndConsolidateStateChangeForMetraNet(extAccountID, status, timeChanged, changedBy );

        // remeber change IDs, so we can delete them at the end
        int changeID = MTXmlDocument.GetNodeValueAsInt(changeNode, "ChangeID");
        ARChangeIDs.Add(changeID);
      }
      return ARChangeIDs;
    }

    private int ApplyStateChangesToAR(StateChangeConsolidator consolidator)
    {
      mLogger.LogDebug("Applying state changes to AR");
      int nNumStatesExported = 0;

      IDictionaryEnumerator itr = consolidator.GetStateChangesForAR();
      ARDocWriter arDocWriter = null;
    
      int numDocInSet = 0;
      
      while (itr.MoveNext())
      {
        StateChange chng = (StateChange)itr.Value;

        //send set if setSize reached
        if (numDocInSet == mSetSize)
        {
          string xml = arDocWriter.GetXmlAndClose();
          
          IMTARWriter ARWriter = new MTARWriterClass();
          ARWriter.UpdateAccountStatus( xml, mARConfigState );

          nNumStatesExported += numDocInSet;
          
          //start fresh
          numDocInSet = 0;
          arDocWriter = null;
        }
         
        //create new ARDocWriter for first ARDocument
        if (arDocWriter == null)
        {
          arDocWriter = ARDocWriter.CreateWithARDocuments();
        }

        mLogger.LogDebug("Changing AR state for acc '{0}' to {1}", chng.mExtAccountID, chng.mState);

        //write one UpdateAccountStatus document
        //<ARDocument>
        //  <UpdateAccountStatus>
        //    <ExtAccountID/>
        //    <Status/>
        //  </UpdateAccountStatus>
        //</ARDocument>
        arDocWriter.WriteARDocumentStart("UpdateAccountStatus");
        arDocWriter.WriteElementString("ExtAccountID", chng.mExtAccountID);
        arDocWriter.WriteElementString("Status", chng.mState);
        arDocWriter.WriteARDocumentEnd();

        numDocInSet ++;
      }

      if (arDocWriter != null)
      {
        //send last set
        string xml = arDocWriter.GetXmlAndClose();
          
        IMTARWriter ARWriter = new MTARWriterClass();
        ARWriter.UpdateAccountStatus( xml, mARConfigState );

        nNumStatesExported += numDocInSet;
      }

      return nNumStatesExported;
    }

    int ApplyStateChangesToMetraNet(StateChangeConsolidator consolidator, DateTime effectiveTime, ref int numberBounced)
    { 
      // (CR 9901) A state change in MN can fail for many reasons (acc is a payer, etc...)
      // When this happens, MN as the driving system, needs to force it's state into AR.
      // So, for every account state change that fails, we will insert a record in this hash
      // that represents the state changes that MN needs to force in AR so, in the end of this adapter
      // run, there is no discrepancy between MN and AR account states.
      Hashtable bouncedStateChanges = new Hashtable();
      
      mLogger.LogDebug("Applying state changes to MetraNet");

      int nNumStatesImported = 0;

      IDictionaryEnumerator itr = consolidator.GetStateChangesForMetraNet();

      while (itr.MoveNext())
      {
        StateChange chng = (StateChange)itr.Value;

        //figure out state to go to
        string newState;
        if( chng.mState == "US" )
        {
          //'unsuspend' goes to active
          newState = "AC";
        }
        else
        {
          newState = chng.mState;
        }

        //changing the state using the mighty AccountStateManager
        mLogger.LogDebug("Changing MetraNet state for acc '{0}' to {1} effective {2}", chng.mExtAccountID, newState, effectiveTime);

        MetraTech.Interop.MTYAAC.IMTYAAC account;
        account = mAccountCatalog.GetAccountByName(chng.mExtAccountID, mAccountNameSpace, effectiveTime);
        
        Debug.Assert(account != null); //GetAccountByName throws exception if not found

				// the end date is primarily for eop and scheduled accountstate
				// adapters.  here, just pass it in as system.datetime.now.  it will
				// not get used.   just there for supporting the interface change
        try
        {
          account.GetAccountStateMgr().GetStateObject().ChangeState(
            mSessionContext, 
            null,
            account.AccountID, 
            -1, 
            newState, 
            effectiveTime, 
            DateTime.MinValue);
          nNumStatesImported ++;
        }
        catch (Exception ex)
        {
          // 1. Add to bouncedStateChanges hash
          bouncedStateChanges.Add(chng.mExtAccountID, new StateChange(chng.mExtAccountID,
                                                                      account.GetAccountStateMgr().GetStateObject().Name,
                                                                      effectiveTime));
          // 2. Log the fact that this state change into MN was not possible and that the MN state will be forced back into AR.

          string bounced;
          bounced = String.Format("Failed to change MetraNet state for acc '{0}' to {1} effective {2} due to the following error: '{3}'. MetraNet state {4} will be forced into AR for this account.",
                                  chng.mExtAccountID,
                                  newState, 
                                  effectiveTime,
                                  ex.Message,
                                  account.GetAccountStateMgr().GetStateObject().Name);
          mLogger.LogDebug(bounced);
          if (mContext != null)
            mContext.RecordWarning(bounced);
        }
      }
      
      // 3. Here, check the size of bouncedStateChanges - if > 0, then send these changes over to AR.
      if (bouncedStateChanges.Count > 0)
      {
        // So here we have a list of MN states that need to be applied to AR, because for each of these accounts,
        // applying the current AR state to MN was not possible.
        numberBounced = ApplyBouncedStateChangesToAR(bouncedStateChanges);

        // Log the number of bounced states
        string detail;
        detail = String.Format(
          "Exported {0} account state{1} due to MetraNet not being able to import them.",
          numberBounced,
          numberBounced == 1 ? "" : "s");

        mLogger.LogDebug(detail);
        if (mContext != null)
          mContext.RecordWarning(detail);
      }

      return nNumStatesImported;
    }

    private int ApplyBouncedStateChangesToAR(Hashtable aBouncedStateChanges)
    {
      mLogger.LogDebug("Bouncing {0} MetraNet state change(s) back to AR, original AR state changes could not be applied to MetraNet.", aBouncedStateChanges.Count);
      int nNumStatesExported = 0;

      IDictionaryEnumerator itr = aBouncedStateChanges.GetEnumerator();
      ARDocWriter arDocWriter = null;
    
      int numDocInSet = 0;
      
      while (itr.MoveNext())
      {
        StateChange chng = (StateChange)itr.Value;

        //send set if setSize reached
        if (numDocInSet == mSetSize)
        {
          string xml = arDocWriter.GetXmlAndClose();
          
          IMTARWriter ARWriter = new MTARWriterClass();
          ARWriter.UpdateAccountStatus( xml, mARConfigState );

          nNumStatesExported += numDocInSet;
          
          //start fresh
          numDocInSet = 0;
          arDocWriter = null;
        }
         
        //create new ARDocWriter for first ARDocument
        if (arDocWriter == null)
        {
          arDocWriter = ARDocWriter.CreateWithARDocuments();
        }

        mLogger.LogDebug("Changing AR state for acc '{0}' to {1}", chng.mExtAccountID, chng.mState);

        //write one UpdateAccountStatus document
        //<ARDocument>
        //  <UpdateAccountStatus>
        //    <ExtAccountID/>
        //    <Status/>
        //  </UpdateAccountStatus>
        //</ARDocument>
        arDocWriter.WriteARDocumentStart("UpdateAccountStatus");
        arDocWriter.WriteElementString("ExtAccountID", chng.mExtAccountID);
        arDocWriter.WriteElementString("Status", chng.mState);
        arDocWriter.WriteARDocumentEnd();

        numDocInSet ++;
      }

      if (arDocWriter != null)
      {
        //send last set
        string xml = arDocWriter.GetXmlAndClose();
          
        IMTARWriter ARWriter = new MTARWriterClass();
        ARWriter.UpdateAccountStatus( xml, mARConfigState );

        nNumStatesExported += numDocInSet;
      }

      return nNumStatesExported;
    }

    void DeleteStateChangeRecordsInAR(IList ARChangeIDs)
    {
      mLogger.LogDebug("Deleting state changes from AR");

      IEnumerator itr = ARChangeIDs.GetEnumerator();
      ARDocWriter arDocWriter = null;
      int numDocInSet = 0;

      while ( itr.MoveNext() )
      {
        int changeID = (int) itr.Current;

        //send set if setSize reached
        if (numDocInSet == mSetSize)
        {
          string xml = arDocWriter.GetXmlAndClose();
          
          IMTARWriter ARWriter = new MTARWriterClass();
          ARWriter.DeleteAccountStatusChanges( xml, mARConfigState );

          //start fresh
          numDocInSet = 0;
          arDocWriter = null;
        }
          
        //create new ARDocWriter for first ARDocument
        if (arDocWriter == null)
        {
          arDocWriter = ARDocWriter.CreateWithARDocuments();
        }

        //write one DeleteAccountStatusChange document
        //<ARDocument>
        //  <DeleteAccountStatusChange>
        //    <ChangeID/>
        //  </DeleteAccountStatusChange>
        //</ARDocument>

        arDocWriter.WriteARDocumentStart("DeleteAccountStatusChange");
        arDocWriter.WriteElementString("ChangeID", changeID.ToString());
        arDocWriter.WriteARDocumentEnd();

        numDocInSet ++;
      }

      if (arDocWriter != null)
      {
        //send last set
        string xml = arDocWriter.GetXmlAndClose();
          
        IMTARWriter ARWriter = new MTARWriterClass();
        ARWriter.DeleteAccountStatusChanges( xml, mARConfigState );
      }
    }
  }
}
