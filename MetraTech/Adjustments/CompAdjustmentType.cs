using System;
using System.Collections;

//using MetraTech.Interop.MTAuthExec;
//using MetraTech.Adjustments;
using MetraTech.Interop.GenericCollection;
using  RS = MetraTech.Interop.Rowset;
using MetraTech.Interop.MTProductCatalog;
using MetraTech;
using MetraTech.MTSQL;
using MetraTech.Interop.MTAuditEvents;
using System.Runtime.InteropServices;

namespace MetraTech.Adjustments
{
	
	/// <summary>
	/// Summary description for AdjustmentType.
	/// </summary>
	/// 
	
	[Guid("5B805138-9211-4c6b-900F-3BD64CCFA919")]
	[ClassInterface(ClassInterfaceType.None)]
	public class CompAdjustmentType : NamedBaseProperty,  IAdjustmentType, IMTPCBase
	{
		public CompAdjustmentType() : base(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE)
		{
			mInputPropsMetadata = new MTPropertyMetaDataSetClass();
			mOutputPropsMetadata = new MTPropertyMetaDataSetClass();
			mDefaultDesc = null;
			mAdjColl = new MetraTech.Interop.GenericCollection.MTCollectionClass();
		}

		public CompAdjustmentType(MetraTech.Interop.GenericCollection.IMTCollection mAdjChildColl) : base(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE)
		{
			mInputPropsMetadata = new MTPropertyMetaDataSetClass();
			mOutputPropsMetadata = new MTPropertyMetaDataSetClass();
			mDefaultDesc = null;
			mAdjColl = mAdjChildColl;
		}
		public CompAdjustmentType(MetraTech.Interop.MTProductCatalog.IMTSessionContext aCTX, MetraTech.Interop.GenericCollection.IMTCollection mAdjCol) : base(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE)
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
			IAdjustmentTransactionSet childTrxSet;
			// Call CreateAdjustmentTransactions on every adjustment type in the composite
			//  Adjustment type. Add the transaction sets in a collection and then initialize 
			//  the trnasaction set with this collection   
			MetraTech.Interop.GenericCollection.IMTCollection aTrxSetCol = new MTCollectionClass();
			foreach(IAdjustmentType childAdjType in mAdjColl)
			{
				if(childAdjType.HasParent)
					childTrxSet = childAdjType.CreateAdjustmentTransactionsForChildren(aSessions);
				else
					childTrxSet = childAdjType.CreateAdjustmentTransactions(aSessions);
				aTrxSetCol.Add( childTrxSet);
			}
			IAdjustmentTransactionSet trxset = new AdjustmentTransactionSet();
			((AdjustmentTransactionSet)trxset).
				AdjustmentType = this;
			trxset.InitializeForComposite((IMTSessionContext)GetSessionContext(), aTrxSetCol);
			return trxset;
		}

		public IAdjustmentDescription DefaultAdjustmentDescription
		{
			get{return mDefaultDesc;}
			set{mDefaultDesc = value;}
		}
    
    
		
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
			MetraTech.Interop.GenericCollection.IMTCollection childTrxSets =  aSet.ChildTransactionSets;
			MetraTech.Interop.Rowset.IMTRowSet  warnings = null;
			MetraTech.Interop.GenericCollection.IMTCollection collRS = new MetraTech.Interop.GenericCollection.MTCollectionClass();
			MetraTech.Interop.Rowset.IMTRowSet mergedWarningsRS = null;
			int countAdjustable = 0;
			if(aSet.ReasonCode == null)
				throw new AdjustmentException("Reason Code has to be specified");
			foreach(IAdjustmentTransactionSet trxSet in childTrxSets)
			{
				foreach(IAdjustmentTransaction trx in trxSet.GetAdjustmentTransactions())
				{
					if(((AdjustmentTransaction)trx).IsAdjustable != false)
						countAdjustable++;
				}				
			}
			if(countAdjustable == 0)
			{
				throw new AdjustmentException("No Adjustments have been saved. Has calculation failed for all the transactions?");
			}
			foreach(IAdjustmentTransactionSet trxSet in childTrxSets)
			{
				trxSet.ReasonCode = aSet.ReasonCode;
				if(trxSet.ReasonCode == null)
					throw new AdjustmentException("Reason Code has to be specified");
				trxSet.Description = aSet.Description;
				warnings = ((AdjustmentTransactionSet)trxSet).AdjustmentType.SaveAdjustments(trxSet,ProgressObj);
				if(warnings.RecordCount != 0)
					collRS.Add(warnings);
				
			}
			mergedWarningsRS = Utils.MergeAllWarningsRowset(collRS);
			return mergedWarningsRS;
		}
				

		public MetraTech.Interop.Rowset.IMTRowSet Calculate(IAdjustmentTransactionSet aSet, object ProgressObj)
		{
			MetraTech.Interop.GenericCollection.IMTCollection childTrxSets =  aSet.ChildTransactionSets;
			object inputValue = null;
			double outputValue = 0.0,totalAdjAmount = 0.0;
			double outputTaxValue = 0.0,totalTaxAdjAmount = 0.0;
			MetraTech.Interop.Rowset.IMTRowSet  warnings = null;
			MetraTech.Interop.GenericCollection.IMTCollection collRS = new MetraTech.Interop.GenericCollection.MTCollectionClass();
			MetraTech.Interop.Rowset.IMTRowSet mergedWarningsRS = null;
			//Getting the input value from eachtransaction set.
			foreach(IMTProperty prop in aSet.Inputs)
			{
				inputValue = prop.Value;
			}
			foreach(IAdjustmentTransactionSet trxSet in childTrxSets)
			{
				outputValue = 0.0;
				outputTaxValue = 0.0;
				// Setting the input value of each input with the common input value(percentage)
				foreach(IMTProperty prop in trxSet.Inputs)
				{
					prop.Value = inputValue;
				}
				warnings = trxSet.CalculateAdjustments(null);
				if(warnings.RecordCount != 0)
					collRS.Add(warnings);
				foreach(IMTProperty prop in trxSet.Outputs)
				{
					if(prop.Name.ToUpper().CompareTo("TOTALADJUSTMENTAMOUNT") == 0)
						outputValue = Convert.ToDouble(prop.Value);
					if(prop.Name.ToUpper().CompareTo("TOTALTAXADJUSTMENTAMOUNT") == 0)
						outputTaxValue = Convert.ToDouble(prop.Value);
				}
				totalAdjAmount += outputValue;
				totalTaxAdjAmount += outputTaxValue;
			}
			foreach(IMTProperty prop in aSet.Outputs)
			{
				if(prop.Name.ToUpper().CompareTo("TOTALADJUSTMENTAMOUNT") == 0)
					prop.Value = (object)totalAdjAmount;
				else if(prop.Name.ToUpper().CompareTo("TOTALTAXADJUSTMENTAMOUNT") == 0)
					prop.Value = (object)totalTaxAdjAmount;
				else	//As we are displying only Total Adjustment amount (with taxes), Setting the rest of 
							//the tax amounts to 0
					prop.Value = 0.0;
			}
			mergedWarningsRS = Utils.MergeAllWarningsRowset(collRS);
			return mergedWarningsRS;
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

		public void SetApplicabilityRules(MetraTech.Interop.GenericCollection.IMTCollection aRules)
		{
			
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
		
		public bool IsCompositeType
		{
			get { return true; }
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

		/// These methods are not implemented by the class. Calling these functions will cause an exception
		public IAdjustmentTransactionSet CreateAdjustmentTransactionsForChildren(object aSessions)//MetraTech.Interop.GenericCollection.IMTCollection aSessions)
		{
			throw new AdjustmentException("This function is not supported");
		}

		public string AdjustmentTable
		{
			get { throw new AdjustmentException("This property is not supported"); }
			set { throw new AdjustmentException("This property is not supported"); }
		}
		public void AddApplicabilityRule(IApplicabilityRule aRule)
		{
			
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
		public MetraTech.Interop.GenericCollection.IMTCollection GetApplicabilityRules()
		{
			return null;
		
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
		
		protected bool mSupportsBulk; 
		protected bool mHasParent;
		protected string mPIName;
		protected bool mIsAdjustmentComposite;
		protected MetraTech.Interop.GenericCollection.IMTCollection mAdjColl;
		protected AdjustmentKind mAdjustmentKind;
		private IAdjustmentDescription mDefaultDesc;
		private int mPiTypeID;

		//meta data for input and output properties
		IMTPropertyMetaDataSet mInputPropsMetadata;
		IMTPropertyMetaDataSet mOutputPropsMetadata;
		
		protected MetraTech.Interop.MTProductCatalog.IMTPriceableItemType mPiType;
  

	}
}
