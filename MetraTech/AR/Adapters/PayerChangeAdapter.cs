using System;
using System.Xml;
using System.Collections;
using System.Diagnostics;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.AR;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;
using MetraTech.Interop.MeterRowset;


namespace MetraTech.AR.Adapters
{
	/// <summary>
  /// Move balances and unbilled charges of non-billable accounts to their payer.
  /// If AR is enabled the balances will be moved in AR as well (maintaining
  ///  aging information).
  ///
  /// Dependencies:
  /// All charge generating adapters should run prior this one, so that all current
  /// charges are taking into account.
  /// The ARPaymentAndAdjustmentAdapter should run prior to this one, so that the
  /// balance in AR is up to date.
  /// This adapter should run immediately before the invoice adapter.
  /// 
  /// Details:
  /// Run at end of period, immediately before generating invoices.
  /// Adapter can run with or without AR integration enabled.
  /// (1) Adapter determines non-billable accounts with balance or current charges.
  /// (2) For all non-billable accounts with outstanding balance:
  ///    (2a) move their balance in MetraNet to the new payer (effective at EOP)
  ///         by creating compensating ARAdjustments for the originating account
  ///         and the new payer.
  ///    (2b) if AR enabled: move their balance in AR as well (maintaining aging
  ///         balance by creating a transaction for the new payer for each
  ///         outstanding debit and a compensating adjustment for the originating account)
  ///         The amount moved in AR will be compared against the amount move in MetraNet
  ///         and a warning generated for any mismatch.
  /// (3) For all non-billable accounts with current (unbilled) charges:
  ///     move their current charges in MetraNet to the new payer by creating 
  ///     compensating misc adjustments for the originating account and the new payer.
  /// MetraNet adjustments will be metered as an adapter batch with the
  /// namespace "PayerChange", name of run ID, and sequence number of one.
  /// The AR transactions will be part of an AR batch named "MOV1234" with 1234 being
  /// the interval ID.
  /// The MetraNet adjustments will be forced into the interval being closed. If the 
  /// payer has an interval other than the one being closed they will go into the next
  /// open one (using normal interval resolution).
  /// 
  /// Back out:
  /// Delete all sessions of the adapter batch "PayerChange, RunID, 1" (standard 
  /// auto reverse functionality).
  /// If AR is enabled the AR batch "MOV1234" (with 1234 being the interval ID)
  /// will be deleted from AR if it exists and has not been posted.
	/// </summary>
  public class PayerChangeAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
  {
    enum MoveType {FROM, TO};

    // data
    private Logger mLogger = new Logger("[ARPayerChangeAdapter]");
    private object mARConfigState = null;
    private IMTSessionContext mSessionContext = null;

    //from ARConfig.xml
    private bool mAREnabled = false;
    private string mARAccountNameSpace = "";
    //from PayerChangeAdapter.xml
    private string mMetraNetAccountNameSpace;
    private int mARSetSize;
    private int mMetraNetSetSize;
    private bool mMoveBalance;
    private bool mMoveCurrentCharges;
    private string mBalanceMovedToPayerDescription;
    private string mBalanceMovedFromPayeeDescription;
    private string mChargesMovedToPayerDescription;
    private string mChargesMovedFromPayeeDescription;
    private string mBalanceMovedToPayerReason;
    private string mBalanceMovedFromPayeeReason;
    private string mChargesMovedToPayerReason;
    private string mChargesMovedFromPayeeReason;
    private string mMeterServer;
    private int mWaitForCommitTimeout;

    // adapter capabilities
    public bool SupportsScheduledEvents     { get { return false; }}
    public bool SupportsEndOfPeriodEvents   { get { return true; }}
    public ReverseMode Reversibility        { get { return ReverseMode.Custom; }}
    public bool AllowMultipleInstances      { get { return false; }}
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
    public bool HasBillingGroupConstraints { get { return false; } }
    // ESR-3106 - Change billing group support to Account
    public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }

    public PayerChangeAdapter()
    {
    }

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
    {
      if (limitedInit)
      {
        mLogger.LogDebug("Intializing adapter (limited)");
      }
      else
      {
        mLogger.LogDebug("Intializing Adapter");

        ReadConfig (configFile); 

        mSessionContext = context;
        mAREnabled = ARConfiguration.GetInstance().IsAREnabled;
        if (mAREnabled)
        {
          mARAccountNameSpace = ARConfiguration.GetInstance().AccountNameSpace;

          //configure ARInterface
          IMTARConfig ARConfig = new MTARConfigClass();
          mARConfigState = ARConfig.Configure("");
        }
      }
    }

    public string Execute(IRecurringEventRunContext context)
    {
      DateTime moveTime = MetraTech.MetraTime.Now;
      IList accountsWithBalance = new ArrayList();
      IList accountsWithCharges = new ArrayList();
      int numBalancesMoved = 0;
      int numCurrentChargesMoved = 0;
      int numBalancesToMove = 0;
      int numCurrentChargesToMove = 0;
      string msg;

      // step: get non-billable accounts with balance or current charges
      GetNonBillableAccounts(context.BillingGroupID, accountsWithBalance, accountsWithCharges);

      numBalancesToMove = accountsWithBalance.Count;
      numCurrentChargesToMove = accountsWithCharges.Count;

      if (numBalancesToMove + numCurrentChargesToMove == 0)
      { 
        //no accounts found
        mLogger.LogDebug("No non-billable accounts with balance or current charges found. Done.");
      }
      else
      {
        msg = String.Format("Found {0} account{1} with balance, {2} account{3} with currentCharges",
          accountsWithBalance.Count,
          accountsWithBalance.Count == 1 ? "" : "s",
          accountsWithCharges.Count,
          accountsWithCharges.Count == 1 ? "" : "s");
        mLogger.LogDebug(msg);
        context.RecordInfo(msg);

        //step: create a MTBatch to be used for metering ARAdjustments, credits or misc charges.
        int runID = context.RunID;
        string adapterName = "PayerChange";
        string sequenceNumber = "1";

        mLogger.LogDebug("creating batch runID: {0} adapterName: {1} sequence: {2}", 
          runID, adapterName, sequenceNumber);

        IMeterRowset meterRowset = new MeterRowset();
        meterRowset.SessionSetSize = mMetraNetSetSize;
        meterRowset.InitSDK(mMeterServer);

        IBatch batch = meterRowset.CreateAdapterBatch(runID, adapterName, sequenceNumber);

        // The following groups of sessions need to be metered in separate session sets
        // because there are issues with metering two different parent types in a single
        // session set.

        if ((mMoveBalance) && (numBalancesToMove > 0))
        {
          ISessionSet sessionSet = batch.CreateSessionSet();
          sessionSet.SessionContext = mSessionContext.ToXML();

          //step: move balances for all accounts in accountsWithBalance, append sessions to sessionSet
          numBalancesMoved = MoveBalance(accountsWithBalance, sessionSet, moveTime, context);

          sessionSet.Close();
        }

        if ((mMoveCurrentCharges) && (numCurrentChargesToMove > 0))
        {
          ISessionSet sessionSet = batch.CreateSessionSet();
          sessionSet.SessionContext = mSessionContext.ToXML();

          //step: move balances for all accounts in accountsWithCharges, append sessions to sessionSet
          numCurrentChargesMoved = MoveCurrentCharges(accountsWithCharges, sessionSet, moveTime, context);

          sessionSet.Close();
        }

        // close batch and wait for completion
        // (need to wait since depended invoice adapter must take sessions into account)
        int numSessions = (numBalancesMoved + numCurrentChargesMoved) * 2;

        msg = String.Format("Metering {0} sessions in batch {1} and waiting for completion",
          numSessions, batch.UID);
        mLogger.LogDebug(msg);
        context.RecordInfo(msg);

        meterRowset.WaitForCommit(numSessions, mWaitForCommitTimeout);

        //check for failure
        if (meterRowset.CommittedSuccessCount < numSessions)
        { 
			Marshal.ReleaseComObject(meterRowset);
			string errorMsg = String.Format("Only {0} of {1} sessions succeeded within {2} seconds. {3} failed.",
											meterRowset.CommittedSuccessCount,
											numSessions,
											mWaitForCommitTimeout,
											meterRowset.CommittedErrorCount);

			mLogger.LogError(errorMsg);
			throw new ARException(errorMsg);
        }

		// releases connections held by SDK now
		Marshal.ReleaseComObject(meterRowset);
      }
      
      msg = String.Format("Moved balance for {0} account{1}, moved current charges for {2} account{3}",
        accountsWithBalance.Count,
        accountsWithBalance.Count == 1 ? "" : "s",
        accountsWithCharges.Count,
        accountsWithCharges.Count == 1 ? "" : "s");
      mLogger.LogDebug(msg);
      context.RecordInfo(msg);
	  return msg;
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      string detailGreatPlains = "";

      //first reverse the created sessions
      string detail = context.AutoReverse();

      //if AREnabled, delete ARBatch
      if (mAREnabled)
      {
        string batchID = MakeARBatchID(context);
        mLogger.LogDebug("Reversing interval {0}, billing group ID {1}. Deleting AR batch {2}",
					     context.UsageIntervalID, context.BillingGroupID, batchID);
 
        if (!AdapterUtil.DeleteAdapterBatch(batchID, mARConfigState, context, out detailGreatPlains))
        {
          detailGreatPlains = String.Format("Unable to delete AR Batch {0}. {1}", batchID, detailGreatPlains);
          mLogger.LogWarning(detailGreatPlains);
          throw new ARException(detailGreatPlains);
        }
      }

	  return "Reverse Succeeded." + detail + " " + detailGreatPlains;
    }

	public void SplitReverseState(int parentRunID, 
								  int parentBillingGroupID,
								  int childRunID, 
								  int childBillingGroupID)
	{
		mLogger.LogDebug("Splitting reverse state of PayerChange Adapter");
	}

    public void Shutdown()
    {
    }

    private void ReadConfig(string configFile)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);

      mMetraNetAccountNameSpace = doc.GetNodeValueAsString("//MetraNetAccountNameSpace");
      mARSetSize = doc.GetNodeValueAsInt("//ARSetSize");
      mMetraNetSetSize = doc.GetNodeValueAsInt("//MetraNetSetSize");
      mMoveBalance = doc.GetNodeValueAsBool("//MoveBalance");
      mMoveCurrentCharges = doc.GetNodeValueAsBool("//MoveCurrentCharges");
      mBalanceMovedToPayerDescription = doc.GetNodeValueAsString("//BalanceMovedToPayerDescription");
      mBalanceMovedFromPayeeDescription = doc.GetNodeValueAsString("//BalanceMovedFromPayeeDescription");
      mChargesMovedToPayerDescription = doc.GetNodeValueAsString("//ChargesMovedToPayerDescription");
      mChargesMovedFromPayeeDescription = doc.GetNodeValueAsString("//ChargesMovedFromPayeeDescription");
      mBalanceMovedToPayerReason = doc.GetNodeValueAsString("//BalanceMovedToPayerReason");
      mBalanceMovedFromPayeeReason = doc.GetNodeValueAsString("//BalanceMovedFromPayeeReason ");
      mChargesMovedToPayerReason = doc.GetNodeValueAsString("//ChargesMovedToPayerReason");
      mChargesMovedFromPayeeReason = doc.GetNodeValueAsString("//ChargesMovedFromPayeeReason");
      mMeterServer = doc.GetNodeValueAsString("//MeterServer");
      mWaitForCommitTimeout = doc.GetNodeValueAsInt("//WaitForCommitTimeout");
    }

    /// <summary>
    /// returns a batch ID given the context
    /// format is "PREFIX123", using the interval id
    /// </summary>
    private string MakeARBatchID(IRecurringEventRunContext context)
    {
      Debug.Assert(context.EventType == RecurringEventType.EndOfPeriod);
      return ARConfiguration.GetInstance().MoveBalanceBatchPrefix + context.BillingGroupID;
    }

    /// <summary>
    /// Get all non billable accounts for billing group that have balances or accountsWithCharges and
    /// populate lists: accountsWithBalance, accountsWithCharges
    /// </summary>
    void GetNonBillableAccounts(int billgroupID, IList accountsWithBalance, IList accountsWithCharges)
    {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            mLogger.LogDebug("Getting non-billable accounts with balance or current charges");

            using (IMTCallableStatement stmt = conn.CreateCallableStatement("GetNonBillAccountsWithBalance"))
            {
                stmt.AddParam("@BillGroup", MTParameterType.Integer, billgroupID);
                stmt.AddParam("@strNamespace", MTParameterType.WideString, mMetraNetAccountNameSpace);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    //load up lists of accounts to move
                    while (reader.Read())
                    {
                        int accountID = reader.GetInt32("AccountID");
                        if (reader.IsDBNull("AccountName"))
                            throw new ARException("Could not resolve AccountName for {0}", accountID);
                        string accountName = reader.GetString("AccountName");

                        string extAccountID = "";
                        string extAccountNamespace = "";
                        if (reader.IsDBNull("ExtAccountID"))
                        {
                            /* v3.7 All accounts don't have to be exported, even if AREnabled 
                            if (mAREnabled) //extAccountID is only used if AR is enabled
                            {
                              throw new ARException("Could not resolve ExtAccountID for {0}", accountID ); 
                            }
                            */
                        }
                        else
                        {
                            extAccountID = reader.GetString("ExtAccountID");
                            extAccountNamespace = reader.GetString("ExtAccountNamespace");
                        }

                        int payerID = reader.GetInt32("PayerID");
                        if (reader.IsDBNull("PayerName"))
                            throw new ARException("Could not resolve PayerName for {0}", payerID);
                        string payerName = reader.GetString("PayerName");

                        string extPayerID = "";
                        string extPayerNamespace = "";
                        if (reader.IsDBNull("ExtPayerID"))
                        {
                            /* v3.7 All accounts don't have to be exported, even if AREnabled 
                            if (mAREnabled) //extPayerID is only used if AR is enabled
                            { 
                              throw new ARException("Could not resolve ExtPayerID for {0}", payerID ); 
                            }
                            */
                        }
                        else
                        {
                            extPayerID = reader.GetString("ExtPayerID");
                            extPayerNamespace = reader.GetString("ExtPayerNamespace");
                        }

                        int payerInterval = reader.GetInt32("PayerInterval");
                        decimal balanceForward = reader.GetDecimal("BalanceForward");
                        decimal currentCharges = reader.GetDecimal("CurrentCharges");
                        string currency = reader.GetString("Currency");

                        if (extAccountID == extPayerID)
                        {
                            // If extAccountID and extPayerID are both empty strings then
                            // this is not an error.  Rather it is a payer change or balance
                            // move request that is valid but that should be ignored by the
                            // AR code (if AR is enabled).  Part of CR12047 fix.
                            if (extAccountID != "")
                            {
                                string sMsg = String.Format("An attempt is being made to move balances to and from the same account: {0} in billing group {1}.  Account: {2}, MetraNet Name Space: {3}",
                                  extAccountID,
                                  extPayerID,
                                  billgroupID,
                                  mMetraNetAccountNameSpace);

                                throw new ARException(sMsg);
                            }
                        }

                        if (balanceForward != 0)
                            accountsWithBalance.Add(new AccountListItem(accountID, accountName, extAccountID, extAccountNamespace, payerID, payerName, extPayerID, extPayerNamespace, payerInterval, balanceForward, currency));

                        if (currentCharges != 0)
                            accountsWithCharges.Add(new AccountListItem(accountID, accountName, extAccountID, extAccountNamespace, payerID, payerName, extPayerID, extPayerNamespace, payerInterval, currentCharges, currency));
                    }
                }
            }
        }
    }

    /// <summary>
    /// for each accountsWithBalance:
    ///   move balance in AR
    ///   create ARAdjustment session for fromPayer
    ///   create ARAdjustment session for toPayer
    /// verify balances moved in AR against balances moved in MT
    /// </summary>
    /// <returns>number of balances moved</returns>
    int MoveBalance(IList accountsWithBalance, ISessionSet sessionSet, DateTime moveTime, IRecurringEventRunContext context)
    {
      int numBalancesMoved = 0;

      if (accountsWithBalance.Count > 0)
      {
        string msg = String.Format("Creating AR Adjustment sessions to move balances from {0} account{1}",
          accountsWithBalance.Count,
          accountsWithBalance.Count == 1 ? "" : "s");
        mLogger.LogDebug(msg);
        context.RecordInfo(msg);

        string batchID = MakeARBatchID(context);

        // loop over all items and create:
        // - ARDocument to MoveBalance in AR
        // - ARAdjustment session for fromPayer
        // - ARAdjustment session for toPayer

        // For external AR export, create a arDocWriter for each namespace
        Hashtable arDocWriters = new Hashtable();
        Hashtable arNamespaceCount = new Hashtable();

        if (mAREnabled)
        {
          //Create an ARDocWriter for each external AR namespace
          ArrayList arrAccountNameSpaces = ARConfiguration.GetInstance().AccountNameSpaces;

          string sAccountNameSpace;
          for (int i=0; i<arrAccountNameSpaces.Count; i++)
          {
            sAccountNameSpace = arrAccountNameSpaces[i].ToString();
            arDocWriters.Add(sAccountNameSpace,ARDocWriter.CreateWithARDocuments(sAccountNameSpace));
            int iCount = 0;
            arNamespaceCount.Add(sAccountNameSpace, iCount);
          }
        }

		int intervalID = context.UsageIntervalID;
        foreach(AccountListItem item in accountsWithBalance)
        {
          if (mAREnabled)
          {
            // If either extPayerNamespace or extAccountNamespace are empty
            // strings then we will catch that as an error here.  (See the
            // "if" statement that follows this one for the case where both
            // namespaces are empty strings.)  We currently consider accounts
            // that are to be ignored by AR to be in a separate "logical"
            // operating company, i.e. the operating company that does not
            // get sent to the AR system.  It is currently an error to attempt
            // to change a payer and/or move a balance for/between one account
            // that is in an AR operating company and another account that is
            // not in an AR operating company.  Basically, we do not currently
            // support moving balances across different operating companies.
            if (item.ExtPayerNamespace != item.ExtAccountNamespace)
            {
              string sMsg = String.Format("Unable to move balances across operating companies in the external AR system. The non-billable account {0}({1}) has balances that need to be moved to the account {2}({3}) in the external AR system. Unfortunately, the two accounts are in different operating companies/namespaces in the external AR system.",
                item.AccountName,item.AccountID.ToString(),
                item.PayerName,  item.PayerID.ToString());

              // Part of CR12047 fix.
              string extAcctID;
              string extAcctNS;

              if (item.ExtAccountNamespace == "")
              {
                extAcctID = "NULL";
                extAcctNS = "NULL";
              }
              else
              {
                extAcctID = item.ExtAccountID;
                extAcctNS = item.ExtAccountNamespace;
              }

              string extPayerID;
              string extPayerNS;

              if (item.ExtPayerNamespace == "")
              {
                extPayerID = "NULL";
                extPayerNS = "NULL";
              }
              else
              {
                extPayerID = item.ExtPayerID;
                extPayerNS = item.ExtPayerNamespace;
              }

              sMsg += String.Format("In the external AR system, the non-billable account {0} is {1} (Namespace:{2}) and the paying account {3} is {4} (Namespace:{5})",
                item.AccountID.ToString(), extAcctID, extAcctNS,
                item.PayerID.ToString(), extPayerID, extPayerNS);

              throw new ARException(sMsg);
            }

            // If extPayerNamespace and extAccountNamespace are both empty
            // strings then this is a payer change or balance move request
            // that is valid but that should be ignored by the AR code (if
            // AR is enabled).  Part of CR12047 fix.
            if (item.ExtAccountNamespace != "")
            {
              //append AR Document:
              //  <ARDocument>
              //    <MoveBalance>
              //      <FromExtAccountID/>
              //      <ToExtAccountID/>
              //      <BatchID/>
              //      <MoveDate/>
              //    </MoveBalance>
              //  </ARDocument>  
              ((ARDocWriter) arDocWriters[item.ExtPayerNamespace]).WriteARDocumentStart("MoveBalance");
              ((ARDocWriter) arDocWriters[item.ExtPayerNamespace]).WriteElementString("FromExtAccountID", item.ExtAccountID);
              ((ARDocWriter) arDocWriters[item.ExtPayerNamespace]).WriteElementString("ToExtAccountID", item.ExtPayerID);
              ((ARDocWriter) arDocWriters[item.ExtPayerNamespace]).WriteElementString("BatchID", batchID);
              ((ARDocWriter) arDocWriters[item.ExtPayerNamespace]).WriteElementString("MoveDate", moveTime.ToString("yyyy-MM-dd"));
              ((ARDocWriter) arDocWriters[item.ExtPayerNamespace]).WriteARDocumentEnd();

              arNamespaceCount[item.ExtPayerNamespace] = ((int)arNamespaceCount[item.ExtPayerNamespace]) + 1;
            }
          }

          // create ARAdjustment session for "from" account (account)
          string description = String.Format(mBalanceMovedToPayerDescription, item.PayerName);
          CreateARAdjustmentSession(sessionSet,
            item.AccountName,
            - item.Amount,
            item.Currency,
            description,
            mBalanceMovedToPayerReason,
            moveTime,
            intervalID);

          // create ARAdjustment session for "to" account (payer)
          description = String.Format(mBalanceMovedFromPayeeDescription, item.AccountName);

          // if "to" account has same interval ID, force it into that one, otherwise use normal guidance
          int intervalForToAccount;
          if (intervalID == item.PayerInterval)
            intervalForToAccount = intervalID;
          else
            intervalForToAccount = 0;

          CreateARAdjustmentSession(sessionSet,
									item.PayerName,
									item.Amount,
									item.Currency,
									description,
									mBalanceMovedFromPayeeReason,
									moveTime,
									intervalForToAccount);

          numBalancesMoved++;
        }

        if (mAREnabled)
        {
          foreach(object accountNamespace in arDocWriters.Keys)
          {
            string sAccountNamespace = accountNamespace.ToString();
            int nCount = ((int)arNamespaceCount[sAccountNamespace]);
            if (nCount > 0)
            {
              string xml =  ((ARDocWriter) arDocWriters[sAccountNamespace]).GetXmlAndClose();
              msg = String.Format("Moving {0} balance{1} in AR system {3} using AR batch {2}",
                  nCount,
                  nCount == 1 ? "" : "s",
                  batchID,
                  sAccountNamespace);
              mLogger.LogDebug(msg);
              context.RecordInfo(msg);
              
              //step: move balances in AR
              IMTARWriter ARWriter = new MTARWriterClass();
              string xmlResponse = ARWriter.MoveBalances(xml, mARConfigState);
      
              // step: verify balances
              CheckBalances(accountsWithBalance, xmlResponse, context);
            }
          }
        }
      }

      return numBalancesMoved;
    }


    /// <summary>
    /// for each accountsWithCharges:
    ///   create Misc Adjustment session for fromPayer
    ///   create Misc Adjustment session for toPayer
    /// </summary>
    /// <returns>number of accounts with charges moved</returns>
    int MoveCurrentCharges(IList accountsWithCharges, ISessionSet sessionSet, DateTime moveTime, IRecurringEventRunContext context)
    {
      int numAccountsMoved = 0;

      if (accountsWithCharges.Count > 0)
      {
        string msg = String.Format("Creating Misc Adjustment sessions to move charges from {0} account{1}",
          accountsWithCharges.Count,
          accountsWithCharges.Count == 1 ? "" : "s");
        mLogger.LogDebug(msg);
        context.RecordInfo(msg);
        
		int intervalID = context.UsageIntervalID;
        foreach(AccountListItem item in accountsWithCharges)
        {
          // create Misc Adjustment session for "from" account
          string description = String.Format(mChargesMovedToPayerDescription, item.PayerName);
          CreateMiscAdjustmentSession(sessionSet,
            item.AccountID,
            - item.Amount,
            item.Currency,
            description,
            mChargesMovedToPayerReason,
            moveTime,
            intervalID);

          // create Misc Adjustment session for "to" account
          description = String.Format(mChargesMovedFromPayeeDescription, item.AccountName);

          // if "to" account has same interval ID, force it into that one, otherwise use normal guidance
          int intervalForToAccount;
          if (intervalID == item.PayerInterval)
            intervalForToAccount = intervalID;
          else
            intervalForToAccount = 0;

          CreateMiscAdjustmentSession(sessionSet,
            item.PayerID,
            item.Amount,
            item.Currency,
            description,
            mChargesMovedFromPayeeReason,
            moveTime,
            intervalForToAccount);
        }
        numAccountsMoved++;
      }
      return numAccountsMoved;
    }

    void CreateARAdjustmentSession(ISessionSet sessionSet,
									string accountName,
									decimal amount,
									string currency,
									string description,
									string reasonCode,
									DateTime moveTime, 
									int intervalID) //ignored if 0 
    {
      ISession session = sessionSet.CreateSession("metratech.com/ARAdjustment");

      //force into interval if provided
      if (intervalID != 0)
        session.InitProperty("_IntervalID", intervalID);
    
      session.InitProperty("Payer", accountName);
      session.InitProperty("_Amount", amount);
      session.InitProperty("Description", description);
      session.InitProperty("EventDate", moveTime);
      session.InitProperty("Source", "AR"); //use source AR, so that adjustments are not exported again
      session.InitProperty("ReasonCode", reasonCode); 
      session.InitProperty("IgnorePaymentRedirection", "T");
    }
    
    void CreateMiscAdjustmentSession(ISessionSet sessionSet,
                                     int accountID,
                                     decimal amount,
                                     string currency,
                                     string description,
                                     string reason,
                                     DateTime moveTime, 
                                     int intervalID) //ignored if 0 
    {
      //AccountCredit is a Misc Adjustment
      ISession session = sessionSet.CreateSession("metratech.com/AccountCredit");

      //force into interval if provided
      if (intervalID != 0)
        session.InitProperty("_IntervalID", intervalID);
      
      session.InitProperty("CreditTime", moveTime);
      session.InitProperty("Status", "APPROVED");
      session.InitProperty("RequestID", -1);
      session.InitProperty("ContentionSessionID", "");
      session.InitProperty("_AccountID", accountID);
      session.InitProperty("_Amount", amount);
      session.InitProperty("_Currency", currency);
      session.InitProperty("Issuer", mSessionContext.AccountID);
      session.InitProperty("Reason", "Other");
      session.InitProperty("Other", reason);
      session.InitProperty("InvoiceComment", description);
      session.InitProperty("ReturnCode", 0);
      session.InitProperty("RequestAmount", amount);
      session.InitProperty("CreditAmount", amount);
      session.InitProperty("ResolveWithAccountIDFlag", "T");
      session.InitProperty("IgnorePaymentRedirection", "T");
    }

    /// <summary>
    /// Check balance moved in MetraNet against balance move in AR
    /// </summary>
    /// <returns>number of mismatches</returns>
    int CheckBalances(IList accountsWithBalance, string xmlMoveBalanceResponse, IRecurringEventRunContext context)
    {
      string msg = "Verifying moved balances";
      mLogger.LogDebug(msg);
      context.RecordInfo(msg);

      int numBalanceMismatches = 0;

      MTXmlDocument docMoveBalance = new MTXmlDocument();
      docMoveBalance.LoadXml(xmlMoveBalanceResponse);

      //for all MoveBalanceResponse nodes in docResponse
      XmlNodeList moveBalanceNodes = docMoveBalance.SelectNodes("//MoveBalanceResponse");
      Debug.Assert(accountsWithBalance.Count == moveBalanceNodes.Count);

      foreach( XmlNode node in moveBalanceNodes)
      {
        //get moved balance in AR
        string fromExtAccountID = MTXmlDocument.GetNodeValueAsString(node, "./FromExtAccountID");
        string toExtAccountID = MTXmlDocument.GetNodeValueAsString(node, "./ToExtAccountID");
        decimal MovedBalanceInAR = MTXmlDocument.GetNodeValueAsDecimal(node, "./MovedBalance");
  
        //get moved balance in MetraNet
        decimal MovedBalanceInMetraNet = GetBalanceForAccount(fromExtAccountID, accountsWithBalance);

        // compare the balances
        if (MovedBalanceInAR == MovedBalanceInMetraNet)
        {
          mLogger.LogDebug(String.Format("Balance OK for account: '{0}', balance: {1}",
            fromExtAccountID, MovedBalanceInMetraNet));
        }
        else
        {
          numBalanceMismatches ++;
          msg = String.Format("Balance moved from '{0}' to '{1}' does not match. Balance moved in MetraNet: {2}, balance moved in AR: {3}",
            fromExtAccountID, toExtAccountID, MovedBalanceInMetraNet, MovedBalanceInAR);

          //record in log and usm run history
          mLogger.LogWarning(msg);
          context.RecordWarning(msg);
        }
      }

      int numBalanceMatches = moveBalanceNodes.Count - numBalanceMismatches;

      msg = String.Format("{0} moved balance{1} match{2}. {3} moved balance{4} do{5} not match",
        numBalanceMatches,
        numBalanceMatches == 1 ? "" : "s",
        numBalanceMatches == 1 ? "es" : "",
        numBalanceMismatches,
        numBalanceMismatches == 1 ? "" : "s",
        numBalanceMismatches == 1 ? "es" : "" );
      if (numBalanceMismatches > 0)
      {
        mLogger.LogWarning(msg);
        context.RecordWarning(msg);
      }
      else
      {
        mLogger.LogDebug(msg);
        context.RecordInfo(msg);
      }

      return numBalanceMismatches;
    }

    decimal GetBalanceForAccount(string extAccountID, IList accountList)
    {
      foreach(AccountListItem item in accountList)
      {
        if (item.ExtAccountID == extAccountID)
          return item.Amount;
      }
      throw new ARException("AR returned unknown account '{0}'", extAccountID );
    }
  }

  class AccountListItem
  {
    public int AccountID;
    public string AccountName;
    public string ExtAccountID;
    public string ExtAccountNamespace;
    public string PayerName;
    public int PayerID;
    public string ExtPayerID;
    public string ExtPayerNamespace;
    public int PayerInterval;
    public decimal Amount;
    public string Currency;

    public AccountListItem(
      int accountID,
      string accountName,
      string extAccountID,
      string extAccountNamespace,
      int payerID,
      string payerName,
      string extPayerID,
      string extPayerNamespace,
      int payerInterval,
      decimal amount,
      string currency)
    {
      AccountID = accountID;
      AccountName = accountName;
      ExtAccountID = extAccountID;
      ExtAccountNamespace = extAccountNamespace;
      PayerID = payerID;
      PayerName = payerName;
      ExtPayerID = extPayerID;
      ExtPayerNamespace = extPayerNamespace;
      PayerInterval = payerInterval;
      Amount = amount;
      Currency = currency;
    }
  }
}
