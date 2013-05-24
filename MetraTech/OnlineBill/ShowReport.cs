using System.Runtime.InteropServices;
using System.Globalization;
using System;
using System.Collections;
using System.Text;
using System.Diagnostics;
using CodeProject.Collections;

[assembly: GuidAttribute("66ef0e82-b653-4c3b-80a0-53230348c12b")]
namespace MetraTech.OnlineBill
{
	using MetraTech.Interop.MTHierarchyReports;
	using MetraTech;
	using MetraTech.DataAccess;
	using MetraTech.DataAccess.MaterializedViews;
	using MetraTech.Performance;
  using System.Web;

  #region Interfaces

  //interfaces
	[Guid("01188a44-f0ad-4e64-b27e-9e7d899a8ab8")]
	public interface IProductOffering
	{
		string Amount{get;set;}
		string Currency{get;set;}
		string ID{get;set;}
		IEnumerable Charges{get;}
		int ChargesCount{get;}
		void AddCharge(Charge charge);
	}

	[Guid("f1d982b7-8535-4686-a7dd-54d877b2785c")]
	public interface ICharge
	{
		string Amount{get;set;}
		decimal AmountAsDecimal{get;set;}
    string PostBillAdjustmentAmount{get;set;}
    decimal PostBillAdjustmentAmountAsDecimal{get;set;}
    string PreBillAdjustmentAmount{get;set;}
    decimal PreBillAdjustmentAmountAsDecimal{get;set;}
		string PostBillAdjustedAmount{get;set;}
		decimal PostBillAdjustedAmountAsDecimal{get;set;}
		string PreBillAdjustedAmount{get;set;}
		decimal PreBillAdjustedAmountAsDecimal{get;set;}
		string Tax{get;set;}
		decimal TaxAsDecimal{get;set;}
		string FederalTax{get;set;}
		decimal FederalTaxAsDecimal{get;set;}
		string StateTax{get;set;}
		decimal StateTaxAsDecimal{get;set;}
		string CountyTax{get;set;}
		decimal CountyTaxAsDecimal{get;set;}
		string LocalTax{get;set;}
		decimal LocalTaxAsDecimal{get;set;}
		string OtherTax{get;set;}
		decimal OtherTaxAsDecimal{get;set;}
		string DisplayAmount{get;set;}
        decimal DisplayAmountAsDecimal{ get; set; }
		string Currency{get;set;}
		string ID{get;set;}
		bool IsAggregate{get;set;}
		IViewSlice ViewSlice{get;set;}
		IEnumerable SubCharges{get;}
		int SubChargesCount{get;}
		void AddSubCharge(Charge charge);
    string PreAndPostBillTotalTaxAdjustmentAmount{get;}
    decimal PreAndPostBillTotalTaxAdjustmentAmountAsDecimal{get;}
		string PreBillTotalTaxAdjustmentAmount{get;set;}
		decimal PreBillTotalTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillFederalTaxAdjustmentAmount{get;set;}
		decimal PreBillFederalTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillStateTaxAdjustmentAmount{get;set;}
		decimal PreBillStateTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillCountyTaxAdjustmentAmount{get;set;}
		decimal PreBillCountyTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillLocalTaxAdjustmentAmount{get;set;}
		decimal PreBillLocalTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillOtherTaxAdjustmentAmount{get;set;}
		decimal PreBillOtherTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillTotalTaxAdjustmentAmount{get;set;}
		decimal PostBillTotalTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillFederalTaxAdjustmentAmount{get;set;}
		decimal PostBillFederalTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillStateTaxAdjustmentAmount{get;set;}
		decimal PostBillStateTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillCountyTaxAdjustmentAmount{get;set;}
		decimal PostBillCountyTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillLocalTaxAdjustmentAmount{get;set;}
		decimal PostBillLocalTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillOtherTaxAdjustmentAmount{get;set;}
		decimal PostBillOtherTaxAdjustmentAmountAsDecimal{get;set;}
		
	}

	[Guid("679cc968-966b-4de1-a8e0-4cc37582c599")]
	public interface ILevel
	{
		string ID{get;set;}
		string CacheID{get;set;}
		int AccountID{get;set;}
		IDateRangeSlice AccountEffectiveDate{get;set;}
		IAccountSlice AccountSlice{get;set;}
		bool IsOpen{get;set;}
		string Amount{get;set;}
		decimal AmountAsDecimal{get;set;}
		string Currency{get;set;}
		int NumTransactions{get;set;}
    string PreBillAdjustmentDisplayAmount{get;}
    decimal PreBillAdjustmentDisplayAmountAsDecimal{get;}
    string PostBillAdjustmentAmount{get;set;}
    decimal PostBillAdjustmentAmountAsDecimal{get;set;}
    string PreBillAdjustmentAmount{get;set;}
    decimal PreBillAdjustmentAmountAsDecimal{get;set;}
		string PostBillAdjustedAmount{get;set;}
		decimal PostBillAdjustedAmountAsDecimal{get;set;}
		string PreBillAdjustedAmount{get;set;}
		decimal PreBillAdjustedAmountAsDecimal{get;set;}
		int NumPreBillAdjustments{get;set;}
		int NumPostBillAdjustments{get;set;}
    string PreAndPostBillTotalTaxAdjustmentAmount{get;}
    decimal PreAndPostBillTotalTaxAdjustmentAmountAsDecimal{get;}
		string PreBillTotalTaxAdjustmentAmount{get;set;}
		decimal PreBillTotalTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillFederalTaxAdjustmentAmount{get;set;}
		decimal PreBillFederalTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillStateTaxAdjustmentAmount{get;set;}
		decimal PreBillStateTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillCountyTaxAdjustmentAmount{get;set;}
		decimal PreBillCountyTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillLocalTaxAdjustmentAmount{get;set;}
		decimal PreBillLocalTaxAdjustmentAmountAsDecimal{get;set;}
		string PreBillOtherTaxAdjustmentAmount{get;set;}
		decimal PreBillOtherTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillTotalTaxAdjustmentAmount{get;set;}
		decimal PostBillTotalTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillFederalTaxAdjustmentAmount{get;set;}
		decimal PostBillFederalTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillStateTaxAdjustmentAmount{get;set;}
		decimal PostBillStateTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillCountyTaxAdjustmentAmount{get;set;}
		decimal PostBillCountyTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillLocalTaxAdjustmentAmount{get;set;}
		decimal PostBillLocalTaxAdjustmentAmountAsDecimal{get;set;}
		string PostBillOtherTaxAdjustmentAmount{get;set;}
		decimal PostBillOtherTaxAdjustmentAmountAsDecimal{get;set;}
		
		string Tax{get;set;}
		decimal TaxAsDecimal{get;set;}
		string FederalTax{get;set;}
		decimal FederalTaxAsDecimal{get;set;}
		string StateTax{get;set;}
		decimal StateTaxAsDecimal{get;set;}
		string CountyTax{get;set;}
		decimal CountyTaxAsDecimal{get;set;}
		string LocalTax{get;set;}
		decimal LocalTaxAsDecimal{get;set;}
		string OtherTax{get;set;}
		decimal OtherTaxAsDecimal{get;set;}
		string TaxedAmount{get;set;}
		IAccountSlice AccountSummarySlice{get;set;}
		IDateRangeSlice TimeSlice{get;set;}
		IEnumerable SubLevels{get;}
		IEnumerable Charges{get;}
		IEnumerable ProductOfferings{get;}
		int ProductOfferingsCount{get;}
		Level GetChild(int number);
		void InitializeSubLevels(ArrayList children);
		void InitializeCharges(ArrayList charges);
		void InitializeProductOfferings(ArrayList pos);
		string DisplayAmount{get;set;}
		decimal DisplayAmountAsDecimal{get;set;}
		string TotalDisplayAmount{get;set;}
		decimal TotalDisplayAmountAsDecimal{get;set;}
		
		bool Root{get;}
	}

	[Guid("c291ebc3-e646-4bda-9e43-1f31b872d434")]
	public interface IReportManager
	{
		void Initialize(string path);
		ITimeSlice TimeSlice{get;set;}
		int LanguageID{get;set;}
		Level Root{get;}
    MPS_VIEW_TYPE ViewType{get;}
    bool ShowSecondPass{get;}
    bool IsEstimate{get;}
		void OpenLevelByID(string id);
		void CloseLevelByID(string id);
		void OpenLevel(Level node);
		void CloseLevel(Level node);
		ITimeSlice GetCombinedTimeSlice(ITimeSlice timeSliceIn);
		void InitializeReport(	MetraTech.Interop.MTYAAC.IMTYAAC yaac, 
			ITimeSlice timeSlice, int viewType, 
			bool showSecondPass, bool estimate,
			IMPSReportInfo reportInfo, int languageID
			);
		IMPSReportInfo ReportInfo {get;}
		
	}

	[Guid("fe4784c1-af6d-42f3-a187-314b93c3dba6")]
	public interface IShowReport
	{
		void Setup(string culture);
		void WriteCurrency();
		int TickCount{get;}
	}
  #endregion

  #region ProductOffering Class
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("326a194e-c8a5-413c-ae3b-68bbdb3f4570")]
	public class ProductOffering : IProductOffering
	{
		public string Amount
		{
			get
			{ return mAmount; }
			set
			{ mAmount = value; }
		}

		public string Currency
		{
			get
			{ return mCurrency; }
			set
			{ mCurrency = value; }
		}

		public string ID
		{
			get
			{ return mID; }
			set
			{ mID = value; }
		}

		public IEnumerable Charges
		{
			get
			{ return mCharges; }
		}

    public int ChargesCount
    {
      get
      {
				Debug.Assert(mCharges != null);
				return mCharges.Count;
			}
    }

		public void AddCharge(Charge charge)
		{
			mCharges.Add(charge);
		}

		private string mAmount;
		private string mID;
		private string mCurrency;
		private ArrayList mCharges = new ArrayList();
	}
#endregion

  #region Charge Class
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("bc44ad9d-24dc-4c8e-842e-8ac24e8dd5f2")]
	public class Charge : ICharge
	{
		public string Amount
		{
			get
			{ return mAmount; }
			set
			{ mAmount = value; }
		}
		public decimal AmountAsDecimal
		{
			get
			{ return mAmountAsDecimal; }
			set
			{ mAmountAsDecimal = value; }
		}

		public string DisplayAmount
		{
			get
			{ return mDisplayAmount; }
			set
			{ mDisplayAmount = value; }
		}

		public decimal DisplayAmountAsDecimal
		{
			get
			{ return mDisplayAmountAsDecimal; }
			set
			{ mDisplayAmountAsDecimal = value; }
		}

    public string PostBillAdjustmentAmount
    {
      get { return mPostBillAdjustmentAmount; }
      set { mPostBillAdjustmentAmount = value; }
    }

    public decimal PostBillAdjustmentAmountAsDecimal
    {
      get { return mPostBillAdjustmentAmountAsDecimal; }
      set { mPostBillAdjustmentAmountAsDecimal = value; }
    }

    public string PreBillAdjustmentAmount
    {
      get { return mPreBillAdjustmentAmount; }
      set { mPreBillAdjustmentAmount = value; }
    }

    public decimal PreBillAdjustmentAmountAsDecimal
    {
      get { return mPreBillAdjustmentAmountAsDecimal; }
      set { mPreBillAdjustmentAmountAsDecimal = value; }
    }

		public string PostBillAdjustedAmount
		{
			get
			{ return mPostBillAmount; }
			set
			{ mPostBillAmount = value; }
		}

		public decimal PostBillAdjustedAmountAsDecimal
		{
			get
			{ return mPostBillBillAmountAsDecimal; }
			set
			{ mPostBillBillAmountAsDecimal = value; }
		}

		private string mPreBillTotalTaxAdjustmentAmount;
		public string PreBillTotalTaxAdjustmentAmount
		{
			get
			{ return mPreBillTotalTaxAdjustmentAmount; }
			set
			{ mPreBillTotalTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillTotalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillTotalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillTotalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillTotalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillFederalTaxAdjustmentAmount;
		public string PreBillFederalTaxAdjustmentAmount
		{
			get
			{ return mPreBillFederalTaxAdjustmentAmount; }
			set
			{ mPreBillFederalTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillFederalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillFederalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillFederalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillFederalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillStateTaxAdjustmentAmount;
		public string PreBillStateTaxAdjustmentAmount
		{
			get
			{ return mPreBillStateTaxAdjustmentAmount; }
			set
			{ mPreBillStateTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillStateTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillStateTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillStateTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillStateTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillCountyTaxAdjustmentAmount;
		public string PreBillCountyTaxAdjustmentAmount
		{
			get
			{ return mPreBillCountyTaxAdjustmentAmount; }
			set
			{ mPreBillCountyTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillCountyTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillCountyTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillCountyTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillCountyTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillLocalTaxAdjustmentAmount;
		public string PreBillLocalTaxAdjustmentAmount
		{
			get
			{ return mPreBillLocalTaxAdjustmentAmount; }
			set
			{ mPreBillLocalTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillLocalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillLocalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillLocalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillLocalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillOtherTaxAdjustmentAmount;
		public string PreBillOtherTaxAdjustmentAmount
		{
			get
			{ return mPreBillOtherTaxAdjustmentAmount; }
			set
			{ mPreBillOtherTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillOtherTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillOtherTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillOtherTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillOtherTaxAdjustmentAmountAsDecimal = value; }
		}

    public string PreAndPostBillTotalTaxAdjustmentAmount
    {
      get { return String.Format("{0}", mPreBillTotalTaxAdjustmentAmountAsDecimal + mPostBillTotalTaxAdjustmentAmountAsDecimal); }
    }

    public decimal PreAndPostBillTotalTaxAdjustmentAmountAsDecimal
    {
      get { return mPreBillTotalTaxAdjustmentAmountAsDecimal + mPostBillTotalTaxAdjustmentAmountAsDecimal; }
    }

		private string mPostBillTotalTaxAdjustmentAmount;
		public string PostBillTotalTaxAdjustmentAmount
		{
			get
			{ return mPostBillTotalTaxAdjustmentAmount; }
			set
			{ mPostBillTotalTaxAdjustmentAmount = value; }
		}

		private decimal mPostBillTotalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillTotalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillTotalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillTotalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillFederalTaxAdjustmentAmount;
		public string PostBillFederalTaxAdjustmentAmount
		{
			get
			{ return mPostBillFederalTaxAdjustmentAmount; }
			set
			{ mPostBillFederalTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillFederalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillFederalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillFederalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillFederalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillStateTaxAdjustmentAmount;
		public string PostBillStateTaxAdjustmentAmount
		{
			get
			{ return mPostBillStateTaxAdjustmentAmount; }
			set
			{ mPostBillStateTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillStateTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillStateTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillStateTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillStateTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillCountyTaxAdjustmentAmount;
		public string PostBillCountyTaxAdjustmentAmount
		{
			get
			{ return mPostBillCountyTaxAdjustmentAmount; }
			set
			{ mPostBillCountyTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillCountyTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillCountyTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillCountyTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillCountyTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillLocalTaxAdjustmentAmount;
		public string PostBillLocalTaxAdjustmentAmount
		{
			get
			{ return mPostBillLocalTaxAdjustmentAmount; }
			set
			{ mPostBillLocalTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillLocalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillLocalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillLocalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillLocalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillOtherTaxAdjustmentAmount;
		public string PostBillOtherTaxAdjustmentAmount
		{
			get
			{ return mPostBillOtherTaxAdjustmentAmount; }
			set
			{ mPostBillOtherTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillOtherTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillOtherTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillOtherTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillOtherTaxAdjustmentAmountAsDecimal = value; }
		}

		public string PreBillAdjustedAmount
		{
			get
			{ return mPreBillBillAmount; }
			set
			{ mPreBillBillAmount = value; }
		}

		public decimal PreBillAdjustedAmountAsDecimal
		{
			get
			{ return mPreBillBillAmountAsDecimal; }
			set
			{ mPreBillBillAmountAsDecimal = value; }
		}
		public string Tax
		{
			get
			{ return mTax; }
			set
			{ mTax = value; }
		}
		public decimal TaxAsDecimal
		{
			get
			{ return mTaxAsDecimal; }
			set
			{ mTaxAsDecimal = value; }
		}

		public string FederalTax
		{
			get
			{ return mFederalTax; }
			set
			{ mFederalTax = value; }
		}
		public decimal FederalTaxAsDecimal
		{
			get
			{ return mFederalTaxAsDecimal; }
			set
			{ mFederalTaxAsDecimal = value; }
		}

		public string StateTax
		{
			get
			{ return mStateTax; }
			set
			{ mStateTax = value; }
		}
		public decimal StateTaxAsDecimal
		{
			get
			{ return mStateTaxAsDecimal; }
			set
			{ mStateTaxAsDecimal = value; }
		}

		public string CountyTax
		{
			get
			{ return mCountyTax; }
			set
			{ mCountyTax = value; }
		}
		public decimal CountyTaxAsDecimal
		{
			get
			{ return mCountyTaxAsDecimal; }
			set
			{ mCountyTaxAsDecimal = value; }
		}

		public string LocalTax
		{
			get
			{ return mLocalTax; }
			set
			{ mLocalTax = value; }
		}
		public decimal LocalTaxAsDecimal
		{
			get
			{ return mLocalTaxAsDecimal; }
			set
			{ mLocalTaxAsDecimal = value; }
		}

		public string OtherTax
		{
			get
			{ return mOtherTax; }
			set
			{ mOtherTax = value; }
		}
		public decimal OtherTaxAsDecimal
		{
			get
			{ return mOtherTaxAsDecimal; }
			set
			{ mOtherTaxAsDecimal = value; }
		}

		public string Currency
		{
			get
			{ return mCurrency; }
			set
			{ mCurrency = value; }
		}

		public string ID
		{
			get
			{ return mID; }
			set
			{ mID = value; }
		}

		public bool IsAggregate
		{
			get
			{ return mAggregate; }
			set
			{ mAggregate = value; }
		}

		public IViewSlice ViewSlice
		{
			get
			{ return mViewSlice; }
			set
			{ mViewSlice = value; }
		}

		public IEnumerable SubCharges
		{
			get
			{ return mSubCharges; }
		}

    public int SubChargesCount
    {
      get
      {
				Debug.Assert(mSubCharges != null);
				return mSubCharges.Count;
			}
    }

		public void AddSubCharge(Charge charge)
		{
			mSubCharges.Add(charge);
		}

    // Who thought it was a good idea to locate private memebers
    // so far away from the properties they are associated with?
    // When somebody has time I hope they move them back to their home...
		private string mAmount;
		private string mDisplayAmount;
		private decimal mAmountAsDecimal;
		private decimal mDisplayAmountAsDecimal;
    private string mPostBillAdjustmentAmount;
    private decimal mPostBillAdjustmentAmountAsDecimal;
    private string mPreBillAdjustmentAmount;
    private decimal mPreBillAdjustmentAmountAsDecimal;
		private string mPostBillAmount;
		private decimal mPostBillBillAmountAsDecimal;
		private string mPreBillBillAmount;
		private decimal mPreBillBillAmountAsDecimal;
		private string mTax;
		private decimal mTaxAsDecimal;
		private string mFederalTax;
		private decimal mFederalTaxAsDecimal;
		private string mStateTax;
		private decimal mStateTaxAsDecimal;
		private string mCountyTax;
		private decimal mCountyTaxAsDecimal;
		private string mLocalTax;
		private decimal mLocalTaxAsDecimal;
		private string mOtherTax;
		private decimal mOtherTaxAsDecimal;
		
		private string mID;
		private string mCurrency;
		private bool mAggregate;
		private ArrayList mSubCharges = new ArrayList();
		private IViewSlice mViewSlice;
	}
  #endregion

  #region Level Class
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("f7d766db-51f6-4060-808a-7b9cefca5347")]
	public class Level : ILevel
	{
		public Level() : this(false)
		{
		}
		internal Level(bool bRootLevel)
		{
			mRoot = bRootLevel;
		}
		

		public void Copy(Level other)
		{
			ID = other.ID;
			CacheID = other.CacheID;
			AccountID = other.AccountID;
			AccountEffectiveDate = other.AccountEffectiveDate;
			AccountSlice = other.AccountSlice;
			IsOpen = other.IsOpen;
			Amount = other.Amount;
			AmountAsDecimal = other.AmountAsDecimal;
			DisplayAmount = other.DisplayAmount;
			DisplayAmountAsDecimal = other.DisplayAmountAsDecimal;
			TotalDisplayAmount = other.TotalDisplayAmount;
			TotalDisplayAmountAsDecimal = other.TotalDisplayAmountAsDecimal;
			Currency = other.Currency;
			NumTransactions = other.NumTransactions;
      PreBillAdjustmentDisplayAmount = other.PreBillAdjustmentDisplayAmount;
      PreBillAdjustmentDisplayAmountAsDecimal = other.PreBillAdjustmentDisplayAmountAsDecimal;
			PostBillAdjustedAmount = other.PostBillAdjustedAmount;
			PostBillAdjustedAmountAsDecimal = other.PostBillAdjustedAmountAsDecimal;
			PreBillAdjustedAmount = other.PreBillAdjustedAmount;
			PreBillAdjustedAmountAsDecimal = other.PreBillAdjustedAmountAsDecimal;
			NumPreBillAdjustments = other.NumPreBillAdjustments;
			NumPostBillAdjustments = other.NumPostBillAdjustments;
			PreBillAdjustmentAmount = other.PreBillAdjustmentAmount;
			PreBillAdjustmentAmountAsDecimal = other.PreBillAdjustmentAmountAsDecimal;
			PostBillAdjustmentAmount = other.PostBillAdjustmentAmount;
			PostBillAdjustmentAmountAsDecimal = other.PostBillAdjustmentAmountAsDecimal;
			Tax = other.Tax;
			TaxAsDecimal = other.TaxAsDecimal;
			FederalTax = other.FederalTax;
			FederalTaxAsDecimal = other.FederalTaxAsDecimal;
			StateTax = other.StateTax;
			StateTaxAsDecimal = other.StateTaxAsDecimal;
			CountyTax = other.CountyTax;
			CountyTaxAsDecimal = other.CountyTaxAsDecimal;
			LocalTax = other.LocalTax;
			LocalTaxAsDecimal = other.LocalTaxAsDecimal;
			OtherTax = other.OtherTax;
			OtherTaxAsDecimal = other.OtherTaxAsDecimal;
			TaxedAmount = other.TaxedAmount;
			AccountSummarySlice = other.AccountSummarySlice;
			TimeSlice = other.TimeSlice;
			PreBillTotalTaxAdjustmentAmountAsDecimal = other.PreBillTotalTaxAdjustmentAmountAsDecimal;
			PreBillTotalTaxAdjustmentAmount = other.PreBillTotalTaxAdjustmentAmount;
			PreBillFederalTaxAdjustmentAmountAsDecimal = other.PreBillFederalTaxAdjustmentAmountAsDecimal;
			PreBillFederalTaxAdjustmentAmount = other.PreBillFederalTaxAdjustmentAmount;
			PreBillStateTaxAdjustmentAmountAsDecimal = other.PreBillStateTaxAdjustmentAmountAsDecimal;
			PreBillStateTaxAdjustmentAmount = other.PreBillStateTaxAdjustmentAmount;
			PreBillCountyTaxAdjustmentAmountAsDecimal = other.PreBillCountyTaxAdjustmentAmountAsDecimal;
			PreBillCountyTaxAdjustmentAmount = other.PreBillCountyTaxAdjustmentAmount;
			PreBillLocalTaxAdjustmentAmountAsDecimal = other.PreBillLocalTaxAdjustmentAmountAsDecimal;
			PreBillLocalTaxAdjustmentAmount = other.PreBillLocalTaxAdjustmentAmount;
			PreBillOtherTaxAdjustmentAmountAsDecimal = other.PreBillOtherTaxAdjustmentAmountAsDecimal;
			PreBillOtherTaxAdjustmentAmount = other.PreBillOtherTaxAdjustmentAmount;
			PostBillTotalTaxAdjustmentAmount = other.PostBillTotalTaxAdjustmentAmount;
			PostBillTotalTaxAdjustmentAmountAsDecimal = other.PostBillTotalTaxAdjustmentAmountAsDecimal;
			PostBillFederalTaxAdjustmentAmountAsDecimal = other.PostBillFederalTaxAdjustmentAmountAsDecimal;
			PostBillFederalTaxAdjustmentAmount = other.PostBillFederalTaxAdjustmentAmount;
			PostBillStateTaxAdjustmentAmountAsDecimal = other.PostBillStateTaxAdjustmentAmountAsDecimal;
			PostBillStateTaxAdjustmentAmount = other.PostBillStateTaxAdjustmentAmount;
			PostBillCountyTaxAdjustmentAmountAsDecimal = other.PostBillCountyTaxAdjustmentAmountAsDecimal;
			PostBillCountyTaxAdjustmentAmount = other.PostBillCountyTaxAdjustmentAmount;
			PostBillLocalTaxAdjustmentAmountAsDecimal = other.PostBillLocalTaxAdjustmentAmountAsDecimal;
			PostBillLocalTaxAdjustmentAmount = other.PostBillLocalTaxAdjustmentAmount;
			PostBillOtherTaxAdjustmentAmountAsDecimal = other.PostBillOtherTaxAdjustmentAmountAsDecimal;
			PostBillOtherTaxAdjustmentAmount = other.PostBillOtherTaxAdjustmentAmount;

			InitializeSubLevels(other.mSubLevels);
			InitializeCharges(other.mCharges);
			InitializeProductOfferings(other.mPOs);
		}

		private bool mRoot = false;
		public bool Root
		{
			get {return mRoot;}
		}

		public string ID
		{
			get
			{ return mID; }
			set
			{ mID = value; }
		}

		public string CacheID
		{
			get
			{ return mCacheID; }
			set
			{ mCacheID = value; }
		}

		public int AccountID
		{
			get
			{ return mAccountID; }
			set
			{ mAccountID = value; }
		}

//		public int ServiceEndpointID
//		{
//			get
//			{ return mEndpointID; }
//			set
//			{ mEndpointID = value; }
//		}

		public IDateRangeSlice AccountEffectiveDate
		{
			get
			{ return mAccountEffDate; }
			set
			{ mAccountEffDate = value; }
		}

		public IAccountSlice AccountSlice
		{
			get
			{ return mAccountSlice; }
			set
			{ mAccountSlice = value; }
		}

		public bool IsOpen
		{
			get
			{ return mIsOpen; }
			set
			{ mIsOpen = value; }
		}

		public string Amount
		{
			get
			{ return mAmount; }
			set
			{ mAmount = value; }
		}

		public decimal AmountAsDecimal
		{
			get
			{ return mAmountAsDecimal; }
			set
			{ mAmountAsDecimal = value; }
		}

    private string mPreBillAdjustmentDisplayAmount;
    public string PreBillAdjustmentDisplayAmount
    {
      get { return mPreBillAdjustmentDisplayAmount; }
      set { mPreBillAdjustmentDisplayAmount = value; }
    }

    private decimal mPreBillAdjustmentDisplayAmountAsDecimal;
    public decimal PreBillAdjustmentDisplayAmountAsDecimal
    {
      get { return mPreBillAdjustmentDisplayAmountAsDecimal; }
      set { mPreBillAdjustmentDisplayAmountAsDecimal = value; }
    }

		public string DisplayAmount
		{
			get
			{ return mDisplayAmount; }
			set
			{ mDisplayAmount = value; }
		}

		public decimal DisplayAmountAsDecimal
		{
			get
			{ return mDisplayAmountAsDecimal; }
			set
			{ mDisplayAmountAsDecimal = value; }
		}

		private string mTotalDisplayAmount;
		public string TotalDisplayAmount
		{
			get
			{ return mTotalDisplayAmount; }
			set
			{ mTotalDisplayAmount = value; }
		}

		private decimal mTotalDisplayAmountAsDecimal;
		public decimal TotalDisplayAmountAsDecimal
		{
			get
			{ return mTotalDisplayAmountAsDecimal; }
			set
			{ mTotalDisplayAmountAsDecimal = value; }
		}

		public string Currency
		{
			get
			{ return mCurrency; }
			set
			{ mCurrency = value; }
		}

		public int NumTransactions
		{
			get
			{ return mNumTransactions; }
			set
			{ mNumTransactions = value; }
		}

		public string PostBillAdjustedAmount
		{
			get
			{ return mPostBillAmount; }
			set
			{ mPostBillAmount = value; }
		}

		public decimal PostBillAdjustedAmountAsDecimal
		{
			get
			{ return mPostBillBillAmountAsDecimal; }
			set
			{ mPostBillBillAmountAsDecimal = value; }
		}


		public string PreBillAdjustedAmount
		{
			get
			{ return mPreBillBillAmount; }
			set
			{ mPreBillBillAmount = value; }
		}

		public decimal PreBillAdjustedAmountAsDecimal
		{
			get
			{ return mPreBillBillAmountAsDecimal; }
			set
			{ mPreBillBillAmountAsDecimal = value; }
		}

		public int NumPreBillAdjustments
		{
			get
			{ return mNumPreBillAdjustments; }
			set
			{ mNumPreBillAdjustments = value; }
		}

		public int NumPostBillAdjustments
		{
			get
			{ return mNumPostBillAdjustments; }
			set
			{ mNumPostBillAdjustments = value; }
		}

		public string PreBillAdjustmentAmount
		{
			get
			{ return mPreBillAdjustmentAmount; }
			set
			{ mPreBillAdjustmentAmount = value; }
		}

		private decimal mPreBillAdjustmentAmountAsDecimal;
		public decimal PreBillAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillAdjustmentAmountAsDecimal; }
			set
			{ mPreBillAdjustmentAmountAsDecimal = value; }
		}

		public string PostBillAdjustmentAmount
		{
			get
			{ return mPostBillAdjustmentAmount; }
			set
			{ mPostBillAdjustmentAmount = value; }
		}

		private decimal mPostBillAdjustmentAmountAsDecimal;
		public decimal PostBillAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillAdjustmentAmountAsDecimal; }
			set
			{ mPostBillAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillTotalTaxAdjustmentAmount;
		public string PreBillTotalTaxAdjustmentAmount
		{
			get
			{ return mPreBillTotalTaxAdjustmentAmount; }
			set
			{ mPreBillTotalTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillTotalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillTotalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillTotalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillTotalTaxAdjustmentAmountAsDecimal = value; }
		}

    public string PreAndPostBillTotalTaxAdjustmentAmount
    {
      get { return String.Format("{0}", mPreBillTotalTaxAdjustmentAmountAsDecimal + mPostBillTotalTaxAdjustmentAmountAsDecimal); }
    }

    public decimal PreAndPostBillTotalTaxAdjustmentAmountAsDecimal
    {
      get { return mPreBillTotalTaxAdjustmentAmountAsDecimal + mPostBillTotalTaxAdjustmentAmountAsDecimal; }
    }

		private string mPreBillFederalTaxAdjustmentAmount;
		public string PreBillFederalTaxAdjustmentAmount
		{
			get
			{ return mPreBillFederalTaxAdjustmentAmount; }
			set
			{ mPreBillFederalTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillFederalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillFederalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillFederalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillFederalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillStateTaxAdjustmentAmount;
		public string PreBillStateTaxAdjustmentAmount
		{
			get
			{ return mPreBillStateTaxAdjustmentAmount; }
			set
			{ mPreBillStateTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillStateTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillStateTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillStateTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillStateTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillCountyTaxAdjustmentAmount;
		public string PreBillCountyTaxAdjustmentAmount
		{
			get
			{ return mPreBillCountyTaxAdjustmentAmount; }
			set
			{ mPreBillCountyTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillCountyTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillCountyTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillCountyTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillCountyTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillLocalTaxAdjustmentAmount;
		public string PreBillLocalTaxAdjustmentAmount
		{
			get
			{ return mPreBillLocalTaxAdjustmentAmount; }
			set
			{ mPreBillLocalTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillLocalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillLocalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillLocalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillLocalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPreBillOtherTaxAdjustmentAmount;
		public string PreBillOtherTaxAdjustmentAmount
		{
			get
			{ return mPreBillOtherTaxAdjustmentAmount; }
			set
			{ mPreBillOtherTaxAdjustmentAmount = value; }
		}


		private decimal mPreBillOtherTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PreBillOtherTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPreBillOtherTaxAdjustmentAmountAsDecimal; }
			set
			{ mPreBillOtherTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillTotalTaxAdjustmentAmount;
		public string PostBillTotalTaxAdjustmentAmount
		{
			get
			{ return mPostBillTotalTaxAdjustmentAmount; }
			set
			{ mPostBillTotalTaxAdjustmentAmount = value; }
		}

		private decimal mPostBillTotalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillTotalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillTotalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillTotalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillFederalTaxAdjustmentAmount;
		public string PostBillFederalTaxAdjustmentAmount
		{
			get
			{ return mPostBillFederalTaxAdjustmentAmount; }
			set
			{ mPostBillFederalTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillFederalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillFederalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillFederalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillFederalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillStateTaxAdjustmentAmount;
		public string PostBillStateTaxAdjustmentAmount
		{
			get
			{ return mPostBillStateTaxAdjustmentAmount; }
			set
			{ mPostBillStateTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillStateTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillStateTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillStateTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillStateTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillCountyTaxAdjustmentAmount;
		public string PostBillCountyTaxAdjustmentAmount
		{
			get
			{ return mPostBillCountyTaxAdjustmentAmount; }
			set
			{ mPostBillCountyTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillCountyTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillCountyTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillCountyTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillCountyTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillLocalTaxAdjustmentAmount;
		public string PostBillLocalTaxAdjustmentAmount
		{
			get
			{ return mPostBillLocalTaxAdjustmentAmount; }
			set
			{ mPostBillLocalTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillLocalTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillLocalTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillLocalTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillLocalTaxAdjustmentAmountAsDecimal = value; }
		}

		private string mPostBillOtherTaxAdjustmentAmount;
		public string PostBillOtherTaxAdjustmentAmount
		{
			get
			{ return mPostBillOtherTaxAdjustmentAmount; }
			set
			{ mPostBillOtherTaxAdjustmentAmount = value; }
		}


		private decimal mPostBillOtherTaxAdjustmentAmountAsDecimal = 0.0M;
		public decimal PostBillOtherTaxAdjustmentAmountAsDecimal
		{
			get
			{ return mPostBillOtherTaxAdjustmentAmountAsDecimal; }
			set
			{ mPostBillOtherTaxAdjustmentAmountAsDecimal = value; }
		}

		public string Tax
		{
			get
			{ return mTax; }
			set
			{ mTax = value; }
		}

		public decimal TaxAsDecimal
		{
			get
			{ return mTaxAsDecimal; }
			set
			{ mTaxAsDecimal = value; }
		}

		public string FederalTax
		{
			get
			{ return mFederalTax; }
			set
			{ mFederalTax = value; }
		}
		public decimal FederalTaxAsDecimal
		{
			get
			{ return mFederalTaxAsDecimal; }
			set
			{ mFederalTaxAsDecimal = value; }
		}

		public string StateTax
		{
			get
			{ return mStateTax; }
			set
			{ mStateTax = value; }
		}
		public decimal StateTaxAsDecimal
		{
			get
			{ return mStateTaxAsDecimal; }
			set
			{ mStateTaxAsDecimal = value; }
		}

		public string CountyTax
		{
			get
			{ return mCountyTax; }
			set
			{ mCountyTax = value; }
		}
		public decimal CountyTaxAsDecimal
		{
			get
			{ return mCountyTaxAsDecimal; }
			set
			{ mCountyTaxAsDecimal = value; }
		}

		public string LocalTax
		{
			get
			{ return mLocalTax; }
			set
			{ mLocalTax = value; }
		}
		public decimal LocalTaxAsDecimal
		{
			get
			{ return mLocalTaxAsDecimal; }
			set
			{ mLocalTaxAsDecimal = value; }
		}

		public string OtherTax
		{
			get
			{ return mOtherTax; }
			set
			{ mOtherTax = value; }
		}
		public decimal OtherTaxAsDecimal
		{
			get
			{ return mOtherTaxAsDecimal; }
			set
			{ mOtherTaxAsDecimal = value; }
		}

		public string TaxedAmount
		{
			get
			{ return mTaxedAmount; }
			set
			{ mTaxedAmount = value; }
		}

		public IAccountSlice AccountSummarySlice
		{
			get
			{ return mAccountSummarySlice; }
			set
			{ mAccountSummarySlice = value; }
		}

		public IDateRangeSlice TimeSlice
		{
			get
			{ return mTimeSlice; }
			set
			{ mTimeSlice = value; }
		}

		public IEnumerable SubLevels
		{
			get
			{ return mSubLevels; }
		}

		public IEnumerable Charges
		{
			get
			{ return mCharges; }
		}

		public IEnumerable ProductOfferings
		{
			get
			{ return mPOs; }
		}

    public int ProductOfferingsCount
    {
      get
      {
				Debug.Assert(mPOs != null);
				return mPOs.Count;
			}
    }

		public Level GetChild(int number)
		{
			return (Level) mSubLevels[number];
		}

		public void InitializeSubLevels(ArrayList children)
		{
			mSubLevels = children;
		}

		public void AddSubLevels(ArrayList children)
		{
			#if DEBUG
			foreach (Level level in children)
				foreach (Level test in mSubLevels)
					Debug.Assert(level.CacheID != test.CacheID);
			#endif
			mSubLevels.AddRange(children);
		}

		public void InitializeCharges(ArrayList charges)
		{
			mCharges = charges;
		}

		public void InitializeProductOfferings(ArrayList pos)
		{
			mPOs = pos;
		}

		public int SubLevelCount
		{
			get
			{
				if (mSubLevels == null)
					return 0;
				else
					return mSubLevels.Count;
			}
		}

		// NOTE: always update the Copy method if you add a field
		private string mID;
		private string mCacheID;
		private bool mIsOpen;
		private string mAmount;
		private decimal mAmountAsDecimal;
		private string mDisplayAmount;
		private decimal mDisplayAmountAsDecimal;
		private string mCurrency;
		private string mPostBillAmount;
		private decimal mPostBillBillAmountAsDecimal;
		private string mPreBillBillAmount;
		private decimal mPreBillBillAmountAsDecimal;
		private string mTax;
		private decimal mTaxAsDecimal;
		private string mFederalTax;
		private decimal mFederalTaxAsDecimal;
		private string mStateTax;
		private decimal mStateTaxAsDecimal;
		private string mCountyTax;
		private decimal mCountyTaxAsDecimal;
		private string mLocalTax;
		private decimal mLocalTaxAsDecimal;
		private string mOtherTax;
		private decimal mOtherTaxAsDecimal;
		private string mTaxedAmount;
		private string mPostBillAdjustmentAmount;
		private string mPreBillAdjustmentAmount;
		private int mNumPostBillAdjustments;
		private int mNumPreBillAdjustments;
		private int mNumTransactions;

		private ArrayList mSubLevels;
		private ArrayList mCharges;
		private ArrayList mPOs;

		private int mAccountID;
		private IDateRangeSlice mAccountEffDate;
		private IAccountSlice mAccountSummarySlice;
		private IAccountSlice mAccountSlice;
		private IDateRangeSlice mTimeSlice;
	}
  #endregion

  #region ReportManager Class
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("5b5b9adb-eeeb-43c4-b289-58d7437db5ee")]
	public class ReportManager : IReportManager
	{
		static bool mMVMEnabled;
		static ReportManager()
		{
			// Determine if materialized view is enabled.
			Manager mvm = new Manager();
			mvm.Initialize();
			mMVMEnabled = mvm.IsMetraViewSupportEnabled;
		}

		public ReportManager()
		{
			// TODO: initialize other currencies?  how do we know which ones?
			mLocaleTranslator.Init("US");

			mLogger = new Logger("[Report]");
			mPerfLogger = new Logger("logging\\perflog", "[Report]");
		}

		public void Initialize(string path)
		{
			Debug.Assert(false);
		}

		public ITimeSlice TimeSlice
		{
			get
			{ return mTimeSlice; }
			set
			{ mTimeSlice = value; }
		}

		public int LanguageID
		{
			get
			{ return mLanguageID; }
			set
			{ mLanguageID = value; }
		}

		public Level Root
		{
			get
			{ return mRoot; }
		}

		public void OpenLevelByID(string id)
		{
			if (mRoot == null)
				throw new ApplicationException("root not initialized");
			Level node = GetLevel(mRoot, id);
			OpenLevel(node);
		}

		public void CloseLevelByID(string id)
		{
			Level node = GetLevel(mRoot, id);
			CloseLevel(node);
		}

		public void OpenLevel(Level node)
		{
			if (node == null)
				throw new ApplicationException("node is null");

			if (node.IsOpen)
				return;

            mLogger.LogDebug("Opening sub level {0} (account)", node.CacheID); 
            
            var performanceStopWatch = new PerformanceStopWatch();
            performanceStopWatch.Start();
			
			InitByFolderReport(node, mPayerId, mTimeSlice, mLanguageID, mPayerReport, mSecondPass);

            performanceStopWatch.Stop("OpenLevel");

			node.IsOpen = true;
		}

		public void CloseLevel(Level node)
		{
			if (!node.IsOpen)
				return;

			mLogger.LogDebug("Closing sub level {0}", node.CacheID);

			node.InitializeSubLevels(new ArrayList());
			node.IsOpen = false;
		}

		private Level GetLevel(Level root, string cacheID)
		{
			string [] strPath = cacheID.Split(new char[] { '_' } );

			if (strPath == null)
				throw new ApplicationException("strPath is null");

			// now follow the path
			Level current = root;
			// keep track of the path as it's build up for debugging
			StringBuilder builtUp = new StringBuilder();
			for (int i = 0; i < strPath.Length; i++)
			{
				int child = System.Convert.ToInt32(strPath[i]);
				if (builtUp.Length > 0)
					builtUp.Append('_');
				builtUp.Append(child.ToString());
				current = current.GetChild(child);
				Debug.Assert(current.CacheID == builtUp.ToString());
			}

			if (current == null)
				throw new ApplicationException("returned level is null");

			return current;
		}

		private void ParseChargeQuery(Level root, IMTDataReader reader)
		{
			int i = 0;

			Hashtable parents = new Hashtable();
			ArrayList charges = new ArrayList();
			Hashtable pos = new Hashtable();

			int poIDIdx = reader.GetOrdinal("ProductOfferingId");
			int piNameIdx = reader.GetOrdinal("PriceableItemName");
			int poNameIdx = reader.GetOrdinal("ProductOfferingName");
			int piParentIdx = reader.GetOrdinal("PriceableItemParentId");
			int templateIDIdx = reader.GetOrdinal("PriceableItemTemplateId");
			int UOMIdx = reader.GetOrdinal("Currency");
			int viewNameIdx = reader.GetOrdinal("ViewName");
			int viewIDIdx = reader.GetOrdinal("ViewId");
			int amountIdx = reader.GetOrdinal("TotalAmount");
			int isAggregateIdx = reader.GetOrdinal("IsAggregate");
			int piInstanceNameIdx = reader.GetOrdinal("PriceableItemInstanceName");
			int piInstanceIDIdx = reader.GetOrdinal("PriceableItemInstanceId");
      int postbillAdjustmentAmountIdx = reader.GetOrdinal("PostBillAdjAmt");
      int prebillAdjustmentAmountIdx = reader.GetOrdinal("PreBillAdjAmt");
			int prebillAdjustedAmountIdx = reader.GetOrdinal("PrebillAdjAmt");
			int postbillAdjustedAmountIdx = reader.GetOrdinal("PostbillAdjAmt");
			int federalTaxIdx = reader.GetOrdinal("TotalFederalTax");
			int stateTaxIdx = reader.GetOrdinal("TotalStateTax");
			int countyTaxIdx = reader.GetOrdinal("TotalCountyTax");
			int localTaxIdx = reader.GetOrdinal("TotalLocalTax");
			int otherTaxIdx = reader.GetOrdinal("TotalOtherTax");
			int totalTaxIdx = reader.GetOrdinal("TotalTax");
			int prebillTotalTaxAdjustmentAmountIdx = reader.GetOrdinal("PreBillTotalTaxAdjAmt");
			int postbillTotalTaxAdjustmentAmountIdx = reader.GetOrdinal("PostBillTotalTaxAdjAmt");
			int prebillFederalTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillFedTaxAdjAmt");
			int postbillFederalTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillFedTaxAdjAmt");
			int prebillStateTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillStateTaxAdjAmt");
			int postbillStateTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillStateTaxAdjAmt");
			int prebillCountyTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillCntyTaxAdjAmt");
			int postbillCountyTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillCntyTaxAdjAmt");
			int prebillLocalTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillLocalTaxAdjAmt");
			int postbillLocalTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillLocalTaxAdjAmt");
			int prebillOtherTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillOtherTaxAdjAmt");
			int postbillOtherTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillOtherTaxAdjAmt");
			
			while (reader.Read())
			{
				Charge charge = new Charge();

				// is this a product offering we haven't seen before?
				ProductOffering po;
				if (!reader.IsDBNull(poIDIdx))	// po ID
				{
					int poID = -1;
					poID = reader.GetInt32(poIDIdx);
					po = (ProductOffering) pos[poID];
					if (po == null)
					{
						// new
						po = new ProductOffering();
            try
            {
              po.ID = reader.GetString(poNameIdx);
            }
            catch(Exception exp)
            {
              // CR 11409
              mLogger.LogError(exp.Message.ToString());
              mLogger.LogError("Product Offering has not been fully localized.");
              throw(new System.ApplicationException("Product Offering has not been fully localized."));
            }
						// TODO: like in the old code we don't support
						// product offering roll ups
						po.Amount = "";
						po.Currency = "";
						pos[poID] = po;
					}
				}
				else
					po = null;

				// is this a child
				Charge parentCharge;
				if (!reader.IsDBNull(piParentIdx))	// priceable item parent ID
				{
					int piParent = reader.GetInt32(piParentIdx);
					parentCharge = (Charge) parents[piParent];

					// assume parents are listed before children
					Debug.Assert(parentCharge != null);
				}
				else
					parentCharge = null;

				int piID;

				//below 2 properties are uniform
				//no matter what kind of usage this is
				string UOM = reader.GetString(UOMIdx);
				decimal amount = reader.GetDecimal(amountIdx);

				if (reader.IsDBNull(templateIDIdx))	// priceable item template id
				{
					// This is non-product catalog usage.  We will pretend that
					// it is priceable item template usage.
					string ID = reader.GetString(viewNameIdx); // view name

					IProductViewSlice view = new ProductViewSlice();
					view.ViewID = reader.GetInt32(viewIDIdx);

					piID = -1;
					bool isAggregate = false;

					charge.Amount = LocalizeCurrency(amount, UOM);
					charge.Currency = UOM;
					charge.ID = ID;
					charge.IsAggregate = isAggregate;
					charge.ViewSlice = view;
				}
				else if (reader.IsDBNull(poIDIdx)) // product offering id
				{
					string ID = reader.GetString(piNameIdx);	// priceable item name

					IPriceableItemTemplateSlice template = new PriceableItemTemplateSlice();
					template.TemplateID = reader.GetInt32(templateIDIdx);
					template.ViewID = reader.GetInt32(viewIDIdx);
					piID = template.TemplateID;
					
					bool isAggregate = reader.GetString(isAggregateIdx) == "Y";

					charge.Amount = LocalizeCurrency(amount, UOM);
					charge.Currency = UOM;
					charge.ID = ID;
					charge.IsAggregate = isAggregate;
					charge.ViewSlice = template;
				}
				else
				{
					
					string ID = reader.GetString(piInstanceNameIdx);

					IPriceableItemInstanceSlice instance = new PriceableItemInstanceSlice();
					instance.InstanceID = reader.GetInt32(piInstanceIDIdx);
					instance.ViewID = reader.GetInt32(viewIDIdx);
					bool isAggregate = reader.GetString(isAggregateIdx) == "Y";

					piID = instance.InstanceID;
					charge.Amount = LocalizeCurrency(amount, UOM);
					charge.Currency = UOM;
					charge.ID = ID;
					charge.IsAggregate = isAggregate;
					charge.ViewSlice = instance;
				}

        decimal prebillAdjustmentAmount = reader.GetDecimal(prebillAdjustmentAmountIdx);
        decimal postbillAdjustmentAmount = reader.GetDecimal(postbillAdjustmentAmountIdx);
				decimal prebillAdjustedAmount = reader.GetDecimal(prebillAdjustedAmountIdx);
				decimal postbillAdjustedAmount = reader.GetDecimal(postbillAdjustedAmountIdx);
				decimal prebillTotalTaxAdjustmentAmount = reader.GetDecimal(prebillTotalTaxAdjustmentAmountIdx);
				decimal prebillFederalTaxAdjustmentAmount = reader.GetDecimal(prebillFederalTaxAdjustmentAmountIdx);
				decimal prebillStateTaxAdjustmentAmount = reader.GetDecimal(prebillStateTaxAdjustmentAmountIdx);
				decimal prebillCountyTaxAdjustmentAmount = reader.GetDecimal(prebillCountyTaxAdjustmentAmountIdx);
				decimal prebillLocalTaxAdjustmentAmount = reader.GetDecimal(prebillLocalTaxAdjustmentAmountIdx);
				decimal prebillOtherTaxAdjustmentAmount = reader.GetDecimal(prebillOtherTaxAdjustmentAmountIdx);
				decimal postbillTotalTaxAdjustmentAmount = reader.GetDecimal(postbillTotalTaxAdjustmentAmountIdx);
				decimal postbillFederalTaxAdjustmentAmount = reader.GetDecimal(postbillFederalTaxAdjustmentAmountIdx);
				decimal postbillStateTaxAdjustmentAmount = reader.GetDecimal(postbillStateTaxAdjustmentAmountIdx);
				decimal postbillCountyTaxAdjustmentAmount = reader.GetDecimal(postbillCountyTaxAdjustmentAmountIdx);
				decimal postbillLocalTaxAdjustmentAmount = reader.GetDecimal(postbillLocalTaxAdjustmentAmountIdx);
				decimal postbillOtherTaxAdjustmentAmount = reader.GetDecimal(postbillOtherTaxAdjustmentAmountIdx);
				
				decimal federalTax = reader.GetDecimal(federalTaxIdx);
				decimal stateTax = reader.GetDecimal(stateTaxIdx);
				decimal countyTax = reader.GetDecimal(countyTaxIdx);
				decimal localTax = reader.GetDecimal(localTaxIdx);
				decimal otherTax = reader.GetDecimal(otherTaxIdx);
				decimal totalTax = reader.GetDecimal(totalTaxIdx);

				charge.AmountAsDecimal = amount;
        charge.PreBillAdjustmentAmountAsDecimal = prebillAdjustmentAmount;
        charge.PreBillAdjustmentAmount = LocalizeCurrency(prebillAdjustmentAmount, UOM);
        charge.PostBillAdjustmentAmount = LocalizeCurrency(postbillAdjustmentAmount, UOM);
        charge.PostBillAdjustmentAmountAsDecimal = postbillAdjustmentAmount;
				charge.PreBillAdjustedAmountAsDecimal = prebillAdjustedAmount;
				charge.PreBillAdjustedAmount = LocalizeCurrency(prebillAdjustedAmount, UOM);
				charge.PostBillAdjustedAmount = LocalizeCurrency(postbillAdjustedAmount, UOM);
				charge.PostBillAdjustedAmountAsDecimal = postbillAdjustedAmount;
				charge.Tax = LocalizeCurrency(totalTax, UOM);
				charge.TaxAsDecimal = totalTax;
				charge.FederalTax = LocalizeCurrency(federalTax, UOM);
				charge.FederalTaxAsDecimal = federalTax;
				charge.StateTax = LocalizeCurrency(stateTax, UOM);
				charge.StateTaxAsDecimal = stateTax;
				charge.CountyTax = LocalizeCurrency(countyTax, UOM);
				charge.CountyTaxAsDecimal = countyTax;
				charge.LocalTax = LocalizeCurrency(localTax, UOM);
				charge.LocalTaxAsDecimal = localTax;
				charge.OtherTax = LocalizeCurrency(otherTax, UOM);
				charge.OtherTaxAsDecimal = otherTax;

				charge.PreBillTotalTaxAdjustmentAmountAsDecimal = prebillTotalTaxAdjustmentAmount;
				charge.PreBillTotalTaxAdjustmentAmount = LocalizeCurrency(prebillTotalTaxAdjustmentAmount, UOM);
				charge.PreBillFederalTaxAdjustmentAmountAsDecimal = prebillFederalTaxAdjustmentAmount;
				charge.PreBillFederalTaxAdjustmentAmount = LocalizeCurrency(prebillFederalTaxAdjustmentAmount, UOM);
				charge.PreBillStateTaxAdjustmentAmountAsDecimal = prebillStateTaxAdjustmentAmount;
				charge.PreBillStateTaxAdjustmentAmount = LocalizeCurrency(prebillStateTaxAdjustmentAmount, UOM);
				charge.PreBillCountyTaxAdjustmentAmountAsDecimal = prebillCountyTaxAdjustmentAmount;
				charge.PreBillCountyTaxAdjustmentAmount = LocalizeCurrency(prebillCountyTaxAdjustmentAmount, UOM);
				charge.PreBillLocalTaxAdjustmentAmountAsDecimal = prebillLocalTaxAdjustmentAmount;
				charge.PreBillLocalTaxAdjustmentAmount = LocalizeCurrency(prebillLocalTaxAdjustmentAmount, UOM);
				charge.PreBillOtherTaxAdjustmentAmountAsDecimal = prebillOtherTaxAdjustmentAmount;
				charge.PreBillOtherTaxAdjustmentAmount = LocalizeCurrency(prebillOtherTaxAdjustmentAmount, UOM);
				charge.PostBillTotalTaxAdjustmentAmountAsDecimal = postbillTotalTaxAdjustmentAmount;
				charge.PostBillTotalTaxAdjustmentAmount = LocalizeCurrency(postbillTotalTaxAdjustmentAmount, UOM);
				charge.PostBillFederalTaxAdjustmentAmountAsDecimal = postbillFederalTaxAdjustmentAmount;
				charge.PostBillFederalTaxAdjustmentAmount = LocalizeCurrency(postbillFederalTaxAdjustmentAmount, UOM);
				charge.PostBillStateTaxAdjustmentAmountAsDecimal = postbillStateTaxAdjustmentAmount;
				charge.PostBillStateTaxAdjustmentAmount = LocalizeCurrency(postbillStateTaxAdjustmentAmount, UOM);
				charge.PostBillCountyTaxAdjustmentAmountAsDecimal = postbillCountyTaxAdjustmentAmount;
				charge.PostBillCountyTaxAdjustmentAmount = LocalizeCurrency(postbillCountyTaxAdjustmentAmount, UOM);
				charge.PostBillLocalTaxAdjustmentAmountAsDecimal = postbillLocalTaxAdjustmentAmount;
				charge.PostBillLocalTaxAdjustmentAmount = LocalizeCurrency(postbillLocalTaxAdjustmentAmount, UOM);
				charge.PostBillOtherTaxAdjustmentAmountAsDecimal = postbillOtherTaxAdjustmentAmount;
				charge.PostBillOtherTaxAdjustmentAmount = LocalizeCurrency(postbillOtherTaxAdjustmentAmount, UOM);

				PopulateChargeDisplayAmount(ref charge);

				// in case someone lists it as a parent
				parents[piID] = charge;

				if (po != null && parentCharge == null)
					// parent within a product offering
					po.AddCharge(charge);

				else if (parentCharge != null)
					// child of another charge
					parentCharge.AddSubCharge(charge);

				else if (po == null && parentCharge == null)
					// standalone charge
					charges.Add(charge);

				i++;
			}
			root.InitializeCharges(charges);

			ArrayList poList = new ArrayList();
			poList.InsertRange(0, pos.Values);
			root.InitializeProductOfferings(poList);
		}


		private void PopulateCharges(Level root, int accountID, int payerID, IDateRangeSlice accountEffDate)
		{
			// Here we are retrieving the by product summary for usage incurred by
			// vtAccountId (and paid for by vtPayerId if we are a bill report).

			bool payerReport = mPayerReport;
			bool secondPass = mSecondPass;

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                        "\\Queries\\PresServer",
                        mMVMEnabled ? "__GET_BYACCOUNTBYPRODUCTFORPAYER_DATAMART__"
                        : "__GET_BYACCOUNTBYPRODUCTFORPAYER__"))
                {
                    if (payerReport)
                    {
                        stmt.AddParam("%%ID_PAYER%%", payerID);
                    }
                    else
                    {
                        stmt.QueryTag = (mMVMEnabled ? "__GET_BYACCOUNTBYPRODUCT_DATAMART__" : "__GET_BYACCOUNTBYPRODUCT__");
                    }

                    // Parameters common to both report types
                    stmt.AddParam("%%ID_ACC%%", accountID);
                    stmt.AddParam("%%ID_LANG%%", mLanguageID);
                    stmt.AddParam("%%TIME_PREDICATE%%", mTimeSlice.GenerateQueryPredicate(), true);
                    stmt.AddParam("%%LIKE_OR_NOT_LIKE%%", secondPass ? " NOT LIKE " : " LIKE ");

                    DateTime begin, end;
                    if (accountEffDate != null)
                    {
                        accountEffDate.GetTimeSpan(out begin, out end);
                    }
                    else
                    {
                        if (!mPayerReport)
                            mTimeSlice.GetTimeSpan(out begin, out end);
                        else
                        {
                            // For payer reports initialize date range to +- infinity						
                            begin = mNegativeInf;
                            end = mPositiveInf;
                        }
                    }

                    stmt.AddParam("%%DT_BEGIN%%", MetraTime.FormatAsODBC(begin), true);
                    stmt.AddParam("%%DT_END%%", MetraTime.FormatAsODBC(end), true);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        ParseChargeQuery(root, reader);
                    }
                }
            }
		}

		private int GetAccountSummaryPanel(Level root, int intAccountId, int intPayerId, IDateRangeSlice accountEffDate)
		{
			ArrayList levels = new ArrayList();
			int rowCount = 0;
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                        "\\Queries\\PresServer", mMVMEnabled ? "__GET_BYACCOUNTALLPRODUCTS_DATAMART__"
                        : "__GET_BYACCOUNTALLPRODUCTS__"))
                {
                    if (mPayerReport)
                    {
                        // Here we are doing a "By-Originator" report but only for charges payed
                        // for by a single account. 
                        stmt.QueryTag = (mMVMEnabled ? "__GET_BYACCOUNTALLPRODUCTSFORPAYER_DATAMART__" : "__GET_BYACCOUNTALLPRODUCTSFORPAYER__");
                        stmt.AddParam("%%ID_PAYER%%", intPayerId);
                    }

                    stmt.AddParam("%%ID_ACC%%", intAccountId);
                    stmt.AddParam("%%TIME_PREDICATE%%", mTimeSlice.GenerateQueryPredicate(), true);
                    stmt.AddParam("%%LIKE_OR_NOT_LIKE%%", mSecondPass ? " NOT LIKE " : " LIKE ");

                    DateTime begin, end;
                    if (accountEffDate != null)
                    {
                        accountEffDate.GetTimeSpan(out begin, out end);
                    }
                    else
                    {
                        if (!mPayerReport)
                            mTimeSlice.GetTimeSpan(out begin, out end);
                        else
                        {
                            // For payer reports initialize date range to +- infinity						
                            begin = mNegativeInf;
                            end = mPositiveInf;
                        }
                    }

                    stmt.AddParam("%%DT_BEGIN%%", MetraTime.FormatAsODBC(begin), true);
                    stmt.AddParam("%%DT_END%%", MetraTime.FormatAsODBC(end), true);

                    // payer report
                    // 0 PayingAccountId
                    // 1 PayingAccountName
                    // 2 AccountId
                    // 3 AccountName
                    // 4 AccountStart
                    // 5 AccountEnd
                    // 6 TotalAmount
                    // 7 TotalFederalTax
                    // 8 TotalStateTax
                    // 9 TotalTax
                    // 10 PrebillAdjustmentAmount
                    // 11 PostbillAdjustmentAmount
                    // 12 PrebillAdjustedAmount
                    // 13 PostbillAdjustedAmount
                    // 14 NumPrebillAdjustments
                    // 15 NumPostbillAdjustments
                    // 16 NumTransactions
                    // 17 Currency

                    // not payer report
                    // 0 AccountId
                    // 1 AccountStart
                    // 2 AccountEnd
                    // 3 AccountName
                    // 4 TotalAmount
                    // 5 TotalFederalTax
                    // 6 TotalStateTax
                    // 7 TotalTax
                    // 8 PrebillAdjustmentAmount
                    // 9 PostbillAdjustmentAmount
                    // 10 PrebillAdjustedAmount
                    // 11 PostbillAdjustedAmount
                    // 12 NumPrebillAdjustments
                    // 13 NumPostbillAdjustments
                    // 14 NumTransactions
                    // 15 Currency 

                    int accountNameIdx;
                    int totalAmountIdx;
                    int prebillAdjustmentAmountIdx;
                    int postbillAdjustmentAmountIdx;
                    int prebillAdjustedAmountIdx;
                    int postbillAdjustedAmountIdx;
                    int totalTaxIdx;
                    int subAccountIDIdx;
                    int subAccountStartIdx;
                    int subAccountEndIdx;
                    int numPrebillIdx;
                    int numPostbillIdx;
                    int currencyIdx;
                    int numTransactionsIdx;
                    int federalTaxIdx;
                    int stateTaxIdx;
                    int countyTaxIdx;
                    int localTaxIdx;
                    int otherTaxIdx;

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        accountNameIdx = reader.GetOrdinal("AccountName");
                        totalAmountIdx = reader.GetOrdinal("TotalAmount");
                        prebillAdjustmentAmountIdx = reader.GetOrdinal("PrebillAdjAmt");
                        postbillAdjustmentAmountIdx = reader.GetOrdinal("PostbillAdjAmt");
                        int prebillTotalTaxAdjustmentAmountIdx = reader.GetOrdinal("PreBillTotalTaxAdjAmt");
                        int postbillTotalTaxAdjustmentAmountIdx = reader.GetOrdinal("PostBillTotalTaxAdjAmt");
                        int prebillFederalTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillFedTaxAdjAmt");
                        int postbillFederalTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillFedTaxAdjAmt");
                        int prebillStateTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillStateTaxAdjAmt");
                        int postbillStateTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillStateTaxAdjAmt");
                        int prebillCountyTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillCntyTaxAdjAmt");
                        int postbillCountyTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillCntyTaxAdjAmt");
                        int prebillLocalTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillLocalTaxAdjAmt");
                        int postbillLocalTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillLocalTaxAdjAmt");
                        int prebillOtherTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillOtherTaxAdjAmt");
                        int postbillOtherTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillOtherTaxAdjAmt");

                        prebillAdjustedAmountIdx = reader.GetOrdinal("PrebillAdjustedAmount");
                        postbillAdjustedAmountIdx = reader.GetOrdinal("PostbillAdjustedAmount");
                        federalTaxIdx = reader.GetOrdinal("TotalFederalTax");
                        stateTaxIdx = reader.GetOrdinal("TotalStateTax");
                        countyTaxIdx = reader.GetOrdinal("TotalCountyTax");
                        localTaxIdx = reader.GetOrdinal("TotalLocalTax");
                        otherTaxIdx = reader.GetOrdinal("TotalOtherTax");
                        totalTaxIdx = reader.GetOrdinal("TotalTax");
                        subAccountIDIdx = reader.GetOrdinal("AccountId");
                        subAccountStartIdx = reader.GetOrdinal("AccountStart");
                        subAccountEndIdx = reader.GetOrdinal("AccountEnd");
                        numPrebillIdx = reader.GetOrdinal("NumPrebillAdjustments");
                        numPostbillIdx = reader.GetOrdinal("NumPostbillAdjustments");
                        currencyIdx = reader.GetOrdinal("Currency");
                        numTransactionsIdx = reader.GetOrdinal("NumTransactions");

                        int i = 0;
                        while (reader.Read())
                        {
                            rowCount++;
                            //int payingAccount = reader.GetInt32(1);
                            string accountName = reader.GetString(accountNameIdx);
                            decimal totalAmount = reader.GetDecimal(totalAmountIdx);
                            decimal prebillAdjustmentAmount = reader.GetDecimal(prebillAdjustmentAmountIdx);
                            decimal postbillAdjustmentAmount = reader.GetDecimal(postbillAdjustmentAmountIdx);
                            decimal prebillTotalTaxAdjustmentAmount = reader.GetDecimal(prebillTotalTaxAdjustmentAmountIdx);
                            decimal prebillFederalTaxAdjustmentAmount = reader.GetDecimal(prebillFederalTaxAdjustmentAmountIdx);
                            decimal prebillStateTaxAdjustmentAmount = reader.GetDecimal(prebillStateTaxAdjustmentAmountIdx);
                            decimal prebillCountyTaxAdjustmentAmount = reader.GetDecimal(prebillCountyTaxAdjustmentAmountIdx);
                            decimal prebillLocalTaxAdjustmentAmount = reader.GetDecimal(prebillLocalTaxAdjustmentAmountIdx);
                            decimal prebillOtherTaxAdjustmentAmount = reader.GetDecimal(prebillOtherTaxAdjustmentAmountIdx);
                            decimal postbillTotalTaxAdjustmentAmount = reader.GetDecimal(postbillTotalTaxAdjustmentAmountIdx);
                            decimal postbillFederalTaxAdjustmentAmount = reader.GetDecimal(postbillFederalTaxAdjustmentAmountIdx);
                            decimal postbillStateTaxAdjustmentAmount = reader.GetDecimal(postbillStateTaxAdjustmentAmountIdx);
                            decimal postbillCountyTaxAdjustmentAmount = reader.GetDecimal(postbillCountyTaxAdjustmentAmountIdx);
                            decimal postbillLocalTaxAdjustmentAmount = reader.GetDecimal(postbillLocalTaxAdjustmentAmountIdx);
                            decimal postbillOtherTaxAdjustmentAmount = reader.GetDecimal(postbillOtherTaxAdjustmentAmountIdx);

                            decimal prebillAdjustedAmount = reader.GetDecimal(prebillAdjustedAmountIdx);
                            decimal postbillAdjustedAmount = reader.GetDecimal(postbillAdjustedAmountIdx);
                            decimal federalTax = reader.GetDecimal(federalTaxIdx);
                            decimal stateTax = reader.GetDecimal(stateTaxIdx);
                            decimal countyTax = reader.GetDecimal(countyTaxIdx);
                            decimal localTax = reader.GetDecimal(localTaxIdx);
                            decimal otherTax = reader.GetDecimal(otherTaxIdx);
                            decimal totalTax = reader.GetDecimal(totalTaxIdx);
                            int subAccountID = reader.GetInt32(subAccountIDIdx);
                            DateTime subAccountStart = reader.GetDateTime(subAccountStartIdx);
                            DateTime subAccountEnd = reader.GetDateTime(subAccountEndIdx);
                            int numPrebill = reader.GetInt32(numPrebillIdx);
                            int numPostbill = reader.GetInt32(numPostbillIdx);
                            string currency = reader.GetString(currencyIdx);
                            int numTransactions = reader.GetInt32(numTransactionsIdx);

                            bool isParent = (subAccountID == intAccountId);

                            Level level;
                            if (isParent)
                                level = root;
                            else
                            {
                                level = new Level();
                                string cacheID;
                                if (root.CacheID.Length == 0)
                                    cacheID = i.ToString();
                                else
                                    cacheID = root.CacheID + "_" + i.ToString();
                                level.CacheID = cacheID;
                                level.AccountID = subAccountID;
                            }

                            level.ID = accountName;

                            if (!mPayerReport)
                            {
                                IPayeeSlice slice = new PayeeSlice();
                                slice.PayeeID = subAccountID;
                                level.AccountSlice = slice;
                            }
                            else
                            {
                                IPayerAndPayeeSlice slice = new PayerAndPayeeSlice();
                                slice.PayeeID = subAccountID;
                                slice.PayerID = mPayerId;
                                level.AccountSlice = slice;
                            }

                            level.Amount = LocalizeCurrency(totalAmount, currency);
                            level.AmountAsDecimal = totalAmount;
                            level.Currency = currency;
                            level.PreBillAdjustedAmountAsDecimal = prebillAdjustedAmount;
                            level.PreBillAdjustedAmount = LocalizeCurrency(prebillAdjustedAmount, currency);
                            level.PostBillAdjustedAmount = LocalizeCurrency(postbillAdjustedAmount, currency);
                            level.PostBillAdjustedAmountAsDecimal = postbillAdjustedAmount;
                            level.PreBillAdjustmentAmount = LocalizeCurrency(prebillAdjustmentAmount, currency);
                            level.PreBillAdjustmentAmountAsDecimal = prebillAdjustmentAmount;
                            level.PostBillAdjustmentAmount = LocalizeCurrency(postbillAdjustmentAmount, currency);
                            level.PostBillAdjustmentAmountAsDecimal = postbillAdjustmentAmount;

                            level.PreBillTotalTaxAdjustmentAmountAsDecimal = prebillTotalTaxAdjustmentAmount;
                            level.PreBillTotalTaxAdjustmentAmount = LocalizeCurrency(prebillTotalTaxAdjustmentAmount, currency);
                            level.PreBillFederalTaxAdjustmentAmountAsDecimal = prebillFederalTaxAdjustmentAmount;
                            level.PreBillFederalTaxAdjustmentAmount = LocalizeCurrency(prebillFederalTaxAdjustmentAmount, currency);
                            level.PreBillStateTaxAdjustmentAmountAsDecimal = prebillStateTaxAdjustmentAmount;
                            level.PreBillStateTaxAdjustmentAmount = LocalizeCurrency(prebillStateTaxAdjustmentAmount, currency);
                            level.PreBillCountyTaxAdjustmentAmountAsDecimal = prebillCountyTaxAdjustmentAmount;
                            level.PreBillCountyTaxAdjustmentAmount = LocalizeCurrency(prebillCountyTaxAdjustmentAmount, currency);
                            level.PreBillLocalTaxAdjustmentAmountAsDecimal = prebillLocalTaxAdjustmentAmount;
                            level.PreBillLocalTaxAdjustmentAmount = LocalizeCurrency(prebillLocalTaxAdjustmentAmount, currency);
                            level.PreBillOtherTaxAdjustmentAmountAsDecimal = prebillOtherTaxAdjustmentAmount;
                            level.PreBillOtherTaxAdjustmentAmount = LocalizeCurrency(prebillOtherTaxAdjustmentAmount, currency);
                            level.PostBillTotalTaxAdjustmentAmountAsDecimal = postbillTotalTaxAdjustmentAmount;
                            level.PostBillTotalTaxAdjustmentAmount = LocalizeCurrency(postbillTotalTaxAdjustmentAmount, currency);
                            level.PostBillFederalTaxAdjustmentAmountAsDecimal = postbillFederalTaxAdjustmentAmount;
                            level.PostBillFederalTaxAdjustmentAmount = LocalizeCurrency(postbillFederalTaxAdjustmentAmount, currency);
                            level.PostBillStateTaxAdjustmentAmountAsDecimal = postbillStateTaxAdjustmentAmount;
                            level.PostBillStateTaxAdjustmentAmount = LocalizeCurrency(postbillStateTaxAdjustmentAmount, currency);
                            level.PostBillCountyTaxAdjustmentAmountAsDecimal = postbillCountyTaxAdjustmentAmount;
                            level.PostBillCountyTaxAdjustmentAmount = LocalizeCurrency(postbillCountyTaxAdjustmentAmount, currency);
                            level.PostBillLocalTaxAdjustmentAmountAsDecimal = postbillLocalTaxAdjustmentAmount;
                            level.PostBillLocalTaxAdjustmentAmount = LocalizeCurrency(postbillLocalTaxAdjustmentAmount, currency);
                            level.PostBillOtherTaxAdjustmentAmountAsDecimal = postbillOtherTaxAdjustmentAmount;
                            level.PostBillOtherTaxAdjustmentAmount = LocalizeCurrency(postbillOtherTaxAdjustmentAmount, currency);

                            level.NumPreBillAdjustments = numPrebill;
                            level.NumPostBillAdjustments = numPostbill;
                            level.Tax = LocalizeCurrency(totalTax, currency);
                            level.TaxAsDecimal = totalTax;
                            level.FederalTax = LocalizeCurrency(federalTax, currency);
                            level.FederalTaxAsDecimal = federalTax;
                            level.StateTax = LocalizeCurrency(stateTax, currency);
                            level.StateTaxAsDecimal = stateTax;
                            level.CountyTax = LocalizeCurrency(countyTax, currency);
                            level.CountyTaxAsDecimal = countyTax;
                            level.LocalTax = LocalizeCurrency(localTax, currency);
                            level.LocalTaxAsDecimal = localTax;
                            level.OtherTax = LocalizeCurrency(otherTax, currency);
                            level.OtherTaxAsDecimal = otherTax;
                            level.TaxedAmount = LocalizeCurrency(totalAmount + totalTax, currency);
                            level.NumTransactions = numTransactions;
                            level.IsOpen = false;
                            PopulateDisplayAmount(ref level);
                            PopulatePreBillAdjustmentDisplayAmount(level);

                            if (isParent && accountEffDate != null)
                            {
                                // More ugly hackery dealing with hierarchy effective dates.  Since this record is
                                // has num_generations = 0, its effective date is negative infinity to infinity.
                                // Correct for that here by intersecting with the effective date
                                level.TimeSlice = accountEffDate;
                                level.AccountEffectiveDate = accountEffDate;
                            }
                            else
                            {
                                IDateRangeSlice subAccountRange = new DateRangeSlice();
                                subAccountRange.Begin = subAccountStart;
                                subAccountRange.End = subAccountEnd;
                                level.TimeSlice = subAccountRange;
                                level.AccountEffectiveDate = subAccountRange;
                            }

                            if (!isParent)
                            {
                                levels.Add(level);
                                i++;
                            }
                        }
                    }
                }
            }
			root.InitializeSubLevels(levels);

			PopulateCharges(root, intAccountId, intPayerId, accountEffDate);
			return rowCount;
		}

		private void GetLeastCommonAncestorOfPayees(int accountId, DateTime dtBegin, DateTime dtEnd, ITimeSlice timeSlice, out int corporateId)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                    "\\Queries\\PresServer", mMVMEnabled ? "__GET_LEASTCOMMONANCESTOROFPAYEES_PRESSERVER_"
                    : "__GET_LEASTCOMMONANCESTOROFPAYEES_PRESSERVER_"))
                {
                    stmt.AddParam("%%ID_ACC%%", accountId);

                    stmt.AddParam("%%BEGIN_DATE%%", MetraTime.FormatAsODBC(dtBegin), true);
                    stmt.AddParam("%%END_DATE%%", MetraTime.FormatAsODBC(dtEnd), true);
                    stmt.AddParam("%%TIME_PREDICATE%%", timeSlice.GenerateQueryPredicate(), true);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                            corporateId = reader.GetInt32("id_ancestor");
                        else
                            corporateId = 0;
                    }
                }
            }
		}

		private void GetCorporateAccount(int accountID, DateTime effDate, out int corporateID)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                    "\\Queries\\AccHierarchies", "__GET_CORPORATEACCOUNT__"))
                {
                    stmt.AddParam("%%ID_ACC%%", accountID);

                    stmt.AddParam("%%EFF_DATE%%", MetraTime.FormatAsODBC(effDate), true);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                            corporateID = reader.GetInt32("id_ancestor");
                        else
                            throw new ApplicationException(string.Format("Unable to get corporate account for account {0} as of {1}", accountID, effDate));
                    }
                }
            }
		}

		private void InitByFolderReport(Level root, int intPayerId, ITimeSlice timeSlice, int intLanguageCode, bool payerReport, bool secondPass)
        {
            var performanceStopWatch = new PerformanceStopWatch();
            performanceStopWatch.Start();

			int intAccountId = root.AccountID;
			IDateRangeSlice accountEffDate = root.AccountEffectiveDate;

			mPayerId = intPayerId;
			mPayerReport = payerReport;
			mSecondPass = secondPass;
			mTimeSlice = timeSlice;
			mLanguageID = intLanguageCode;

			mLogger.LogDebug("ByFolder, accountID = {0}, payerID = {1}, payerReport = {2}, secondPass = {3}",
											 intAccountId, intPayerId, mPayerReport, mSecondPass);
			/*
		mLogger.LogVarArgs(LOG_DEBUG, 
											 "HierarchyReportLevel::InitByFolderReport(%d, %d, %s, %s, %d, %d, %d)",
											 intAccountId, 
											 intPayerId, 
											 NULL == pAccountEffDate.GetInterfacePtr() ? "NULL" : (const char *)pAccountEffDate->ToString(), 
											 NULL == mTimeSlice .GetInterfacePtr() ? "NULL" : (const char *)mTimeSlice->ToString(),
											 intLanguageCode,
											 bPayerReport,
											 bSecondPass);
			*/

			int accountID = intAccountId;

			if (mPayerReport && intAccountId == -1)
			{
				// This is the root of a payer report.  Fetch the corporate account.
				// TODO: The effective date logic here needs to be thought through.

				int corporateId;
				DateTime dtBegin, dtEnd;
				mTimeSlice.GetTimeSpan(out dtBegin, out dtEnd);

				GetLeastCommonAncestorOfPayees(mPayerId, dtBegin, dtEnd, mTimeSlice, out corporateId);

				/*
					if(mLogger.IsOkToLog(LOG_DEBUG))
					{
					mLogger.LogVarArgs(LOG_DEBUG, "By folder bill report for payer id = %d is being "
					"started with least common ancestor of payees = %d calculated "
					"with hierarchy effective date '%s'", mPayerId, corporateId, (const char *)(_bstr_t)(_variant_t(dtEnd, VT_DATE)));
					}
				*/

				// If corporateId == 0, that means I am not paying for anyone.  In
				// this case, just return since I am an empty report.
				if (corporateId == 0)
				{
					root.InitializeSubLevels(new ArrayList());
                    performanceStopWatch.Stop("InitByFolderReport");
					return;
				}

				accountID = corporateId;
			}

			if ((mPayerReport && intAccountId == -1) || (!mPayerReport && accountEffDate == null))
			{
				// We are at the root of a by-folder report.  Record the
				// account slice that describes the summary we are performing.
				// This is different from the account slice that is in the internal_id
				// node; that one describes the account slice used for the "account panel"
				// (by product summaries for a single payee).

				if (!mPayerReport)
				{
					IDescendentPayeeSlice hierarchySlice = new DescendentPayeeSlice();
					hierarchySlice.AncestorID = accountID;
					hierarchySlice.Begin = mNegativeInf;
					hierarchySlice.End = mPositiveInf;

					root.AccountSummarySlice = hierarchySlice;
				}
				else
				{
					IPayerSlice payerSlice = new PayerSlice();
					payerSlice.PayerID = intPayerId;
					
					root.AccountSummarySlice = payerSlice;
				}
			}

			int rowCount = GetAccountSummaryPanel(root, accountID, intPayerId,
																						accountEffDate);

			// Here we are retrieving the by service endpoint summaries for 
			// endpoints beneath vtAccountID (and paid for by vtPayerId if we are a bill report).
			//GetServiceEndpointSummaryPanel(root, accountID, intPayerId);

			// the root open
			root.IsOpen = true;

            performanceStopWatch.Stop("InitByFolderReport");
		}

		// Create a timeslice representing the AND of the argument
		// with the current timeslice.
		public ITimeSlice GetCombinedTimeSlice(ITimeSlice timeSliceIn)
		{
			if (timeSliceIn != null)
			{
				IIntersectionTimeSlice composite = new IntersectionTimeSlice();
				composite.LHS = timeSliceIn;
				composite.RHS = mTimeSlice;
				return composite;
			}
			else
				return mTimeSlice;
		}

		private void InitByProductReport(Level root, int payerID, ITimeSlice timeSlice, int languageCode, bool payerReport, bool secondPass)
    {
            var performanceStopWatch = new PerformanceStopWatch();
            performanceStopWatch.Start();

			// Record who the payer is
			mPayerId = payerID;
			mPayerReport = payerReport;
			mSecondPass = secondPass;
			mTimeSlice = timeSlice;
			mLanguageID = languageCode;

			mLogger.LogDebug("ByProduct, payerID = {0}, payerReport = {1}, secondPass = {2}",
											 payerID, mPayerReport, mSecondPass);

			/*
			mLogger.LogVarArgs(LOG_DEBUG, 
												 "HierarchyReportLevel::InitByProductReport(%d, %s, %d, %d, %d)",
												 intPayerId, 
												 (const char *)mTimeSlice->ToString(),
												 intLanguageCode,
												 bPayerReport,
												 bSecondPass);
			*/

			/*
			if (mPayerReport)
			{
				mLogger.LogVarArgs(LOG_DEBUG, "Creating by product bill report for account id = %d", intPayerId);
			}
			else
			{
				mLogger.LogVarArgs(LOG_DEBUG, "Creating by product hierarchy report for account id = %d", intPayerId);
			}
			*/


			int accountID;
            DateTime dtBegin, dtEnd;
                    
			if (mPayerReport)
			{
				// This is the root of a payer report.  Fetch the corporate account.
				// TODO: The effective date logic here needs to be thought through.
				mTimeSlice.GetTimeSpan(out dtBegin, out dtEnd);
				int corporateId;
				GetCorporateAccount(mPayerId, dtEnd, out corporateId);

				/*
				mLogger.LogVarArgs(LOG_DEBUG, "By product payer report for account id = %d is being "
													 "based on corporate account id = %d", mPayerId, corporateId);
				*/

				accountID = corporateId;
			}
			else
			{
				accountID = payerID;
			}

			// For payer (i.e. bill) reports, we need to generate a total over
			// all accounts and all products.  These used to only be for bills (i.e. payerreport)
			// but in 3.5 we decided to put them on all by-folder reports.


            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                        "\\Queries\\PresServer", mMVMEnabled ? "__GET_ALLPRODUCTSALLACCOUNTS_DATAMART__"
                                                                 : "__GET_ALLPRODUCTSALLACCOUNTS__"))
                {

                    // In 3.5 we decided that we wanted a totals section on the by-folder
                    // reports.
                    if (mPayerReport)
                    {
                        stmt.QueryTag = (mMVMEnabled ? "__GET_ALLPRODUCTSALLACCOUNTSFORPAYER_DATAMART__" : "__GET_ALLPRODUCTSALLACCOUNTSFORPAYER__");
                        stmt.AddParam("%%ID_PAYER%%", payerID);
                    }

                    // Parameters common to both report types
                    stmt.AddParam("%%ID_ACC%%", accountID);
                    stmt.AddParam("%%TIME_PREDICATE%%",
                                                mTimeSlice.GenerateQueryPredicate(), true);
                    stmt.AddParam("%%LIKE_OR_NOT_LIKE%%", mSecondPass ? " NOT LIKE " : " LIKE ");

                    if (!mPayerReport)
                        mTimeSlice.GetTimeSpan(out dtBegin, out dtEnd);
                    else
                    {
                        // For payer reports initialize date range to +- infinity						
                        dtBegin = mNegativeInf;
                        dtEnd = mPositiveInf;
                    }

                    stmt.AddParam("%%DT_BEGIN%%", MetraTime.FormatAsODBC(dtBegin), true);
                    stmt.AddParam("%%DT_END%%", MetraTime.FormatAsODBC(dtEnd), true);

                    // 0 Currency
                    // 1 TotalAmount
                    // 2 TotalFederalTax
                    // 3 TotalStateTax
                    // 4 TotalTax
                    // 5 PrebillAdjustmentAmount
                    // 6 PostbillAdjustmentAmount
                    // 7 PrebillAdjustedAmount
                    // 8 PostbillAdjustedAmount
                    // 9 NumPrebillAdjustments
                    // 10 NumPostbillAdjustments
                    // 11 NumTransactions 

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        // One row per currency.  We only know how to handle a single
                        // currency per account though

                        int totalAmountIdx = reader.GetOrdinal("TotalAmount");
                        int currencyIdx = reader.GetOrdinal("Currency");
                        int prebillAdjustmentAmountIdx = reader.GetOrdinal("PrebillAdjAmt");
                        int postbillAdjustmentAmountIdx = reader.GetOrdinal("PostbillAdjAmt");
                        int prebillTotalTaxAdjustmentAmountIdx = reader.GetOrdinal("PreBillTotalTaxAdjAmt");
                        int postbillTotalTaxAdjustmentAmountIdx = reader.GetOrdinal("PostBillTotalTaxAdjAmt");
                        int prebillFederalTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillFedTaxAdjAmt");
                        int postbillFederalTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillFedTaxAdjAmt");
                        int prebillStateTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillStateTaxAdjAmt");
                        int postbillStateTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillStateTaxAdjAmt");
                        int prebillCountyTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillCntyTaxAdjAmt");
                        int postbillCountyTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillCntyTaxAdjAmt");
                        int prebillLocalTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillLocalTaxAdjAmt");
                        int postbillLocalTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillLocalTaxAdjAmt");
                        int prebillOtherTaxAdjustmentAmountIdx = reader.GetOrdinal("PrebillOtherTaxAdjAmt");
                        int postbillOtherTaxAdjustmentAmountIdx = reader.GetOrdinal("PostbillOtherTaxAdjAmt");

                        int prebillAdjustedAmountIdx = reader.GetOrdinal("PrebillAdjustedAmount");
                        int postbillAdjustedAmountIdx = reader.GetOrdinal("PostbillAdjustedAmount");
                        int federalTaxIdx = reader.GetOrdinal("TotalFederalTax");
                        int stateTaxIdx = reader.GetOrdinal("TotalStateTax");
                        int countyTaxIdx = reader.GetOrdinal("TotalCountyTax");
                        int localTaxIdx = reader.GetOrdinal("TotalLocalTax");
                        int otherTaxIdx = reader.GetOrdinal("TotalOtherTax");
                        int totalTaxIdx = reader.GetOrdinal("TotalTax");
                        int numTransactionsIdx = reader.GetOrdinal("NumTransactions");
                        int numPrebillIdx = reader.GetOrdinal("NumPrebillAdjustments");
                        int numPostbillIdx = reader.GetOrdinal("NumPostbillAdjustments");

                        if (reader.Read())
                        {
                            decimal totalAmount = reader.GetDecimal(totalAmountIdx);
                            string currency = reader.GetString(currencyIdx);
                            decimal prebillAdjustmentAmount = reader.GetDecimal(prebillAdjustmentAmountIdx);
                            decimal postbillAdjustmentAmount = reader.GetDecimal(postbillAdjustmentAmountIdx);
                            decimal prebillTotalTaxAdjustmentAmount = reader.GetDecimal(prebillTotalTaxAdjustmentAmountIdx);
                            decimal prebillFederalTaxAdjustmentAmount = reader.GetDecimal(prebillFederalTaxAdjustmentAmountIdx);
                            decimal prebillStateTaxAdjustmentAmount = reader.GetDecimal(prebillStateTaxAdjustmentAmountIdx);
                            decimal prebillCountyTaxAdjustmentAmount = reader.GetDecimal(prebillCountyTaxAdjustmentAmountIdx);
                            decimal prebillLocalTaxAdjustmentAmount = reader.GetDecimal(prebillLocalTaxAdjustmentAmountIdx);
                            decimal prebillOtherTaxAdjustmentAmount = reader.GetDecimal(prebillOtherTaxAdjustmentAmountIdx);
                            decimal postbillTotalTaxAdjustmentAmount = reader.GetDecimal(postbillTotalTaxAdjustmentAmountIdx);
                            decimal postbillFederalTaxAdjustmentAmount = reader.GetDecimal(postbillFederalTaxAdjustmentAmountIdx);
                            decimal postbillStateTaxAdjustmentAmount = reader.GetDecimal(postbillStateTaxAdjustmentAmountIdx);
                            decimal postbillCountyTaxAdjustmentAmount = reader.GetDecimal(postbillCountyTaxAdjustmentAmountIdx);
                            decimal postbillLocalTaxAdjustmentAmount = reader.GetDecimal(postbillLocalTaxAdjustmentAmountIdx);
                            decimal postbillOtherTaxAdjustmentAmount = reader.GetDecimal(postbillOtherTaxAdjustmentAmountIdx);

                            decimal prebillAdjustedAmount = reader.GetDecimal(prebillAdjustedAmountIdx);
                            decimal postbillAdjustedAmount = reader.GetDecimal(postbillAdjustedAmountIdx);
                            decimal federalTax = reader.GetDecimal(federalTaxIdx);
                            decimal stateTax = reader.GetDecimal(stateTaxIdx);
                            decimal countyTax = reader.GetDecimal(countyTaxIdx);
                            decimal localTax = reader.GetDecimal(localTaxIdx);
                            decimal otherTax = reader.GetDecimal(otherTaxIdx);
                            decimal totalTax = reader.GetDecimal(totalTaxIdx);

                            int numTransactions = reader.GetInt32(numTransactionsIdx);
                            int numPrebill = reader.GetInt32(numPrebillIdx);
                            int numPostbill = reader.GetInt32(numPostbillIdx);

                            root.Amount = LocalizeCurrency(totalAmount, currency);
                            root.Currency = currency;
                            root.PreBillAdjustedAmountAsDecimal = prebillAdjustedAmount;
                            root.PreBillAdjustedAmount = LocalizeCurrency(prebillAdjustedAmount, currency);
                            root.PostBillAdjustedAmount = LocalizeCurrency(postbillAdjustedAmount, currency);
                            root.PreBillAdjustmentAmount = LocalizeCurrency(prebillAdjustmentAmount, currency);
                            root.PostBillAdjustmentAmount = LocalizeCurrency(postbillAdjustmentAmount, currency);

                            root.PreBillTotalTaxAdjustmentAmountAsDecimal = prebillTotalTaxAdjustmentAmount;
                            root.PreBillTotalTaxAdjustmentAmount = LocalizeCurrency(prebillTotalTaxAdjustmentAmount, currency);
                            root.PreBillFederalTaxAdjustmentAmountAsDecimal = prebillFederalTaxAdjustmentAmount;
                            root.PreBillFederalTaxAdjustmentAmount = LocalizeCurrency(prebillFederalTaxAdjustmentAmount, currency);
                            root.PreBillStateTaxAdjustmentAmountAsDecimal = prebillStateTaxAdjustmentAmount;
                            root.PreBillStateTaxAdjustmentAmount = LocalizeCurrency(prebillStateTaxAdjustmentAmount, currency);
                            root.PreBillCountyTaxAdjustmentAmountAsDecimal = prebillCountyTaxAdjustmentAmount;
                            root.PreBillCountyTaxAdjustmentAmount = LocalizeCurrency(prebillCountyTaxAdjustmentAmount, currency);
                            root.PreBillLocalTaxAdjustmentAmountAsDecimal = prebillLocalTaxAdjustmentAmount;
                            root.PreBillLocalTaxAdjustmentAmount = LocalizeCurrency(prebillLocalTaxAdjustmentAmount, currency);
                            root.PreBillOtherTaxAdjustmentAmountAsDecimal = prebillOtherTaxAdjustmentAmount;
                            root.PreBillOtherTaxAdjustmentAmount = LocalizeCurrency(prebillOtherTaxAdjustmentAmount, currency);
                            root.PostBillTotalTaxAdjustmentAmountAsDecimal = postbillTotalTaxAdjustmentAmount;
                            root.PostBillTotalTaxAdjustmentAmount = LocalizeCurrency(postbillTotalTaxAdjustmentAmount, currency);
                            root.PostBillFederalTaxAdjustmentAmountAsDecimal = postbillFederalTaxAdjustmentAmount;
                            root.PostBillFederalTaxAdjustmentAmount = LocalizeCurrency(postbillFederalTaxAdjustmentAmount, currency);
                            root.PostBillStateTaxAdjustmentAmountAsDecimal = postbillStateTaxAdjustmentAmount;
                            root.PostBillStateTaxAdjustmentAmount = LocalizeCurrency(postbillStateTaxAdjustmentAmount, currency);
                            root.PostBillCountyTaxAdjustmentAmountAsDecimal = postbillCountyTaxAdjustmentAmount;
                            root.PostBillCountyTaxAdjustmentAmount = LocalizeCurrency(postbillCountyTaxAdjustmentAmount, currency);
                            root.PostBillLocalTaxAdjustmentAmountAsDecimal = postbillLocalTaxAdjustmentAmount;
                            root.PostBillLocalTaxAdjustmentAmount = LocalizeCurrency(postbillLocalTaxAdjustmentAmount, currency);
                            root.PostBillOtherTaxAdjustmentAmountAsDecimal = postbillOtherTaxAdjustmentAmount;
                            root.PostBillOtherTaxAdjustmentAmount = LocalizeCurrency(postbillOtherTaxAdjustmentAmount, currency);

                            root.NumPreBillAdjustments = numPrebill;
                            root.NumPostBillAdjustments = numPostbill;
                            root.NumTransactions = numTransactions;
                            root.Tax = LocalizeCurrency(totalTax, currency);
                            root.TaxAsDecimal = totalTax;
                            root.FederalTax = LocalizeCurrency(federalTax, currency);
                            root.FederalTaxAsDecimal = federalTax;
                            root.StateTax = LocalizeCurrency(stateTax, currency);
                            root.StateTaxAsDecimal = stateTax;
                            root.CountyTax = LocalizeCurrency(countyTax, currency);
                            root.CountyTaxAsDecimal = countyTax;
                            root.LocalTax = LocalizeCurrency(localTax, currency);
                            root.LocalTaxAsDecimal = localTax;
                            root.OtherTax = LocalizeCurrency(otherTax, currency);
                            root.OtherTaxAsDecimal = otherTax;
                            root.TaxedAmount = LocalizeCurrency(totalAmount + totalTax, currency);

                            root.AmountAsDecimal = totalAmount;
                            root.PostBillAdjustedAmountAsDecimal = postbillAdjustedAmount;
                            root.PreBillAdjustmentAmountAsDecimal = prebillAdjustmentAmount;
                            root.PostBillAdjustmentAmountAsDecimal = postbillAdjustmentAmount;

                            PopulateDisplayAmount(ref root);

                        }
                    }
                }
                // Let's work up the kiddies.  Note that this query will also
                // do a summary for the parent we are dealing with.

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                            "\\Queries\\PresServer", mMVMEnabled ? "__GET_BYPRODUCTALLACCOUNTS_DATAMART__"
                                                                 : "__GET_BYPRODUCTALLACCOUNTS__"))
                {
                    if (mPayerReport)
                    {
                        // Here we are doing a "By-Originator" report but only for charges payed
                        // for by a single account.
                        stmt.QueryTag = (mMVMEnabled ? "__GET_BYPRODUCTALLACCOUNTSFORPAYER_DATAMART__"
                                                                 : "__GET_BYPRODUCTALLACCOUNTSFORPAYER__");
                        stmt.AddParam("%%ID_PAYER%%", payerID);
                    }

                    // Do the common query parameters
                    stmt.AddParam("%%ID_ACC%%", accountID);
                    stmt.AddParam("%%ID_LANG%%", mLanguageID);
                    stmt.AddParam("%%TIME_PREDICATE%%", mTimeSlice.GenerateQueryPredicate(), true);
                    stmt.AddParam("%%LIKE_OR_NOT_LIKE%%", mSecondPass ? " NOT LIKE " : " LIKE ");

                    if (!mPayerReport)
                        mTimeSlice.GetTimeSpan(out dtBegin, out dtEnd);
                    else
                    {
                        // For payer reports initialize date range to +- infinity						
                        dtBegin = mNegativeInf;
                        dtEnd = mPositiveInf;
                    }

                    stmt.AddParam("%%DT_BEGIN%%", MetraTime.FormatAsODBC(dtBegin), true);
                    stmt.AddParam("%%DT_END%%", MetraTime.FormatAsODBC(dtEnd), true);

                    // Create an appropriate account slice for the report and stuff it in
                    // the level element.
                    if (!mPayerReport)
                    {
                        IDescendentPayeeSlice hierarchySlice = new DescendentPayeeSlice();
                        hierarchySlice.AncestorID = accountID;
                        hierarchySlice.Begin = dtBegin;
                        hierarchySlice.End = dtEnd;
                        root.AccountSlice = hierarchySlice;

                        // Also record the account slice used for this report.  It happens to be
                        // the same as the internal_id for by product reports, but it won't be for
                        // by folder reports.
                        root.AccountSummarySlice = hierarchySlice;
                    }
                    else
                    {
                        IPayerSlice payerSlice = new PayerSlice();
                        payerSlice.PayerID = payerID;
                        root.AccountSlice = payerSlice;

                        // Also record the account slice used for this report.  It happens to be
                        // the same as the internal_id for by product reports, but it won't be for
                        // by folder reports.
                        root.AccountSummarySlice = payerSlice;
                    }

                    // ProductOfferingName
                    // PriceableItemName
                    // PriceableItemInstanceName
                    // ViewName
                    // ProductOfferingId
                    // PriceableItemInstanceId
                    // PriceableItemTemplateId
                    // IsAggregate
                    // ViewId
                    // Currency
                    // PriceableItemParentId
                    // TotalAmount
                    // TotalFederalTax
                    // TotalStateTax
                    // PrebillAdjustmentAmount
                    // PostbillAdjustmentAmount
                    // PrebillAdjustedAmount
                    // PostbillAdjustedAmount
                    // NumPrebillAdjustments
                    // NumPostbillAdjustments
                    // NumTransactions 

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        ParseChargeQuery(root, reader);
                    }
                }
                // no sublevels here
                root.InitializeSubLevels(new ArrayList());

            }

			// the root is always open
			root.IsOpen = true;
            performanceStopWatch.Stop("InitByProductReport");
		}

		public void InitializeReport(MetraTech.Interop.MTYAAC.IMTYAAC yaac, ITimeSlice timeSlice, int viewType, bool showSecondPass, bool estimate,
																 IMPSReportInfo reportInfo, int languageID)
		{
			IMPSRenderInfo renderInfo = new MPSRenderInfo();
			Debug.Assert(reportInfo != null);
			mReportInfo = reportInfo;

			int accountID;
			if (reportInfo.AccountIDOverride > 0)
				accountID = reportInfo.AccountIDOverride;
			else
				accountID = yaac.AccountID;

			renderInfo.AccountID = accountID;
			renderInfo.ViewType = (MPS_VIEW_TYPE) viewType;
			renderInfo.TimeSlice = timeSlice;
			renderInfo.LanguageCode = languageID;

			mViewType = (MPS_VIEW_TYPE) viewType;
			mShowSecondPass = showSecondPass;

			//Identify whether or not to show second pass PV data
			// TODO: I don't think this is the right test
			renderInfo.Estimate = showSecondPass ? showSecondPass : estimate;

			mIsEstimate = renderInfo.Estimate;

			Init(renderInfo, reportInfo);
		}

		public IMPSReportInfo ReportInfo
		{
			get
			{ 
				return mReportInfo; 
			}
		}


		public MPS_VIEW_TYPE ViewType
		{
			get
			{ return mViewType; }
		}

		public bool ShowSecondPass
		{
			get
			{ return mShowSecondPass; }
		}

		public bool IsEstimate
		{
			get
			{ return mIsEstimate; }
		}

		

		private void Init(IMPSRenderInfo render, IMPSReportInfo report)
		{
			// this is basically HierarchyReportLevel::Init

			if (render.TimeSlice == null)
				throw new ApplicationException("Must specify time slice for report");

			//Decide based on Report Type and Report View
			mRoot = new Level(true);
			mRoot.CacheID = "";
			
			if (report.Type == MPS_REPORT_TYPE.REPORT_TYPE_BILL)
			{
				// Use second pass of aggregate charges if doing an estimate
				if(render.ViewType == MPS_VIEW_TYPE.VIEW_TYPE_BY_FOLDER)
				{
					mRoot.AccountID = -1;
					mRoot.AccountEffectiveDate = null;
					//InitByFolderReport(-1, render.AccountID, null,
					InitByFolderReport(mRoot, render.AccountID,
														 render.TimeSlice,
														 render.LanguageCode, true,
														 render.Estimate);
				}
				else if(render.ViewType == MPS_VIEW_TYPE.VIEW_TYPE_BY_PRODUCT)
				{
					InitByProductReport(mRoot, render.AccountID, render.TimeSlice, render.LanguageCode, true, render.Estimate);
				}
				else
					Debug.Assert(false, "unrecognized view type");
			}
			else if(report.Type == MPS_REPORT_TYPE.REPORT_TYPE_INTERACTIVE_REPORT)
			{
				// Always use the second pass of aggregate charges if doing a report
				if(render.ViewType == MPS_VIEW_TYPE.VIEW_TYPE_BY_FOLDER)
				{
					mRoot.AccountID = render.AccountID;
					mRoot.AccountEffectiveDate = null;

					//InitByFolderReport(render.AccountID, -1, null,
					InitByFolderReport(mRoot, -1,
														 render.TimeSlice, render.LanguageCode,
														 false, true);
				}
				else if (render.ViewType == MPS_VIEW_TYPE.VIEW_TYPE_BY_PRODUCT)
				{
					InitByProductReport(mRoot, render.AccountID,
															render.TimeSlice,
															render.LanguageCode,
															false, true);
				}
				else
					Debug.Assert(false, "unrecognized view type");
			}
			else
				Debug.Assert(false, "unrecognized report type");
		}

		private string LocalizeCurrency(decimal value, string currency)
		{
			// TODO: handle ZZZ currency?
			return mLocaleTranslator.GetCurrency(value, currency);
		}
		
    // Get current display mode enum, one of the following values:
    //  ONLINE_BILL
    //  ONLINE_BILL_ADJUSTMENTS
    //  ONLINE_BILL_ADJUSTMENTS_TAXES
    //  ONLINE_BILL_TAXES
    //  REPORT
    //  REPORT_ADJUSTMENTS
    //  REPORT_ADJUSTMENTS_TAXES
    //  REPORT_TAXES
    private DisplayModeEnum GetDisplayMode()
    {
      DisplayModeEnum m = DisplayModeEnum.ONLINE_BILL;
     
      if(ReportInfo.Type == MPS_REPORT_TYPE.REPORT_TYPE_INTERACTIVE_REPORT)
      {
        if(ReportInfo.InlineAdjustments)
        {
          if(ReportInfo.InlineVATTaxes)
          {
            m = DisplayModeEnum.REPORT_ADJUSTMENTS_TAXES;
          }
          else
          {
            m = DisplayModeEnum.REPORT_ADJUSTMENTS;
          }
        }
        else
        {
          if(ReportInfo.InlineVATTaxes)
          {
            m = DisplayModeEnum.REPORT_TAXES;
          }
          else
          {
            m = DisplayModeEnum.REPORT;
          }
        }
      }
      else
      {
        if(ReportInfo.InlineAdjustments)
        {
          if(ReportInfo.InlineVATTaxes)
          {
            m = DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS_TAXES;
          }
          else
          {
            m = DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS;
          }
        }
        else
        {
          if(ReportInfo.InlineVATTaxes)
          {
            m = DisplayModeEnum.ONLINE_BILL_TAXES;
          }
          else
          {
            m = DisplayModeEnum.ONLINE_BILL;
          }
        }
      }

      mLogger.LogDebug("Display Mode {0}", m.ToString());
      return m;
    }

		private void PopulateChargeDisplayAmount(ref Charge charge)
		{
			Debug.Assert(this.ReportInfo != null);
			string currency = charge.Currency;
    
      // Here we calculate the DisplayAmount for the charge based on the following
      // DisplayMode matrix:
      // 
      //  --------------------------------------------------------------------------------------------
      //  | Online  | Interactive | Inline      | Inline | Calculated
      //  | Bill    | Report      | Adjustments | Taxes  | Display Amount 
      //  ---------------------------------------------------------------------------------------------
      //  |    X    |             |     X       |   X    | Amount + TotalTax +  PreBillAdjustmentAmount
      //  |         |             |             |        | + PreBillTotalTaxAdjustmentAmount 
      //  ---------------------------------------------------------------------------------------------
      //  |    X    |             |     X       |        | Amount + PreBillAdjustmentAmount
      //  ---------------------------------------------------------------------------------------------
      //  |    X    |             |             |   X    | Amount + TotalTax
      //  ---------------------------------------------------------------------------------------------
      //  |    X    |             |             |        | Amount
      //  ---------------------------------------------------------------------------------------------
      //  |         |     X       |     X       |   X    | Amount + TotalTax + PostBillAdjustmentAmount
      //  |         |             |             |        | + PostBillTotalTaxAdjustmentAmount 
      //  |         |             |             |        | + PreBillAdjustmentAmount 
      //  |         |             |             |        | + PreBillTotalTaxAdjustmentAmount
      //  ---------------------------------------------------------------------------------------------
      //  |         |     X       |     X       |        | Amount + PostBillAdjustmentAmount 
      //  |         |             |             |        | + PreBillAdjustmentAmount 
      //  ---------------------------------------------------------------------------------------------
      //  |         |     X       |             |   X    | Amount + TotalTax + PostBillAdjustmentAmount
      //  |         |             |             |        | + PostBillTotalTaxAdjustmentAmount 
      //  |         |             |             |        | + PreBillAdjustmentAmount 
      //  |         |             |             |        | + PreBillTotalTaxAdjustmentAmount    
      //  ---------------------------------------------------------------------------------------------
      //  |         |     X       |             |        | Amount + PostBillAdjustmentAmount
      //  |         |             |             |        | + PreBillAdjustmentAmount
      //  ---------------------------------------------------------------------------------------------
      mDisplayMode = GetDisplayMode();
		
      switch(mDisplayMode)
      {
        // ONLINE_BILL
        case DisplayModeEnum.ONLINE_BILL:
			charge.DisplayAmountAsDecimal = charge.AmountAsDecimal;
          break;

        // ONLINE_BILL_ADJUSTMENTS
        case DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS:
          charge.DisplayAmountAsDecimal = charge.AmountAsDecimal +
                                          charge.PreBillAdjustmentAmountAsDecimal;
          break;

        // ONLINE_BILL_ADJUSTMENTS_TAXES
        case DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS_TAXES:
          charge.DisplayAmountAsDecimal = charge.AmountAsDecimal +
                                          charge.TaxAsDecimal +
                                          charge.PreBillAdjustmentAmountAsDecimal +
                                          charge.PreBillTotalTaxAdjustmentAmountAsDecimal;
          break;

        // ONLINE_BILL_TAXES
        case DisplayModeEnum.ONLINE_BILL_TAXES:
          charge.DisplayAmountAsDecimal = charge.AmountAsDecimal +
                                          charge.TaxAsDecimal;
          break;

        // REPORT
        case DisplayModeEnum.REPORT:
          charge.DisplayAmountAsDecimal = charge.AmountAsDecimal +
                                          charge.PostBillAdjustmentAmountAsDecimal +
                                          charge.PreBillAdjustmentAmountAsDecimal;
          break;

        // REPORT_ADJUSTMENTS
        case DisplayModeEnum.REPORT_ADJUSTMENTS:
          charge.DisplayAmountAsDecimal = charge.AmountAsDecimal + 
                                          charge.PostBillAdjustmentAmountAsDecimal +
                                          charge.PreBillAdjustmentAmountAsDecimal;
          break;

        // REPORT_ADJUSTMENTS_TAXES
        case DisplayModeEnum.REPORT_ADJUSTMENTS_TAXES:
          charge.DisplayAmountAsDecimal = charge.AmountAsDecimal + 
                                          charge.TaxAsDecimal +
                                          charge.PostBillAdjustmentAmountAsDecimal + 
                                          charge.PostBillTotalTaxAdjustmentAmountAsDecimal +
                                          charge.PreBillAdjustmentAmountAsDecimal +
                                          charge.PreBillTotalTaxAdjustmentAmountAsDecimal;
          break;

        // REPORT_TAXES
        case DisplayModeEnum.REPORT_TAXES:
          charge.DisplayAmountAsDecimal = charge.AmountAsDecimal + 
                                          charge.TaxAsDecimal +
                                          charge.PostBillAdjustmentAmountAsDecimal + 
                                          charge.PostBillTotalTaxAdjustmentAmountAsDecimal +
                                          charge.PreBillAdjustmentAmountAsDecimal +
                                          charge.PreBillTotalTaxAdjustmentAmountAsDecimal;
          break;
				
        // Invalid Display Mode
        default:
          mLogger.LogDebug("Unrecognized display mode");
          Debug.Assert(false, "Unrecognized display mode");
          break;
      }
				charge.DisplayAmount =LocalizeCurrency(charge.DisplayAmountAsDecimal, currency);

			}
    
    private void PopulatePreBillAdjustmentDisplayAmount(Level level)
			{
			Debug.Assert(this.ReportInfo != null);
			string currency = level.Currency;

      decimal d = 0.0M;
			if(ReportInfo.InlineVATTaxes)
			{
        d = level.PreBillAdjustmentAmountAsDecimal + level.PreBillTotalTaxAdjustmentAmountAsDecimal;
      }
      else
      {
        d = level.PreBillAdjustmentAmountAsDecimal;
			}
		
      level.PreBillAdjustmentDisplayAmountAsDecimal = d;
      level.PreBillAdjustmentDisplayAmount = LocalizeCurrency(level.PreBillAdjustmentDisplayAmountAsDecimal, currency);
		}

		private void PopulateDisplayAmount(ref Level level)
		{
			Debug.Assert(this.ReportInfo != null);
			string currency = level.Currency;
			
      // We keep track of the adjustments and tax for each case so we
      // can set Total Current Charges at the end.
			decimal adjustmentAmount = 0.0M;
			decimal taxAmount = 0.0M;
      decimal ajTaxAmount = 0.0M;

      // Here we calculate the DisplayAmount for the level based on the
      // DisplayMode Matrix.  (See matrix comment in PopulateChargeDisplayAmount method)
      mDisplayMode = GetDisplayMode();
		  
      switch(mDisplayMode)
			{
          // ONLINE_BILL
        case DisplayModeEnum.ONLINE_BILL:
          level.DisplayAmountAsDecimal = level.AmountAsDecimal;

				adjustmentAmount = level.PreBillAdjustmentAmountAsDecimal;
          taxAmount = level.TaxAsDecimal;
          ajTaxAmount = level.PreBillTotalTaxAdjustmentAmountAsDecimal;
          break;

          // ONLINE_BILL_ADJUSTMENTS
        case DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS:
          level.DisplayAmountAsDecimal = level.AmountAsDecimal +
                                         level.PreBillAdjustmentAmountAsDecimal;

          adjustmentAmount = level.PreBillAdjustmentAmountAsDecimal;
          taxAmount = level.TaxAsDecimal;
          ajTaxAmount = level.PreBillTotalTaxAdjustmentAmountAsDecimal;
          break;

          // ONLINE_BILL_ADJUSTMENTS_TAXES
        case DisplayModeEnum.ONLINE_BILL_ADJUSTMENTS_TAXES:
          level.DisplayAmountAsDecimal = level.AmountAsDecimal +
                                         level.TaxAsDecimal +
                                         level.PreBillAdjustmentAmountAsDecimal +
                                         level.PreBillTotalTaxAdjustmentAmountAsDecimal;

          adjustmentAmount = level.PreBillAdjustmentAmountAsDecimal;
          taxAmount = level.TaxAsDecimal;
          ajTaxAmount = level.PreBillTotalTaxAdjustmentAmountAsDecimal;
          break;

          // ONLINE_BILL_TAXES
        case DisplayModeEnum.ONLINE_BILL_TAXES:
          level.DisplayAmountAsDecimal = level.AmountAsDecimal +
                                         level.TaxAsDecimal;

          adjustmentAmount = level.PreBillAdjustmentAmountAsDecimal;
          taxAmount = level.TaxAsDecimal;
          ajTaxAmount = level.PreBillTotalTaxAdjustmentAmountAsDecimal;
          break;

          // REPORT
        case DisplayModeEnum.REPORT:
          level.DisplayAmountAsDecimal = level.AmountAsDecimal +
                                         level.PostBillAdjustmentAmountAsDecimal +
                                         level.PreBillAdjustmentAmountAsDecimal;

          adjustmentAmount = level.PreBillAdjustmentAmountAsDecimal + 
                             level.PostBillAdjustmentAmountAsDecimal;
          taxAmount = level.TaxAsDecimal;
          ajTaxAmount = level.PreBillTotalTaxAdjustmentAmountAsDecimal +
                        level.PostBillTotalTaxAdjustmentAmountAsDecimal;
          break;

          // REPORT_ADJUSTMENTS
        case DisplayModeEnum.REPORT_ADJUSTMENTS:
          level.DisplayAmountAsDecimal = level.AmountAsDecimal +
                                         level.PostBillAdjustmentAmountAsDecimal +
                                         level.PreBillAdjustmentAmountAsDecimal;

          adjustmentAmount = level.PreBillAdjustmentAmountAsDecimal + 
                             level.PostBillAdjustmentAmountAsDecimal;
          taxAmount = level.TaxAsDecimal;
          ajTaxAmount = level.PreBillTotalTaxAdjustmentAmountAsDecimal +
                        level.PostBillTotalTaxAdjustmentAmountAsDecimal;
          break;

          // REPORT_ADJUSTMENTS_TAXES
        case DisplayModeEnum.REPORT_ADJUSTMENTS_TAXES:
          level.DisplayAmountAsDecimal = level.AmountAsDecimal + 
                                         level.TaxAsDecimal +
                                         level.PostBillAdjustmentAmountAsDecimal + 
                                         level.PostBillTotalTaxAdjustmentAmountAsDecimal +
                                         level.PreBillAdjustmentAmountAsDecimal +
                                         level.PreBillTotalTaxAdjustmentAmountAsDecimal;
          
          adjustmentAmount = level.PreBillAdjustmentAmountAsDecimal + 
                             level.PostBillAdjustmentAmountAsDecimal;
          taxAmount = level.TaxAsDecimal;
          ajTaxAmount = level.PreBillTotalTaxAdjustmentAmountAsDecimal +
                        level.PostBillTotalTaxAdjustmentAmountAsDecimal;
          break;

          // REPORT_TAXES
        case DisplayModeEnum.REPORT_TAXES:
          level.DisplayAmountAsDecimal = level.AmountAsDecimal + 
                                         level.TaxAsDecimal +
                                         level.PostBillAdjustmentAmountAsDecimal + 
                                         level.PostBillTotalTaxAdjustmentAmountAsDecimal +
                                         level.PreBillAdjustmentAmountAsDecimal +
                                         level.PreBillTotalTaxAdjustmentAmountAsDecimal;

          adjustmentAmount = level.PreBillAdjustmentAmountAsDecimal + 
                             level.PostBillAdjustmentAmountAsDecimal;
				taxAmount = level.TaxAsDecimal;
          ajTaxAmount = level.PreBillTotalTaxAdjustmentAmountAsDecimal +
                        level.PostBillTotalTaxAdjustmentAmountAsDecimal;
          break;

          // Invalid Display Mode
        default:
          mLogger.LogDebug("Unrecognized display mode");
          Debug.Assert(false, "Unrecognized display mode");
          break;
			}
      level.DisplayAmount = LocalizeCurrency(level.DisplayAmountAsDecimal, currency);

			//Now initialize TotalDisplayAmount. It's a helper property that MetraView uses
			//in "Total Current Charges" field. 
			level.TotalDisplayAmountAsDecimal = level.AmountAsDecimal + adjustmentAmount + taxAmount + ajTaxAmount;
			level.TotalDisplayAmount = LocalizeCurrency(level.TotalDisplayAmountAsDecimal, currency);
		}

	
		private MetraTech.Interop.COMDBObjects.ICOMLocaleTranslator mLocaleTranslator = new MetraTech.Interop.COMDBObjects.COMLocaleTranslator();
		private Logger mLogger;
		private Logger mPerfLogger;
		private Level mRoot;
		private int mPayerId;
		private bool mPayerReport;
		private bool mSecondPass;
		private ITimeSlice mTimeSlice;
		private int mLanguageID;
		private MPS_VIEW_TYPE mViewType;
		private bool mShowSecondPass;
		private bool mIsEstimate;

		private IMPSReportInfo mReportInfo = null;
    
		// NOTE: these constants copied from HierarchyReportLevel.  I assume they have special meaning
		private DateTime mNegativeInf = DateTime.FromOADate(25569.00);
		private DateTime mPositiveInf = DateTime.FromOADate(50406.00);

    private DisplayModeEnum mDisplayMode;
    enum DisplayModeEnum 
    {
      ONLINE_BILL,
      ONLINE_BILL_ADJUSTMENTS,
      ONLINE_BILL_ADJUSTMENTS_TAXES,
      ONLINE_BILL_TAXES,
      REPORT,
      REPORT_ADJUSTMENTS,
      REPORT_ADJUSTMENTS_TAXES,
      REPORT_TAXES,
	}

	}
  #endregion

  #region ShowReport Class
	// utilities to generate a MetraView report
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("bdd88fc2-c9d6-446e-a072-8e9f612261cb")]
	public class ShowReport : IShowReport
	{
		public void Setup(string culture)
		{
      mCulture = new CultureInfo("en-US");
		}

		public void WriteCurrency()
		{
      decimal dec = 100.23M;

			for (int i = 0; i < 100; i++)
			{
				// Create a CultureInfo object for English in the U.S.

				// Display i formatted as currency for us.
				Console.WriteLine(dec.ToString("c", mCulture));
			}
		}

		public int TickCount
		{ get { return Environment.TickCount; } }

		private CultureInfo mCulture;
	}
  #endregion

}

