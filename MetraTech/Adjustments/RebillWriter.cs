using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;

using RS = MetraTech.Interop.Rowset;
using MetraTech.Interop.MeterRowset;
using MetraTech.Interop.MTBillingReRun;
using Coll = MetraTech.Interop.GenericCollection;
using ProdCat = MetraTech.Interop.MTProductCatalog;
//using SEExec = MetraTech.Interop.MTServiceEndpointsExec;
using YAAC = MetraTech.Interop.MTYAAC;
using System.Diagnostics;
using MetraTech.Interop.MTServerAccess;
using TRX = MetraTech.Interop.PipelineTransaction;
using MetraTech.Pipeline;

namespace MetraTech.Adjustments
{

  [Guid("520607a5-fbcd-4323-a772-97e86e8af324")]
  public interface IRebillWriter
  {
    MetraTech.Interop.Rowset.IMTRowSet CreatePrebillRebill
      (
      IMTSessionContext apCTX,
      IRebillTransaction trx,
      ProdCat.IMTPriceableItemType aPIType,
      out int rerunID,
      object aProgress
      );
    MetraTech.Interop.Rowset.IMTRowSet CreatePostbillRebill
      (
      IMTSessionContext apCTX,
      IRebillTransaction trx,
      ProdCat.IMTPriceableItemType aPIType,
      object aProgress
      );

    void FinalizePrebillRebill(IMTSessionContext apCTX, int rerunID);
  }
  /// <summary>
  /// Summary description for RebillWriter.
  /// </summary>
  /// 


  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.RequiresNew, Isolation = TransactionIsolationLevel.Any)]

  [Guid("eb7ca7c8-d192-4a74-ad60-748e38c56a2f")]
  public class RebillWriter : ServicedComponent, IRebillWriter
  {
    protected IMTSessionContext mCTX;

    // looks like this is necessary for COM+?
    public RebillWriter() { }

    [AutoComplete]
    public MetraTech.Interop.Rowset.IMTRowSet CreatePrebillRebill
      (
      IMTSessionContext apCTX,
      IRebillTransaction trx,
      ProdCat.IMTPriceableItemType aPIType,
      out int rerunID,
      object aProgress
      )
    {
      //uint PIPE_ERR_SESSION_COMMIT_TIMEOUT = 0xE120002A;  /*PIPE_ERR_SESSION_COMMIT_TIMEOUT*/;
      //uint MT_ERR_SYN_TIMEOUT = 0xE1300025;              /*MT_ERR_SYN_TIMEOUT*/;
      RS.IMTRowSet rs = new RS.MTSQLRowsetClass();
      IMeterRowset meter = null;
      TRX.IMTTransaction oMTTransaction = null;
      try
      {
        string desc = String.Format("Prebill Rebill BackOut for Payer With ID {0}", trx.OriginalPayerID);

        ResolveAccountIdentifiers(apCTX, trx);
        AdjustmentTransactionReader reader = new AdjustmentTransactionReader();
        meter = reader.CreateMeterRowset(trx, aPIType);
        meter.GenerateBatchID();

        //get current transaction info, export it to cookie and set it on MeterRowset

        TRX.IMTWhereaboutsManager whereaboutsmgr = new TRX.CMTWhereaboutsManagerClass();
        string cookie = whereaboutsmgr.GetWhereaboutsForServer("AdjustmentsServer");


        ITransaction oTransaction = (ITransaction)ContextUtil.Transaction;
        oMTTransaction = new TRX.CMTTransactionClass();
        /*false means no ownership, otherwise it'll rollback when MTTransaction object is destroyed*/
        oMTTransaction.SetTransaction(oTransaction, false);
        string encodedCookie = oMTTransaction.Export(cookie);


        //2. Create 100% compensating adjustment
        Coll.IMTCollection sessions = new Coll.MTCollectionClass();
        sessions.Add(trx.SessionID);

        
        IAdjustmentTransactionSet ajset = trx.AdjustmentType.CreateAdjustmentTransactions(sessions);
        ajset.ReasonCode = trx.ReasonCode;
        ajset.Description = trx.Description;
        AdjustmentCache.GetInstance().GetLogger().LogDebug("Calculating adjustment amount");
        rs = ajset.CalculateAdjustments(null);
        ajset.SaveAdjustments(null);
        AdjustmentCache.GetInstance().GetLogger().LogDebug("Created adjustment record");
        

        IMTBillingReRun rerun = new MetraTech.Pipeline.ReRun.Client();
        rerun = new MetraTech.Pipeline.ReRun.Client();

        rerun.TransactionID = encodedCookie;

        rerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext)apCTX);


        rerun.Setup(String.Format("Prebill Rebill backout of a transaction with id {0}", trx.SessionID));

        IMTIdentificationFilter filter = rerun.CreateFilter();

        filter.AddSessionID(trx.SessionUID);
        rerun.Identify(filter, desc);
        rerun.Analyze(desc);

        rerun.BackoutDelete(desc);

        // Return rerun ID
        rerunID = rerun.ID;
        AdjustmentCache.GetInstance().GetLogger().LogDebug("Backed out original transaction, rerun id {0}", rerunID);

        meter.ListenerTransactionID = encodedCookie;
        //meter.TransactionID = transactionID;
        //meter.MeterSynchronously = true;
        //meter.SyncMeteringRetries = AdjustmentCache.GetInstance().GetBatchMAXRetries();
        //meter.SyncMeteringRetrySleepInterval = AdjustmentCache.GetInstance().GetBatchRetryInterval();
        meter.MeterPopulatedRowset();

        //CR 13892: examine failed session count
        if (meter.MeterErrorCount > 0)
          throw new RebillException("Failed to remeter transaction!");

        AdjustmentCache.GetInstance().GetLogger().LogDebug("Submitted Reassign rowset to pipeline");

      }
      finally
      {
        if (meter != null)
          System.Runtime.InteropServices.Marshal.ReleaseComObject(meter);
        if (oMTTransaction != null)
          System.Runtime.InteropServices.Marshal.ReleaseComObject(oMTTransaction);
      }

      return rs;
    }

    public void FinalizePrebillRebill(IMTSessionContext apCTX, int rerunID)
    {
      string desc = String.Format("Abandon rerun id {0}", rerunID);
      AdjustmentCache.GetInstance().GetLogger().LogDebug(desc);

      // Abandon rerun.
      IMTBillingReRun rerun = new MetraTech.Pipeline.ReRun.Client();
      rerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext)apCTX);
      rerun.ID = rerunID;
      rerun.Abandon(desc);
    }


    [AutoComplete]
    public MetraTech.Interop.Rowset.IMTRowSet CreatePostbillRebill
      (
      IMTSessionContext apCTX,
      IRebillTransaction trx,
      ProdCat.IMTPriceableItemType aPIType,
      object aProgress
      )
    {
      RS.IMTRowSet rs = new RS.MTSQLRowsetClass();
      IReasonCodeReader rcreader = new ReasonCodeReader();
      ResolveAccountIdentifiers(apCTX, trx);    
      
      AdjustmentTransactionReader reader = new AdjustmentTransactionReader();
      MeterRowset meter = null;
      try
      {
        meter = reader.CreateMeterRowset(trx, aPIType);
        meter.GenerateBatchID();

        //get current transaction info, export it to cookie and set it on MeterRowset

        TRX.IMTWhereaboutsManager whereaboutsmgr = new TRX.CMTWhereaboutsManagerClass();
        string cookie = whereaboutsmgr.GetWhereaboutsForServer("AdjustmentsServer");

        ITransaction oTransaction = (ITransaction)ContextUtil.Transaction;
        TRX.IMTTransaction oMTTransaction = new TRX.CMTTransactionClass();
        /*false means no ownership, otherwise it'll rollback when MTTransaction object is destroyed*/
        oMTTransaction.SetTransaction(oTransaction, false);
        string encodedCookie = oMTTransaction.Export(cookie);

        meter.ListenerTransactionID = encodedCookie;

        //2. Create 100% compensating adjustment
        Coll.IMTCollection sessions = new Coll.MTCollectionClass();
        sessions.Add(trx.SessionID);
        IAdjustmentTransactionSet ajset = trx.AdjustmentType.CreateAdjustmentTransactions(sessions);        
        ajset.ReasonCode = trx.ReasonCode;
        ajset.Description = trx.Description;
        rs = ajset.CalculateAdjustments(null);
        ajset.SaveAdjustments(null);
        meter.MeterPopulatedRowset();

        //CR 13892: examine failed session count
        if (meter.MeterErrorCount > 0)
          throw new RebillException("Failed to remeter transaction!");
      }
      finally
      {
        System.Runtime.InteropServices.Marshal.ReleaseComObject(meter);
      }
      return rs;

    }

    public void ResolveAccountIdentifiers(
                                          IMTSessionContext apCTX,
                                          IRebillTransaction trx
                                          )
    {
      // if neither internal SE iD or internal account ID are
      // set then there is nothing to resolve
      bool bResolved = false;
      AdjustmentCache.GetInstance().GetLogger().LogDebug("Resolving account identifiers for rebill");
             
      if (((RebillTransaction)trx).IsMIU)
      {
        ResolveMIUIdentifiers(apCTX, trx);
        return;
      }

      //if there is no account identifiers, then can not rebill
      if (trx.IdentifiedByAccount == false && trx.AccountID < 0)
        throw new RebillException("None of the properties on '{0}' service definition are marked as account identifiers and account id is not set, can not reassign transaction.");

      Hashtable idtypemappings = ((RebillTransaction)trx).GetTypeMappings();
      ProdCat.IMTProperty prop = null;
      if (trx.IdentifiedByAccountInternalID)
      {
        ProdCat.IMTPropertyMetaData accidmd = idtypemappings.Contains(AccountIdentifierType.ACCOUNT_ID) ?
          (ProdCat.IMTPropertyMetaData)idtypemappings[AccountIdentifierType.ACCOUNT_ID] : null;
        if (accidmd == null)
        {
          throw new AdjustmentException(string.Format("Property marked as \"accountid\" not found in {0}, trx.ServiceDefinition.Name"));
        }
        prop = (ProdCat.IMTProperty)trx.AccountIdentifiers[accidmd.Name];
        Debug.Assert(prop != null);
        if (IsEmpty(prop))
        {
          AdjustmentCache.GetInstance().GetLogger().LogDebug(string.Format(@"Property {0} of {1} is marked as accountid='Y' " +
          "but its' value is not set, skipping internal id identification.", prop.Name, trx.ServiceDefinition.Name));
        }
        else
        {
          AdjustmentCache.GetInstance().GetLogger().LogDebug("Property {0} is marked as accountid='Y' and is set to {1}. Nothing to resolve, proceeding with reassignment operation.",
            prop.Name, prop.Value);
          bResolved = true;
        }
      }
      //do a sanity check - make sure that property that is marked as "accountname" is set
      if (trx.IdentifiedByAccountExternalID && bResolved == false)
      {
        ProdCat.IMTPropertyMetaData accnamemd = idtypemappings.Contains(AccountIdentifierType.ACCOUNT_NAME) ?
        (ProdCat.IMTPropertyMetaData)idtypemappings[AccountIdentifierType.ACCOUNT_NAME] : null;
        object defvalue = null;
        if (accnamemd != null)
        {
          prop = (ProdCat.IMTProperty)trx.AccountIdentifiers[accnamemd.Name];
          defvalue = prop.GetMetaData().DefaultValue;
        }
        else
        {
          throw new AdjustmentException(string.Format("Property marked as \"accountname\" not found in {0}", trx.ServiceDefinition.Name));
        }
        if (IsEmpty(prop))
        {
          AdjustmentCache.GetInstance().GetLogger().LogDebug(string.Format(@"Property {0} of {1} is marked as accountname='Y' " +
          "but its' value is not set, skipping external id identification.", prop.Name, trx.ServiceDefinition.Name));
        }
        //CR 14173: only if the value is not a default value for this service def.
        else if (string.Compare(defvalue.ToString(), prop.Value.ToString(), true) != 0)
        {
          AdjustmentCache.GetInstance().GetLogger().LogDebug("Property {0} is marked as accountname='Y' and is set to {1}. Nothing to resolve, proceeding with reassignment operation.",
            prop.Name, prop.Value);
          bResolved = true;
        }
      }
      if (bResolved == false)
      {
        if (trx.AccountID > 0)
        {
          ResolveAccount(apCTX, trx);
        }       
        else
        {
          if (trx.IdentifiedByAccount)
          {
            throw new AdjustmentException(string.Format("Neither {0} nor account id is set, can not reassign transaction", prop.Name));
          }
          else
          {
            throw new AdjustmentException(string.Format("{0} is missing account identifiers and account id is not set, can not reassign transaction", trx.ServiceDefinition.Name));
          }

        }
      }

    }

    public void ResolveAccount(
      IMTSessionContext apCTX,
      IRebillTransaction trx
      )
    {
      Hashtable idtypemappings = ((RebillTransaction)trx).GetTypeMappings();
      ProdCat.IMTPropertyMetaData accnamemd = idtypemappings.Contains(AccountIdentifierType.ACCOUNT_NAME) ?
        (ProdCat.IMTPropertyMetaData)idtypemappings[AccountIdentifierType.ACCOUNT_NAME] : null;
      ProdCat.IMTPropertyMetaData accnamespacemd = idtypemappings.Contains(AccountIdentifierType.ACCOUNT_NAMESPACE) ?
        (ProdCat.IMTPropertyMetaData)idtypemappings[AccountIdentifierType.ACCOUNT_NAMESPACE] : null;
      ProdCat.IMTProperty accname = null;
      ProdCat.IMTProperty accnamespace = null;

      AdjustmentCache.GetInstance().GetLogger().LogDebug("Resolving Account based on '{0}' DB ID", trx.AccountID);

      //TODO: !!!!!!
      //Is it going to screw up my transaction?
      //There really isn't an easy way
      //to get YAAC object from an executant
      YAAC.IMTYAAC acc = new YAAC.MTYAACClass();
      acc.InitAsSecuredResource
        (
        trx.AccountID,
        (MetraTech.Interop.MTYAAC.IMTSessionContext)apCTX,
        null //no date, I want it as of NOW
        );
      Debug.Assert(acc != null);

      //now Set account name and (optionally!) namespace
      //in identifiers collection

      if (accnamemd != null)
        accname = (ProdCat.IMTProperty)trx.AccountIdentifiers[accnamemd.Name];
      if (accnamespacemd != null)
        accnamespace = (ProdCat.IMTProperty)trx.AccountIdentifiers[accnamespacemd.Name];
      Debug.Assert(accname != null);
      //CR 10287 fix. Don't use Account Name.
      accname.Value = acc.LoginName;

      if (accnamespace != null)
      {
        accnamespace.Value = acc.Namespace;
      }

      AdjustmentCache.GetInstance().GetLogger().LogDebug("Resolved Account based on '{0}' ID: Name - {1}, Namespace - {2}",
        trx.AccountID, accname.Value, acc.Namespace);


    }
    public void ResolveMIUIdentifiers(
      IMTSessionContext apCTX,
      IRebillTransaction trx
      )
    {

      ProdCat.IMTProperty accid = null;
      ProdCat.IMTProperty accname = null;
      ProdCat.IMTProperty accnamespace = null;

      Hashtable idtypemappings = ((RebillTransaction)trx).GetTypeMappings();
      ProdCat.IMTPropertyMetaData accountidmd = idtypemappings.Contains(AccountIdentifierType.ACCOUNT_ID) ?
        (ProdCat.IMTPropertyMetaData)idtypemappings[AccountIdentifierType.ACCOUNT_ID] : null;
      ProdCat.IMTPropertyMetaData accountnamemd = idtypemappings.Contains(AccountIdentifierType.ACCOUNT_NAME) ?
        (ProdCat.IMTPropertyMetaData)idtypemappings[AccountIdentifierType.ACCOUNT_NAME] : null;
      ProdCat.IMTPropertyMetaData accountnamespacemd = idtypemappings.Contains(AccountIdentifierType.ACCOUNT_NAMESPACE) ?
        (ProdCat.IMTPropertyMetaData)idtypemappings[AccountIdentifierType.ACCOUNT_NAMESPACE] : null;
      if (accountidmd != null)
      {
        accid = (ProdCat.IMTProperty)trx.AccountIdentifiers[accountidmd.Name];
        if (accid != null)
          accid.Value = AdjustmentCache.GetInstance().GetMIU().AccountID;
      }
      if (accountnamemd != null)
      {
        accname = (ProdCat.IMTProperty)trx.AccountIdentifiers[accountnamemd.Name];
        if (accname != null)
          accname.Value = AdjustmentCache.GetInstance().GetMIU().AccountName;
      }
      if (accountnamespacemd != null)
      {
        accnamespace = (ProdCat.IMTProperty)trx.AccountIdentifiers[accountnamespacemd.Name];
        if (accnamespace != null)
          accnamespace.Value = AdjustmentCache.GetInstance().GetMIU().AccountNamespace;
      }

    }
    private bool IsEmpty(MetraTech.Interop.MTProductCatalog.IMTProperty prop)
    {
      return prop.Empty || System.Convert.ToString(prop.Value).Length < 1;
    }


  }


}
