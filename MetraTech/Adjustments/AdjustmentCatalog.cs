using System;
using System.Collections;
//
using MetraTech.Pipeline;
using MetraTech.Interop.MeterRowset;
using MetraTech.Interop.GenericCollection;
using System.Runtime.InteropServices;
using MetraTech.Interop.MTProductCatalog;
using RS = MetraTech.Interop.Rowset;




namespace MetraTech.Adjustments
{
  [Guid("f7a5e0ab-4dc3-4ef2-bb1f-04b7b4d645f9")]
  public interface IAdjustmentCatalog
  {
    void Initialize( IMTSessionContext apCTX);

    MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypesForPITemplate(int aPITemplateID,bool bParentId);
    MetraTech.Interop.GenericCollection.IMTCollection GetAdjustments(IMTPriceableItem pi);
    MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypes (int aPITypeID);
    MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodes ();
    RS.IMTSQLRowset GetReasonCodesAsRowset ();
    IAdjustmentType GetAdjustmentTypeByName(string aName);
    IAdjustmentType GetAdjustmentType(int aID);
    IApplicabilityRule GetApplicabilityRuleByName(string aName);
    IApplicabilityRule GetApplicabilityRule(int aID);
    IReasonCode GetReasonCodeByName(string aName);
    IReasonCode GetReasonCode(int aID);
    IRebillTransaction CreateRebillTransaction(long sessionID);
    RS.IMTSQLRowset GetAdjustedTransactionsAsRowset(RS.IMTDataFilter filter);
    RS.IMTSQLRowset GetOrphanAdjustmentsAsRowset(RS.IMTDataFilter filter);
    RS.IMTSQLRowset GetAdjustmentDetailsAsRowset(int aAdjustmentTransactionID);
    IAdjustmentTransactionSet CreateAdjustmentTransactions(object aSessions);
    IAdjustmentTransactionSet CreateOrphanAdjustments(object aAdjTransactionIds);
    IReasonCode CreateReasonCode();
    //MetraTech.Interop.GenericCollection.IMTCollection  GetAdjustmentTypeApplicabilityRules(int aAdjustmentTypeID);
    void SynchronizeTypes();
		IRebillTransactionSet CreateRebillTransactions(object aSessions);
  }
  /// <summary>
	/// Top Level data object
	/// </summary>
	/// 
  [Guid("6f0113ed-b33a-4aa5-a082-c1590f98f5dd")]
  [ClassInterface(ClassInterfaceType.None)]
	public class AdjustmentCatalog : IAdjustmentCatalog
	{
    private  IMTSessionContext mCtx;
    private System.Collections.Hashtable mTemplateMap;
    private System.Collections.Hashtable mTypesMap;
    private System.Collections.Hashtable mPITypeMap;
    private System.Collections.Hashtable mApplicMap;

    public AdjustmentCatalog()
		{
			mTemplateMap = new Hashtable();
      mPITypeMap = new Hashtable();
      mTypesMap = new Hashtable();
      mApplicMap = new Hashtable();
		}

    /// <summary>
    /// Initialize method with session context of the caller has to be called first.
    /// </summary>
    public void Initialize( IMTSessionContext apCTX)
    {
      mCtx = apCTX;
       
    }
    /// <summary>
    /// Retrieve adjustment types supported by given PI template
    /// </summary>
    public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypesForPITemplate(int aPITemplateID,bool bParentId)
    {
      return AdjustmentCache.GetInstance().GetAdjustmentTypesForPITemplate(mCtx, aPITemplateID,bParentId);
    }

    /// <summary>
    /// Retrieve adjustment templates Attached to a given PI template
    /// </summary>
    public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustments(IMTPriceableItem aPI)
    {
      return AdjustmentCache.GetInstance().GetAdjustments(mCtx, aPI);
    }
    /// <summary>
    /// Retrieve adjustment types supported by given PI Type
    /// </summary>
    public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypes(int aPITypeID)
    {
      return AdjustmentCache.GetInstance().GetAdjustmentTypes(mCtx, aPITypeID);
    }
    /// <summary>
    /// Retrieve adjustment type by name
    /// </summary>
    public IAdjustmentType GetAdjustmentTypeByName(string aName)
    {
      return AdjustmentCache.GetInstance().GetAdjustmentTypeByName(mCtx, aName);
    }
    /// <summary>
    /// Retrieve adjustment type by id
    /// </summary>
    public IAdjustmentType GetAdjustmentType(int aID)
    {
      return AdjustmentCache.GetInstance().GetAdjustmentType(mCtx, aID);
    }
    public void SynchronizeTypes()
    {
      AdjustmentCache.GetInstance().SynchronizeTypes(mCtx);
    }

    /// <summary>
    /// Retrieve applicability rule by id
    /// </summary>
    public IApplicabilityRule GetApplicabilityRule(int aID)
    {
       return AdjustmentCache.GetInstance().GetApplicabilityRule(mCtx, aID);
    }

    
    /// <summary>
    /// Retrieve applicability rule by id
    /// </summary>
    public IApplicabilityRule GetApplicabilityRuleByName(string aName)
    {
      return AdjustmentCache.GetInstance().GetApplicabilityRuleByName(mCtx, aName);
    }

    /// <summary>
    /// Create new reason code
    /// </summary>
    public IReasonCode CreateReasonCode()
    {
      if(mCtx == null)
        throw new AdjustmentException("Adjustment Catalog needs to be initialized first.");
      IReasonCode outobj = new ReasonCode();
      outobj.SetSessionContext((IMTSessionContext)mCtx);
      return outobj;
    }

    /// <summary>
    /// Retrieve reason code by id
    /// </summary>
    public IReasonCode GetReasonCode(int aID)
    {
      return AdjustmentCache.GetInstance().GetReasonCode(mCtx, aID);
    }

    
    /// <summary>
    /// Retrieve reason code by name
    /// </summary>
    public IReasonCode GetReasonCodeByName(string aName)
    {
      return AdjustmentCache.GetInstance().GetReasonCodeByName(mCtx, aName);
    }

    /// <summary>
    /// Retrieve all reason codes
    /// </summary>
    public MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodes()
    {
      return AdjustmentCache.GetInstance().GetReasonCodes(mCtx);
    }

    /// <summary>
    /// Retrieve all reason codes as rowset
    /// </summary>
    public RS.IMTSQLRowset GetReasonCodesAsRowset()
    {
      return AdjustmentCache.GetInstance().GetReasonCodesAsRowset(mCtx);
    }

    /// <summary>
    /// Creates a transaction to be rebilled based on transaction session id
    /// </summary>
    public IRebillTransaction CreateRebillTransaction(long sessionID)
    {
      //1. Based on the session ID, fetch the usage record
      //2. Create meter rowset based on the parent record rowset
      //3. Get children PI Types based on id_template->Type
      //4. Get MSIX service ID from PI type?
      //5. For every children PI type Fetch the rowset the children of this transaction
      //6. Add all those rowsets as children of this one
      //7 based on the parent service, get MSIX collection and account identifiers
      IAdjustmentTransactionReader reader = new AdjustmentTransactionReader();
      return reader.CreateRebillTransaction(mCtx, sessionID);
    }

		public IRebillTransactionSet CreateRebillTransactions(object ids)
		{
			MetraTech.Interop.GenericCollection.IMTCollection sessions = (MetraTech.Interop.GenericCollection.IMTCollection)ids;
			IAdjustmentTransactionReader reader = new AdjustmentTransactionReader();
			return reader.CreateRebillTransactions(mCtx, sessions);
		}

    
    /// <summary>
    /// Retrieves a summary rowset for previously adjusted transactions based
    /// on the DataFilter criteria
    /// </summary>
    public RS.IMTSQLRowset GetAdjustedTransactionsAsRowset(RS.IMTDataFilter filter)
    {
      return AdjustmentCache.GetInstance().GetAdjustedTransactionsAsRowset(mCtx, filter);
    }

    /// <summary>
    /// Retrieves a summary rowset for Orphan transactions
    /// on the DataFilter criteria
    /// </summary>
    public RS.IMTSQLRowset GetOrphanAdjustmentsAsRowset(RS.IMTDataFilter filter)
    {
      return AdjustmentCache.GetInstance().GetOrphanAdjustmentsAsRowset(mCtx, filter);
    }

    /// <summary>
    /// Creates a Set of previously adjusted transactions for management purposes:
    /// Bulk approve, bulk delete etc.
    /// </summary>
    public IAdjustmentTransactionSet CreateAdjustmentTransactions(object aSessions)
    {
      MetraTech.Interop.GenericCollection.IMTCollection sessions = (MetraTech.Interop.GenericCollection.IMTCollection)aSessions;
      IAdjustmentTransactionSet trxset = new AdjustmentTransactionSet();
      trxset.Initialize(mCtx, sessions, false);
      return trxset;
    }

    /// <summary>
    /// Creates a set of Orphan adjustments for management
    /// Bulk approve, bulk delete etc.
    /// </summary>
    public IAdjustmentTransactionSet CreateOrphanAdjustments(object aAdjTransactionIds)
    {
      MetraTech.Interop.GenericCollection.IMTCollection trxs = (MetraTech.Interop.GenericCollection.IMTCollection)aAdjTransactionIds;
      IAdjustmentTransactionSet trxset = new AdjustmentTransactionSet();
      trxset.InitializeOrphans((IMTSessionContext)mCtx, trxs);
      return trxset;
    }


    /// <summary>
    /// Retrieves charge breakdown rowset based on adjustment transaction DB ID
    /// </summary>
    public RS.IMTSQLRowset GetAdjustmentDetailsAsRowset(int aTrxID)
    {
      return AdjustmentCache.GetInstance().GetAdjustmentDetailsAsRowset(mCtx, aTrxID);
    }
    
   
	}
}
