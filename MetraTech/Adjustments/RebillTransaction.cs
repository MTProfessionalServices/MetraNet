using System;
using System.Collections;
using RS = MetraTech.Interop.Rowset;
using MetraTech.Interop.MeterRowset;
using MetraTech.Pipeline;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTBillingReRun;
using MetraTech.Interop.MTAuditEvents;
using Coll = MetraTech.Interop.GenericCollection;
using System.Runtime.InteropServices;
using System.Diagnostics;
using MTAuthExec = MetraTech.Interop.MTAuthExec;


namespace MetraTech.Adjustments
{
  /// <summary>
  /// CR 14130: put some basic support for bulk reassignment
  /// </summary>
  /// 
  [Guid("f5fe35e4-e957-4ebe-b09c-d3791ed04cf5")]
  public interface IRebillTransactionSet
  {
    IServiceDefinition ServiceDefinition
    {
      get;
    }
    IMTProperties AccountIdentifiers
    {
      get;
    }
    IReasonCode ReasonCode
    {
      get;
      set;
    }
    string Description
    {
      get;
      set;
    }
    bool IdentifiedByAccount
    {
      get;
    }
    bool IdentifiedByAccountExternalID
    {
      get;
    }
    bool IdentifiedByAccountInternalID
    {
      get;
    }
    bool CanSaveToMIU
    {
      get;
    }
    int AccountID
    {
      get;
      set;
    }
    int Count
    {
      get;
    }

    MetraTech.Interop.GenericCollection.IMTCollection
      GetApplicableReasonCodes();
    MetraTech.Interop.Rowset.IMTRowSet Save(object aProgressObject);
    MetraTech.Interop.Rowset.IMTRowSet SaveToMIU(object aProgressObject);
    MetraTech.Interop.Rowset.IMTRowSet SaveToMIUAsynchronously(object aProgressObject);
  }

  [Guid("b94a06e9-fbc1-41d3-96e7-4234ba1774c7")]
  [ClassInterface(ClassInterfaceType.None)]
  public class RebillTransactionSet : IRebillTransactionSet
  {
    private RebillTransactionSet()
    {

    }
    public RebillTransactionSet(MetraTech.Interop.GenericCollection.IMTCollection trxs) { mTransactions = trxs; }
    public IServiceDefinition ServiceDefinition
    {
      get
      {
        return ((IRebillTransaction)mTransactions[1]).ServiceDefinition;
      }
    }
    public IMTProperties AccountIdentifiers
    {
      get
      {
        return ((IRebillTransaction)mTransactions[1]).AccountIdentifiers;
      }
    }
    public int Count
    {
      get
      {
        return mTransactions.Count;
      }
    }
    public IReasonCode ReasonCode
    {
      get
      {
        return mReasonCode;
      }
      set
      {
        mReasonCode = value;
      }
    }
    public string Description
    {
      get
      {
        return mDescription;
      }
      set
      {
        mDescription = value;
      }
    }
    public bool IdentifiedByAccount
    {
      get
      {
        return ((IRebillTransaction)mTransactions[1]).IdentifiedByAccount;
      }
    }
    public bool IdentifiedByAccountExternalID
    {
      get
      {
        return ((IRebillTransaction)mTransactions[1]).IdentifiedByAccountExternalID;
      }
    }
    public bool IdentifiedByAccountInternalID
    {
      get
      {
        return ((IRebillTransaction)mTransactions[1]).IdentifiedByAccountInternalID;
      }
    }
    public bool CanSaveToMIU
    {
      get
      {
        return ((IRebillTransaction)mTransactions[1]).CanSaveToMIU;
      }
    }
    public int AccountID
    {
      get
      {
        return mAccountID;
      }
      set
      {
        mAccountID = value;
      }
    }

    public MetraTech.Interop.GenericCollection.IMTCollection GetApplicableReasonCodes()
    {
      return ((IRebillTransaction)mTransactions[1]).GetApplicableReasonCodes();
    }
    public MetraTech.Interop.Rowset.IMTRowSet Save(object aProgressObject)
    {
      bool atleastonewarn = false;
      //loop over rebill transactions. Refuse to reassign prebill ones.
      //Attempt to reassign the rest and return  error rowset
      RS.IMTSQLRowset errs = Utils.CreateWarningsRowset();
      long sessid = 0;
      bool first = true;
      IMTProperties accountidentifiers = null;
      foreach (IRebillTransaction trx in mTransactions)
      {
        try
        {
          bool bIsPrebill = trx.IsPrebill;
          sessid = trx.SessionID;
          if (bIsPrebill == true) throw new AdjustmentException("Bulk reassignment operations are not supported for prebill transactions");
          //propagate account identifiers down to all transactions
          if (first)
          {
            accountidentifiers = trx.AccountIdentifiers;
            first = false;
          }
          else
          {
            ((RebillTransaction)trx).SetAccountIdentifiers(accountidentifiers);
          }
          trx.ReasonCode = this.ReasonCode;
          trx.Description = this.Description;
          trx.AccountID = this.AccountID;
          trx.Save(aProgressObject);

        }
        catch (ApplicationException e)
        {
          atleastonewarn = true;
          Utils.InsertWarningRecord(ref errs, sessid, e.Message);
        }
        catch (Exception e)
        {
          atleastonewarn = true;
          //in case of unexpected exception put some more info
          Utils.InsertWarningRecord(ref errs, 0, e.ToString());
        }
      }

      if (atleastonewarn)
        errs.MoveFirst();
      return errs;
    }
    public MetraTech.Interop.Rowset.IMTRowSet SaveToMIU(object aProgressObject)
    {
      // Loop over rebill transactions. Refuse to reassign prebill ones.
      // Attempt to reassign the rest and return  error rowset
      RS.IMTSQLRowset errs = Utils.CreateWarningsRowset();
      return errs;
    }

    public MetraTech.Interop.Rowset.IMTRowSet SaveToMIUAsynchronously(object aProgressObject)
    {
      //Code added on 06/02/2008 to implement rebill to uinknown account
      foreach (RebillTransaction trx in mTransactions)
      {
        trx.mbUnknownAccount = true;
      }
      return Save(aProgressObject);
    }

    private MetraTech.Interop.GenericCollection.IMTCollection mTransactions;
    private IReasonCode mReasonCode;
    private string mDescription;
    //MetraTech.Interop.GenericCollection.IMTCollection mIDCol;
    private int mAccountID;
  }


  /// <summary>
  /// Summary description for RebillTransaction.
  /// </summary>
  /// 
  [Guid("1e169711-1533-4967-b108-65455b7ced9b")]
  public interface IRebillTransaction
  {
    bool IsPrebill
    {
      get;
    }
    bool CanSaveToMIU
    {
      get;
    }
    bool IsPrebillAdjusted
    {
      get;
    }
    bool IsPostbillAdjusted
    {
      get;
    }
    bool IsAtLeastOneChildAdjusted
    {
      get;
    }

    IServiceDefinition ServiceDefinition
    {
      get;
    }

    IMTProperties AccountIdentifiers
    {
      get;
    }
    bool IdentifiedByAccount
    {
      get;
    }
    bool IdentifiedByAccountExternalID
    {
      get;
    }
    bool IdentifiedByAccountInternalID
    {
      get;
    }

    int PriceableItemTypeID
    {
      get;
    }
    int PriceableItemTemplateID
    {
      get;
    }
    long SessionID
    {
      get;
      set;
    }
    string SessionUID
    {
      get;
      set;
    }
    int ServiceEndpointID
    {
      get;
      set;
    }
    int AccountID
    {
      get;
      set;
    }
    int OriginalPayerID
    {
      get;
    }
    IReasonCode ReasonCode
    {
      get;
      set;
    }
    string Description
    {
      get;
      set;
    }
    IAdjustmentType AdjustmentType
    {
      get;
    }
    IAdjustment AdjustmentTemplate
    {
      get;
    }
    Hashtable UsageRecord
    {
      get;
    }

    bool IsComplete();

    MetraTech.Interop.GenericCollection.IMTCollection
      GetApplicableReasonCodes();

    MetraTech.Interop.Rowset.IMTRowSet Save(object aProgressObject);
    MetraTech.Interop.Rowset.IMTRowSet SaveAsynchronously(object aProgressObject);

    MetraTech.Interop.Rowset.IMTRowSet SaveToMIU(object aProgressObject);
    MetraTech.Interop.Rowset.IMTRowSet SaveToMIUAsynchronously(object aProgressObject);

  }
  [Guid("930c03f5-4d97-47fa-9577-a3786f62540f")]
  [ClassInterface(ClassInterfaceType.None)]
  public class RebillTransaction : IRebillTransaction
  {
    public RebillTransaction(MetraTech.Interop.MTProductCatalog.IMTSessionContext aCTX)
    {
      mMeterRS = null;
      mCtx = aCTX;
      mAccountID = -1;
      mbUnknownAccount = false;
      mOriginalPayerID = -1;
      mAdjustmentType = null;
      mUsageRecord = new Hashtable();
      //mRebillWriter = new AsyncRebillWrapper();
    }

    public MetraTech.Interop.Rowset.IMTRowSet SaveToMIU(object aProgressObject)
    {
      mbUnknownAccount = true;
      return Save(aProgressObject);
    }

    public MetraTech.Interop.Rowset.IMTRowSet SaveToMIUAsynchronously(object aProgressObject)
    {
      mbUnknownAccount = true;
      return Save(aProgressObject);
    }

    public Hashtable UsageRecord
    {
      get { return mUsageRecord; }
    }

    public void SetUsageRecord(Hashtable record)
    {
      mUsageRecord = record;
    }
    public MetraTech.Interop.Rowset.IMTRowSet SaveAsynchronously(object aProgressObject)
    {
      return Save(aProgressObject);
    }
    [MTAThread]
    public MetraTech.Interop.Rowset.IMTRowSet Save(object aProgressObject)
    {

      string capname = "Apply Adjustments";
      uint MTAUTH_ACCESS_DENIED = 0xE29F0001;
      MTAuditEntityType entity = MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT;

      //Determine if the caller can perform "Apply Adjustments" operation
      MetraTech.Interop.MTAuthExec.IMTCompositeCapabilityTypeReader capReader =
        new MetraTech.Interop.MTAuthExec.MTCompositeCapabilityTypeReaderClass();
      //CR 13827 - check CanRebill flag and throw exception if it's not set.
      /*
       *-- Can not Rebill transactions:
        -- 1. If they are child transactions
        -- 2. in soft closed interval
        -- 3. If transaction is Prebill and it (or it's children) have already been adjusted (need to delete adjustments first)
        -- 4. If transaction is Postbill and it (or it's children) have already been adjusted (need to delete adjustments first)
        --    Above case will take care of possibility of someone trying to do PostBill rebill over and over again.
       * 
       * */
      if (mbCanRebill == false)
        throw new AdjustmentException(@"Session cannot be reassigned. Some of the possible reasons are: " +
          "transaction has been adjusted or already reassigned, usage interval is in soft close state, or transaction is a child of a multipoint transaction.");
      MetraTech.Interop.MTAuth.IMTCompositeCapability requiredCap =
        ((MetraTech.Interop.MTAuth.IMTCompositeCapabilityType)capReader.GetByName(capname)).CreateInstance();
      //MTDecimalCapability atomic = (MTDecimalCapability)requiredCap.GetAtomicDecimalCapability();
      MetraTech.Interop.MTAuth.MTAtomicCapabilityClass atomic = (MetraTech.Interop.MTAuth.MTAtomicCapabilityClass)requiredCap.GetAtomicDecimalCapability();
      if (atomic == null)
        throw new AdjustmentException("ApplyAdjustmentsCapability is missing atomic decimal capability!");
      MetraTech.Interop.MTAuth.MTAtomicCapabilityClass atomic1 = (MetraTech.Interop.MTAuth.MTAtomicCapabilityClass)requiredCap.GetAtomicEnumCapability();
      if (atomic1 == null)
        throw new AdjustmentException("ApplyAdjustmentsCapability is missing atomic enum capability!");
      MetraTech.Interop.MTAuth.IMTDecimalCapability decatomic = (MetraTech.Interop.MTAuth.IMTDecimalCapability)atomic;
      decimal trxamount = (decimal)UsageRecord["compoundprebilladjedamt"];
      decatomic.SetParameter(trxamount, MetraTech.Interop.MTAuth.MTOperatorType.OPERATOR_TYPE_EQUAL);

      MetraTech.Interop.MTAuth.IMTEnumTypeCapability enumatomic = (MetraTech.Interop.MTAuth.IMTEnumTypeCapability)atomic1;
      string sCurrency = System.Convert.ToString(UsageRecord["am_currency"]);
      enumatomic.SetParameter(sCurrency);


      MetraTech.Interop.MTAuth.IMTSecurityContext ctx = (MetraTech.Interop.MTAuth.IMTSecurityContext)mCtx.SecurityContext;
      //check Auth and audit failures
      try
      {
        ctx.CheckAccess(requiredCap);
      }
      catch (COMException ex)
      {
        if ((uint)ex.ErrorCode == MTAUTH_ACCESS_DENIED)
        {
          MTAuditEvent auditevent = IsPrebill ?
            MTAuditEvent.AUDITEVENT_PREBILL_REASSIGN_CREATE_DENIED :
            MTAuditEvent.AUDITEVENT_POSTBILL_REASSIGN_CREATE_DENIED;

          AdjustmentCache.GetInstance().GetAuditor().FireEvent
            (
            (int)auditevent,
            mCtx != null ? mCtx.AccountID : -1,
            (int)entity,
            TypeConverter.ConvertInteger(UsageRecord["id_acc"]),
            ""
            );
          throw;
        }
        throw;
      }


      IMTProductCatalog pcat = new MTProductCatalogClass();
      pcat.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)mCtx);
      IMTPriceableItemType pitype = pcat.GetPriceableItemType(PriceableItemTypeID);

      uint dummy = DBIDGenerator.GetInstance().NextID("adjustment");


      RebillWriter writer = new RebillWriter();

      if (IsPrebill)
      {
        RS.IMTRowSet rs = new RS.MTSQLRowsetClass();
        int rerunID = -1;
        rs = writer.CreatePrebillRebill
                    ((MetraTech.Interop.MTBillingReRun.IMTSessionContext)mCtx, this, pitype, out rerunID, aProgressObject);
        writer.FinalizePrebillRebill((MetraTech.Interop.MTBillingReRun.IMTSessionContext)mCtx, rerunID);
        return rs;
      }
      else
      {
        return writer.CreatePostbillRebill
          ((MetraTech.Interop.MTBillingReRun.IMTSessionContext)mCtx, this, pitype, aProgressObject);
      }
    }

    public bool IsPrebill
    {
      get { return mbIsPrebill; }
    }
    public bool CanSaveToMIU
    {
      //TODO: Are there any conditions
      //that would prevent MIU rebill
      get { return true; }
    }

    public bool IsPrebillAdjusted
    {
      get { return mbIsPrebillAdjusted; }
    }

    public bool IsPostbillAdjusted
    {
      get { return mbIsPostbillAdjusted; }
    }

    public bool IsAtLeastOneChildAdjusted
    {
      get { return mbKidsAdjusted; }
    }

    public IMTProperties AccountIdentifiers
    {
      get { return mAccIDs; }
    }
    public IMTProperties ServiceEndpointIdentifiers
    {
      get { throw new NotSupportedException("while calling get::ServiceEndpointIdentifiers: Service endpoints are no longer supported"); }
    }
    public IServiceDefinition ServiceDefinition
    {
      get { return mSD; }
    }
    public bool IdentifiedByServiceEndpoint
    {
      get
      {
        return false;
      }
    }
    public bool IdentifiedByAccount
    {
      get
      {
        return (mSD == null)
          ? false :
          mSD.IdentifiedByAccountExternalID |
          mSD.IdentifiedByAccountInternalID;
      }
    }
    public bool IdentifiedByAccountExternalID
    {
      get
      {
        return (mSD == null) ? false : mSD.IdentifiedByAccountExternalID;
      }
    }
    public bool IdentifiedByAccountInternalID
    {
      get
      {
        return (mSD == null) ? false : mSD.IdentifiedByAccountInternalID;
      }
    }


    public bool IsMIU
    {
      get
      {
        return mbUnknownAccount;
      }
    }
    public string SessionUID
    {
      get { return mSessionUID; }
      set { mSessionUID = value; }
    }
    public long SessionID
    {
      get { return mSessionID; }
      set { mSessionID = value; }
    }

    public int AccountID
    {
      get { return mAccountID; }
      set { mAccountID = value; }
    }
    public int OriginalPayerID
    {
      get { return mOriginalPayerID; }
      set { mOriginalPayerID = value; }
    }
    public int ServiceEndpointID
    {
      get { throw new NotSupportedException("while calling get::ServiceEndpointID: Service endpoints are no longer supported"); }
      set { throw new NotSupportedException("while calling set::ServiceEndpointID: Service endpoints are no longer supported"); }
    }
    public int PriceableItemTypeID
    {
      get { return mTypeID; }
    }
    public int PriceableItemTemplateID
    {
      get { return mPITemplateID; }
    }

    public IReasonCode ReasonCode
    {
      get { return mReasonCode; }
      set { mReasonCode = value; }
    }

    public string Description
    {
      get { return mDescription; }
      set { mDescription = value; }
    }

    public IAdjustmentType AdjustmentType
    {
      get { return mAdjustmentType; }
      set { mAdjustmentType = value; }
    }

    public IAdjustment AdjustmentTemplate
    {
      get { return mAJTemplate; }
      set { mAJTemplate = value; }
    }

    // Not on interface

    public void SetMeterRowset(MeterRowset meterrs)
    {
      mMeterRS = meterrs;
    }
    public void SetAccountIdentifiers(IMTProperties ids)
    {
      mAccIDs = ids;
    }
    public void SetSEIdentifiers(IMTProperties ids)
    {
      throw new NotSupportedException("while calling SetSEIdentifiers: Service endpoints are no longer supported");
    }
    public void SetTypeMappings(Hashtable aMappings)
    {
      mIdentifierTypeMappings = aMappings;
    }
    public Hashtable GetTypeMappings()
    {
      return mIdentifierTypeMappings;
    }
    public void SetPrebillFlag(bool flag)
    {
      mbIsPrebill = flag;
    }

    public void SetIsPrebillAdjustedFlag(bool flag)
    {
      mbIsPrebillAdjusted = flag;
    }
    public void SetIsPostbillAdjustedFlag(bool flag)
    {
      mbIsPostbillAdjusted = flag;
    }
    public void SetAdjustedKidsFlag(bool flag)
    {
      mbKidsAdjusted = flag;
    }
    public void SetPIType(int type)
    {
      mTypeID = type;
    }

    public void SetPITemplate(int template)
    {
      mPITemplateID = template;
    }

    public void SetSD(ServiceDefinition aSD)
    {
      mSD = aSD;
    }

    public MetraTech.Interop.GenericCollection.IMTCollection
      GetApplicableReasonCodes()
    {
      Debug.Assert(mAJTemplate != null);
      return mAJTemplate.GetApplicableReasonCodes();
    }

    public bool IsComplete()
    {
      //if(mRebillWriter == null) return true;
      //return mRebillWriter.IsComplete();
      return false;
    }

    /* CR 13827:
     * Can not Rebill transactions:
      1. If they are child transactions
      2. in soft closed interval
      3. If transaction is Prebill and it (or it's children) have already been adjusted (need to delete adjustments first)
      4. If transaction is Postbill and it (or it's children) have already been adjusted (need to delete adjustments first)
          Above case will take care of possibility of someone trying to do PostBill rebill over and over again.
    */
    private bool mbCanRebill;
    public bool CanRebill()
    {
      return mbCanRebill;
    }
    public void SetCanRebill(bool canRebill)
    {
      mbCanRebill = canRebill;
    }


    /*
        private IAdjustmentType GetRebillAdjustmentType(int aPITypeID)
        {
          IAdjustmentCatalog ac = new AdjustmentCatalog();
          ac.Initialize(mCtx);
          Coll.IMTCollection ajtypes = ac.GetAdjustmentTypes(aPITypeID);
          IAdjustmentType rebillType = null;
          foreach (IAdjustmentType ajtype in ajtypes)
          {
            if(ajtype.Kind == AdjustmentKind.REBILL)
            {
              rebillType = ajtype;
              break;
            }
          }
          if (rebillType == null)
            throw new AdjustmentException
              (String.Format("Unable To Find REBILL adjustment type for <{0}> PI Type", aPITypeID));

          return rebillType;

        }
        */


    private MeterRowset mMeterRS;
    bool mbIsPrebill;
    bool mbIsPrebillAdjusted;
    bool mbIsPostbillAdjusted;
    bool mbKidsAdjusted;
    private IMTProperties mAccIDs;
    private Hashtable mIdentifierTypeMappings;
    long mSessionID;
    string mSessionUID;
    private MetraTech.Interop.MTProductCatalog.IMTSessionContext mCtx;
    private int mTypeID;
    private int mAccountID;
    private int mPITemplateID;
    private int mOriginalPayerID;
    private IReasonCode mReasonCode;
    private string mDescription;
    private ServiceDefinition mSD;
    private IAdjustmentType mAdjustmentType;
    private IAdjustment mAJTemplate;
    private Hashtable mUsageRecord;
    //AsyncRebillWrapper mRebillWriter;
    public bool mbUnknownAccount;
  }
}

