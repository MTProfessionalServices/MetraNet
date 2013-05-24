using System;
using System.Collections;

//
using MetraTech.Interop.Rowset;
using System.Runtime.InteropServices;
using MetraTech.Interop.MTProductCatalog;
using System.Diagnostics;


namespace MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for AdjustmentTransaction.
  /// </summary>
  ///
  [Guid("adbbcbf0-627f-4716-b959-94ac86dcbbc8")]
  public interface IAdjustmentTransaction
  {
    long SessionID
    {
      get;set;
    }
    int IntervalID
    {
      get;set;
    }
    int CreatorAccountID
    {
      get;
    }
    int PayerAccountID
    {
      get;
    }

    string Currency
    {
      get;
    }
    Hashtable UsageRecord
    {
      get;
    }
    bool IsPrebill
    {
      get;set;
    }

    bool IsPrebillAdjusted
    {
      get;set;
    }
    bool IsPostbillAdjusted
    {
      get;set;
    }

    decimal PrebillAdjustmentAmount
    {
      get;set;
    }

    decimal PostbillAdjustmentAmount
    {
      get;set;
    }

    decimal OriginalTransactionAmount
    {
      get;set;
    }

    AdjustmentStatus Status
    {
      get;set;
    }
    IAdjustmentType AdjustmentType
    {
      get;set;
    }
  
    decimal TotalAdjustmentAmount
    {
      get;set;
    }

		decimal FederalTaxAdjustmentAmount
		{
			get;set;
		}
		decimal StateTaxAdjustmentAmount
		{
			get;set;
		}
		decimal CountyTaxAdjustmentAmount
		{
			get;set;
		}
		decimal LocalTaxAdjustmentAmount
		{
			get;set;
		}
		decimal OtherTaxAdjustmentAmount
		{
			get;set;
		}

		decimal TotalTaxAdjustmentAmount
		{
			get;
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
    bool IsAdjustable
    {
      get;set;
    }
    bool IsIntervalSoftClosed
    {
      get;set;
    }
		bool IsParentSession
		{
			get;
		}
		bool IsParentSessionPostbillRebilled
		{
			get;
		}
    
    /// <summary>
    /// Saves individual adjustment transaction
    /// Right now only support saving Orphan adjustments
    /// The rest are saved in bulk from AdjustmentTransactionSet
    /// </summary>
    void Save();

    string DivisionCurrency
    {
        get;
    }

    decimal DivisionAmount
    {
        get;
    }
  }

  [Guid("badf924b-4c65-431d-8d9f-256e39f831be")]
  [ClassInterface(ClassInterfaceType.None)]
  public class AdjustmentTransaction : IAdjustmentTransaction
  {
    public AdjustmentTransaction(IMTSessionContext aCTX)
    {
      mIntervalID = -1;
      mPayerAccountID = -1;
      mCtx = aCTX;
      mUsageRecord = new Hashtable();
      mbIsAdjustable = true;
      mbIsIntervalSoftClosed = false;
      mTotal = 0.0M;
      mPrebillTotal = 0.0M;
      mPostbillTotal = 0.0M;
      mStatus = AdjustmentStatus.NOT_ADJUSTED;
      mAdjustmentType = null;
      mCurrency = string.Empty;
      mDescription = string.Empty;
    }
    public long SessionID
    {
      get { return mSessionID; }
      set { mSessionID = value; }
    }
    public int IntervalID
    {
      get { return mIntervalID; }
      set { mIntervalID = value; }
    }
    public int CreatorAccountID
    {
      get { return mCtx.AccountID; }
      set { mCtx.AccountID = value; }
    }

    public int PayerAccountID
    {
      get { return mPayerAccountID; }
      set { mPayerAccountID = value; }
    }

    public string Currency
    {
      get { return mCurrency; }
      set { mCurrency = value; }
    }


    public bool IsPrebill
    {
      get{return mbIsPrebill;}
      set{mbIsPrebill = value;}
    }
    
    public bool IsPrebillAdjusted
    {
      get{return mbIsPrebillAdjusted;}
      set{mbIsPrebillAdjusted = value;}
    }
    public bool IsPostbillAdjusted
    {
      get{return mbIsPostbillAdjusted;}
      set{mbIsPostbillAdjusted = value;}
    }

    public decimal TotalAdjustmentAmount
    {
      get{return mTotal;}
      set{mTotal = value;}
    }

		private decimal mFederalTaxAdjustmentAmount = 0.0M;
		public decimal FederalTaxAdjustmentAmount
		{
			get{return mFederalTaxAdjustmentAmount;}
			set{mFederalTaxAdjustmentAmount = value;}
		}
		private decimal mStateTaxAdjustmentAmount = 0.0M;
		public decimal StateTaxAdjustmentAmount
		{
			get{return mStateTaxAdjustmentAmount;}
			set{mStateTaxAdjustmentAmount = value;}
		}
		private decimal mCountyTaxAdjustmentAmount = 0.0M;
		public decimal CountyTaxAdjustmentAmount
		{
			get{return mCountyTaxAdjustmentAmount;}
			set{mCountyTaxAdjustmentAmount = value;}
		}
		private decimal mLocalTaxAdjustmentAmount = 0.0M;
		public decimal LocalTaxAdjustmentAmount
		{
			get{return mLocalTaxAdjustmentAmount;}
			set{mLocalTaxAdjustmentAmount = value;}
		}
		private decimal mOtherTaxAdjustmentAmount = 0.0M;
		public decimal OtherTaxAdjustmentAmount
		{
			get{return mOtherTaxAdjustmentAmount;}
			set{mOtherTaxAdjustmentAmount = value;}
		}

		public decimal TotalTaxAdjustmentAmount
		{
			get
			{
				return	FederalTaxAdjustmentAmount + 
								StateTaxAdjustmentAmount +
								CountyTaxAdjustmentAmount + 
								LocalTaxAdjustmentAmount + 
								OtherTaxAdjustmentAmount;
			}
		}



    
    public decimal PrebillAdjustmentAmount
    {
      get{return mPrebillTotal;}
      set{mPrebillTotal = value;}
    }
    
    public decimal PostbillAdjustmentAmount
    {
      get{return mPostbillTotal;}
      set{mPostbillTotal = value;}
    }

    public decimal OriginalTransactionAmount
    {
      get{return mOriginalTransactionAmount;}
      set{mOriginalTransactionAmount = value;}
    }

    public Hashtable UsageRecord
    {
      get { return mUsageRecord; }
    }
    public IMTProperties Inputs
    {
      get {return mInputs;}
      set 
      {
        mInputs = CloneProperties(value);
      }
    }
    public IMTProperties Outputs
    {
      get {return mOutputs;}
      set 
      {
        mOutputs = CloneProperties(value);
      }
    }
    public string Description
    {
      get { return mDescription; }
      set { mDescription = value; }
    }
    
    public IReasonCode ReasonCode
    {
      get { return mReasonCode; }
      set { mReasonCode = value; }
    }

    public IAdjustmentType AdjustmentType
    {
      get { return mAdjustmentType; }
      set { mAdjustmentType = value; }
    }
    
    public AdjustmentStatus Status
    {
      get { return mStatus; }
      set { mStatus = value; }
    }

		private bool mParentSession;
		public bool IsParentSession
		{
			get { return mParentSession; }
			set { mParentSession = value; }
		}

		private bool mIsParentSessionPostbillRebilled;
		public bool IsParentSessionPostbillRebilled
		{
			get { return mIsParentSessionPostbillRebilled; }
			set { mIsParentSessionPostbillRebilled = value; }
		}

	
    //NON interface methods
    public void SetUsageRecord(Hashtable record)
    {
      mUsageRecord = record;
    }

    public bool IsAdjustable
    {
      get
      {
        return mbIsAdjustable;
      }
      set
      {
        mbIsAdjustable = value;
      }
    }
    public bool IsIntervalSoftClosed
    {
      get
      {
        return mbIsIntervalSoftClosed;
      }
      set
      {
        mbIsIntervalSoftClosed = value;
      }
    }

    //there is no way to clone properties other then below
    private IMTProperties CloneProperties(IMTProperties source)
    {
      IMTProperties propPtr = new MTPropertiesClass();

      System.Collections.IEnumerator it = source.GetEnumerator();
      while(it.MoveNext())
      {
        IMTProperty curprop = (IMTProperty)it.Current;
        MTPropertyMetaData ptempMetaData = curprop.GetMetaData();
        propPtr.Add(ptempMetaData);
        ((IMTProperty)propPtr[ptempMetaData.Name]).Value = curprop.Value; 
      }
      return propPtr;
    }

    public void Save()
    {
      int e_notimpl = -2147467263; //0x80004001
      throw new COMException("not implemented", e_notimpl);
    }

    public string DivisionCurrency
    {
        get { return mDivisionCurrency; }
        set { mDivisionCurrency = value; }
    }

    public decimal DivisionAmount
    {
        get { return mDivisionAmount; }
        set { mDivisionAmount = value; }
    }

    private long mSessionID;
    private int mIntervalID;
    private int mPayerAccountID;
    private IMTSessionContext mCtx;
    private System.Collections.Hashtable mUsageRecord;
    private IMTProperties mInputs;
    private IMTProperties mOutputs;
    private IAdjustmentType mAdjustmentType;
    private bool mbIsPrebill;
    private bool mbIsPrebillAdjusted;
    private bool mbIsPostbillAdjusted;
    private bool mbIsAdjustable;
    private bool mbIsIntervalSoftClosed;
    
    private string mDescription;
    private decimal mOriginalTransactionAmount;
    private decimal mPrebillTotal;
    private decimal mPostbillTotal;
    private decimal mTotal;
    AdjustmentStatus mStatus;
    IReasonCode mReasonCode;
    private string mCurrency;
    private string mDivisionCurrency = null;
    private decimal mDivisionAmount = 0;
  }
  internal struct TransactionInfo
  {
    internal TransactionInfo(int aTrxID)
    {
      TrxID = aTrxID;
      PITemplateID = PITypeID = ServiceID = 0;
      SessionID = 0;
      AJTypeID = AJTemplateID = AJInstanceID = 0;
      IsPrebill = IsPrebillAdjusted = IsPostbillAdjusted = false;
      UID = "";
    }
    public int PITemplateID;
    public int PITypeID;
    public int AJTypeID;
    public int AJTemplateID;
    public int AJInstanceID;
    public int ServiceID;
    public bool IsPrebill;
    public bool IsPrebillAdjusted;
    public bool IsPostbillAdjusted;
    public string UID;
    public int TrxID;
    public long SessionID;
  }
}

