using System;
using System.Collections;
using System.Collections.Generic;

//using MetraTech.Interop.MTAuthExec;
//using MetraTech.Adjustments;
using MetraTech.Interop.GenericCollection;
using  RS = MetraTech.Interop.Rowset;
using MetraTech.Interop.MTProductCatalog;
using MetraTech;
using MetraTech.MTSQL;
using MetraTech.Interop.MTAuditEvents;
using System.Runtime.InteropServices;
using MetraTech.DataAccess;
using MetraTech.Utils;
using MetraTech.Interop.QueryAdapter;

namespace MetraTech.Adjustments
{
  [Guid("0b830500-aa21-4bb2-a124-441cea780986")]
  public enum AdjustmentKind {FLAT=1, PERCENT, MINUTES, REBILL};

  [Guid("9c94674d-07d7-49ce-a0a2-42753283a846")]
  public enum AdjustmentStatus {NOT_ADJUSTED, APPROVED, PENDING, DELETED, AUTODELETED, ORPHAN, PREBILL_REBILL};
  //NOT_ADJUSTED == 'NA'
  //APPROVED == 'A'
  //PENDING == 'P'
  //DELETED == 'D'
  //AUTODELETED == 'AD'
  //ORPHAN == 'O'


  [Guid("3df7c474-58ba-4131-aff0-ebe550181de8")]
  public interface IAdjustmentType : IMTPCBase
  {
    IAdjustmentTransactionSet CreateAdjustmentTransactions(object aSessions);//MetraTech.Interop.GenericCollection.IMTCollection aSessions);
    IAdjustmentTransactionSet CreateAdjustmentTransactionsForChildren(object aSessions);//MetraTech.Interop.GenericCollection.IMTCollection aSessions);
    IAdjustment CreateAdjustmentTemplate(MetraTech.Interop.MTProductCatalog.IMTPriceableItem aTemplate);
    IAdjustment CreateAdjustmentInstance(MetraTech.Interop.MTProductCatalog.IMTPriceableItem aInstance);
    MetraTech.Interop.GenericCollection.IMTCollection GetApplicabilityRules();
	void SetApplicabilityRules(MetraTech.Interop.GenericCollection.IMTCollection aRules);
    
    MetraTech.Interop.Rowset.IMTRowSet SaveAdjustments(IAdjustmentTransactionSet aSet,
      object ProgressObj);
    void AddApplicabilityRule(IApplicabilityRule aRule);
    
    int Save();
    MetraTech.Interop.Rowset.IMTRowSet Calculate(IAdjustmentTransactionSet aSet, object ProgressObj);
    MetraTech.Interop.MTProductCatalog.IMTProperties CreateInputProperties();
    MetraTech.Interop.MTProductCatalog.IMTProperties CreateOutputProperties();
    
    IMTPropertyMetaDataSet ExpectedOutputs
    {
      get;
    }
    IMTPropertyMetaDataSet RequiredInputs
    {
      get;
    }
    
    ICalculationFormula AdjustmentFormula
    {
      set; get;
    }
		bool IsCompositeType
		{
			get;
		}
    bool SupportsBulk
    {
      set; get;
    }
    bool HasParent
    {
	  set; get;
    }
    string AdjustmentTable
    {
      set; get;
    }
	string PIName
	{
	  set; get;
	}
    int  PriceableItemTypeID
    {
      set; get;
    }
    AdjustmentKind Kind
    {
      get;set;
    }

	MetraTech.Interop.GenericCollection.IMTCollection ChildAdjustmentCollection
	{
	  get;set;
	}

    IAdjustmentDescription DefaultAdjustmentDescription
    {
      get;set;
    }

    //INamedBaseProperty
    [DispId(0)]
    int ID
    {
      set; get;
    }
    string GUID
    {
      set; get;
    }
    string Name
    {
      set; get;
    }
    string Description
    {
      set; get;
    }
    string DisplayName
    {
      set; get;
    }
    

    //IMTPCBase
    new void SetSessionContext(MetraTech.Interop.MTProductCatalog.IMTSessionContext aCtx);
    new MetraTech.Interop.MTProductCatalog.IMTSessionContext GetSessionContext();

    //IMTProperties
    IMTProperties Properties
    {
      get;
    }
  }
  
  /// <summary>
  /// Summary description for AdjustmentType.
  /// </summary>
  /// 
  [Guid("4d84e868-ed8f-493d-b430-44b2ecf5815b")]
  [ClassInterface(ClassInterfaceType.None)]
  public class AdjustmentType : NamedBaseProperty,  IAdjustmentType, IMTPCBase
  {
    public AdjustmentType() : base(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE)
    {
      mInputPropsMetadata = new MTPropertyMetaDataSetClass();
      mOutputPropsMetadata = new MTPropertyMetaDataSetClass();
      mApplicabilityRules = new MTCollectionClass();
      mDefaultDesc = null;
    }
    public AdjustmentType(MetraTech.Interop.MTProductCatalog.IMTSessionContext aCTX) : base(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE)
    {
      SetSessionContext(aCTX);
      mInputPropsMetadata = new MTPropertyMetaDataSetClass();
      mOutputPropsMetadata = new MTPropertyMetaDataSetClass();
      LoadPropertiesMetaData(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE);
    }
    public IAdjustmentType GetAsIAdjustment()
    {
      return this;
    }
    public IAdjustment CreateAdjustmentTemplate(MetraTech.Interop.MTProductCatalog.IMTPriceableItem aTemplate)
    {
      IAdjustment template = new Adjustment();
      template.AdjustmentType = this;
      CloneBaseProps(this, template, false);
      if(!aTemplate.IsTemplate())
        throw new AdjustmentException("Priceable Item not a template");
      ((Adjustment)template).PriceableItem = aTemplate;
      template.SetSessionContext(aTemplate.GetSessionContext());
      return template;
    }
    public IAdjustment CreateAdjustmentInstance(MetraTech.Interop.MTProductCatalog.IMTPriceableItem aInstance)
    {
      IAdjustment instance = new Adjustment();
      instance.AdjustmentType = this;
      CloneBaseProps(this, instance, true);
      if(aInstance.IsTemplate())
        throw new AdjustmentException("Priceable Item not an instance");
      ((Adjustment)instance).PriceableItem = aInstance;
      return instance;
    }
    
    /// <summary>
    /// Pass aSessions in as an object, because of the problems with calling it
    /// from VBscript through Dispatch
    /// 
    /// </summary>
    /// <param name="aSessions"></param>
    /// <returns></returns>
    public IAdjustmentTransactionSet CreateAdjustmentTransactions(object aSessions)//MetraTech.Interop.GenericCollection.IMTCollection aSessions)
    {
      MetraTech.Interop.GenericCollection.IMTCollection sessions = (MetraTech.Interop.GenericCollection.IMTCollection)aSessions;

      IAdjustmentTransactionSet trxset = new AdjustmentTransactionSet();
      ((AdjustmentTransactionSet)trxset).AdjustmentType = this;
      trxset.Initialize((IMTSessionContext)GetSessionContext(), sessions, false);
      return trxset;
    }

    /// <summary>
    /// Pass aSessions in as an object, because of the problems with calling it
    /// from VBscript through Dispatch
    /// 
    /// </summary>
    /// <param name="aSessions"></param>
    /// <returns></returns>
    public IAdjustmentTransactionSet CreateAdjustmentTransactionsForChildren(object aSessions)//MetraTech.Interop.GenericCollection.IMTCollection aSessions)
    {
      MetraTech.Interop.GenericCollection.IMTCollection sessions = (MetraTech.Interop.GenericCollection.IMTCollection)aSessions;

      //if(sessions.Count > 1)
      //  throw new AdjustmentException("Only one parent record is supported for bulk children adjustments!");
      IAdjustmentTransactionSet trxset = new AdjustmentTransactionSet();
      ((AdjustmentTransactionSet)trxset).AdjustmentType = this;
      trxset.Initialize((IMTSessionContext)GetSessionContext(), sessions, true);
      return trxset;
    }


    private IAdjustmentDescription mDefaultDesc;
    public IAdjustmentDescription DefaultAdjustmentDescription
    {
      get{return mDefaultDesc;}
      set{mDefaultDesc = value;}
    }
    
    
		private int mPiTypeID;
    public int PriceableItemTypeID
    {
      get 
      { 
        return mPiTypeID; 
      }
      set 
      { 
        mPiTypeID = value; 
      }
    }
		
    public MetraTech.Interop.Rowset.IMTRowSet SaveAdjustments(IAdjustmentTransactionSet aSet,
      object ProgressObj)
    {
      IAdjustmentTypeWriter writer = new AdjustmentTypeWriter();
      string capname = "Apply Adjustments";
      uint MTAUTH_ACCESS_DENIED = 0xE29F0001;
      MTAuditEntityType entity = MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT;

      
      //Determine if the caller can perform "Apply Adjustments" operation
			MetraTech.Interop.MTAuthExec.IMTCompositeCapabilityTypeReader capReader = 
													new MetraTech.Interop.MTAuthExec.MTCompositeCapabilityTypeReaderClass();

      MetraTech.Interop.MTAuth.IMTCompositeCapability requiredCap = 
        ((MetraTech.Interop.MTAuth.IMTCompositeCapabilityType)capReader.GetByName(capname)).CreateInstance();
      MetraTech.Interop.MTAuth.IMTSecurityContext ctx = (MetraTech.Interop.MTAuth.IMTSecurityContext)GetSessionContext().SecurityContext;
      //check Auth and audit failures
      try
      {
        ctx.CheckAccess(requiredCap);
      }
      catch(COMException ex)
      {
        if((uint)ex.ErrorCode == MTAUTH_ACCESS_DENIED)
        {
          foreach(IAdjustmentTransaction trx in aSet.GetAdjustmentTransactions())
          {
            MTAuditEvent auditevent = trx.IsPrebill ? 
              MTAuditEvent.AUDITEVENT_PREBILL_ADJUSTMENT_CREATE_DENIED :
              MTAuditEvent.AUDITEVENT_POSTBILL_ADJUSTMENT_CREATE_DENIED;

            AdjustmentCache.GetInstance().GetAuditor().FireEvent
              (
              (int)auditevent,
              GetSessionContext() != null ? GetSessionContext().AccountID : -1,
              (int)entity,
			  TypeConverter.ConvertInteger(trx.UsageRecord["id_acc"]),
              trx.Description
              );
          }
          throw;
        }
        throw;
      }
      
      return writer.CreateAdjustmentRecords(
        (IMTSessionContext)GetSessionContext(), 
        aSet, 
        this, 
        ProgressObj);
    }
		
    public int Save()
    {
      IAdjustmentTypeWriter writer = new AdjustmentTypeWriter();
      //for now try look it up by name and mark for update here
      IAdjustmentTypeReader reader = new AdjustmentTypeReader();
      IAdjustmentType existingtype = 
        reader.FindAdjustmentTypeByName
        ((IMTSessionContext)GetSessionContext(), this.Name);
      if (existingtype != null)
      {
        AdjustmentFormula.ID = existingtype.AdjustmentFormula.ID;
        ID = existingtype.ID;
      }
      if(HasID())
        return writer.Create((IMTSessionContext)GetSessionContext(), this);
      else
      {
        writer.Update((IMTSessionContext)GetSessionContext(), this);
        return GetID();
      }
    }
    public MetraTech.Interop.GenericCollection.IMTCollection GetApplicabilityRules()
    {
      return mApplicabilityRules;
    }

    public void SetApplicabilityRules(MetraTech.Interop.GenericCollection.IMTCollection aRules)
    {
		mApplicabilityRules = aRules;
    }

    
		public MetraTech.Interop.Rowset.IMTRowSet Calculate(IAdjustmentTransactionSet aSet, object ProgressObj)
		{
			RS.IMTSQLRowset warnings = Utils.CreateWarningsRowset();
			IMTProductCatalog prodcat;
			AdjustmentFormula.Compile();
			((AdjustmentTransactionSet)aSet).ClearOutputs();
			IMTProperties TrxSetOutputs  = aSet.Outputs;
			prodcat = new MTProductCatalogClass();
			prodcat.SetSessionContext((IMTSessionContext)GetSessionContext());

            MTCurrencyConverter converter = new MTCurrencyConverter();

            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
            {
                queryAdapter.Item = new MTQueryAdapter();
                queryAdapter.Item.Init("queries\\Adjustments");
                queryAdapter.Item.SetQueryTag("__GET_DIVISION_CURRENCY_FOR_USAGE__");

                foreach (IAdjustmentTransaction instance in aSet.GetAdjustmentTransactions())
                {
                    instance.Inputs = aSet.Inputs;
                    instance.Outputs = aSet.Outputs;
                    decimal dTotal = 0.0M;
                    bool bAtLeastOneCharge = false;


                    //check business rule
                    //not every instance selected can be actually adjusted:

                    //1. Id Interval is Open and the transaction was previously adjusted
                    try
                    {
                        //CR 9662 fix: reset Adjustable flag when recalculating
                        ((AdjustmentTransaction)instance).IsAdjustable = true;

                        //2. If Interval is soft closed, can not adjust
                        if (instance.IsIntervalSoftClosed)
                        {
                            throw new SoftClosedIntervalException((int)instance.UsageRecord["id_usage_interval"], instance.SessionID);
                        }

                        if (instance.IsPrebill && instance.IsPrebillAdjusted)
                        {
                            throw new SecondPrebillAdjustmentException(instance.SessionID);
                        }


                        //2. Id Interval is Open and the transaction was previously adjusted
                        if (instance.IsPostbillAdjusted)
                        {
                            throw new SecondPostbillAdjustmentException(instance.SessionID);
                        }

                        //3. Check all applicability rules
                        foreach (IApplicabilityRule rule in mApplicabilityRules)
                        {
                            if (!rule.IsApplicable(instance))
                                throw new AdjustmentApplicabilityException(instance.SessionID, rule.Name);
                        }

                        //4. CR 11284: If this session is aprat of compound which has been postbill reassigned
                        if (instance.IsParentSessionPostbillRebilled)
                        {
                            throw new ParentSessionPostbillReassignedException(instance.SessionID);
                        }



                        //pass this instance to CalculationFormula for execution
                        AdjustmentFormula.Execute(instance);

                        // Get the division currency for the session
                        string amountCurrency = null;
                        using (IMTConnection conn = ConnectionManager.CreateConnection())
                        {
                            using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {
                                prepStmt.AddParam("sessionId", MTParameterType.BigInteger, instance.SessionID);

                                using (IMTDataReader rdr = prepStmt.ExecuteReader())
                                {
                                    if (rdr.Read())
                                    {
                                        if (!rdr.IsDBNull(0))
                                        {
                                            amountCurrency = rdr.GetString(0);
                                        }

                                        if (!rdr.IsDBNull(1))
                                        {
                                            ((AdjustmentTransaction)instance).DivisionCurrency = rdr.GetString(1);
                                        }
                                    }
                                }
                            }
                        }


                        //set outputs back on the transaction
                        IMTProperties outputs = instance.Outputs;
                        foreach (Parameter param in AdjustmentFormula.Parameters.Values)
                        {
                            string name = param.Name;
                            if (param.Direction == ParameterDirection.Out)
                            {
                                if (!outputs.Exist(name))
                                    throw new AdjustmentException(System.String.Format("Output Property {0} is required.", name));
                                ((IMTProperty)outputs[name]).Value = param.Value;
                                if (name.ToUpper().CompareTo("TOTALADJUSTMENTAMOUNT") == 0)
                                    instance.TotalAdjustmentAmount = System.Convert.ToDecimal(param.Value);
                                else if (name.ToUpper().StartsWith("AJ_TAX"))
                                {
                                    decimal val = TypeConverter.ConvertDecimal(param.Value);
                                    if (name.ToUpper().EndsWith("FEDERAL"))
                                    {
                                        instance.FederalTaxAdjustmentAmount = System.Convert.ToDecimal(val);
                                    }
                                    else if (name.ToUpper().EndsWith("STATE"))
                                    {
                                        instance.StateTaxAdjustmentAmount = System.Convert.ToDecimal(val);
                                    }
                                    else if (name.ToUpper().EndsWith("COUNTY"))
                                    {
                                        instance.CountyTaxAdjustmentAmount = System.Convert.ToDecimal(val);
                                    }
                                    else if (name.ToUpper().EndsWith("LOCAL"))
                                    {
                                        instance.LocalTaxAdjustmentAmount = System.Convert.ToDecimal(val);
                                    }
                                    else if (name.ToUpper().EndsWith("OTHER"))
                                    {
                                        instance.OtherTaxAdjustmentAmount = System.Convert.ToDecimal(val);
                                    }

                                }
                                else
                                {
                                    bAtLeastOneCharge = (name.StartsWith("AJ"));
                                    dTotal += System.Convert.ToDecimal(param.Value);

                                    if (!string.IsNullOrEmpty(instance.DivisionCurrency))
                                    {
                                        ((AdjustmentTransaction)instance).DivisionAmount += converter.ConvertCurrency(amountCurrency, System.Convert.ToDecimal(param.Value), instance.DivisionCurrency, MetraTime.Now);
                                    }
                                }
                            }
                        }

                        //set TotalTaxAdjustmentAmount here because it's never set in the formula
                        //and only required for display purposes
                        ((IMTProperty)outputs["TotalTaxAdjustmentAmount"]).Value = instance.TotalTaxAdjustmentAmount;

                        //compare TotalAdjustmentAmount to running total
                        //only if there was at least one charge property on this adjustment type
                        //and if the type is not rebill

                        //CR 9756: round before comparing
                        //CR 11316: add a small fuzz factor before rounding. We need this to 
                        //force Math.Round to round to greatest as opposed to bankers rounding
                        dTotal = System.Math.Round(dTotal + 0.000000001m, 2);
                        if (bAtLeastOneCharge)
                        {
                            if (this.Kind != AdjustmentKind.REBILL && dTotal != instance.TotalAdjustmentAmount)
                                throw new TotalAdjustmentAmountException(dTotal, instance.TotalAdjustmentAmount);
                        }

                        //CR 11285: Do not save adjustments if adjustment amount is 0
                        //CR 12119: Do save adjsutments if amount is 0 but this is Rebill. we need it to keep track of rebills done
                        if (instance.TotalAdjustmentAmount == 0.0M && this.Kind != AdjustmentKind.REBILL)
                            throw new AdjustmentZeroAmountException(instance.SessionID);

                        //See if resulting adjusted amount is actually more then the original charge amount
                        //and if it is, then check the business rule
                        decimal decOriginalAmount = System.Convert.ToDecimal(instance.UsageRecord["atomicprebilladjedamt"]);
                        if (instance.TotalAdjustmentAmount > decOriginalAmount)
                        {
                            MTPC_BUSINESS_RULE rule =
                                MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Adjustments_NoGreaterThanCharge;
                            if (prodcat.IsBusinessRuleEnabled(rule))
                                throw new NoGreaterThanChargeBusinessRuleException
                                    (instance.SessionID, MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Adjustments_NoGreaterThanCharge, instance.TotalAdjustmentAmount, decOriginalAmount);
                        }
                        instance.Outputs = outputs;

                        //keep running total at transaction set level
                        //TODO: don't do it for strings, booleans etc (hopefully there is none)
                        foreach (IMTProperty outpprop in instance.Outputs)
                        {
                            switch (outpprop.DataType)
                            {
                                case PropValType.PROP_TYPE_DECIMAL:
                                    {
                                        decimal val = TypeConverter.ConvertDecimal(((IMTProperty)TrxSetOutputs[outpprop.Name]).Value);
                                        decimal increment = TypeConverter.ConvertDecimal(outpprop.Value);
                                        ((IMTProperty)TrxSetOutputs[outpprop.Name]).Value = (val + increment);
                                        break;
                                    }
                                case PropValType.PROP_TYPE_DOUBLE:
                                    {
                                        double val = TypeConverter.ConvertDouble(((IMTProperty)TrxSetOutputs[outpprop.Name]).Value);
                                        double increment = TypeConverter.ConvertDouble(outpprop.Value);
                                        ((IMTProperty)TrxSetOutputs[outpprop.Name]).Value = (val + increment);
                                        break;
                                    }
                                case PropValType.PROP_TYPE_INTEGER:
                                    {
                                        Int32 val = TypeConverter.ConvertInteger(((IMTProperty)TrxSetOutputs[outpprop.Name]).Value);
                                        Int32 increment = TypeConverter.ConvertInteger(outpprop.Value);
                                        ((IMTProperty)TrxSetOutputs[outpprop.Name]).Value = (val + increment);
                                        break;
                                    }
                                case PropValType.PROP_TYPE_BIGINTEGER:
                                    {
                                        Int64 val = TypeConverter.ConvertLong(((IMTProperty)TrxSetOutputs[outpprop.Name]).Value);
                                        Int64 increment = TypeConverter.ConvertLong(outpprop.Value);
                                        ((IMTProperty)TrxSetOutputs[outpprop.Name]).Value = (val + increment);
                                        break;
                                    }

                            }

                        }
                    }
                    catch (Exception ex)
                    {
                        warnings.AddRow();
                        warnings.AddColumnData("id_sess", instance.SessionID);
                        if (ex is AdjustmentException)
                            warnings.AddColumnData("description", ex.Message);
                        //if it's some kind of a lower level exception, print more
                        else
                        {
                            warnings.AddColumnData("description", ex.ToString());
                        }
                        ((AdjustmentTransaction)instance).IsAdjustable = false;
                        //ESR-5784, revert the change done for ESR-5339, ESR-5376 throw the error will not work here, which lets the UI display the error, So continue, otherwise it appears that all is well when in fact it's not with out logging
                        AdjustmentCache.GetInstance().GetLogger().LogError("Ex.Message : {0} ", ex.Message);
                        AdjustmentCache.GetInstance().GetLogger().LogError("Ex.StackTrace : {0} ", ex.StackTrace); 
                        continue;
                    }

                }
            }

			if(warnings.RecordCount > 0) 
			{
				warnings.MoveFirst();
			}
      
			return warnings;
		}
		public MetraTech.Interop.MTProductCatalog.IMTProperties CreateInputProperties()
    {
      IMTProperties propPtr = new MTPropertiesClass();

      System.Collections.IEnumerator it = mInputPropsMetadata.GetEnumerator();
      while(it.MoveNext())
      {
        object ptempMetaData = it.Current;
        propPtr.Add((MTPropertyMetaData)ptempMetaData);
      }
      return propPtr;
    }

    public MetraTech.Interop.MTProductCatalog.IMTProperties CreateOutputProperties()
    {
      IMTProperties propPtr = new MTPropertiesClass();

      System.Collections.IEnumerator it = mOutputPropsMetadata.GetEnumerator();
      while(it.MoveNext())
      {
        object ptempMetaData = it.Current;
        propPtr.Add((MTPropertyMetaData)ptempMetaData);
      }
      return propPtr;
    }

    public void AddApplicabilityRule(IApplicabilityRule aRule)
    {
      mApplicabilityRules.Add(aRule);
    }
		
    public IMTPropertyMetaDataSet ExpectedOutputs
    {
      get
      {
        return mOutputPropsMetadata;
      }
    }

    public IMTPropertyMetaDataSet RequiredInputs 
    {
      
      get 
      {
        return mInputPropsMetadata;
      }
    }
		
    public ICalculationFormula AdjustmentFormula
    {
      get 
      { 
        if(GetPropertyValue("AdjustmentFormula") == null)
        {
          AdjustmentFormula formula = new AdjustmentFormula();
          formula.AdjustmentType = this;
          PutPropertyValue("AdjustmentFormula", formula);
        }
        return (ICalculationFormula)GetPropertyValue("AdjustmentFormula");
      }
      set { PutPropertyValue("AdjustmentFormula", value); }
    }
		
    public bool SupportsBulk
    {
      get { return mSupportsBulk; }
      set { mSupportsBulk = value; }
    }
	public bool HasParent
	{
		get { return mHasParent; }
		set { mHasParent = value; }		  
	}
	public bool IsCompositeType
	{
		get { return false; }
	}
	public string AdjustmentTable
    {
      get { return mAdjustmentTable; }
      set { mAdjustmentTable = value; }
    }
    public AdjustmentKind Kind
    {
      get { return mAdjustmentKind; }
      set { mAdjustmentKind = value; }
    }
	public string PIName
	{
	  get { return mPIName; }
	  set { mPIName = value; }
	}

	public MetraTech.Interop.GenericCollection.IMTCollection ChildAdjustmentCollection
	{
		get{return mAdjColl;}
		set{mAdjColl = value;}
	}

    //methods not exposed through interface
   

    public void CloneBaseProps(IAdjustmentType aType, IAdjustment aPI, bool IsInstance)
    {
      //string prefix = IsInstance ? " (Cloned Instance)" : " (Cloned Template)";
      aPI.Name = aType.Name;
      aPI.DisplayName = aType.DisplayName;
      aPI.Description = aType.Description;
    }

    protected ICalculationFormula mFormula;
    protected string mProductViewTable;
    protected string mAdjustmentTable;
    protected bool mSupportsBulk; 
	protected bool mHasParent;
    protected string mPIName;
    protected MetraTech.Interop.GenericCollection.IMTCollection mAdjColl;
    protected AdjustmentKind mAdjustmentKind;
    protected bool mIsAdjustmentComposite;
    //meta data for input and output properties
    IMTPropertyMetaDataSet mInputPropsMetadata;
    IMTPropertyMetaDataSet mOutputPropsMetadata;
    private MetraTech.Interop.GenericCollection.IMTCollection mApplicabilityRules;
    
    // TODO: is this the correct .NET data type?
    protected MetraTech.Interop.MTProductCatalog.IMTPriceableItemType mPiType;

    

  }
}
