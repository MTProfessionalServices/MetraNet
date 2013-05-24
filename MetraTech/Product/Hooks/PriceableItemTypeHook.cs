using System;
using System.Xml;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using System.Collections;
using System.Reflection;
using MetraTech;
using MetraTech.Xml;
//using MetraTech.Interop.MTHooklib;
using MetraTech.Interop.RCD;
using MetraTech.Adjustments;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DataAccess;
using Rowset = MetraTech.Interop.Rowset;


namespace MetraTech.Product.Hooks
{
  internal class DuplicateNameException : Exception
  {
    private object m_Obj;

    public DuplicateNameException(string msg, object obj)
      : base(msg)
    {
      m_Obj = obj;
    }

    public object DuplicateObject
    {
      get { return m_Obj; }
    }
  }

  [ComVisible(false)]
  public class PCObjectDifference
  {
    protected ArrayList mCreate;
    protected ArrayList mDelete;
    protected ArrayList mUpdate;

    public IEnumerable Delete
    {
      get { return mDelete; }
    }

    public IEnumerable Update
    {
      get { return mUpdate; }
    }

    public IEnumerable Create
    {
      get { return mCreate; }
    }

    protected virtual void AddCreated(Object obj)
    {
      mCreate.Add(obj);
    }

    protected virtual void AddUpdated(Object before, Object after)
    {
      mUpdate.Add(after);
    }

    protected virtual void AddDeleted(Object obj)
    {
      mDelete.Add(obj);
    }

    class ObjectPair
    {
      public Object left;
      public Object right;
      public ObjectPair(Object l, Object r)
      {
        left = l;
        right = r;
      }
    }

    // The basic "full outer join" algorithm for changed
    // data capture.  This is structured as a full outer
    // hash join.
    protected void CaptureChangedData(IEnumerable before, IEnumerable after, IHashCodeProvider hcp, IComparer eq)
    {
      // Load up the before image into a hash table.
      Hashtable hash = new Hashtable(hcp, eq);
      foreach(Object e in before)
      {
        hash[e] = new ObjectPair(e, null);
      }

      foreach(Object e in after)
      {
        if (hash.Contains(e))
        {
          // Match, make a note of the match in hash so that
          // we can process non-matchers (deleted entities) later.
          ObjectPair pair = ((ObjectPair)hash[e]);
          
          // if pair.right exists then another object with the same name exists in the file
          // This is a problem since the name is assumed to be unique
          if (pair.right == null)
          {
            pair.right = e;
            AddUpdated(pair.left, e);
          }
          else
          {
            throw new DuplicateNameException("Duplicate object name found", e);
          }
        }
        else
        {
          AddCreated(e);
        }
      }

      // Lastly search through the hashtable and find those with no match
      // in the snapshot; these are deleted
      foreach(DictionaryEntry de in hash)
      {
        if (((ObjectPair)de.Value).right == null)
        {
          AddDeleted(de.Key);
        }
      }
    }

    protected PCObjectDifference()
    {
      mCreate = new ArrayList();
      mDelete = new ArrayList();
      mUpdate = new ArrayList();
    }
		
  }

  [ComVisible(false)]
  public class UniquePropertyObjectComparer : IComparer, IHashCodeProvider
  {
    private String mPropertyName;


    public int GetHashCode(object obj)
    {
      Object result = obj.GetType().InvokeMember(mPropertyName, BindingFlags.GetProperty, null, obj, null);
      return ((String)result).ToLower().GetHashCode();
    }

    public int Compare(object lhs, object rhs)
    {
      Object lhsValue = lhs.GetType().InvokeMember(mPropertyName, BindingFlags.GetProperty, null, lhs, null);
      Object rhsValue = rhs.GetType().InvokeMember(mPropertyName, BindingFlags.GetProperty, null, rhs, null);
      return String.Compare((String) lhsValue, (String) rhsValue, true);
    }

    public UniquePropertyObjectComparer(String propertyName)
    {
      mPropertyName = propertyName;
    }

    public UniquePropertyObjectComparer()
    {
      mPropertyName = "Name";
    }
  }

  [ComVisible(false)]
  public class ChargePropertyComparer : IComparer, IHashCodeProvider
  {
    private MetraTech.Interop.MTProductView.IProductViewCatalog mPV;

    private String GetName(Object obj)
    {
      if(obj.GetType().Equals(typeof(ChargeProperty)))
      {
        return (String) obj.GetType().InvokeMember("Name", BindingFlags.GetProperty, null, obj, null);
      }
      else
      {
        // TODO: For performance reasons can we cache here?????  I think this is OK because the
        // name of a property is immutable.
        // We have the pc object, for this guy, we need to get the string from the IProductViewProperty
        // Actually, now that we grab the PVID when we deserialize the PV Property, we can compare IDs.
        return mPV.GetProductViewProperty((int)obj.GetType().InvokeMember("ProductViewPropertyID", BindingFlags.GetProperty, null, obj, null)).dn;
      }
    }

    public int GetHashCode(object obj)
    {
      return ((String) GetName(obj)).ToLower().GetHashCode();
    }

    public int Compare(object lhs, object rhs)
    {
      return String.Compare(GetName(lhs), GetName(rhs), true);
    }

    public ChargePropertyComparer(MetraTech.Interop.MTProductView.IProductViewCatalog pv)
    {
      mPV = pv;
    }
    public ChargePropertyComparer()
    {
      mPV = new MetraTech.Interop.MTProductView.ProductViewCatalogClass();
    }
  }

  [ComVisible(false)]
  public class ApplicabilityRuleDifference : PCObjectDifference
  {
    private ArrayList mProgram;
    private AdjustmentType mAdjType;

    protected override void AddCreated(Object obj)
    {
      base.AddCreated(obj);
      mProgram.Add(Instruction.CreateApplicabilityRule((ApplicabilityRule)obj, mAdjType));
    }

    protected override void AddUpdated(Object before, Object after)
    {
      base.AddUpdated(before, after);
      mProgram.Add(Instruction.UpdateApplicabilityRule((ApplicabilityRule)after,
                                                       (ApplicabilityRule) before));
    }

    protected override void AddDeleted(Object obj)
    {
      base.AddDeleted(obj);
      mProgram.Add(Instruction.DeleteApplicabilityRule((ApplicabilityRule) obj, mAdjType));
    }

    public void Calculate(AdjustmentType pcAdjType,
                          AdjustmentType adjType)
    {
      try
      {
        mAdjType = adjType;
        CaptureChangedData(pcAdjType.GetApplicabilityRules(), adjType.GetApplicabilityRules(), new UniquePropertyObjectComparer(), new UniquePropertyObjectComparer());
      }
      catch (DuplicateNameException app)
      {
        IApplicabilityRule rule = app.DuplicateObject as IApplicabilityRule;

        throw new ApplicationException(string.Format("Duplicate name ({0}) found processing ApplicabilityRules for Adjustment ({1})", rule.Name, adjType.Name));
      }
    }

    public ApplicabilityRuleDifference(ArrayList program)
    {
      mProgram = program;
    }
  }

  [ComVisible(false)]
  public class AdjustmentTypeDifference : PCObjectDifference
  {
    private ArrayList mProgram;
    private PriceableItemType mPiType;

    protected override void AddCreated(Object obj)
    {
      base.AddCreated(obj);
      mProgram.Add(Instruction.CreateAdjustmentType((IAdjustmentType)obj, mPiType));
    }

    protected override void AddUpdated(Object before, Object after)
    {
      base.AddUpdated(before, after);
      mProgram.Add(Instruction.UpdateAdjustmentType((IAdjustmentType)after,
                                                    (IAdjustmentType) before));
	  
		if( !((IAdjustmentType)before).IsCompositeType )
		{
			// Check for changes to applicability rules.
			ApplicabilityRuleDifference ardiff = new ApplicabilityRuleDifference(mProgram);
			ardiff.Calculate((AdjustmentType) before, (AdjustmentType) after);
		}
    }

    protected override void AddDeleted(Object obj)
    {
      base.AddDeleted(obj);
      mProgram.Add(Instruction.DeleteAdjustmentType((IAdjustmentType) obj));
    }

    public void Calculate(IMTPriceableItemType pcPiType,
                          PriceableItemType piType)
    {
      try
      {
        mPiType = piType;
        CaptureChangedData(pcPiType.AdjustmentTypes, piType.AdjustmentTypes, new UniquePropertyObjectComparer(), new UniquePropertyObjectComparer());
      }
      catch (DuplicateNameException app)
      {
        AdjustmentType adj = app.DuplicateObject as AdjustmentType;

        throw new ApplicationException(string.Format("Duplicate name ({0}) found processing AdjustmentTypes for PriceableItem ({1})", adj.Name, piType.Name));
      }
    }

    public AdjustmentTypeDifference(ArrayList program)
    {
      mProgram = program;
    }
  }

  [ComVisible(false)]
  public class ReasonCodeDifference : PCObjectDifference
  {
    private ArrayList mProgram;
    private AdjustmentTemplate mAdjTemplate;
    private Adjustment mPcAdjTemplate;

    protected override void AddCreated(Object obj)
    {
      base.AddCreated(obj);
      mProgram.Add(Instruction.CreateReasonCode((ReasonCode)obj, mAdjTemplate));
    }

    protected override void AddUpdated(Object before, Object after)
    {
      base.AddUpdated(before, after);
      mProgram.Add(Instruction.UpdateReasonCode((ReasonCode) after,
                                                (ReasonCode) before));
    }

    protected override void AddDeleted(Object obj)
    {
      base.AddDeleted(obj);
      mProgram.Add(Instruction.DeleteReasonCode((ReasonCode) obj, mPcAdjTemplate));
    }

    public void Calculate(Adjustment pcAdjTemplate,
                          AdjustmentTemplate adjTemplate)
    {
      try
      {
        mAdjTemplate = adjTemplate;
        mPcAdjTemplate = pcAdjTemplate;
        CaptureChangedData(pcAdjTemplate.GetApplicableReasonCodes(), adjTemplate.ReasonCodes, new UniquePropertyObjectComparer(), new UniquePropertyObjectComparer());
      }
      catch (DuplicateNameException app)
      {
        ReasonCode reason = app.DuplicateObject as ReasonCode;

        throw new ApplicationException(string.Format("Duplicate name ({0}) found processing ReasonCodes for AdjustmentTemplate ({1})", reason.Name, adjTemplate.Name));
      }
    }

    public ReasonCodeDifference(ArrayList program)
    {
      mProgram = program;
    }
  }

  [ComVisible(false)]
  public class AdjustmentTemplateDifference : PCObjectDifference
  {
    private ArrayList mProgram;
    private PriceableItemType mPiType;

    protected override void AddCreated(Object obj)
    {
      base.AddCreated(obj);
      mProgram.Add(Instruction.CreateAdjustmentTemplate((AdjustmentTemplate)obj, mPiType.Template));
    }

    protected override void AddUpdated(Object before, Object after)
    {
      base.AddUpdated(before, after);
      mProgram.Add(Instruction.UpdateAdjustmentTemplate((AdjustmentTemplate)after,
                                                        (Adjustment) before));

      ReasonCodeDifference rcdiff = new ReasonCodeDifference(mProgram);
      rcdiff.Calculate((Adjustment) before, (AdjustmentTemplate)after);
    }

    protected override void AddDeleted(Object obj)
    {
      base.AddDeleted(obj);
      mProgram.Add(Instruction.DeleteAdjustmentTemplate((Adjustment) obj));
    }

    public void Calculate(IMTPriceableItemType pcPiType,
                          PriceableItemType piType)
    {
      try
      {
        mPiType = piType;
        IMTPriceableItem pcPiTemplate = (IMTPriceableItem)pcPiType.GetTemplates()[1];
        CaptureChangedData(pcPiTemplate.GetAdjustments(), piType.Template.AdjustmentTemplates, new UniquePropertyObjectComparer(), new UniquePropertyObjectComparer());
      }
      catch (DuplicateNameException app)
      {
        AdjustmentTemplate templ = app.DuplicateObject as AdjustmentTemplate;

        throw new ApplicationException(string.Format("Duplicate name ({0}) found processing AdjustmentTemplates for PriceableItem ({1})", templ.Name, piType.Name));
      }
    }

    public AdjustmentTemplateDifference(ArrayList program)
    {
      mProgram = program;
    }
  }

  [ComVisible(false)]
  public class ParameterTableDifference : PCObjectDifference
  {
    private ArrayList mProgram;
    private PriceableItemType mPiType;
    private IMTPriceableItemType mPcPiType;

    protected override void AddCreated(Object obj)
    {
      // Create for a charge will create all charge properties as well
      base.AddCreated(obj);
      mProgram.Add(Instruction.CreateParameterTable((ParameterTable)obj, mPiType));
    }

    protected override void AddUpdated(Object before, Object after)
    {
      base.AddUpdated(before, after);
      mProgram.Add(Instruction.UpdateParameterTable((ParameterTable)after,
                                                    (IMTParamTableDefinition) before));
    }

    protected override void AddDeleted(Object obj)
    {
      // If a charge is deleted, the PCExec remove will delete the properties, so there
      // is no need to descend into the child collections.
      base.AddDeleted(obj);
      mProgram.Add(Instruction.DeleteParameterTable((IMTParamTableDefinition) obj, mPcPiType));
    }

    public void Calculate(IMTPriceableItemType pcPiType,
                          PriceableItemType piType)
    {
      try
      {
        mPiType = piType;
        mPcPiType = pcPiType;
        CaptureChangedData(pcPiType.GetParamTableDefinitions(), piType.ParameterTables, new UniquePropertyObjectComparer(), new UniquePropertyObjectComparer());
      }
      catch (DuplicateNameException app)
      {
        ParameterTable pt = app.DuplicateObject as ParameterTable;

        throw new ApplicationException(string.Format("Duplicate name ({0}) found processing ParameterTables for PriceableItem ({1})", pt.Name, piType.Name));
      }
    }

    public ParameterTableDifference(ArrayList program)
    {
      mProgram = program;
    }
  }

  [ComVisible(false)]
  public class CounterPropertyDefinitionDifference : PCObjectDifference
  {
    private ArrayList mProgram;
    private PriceableItemType mPiType;
    private IMTPriceableItemType mPcPiType;

    protected override void AddCreated(Object obj)
    {
      // Create for a charge will create all charge properties as well
      base.AddCreated(obj);
      mProgram.Add(Instruction.CreateCounterPropertyDefinition((CounterPropertyDefinition)obj, mPiType));
      // Creating a counter prop def does NOT create the corresponding Counter.
      if(mPiType.EntityType == MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE)
      {
        mProgram.Add(Instruction.CreateCounter(((CounterPropertyDefinition)obj).ConfiguredCounter,
                                               (AggregateCharge)mPiType.Template,
                                               (CounterPropertyDefinition)obj));
      }
    }

    protected override void AddUpdated(Object before, Object after)
    {
      base.AddUpdated(before, after);
      mProgram.Add(Instruction.UpdateCounterPropertyDefinition((CounterPropertyDefinition)after,
                                                              (IMTCounterPropertyDefinition) before));

      // TODO: What about the case in which a CPD is modified on a discount???????
      if(mPiType.EntityType == MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE)
      {
        // Always handle a counter update as a delete/insert pair.
        IMTCounterPropertyDefinition pcCpd =
        (IMTCounterPropertyDefinition) before;
        IMTCollection templates = mPcPiType.GetTemplates();
        foreach(IMTAggregateCharge pcTemplate in templates)
        {
          IMTCounter pcCounter = pcTemplate.GetCounter(pcCpd.ID);
          if(pcCounter != null)
          {
            mProgram.Add(Instruction.DeleteCounter(pcCounter,
                                                   (AggregateCharge) mPiType.Template));
          }
        }

        if (mPiType.Template != null)
        {
          mProgram.Add(Instruction.CreateCounter(((CounterPropertyDefinition)after).ConfiguredCounter,
                                                 (AggregateCharge)mPiType.Template,
                                                 (CounterPropertyDefinition)after));
        }
      }
    }

    protected override void AddDeleted(Object obj)
    {
      // If a charge is deleted, the PCExec remove will delete the properties, so there
      // is no need to descend into the child collections.
      base.AddDeleted(obj);
      mProgram.Add(Instruction.DeleteCounterPropertyDefinition((IMTCounterPropertyDefinition) obj));
      // Note that deleting a counter prop def does NOT delete the corresponding Counter,
      // so we must do that here.  Note that in the case in which there is a discount
      // there may be multiple templates, so we may want to let this code delete counters
      // for each of those.
      if(mPiType.EntityType == MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE)
      {
        IMTCounterPropertyDefinition pcCpd =
        (IMTCounterPropertyDefinition) obj;
        IMTCollection templates = mPcPiType.GetTemplates();
        foreach(IMTAggregateCharge pcTemplate in templates)
        {
          IMTCounter pcCounter = pcTemplate.GetCounter(pcCpd.ID);
          if(pcCounter != null)
          {
            mProgram.Add(Instruction.DeleteCounter(pcCounter,
                                                   (AggregateCharge) mPiType.Template));
          }
        }
      }
    }

    public void Calculate(IMTPriceableItemType pcPiType,
                          PriceableItemType piType)
    {
      try
      {
        mPiType = piType;
        mPcPiType = pcPiType;
        CaptureChangedData(pcPiType.GetCounterPropertyDefinitions(), piType.CounterPropertyDefinitions, new UniquePropertyObjectComparer(), new UniquePropertyObjectComparer());
      }
      catch (DuplicateNameException app)
      {
        CounterPropertyDefinition counter = app.DuplicateObject as CounterPropertyDefinition;

        throw new ApplicationException(string.Format("Duplicate name ({0}) found processing CounterPropertyDefinitions for PriceableItem ({1})", counter.Name, piType.Name));
      }
    }

    public CounterPropertyDefinitionDifference(ArrayList program)
    {
      mProgram = program;
    }
  }

  [ComVisible(false)]
  public class ChargeDifference : PCObjectDifference
  {
    private ArrayList mProgram;
    private PriceableItemType mPiType;

    private ChargePropertyDifference mChargeProperties;
    public ChargePropertyDifference ChargeProperties
    {
      get { return mChargeProperties; }
    }

    protected override void AddCreated(Object obj)
    {
      // Create for a charge will create all charge properties as well
      base.AddCreated(obj);
      mProgram.Add(Instruction.CreateCharge((Charge)obj, mPiType));
    }

    protected override void AddUpdated(Object before, Object after)
    {
      base.AddUpdated(before, after);
      IMTCharge pcCharge = (IMTCharge) before;
      Charge charge = (Charge) after;

      mProgram.Add(Instruction.UpdateCharge((Charge)after,
                                            (IMTCharge) before));
      mChargeProperties.Calculate(pcCharge, charge);
    }

    protected override void AddDeleted(Object obj)
    {
      // If a charge is deleted, the PCExec remove will delete the properties, so there
      // is no need to descend into the child collections.
      base.AddDeleted(obj);
      mProgram.Add(Instruction.DeleteCharge((IMTCharge) obj));
    }

    public void Calculate(IMTPriceableItemType pcPiType,
                          PriceableItemType piType)
    {
      try
      {
        mPiType = piType;
        CaptureChangedData(pcPiType.GetCharges(), piType.Charges, new UniquePropertyObjectComparer(), new UniquePropertyObjectComparer());
      }
      catch (DuplicateNameException app)
      {
        Charge charge = app.DuplicateObject as Charge;

        throw new ApplicationException(string.Format("Duplicate name ({0}) found processing Charges for PriceableItem ({1})", charge.Name, piType.Name));
      }
    }

    public ChargeDifference(ArrayList program)
    {
      mProgram = program;
      mChargeProperties = new ChargePropertyDifference(program);
    }
  }

  [ComVisible(false)]
  public class ChargePropertyDifference : PCObjectDifference
  {
    private ArrayList mProgram;
    private Charge mCharge;

    protected override void AddCreated(Object obj)
    {
      // Create for a charge will create all charge properties as well
      base.AddCreated(obj);
      mProgram.Add(Instruction.CreateChargeProperty((ChargeProperty)obj, mCharge));
    }

    protected override void AddUpdated(Object before, Object after)
    {
      base.AddUpdated(before, after);
      mProgram.Add(Instruction.UpdateChargeProperty((ChargeProperty)after,
                                                    (IMTChargeProperty) before));
    }

    protected override void AddDeleted(Object obj)
    {
      // If a charge is deleted, the PCExec remove will delete the properties, so there
      // is no need to descend into the child collections.
      base.AddDeleted(obj);
      mProgram.Add(Instruction.DeleteChargeProperty((IMTChargeProperty) obj));
    }

    public void Calculate(IMTCharge pcCharge,
                          Charge charge)
    {
      try
      {
        ChargePropertyComparer comparer = new ChargePropertyComparer();
        mCharge = charge;
        CaptureChangedData(pcCharge.GetChargeProperties(), charge.ChargeProperties, comparer, comparer);
      }
      catch (DuplicateNameException app)
      {
        ChargeProperty pt = app.DuplicateObject as ChargeProperty;

        throw new ApplicationException(string.Format("Duplicate name ({0}) found processing ChargeProperty for charge ({1})", pt.Name, charge.Name));
      }
    }

    public ChargePropertyDifference(ArrayList program)
    {
      mProgram = program;
    }
  }

  [ComVisible(false)]
  public class PriceableItemTypeDifference : PCObjectDifference
  {
    private AdjustmentTypeDifference mAdjustmentTypes;

    private ChargeDifference mCharges;
    public ChargeDifference Charges
    {
      get { return mCharges; }
    }
    
    private ParameterTableDifference mParameterTables;
    public ParameterTableDifference ParameterTables
    {
      get { return mParameterTables; }
    }
    
    private CounterPropertyDefinitionDifference mCounterPropertyDefinitions;
    public CounterPropertyDefinitionDifference CounterPropertyDefinitions
    {
      get { return mCounterPropertyDefinitions; }
    }
    
		public void Calculate(IMTPriceableItemType pcPiType,
			PriceableItemType piType,
			ArrayList program)
		{
			try
			{
				if (pcPiType.Name == piType.Name)
				{
					program.Add(Instruction.UpdatePriceableItemType(piType, pcPiType));
					// Calculate changes to:
					// Child priceable item types (what to do when these are removed?)
					// Parameter table definitions
					// Counter property definitions
					// Charges (and charge properties)
					// Adjustment types
					// Propagate those changes down to the PI template
					// level if need be?
					mCharges = new ChargeDifference(program);
					mCharges.Calculate(pcPiType, piType);
					mCounterPropertyDefinitions = new CounterPropertyDefinitionDifference(program);
					mCounterPropertyDefinitions.Calculate(pcPiType, piType);
					mParameterTables = new ParameterTableDifference(program);
					mParameterTables.Calculate(pcPiType, piType);
					mAdjustmentTypes = new AdjustmentTypeDifference(program);
					mAdjustmentTypes.Calculate(pcPiType, piType);
					/// TODO!!!!!!!!!!! Glue in stuff for aggregate and usage charge.

					if(pcPiType.Kind == MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE ||
						pcPiType.Kind == MTPCEntityType.PCENTITY_TYPE_USAGE)
					{
						AdjustmentTemplateDifference adjustmentTemplates = new AdjustmentTemplateDifference(program);
						adjustmentTemplates.Calculate(pcPiType, piType);
					}
					if(pcPiType.Kind == MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE)
					{
						program.Add(Instruction.UpdateAggregateCharge((AggregateCharge)piType.Template, 
							(IMTAggregateCharge)pcPiType.GetTemplates()[1]));
					}
					else if(pcPiType.Kind == MTPCEntityType.PCENTITY_TYPE_USAGE)
					{
						program.Add(Instruction.UpdateUsageCharge((UsageCharge)piType.Template, 
							(IMTPriceableItem)pcPiType.GetTemplates()[1]));
					}
				}
			}
			catch(Exception e)
			{
				System.Console.Out.WriteLine(string.Format("Exception Message: {0}", e.Message));
				System.Console.Out.WriteLine(string.Format("Exception Stack Trace: {0}", e.StackTrace));
				throw;
			}

		}

  }

  [ComVisible(false)]
  public class ProductCatalogDifference : PCObjectDifference
  {
    private ArrayList mProgram;
    private PriceableItemTypeDifference mPiTypeDiff;

    protected override void AddCreated(Object obj)
    {
      // Create for a charge will create all charge properties as well
      base.AddCreated(obj);
      mProgram.Add(Instruction.CreatePriceableItemType((PriceableItemType)obj));
      mProgram.Add(Instruction.CreateChecksum((PriceableItemType)obj));
    }

    protected override void AddUpdated(Object before, Object after)
    {
      base.AddUpdated(before, after);
      IMTPriceableItemType pcPiType = (IMTPriceableItemType) before;
      PriceableItemType piType = (PriceableItemType) after;

      // TODO: Retrieve the checksum of the pcPiType; if version is 0, then only
      // update the checksum not the pi type itself.
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ProductCatalog", "__GET_PARAMTABLE_CHECKSUM__"))
          {
              stmt.AddParam("%%ID_PARAM%%", pcPiType.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  string checksum = reader.GetString("tx_checksum");
                  string version = reader.GetString("n_version");
                  int intVersion = System.Int32.Parse(version);

                  // Special case: version = 0 implies just update checksum
                  // checksums equal => don't even bother to update
                  // checksums different => do the full update and checksum update
                  if (intVersion == 0)
                  {
                      mProgram.Add(Instruction.UpdateChecksum(piType));
                  }
                  else if (checksum != piType.FileChecksum)
                  {
                      mProgram.Add(Instruction.UpdatePriceableItemType(piType, pcPiType));
                      mPiTypeDiff.Calculate(pcPiType, piType, mProgram);
                      mProgram.Add(Instruction.UpdateChecksum(piType));
                  }
              }
          }
      }
    }

    protected override void AddDeleted(Object obj)
    {
      // If a charge is deleted, the PCExec remove will delete the properties, so there
      // is no need to descend into the child collections.
      base.AddDeleted(obj);
      mProgram.Add(Instruction.DeletePriceableItemType((IMTPriceableItemType) obj));
      mProgram.Add(Instruction.DeleteChecksum((IMTPriceableItemType) obj));
    }

    public void Calculate(IMTProductCatalog pc,
                          IEnumerable piTypes)
    {
      // We must create the PiType executant directly since the product catalog method
      // won't let you get children.
      MetraTech.Interop.MTProductCatalogExec.IMTPriceableItemTypeReader reader = 
      new MetraTech.Interop.MTProductCatalogExec.MTPriceableItemTypeReaderClass();
      CaptureChangedData(reader.FindByFilter((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), null), 
                         piTypes, 
                         new UniquePropertyObjectComparer(), 
                         new UniquePropertyObjectComparer());
    }

    public ProductCatalogDifference(ArrayList program)
    {
      mProgram = program;
      mPiTypeDiff = new PriceableItemTypeDifference();
    }
  }

  [ComVisible(false)]
  /// <remarks>
  /// Be careful when modifying this enumeration.  The order of items in the enumeration is important 
  /// and reflects the order in which these operations should be executed in a batch operation (for
  /// example, we update things before creating and we must create a priceable
  /// item type before create the charges underneath it.
  /// </remarks>
  public enum InstructionType { UpdatePriceableItemType, UpdateCharge, UpdateChargeProperty, UpdateAggregateCharge, UpdateUsageCharge, UpdateCounterPropertyDefinition, UpdateCounter, UpdateParameterTable, UpdateAdjustmentType, UpdateApplicabilityRule, UpdateAdjustmentTemplate, UpdateReasonCode, UpdateChecksum,
                                CreatePriceableItemType, CreateCharge, CreateChargeProperty, CreateAggregateCharge, CreateUsageCharge, CreateCounterPropertyDefinition, CreateCounter, CreateParameterTable, CreateAdjustmentType, CreateApplicabilityRule, CreateAdjustmentTemplate, CreateReasonCode, CreateChecksum,
                                DeleteChecksum, DeleteReasonCode, DeleteAdjustmentTemplate, DeleteApplicabilityRule, DeleteChargeProperty, DeleteCharge, DeleteCounter, DeleteCounterPropertyDefinition, DeleteAggregateCharge, DeleteUsageCharge, DeleteParameterTable, DeleteAdjustmentType, DeletePriceableItemType
  }

  [ComVisible(false)]
  public class Instruction : IComparable
  {
    public InstructionType Type;
    public Object Argument1;
    public Object Argument2;
    public Object Argument3;

    private Instruction(InstructionType type, Object arg1, Object arg2)
    {
      Type = type;
      Argument1 = arg1;
      Argument2 = arg2;
      Argument3 = null;
    }

    private Instruction(InstructionType type, Object arg1, Object arg2, Object arg3)
    {
      Type = type;
      Argument1 = arg1;
      Argument2 = arg2;
      Argument3 = arg3;
    }

    public int CompareTo(Object obj)
    {
      // I would rather use the definition from "PropertiesBase.h" but it is written
      // in C++ and not exposed as a COM enum so...
      const long PROPERTIES_BASE_NO_ID = -1L; //value of no ID

      if (!obj.GetType().Equals(typeof(Instruction)))
        throw new ArgumentException("Argument not of type Instruction");

      Instruction rhs = (Instruction) obj;

      if ((int) this.Type < (int) rhs.Type)
      {
        return -1;
      }
      else if (this.Type == rhs.Type)
      {
        // For the special case of PiType and PiTemplate instructions, refine the ordering by the parent child
        // relationship (parents are created first and children are deleted first).  Because the ArrayList
        // uses some sort of binary search we also have to make sure that all items with parents go after (or
        // before in the case of delete) all items without parents.
        //
        // Whether something is a parent or child of the other item should take first precedent.
        //
        // It there is no parent/child relationship then things without parents should be grouped
        // seperately from things with parents.
        switch(this.Type)
        {
        case InstructionType.UpdatePriceableItemType:
        case InstructionType.CreatePriceableItemType:
          {
            PriceableItemType piType1 = (PriceableItemType) this.Argument1;
            PriceableItemType piType2 = (PriceableItemType) rhs.Argument1;

            // The code in the "if true" block assumes the following:
            //
            // 1. We only have one level of children.
            // 2. All parents can not be a child (i.e. thier Parent field must be null).
            // 3. All children must have a parent (i.e. thier Parent field must not be null).
            //
            // With these assumptions we can simply group these items by putting all the
            // parents (all the items whose Parent is null) before all the children (all
            // the items whose Parent is not null).
            //
            // If we were to allow multiple levels of children (i.e. grandchildren, etc.)
            // then we would want to use the code in the "else" block.
#if true
            // If piType1 has a null parent then we can put it before piType2 regardless
            // of whether piType2 has a null parent or not.
            if (piType1.Parent == null)
              return -1;

            // If piType2 has a null parent it must go before piType1 because we know
            // that piType1 does not have a null parent.
            if (piType2.Parent == null)
              return 1;

            // Otherwise we don't care which goes first.
            return 0;
#else
            // If they both have the same parent or if they both have null parents they are equal.
            if (piType1.Parent == piType2.Parent)
              return 0;

            // If piType2 is the parent of piType1 then piType2 must appear in the list before
            // piType1 so piType1 is greater than piType2.
            if (piType1.Parent == piType2)
              return 1;

            // If piType1 is the parent of piType2 then piType1 must appear in the list before
            // piType2 so piType1 is less than piType2.
            if (piType2.Parent == piType1)
              return -1;

            // If piType1 has a null parent and we are here we know that piType2 must have a
            // a parent therefore we want piType1 to appear in the list before piType2 so
            // piType1 is less than piType2.
            if (piType1.Parent == null)
              return -1;

            // If piType2 has a null parent and we are here we know that piType1 must have a
            // a parent therefore we want piType1 to appear in the list after piType2 so
            // piType1 is greater than piType2.
            if (piType2.Parent == null)
              return 1;

            // Both items have parents but the parents are different.  In this case we
            // sort them by parent id to ensure that there is some ultimate order so that
            // proper comparisons are done for future items added to this list.

            // If piType1s ParentID is greater then piType2s then we want piType2 to be before
            // piType1.
            if (piType1.Parent.ID > piType2.Parent.ID)
              return 1;

            // If we get here we know that piType2s ParentID must be greater then piType1s
            // so we want piType1 to go before piType2.
            return -1;
#endif
          }
        case InstructionType.DeletePriceableItemType:
          {
            IMTPriceableItemType piType1 = (IMTPriceableItemType) this.Argument1;
            IMTPriceableItemType piType2 = (IMTPriceableItemType) rhs.Argument1;

            // The code in the "if true" block assumes the following:
            //
            // 1. We only have one level of children.
            // 2. All parents can not be a child (i.e. thier Parent field must be null).
            // 3. All children must have a parent (i.e. thier Parent field must not be null).
            //
            // With these assumptions we can simply group these items by putting all the
            // parents (all the items whose Parent is null) before all the children (all
            // the items whose Parent is not null).
            //
            // If we were to allow multiple levels of children (i.e. grandchildren, etc.)
            // then we would want to use the code in the "else" block.
#if true
            // If piType1 has a null parent then we can put it after piType2 regardless
            // of whether piType2 has a null parent or not.
            if (piType1.ParentID == PROPERTIES_BASE_NO_ID)
              return 1;

            // If piType2 has a null parent it must go after piType1 because we know
            // that piType1 does not have a null parent.
            if (piType2.ParentID == PROPERTIES_BASE_NO_ID)
              return -1;

            // Otherwise we don't care which goes first.
            return 0;
#else
            // If they both have the same parent or if they both have null parents they are equal.
            if (piType1.ParentID == piType2.ParentID)
              return 0;

            // If piType2 is the parent of piType1 then piType1 must appear in the list before
            // piType2 so piType1 is less than piType2.
            if (piType1.ParentID == piType2.ID)
              return -1;

            // If piType1 is the parent of piType2 then piType2 must appear in the list before
            // piType1 so piType1 is greater than piType2.
            if (piType2.ParentID == piType1.ID)
              return 1;

            // If piType1 has a null parent and we are here we know that piType2 must have a
            // a parent therefore we want piType2 to appear in the list before piType1 so
            // piType1 is greater than piType2.
            if (piType1.ParentID == PROPERTIES_BASE_NO_ID)
              return 1;

            // If piType2 has a null parent and we are here we know that piType1 must have a
            // a parent therefore we want piType2 to appear in the list after piType1 so
            // piType1 is less than piType2.
            if (piType2.ParentID == PROPERTIES_BASE_NO_ID)
              return -1;

            // Both items have parents but the parents are different.  In this case we
            // sort them by parent id to ensure that there is some ultimate order so that
            // proper comparisons are done for future items added to this list.

            // If piType1s ParentID is greater then piType2s then we want piType1 to be before
            // piType2.
            if (piType1.ParentID > piType2.ParentID)
              return -1;

            // If we get here we know that piType2s ParentID must be greater then piType1s
            // so we want piType2 to go before piType1.
            return 1;
#endif
          }
        case InstructionType.UpdateUsageCharge:
        case InstructionType.UpdateAggregateCharge:
        case InstructionType.CreateUsageCharge:
        case InstructionType.CreateAggregateCharge:
          {
            UsageCharge piType1 = (UsageCharge) this.Argument1;
            UsageCharge piType2 = (UsageCharge) rhs.Argument1;

            // The code in the "if true" block assumes the following:
            //
            // 1. We only have one level of children.
            // 2. All parents can not be a child (i.e. thier Parent field must be null).
            // 3. All children must have a parent (i.e. thier Parent field must not be null).
            //
            // With these assumptions we can simply group these items by putting all the
            // parents (all the items whose Parent is null) before all the children (all
            // the items whose Parent is not null).
            //
            // If we were to allow multiple levels of children (i.e. grandchildren, etc.)
            // then we would want to use the code in the "else" block.
#if true
            // If piType1 has a null parent then we can put it before piType2 regardless
            // of whether piType2 has a null parent or not.
            if (piType1.Parent == null)
              return -1;

            // If piType2 has a null parent it must go before piType1 because we know
            // that piType1 does not have a null parent.
            if (piType2.Parent == null)
              return 1;

            // Otherwise we don't care which goes first.
            return 0;
#else
            // If they both have the same parent or if they both have null parents they are equal.
            if (piType1.Parent == piType2.Parent)
              return 0;

            // If piType2 is the parent of piType1 then piType2 must appear in the list before
            // piType1 so piType1 is greater than piType2.
            if (piType1.Parent == piType2)
              return 1;

            // If piType1 is the parent of piType2 then piType1 must appear in the list before
            // piType2 so piType1 is less than piType2.
            if (piType2.Parent == piType1)
              return -1;

            // If piType1 has a null parent and we are here we know that piType2 must have a
            // a parent therefore we want piType1 to appear in the list before piType2 so
            // piType1 is less than piType2.
            if (piType1.Parent == null)
              return -1;

            // If piType2 has a null parent and we are here we know that piType1 must have a
            // a parent therefore we want piType1 to appear in the list after piType2 so
            // piType1 is greater than piType2.
            if (piType2.Parent == null)
              return 1;

            // Both items have parents but the parents are different.  In this case we
            // sort them by parent id to ensure that there is some ultimate order so that
            // proper comparisons are done for future items added to this list.

            // If piType1s ParentID is greater then piType2s then we want piType2 to be before
            // piType1.
            if (piType1.Parent.ID > piType2.Parent.ID)
              return 1;

            // If we get here we know that piType2s ParentID must be greater then piType1s
            // so we want piType1 to go before piType2.
            return -1;
#endif
          }
        case InstructionType.DeleteUsageCharge:
        case InstructionType.DeleteAggregateCharge:
          {
            IMTPriceableItem piType1 = (IMTPriceableItem) this.Argument1;
            IMTPriceableItem piType2 = (IMTPriceableItem) rhs.Argument1;

            // The code in the "if true" block assumes the following:
            //
            // 1. We only have one level of children.
            // 2. All parents can not be a child (i.e. thier Parent field must be null).
            // 3. All children must have a parent (i.e. thier Parent field must not be null).
            //
            // With these assumptions we can simply group these items by putting all the
            // parents (all the items whose Parent is null) before all the children (all
            // the items whose Parent is not null).
            //
            // If we were to allow multiple levels of children (i.e. grandchildren, etc.)
            // then we would want to use the code in the "else" block.
#if true
            // If piType1 has a null parent then we can put it after piType2 regardless
            // of whether piType2 has a null parent or not.
            if (piType1.ParentID == PROPERTIES_BASE_NO_ID)
              return 1;

            // If piType2 has a null parent it must go after piType1 because we know
            // that piType1 does not have a null parent.
            if (piType2.ParentID == PROPERTIES_BASE_NO_ID)
              return -1;

            // Otherwise we don't care which goes first.
            return 0;
#else
            // If they both have the same parent or if they both have null parents they are equal.
            if (piType1.ParentID == piType2.ParentID)
              return 0;

            // If piType2 is the parent of piType1 then piType1 must appear in the list before
            // piType2 so piType1 is less than piType2.
            if (piType1.ParentID == piType2.ID)
              return -1;

            // If piType1 is the parent of piType2 then piType2 must appear in the list before
            // piType1 so piType1 is greater than piType2.
            if (piType2.ParentID == piType1.ID)
              return 1;

            // If piType1 has a null parent and we are here we know that piType2 must have a
            // a parent therefore we want piType2 to appear in the list before piType1 so
            // piType1 is greater than piType2.
            if (piType1.ParentID == PROPERTIES_BASE_NO_ID)
              return 1;

            // If piType2 has a null parent and we are here we know that piType1 must have a
            // a parent therefore we want piType2 to appear in the list after piType1 so
            // piType1 is less than piType2.
            if (piType2.ParentID == PROPERTIES_BASE_NO_ID)
              return -1;

            // Both items have parents but the parents are different.  In this case we
            // sort them by parent id to ensure that there is some ultimate order so that
            // proper comparisons are done for future items added to this list.

            // If piType1s ParentID is greater then piType2s then we want piType1 to be before
            // piType2.
            if (piType1.ParentID > piType2.ParentID)
              return -1;

            // If we get here we know that piType2s ParentID must be greater then piType1s
            // so we want piType2 to go before piType1.
            return 1;
#endif
          }
        default:
          return 0;
        }
      }
      else
      {
        return 1;
      }
    }

    public override String ToString()
    {
      if(Argument1 == null)
      {
        return Type.ToString();
      }
      else if(Argument2 == null)
      {
        return Type.ToString() + "(" + Argument1.GetType().InvokeMember("Name", BindingFlags.GetProperty, null, Argument1, null) + ")";
      }
      else
      {
        return Type.ToString() + "(" + Argument1.GetType().InvokeMember("Name", BindingFlags.GetProperty, null, Argument1, null) + ", " + 
        Argument2.GetType().InvokeMember("Name", BindingFlags.GetProperty, null, Argument2, null) + ")";
      }
    }

    // PriceableItemType
    static public Instruction DeletePriceableItemType(IMTPriceableItemType pcPiType)
    {
      return new Instruction(InstructionType.DeletePriceableItemType, pcPiType, null);
    }
    static public Instruction UpdatePriceableItemType(PriceableItemType piType,
                                                      IMTPriceableItemType pcPiType)
    {
      return new Instruction(InstructionType.UpdatePriceableItemType, piType, pcPiType);
    }
    static public Instruction CreatePriceableItemType(PriceableItemType piType)
    {
      return new Instruction(InstructionType.CreatePriceableItemType, piType, null);
    }

    // AggregateCharge
    static public Instruction DeleteAggregateCharge(IMTAggregateCharge pcCharge,
                                                    IMTPriceableItemType pcPiType)
    {
      return new Instruction(InstructionType.DeleteAggregateCharge, pcCharge, pcPiType);
    }
    static public Instruction UpdateAggregateCharge(AggregateCharge charge,
                                                    IMTAggregateCharge pcAggregateCharge)
    {
      return new Instruction(InstructionType.UpdateAggregateCharge, charge, pcAggregateCharge);
    }
    static public Instruction CreateAggregateCharge(AggregateCharge charge,
                                                    PriceableItemType piType)
    {
      return new Instruction(InstructionType.CreateAggregateCharge, charge, piType);
    }

    // UsageCharge
    static public Instruction DeleteUsageCharge(IMTPriceableItem pcCharge,
                                                IMTPriceableItemType pcPiType)
    {
      return new Instruction(InstructionType.DeleteUsageCharge, pcCharge, pcPiType);
    }
    static public Instruction UpdateUsageCharge(UsageCharge charge,
                                                IMTPriceableItem pcUsageCharge)
    {
      return new Instruction(InstructionType.UpdateUsageCharge, charge, pcUsageCharge);
    }
    static public Instruction CreateUsageCharge(UsageCharge charge,
                                                PriceableItemType piType)
    {
      return new Instruction(InstructionType.CreateUsageCharge, charge, piType);
    }

    // Charge
    static public Instruction DeleteCharge(IMTCharge charge)
    {
      return new Instruction(InstructionType.DeleteCharge, charge, null);
    }
    static public Instruction UpdateCharge(Charge charge,
                                           IMTCharge pcCharge)
    {
      return new Instruction(InstructionType.UpdateCharge, charge, pcCharge);
    }
    static public Instruction CreateCharge(Charge charge,
                                           PriceableItemType piType)
    {
      return new Instruction(InstructionType.CreateCharge, charge, piType);
    }

    // ChargeProperty
    static public Instruction DeleteChargeProperty(IMTChargeProperty chargeProperty)
    {
      return new Instruction(InstructionType.DeleteChargeProperty, chargeProperty, null);
    }
    static public Instruction UpdateChargeProperty(ChargeProperty chargeProperty,
                                                   IMTChargeProperty pcChargeProperty)
    {
      return new Instruction(InstructionType.UpdateChargeProperty, chargeProperty, pcChargeProperty);
    }
    static public Instruction CreateChargeProperty(ChargeProperty chargeProperty,
                                                   Charge charge)
    {
      return new Instruction(InstructionType.CreateChargeProperty, chargeProperty, charge);
    }

    // CounterPropertyDefinition
    static public Instruction DeleteCounterPropertyDefinition(IMTCounterPropertyDefinition charge)
    {
      return new Instruction(InstructionType.DeleteCounterPropertyDefinition, charge, null);
    }
    static public Instruction UpdateCounterPropertyDefinition(CounterPropertyDefinition charge,
                                           IMTCounterPropertyDefinition pcCounterPropertyDefinition)
    {
      return new Instruction(InstructionType.UpdateCounterPropertyDefinition, charge, pcCounterPropertyDefinition);
    }
    static public Instruction CreateCounterPropertyDefinition(CounterPropertyDefinition charge,
                                                              PriceableItemType piType)
    {
      return new Instruction(InstructionType.CreateCounterPropertyDefinition, charge, piType);
    }

    // Counter
    static public Instruction DeleteCounter(IMTCounter counter,
                                            AggregateCharge piTemplate)
    {
      return new Instruction(InstructionType.DeleteCounter, counter, piTemplate);
    }
    static public Instruction UpdateCounter(CounterPropertyDefinition counter,
                                            PriceableItemType piType)
    {
      return new Instruction(InstructionType.UpdateCounter, counter, piType);
    }
    static public Instruction CreateCounter(Counter counter,
                                            AggregateCharge piTemplate,
                                            CounterPropertyDefinition cpd)
    {
      return new Instruction(InstructionType.CreateCounter, counter, piTemplate, cpd);
    }

    // ParameterTable
    static public Instruction DeleteParameterTable(IMTParamTableDefinition charge,
                                                   IMTPriceableItemType pcPiType)
    {
      return new Instruction(InstructionType.DeleteParameterTable, charge, pcPiType);
    }
    static public Instruction UpdateParameterTable(ParameterTable charge,
                                           IMTParamTableDefinition pcParameterTable)
    {
      return new Instruction(InstructionType.UpdateParameterTable, charge, pcParameterTable);
    }
    static public Instruction CreateParameterTable(ParameterTable charge,
                                                   PriceableItemType piType)
    {
      return new Instruction(InstructionType.CreateParameterTable, charge, piType);
    }

    // AdjustmentType
    static public Instruction DeleteAdjustmentType(IAdjustmentType adjType)
    {
      return new Instruction(InstructionType.DeleteAdjustmentType, adjType, null);
    }
    static public Instruction UpdateAdjustmentType(IAdjustmentType after,
                                                   IAdjustmentType before)
    {
      return new Instruction(InstructionType.UpdateAdjustmentType, after, before);
    }
    static public Instruction CreateAdjustmentType(IAdjustmentType adjType,
                                                   PriceableItemType piType)
    {
      return new Instruction(InstructionType.CreateAdjustmentType, adjType, piType);
    }

    // AdjustmentTemplate
    static public Instruction DeleteAdjustmentTemplate(Adjustment adjTemplate)
    {
      return new Instruction(InstructionType.DeleteAdjustmentTemplate, adjTemplate, null);
    }
    static public Instruction UpdateAdjustmentTemplate(AdjustmentTemplate after,
                                                       Adjustment before)
    {
      return new Instruction(InstructionType.UpdateAdjustmentTemplate, after, before);
    }
    static public Instruction CreateAdjustmentTemplate(AdjustmentTemplate adjType,
                                                       UsageCharge piTemplate)
    {
      return new Instruction(InstructionType.CreateAdjustmentTemplate, adjType, piTemplate);
    }

    // ApplicabilityRule
    static public Instruction DeleteApplicabilityRule(ApplicabilityRule adjRule, AdjustmentType adjType)
    {
      return new Instruction(InstructionType.DeleteApplicabilityRule, adjRule, adjType);
    }
    static public Instruction UpdateApplicabilityRule(ApplicabilityRule after,
                                                      ApplicabilityRule before)
    {
      return new Instruction(InstructionType.UpdateApplicabilityRule, after, before);
    }
    static public Instruction CreateApplicabilityRule(ApplicabilityRule adjRule,
                                                      AdjustmentType adjType)
    {
      return new Instruction(InstructionType.CreateApplicabilityRule, adjRule, adjType);
    }

    // ReasonCode
    static public Instruction DeleteReasonCode(ReasonCode adjCode, Adjustment adjTemplate)
    {
      return new Instruction(InstructionType.DeleteReasonCode, adjCode, adjTemplate);
    }
    static public Instruction UpdateReasonCode(ReasonCode after,
                                               ReasonCode before)
    {
      return new Instruction(InstructionType.UpdateReasonCode, after, before);
    }
    static public Instruction CreateReasonCode(ReasonCode adjCode,
                                               AdjustmentTemplate adjTemplate)
    {
      return new Instruction(InstructionType.CreateReasonCode, adjCode, adjTemplate);
    }

    // Checksum
    static public Instruction DeleteChecksum(IMTPriceableItemType pcPiType)
    {
      return new Instruction(InstructionType.DeleteChecksum, pcPiType, null);
    }
    static public Instruction UpdateChecksum(PriceableItemType piType)
    {
      return new Instruction(InstructionType.UpdateChecksum, piType, null);
    }
    static public Instruction CreateChecksum(PriceableItemType piType)
    {
      return new Instruction(InstructionType.CreateChecksum, piType, null);
    }

  }

  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("3a6804bf-ba4b-4e7b-8ea8-8c66e559a3e1")]
  public class PriceableItemTypeWriter : ServicedComponent
  {
    // Our "interpreter" has an associative memory of
    // pairs (PCobject, localObject).  We provide convenient
    // typed memory accessors.
    private Hashtable mMemory = new Hashtable();
    private Hashtable mMemoryIndex = new Hashtable();
    private MetraTech.ILogger mLogger = new MetraTech.Logger("[PriceableItemTypeHook]");

		protected IMTPriceableItemType GetPriceableItemTypeByName(string pitypename)
		{
			IMTProductCatalog pc = 
				(IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
			return this.GetPriceableItemTypeByName(pc, pitypename);
		}

		protected IMTPriceableItemType GetPriceableItemTypeByName(IMTProductCatalog pc, string pitypename)
		{
			MetraTech.Interop.MTProductCatalogExec.IMTPriceableItemTypeReader reader = 
				new MetraTech.Interop.MTProductCatalogExec.MTPriceableItemTypeReaderClass();
			return (IMTPriceableItemType)reader.FindByName
				((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), 
				pitypename);
		}

    private void InternalMemoryWrite(Object pc, Object local)
    {
      if(pc != null) mMemory[pc] = local;
      if(local != null) mMemoryIndex[local] = pc;
    }

    // Priceable Item Type
    private void MemoryWrite(IMTPriceableItemType pc, PriceableItemType local)
    {
      InternalMemoryWrite(pc, local);
    }

    private IMTPriceableItemType MemoryRead(PriceableItemType local)
    {
      return (IMTPriceableItemType) mMemoryIndex[local];
    }

    private PriceableItemType MemoryRead(IMTPriceableItemType pc)
    {
      return (PriceableItemType) mMemory[pc];
    }

    // Charge
    private void MemoryWrite(IMTCharge pc, Charge local)
    {
      InternalMemoryWrite(pc, local);
    }

    private IMTCharge MemoryRead(Charge local)
    {
      return (IMTCharge) mMemoryIndex[local];
    }

    private Charge MemoryRead(IMTCharge pc)
    {
      return (Charge) mMemory[pc];
    }

    // Charge Property
    private void MemoryWrite(IMTChargeProperty pc, ChargeProperty local)
    {
      InternalMemoryWrite(pc, local);
    }

    private ChargeProperty MemoryRead(IMTChargeProperty pc)
    {
      return (ChargeProperty) mMemory[pc];
    }

    private IMTChargeProperty MemoryRead(ChargeProperty local)
    {
      return (IMTChargeProperty) mMemoryIndex[local];
    }

    // Counter Property Definition
    private void MemoryWrite(IMTCounterPropertyDefinition pc, CounterPropertyDefinition local)
    {
      InternalMemoryWrite(pc, local);
    }

    private IMTCounterPropertyDefinition MemoryRead(CounterPropertyDefinition local)
    {
      return (IMTCounterPropertyDefinition) mMemoryIndex[local];
    }

    private CounterPropertyDefinition MemoryRead(IMTCounterPropertyDefinition pc)
    {
      return (CounterPropertyDefinition) mMemory[pc];
    }

    // Counter 
    private void MemoryWrite(IMTCounter pc, Counter local)
    {
      InternalMemoryWrite(pc, local);
    }

    private IMTCounter MemoryRead(Counter local)
    {
      return (IMTCounter) mMemoryIndex[local];
    }

    private Counter MemoryRead(IMTCounter pc)
    {
      return (Counter) mMemory[pc];
    }

    // AggregateCharge 
    private void MemoryWrite(IMTAggregateCharge pc, AggregateCharge local)
    {
      InternalMemoryWrite(pc, local);
    }

    private IMTAggregateCharge MemoryRead(AggregateCharge local)
    {
      return (IMTAggregateCharge) mMemoryIndex[local];
    }

    private AggregateCharge MemoryRead(IMTAggregateCharge pc)
    {
      return (AggregateCharge) mMemory[pc];
    }

    // UsageCharge 
    private void MemoryWrite(IMTPriceableItem pc, UsageCharge local)
    {
      InternalMemoryWrite(pc, local);
    }

    private IMTPriceableItem MemoryRead(UsageCharge local)
    {
      return (IMTPriceableItem) mMemoryIndex[local];
    }

    private UsageCharge MemoryRead(IMTPriceableItem pc)
    {
      return (UsageCharge) mMemory[pc];
    }

    // Parameter Table
    private void MemoryWrite(IMTParamTableDefinition pc, ParameterTable local)
    {
      InternalMemoryWrite(pc, local);
    }

    private IMTParamTableDefinition MemoryRead(ParameterTable local)
    {
      return (IMTParamTableDefinition) mMemoryIndex[local];
    }

    private ParameterTable MemoryRead(IMTParamTableDefinition pc)
    {
      return (ParameterTable) mMemory[pc];
    }

    // AdjustmentType
    private void MemoryWrite(IAdjustmentType pc, IAdjustmentType local)
    {
      InternalMemoryWrite(pc, local);
    }

    private AdjustmentType MemoryReadLocalToPC(AdjustmentType local)
    {
      return (AdjustmentType) mMemoryIndex[local];
    }

    private AdjustmentType MemoryReadPCToLocal(AdjustmentType pc)
    {
      return (AdjustmentType) mMemory[pc];
    }

    // ApplicabilityRule
    private void MemoryWrite(ApplicabilityRule pc, ApplicabilityRule local)
    {
      InternalMemoryWrite(pc, local);
    }

    private ApplicabilityRule MemoryReadLocalToPC(ApplicabilityRule local)
    {
      return (ApplicabilityRule) mMemoryIndex[local];
    }

    private ApplicabilityRule MemoryReadPCToLocal(ApplicabilityRule pc)
    {
      return (ApplicabilityRule) mMemory[pc];
    }

    // AdjustmentTemplate
    private void MemoryWrite(Adjustment pc, AdjustmentTemplate local)
    {
      InternalMemoryWrite(pc, local);
    }

    private Adjustment MemoryRead(AdjustmentTemplate local)
    {
      return (Adjustment) mMemoryIndex[local];
    }

    private AdjustmentTemplate MemoryRead(Adjustment pc)
    {
      return (AdjustmentTemplate) mMemory[pc];
    }

    // ReasonCode
    private void MemoryWrite(ReasonCode pc, ReasonCode local)
    {
      InternalMemoryWrite(pc, local);
    }

    private ReasonCode MemoryReadLocalToPC(ReasonCode local)
    {
      return (ReasonCode) mMemoryIndex[local];
    }

    private ReasonCode MemoryReadPCToLocal(ReasonCode pc)
    {
      return (ReasonCode) mMemory[pc];
    }

    // Reflection driven update of properties
    void PropagateProperty(Object target, Object source, String [] targetProperty, String [] sourceProperty, ref bool change)
    {
      // This guy implements propagating properies down a chain of properties...
      // obj1.prop1.prop2 = obj2.prop3.pro4.prop5;
      Object targetProp=null;
      for(int i=0; i<targetProperty.Length; i++)
      {
        if (i > 0) target = targetProp;
        targetProp = target.GetType().InvokeMember(targetProperty[i], BindingFlags.GetProperty, null, target, null);
      }

      Object sourceProp = null;
      for(int i=0; i<sourceProperty.Length; i++)
      {
        if (i > 0) source = sourceProp;
        sourceProp = source.GetType().InvokeMember(sourceProperty[i], BindingFlags.GetProperty, null, source, null);
      }

      if (targetProp != null || sourceProp != null)
      {
        if(targetProp == null || !targetProp.Equals(sourceProp))
        {
          target.GetType().InvokeMember(targetProperty[targetProperty.Length - 1], BindingFlags.SetProperty, null, target, new Object [] {sourceProp} );
          change = true;
        }
      }
    }

    // Reflection driven update of properties
    void PropagateProperty(Object target, Object source, String targetProperty, String sourceProperty, ref bool change)
    {
      Object targetProp = target.GetType().InvokeMember(targetProperty, BindingFlags.GetProperty, null, target, null);
      Object sourceProp = source.GetType().InvokeMember(sourceProperty, BindingFlags.GetProperty, null, source, null);
      if (targetProp != null || sourceProp != null)
      {
        if(targetProp == null || !targetProp.Equals(sourceProp))
        {
          target.GetType().InvokeMember(targetProperty, BindingFlags.SetProperty, null, target, new Object [] {sourceProp} );
          change = true;
        }
      }
    }

    void PropagateProperty(Object target, Object source, String property, ref bool change)
    {
      PropagateProperty(target, source, property, property, ref change);
    }

	  /// <summary>
	  /// Function used to find the difference in the child adjustments for the passed target 
	  /// (generated from the database) and the source (created from the xml-schema) of the type
	  /// composite adjustment. The child  adjustment types are stored as a collection in the 
	  /// composite adjustment type class
	  /// </summary>
	  /// <param name="target">object created from the database</param>
	  /// <param name="source">object created by reading the xml file</param>
	  /// <param name="targetProperty">property to be matched in the target object</param>
	  /// <param name="sourceProperty">property to be matched in the source property</param>
	  /// <param name="classtypecollection">indicates whether the property is of type collection</param>
	  /// <param name="change">passed as a reference</param>
	  void PropagateProperty(Object target, Object source, String targetProperty, String sourceProperty, bool classtypecollection, ref bool change)
	  {
		  if( classtypecollection )
		  {
			  Object targetProp = target.GetType().InvokeMember(targetProperty, BindingFlags.GetProperty, null, target, null);
			  Object sourceProp = source.GetType().InvokeMember(sourceProperty, BindingFlags.GetProperty, null, source, null);


			  if (targetProp != null || sourceProp != null)
			  {
				  if(targetProp == null )
				  {
					  target.GetType().InvokeMember(targetProperty, BindingFlags.SetProperty, null, target, new Object [] {sourceProp} );
					  change = true;
				  }
				  else 
				  {
					  MetraTech.Interop.GenericCollection.IMTCollection targetCol = (MetraTech.Interop.GenericCollection.IMTCollection) targetProp;
					  MetraTech.Interop.GenericCollection.IMTCollection sourceCol = (MetraTech.Interop.GenericCollection.IMTCollection) sourceProp;
					  bool matchfound = false;
					  if( sourceCol.Count == targetCol.Count )
					  {
						  for(int iSourceCount=1; iSourceCount<=sourceCol.Count;iSourceCount++)
						  {
							  IAdjustmentType sourceAdjType = (IAdjustmentType) sourceCol[iSourceCount ];
							  matchfound = false;
							  for(int iTargetCount=1; iTargetCount<=targetCol.Count;iTargetCount++)
							  {	
								  IAdjustmentType targetAdjType = (IAdjustmentType) targetCol[iTargetCount ]; 
								  if( (sourceAdjType.PIName==targetAdjType.PIName) && (sourceAdjType.Name==targetAdjType.Name) )
								  {
									  matchfound = true;
									  break;
								  }
							  }
							  if(!matchfound)
								  break;
						  }
					  }
					  if(!matchfound)
					  {
						  target.GetType().InvokeMember(targetProperty, BindingFlags.SetProperty, null, target, new Object [] {sourceProp} );
						  change = true;					  }

				  }
			  }
		  }
	  }

    IMTPriceableItemType GetPriceableItemType(IMTProductCatalog pc, PriceableItemType piType)
    {
      if (piType == null) return null;
      IMTPriceableItemType pcPiType = MemoryRead(piType);
      if(pcPiType != null) return pcPiType;
      return GetPriceableItemTypeByName(pc, piType.Name);
    }

    IMTPriceableItem GetPriceableItemTemplate(IMTProductCatalog pc, UsageCharge piTemplate)
    {
      if(piTemplate == null) return null;
      IMTPriceableItem pcTemplatePi = MemoryRead(piTemplate);
      if (pcTemplatePi != null) return pcTemplatePi;
      foreach(IMTPriceableItem pcPi in GetPriceableItemType(pc, piTemplate.Type).GetTemplates())
      {
        if(pcPi.Name == piTemplate.Name)
        {
          pcTemplatePi = pcPi;
          break;
        }
      }
      return pcTemplatePi;
    }

    // The interpreter itself...

    void Execute(IMTProductCatalog pc, ArrayList prog)
    {
			
      foreach(Instruction inst in prog)
      {
				mLogger.LogDebug( "Executing the Instruction: " + ((InstructionType) inst.Type) );
        if(inst.Type == InstructionType.DeleteChargeProperty)
        {
          IMTChargeProperty pcChargeProperty = (IMTChargeProperty)inst.Argument1;
          mLogger.LogDebug("Deleting charge property: ID = {0}", new object[] {pcChargeProperty.ID});
          MetraTech.Interop.MTProductCatalogExec.IMTChargePropertyWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTChargePropertyWriterClass();
          writer.Remove((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), 
                        pcChargeProperty.ID);
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateChargeProperty)
        {
          ChargeProperty chargeProperty = (ChargeProperty) inst.Argument1;
          IMTChargeProperty pcChargeProperty = (IMTChargeProperty) inst.Argument2;


          // Only update if there is a real change.
          bool change=false;
          PropagateProperty(pcChargeProperty, chargeProperty, "ProductViewPropertyID", ref change);
          if (change)
          {
            mLogger.LogDebug("Updating charge property: ID = {0}", new object[] {pcChargeProperty.ID});
            MetraTech.Interop.MTProductCatalogExec.IMTChargePropertyWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTChargePropertyWriterClass();
            writer.Update((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(),
                          (MetraTech.Interop.MTProductCatalogExec.IMTChargeProperty)pcChargeProperty);
          }
          else
          {
            mLogger.LogDebug("No change detected in charge property: ID = {0}", new object[] {pcChargeProperty.ID});
          }

          // Set in memory
          MemoryWrite(pcChargeProperty, chargeProperty);
        }
        else if(inst.Type == InstructionType.CreateChargeProperty)
        {
          ChargeProperty chargeProperty = (ChargeProperty) inst.Argument1;
          IMTCharge pcCharge = MemoryRead((Charge) inst.Argument2);
          mLogger.LogDebug("Creating charge property: name = {0} in charge: ID={1}; name={2}", new object[] {chargeProperty.Name, pcCharge.ID, pcCharge.Name});
          MetraTech.Interop.MTProductView.IProductView pv = (MetraTech.Interop.MTProductView.IProductView) MemoryRead(((Charge) inst.Argument2).PIType).GetProductViewObject();
          IMTChargeProperty pcChargeProperty = CreateChargeProperty(pc, chargeProperty, pcCharge, pv);

          // Set in memory
          MemoryWrite(pcChargeProperty, chargeProperty);
        }
        else if(inst.Type == InstructionType.DeleteCharge)
        {
          IMTCharge pcCharge = (IMTCharge)inst.Argument1;
          mLogger.LogDebug("Deleting charge: ID = {0}; name = {1}", new object[] {pcCharge.ID, pcCharge.Name});
          MetraTech.Interop.MTProductCatalogExec.IMTChargeWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTChargeWriterClass();
          writer.Remove((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), 
                        pcCharge.ID);
					//Regenerate adjustment table
					AdjustmentTypeWriter ajw = new AdjustmentTypeWriter();
					ajw.DropAndCreateAdjustmentTable(pc.GetSessionContext(), pcCharge.PITypeID);
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateCharge)
        {
          Charge charge = (Charge) inst.Argument1;
          IMTCharge pcCharge = (IMTCharge) inst.Argument2;
          // Only update if there is a real change.
          bool change=false;
          PropagateProperty(pcCharge, charge, "Name", ref change);
          PropagateProperty(pcCharge, charge, "DisplayName", ref change);
          PropagateProperty(pcCharge, charge, "AmountPropertyID", ref change);
          if (change)
          {
            mLogger.LogDebug("Updating charge: ID = {0}; Name = {1}", new object[] {pcCharge.ID, pcCharge.Name});
            MetraTech.Interop.MTProductCatalogExec.IMTChargeWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTChargeWriterClass();
            writer.Update((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(),
                          (MetraTech.Interop.MTProductCatalogExec.IMTCharge)pcCharge);
						//Regenerate adjustment table
						AdjustmentTypeWriter ajw = new AdjustmentTypeWriter();
						ajw.DropAndCreateAdjustmentTable(pc.GetSessionContext(), pcCharge.PITypeID);
          }
          else
          {
            mLogger.LogDebug("No change detected in charge: ID = {0}; Name = {1}", new object[] {pcCharge.ID, pcCharge.Name});
          }

          // Set in memory
          MemoryWrite(pcCharge, charge);
        }
        else if(inst.Type == InstructionType.CreateCharge)
        {
          Charge charge = (Charge) inst.Argument1;
          IMTPriceableItemType pcPiType = MemoryRead((PriceableItemType) inst.Argument2);
          mLogger.LogDebug("Creating charge: name = {0} in priceable item type: ID={1}; name={2}", new object[] {charge.Name, pcPiType.ID, pcPiType.Name});
          MetraTech.Interop.MTProductView.IProductView pv = (MetraTech.Interop.MTProductView.IProductView) pcPiType.GetProductViewObject();
          IMTCharge pcCharge = CreateCharge(pc, charge, pcPiType, pv);
					//Regenerate adjustment table
					AdjustmentTypeWriter ajw = new AdjustmentTypeWriter();
					ajw.DropAndCreateAdjustmentTable(pc.GetSessionContext(), pcPiType.ID);

          // Set in memory
          MemoryWrite(pcCharge, charge);
        }
        else if(inst.Type == InstructionType.DeleteAggregateCharge)
        {
          IMTAggregateCharge pcAggregateCharge = (IMTAggregateCharge) inst.Argument1;
          IMTPriceableItemType pcPiType = (IMTPriceableItemType) inst.Argument2;
          mLogger.LogDebug("Deleting aggregate charge template: ID = {0}; Name={1} from pricable item type: ID={2}; Name={3}",
                           pcAggregateCharge.ID, pcAggregateCharge.Name, pcPiType.ID, pcPiType.Name);
          pcPiType.RemoveTemplate(pcAggregateCharge.ID);
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateAggregateCharge)
        {
          AggregateCharge charge = (AggregateCharge) inst.Argument1;
          IMTAggregateCharge pcAggregateCharge = (IMTAggregateCharge) inst.Argument2;

          // Actually perform updates if something changed.
          bool change=false;
          PropagateProperty(pcAggregateCharge, charge, "Name", ref change);

          // Handle changes to the parent template
          IMTPriceableItem pcParentCharge = GetPriceableItemTemplate(pc, charge.Parent);
          if (pcAggregateCharge.ParentID != (pcParentCharge == null ? -1 : pcParentCharge.ID))
          {
            change = true;
            pcAggregateCharge.ParentID = (pcParentCharge == null ? -1 : pcParentCharge.ID);
          }

          if (change)
          {
            mLogger.LogDebug("Updating aggregate charge template: ID = {0}; Name={1}",
                             pcAggregateCharge.ID, pcAggregateCharge.Name);
            MetraTech.Interop.MTProductCatalogExec.IMTPriceableItemWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTPriceableItemWriterClass();
            writer.Update((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext) pc.GetSessionContext(),
                          (MetraTech.Interop.MTProductCatalogExec.IMTPriceableItem) pcAggregateCharge);
          }
          else
          {
            mLogger.LogDebug("No change detected in aggregate charge template: ID = {0}; Name={1}",
                             pcAggregateCharge.ID, pcAggregateCharge.Name);
          }

          // Set in memory
          MemoryWrite(pcAggregateCharge, charge);
        }
        else if(inst.Type == InstructionType.CreateAggregateCharge)
        {
          AggregateCharge charge = (AggregateCharge) inst.Argument1;
          IMTPriceableItemType pcPiType = MemoryRead((PriceableItemType) inst.Argument2);

          mLogger.LogDebug("Creating aggregate charge template: Name={0} in priceable item type: ID={1}; Name={2}",
                           charge.Name, pcPiType.ID, pcPiType.Name);

          IMTAggregateCharge pcAggregateCharge = 
          (IMTAggregateCharge) pcPiType.CreateTemplate(false);

          charge.CopyTo(pcAggregateCharge);

          // Manually handle the parent (if any)
          if(charge.Parent != null)
          {
            pcAggregateCharge.ParentID = GetPriceableItemTemplate(pc, charge.Parent).ID;
          }

          // Note that the AggregateCharge saves its adjustment templates.
          pcAggregateCharge.Save();
          // Set in memory
          MemoryWrite(pcAggregateCharge, charge);
        }
        else if(inst.Type == InstructionType.DeleteUsageCharge)
        {
          IMTPriceableItem pcUsageCharge = (IMTPriceableItem) inst.Argument1;
          IMTPriceableItemType pcPiType = (IMTPriceableItemType) inst.Argument2;
          mLogger.LogDebug("Deleting non-aggregate usage charge template: ID = {0}; Name={1} from pricable item type: ID={2}; Name={3}",
                           pcUsageCharge.ID, pcUsageCharge.Name, pcPiType.ID, pcPiType.Name);
          pcPiType.RemoveTemplate(pcUsageCharge.ID);
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateUsageCharge)
        {
          UsageCharge charge = (UsageCharge) inst.Argument1;
          IMTPriceableItem pcUsageCharge = (IMTPriceableItem) inst.Argument2;

          // Actually perform updates if something changed.
          bool change=false;
          PropagateProperty(pcUsageCharge, charge, "Name", ref change);

          IMTPriceableItem pcParentCharge = GetPriceableItemTemplate(pc, charge.Parent);
          if (pcUsageCharge.ParentID != (pcParentCharge == null ? -1 : pcParentCharge.ID))
          {
            change = true;
            pcUsageCharge.ParentID = (pcParentCharge == null ? -1 : pcParentCharge.ID);
          }

          if (change)
          {
            mLogger.LogDebug("Updating non-aggregate usage charge template: ID = {0}; Name={1}",
                             pcUsageCharge.ID, pcUsageCharge.Name);
            MetraTech.Interop.MTProductCatalogExec.IMTPriceableItemWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTPriceableItemWriterClass();
            writer.Update((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext) pc.GetSessionContext(),
                          (MetraTech.Interop.MTProductCatalogExec.IMTPriceableItem) pcUsageCharge);
          }
          else
          {
            mLogger.LogDebug("No change detected in non-aggregate usage charge template: ID = {0}; Name={1}",
                             pcUsageCharge.ID, pcUsageCharge.Name);
          }

          // Set in memory
          MemoryWrite(pcUsageCharge, charge);
        }
        else if(inst.Type == InstructionType.CreateUsageCharge)
        {
          UsageCharge charge = (UsageCharge) inst.Argument1;
          IMTPriceableItemType pcPiType = MemoryRead((PriceableItemType) inst.Argument2);

          mLogger.LogDebug("Creating non-aggregate usage charge template: Name={0} in pricable item type: ID={1}; Name={2}",
                           charge.Name, pcPiType.ID, pcPiType.Name);

          IMTPriceableItem pcUsageCharge = 
          (IMTPriceableItem) pcPiType.CreateTemplate(false);

          charge.CopyTo(pcUsageCharge);

          // Manually handle the parent (if any)
          if(charge.Parent != null)
          {
            pcUsageCharge.ParentID = GetPriceableItemTemplate(pc, charge.Parent).ID;
          }

          // Note that the UsageCharge saves its adjustment templates.
          pcUsageCharge.Save();
          // Set in memory
          MemoryWrite(pcUsageCharge, charge);
        }
        else if(inst.Type == InstructionType.DeletePriceableItemType)
        {
          IMTPriceableItemType pcPiType = 
          (IMTPriceableItemType) inst.Argument1;
          mLogger.LogDebug("Deleting priceable item type: ID = {0}; Name={1}",
                           pcPiType.ID, pcPiType.Name);
          InternalRemovePriceableItemType(pc, pcPiType);
        }
        else if(inst.Type == InstructionType.UpdatePriceableItemType)
        {
          PriceableItemType piType = (PriceableItemType) inst.Argument1;
          IMTPriceableItemType pcPiType = (IMTPriceableItemType) inst.Argument2;

          bool change=false;
          PropagateProperty(pcPiType, piType, "Name", ref change);
          PropagateProperty(pcPiType, piType, "Description", ref change);
          PropagateProperty(pcPiType, piType, "ServiceDefinition", ref change);
          PropagateProperty(pcPiType, piType, "ProductView", ref change);
          PropagateProperty(pcPiType, piType, "ConstrainSubscriberCycle", ref change);

          // TODO: Reflection doesn't handle this property since the Kind comes back as Int32.
          // Not sure how important this is...
//          PropagateProperty(pcPiType, piType, "Kind", "EntityType", ref change);

          // Our PropagateProperty infrastructure doesn't handle associations so we do the
          // parent child manually
          IMTPriceableItemType pcParentPiType = null;
          if (piType.Parent != null)
          {
            pcParentPiType = MemoryRead(piType.Parent);
            if(pcParentPiType == null)
            {
              pcParentPiType = GetPriceableItemTypeByName(pc, piType.Parent.Name);
            }
          }
          if (pcPiType.ParentID != (piType.Parent == null ? -1 : pcParentPiType.ID))
          {
            change = true;
            pcPiType.ParentID = (piType.Parent == null ? -1 : pcParentPiType.ID);
          }

          if (change)
          {
            mLogger.LogDebug("Updating priceable item type: ID = {0}; Name={1}",
                             pcPiType.ID, pcPiType.Name);
            MetraTech.Interop.MTProductCatalogExec.IMTPriceableItemTypeWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTPriceableItemTypeWriterClass();
            writer.Update((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext) pc.GetSessionContext(),
                          (MetraTech.Interop.MTProductCatalogExec.IMTPriceableItemType) pcPiType);
          }
          else
          {
            mLogger.LogDebug("No change detected in priceable item type: ID = {0}; Name={1}",
                            pcPiType.ID, pcPiType.Name);
          }

          // Set in memory
          MemoryWrite(pcPiType, piType);
        }
        else if(inst.Type == InstructionType.CreatePriceableItemType)
        {
          PriceableItemType piType = (PriceableItemType) inst.Argument1;
          mLogger.LogDebug("Creating priceable item type: Name={0}",
                           piType.Name);
          MemoryWrite(CreatePriceableItemType(pc, piType), piType);
        }
        else if(inst.Type == InstructionType.DeleteCounterPropertyDefinition)
        {
          IMTCounterPropertyDefinition pcCpd = (IMTCounterPropertyDefinition)inst.Argument1; 
          mLogger.LogDebug("Deleting counter property definition: ID = {0}; Name={1}",
                           pcCpd.ID, pcCpd.Name);
          MetraTech.Interop.MTProductCatalogExec.IMTCounterPropertyDefinitionWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTCounterPropertyDefinitionWriterClass();
          writer.Remove((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), 
                        pcCpd.ID);
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateCounterPropertyDefinition)
        {
          CounterPropertyDefinition cpd = (CounterPropertyDefinition) inst.Argument1;
          IMTCounterPropertyDefinition pcCpd = (IMTCounterPropertyDefinition) inst.Argument2;

          bool change=false;
          PropagateProperty(pcCpd, cpd, "Name", ref change);
          PropagateProperty(pcCpd, cpd, "DisplayName", ref change);
          PropagateProperty(pcCpd, cpd, "PreferredCounterTypeName", ref change);
          PropagateProperty(pcCpd, cpd, "ServiceDefProperty", "ServiceProperty", ref change);
          if (change)
          {
            mLogger.LogDebug("Updating counter property definition: ID = {0}; Name={1}",
                             pcCpd.ID, pcCpd.Name);
            MetraTech.Interop.MTProductCatalogExec.IMTCounterPropertyDefinitionWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTCounterPropertyDefinitionWriterClass();
            writer.Update((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext) pc.GetSessionContext(),
                          (MetraTech.Interop.MTProductCatalogExec.IMTCounterPropertyDefinition) pcCpd);
          }
          else
          {
            mLogger.LogDebug("No change detected in counter property definition: ID = {0}; Name={1}",
                             pcCpd.ID, pcCpd.Name);
          }

          // Set in memory
          MemoryWrite(pcCpd, cpd);
        }
        else if(inst.Type == InstructionType.CreateCounterPropertyDefinition)
        {
          CounterPropertyDefinition cpd = (CounterPropertyDefinition) inst.Argument1;
          IMTPriceableItemType pcPiType = MemoryRead((PriceableItemType) inst.Argument2);
          mLogger.LogDebug("Creating counter property definition: Name={0} in priceable item type: ID = {1}; Name={2}",
                           cpd.Name, pcPiType.ID, pcPiType.Name);
          IMTCounterPropertyDefinition pcCounterPropertyDefinition = CreateCounterPropertyDefinition(pc, cpd, pcPiType);

          // Set in memory
          MemoryWrite(pcCounterPropertyDefinition, cpd);
        }
        else if(inst.Type == InstructionType.DeleteCounter)
        {
          IMTCounter counter = (IMTCounter) inst.Argument1;
          IMTAggregateCharge charge = MemoryRead((AggregateCharge)inst.Argument2);
          mLogger.LogDebug("Removing counter : ID={0}; Name={1} from priceable item template: ID = {2}; Name={3}",
                           counter.ID, counter.Name, charge.ID, charge.Name);
          MetraTech.Interop.MTProductCatalogExec.IMTCounterMapWriter cmwriter = new MetraTech.Interop.MTProductCatalogExec.MTCounterMapWriterClass();
          cmwriter.RemoveMapping((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), charge.ID, counter.ID);
          MetraTech.Interop.MTProductCatalogExec.IMTCounterWriter cwriter = new MetraTech.Interop.MTProductCatalogExec.MTCounterWriterClass();
          cwriter.Remove((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), counter.ID);       
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateCounter)
        {
          CounterPropertyDefinition cpd = (CounterPropertyDefinition) inst.Argument1;
          PriceableItemType piType = (PriceableItemType) inst.Argument2;
          Counter counter = cpd.ConfiguredCounter;
          IMTCounterPropertyDefinition pcCpd = MemoryRead(cpd);
          IMTAggregateCharge pcAgg = MemoryRead((AggregateCharge)piType.Template);
          IMTCounter pcCounter = pcAgg.GetCounter(pcCpd.ID);
          mLogger.LogDebug("Updating counter : ID={0}; Name={1} in priceable item template: ID = {2}; Name={3}",
                           pcCounter.ID, pcCounter.Name, pcAgg.ID, pcAgg.Name);

          // Set in memory
          MemoryWrite(pcCounter, counter);
        }
        else if(inst.Type == InstructionType.CreateCounter)
        {
          Counter counter = (Counter) inst.Argument1;
          IMTAggregateCharge pcPiTemplate = MemoryRead((AggregateCharge) inst.Argument2);
          IMTCounterPropertyDefinition pcCpd = MemoryRead((CounterPropertyDefinition) inst.Argument3);
          mLogger.LogDebug("Creating counter : Name={0} with counter property definition: ID={1};Name={2} in priceable item template: ID = {3}; Name={4}",
                           counter.Name, pcCpd.ID, pcCpd.Name, pcPiTemplate.ID, pcPiTemplate.Name);
          IMTCounter pcCounter = CreateCounter(pc, counter, pcPiTemplate, pcCpd);
          // Set in memory
          MemoryWrite(pcCounter, counter);
        }
        else if(inst.Type == InstructionType.DeleteParameterTable)
        {
          IMTPriceableItemType pcPiType=(IMTPriceableItemType)inst.Argument2;
          IMTParamTableDefinition pcPt=(IMTParamTableDefinition)inst.Argument1;
          mLogger.LogDebug("Deleting parameter table: ID = {0}; Name={1} from priceable item type: ID={2}; Name={3}",
                           pcPt.ID, pcPt.Name, pcPiType.ID, pcPiType.Name);
          MetraTech.Interop.MTProductCatalogExec.IMTPriceableItemTypeWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTPriceableItemTypeWriterClass();
          writer.RemoveParamTableDefinition((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), 
                                            pcPiType.ID,
                                            pcPt.ID);
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateParameterTable)
        {
          ParameterTable pt = (ParameterTable) inst.Argument1;
          IMTParamTableDefinition pcPt = (IMTParamTableDefinition) inst.Argument2;

          mLogger.LogDebug("Updating parameter table: ID = {0}; Name={1}",
                           pcPt.ID, pcPt.Name);
          // Set in memory
          MemoryWrite(pcPt, pt);
        }
        else if(inst.Type == InstructionType.CreateParameterTable)
        {
          ParameterTable cpd = (ParameterTable) inst.Argument1;
          IMTPriceableItemType pcPiType = MemoryRead((PriceableItemType) inst.Argument2);
          mLogger.LogDebug("Creating parameter table: Name={0} in priceable item type: ID={1}; Name={2}",
                           cpd.Name, pcPiType.ID, pcPiType.Name);
          IMTParamTableDefinition pcParameterTable = CreateParameterTable(pc, cpd, pcPiType);

          // Set in memory
          MemoryWrite(pcParameterTable, cpd);
        }
        else if(inst.Type == InstructionType.DeleteAdjustmentType)
        {
					mLogger.LogDebug( "Deleteing AdjustmentType for: " +((IAdjustmentType)inst.Argument1).Name );
          AdjustmentTypeWriter writer = new AdjustmentTypeWriter();
          writer.Remove((IMTSessionContext)pc.GetSessionContext(), 
                        (IAdjustmentType)inst.Argument1);
          // Should remove from memory
        }
				else if (inst.Type == InstructionType.UpdateAdjustmentType)
				{
					IAdjustmentType adjType = (IAdjustmentType)inst.Argument1;
					IAdjustmentType pcAdjType = (IAdjustmentType)inst.Argument2;

					bool change = false;
					PropagateProperty(pcAdjType, adjType, "Name", ref change);
					PropagateProperty(pcAdjType, adjType, "DisplayName", ref change);
					PropagateProperty(pcAdjType, adjType, "Description", ref change);
					if (!adjType.IsCompositeType)
					{
						PropagateProperty(pcAdjType, adjType, "SupportsBulk", ref change);
						PropagateProperty(pcAdjType, adjType, "AdjustmentTable", ref change);
						PropagateProperty(pcAdjType, adjType, "Kind", ref change);
						PropagateProperty(pcAdjType, adjType, "SupportsBulk", ref change);
						PropagateProperty(pcAdjType, adjType, new String[] { "AdjustmentFormula", "Text" }, new String[] { "AdjustmentFormula", "Text" }, ref change);
						PropagateProperty(pcAdjType, adjType, new String[] { "AdjustmentFormula", "EngineType" }, new String[] { "AdjustmentFormula", "EngineType" }, ref change);
					}
					else
					{
						PropagateProperty(pcAdjType, adjType, "ChildAdjustmentCollection", "ChildAdjustmentCollection", true, ref change);
					}

					// TODO: Walk the properties and see if there are any changes there.
					if (change)
					{
						// Damn, I can't modify the inputs/outputs on an adjustment type.
						// So here, I simply move the ID from the existing object into
						// the new copy.  
						adjType.ID = pcAdjType.ID;
						AdjustmentTypeWriter writer = new AdjustmentTypeWriter();
						writer.Update((IMTSessionContext)pc.GetSessionContext(), adjType);
					}


					// Set in memory
					MemoryWrite(pcAdjType, adjType);
				}
        else if(inst.Type == InstructionType.CreateAdjustmentType)
        {
          IAdjustmentType adjType = (IAdjustmentType) inst.Argument1;
          IMTPriceableItemType pcPiType = MemoryRead((PriceableItemType) inst.Argument2);
          // Simply put the ID of the PIType into the adjustment type and save
          adjType.PriceableItemTypeID = pcPiType.ID;
          AdjustmentTypeWriter writer = new AdjustmentTypeWriter();
          writer.Create((IMTSessionContext)pc.GetSessionContext(), adjType);

          // Set in memory
          MemoryWrite(adjType, adjType);
        }
        else if(inst.Type == InstructionType.DeleteApplicabilityRule)
        {
          ApplicabilityRuleWriter writer = new ApplicabilityRuleWriter();
          writer.RemoveMapping((IMTSessionContext)pc.GetSessionContext(), 
                               (ApplicabilityRule)inst.Argument1,
                               MemoryReadLocalToPC((AdjustmentType)inst.Argument2));
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateApplicabilityRule)
        {
          ApplicabilityRule rule = (ApplicabilityRule) inst.Argument1;
          ApplicabilityRule pcRule = (ApplicabilityRule) inst.Argument2;

          // I don't believe it makes sense to update here.

          // Set in memory
          MemoryWrite(pcRule, rule);
        }
        else if(inst.Type == InstructionType.CreateApplicabilityRule)
        {
          ApplicabilityRule rule = (ApplicabilityRule) inst.Argument1;
          AdjustmentType pcAdjType = MemoryReadLocalToPC((AdjustmentType) inst.Argument2);
          // Create the connection between the applicability rule and the adjustment type.
          ApplicabilityRuleWriter writer = new ApplicabilityRuleWriter();
          writer.CreateMapping((IMTSessionContext)pc.GetSessionContext(), rule, pcAdjType);

          // Set in memory
          MemoryWrite(rule, rule);
        }
        else if(inst.Type == InstructionType.DeleteReasonCode)
        {
          ReasonCodeWriter writer = new ReasonCodeWriter();
          writer.RemoveMapping((IMTSessionContext)pc.GetSessionContext(), 
                               (ReasonCode)inst.Argument1,
                               (Adjustment)inst.Argument2);
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateReasonCode)
        {
          ReasonCode rc = (ReasonCode) inst.Argument1;
          ReasonCode pcRc = (ReasonCode) inst.Argument2;

          // I don't believe it makes sense to update here.

          // Set in memory
          MemoryWrite(pcRc, rc);
        }
        else if(inst.Type == InstructionType.CreateReasonCode)
        {
          ReasonCode rc = (ReasonCode) inst.Argument1;
          Adjustment pcAdjTemplate = MemoryRead((AdjustmentTemplate) inst.Argument2);
          // Create the connection between the applicability rule and the adjustment type.
          ReasonCodeWriter writer = new ReasonCodeWriter();
          writer.CreateMapping((IMTSessionContext)pc.GetSessionContext(), rc, pcAdjTemplate);

          // Set in memory
          MemoryWrite(rc, rc);
        }
        else if(inst.Type == InstructionType.DeleteAdjustmentTemplate)
        {
					mLogger.LogDebug( "Deleting AdjustmentTemplate for: " +(((Adjustment)inst.Argument1).AdjustmentType).Name );
          AdjustmentWriter writer = new AdjustmentWriter();
          writer.Remove((IMTSessionContext)pc.GetSessionContext(), 
                        (Adjustment)inst.Argument1);
          // Should remove from memory
        }
        else if(inst.Type == InstructionType.UpdateAdjustmentTemplate)
        {
          AdjustmentTemplate adjTemplate = (AdjustmentTemplate) inst.Argument1;
          Adjustment pcAdjTemplate = (Adjustment) inst.Argument2;
					mLogger.LogDebug( "Updating AdjustmentTemplate for: " +(pcAdjTemplate.AdjustmentType).Name );
          bool change=false;
          PropagateProperty(pcAdjTemplate, adjTemplate.Template, "Name", ref change);
          PropagateProperty(pcAdjTemplate, adjTemplate.Template, "DisplayName", ref change);
          PropagateProperty(pcAdjTemplate, adjTemplate.Template, "Description", ref change);
          if (change)
          {
            AdjustmentWriter writer = new AdjustmentWriter();
            writer.Update((IMTSessionContext) pc.GetSessionContext(), pcAdjTemplate);
          }

          // Set in memory
          MemoryWrite(pcAdjTemplate, adjTemplate);
        }
        else if(inst.Type == InstructionType.CreateAdjustmentTemplate)
        {
          AdjustmentTemplate adjTemplate = (AdjustmentTemplate) inst.Argument1;
          IMTPriceableItem pcPiTemplate = MemoryRead((UsageCharge) inst.Argument2);
					mLogger.LogDebug( "Creating AdjustmentTemplate for: " +(adjTemplate.Template.AdjustmentType).Name );
          // Simply put the ID of the PIType into the adjustment type and save
          adjTemplate.CopyTo(pcPiTemplate);

          AdjustmentWriter writer = new AdjustmentWriter();
          writer.Create((IMTSessionContext)pc.GetSessionContext(), adjTemplate.Template);

          // Set in memory
          MemoryWrite(adjTemplate.Template, adjTemplate);
        }
        else if(inst.Type == InstructionType.DeleteChecksum)
        {
          IMTPriceableItemType pcPiType = (IMTPriceableItemType) inst.Argument1;
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ProductCatalog", "__DELETE_PARAMTABLE_CHECKSUM__"))
              {
                  stmt.AddParam("%%ID_PARAM%%", pcPiType.ID);
                  stmt.ExecuteNonQuery();
              }
          }
        }
        else if(inst.Type == InstructionType.UpdateChecksum)
        {
          PriceableItemType piType = (PriceableItemType) inst.Argument1;
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ProductCatalog", "__UPDATE_PARAMTABLE_CHECKSUM__"))
              {
                  stmt.AddParam("%%ID_PARAM%%", MemoryRead(piType).ID);
                  stmt.AddParam("%%CHECKSUM%%", piType.FileChecksum);
                  stmt.ExecuteNonQuery();
              }
          }
        }
        else if(inst.Type == InstructionType.CreateChecksum)
        {
          PriceableItemType piType = (PriceableItemType) inst.Argument1;
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ProductCatalog", "__ADD_PARAMTABLE_CHECKSUM__"))
              {
                  stmt.AddParam("%%ID_PARAM%%", MemoryRead(piType).ID);
                  stmt.AddParam("%%CHECKSUM%%", piType.FileChecksum);
                  stmt.ExecuteNonQuery();
              }
          }
        }
      }
    }


    void Delete(IMTProductCatalog pc, CounterPropertyDefinitionDifference diff)
    {
      foreach(IMTCounterPropertyDefinition cpd in diff.Delete)
      {
        MetraTech.Interop.MTProductCatalogExec.IMTCounterPropertyDefinitionWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTCounterPropertyDefinitionWriterClass();
        writer.Remove((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), cpd.ID);
      }
    }

    void Delete(IMTProductCatalog pc, ChargeDifference diff)
    {
      foreach(IMTCharge charge in diff.Delete)
      {
        MetraTech.Interop.MTProductCatalogExec.IMTChargeWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTChargeWriterClass();
        writer.Remove((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), charge.ID);
      }
    }

    void Delete(IMTProductCatalog pc, ChargePropertyDifference diff)
    {
      foreach(IMTChargeProperty cp in diff.Delete)
      {
        MetraTech.Interop.MTProductCatalogExec.IMTChargePropertyWriter writer = new MetraTech.Interop.MTProductCatalogExec.MTChargePropertyWriterClass();
        writer.Remove((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), cp.ID);
      }
    }

    void InternalRemovePriceableItemType(IMTProductCatalog pc,
                                         IMTPriceableItemType pcPiType)
    {
      if(null != pcPiType)
      {
        if(pcPiType.GetProductOfferings().Count > 0)
        {
          throw new ApplicationException("Unable to remove priceable item type " + pcPiType.Name + ", it is part of one or more product offerings");
        }
        
        // Remove all templates.  Note that templates remove their 
        // counters and adjustment templates.
        foreach(IMTPriceableItem pcPiTemplate in pcPiType.GetTemplates())
        {
          pcPiType.RemoveTemplate(pcPiTemplate.ID);
        }
        foreach(IMTPriceableItemType pcChildPiType in pcPiType.GetChildren())
        {
          foreach(IMTPriceableItem pcPiTemplate in pcChildPiType.GetTemplates())
          {
            pcChildPiType.RemoveTemplate(pcPiTemplate.ID);
          }
        }

        // The MTProductCatalog.RemovePriceableItemType performs the following actions:
        // Recursively remove child PITypes
        // Remove parameter table definitions
        // Removes counter property definitions
        // Removes charges
        // Removes adjustment types
        // Removes the priceable item type itself
        pc.RemovePriceableItemType(pcPiType.ID);
        
      }
    }

     IMTParamTableDefinition CreateParameterTable(IMTProductCatalog pc,
                                                                                                  ParameterTable pt,
                                                                                                  IMTPriceableItemType pcPiType)
    {
      // Assume the parameter table exists since doing so is the responsibility of the param table hook.  
      // Get it and set the reference.
      IMTParamTableDefinition pcPT = pc.GetParamTableDefinitionByName(pt.Name);
      if(pcPT == null) throw new ApplicationException("Parameter table with name '" + pt.Name + "' not found in product catalog");
      pcPiType.AddParamTableDefinition(pcPT.ID);
      return pcPT;
    }

    void CreateParameterTables(IMTProductCatalog pc,
                               PriceableItemType piType,
                               IMTPriceableItemType pcPiType)
    {
      foreach(ParameterTable pt in piType.ParameterTables)
      {
        CreateParameterTable(pc, pt, pcPiType);
      }
    }

    IMTCharge CreateCharge(IMTProductCatalog pc,
                                                                           Charge charge,
                                                                           IMTPriceableItemType pcPiType,
                                                                           MetraTech.Interop.MTProductView.IProductView pv)
    {
      IMTCharge pcCharge = pcPiType.CreateCharge();
      pcCharge.Name = charge.Name;
      pcCharge.DisplayName = charge.DisplayName;
      pcCharge.AmountPropertyID = charge.AmountPropertyID;
      pcCharge.Save();
      
      CreateChargeProperties(pc, charge, pcCharge, pv);
      return pcCharge;
    }

    void CreateCharges(IMTProductCatalog pc,
                       PriceableItemType piType,
                       IMTPriceableItemType pcPiType)
    {
      MetraTech.Interop.MTProductView.IProductView pv = (MetraTech.Interop.MTProductView.IProductView) pcPiType.GetProductViewObject();
      foreach(Charge charge in piType.Charges)
      {
        CreateCharge(pc, charge, pcPiType, pv);
      }
    }

    IMTChargeProperty CreateChargeProperty(IMTProductCatalog pc,
                              ChargeProperty cp,
                              IMTCharge pcCharge,
                              MetraTech.Interop.MTProductView.IProductView pv)
    {
      IMTChargeProperty pcChargeProperty = pcCharge.CreateChargeProperty();
      // Match the charge property name with a product view property
      pcChargeProperty.ProductViewPropertyID = cp.ProductViewPropertyID;
      pcChargeProperty.ChargeID = pcCharge.ID;
      pcChargeProperty.Save();
      cp.ID = pcChargeProperty.ID;
      return pcChargeProperty;
    }

    void CreateChargeProperties(IMTProductCatalog pc,
                                Charge charge,
                                IMTCharge pcCharge,
                                MetraTech.Interop.MTProductView.IProductView pv)
    {
      foreach(ChargeProperty cp in charge.ChargeProperties)
      {
        CreateChargeProperty(pc, cp, pcCharge, pv);
      }
    }
    
    IMTCounterPropertyDefinition CreateCounterPropertyDefinition(IMTProductCatalog pc,
                                         CounterPropertyDefinition cpd,
                                         IMTPriceableItemType pcPiType)
    {
      IMTCounterPropertyDefinition pcCpd = pcPiType.CreateCounterPropertyDefinition();
      pcCpd.Name = cpd.Name;
      pcCpd.DisplayName = cpd.DisplayName;
      pcCpd.PreferredCounterTypeName = cpd.PreferredCounterTypeName;
      pcCpd.ServiceDefProperty = cpd.ServiceProperty;
      pcCpd.Save();
      cpd.ID = pcCpd.ID;
      return pcCpd;
    }

    void CreateCounterPropertyDefinitions(IMTProductCatalog pc,
                                          PriceableItemType piType,
                                          IMTPriceableItemType pcPiType)
    {
      foreach(CounterPropertyDefinition cpd in piType.CounterPropertyDefinitions)
      {
        CreateCounterPropertyDefinition(pc, cpd, pcPiType);
      }
    }

    IMTPriceableItemType CreatePriceableItemType(IMTProductCatalog pc,
                                                 PriceableItemType piType)
    {
      // Create the associated PC object and save
      IMTPriceableItemType pcPiType = GetPriceableItemTypeByName(pc, piType.Name);
      if(pcPiType == null)
      {
        pcPiType = pc.CreatePriceableItemType();
        pcPiType.Name = piType.Name;
        pcPiType.Kind = piType.EntityType;
        // DANGER! Is this going to be ok!  The existing
        // adjustment types may not have been created in the
        // correct context.
        pcPiType.AdjustmentTypes = (IMTCollection) piType.AdjustmentTypes;
      }

      pcPiType.Description = piType.Description;
      pcPiType.ServiceDefinition = piType.ServiceDefinition;
      pcPiType.ProductView = piType.ProductView;

      pcPiType.ConstrainSubscriberCycle = piType.ConstrainSubscriberCycle;
      if (piType.Parent != null)
      {
        IMTPriceableItemType pcParentPiType = MemoryRead(piType.Parent);
        if(pcParentPiType == null)
        {
          pcParentPiType = GetPriceableItemTypeByName(pc, piType.Parent.Name);
        }
        pcPiType.ParentID = pcParentPiType.ID;
      }

      // The PIType save method performs the following actions:
      // Saves the pitype itself
      // Saves the adjustment types
      pcPiType.Save();

      // Save the ID for later fun and games.
      piType.ID = pcPiType.ID;

      // Set up parameter tables
      CreateParameterTables(pc, piType, pcPiType);

      // Set up the charges
      CreateCharges(pc, piType, pcPiType);

      // Set up counter property defintions
      CreateCounterPropertyDefinitions(pc, piType, pcPiType);

      // For usage priceable items, create any necessary priceable item
      // templates.
      CreateTemplate(pc, piType, pcPiType);

			//Create adjustments table
			AdjustmentTypeWriter ajw = new AdjustmentTypeWriter();
			ajw.CreateAdjustmentTable(pc.GetSessionContext(), pcPiType.ID);


      return pcPiType;
    }

    void CreateTemplate(IMTProductCatalog pc,
                        PriceableItemType piType,
                        IMTPriceableItemType pcPiType)
    {
      if(pcPiType.Kind != MTPCEntityType.PCENTITY_TYPE_USAGE &&
         pcPiType.Kind != MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE)
        return;

      IMTPriceableItem pcPI = pcPiType.CreateTemplate(false);

      // Initialize the state of the PI from the template created during
      // deserialization.
      if(pcPiType.Kind == MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE)
      {
        IMTAggregateCharge pcAgg = (IMTAggregateCharge) pcPI;
        AggregateCharge agg = (AggregateCharge)piType.Template;

        agg.CopyTo(pcAgg);
      }
      else
      {
        piType.Template.CopyTo(pcPI);
      }

      if(piType.Template.Parent != null)
      {
        pcPI.ParentID = GetPriceableItemTemplate(pc, piType.Template.Parent).ID;
      }

      // Saving the template saves the adjustment templates.
      pcPI.Save();

      // If this is an aggregate charge, then configure a counter for each CPD.
      if(pcPiType.Kind == MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE)
      {
        IMTAggregateCharge pcAgg = (IMTAggregateCharge) pcPI;
        foreach(CounterPropertyDefinition cpd in piType.CounterPropertyDefinitions)
        {
          foreach(IMTCounterPropertyDefinition pcCpd in pcPiType.GetCounterPropertyDefinitions())
          {
            if(pcCpd.Name == cpd.ConfiguredCounter.Name)
            {
              CreateCounter(pc, cpd.ConfiguredCounter, pcAgg, pcCpd);
              break;
            }
          }
        }
      }
    }


    IMTCounter CreateCounter(IMTProductCatalog pc,
                             Counter counter,
                             IMTAggregateCharge pcPiTemplate,
                             IMTCounterPropertyDefinition pcCpd)
    {
      IMTCounterType ct = pc.GetCounterTypeByName(counter.CounterType);
      IMTCounter pcCounter = pc.CreateCounter(ct.ID);

      // Initialize the pc object from the local object
      counter.CopyTo(pcCounter);
      
      // Save 
      MetraTech.Interop.MTProductCatalogExec.IMTCounterWriter cwriter = new MetraTech.Interop.MTProductCatalogExec.MTCounterWriterClass();
      counter.ID = cwriter.Create((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), 
                                  (MetraTech.Interop.MTProductCatalogExec.IMTCounter)pcCounter);        
      MetraTech.Interop.MTProductCatalogExec.IMTCounterMapWriter cmwriter = new MetraTech.Interop.MTProductCatalogExec.MTCounterMapWriterClass();
      cmwriter.AddMapping((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext)pc.GetSessionContext(), pcCounter.ID, pcPiTemplate.ID, pcCpd.ID);

      return pcCounter;

    }

    [AutoComplete]
    public void RemovePriceableItemType(PriceableItemType piType)
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
      IMTPriceableItemType pcPiType = GetPriceableItemTypeByName(pc, piType.Name);
      InternalRemovePriceableItemType(pc, pcPiType);
    }

    [AutoComplete]
    public void CreatePriceableItemType(PriceableItemType piType)
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
      CreatePriceableItemType(pc, piType);
    }

    private void InternalUpdatePriceableItemType(PriceableItemType piType)
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

      IMTPriceableItemType pcPiType = GetPriceableItemTypeByName(pc, piType.Name);

      if (pcPiType == null)
      {
        CreatePriceableItemType(pc, piType);
      }
      else
      {
        PriceableItemTypeDifference diff = new PriceableItemTypeDifference();
        ArrayList program = new ArrayList();
        diff.Calculate(pcPiType, piType, program);
        program.Sort();
        Execute(pc, program);
      }
    }

    [AutoComplete]
    public void UpdatePriceableItemTypes(IEnumerable piTypes)
    {
      InternalUpdatePriceableItemTypes(piTypes);
    }

    private void InternalUpdatePriceableItemTypes(IEnumerable piTypes)
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

      ArrayList program = new ArrayList();
      ProductCatalogDifference diff = new ProductCatalogDifference(program);
      diff.Calculate(pc, piTypes);
	  //As we haven't loaded the composite in the pitype object, We would like to remove the
	  //remove delete composite adjustment instructions.
	  int totalInstructions = program.Count;
	  for(int arrCounter=0; arrCounter<totalInstructions; arrCounter++)
		{
			Instruction inst = (Instruction)program[arrCounter];
		  if((inst.Type==InstructionType.DeleteAdjustmentType && ((IAdjustmentType)inst.Argument1).IsCompositeType) ||
				  ( (inst.Type==InstructionType.DeleteAdjustmentTemplate) &&  (((Adjustment)inst.Argument1).AdjustmentType).IsCompositeType) )
		  {
			  program.RemoveAt(arrCounter);
			  arrCounter--;
			  totalInstructions--;
		  }
		}
      program.Sort();
      Execute(pc, program);
    }

    [AutoComplete]
    public void UpdatePriceableItemType(PriceableItemType piType)
    {
      InternalUpdatePriceableItemType(piType);
    }

    [AutoComplete]
    public void UpdatePriceableItemTypeFromFile(String xmlFile)
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

      XmlSerializer xml = new XmlSerializer(pc);
      PriceableItemType piType = xml.LoadPriceableItemTypeFromXML(xmlFile, true);
      InternalUpdatePriceableItemType(piType);
    }

    private MetraTech.Logger mLog;
    public PriceableItemTypeWriter()
    {
      mLog = new MetraTech.Logger("[PriceableItemTypeHook]");
    }
  }

  [ComVisible(false)]
  public class XmlSerializer
  {
    private Hashtable mPITypes = new Hashtable();
    private Hashtable mPITemplates = new Hashtable();
    private IMTProductCatalog mPC;
    private MetraTech.Adjustments.AdjustmentCatalog mAC;

    public XmlSerializer(IMTProductCatalog pc)
    {
      mPC = pc;
      mAC = new MetraTech.Adjustments.AdjustmentCatalog();
      mAC.Initialize((IMTSessionContext) mPC.GetSessionContext());
    }

    /// <summary>
    /// Manages priceable item types and guarantees that
    /// instances are uniquely identified by their name.
    /// </summary>
    public PriceableItemType CreatePriceableItemType(String name)
    {
      if(!mPITypes.ContainsKey(name))
      {
        PriceableItemType pitype = new PriceableItemType();
        pitype.Name = name;
        mPITypes.Add(name, pitype);
      }
      return (PriceableItemType) mPITypes[name];
    }

    /// <summary>
    /// Manages priceable item types and guarantees that
    /// instances are uniquely identified by their name.
    /// </summary>
    public UsageCharge CreateUsageCharge(String name)
    {
      if(!mPITemplates.ContainsKey(name))
      {
        UsageCharge piTemplate = new UsageCharge(name);
        mPITemplates.Add(name, piTemplate);
      }
      return (UsageCharge) mPITemplates[name];
    }

    /// <summary>
    /// Manages priceable item types and guarantees that
    /// instances are uniquely identified by their name.
    /// </summary>
    public AggregateCharge CreateAggregateCharge(String name)
    {
      if(!mPITemplates.ContainsKey(name))
      {
        AggregateCharge piTemplate = new AggregateCharge(name);
        mPITemplates.Add(name, piTemplate);
      }
      return (AggregateCharge) mPITemplates[name];
    }

		public PriceableItemType LoadPriceableItemTypeFromXML(String file )
		{
			return LoadPriceableItemTypeFromXML(file, false);
		}

	  /// <summary>
	  /// This function reads the PI xml-schema file and creates the PI object
	  /// </summary>
	  /// <param name="file">xml file for the pi</param>
	  /// <returns>PIType object</returns>
    public PriceableItemType LoadPriceableItemTypeFromXML(String file, bool childloaded )
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(file);
			string pitypename = doc.GetNodeValueAsString("/priceable_item/name"); 

			if( childloaded && (doc.SelectNodes("/priceable_item/relationships/child").Count <=0))
				return null;

			PriceableItemType piType = CreatePriceableItemType(pitypename);

      piType.Description = doc.GetNodeValueAsString("/priceable_item/description");

      String strParent = doc.GetNodeValueAsString("/priceable_item/relationships/parent");
      if(strParent.Length > 0)
      {
        piType.Parent = CreatePriceableItemType(strParent);
      }
  
      foreach(XmlNode node in doc.SelectNodes("/priceable_item/relationships/child"))
      {
        if(node.InnerText.Length == 0) throw new ApplicationException("Invalid child node; must have non-empty string value");
        piType.AddChild(CreatePriceableItemType(node.InnerText));
      }

      string strItemType = doc.GetNodeValueAsString("/priceable_item/item_type").ToUpper();
      if(strItemType == "USAGE")
      {
        piType.EntityType = MTPCEntityType.PCENTITY_TYPE_USAGE;
        piType.Template = CreateUsageCharge(piType.Name);
        piType.Template.Type = piType;
        if(piType.Parent != null)
        {
          piType.Template.Parent = CreateUsageCharge(piType.Parent.Name);
        }
      }
      else if (strItemType == "RECURRING")
      {
        piType.EntityType = MTPCEntityType.PCENTITY_TYPE_RECURRING;
      }
      else if (strItemType == "UNIT_DEPENDENT_RECURRING")
      {
        piType.EntityType = MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT;
      }
      else if (strItemType == "NON-RECURRING")
      {
        piType.EntityType = MTPCEntityType.PCENTITY_TYPE_NON_RECURRING;
      }
      else if (strItemType == "DISCOUNT")
      {
        piType.EntityType = MTPCEntityType.PCENTITY_TYPE_DISCOUNT;
      }
      else if (strItemType == "AGGREGATE")
      {
        piType.EntityType = MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE;
        AggregateCharge piTemplate = CreateAggregateCharge(piType.Name);
        piTemplate.Type = piType;
        piTemplate.CycleTypeID = 4;
        piTemplate.EndDayOfWeek = 1;
        piType.Template = piTemplate;
        if(piType.Parent != null)
        {
          piType.Template.Parent = CreateAggregateCharge(piType.Parent.Name);
        }
      }

      foreach(XmlNode node in doc.SelectNodes("/priceable_item/counters/cpd"))
      {
        CounterPropertyDefinition cpd = new CounterPropertyDefinition();
        cpd.Name = MTXmlDocument.GetNodeValueAsString(node, "name");
        cpd.DisplayName = MTXmlDocument.GetNodeValueAsString(node, "display_name");
        cpd.ServiceProperty = MTXmlDocument.GetNodeValueAsString(node, "service_property");
        cpd.PreferredCounterTypeName = MTXmlDocument.GetNodeValueAsString(node, "preferred_counter_type");
        piType.AddCounterPropertyDefinition(cpd);
      }

      foreach(XmlNode node in doc.SelectNodes("/priceable_item/counters/counter"))
      {
        Counter counter = new Counter();
        counter.Name = MTXmlDocument.GetNodeValueAsString(node, "name");
        counter.CounterType = MTXmlDocument.GetNodeValueAsString(node, "type");
        counter.Description = "_blank_";

        foreach(XmlNode paramNode in node.SelectNodes("parameter"))
        {
          counter.AddCounterParameter(MTXmlDocument.GetNodeValueAsString(paramNode, "name"), MTXmlDocument.GetNodeValueAsString(paramNode, "value"));
        }

        // Match the counter with a cpd
        CounterPropertyDefinition match = null;
        foreach(CounterPropertyDefinition cpd in piType.CounterPropertyDefinitions)
        {
          if (cpd.Name == counter.Name)
          {
            match = cpd;
            break;
          }
        }
        if (match == null) throw new ApplicationException("Counter '" + counter.Name + "' does not having matching counter property defintion");
        match.ConfiguredCounter = counter;
      }

      piType.ServiceDefinition = doc.GetNodeValueAsString("/priceable_item/pipeline/service_definition");
      piType.ProductView = doc.GetNodeValueAsString("/priceable_item/pipeline/product_view");
      MetraTech.Interop.MTProductView.IProductViewCatalog pvCatalog = new MetraTech.Interop.MTProductView.ProductViewCatalogClass();
      MetraTech.Interop.MTProductView.IProductView pv = pvCatalog.GetProductViewByName(piType.ProductView);
			if(pv == null) 
				throw new ApplicationException("Product View with name '" + piType.ProductView + "' not found in product catalog. (Has product view deployment hook been run?)");
      
      foreach(XmlNode node in doc.SelectNodes("/priceable_item/charges/charge"))
      {
        Charge charge = new Charge();
        charge.PIType = piType;
        charge.Name = MTXmlDocument.GetNodeValueAsString(node, "name");
        MetraTech.Interop.MTProductView.IProductViewProperty pvProp = pv.GetPropertyByName(charge.Name);
        if (pvProp == null)
          throw new ApplicationException("Product view '" + piType.ProductView + "' does not have property with name '" + charge.Name + "' used in defining charge for priceable item '" + piType.Name + "'");
        charge.AmountPropertyID = pvProp.ID;
        charge.DisplayName = MTXmlDocument.GetNodeValueAsString(node, "display_name");

        foreach(XmlNode pnode in node.SelectNodes("charge_property"))
        {
          String propName = MTXmlDocument.GetNodeValueAsString(pnode, "name");
          pvProp = pv.GetPropertyByName(propName);
          if (pvProp == null)
            throw new ApplicationException("Product view '" + piType.ProductView + "' does not have property with name '" + propName + "' used in defining charge property for charge '" + charge.Name + "' of priceable item '" + piType.Name + "'");
          charge.AddChargeProperty(propName, pvProp.ID);
        }

        piType.AddCharge(charge);
      }

      foreach(XmlNode node in doc.SelectNodes("/priceable_item/adjustment_type"))
      {
        AdjustmentType adjType = new AdjustmentType();
        piType.AdjustmentTypes.Add(adjType);
        adjType.AdjustmentTable = pv.tablename.Replace("t_pv", "t_aj");
        adjType.Name = MTXmlDocument.GetNodeValueAsString(node, "name");
        adjType.Description = MTXmlDocument.GetNodeValueAsString(node, "description");
        adjType.DisplayName = MTXmlDocument.GetNodeValueAsString(node, "displayname");
        adjType.AdjustmentFormula.EngineType = (EngineType)MTXmlDocument.GetNodeValueAsInt(node, "CalculationEngine");
        adjType.SupportsBulk = MTXmlDocument.GetNodeValueAsBool(node, "supportsBulk");
        adjType.AdjustmentFormula.Text = MTXmlDocument.GetNodeValueAsString(node, "formula");
				//CR 13973 initialize PricebleITemTypeID property, so that adjustment type is updated correctly.
				MetraTech.Interop.MTProductCatalog.IMTPriceableItemType pit = mPC.GetPriceableItemTypeByName(pitypename);
				int pitid = -1;
				if (pit != null)
				{
					pitid = mPC.GetPriceableItemTypeByName(pitypename).ID;
				}
				adjType.PriceableItemTypeID = pitid;
				

        foreach(XmlNode rule in node.SelectNodes("applicabilityrules/rule"))
        {
          adjType.AddApplicabilityRule(mAC.GetApplicabilityRuleByName(MTXmlDocument.GetNodeValueAsString(rule)));
        }
        adjType.Kind = (AdjustmentKind)MTXmlDocument.GetNodeValueAsInt(node, "Kind");
        adjType.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext) mPC.GetSessionContext());
        
				// TODO: What about default description????????
        // TODO: Changes to outputs actually need to be synchronized with values in the
        // t_aj tables!!!!  Note that maintainence of t_aj tables is done through a call
        // to AdjustmentTypeWriter.SynchronizeTypes that winds up in a stored procedure.
        foreach(XmlNode prop in node.SelectNodes("required_inputs/input_val"))
        {
          String propname = MTXmlDocument.GetNodeValueAsString(prop, "@name");
          MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData md = adjType.RequiredInputs.CreateMetaData(propname);
          md.Name = propname;
          md.DisplayName = MTXmlDocument.GetNodeValueAsString(prop, "@displayname");
          md.DataType = TypeConverter.ConvertStringToMSIX(MTXmlDocument.GetNodeValueAsString(prop, "@type"));
        }
        foreach(XmlNode prop in node.SelectNodes("outputs/output_val"))
        {
          String propname = MTXmlDocument.GetNodeValueAsString(prop, "@name");
          MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData md = adjType.ExpectedOutputs.CreateMetaData(propname);
          md.Name = propname;
          md.DisplayName = MTXmlDocument.GetNodeValueAsString(prop, "@displayname");
          md.DataType = TypeConverter.ConvertStringToMSIX(MTXmlDocument.GetNodeValueAsString(prop, "@type"));
        }

        // For usage and aggregate charges, add adjustment templates for each adjustment type.
        if(piType.Template != null)
        {
          AdjustmentTemplate adjTemplate = new AdjustmentTemplate();
          adjTemplate.Template.AdjustmentType = adjType;
          adjTemplate.Template.Name = adjType.Name;
          adjTemplate.Template.DisplayName = adjType.DisplayName;
          adjTemplate.Template.Description = adjType.Description;
          adjTemplate.Template.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext) mPC.GetSessionContext());
          // Configure reason codes.
          foreach(XmlNode rc in node.SelectNodes("reasoncodes/reasoncode"))
          {
            adjTemplate.ReasonCodes.Add(mAC.GetReasonCodeByName(MTXmlDocument.GetNodeValueAsString(rc)));
          }
          piType.Template.AdjustmentTemplates.Add(adjTemplate);
        }
      }
		//Adding the Composite Adjustment Type object in the adjustmenttype collection for the
		//pi type
		if( childloaded )
		{
			foreach(XmlNode node in doc.SelectNodes("/priceable_item/composite_adjustment_type"))
			{
				CompAdjustmentType compadjType = new CompAdjustmentType();
				piType.AdjustmentTypes.Add(compadjType);
				compadjType.Name = MTXmlDocument.GetNodeValueAsString(node, "name");
				compadjType.Description = MTXmlDocument.GetNodeValueAsString(node, "description");
				compadjType.DisplayName = MTXmlDocument.GetNodeValueAsString(node, "displayname");
				compadjType.AdjustmentFormula.EngineType = EngineType.MTSQL;
				compadjType.AdjustmentFormula.Text = "Create Procedure CalculateAdjustment\n  --required inputs\n@ChargesPercent DECIMAL,\n  --nonrequired inputs\n  --outputs\n@TotalAdjustmentAmount DECIMAL OUTPUT\nAs\n          set @TotalAdjustmentAmount = 0.0\n    ";
			
				compadjType.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext) mPC.GetSessionContext());
				//CR 13973 initialize PricebleITemTypeID property, so that adjustment type is updated correctly.
				MetraTech.Interop.MTProductCatalog.IMTPriceableItemType pit = mPC.GetPriceableItemTypeByName(pitypename);
				int pitid = -1;
				if (pit != null)
				{
					pitid = mPC.GetPriceableItemTypeByName(pitypename).ID;
				}
				compadjType.PriceableItemTypeID = pitid;

				foreach(XmlNode prop in node.SelectNodes("required_inputs/input_val"))
				{
					String propname = MTXmlDocument.GetNodeValueAsString(prop, "@name");
					MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData md = compadjType.RequiredInputs.CreateMetaData(propname);
					md.Name = propname;
					md.DisplayName = MTXmlDocument.GetNodeValueAsString(prop, "@displayname");
					md.DataType = TypeConverter.ConvertStringToMSIX(MTXmlDocument.GetNodeValueAsString(prop, "@type"));
				}
				foreach(XmlNode prop in node.SelectNodes("outputs/output_val"))
				{
					String propname = MTXmlDocument.GetNodeValueAsString(prop, "@name");
					MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData md = compadjType.ExpectedOutputs.CreateMetaData(propname);
					md.Name = propname;
					md.DisplayName = MTXmlDocument.GetNodeValueAsString(prop, "@displayname");
					md.DataType = TypeConverter.ConvertStringToMSIX(MTXmlDocument.GetNodeValueAsString(prop, "@type"));
				}

				if(piType.Template != null)
				{
					AdjustmentTemplate adjTemplate = new AdjustmentTemplate();
					adjTemplate.Template.AdjustmentType = compadjType;
					adjTemplate.Template.Name = compadjType.Name;
					adjTemplate.Template.DisplayName = compadjType.DisplayName;
					adjTemplate.Template.Description = compadjType.Description;
					adjTemplate.Template.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext) mPC.GetSessionContext());
					// Configure reason codes.
					//foreach(XmlNode rc in node.SelectNodes("reasoncodes/reasoncode"))
					//{
					//	adjTemplate.ReasonCodes.Add(mAC.GetReasonCodeByName(MTXmlDocument.GetNodeValueAsString(rc)));
					//}
					adjTemplate.ReasonCodes.Add(mAC.GetReasonCodeByName("RateCorrection"));
					piType.Template.AdjustmentTemplates.Add(adjTemplate);
				}
				foreach(XmlNode prop in node.SelectNodes("ChildAdjustments/ChildAdjustment"))
				{
					AdjustmentType adj = new AdjustmentType();
					adj.PIName = MTXmlDocument.SelectOnlyNode(prop, "ChildPI").InnerText;
					adj.Name = MTXmlDocument.SelectOnlyNode(prop,"ChildAdjustmentType").InnerText;
					compadjType.ChildAdjustmentCollection.Add( adj );
				}
			}
		}
      foreach(XmlNode node in doc.SelectNodes("/priceable_item/parameter_table"))
      {
        ParameterTable pt = new ParameterTable();
        pt.Name = node.InnerText;
        piType.AddParameterTable(pt);
      }

      // TODO: Handle the "checksum" update logic when the tx_checksum is 0 in the database.

      // Last thing.  Get the checksum of the file and store
      // it as part of the pitype.
      MetraTech.Interop.PropSet.IMTConfig config = new MetraTech.Interop.PropSet.MTConfig();
      bool ck=false;
      piType.FileChecksum = config.ReadConfiguration(file, out ck).Checksum;
     
      return piType;
    }

    ///<remarks>
    /// For the priceable item type, find the pcrate plugin file for 
    /// the parameter table in question.  This is simply NOT well defined.
    ///</remarks>

  }

  [ComVisible(false)]
    public class ParameterTable
  {
    static String PriceableItemDir
    {
      get { return "PriceableItems"; }
    }

    private String mName;
    public String Name
    {
      get { return mName; }
      set { mName = value; }
    }

    public String WeightOnKey;
    public String StartAt;
    public String InSession;
    public bool HasIndexedProperty;
    public String Extension;

    public void LoadFromXML(String extensionPath)
    {
    }

    public ParameterTable()
    {
      Name = "";
      WeightOnKey = "";
      StartAt = "";
      InSession = "";
      HasIndexedProperty = false;
      Extension = "";
    }
  }

  [ComVisible(false)]
  public class CounterParameter
  {
    private String mName;
    public String Name
    {
      get { return mName; }
      set { mName = value; }
    }

    private String mValue;
    public String Value
    {
      get { return mValue; }
      set { mValue = value; }
    }

    public CounterParameter(String name, String value)
    {
      mName = name;
      mValue = value;
    }
  }

  [ComVisible(false)]
  public class Counter
  {
    public CounterPropertyDefinition Property;
    private String mName;
    public String Name
    {
      get { return mName; }
      set { mName = value; }
    }
    private String mDescription;
    public String Description
    {
      get { return mDescription; }
      set { mDescription = value; }
    }
    public int ID;
    // E.g. SumOfOneProperty
    public String CounterType;
    // Parameters 
    public ArrayList CounterParameters = new ArrayList();
    public void AddCounterParameter(String name, String value)
    {
      CounterParameters.Add(new CounterParameter(name, value));
    }

    // Initialize a product catalog object from this one
    public void CopyTo(IMTCounter pcCounter)
    {
      pcCounter.Name = this.Name;
      pcCounter.Description = this.Description;
      foreach(CounterParameter param in CounterParameters)
      {
        pcCounter.GetParameter(param.Name).Value = param.Value;
      }
    }
  }

  [ComVisible(false)]
  public class CounterPropertyDefinition
  {
    private String mName;
    public String Name
    {
      get { return mName; }
      set { mName = value; }
    }
    private String mDisplayName;
    public String DisplayName
    {
      get { return mDisplayName; }
      set { mDisplayName = value; }
    }
    private String mPreferredCounterTypeName;
    public String PreferredCounterTypeName
    {
      get { return mPreferredCounterTypeName; }
      set { mPreferredCounterTypeName = value; }
    }
    private String mServiceProperty;
    public String ServiceProperty
    {
      get { return mServiceProperty; }
      set { mServiceProperty = value; }
    }
    // For aggregate charges only.  This is the
    // counter configuration to create on the template.
    public Counter ConfiguredCounter;
    public int ID;
  }

  [ComVisible(false)]
  public class Charge
  {
    private PriceableItemType mPIType;
    public PriceableItemType PIType
    {
      get { return mPIType; }
      set { mPIType = value; }
    }

    private String mName;
    public String Name
    {
      get { return mName; }
      set { mName = value; }
    }
    private String mDisplayName;
    public String DisplayName
    {
      get { return mDisplayName; }
      set { mDisplayName = value; }
    }
    
    private int mAmountPropertyID;
    public int AmountPropertyID
    {
      get { return mAmountPropertyID; }
      set { mAmountPropertyID = value; }
    }
    
    public int ID;

    private ArrayList mChargeProperties;
    public ArrayList ChargeProperties
    {
      get { return mChargeProperties; }
    }
    public void AddChargeProperty(String name, int productViewPropertyID)
    {
      mChargeProperties.Add(new ChargeProperty(name, productViewPropertyID));
    }
    public ChargeProperty GetChargeProperty(String name)
    {
      foreach(ChargeProperty cp in mChargeProperties)
      {
        if(cp.Name == name) return cp;
      }
      return null;
    }
    
    public Charge()
    {
      Name = "";
      DisplayName = "";
      ID = -1;
      mChargeProperties = new ArrayList();
    }

    public Charge(String name, String displayName, int amountPropertyID)
    {
      Name = name;
      DisplayName = displayName;
      mAmountPropertyID = amountPropertyID;
      ID = -1;
      mChargeProperties = new ArrayList();
    }
  }

  [ComVisible(false)]
  public class ChargeProperty
  {
    private String mName;
    public String Name
    {
      get { return mName; }
      set { mName = value; }
    }

    private int mProductViewPropertyID;
    public int ProductViewPropertyID
    {
      get { return mProductViewPropertyID; }
      set { mProductViewPropertyID = value; }
    }

    private int mID;
    public int ID
    {
      get { return mID; }
      set { mID = value; }
    }

    public ChargeProperty(String name, int productViewPropertyID)
    {
      mName = name;
      mProductViewPropertyID = productViewPropertyID;
    }
  }

  [ComVisible(false)]
  /// <remarks>
  /// The reason that I had to create this guy is that the adjustment
  /// objects will not accept reason codes until they have a priceable
  /// item attached to them.  Unfortunately, we don't create product catalog
  /// objects until we save.  This guy allows us to save reason codes
  /// during deserialization and then later set them into the "formal"
  /// adjustment objects.
  /// </remarks>
  public class AdjustmentTemplate
  {
    public MetraTech.Adjustments.Adjustment Template;
    public ArrayList ReasonCodes;

    public String Name
    {
      get { return Template.Name; }
    }

    public void CopyTo(IMTPriceableItem pcCharge)
    {
      this.Template.PriceableItem = (MetraTech.Interop.MTProductCatalog.IMTPriceableItem) pcCharge;
      foreach(MetraTech.Adjustments.IReasonCode rc in this.ReasonCodes)
      {
        this.Template.AddExistingReasonCode(rc);
      }
    }

    public AdjustmentTemplate()
    {
      ReasonCodes = new ArrayList();
      Template = new MetraTech.Adjustments.Adjustment();
    }
  }

  [ComVisible(false)]
  public class UsageCharge
  {
    private String mName;
    public String Name
    {
      get { return mName; }
      set { mName = value; }
    }

    private int mID;
    public int ID
    {
      get { return mID; }
      set { mID = value; }
    }

    private UsageCharge mParent;
    public UsageCharge Parent
    {
      get { return mParent; }
      set { mParent = value; }
    }

    private PriceableItemType mType;
    public PriceableItemType Type
    {
      get { return mType; }
      set { mType = value; }
    }

    public ArrayList AdjustmentTemplates = new ArrayList();

    public void CopyTo(IMTPriceableItem pcCharge)
    {
      pcCharge.Name = this.Name;

      // Munge adjustments with reason codes and set them in the priceable item
      MetraTech.Interop.GenericCollection.IMTCollection adjustmentTemplates = new MetraTech.Interop.GenericCollection.MTCollectionClass();      
      foreach(AdjustmentTemplate adj in this.AdjustmentTemplates)
      {
        adj.CopyTo(pcCharge);
        adjustmentTemplates.Add(adj.Template);
      }
      pcCharge.SetAdjustments((IMTCollection) adjustmentTemplates);
    }

    public UsageCharge(String name)
    {
      mName = name;
      mParent = null;
      mID = -1;
    }
  }

  [ComVisible(false)]
  public class AggregateCharge : UsageCharge
  {
    public int CycleTypeID;
    public int EndDayOfWeek;
    public void CopyTo(IMTAggregateCharge pcCharge)
    {
      base.CopyTo(pcCharge);
      pcCharge.Cycle.CycleTypeID = this.CycleTypeID;
      pcCharge.Cycle.EndDayOfWeek = this.EndDayOfWeek;
    }
    
    public AggregateCharge(String name)
    :
    base(name)
    {
    }
  }

  [ComVisible(false)]
  public class PriceableItemType 
  {
    private String mName;
    public String Name
    {
      get { return mName; }
      set { mName = value; }
    }

    private String mDescription;
    public String Description
    {
      get { return mDescription; }
      set { mDescription = value; }
    }

    private String mServiceDefinition;
    public String ServiceDefinition
    {
      get { return mServiceDefinition; }
      set { mServiceDefinition = value; }
    }

    private String mProductView;
    public String ProductView
    {
      get { return mProductView; }
      set { mProductView = value; }
    }

    public bool ConstrainSubscriberCycle
    {
      get { return (EntityType == MTPCEntityType.PCENTITY_TYPE_DISCOUNT)
            ? false
            : true;
      }
    }

    private MTPCEntityType mEntityType;
    public MTPCEntityType EntityType
    {
      get { return mEntityType; }
      set { mEntityType = value; }
    }

    public PriceableItemType Parent;
    public ArrayList Children;
    public ArrayList ParameterTables;

    public int ID;
    public ArrayList CounterTypes;
    public ArrayList CounterPropertyDefinitions;
    public ArrayList Charges;
    public MetraTech.Interop.GenericCollection.IMTCollection AdjustmentTypes;

    public UsageCharge Template;

    public String FileChecksum;

    public void AddChild(PriceableItemType child)
    {
      Children.Add(child);
    }

    public void AddCounterPropertyDefinition(CounterPropertyDefinition cpd)
    {
      CounterPropertyDefinitions.Add(cpd);
    }

    public void AddCharge(Charge charge)
    {
      Charges.Add(charge);
    }

    public void AddParameterTable(ParameterTable pt)
    {
      ParameterTables.Add(pt);
    }

    public void LoadFromXML(String file)
    {
    }

    public void Remove()
    {
    }

    public PriceableItemType()
    {
      Parent = null;
      Template = null;
      Children = new ArrayList();
      ParameterTables = new ArrayList();
      CounterTypes = new ArrayList();
      CounterPropertyDefinitions = new ArrayList();
      Charges = new ArrayList();
      AdjustmentTypes = new MetraTech.Interop.GenericCollection.MTCollectionClass();
      FileChecksum = "";
    }
  }

  /// <summary>
  /// Summary description for PriceableItemTypeHook.
  /// </summary>
  [Guid("850fc83c-e828-4b54-957c-543fdcaee077")]
  public class PriceableItemTypeHook : MetraTech.Interop.MTHooklib.IMTHook
  {
    private MetraTech.Logger mLog;
    private IMTRcd mRcd;

    public PriceableItemTypeHook()
    {
      mLog = new Logger("[PriceableItemTypeHook]");
      mRcd = new MTRcdClass();
    }

    public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
    {
      try
      {
        mLog.LogDebug("Starting hook execution.");

        Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
        rowset.Init(@"Queries\ServiceDef");

        IMTProductCatalog pc =
        (IMTProductCatalog)new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
        System.Collections.ArrayList piTypes = new System.Collections.ArrayList();
        IMTRcdFileList files = (IMTRcdFileList)MetraTech.Xml.MTXmlDocument.FindFilesInExtensions("config\\PriceableItems\\*.xml");

        mLog.LogInfo("Found " + files.Count + " priceable item types.");

        mLog.LogInfo("Loading priceable item types from XML.");

        XmlSerializer xml = new XmlSerializer(pc);
        foreach (string file in files)
        {
          PriceableItemType piType = xml.LoadPriceableItemTypeFromXML(file, false);
          if (piType != null)
            piTypes.Add(piType);
        }

        new PriceableItemTypeWriter().UpdatePriceableItemTypes(piTypes);

        piTypes.Clear();

        XmlSerializer xml1 = new XmlSerializer(pc);
        foreach (string file in files)
        {
          PriceableItemType piType = xml1.LoadPriceableItemTypeFromXML(file, true);
          if (piType != null)
          {
            new PriceableItemTypeWriter().UpdatePriceableItemType(piType);
          }
        }

        // Create Adjustment Tables...
        mLog.LogInfo("Creating Adjustment metadata...");

        // TODO: create adjustment types from XML, populate object

        pc = null;
      }
      catch (System.Exception ex)
      {
        mLog.LogException("Exception executing PriceableItemTypeHook", ex);
        throw ex;
      }
    }
  }
}
