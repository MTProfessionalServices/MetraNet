using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
//
using MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.Interop.MTProductCatalog;



namespace  MetraTech.Adjustments
{
	class AdjustmentTypeProxy
	{
		public IAdjustmentType AdjustmentType;
		public int PITypeID;

		public AdjustmentTypeProxy(IAdjustmentType adjustmentType, int piTypeID)
		{
			AdjustmentType = adjustmentType;
			PITypeID = piTypeID;
		}
	}

	/// <summary>
	/// Summary description for AdjustmentTypeReader.
	/// </summary>
	/// 
	[Guid("fa6601fe-d1c2-48f0-91ff-5a662bbf8dfb")]
	public interface IAdjustmentTypeReader
	{
		MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypesForPIType(IMTSessionContext apCTX, int piType);
		MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypesForPI(IMTSessionContext apCTX, int aPIID,bool bParent) ;
		MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypes(IMTSessionContext apCTX);
		IAdjustmentType FindAdjustmentType(IMTSessionContext apCTX, int aID);
		IAdjustmentType FindAdjustmentTypeByName(IMTSessionContext apCTX, string aName);
		ArrayList GetAdjustmentTypeIDsForPI(IMTSessionContext apCTX, 
			MetraTech.Interop.MTProductCatalog.IMTPriceableItem aPI);
		void CheckExistingAdjustmentType(IMTSessionContext apCTX, string aAJTName, int aPITName);
	}

	// readers support transactions but do not require them
	[ClassInterface(ClassInterfaceType.None)]
	[Transaction(TransactionOption.Supported, Isolation=TransactionIsolationLevel.Any)]
	[Guid("3012a00f-f84f-4705-b057-efdbb3e450d1")]
	public class AdjustmentTypeReader : ServicedComponent, IAdjustmentTypeReader
	{
		protected IMTSessionContext mCTX;
		protected bool mRequireParent = false;

		// looks like this is necessary for COM+?
		public AdjustmentTypeReader()
		{ 
		}
		[AutoComplete]
		public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypesForPIType(IMTSessionContext apCTX, int piType) 
		{
			MetraTech.Interop.GenericCollection.IMTCollection ajtypes;
			IApplicabilityRuleReader applicreader = new ApplicabilityRuleReader();
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_ADJUSTMENT_TYPES__"))
                {
                    stmt.AddParam("%%PREDICATE%%", String.Format("AND ajt.id_pi_type={0}", piType));
                    // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments 
                    stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        // step 3: populate the collection
                        ajtypes = GetAdjustmentTypesInternal(apCTX, reader);
                    }
                }

				// set applicability rules
				foreach(IAdjustmentType AdjType in ajtypes)
				{
					AdjType.SetApplicabilityRules(applicreader.GetApplicabilityRulesForAdjustmentType(apCTX, AdjType.ID));
				}
			}
			return ajtypes;
		}
		[AutoComplete]
		public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypesForPI(IMTSessionContext apCTX, int aPIID, bool bParent) 
		{
			MetraTech.Interop.GenericCollection.IMTCollection ajtypes;
			IApplicabilityRuleReader applicreader = new ApplicabilityRuleReader();
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
        
				string queryName;
				if(bParent)
					queryName = "__LOAD_COMPOSITEADJUSTMENT_TYPES_FOR_PI__";
				else
					queryName = "__LOAD_ADJUSTMENT_TYPES_FOR_PI__";

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", queryName))
                {
                    stmt.AddParam("%%COLUMN%%", "id_pi_template");
                    stmt.AddParam("%%ID_PI%%", aPIID);
                    // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments 
                    stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        ajtypes = GetAdjustmentTypesInternal(apCTX, reader);
                    }
                }

				// set applicability rules
				foreach(IAdjustmentType AdjType in ajtypes)
				{
					AdjType.SetApplicabilityRules(applicreader.GetApplicabilityRulesForAdjustmentType(apCTX, AdjType.ID));
				}

			}
      
			return ajtypes;
		}
		[AutoComplete]
		public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypes(IMTSessionContext apCTX) 
		{
			IApplicabilityRuleReader applicreader = new ApplicabilityRuleReader();
			MetraTech.Interop.GenericCollection.IMTCollection ajtypes;

			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_ADJUSTMENT_TYPES__"))
                {
                    stmt.AddParam("%%PREDICATE%%", "");
                    // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
                    stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        // step 3: populate the collection
                        ajtypes = GetAdjustmentTypesInternal(apCTX, reader);
                    }
                }

				// set applicability rules
				foreach(IAdjustmentType AdjType in ajtypes)
				{
					AdjType.SetApplicabilityRules(applicreader.GetApplicabilityRulesForAdjustmentType(apCTX, AdjType.ID));
				}
        
			}
      
			return ajtypes;
      
		}

		
    
		protected MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypesInternal  (IMTSessionContext apCTX, IMTDataReader reader) 
		{
			MetraTech.Interop.GenericCollection.IMTCollection mRetCol = new MetraTech.Interop.GenericCollection.MTCollectionClass();
			int previd = 0;
			int isAdjComposite = 0;
			MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData md;
			IAdjustmentType AdjType = null;
			while(reader.Read())
			{
				int ajtypeid = reader.GetInt32("TypeID");
				if(ajtypeid != previd)
				{
					isAdjComposite = reader.GetInt32("IsAdjustmentComposite");
					string ajtypename = reader.GetString("TypeName");
					string ajtypedesc = reader.GetString("TypeDescription");
					string ajdefaultdesc = string.Empty;
					if(!reader.IsDBNull("AdjustmentDefaultDescription"))
						ajdefaultdesc = reader.GetString("AdjustmentDefaultDescription");
					string ajtypedispname = reader.GetString("TypeDisplayName");
					string ajformula = reader.GetString("TypeFormula");
					string ajguid = reader.IsDBNull("TypeGUID") ? "" : reader.GetString("TypeGUID");
					int piTypeID = reader.GetInt32("TypePIType");
					int FormulaID = reader.GetInt32("TypeFormulaID");
					EngineType engine = (EngineType)reader.GetInt32("TypeFormulaEngine");
					// I am breaking encapsulation of the priceable item and product view objects
					// by hacking their tables directly; however, this seems necessary.  Use of the
					// priceable item type objects here necessitates creating product catalog objects
					// through the Activation classes and this does not properly propagate COM+/transaction
					// context.  We must require client code to create priceable item types from product
					// catalogs that have correctly built contexts.
					
					string pvname = reader.GetString("ProductViewTableName");
					bool supportsbulk = reader.GetBoolean("SupportsBulk");
					string piname = null;
					try
					{
						piname = reader.GetString( "PIName" );
					}
					catch(Exception){}
					
					
					AdjustmentKind typeUOM = (AdjustmentKind)reader.GetInt32("TypeUOM");
					
					AdjType =  (isAdjComposite == 1) ? (IAdjustmentType) new CompAdjustmentType() : (IAdjustmentType)new AdjustmentType();
					AdjType.ID = ajtypeid;
					AdjType.GUID = ajguid;
					AdjType.Name = ajtypename;
					AdjType.Description = ajtypedesc;
					AdjType.DisplayName = ajtypedispname;
					AdjType.SupportsBulk = supportsbulk;
					if(reader.IsDBNull("PARENTID"))
						AdjType.HasParent = false;
					else
						AdjType.HasParent = true;
					AdjType.Kind = typeUOM;
					//CR 14166: formula on composite adjustments types are unused.
					//But update and create methods compile and save it. The path of
					//least resistance is to read it as well so that update method works correctly.
					//The right method would be to never attempt and save formulas for composite adjustment types.
					AdjType.AdjustmentFormula.ID = FormulaID;
					AdjType.AdjustmentFormula.EngineType = engine;
					AdjType.AdjustmentFormula.Text = ajformula;
					if (AdjType is AdjustmentType)
					{
						AdjType.AdjustmentTable = pvname.Replace("t_pv", "t_aj");
					}
					AdjType.PriceableItemTypeID = piTypeID;
					
					
					AdjType.PIName = piname;
					if(ajdefaultdesc.Length > 0)
					{
						IAdjustmentDescription desc = new AdjustmentDescription();
						desc.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)apCTX);
						desc.AdjustmentType = AdjType;
						desc.DefaultDescription = ajdefaultdesc;
						AdjType.DefaultAdjustmentDescription = desc;
					}
					AdjType.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)apCTX);
					mRetCol.Add(AdjType);
					
					previd = ajtypeid;
				}
				string propname = reader.GetString("TypePropName");
				string propdispname = reader.GetString("TypePropDisplayName");
				string propdatatype = reader.GetString("TypePropDataType");
				int propdirection = reader.GetInt32("TypePropDirection");
				if(propdirection == 0 /*IN*/)
				{
					md = AdjType.RequiredInputs.CreateMetaData(propname);
				}
				else
				{
					md = AdjType.ExpectedOutputs.CreateMetaData(propname);
				}
				md.Name = propname;
				md.DisplayName = propdispname;
				md.DataType = TypeConverter.ConvertStringToMSIX(propdatatype);
			}

			// Close up the reader so that we can execute queries against the product 
			// catalog.
			reader.Close();

			//now is time to recursively initialize child adjustments for all composite
			//adjustment types
			foreach(IAdjustmentType aj in mRetCol)
			{
				if(aj is CompAdjustmentType)
				{
					int ajtypeid = aj.ID;
					((CompAdjustmentType)aj).ChildAdjustmentCollection = GetAdjustmentTypesForComposite(apCTX, ajtypeid);
				}
			}


			return mRetCol;
		}

		[AutoComplete]
		public ArrayList GetAdjustmentTypeIDsForPI( IMTSessionContext apCTX, 
			MetraTech.Interop.MTProductCatalog.IMTPriceableItem aPI)
		{
			string picol = aPI.IsTemplate() ? "id_pi_template" : "id_pi_instance";
			ArrayList outcol = new ArrayList();
        
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__GET_ADJUSTMENT_TYPES_BY_PI__"))
                {
                    stmt.AddParam("%%PI_COLUMN%%", picol);
                    stmt.AddParam("%%ID_PI%%", aPI.ID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            outcol.Add(reader.GetInt32("id_adjustment_type"));
                        }
                    }
                }
			}
			return outcol;
		}
		[AutoComplete]
		public IAdjustmentType FindAdjustmentTypeByName(IMTSessionContext apCTX, string aName)
		{
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_ADJUSTMENT_TYPES__"))
                {
                    stmt.AddParam("%%PREDICATE%%", String.Format("AND base1.nm_name = N'{0}'", aName), true);
                    stmt.AddParam("%%ID_LANG_CODE%%", 840);//aCtx.LanguageCode);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        MetraTech.Interop.GenericCollection.IMTCollection coll =
                            GetAdjustmentTypesInternal(apCTX, reader);
                        if (coll.Count == 0)
                            return null;
                        //throw new AdjustmentException(System.String.Format("Adjustment Type <{0}> not found", aName));
                        return (IAdjustmentType)coll[1];
                    }
                }
			}
    
		}
    
		[AutoComplete]
		public IAdjustmentType FindAdjustmentType(IMTSessionContext apCTX, int aID)
		{
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_ADJUSTMENT_TYPES__"))
                {
                    stmt.AddParam("%%PREDICATE%%", String.Format("AND ajt.id_prop = {0}", aID));
                    // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
                    stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        MetraTech.Interop.GenericCollection.IMTCollection coll =
                            GetAdjustmentTypesInternal(apCTX, reader);
                        if (coll.Count == 0)
                            return null;
                        //throw new AdjustmentException(System.String.Format("Adjustment Type with ID <{0}> not found", aID));
                        return (IAdjustmentType)coll[1];
                    }
                }
			}
    
		}

		[AutoComplete]
		public void CheckExistingAdjustmentType(IMTSessionContext apCTX, string aAdjustmentTypeName, int aPITTypeID)
		{
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__CHECK_EXISTING_AJTYPE_BYNAME__"))
                {
                    stmt.AddParam("%%NAME%%", aAdjustmentTypeName);
                    stmt.AddParam("%%ID_PI_TYPE%%", aPITTypeID);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string pitname = reader.GetString("pitname");
                            throw new AdjustmentException
                                (System.String.Format("Adjustment Type With Name <{0}> is already used by <{1}> priceable item type. Use different name!", aAdjustmentTypeName, pitname));
                        }

                    }
                }
			}
		}

		private MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentTypesForComposite(IMTSessionContext apCTX,int iAdjTypeId) 
		{
			MetraTech.Interop.GenericCollection.IMTCollection ajtypes;
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_ADJUSTMENT_TYPES_IN_COMPOSITE__"))
                {
                    // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
                    stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                    stmt.AddParam("%%ID_PARENTID%%", iAdjTypeId);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        ajtypes = GetAdjustmentTypesInternal(apCTX, reader);
                    }
                }
			}
			return ajtypes;
		
		}
     
   
	}

}
