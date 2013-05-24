using System;
using System.Collections;
using MetraTech.Interop.GenericCollection;
using RS = MetraTech.Interop.Rowset;
using MetraTech.Interop.MTProductCatalog;
using System.Runtime.InteropServices;
using System.Diagnostics;
//
using MetraTech.Interop.MTAuditEvents;
using MetraTech;


namespace MetraTech.Adjustments
{
  
  [Guid("5f22d857-3047-44b9-967d-1969dac42d35")]
  public interface IAdjustmentTransactionSet : IMTPCBase
  {
    MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTransactions();
		

    //TODO: hide next property
    //transaction set could be initialized
    //with transactions across types
    // i.e. "For Approval"
    /*
    IAdjustmentType AdjustmentType
    {
      get;
      set;
    }
    */

    int AdjustmentTemplateID
    {
      get;set;
    }
    int AdjustmentInstanceID
    {
      get;set;
    }

    IMTProperties Inputs
    {
      get;set;
    }
    IMTProperties Outputs
    {
      get;set;
    }
    string Description
    {
      get;set;
    }
    IReasonCode ReasonCode
    {
      get;set;
    }
    bool ApplyDefaultDescription
    {
      get;set;
    }
	MetraTech.Interop.GenericCollection.IMTCollection ChildTransactionSets
	{
		get;set;
	}
    MetraTech.Interop.Rowset.IMTRowSet CalculateAdjustments(object aProgressObject);
    MetraTech.Interop.Rowset.IMTRowSet SaveAdjustments(object aProgressObject);
    MetraTech.Interop.GenericCollection.IMTCollection GetApplicableReasonCodes();
    void Initialize
      ( IMTSessionContext aCTX, 
        MetraTech.Interop.GenericCollection.IMTCollection aTrxs, bool bKids
      );
	void InitializeForComposite(IMTSessionContext aCTX, 
		  MetraTech.Interop.GenericCollection.IMTCollection aTrxSets);
    void InitializeOrphans
      ( IMTSessionContext aCTX, 
      MetraTech.Interop.GenericCollection.IMTCollection aTrxs
      );

    //The only 2 statuses that we can change transaction to manually are
    // 'A' (If trasnaction is in 'P' status)
    //and 'D' if transaction is either 'A' or 'P'
   MetraTech.Interop.Rowset.IMTRowSet ApproveAndSave(object aProgressObject);
   MetraTech.Interop.Rowset.IMTRowSet DeleteAndSave(object aProgressObject);

    //IMTPCBase
    new void SetSessionContext(MetraTech.Interop.MTProductCatalog.IMTSessionContext aCtx);
    new MetraTech.Interop.MTProductCatalog.IMTSessionContext GetSessionContext();
  }
  
	/// <summary>
	/// Summary description for AdjustmentTransactionSet.
	/// </summary>
	/// 

  
  [Guid("5020aba6-d925-4474-bab0-0bf0bdeb6ac8")]
	public class AdjustmentTransactionSet : PCBase, IAdjustmentTransactionSet
	{
    public AdjustmentTransactionSet()
    {
      mReasonCodes = new MetraTech.Interop.GenericCollection.MTCollectionClass();
      mbOrphanSet = false;
      mbDefaultDesc = true;
      mDescription = string.Empty;
     
    }
    public AdjustmentTransactionSet(IMTSessionContext aCTX, 
                                    MetraTech.Interop.GenericCollection.IMTCollection aTrxs)
		{
			mTransactions = aTrxs;
      mInputs = null;
      mOutputs = null;
		}
    public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTransactions()
    {
      return mTransactions;
    }
    public IMTProperties Inputs
    {
      
      get 
      {
        if (mInputs == null)
          mInputs = AdjustmentType.CreateInputProperties();
        return mInputs;
      }
      set {mInputs = value;}
    }
    public IMTProperties Outputs
    {
      get 
      {
        if (mOutputs == null)
          mOutputs = AdjustmentType.CreateOutputProperties();
         return mOutputs;
      }

      set {mOutputs = value;}
    }
    public IAdjustmentType AdjustmentType
    {
      get { return mType; }
      set { mType = value; }
    }
    public int AdjustmentTemplateID
    {
      get { return mAJTemplateID; }
      set { mAJTemplateID = value; }
    }
    public int AdjustmentInstanceID
    {
      get { return mAJInstanceID; }
      set { mAJInstanceID = value; }
    }
    public string Description
    {
      get 
      { 
        IAdjustmentDescription desc = null;
      
        //preset description to default one
        //if transaction set size is 1, then
        //fully expand it.
        if( 
            this.AdjustmentType != null && 
            this.AdjustmentType.DefaultAdjustmentDescription != null && 
            mDescription.Length < 1
          )
        {
          desc = AdjustmentType.DefaultAdjustmentDescription;
          if(this.GetAdjustmentTransactions().Count == 1)
          {
            mDescription = desc.Expand((IAdjustmentTransaction)this.GetAdjustmentTransactions()[1]);
          }
          else
            mDescription = desc.UserFriendlyDescription;
        }
        return mDescription; 
      }
      set { mDescription = value; }
    }
    
    public IReasonCode ReasonCode
    {
      get { return mReasonCode; }
      set { mReasonCode = value; }
    }

    public bool ApplyDefaultDescription
    {
      get { return mbDefaultDesc; }
      set { mbDefaultDesc = value; }
    }

	public MetraTech.Interop.GenericCollection.IMTCollection ChildTransactionSets
	{
		get { return mTrxSets; }
		set { mTrxSets = value; }
	}

	public MetraTech.Interop.Rowset.IMTRowSet CalculateAdjustments(object aProgressObject)
    {
      if(Inputs == null || Outputs == null)
        throw new AdjustmentException("Transaction set is not initialized for adjustment calculation, call AdjustmentType::CreateAdjustmentTransactions");
      return mType.Calculate(this, aProgressObject);
    }
    public MetraTech.Interop.Rowset.IMTRowSet SaveAdjustments(object aProgressObject)
    {
		return mType.SaveAdjustments(this, aProgressObject);
    }
    public MetraTech.Interop.GenericCollection.IMTCollection  
      GetApplicableReasonCodes()
    {
      return mReasonCodes;
    }
    //not on the interface
    public void SetAdjustmentTransactions(MetraTech.Interop.GenericCollection.IMTCollection aTrxs)
    {
      mTransactions = aTrxs;
    }
    public void Initialize(IMTSessionContext aCTX, 
      MetraTech.Interop.GenericCollection.IMTCollection aTrxs, bool aKids)
    {
      //collection of session ids is stored for convenience
      mIDCol = aTrxs;
      
      SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)aCTX);
      //get transactions from the reader
      AdjustmentTransactionReader reader = new AdjustmentTransactionReader();
      IReasonCodeReader rcreader = new ReasonCodeReader();
      mTransactions = (MetraTech.Interop.GenericCollection.IMTCollection)reader.GetAdjustmentTransactions
        (this, 
        (MetraTech.Interop.MTProductCatalog.IMTCollection)aTrxs, 
        aKids);
      mInputs = null;
      mOutputs = null;
      //set input on every transaction
      //only if Adjustment Type is not null
      if(AdjustmentType != null && mTransactions.Count > 0)
      {
        Debug.Assert(AdjustmentTemplateID > 0);
        mReasonCodes = rcreader.GetReasonCodesForAdjustmentTemplate(aCTX, this.AdjustmentTemplateID);
        foreach(IAdjustmentTransaction trx in mTransactions)
        {
          trx.Inputs = Inputs;
          trx.Outputs = Outputs;
        }
      }
    }
	public void InitializeForComposite(IMTSessionContext aCTX, 
		MetraTech.Interop.GenericCollection.IMTCollection aTrxSets)
	{
		// The array of transaction sets are stored in a member variable for 
		// further use
		mTrxSets = aTrxSets;
		SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)aCTX);
		IReasonCodeReader rcreader = new ReasonCodeReader();
		
		MetraTech.Interop.GenericCollection.IMTCollection aTempIds = new MTCollectionClass();
		mTransactions = new MTCollectionClass();
		foreach(IAdjustmentTransactionSet trxSet in  aTrxSets)
		{
			MetraTech.Interop.GenericCollection.IMTCollection childTrxs = trxSet.GetAdjustmentTransactions();
			if(trxSet.AdjustmentTemplateID > 0)
			  aTempIds.Add(trxSet.AdjustmentTemplateID);
			foreach(IAdjustmentTransaction trx in childTrxs)
			{
				mTransactions.Add(trx);
			}
 		}
		if(mTransactions.Count <= 0)
		{
			throw new AdjustmentException("No usage transactions were found.");
		}
		

		mReasonCodes = rcreader.GetCommonReasonCodesForAdjustmentTemplate(aCTX, aTempIds);

		mInputs = null;
		mOutputs = null;	
	}
    

    public void InitializeOrphans(IMTSessionContext aCTX, 
      MetraTech.Interop.GenericCollection.IMTCollection aTrxs)
    {
      mIDCol = aTrxs;

      SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)aCTX);
      //get transactions from the reader
      AdjustmentTransactionReader reader = new AdjustmentTransactionReader();
      mTransactions = (MetraTech.Interop.GenericCollection.IMTCollection)reader.GetOrphanAdjustments
        (
        aCTX,
        this, 
        (MetraTech.Interop.MTProductCatalog.IMTCollection)aTrxs 
        );
      mInputs = null;
      mOutputs = null;
      mbOrphanSet = true;
     
    }
    
    
    /// <summary>
    /// Bulk approves a set of transactions
    /// </summary>
    /// 
    public MetraTech.Interop.Rowset.IMTRowSet ApproveAndSave(object aProgressObject)
    {
      //1 first check Manage Adjustments capaibility
      string capname = "Manage Adjustments";
      AdjustmentStatus final = AdjustmentStatus.APPROVED;
      uint MTAUTH_ACCESS_DENIED = 0xE29F0001;
      MTAuditEntityType entity = MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT;
      //MTAUTH_ACCESS_DENIED             ((DWORD)0xE29F0001L)

      if(mbOrphanSet)
        return SaveOrphans(final, aProgressObject);

			MetraTech.Interop.MTAuthExec.IMTCompositeCapabilityTypeReader capReader = 
				new MetraTech.Interop.MTAuthExec.MTCompositeCapabilityTypeReaderClass();
      
      MetraTech.Interop.MTAuth.IMTCompositeCapability requiredCap = 
        ((MetraTech.Interop.MTAuth.IMTCompositeCapabilityType)capReader.GetByName(capname)).CreateInstance();
      MetraTech.Interop.MTAuth.IMTSecurityContext ctx = 
        (MetraTech.Interop.MTAuth.IMTSecurityContext)GetSessionContext().SecurityContext;
     

      //evaluate state transition
      
      RS.IMTSQLRowset warnings = Utils.CreateWarningsRowset();
      IAdjustmentTransactionWriter writer = new AdjustmentTransactionWriter();
      MetraTech.Interop.GenericCollection.IMTCollection qualifiedsessions = new MTCollectionClass();

      foreach (IAdjustmentTransaction trx in GetAdjustmentTransactions())
      {
        try
        {
          Utils.EvaluateStateTransition(trx.Status, final, trx.PayerAccountID, trx.IntervalID);
          qualifiedsessions.Add(trx);
        }
        catch(AdjustmentUserException ex)
        {
          warnings.AddRow();
          warnings.AddColumnData("id_sess",trx.SessionID);
          warnings.AddColumnData("description", ex.Message);
          continue;
        }
      }
      if(qualifiedsessions.Count > 0)
      {
        //check Auth and audit failures
        try
        {
          ctx.CheckAccess(requiredCap);
        }
        catch(COMException ex)
        {
          if((uint)ex.ErrorCode == MTAUTH_ACCESS_DENIED)
          {
            foreach(IAdjustmentTransaction trx in qualifiedsessions)
            {
              MTAuditEvent auditevent = trx.IsPrebill ? 
                MTAuditEvent.AUDITEVENT_PREBILL_ADJUSTMENT_APPROVE_DENIED :
                MTAuditEvent.AUDITEVENT_POSTBILL_ADJUSTMENT_APPROVE_DENIED;

              AdjustmentCache.GetInstance().GetAuditor().FireEvent
                (
                (int)auditevent,
                GetSessionContext() != null ? GetSessionContext().AccountID : -1,
                (int)entity,
                trx.PayerAccountID,
                trx.Description
                );
            }
            throw;
          }

          throw;

        }
        writer.Approve(GetSessionContext(), 
                       ( MetraTech.Interop.MTProductCatalog.IMTCollection)qualifiedsessions, 
                       aProgressObject
                      );

        // hmm... now I need to audit those guys. Is there a better way than
        // Fire events for each individual transaction?
        AdjustmentCache.GetInstance().GetLogger().LogDebug("Inserting audit entries for approved adjustments");
        
        foreach(IAdjustmentTransaction trx in qualifiedsessions)
        {
          MTAuditEvent auditevent = trx.IsPrebill ? 
            MTAuditEvent.AUDITEVENT_PREBILL_ADJUSTMENT_APPROVE :
            MTAuditEvent.AUDITEVENT_POSTBILL_ADJUSTMENT_APPROVE;
          AdjustmentCache.GetInstance().GetAuditor().FireEvent
            (
            (int)auditevent,
            GetSessionContext() != null ? GetSessionContext().AccountID : -1,
            (int)entity,
            trx.PayerAccountID,
            trx.Description
            );
        }

      }
      if(warnings.RecordCount > 0)
        warnings.MoveFirst();
    
      return warnings;
    }
    
    /// <summary>
    /// Bulk deletes a set of transactions
    /// </summary>
    /// 
    public MetraTech.Interop.Rowset.IMTRowSet DeleteAndSave(object aProgressObject)
    {
      //1 first check Manage Adjustments capaibility
      string capname = "Manage Adjustments";
      uint MTAUTH_ACCESS_DENIED = 0xE29F0001;
      MTAuditEntityType entity = MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT;
      
			MetraTech.Interop.MTAuthExec.IMTCompositeCapabilityTypeReader capReader = 
				new MetraTech.Interop.MTAuthExec.MTCompositeCapabilityTypeReaderClass();
      MetraTech.Interop.MTAuth.IMTCompositeCapability requiredCap = 
        ((MetraTech.Interop.MTAuth.IMTCompositeCapabilityType)capReader.GetByName(capname)).CreateInstance();
      MetraTech.Interop.MTAuth.IMTSecurityContext ctx = 
        (MetraTech.Interop.MTAuth.IMTSecurityContext)GetSessionContext().SecurityContext;
      //evaluate state transition
      AdjustmentStatus final = AdjustmentStatus.DELETED;
      if(mbOrphanSet)
        return SaveOrphans(final, aProgressObject);
      RS.IMTSQLRowset warnings = Utils.CreateWarningsRowset();
      IAdjustmentTransactionWriter writer = new AdjustmentTransactionWriter();
       MetraTech.Interop.GenericCollection.IMTCollection 
         qualifiedsessions = new MTCollectionClass();

      foreach (IAdjustmentTransaction trx in GetAdjustmentTransactions())
      {
        try
        {
          Utils.EvaluateStateTransition(trx.Status, final, trx.PayerAccountID, trx.IntervalID);
          qualifiedsessions.Add(trx);
        }
        catch(AdjustmentUserException ex)
        {
          warnings.AddRow();
          warnings.AddColumnData("id_sess",trx.SessionID);
          warnings.AddColumnData("description", ex.Message);
          continue;
        }
      }
      if(qualifiedsessions.Count > 0)
      {
        //check Auth and audit failures
        try
        {
          ctx.CheckAccess(requiredCap);
        }
        catch(COMException ex)
        {
          if((uint)ex.ErrorCode == MTAUTH_ACCESS_DENIED)
          {
            foreach(IAdjustmentTransaction trx in qualifiedsessions)
            {
              MTAuditEvent auditevent = trx.IsPrebill ? 
                MTAuditEvent.AUDITEVENT_PREBILL_ADJUSTMENT_DELETE_DENIED :
                MTAuditEvent.AUDITEVENT_POSTBILL_ADJUSTMENT_DELETE_DENIED;

              AdjustmentCache.GetInstance().GetAuditor().FireEvent
                (
                (int)auditevent,
                GetSessionContext() != null ? GetSessionContext().AccountID : -1,
                (int)entity,
                trx.PayerAccountID,
                trx.Description
                );
            }
          }
          throw;
        }
        writer.UpdateState( (IMTSessionContext)GetSessionContext(), 
                            (MetraTech.Interop.MTProductCatalog.IMTCollection)qualifiedsessions,
                            final, 
                            aProgressObject
                          );
        // hmm... now I need to audit those guys. Is there a better way than
        // Fire events for each individual transaction?
        AdjustmentCache.GetInstance().GetLogger().LogDebug("Inserting audit entries for approved adjustments");
        
        foreach(IAdjustmentTransaction trx in qualifiedsessions)
        {
          MTAuditEvent auditevent = trx.IsPrebill ? 
            MTAuditEvent.AUDITEVENT_PREBILL_ADJUSTMENT_DELETE :
            MTAuditEvent.AUDITEVENT_POSTBILL_ADJUSTMENT_DELETE;
          AdjustmentCache.GetInstance().GetAuditor().FireEvent
            (
            (int)auditevent,
            GetSessionContext() != null ? GetSessionContext().AccountID : -1,
            (int)entity,
            trx.PayerAccountID,
            trx.Description
            );
        }
      }
      if(warnings.RecordCount > 0)
        warnings.MoveFirst();
    
      return warnings;
    }

    public void ClearOutputs()
    {
      foreach (IMTProperty outpprop in mOutputs)
      {
        outpprop.Value = null; 
      }
    }

    private MetraTech.Interop.Rowset.IMTRowSet SaveOrphans(AdjustmentStatus aStatus, object aProgressObject)
    {
      IAdjustmentTransactionWriter writer = new AdjustmentTransactionWriter();
      string sStatus = (aStatus == AdjustmentStatus.APPROVED) ? "APPROVED" : "DENIED";
      RS.IMTSQLRowset warnings = Utils.CreateWarningsRowset();

      //1 first check Manage Adjustments capaibility
      string capname = "Apply Adjustments";

			MetraTech.Interop.MTAuthExec.IMTCompositeCapabilityTypeReader capReader = 
				new MetraTech.Interop.MTAuthExec.MTCompositeCapabilityTypeReaderClass();
      
      MetraTech.Interop.MTAuth.IMTCompositeCapability requiredCap = 
        ((MetraTech.Interop.MTAuth.IMTCompositeCapabilityType)capReader.GetByName(capname)).CreateInstance();
      MetraTech.Interop.MTAuth.IMTSecurityContext ctx = 
        (MetraTech.Interop.MTAuth.IMTSecurityContext)GetSessionContext().SecurityContext;
      ctx.CheckAccess(requiredCap);


      //warnings rowset is always empty here.
      //What are the cases where we could generate a warning?
      return writer.SaveOrphans( this,
                                 aStatus, 
                                 aProgressObject
                                );
    }

    internal MetraTech.Interop.GenericCollection.IMTCollection GetIDCollection()
    {
      return mIDCol == null ? new MetraTech.Interop.GenericCollection.MTCollectionClass() : mIDCol;
    }




    private MetraTech.Interop.GenericCollection.IMTCollection mTransactions; 
    private MetraTech.Interop.GenericCollection.IMTCollection mTrxSets;
    private MetraTech.Interop.GenericCollection.IMTCollection mReasonCodes;
    private IReasonCode mReasonCode;
    private IAdjustmentType mType;
    private MetraTech.Interop.MTProductCatalog.IMTProperties mInputs;
    private MetraTech.Interop.MTProductCatalog.IMTProperties mOutputs;
    private string mDescription;
    private int mAJTemplateID;
    private int mAJInstanceID;
    private bool mbOrphanSet;
    private bool mbDefaultDesc;
    MetraTech.Interop.GenericCollection.IMTCollection mIDCol;

	}

}


