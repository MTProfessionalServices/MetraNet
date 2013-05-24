using System;
using System.EnterpriseServices;
using System.Collections;
using System.Text;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.MTSQL;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DataAccess.MaterializedViews;

namespace  MetraTech.Adjustments
{
	/// <summary>
	/// Summary description for AdjustmentTypeWriter.
	/// </summary>
	/// 
    [Guid("486c6892-50bf-4f5c-9eac-7b89ed5e549d")]
	public interface IAdjustmentTypeWriter
	{
		int Create(IMTSessionContext apCTX, IAdjustmentType pAdjustmentType);
		void Update(IMTSessionContext apCTX, IAdjustmentType pAdjustmentType);
		void Remove(IMTSessionContext apCTX, IAdjustmentType pAdjustmentType);
		void SynchronizeTypes(IMTSessionContext apCTX);
	    
		MetraTech.Interop.Rowset.IMTRowSet CreateAdjustmentRecords
		(
			IMTSessionContext apCTX,
			IAdjustmentTransactionSet sTrxSet,
			IAdjustmentType aType,
			object aProgress
		);
	}

	[ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("614d4f05-0065-4327-983a-a157246273c3")]
  public class AdjustmentTypeWriter : ServicedComponent, IAdjustmentTypeWriter
  {
    protected IMTSessionContext mCTX; 

		private enum TaxProps
		{
			Federal = 0x2,
			State = 0x4,
			County = 0x8,
			Local = 0x16,
			Other = 0x32,
			Total = 0x64
		}
	
		private long mSpecifiedTaxProps = 0;
		private string mStagingDatabase;

		// Datamart manager object.
		private Manager mMaterializedViewMgr = null; // Initialize on first use.

		// looks like this is necessary for COM+?
		public AdjustmentTypeWriter()
		{
			ConnectionInfo ciStageDb = new ConnectionInfo("NetMeterStage");
			mStagingDatabase = ciStageDb.Catalog + ((ciStageDb.DatabaseType == DBType.Oracle) ? "." : "..");
		}
	
		/// <summary>
		/// This function was used to create a new adjustment type in the db.
		/// </summary>
		/// <param name="apCTX"></param>
		/// <param name="pAdjustmentType"></param>
		/// <returns></returns>
		[AutoComplete]
		public int Create(IMTSessionContext apCTX, IAdjustmentType pAdjustmentType)
		{
			//CR 12996: check if the name collides with any other adjustment type
			new AdjustmentTypeReader().CheckExistingAdjustmentType
				(apCTX, pAdjustmentType.Name, pAdjustmentType.PriceableItemTypeID);
			BasePropsWriter basewriter = new BasePropsWriter();
			FormulaWriter formulaWriter = new FormulaWriter();
			IApplicabilityRuleWriter applicWriter = new ApplicabilityRuleWriter();
			int FormulaID = formulaWriter.Create(apCTX, pAdjustmentType.AdjustmentFormula);
      
			int typeID = basewriter.CreateWithDisplayName(
				apCTX,
				(int)MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE,
				pAdjustmentType.Name, pAdjustmentType.Description, pAdjustmentType.DisplayName);

			// set the type ID in the adjustment
			pAdjustmentType.ID = typeID;
    
			//If the passed Adjustment types is a normal one
			if( !pAdjustmentType.IsCompositeType)
			{
				using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
				{
					String guid = new System.String('A', 4);
                    using (IMTCallableStatement stmt = conn.CreateCallableStatement("CreateAdjustmentType"))
                    {
                        stmt.AddParam("p_id_prop", MTParameterType.Integer, typeID);
                        stmt.AddParam("p_tx_guid", MTParameterType.Binary, null);// TODO fix me pAdjustmentType.GUID);
                        stmt.AddParam("p_id_pi_type", MTParameterType.Integer, pAdjustmentType.PriceableItemTypeID);
                        stmt.AddParam("p_n_AdjustmentType", MTParameterType.Integer, pAdjustmentType.Kind);// TODO fix me pAdjustmentType.GUID);
                        stmt.AddParam("p_b_supportBulk", MTParameterType.String, pAdjustmentType.SupportsBulk ? "Y" : "N");
                        IAdjustmentDescription defdesc = pAdjustmentType.DefaultAdjustmentDescription;
                        stmt.AddParam("p_tx_defaultdesc", MTParameterType.WideString,
                            defdesc != null ? defdesc.DefaultDescription : null);
                        stmt.AddParam("p_id_formula", MTParameterType.Integer, FormulaID);
                        //stmt.AddParam("p_n_composite_adjustment", MTParameterType.Integer, 0);
                        stmt.ExecuteNonQuery();
                    }

					CreateInputProperties(basewriter, conn, apCTX, pAdjustmentType);
				}

				//create applicability rule mappings
				foreach(IApplicabilityRule rule in pAdjustmentType.GetApplicabilityRules())
				{
					//part of CR 9482 fix: do not assume that applicability rule is
					//already in the database
					rule.Save();
					applicWriter.CreateMapping(apCTX, rule, pAdjustmentType);
				}
			}
			else //Adjustment types is a composite one
			{
				using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
				{
					String guid = new System.String('A', 4);
                    using (IMTCallableStatement stmt = conn.CreateCallableStatement("CreateCompositeAdjustmentType"))
                    {
                        stmt.AddParam("p_id_prop", MTParameterType.Integer, typeID);
                        stmt.AddParam("p_tx_guid", MTParameterType.Binary, null);
                        stmt.AddParam("p_id_pi_type", MTParameterType.Integer, pAdjustmentType.PriceableItemTypeID);
                        stmt.AddParam("p_n_AdjustmentType", MTParameterType.Integer, 1);
                        stmt.AddParam("p_b_supportBulk", MTParameterType.String, "Y");
                        IAdjustmentDescription defdesc = pAdjustmentType.DefaultAdjustmentDescription;
                        stmt.AddParam("p_tx_defaultdesc", MTParameterType.String,
                            defdesc != null ? defdesc.DefaultDescription : null);
                        stmt.AddParam("p_id_formula", MTParameterType.Integer, FormulaID);
                        stmt.AddParam("p_n_composite_adjustment", MTParameterType.Integer, 1);
                        stmt.ExecuteNonQuery();
                    }
                    
                    CreateInputProperties(basewriter, conn, apCTX, pAdjustmentType);
				}

				using(IMTServicedConnection conn1 = ConnectionManager.CreateConnection())
				{
					foreach(IAdjustmentType adjustmenttype in pAdjustmentType.ChildAdjustmentCollection)
					{
                        using (IMTCallableStatement stmt = conn1.CreateCallableStatement("CreateCompositeAdjDetails"))
                        {
                            stmt.AddParam("p_id_prop", MTParameterType.Integer, typeID);
                            stmt.AddParam("p_id_pi_type", MTParameterType.Integer, pAdjustmentType.PriceableItemTypeID);
                            stmt.AddParam("p_pi_name", MTParameterType.String, adjustmenttype.PIName);
                            stmt.AddParam("p_adjustment_type_name", MTParameterType.String, adjustmenttype.Name);
                            stmt.ExecuteNonQuery();
                        }
					}
				}
			}
    
      
			return typeID;
		}
    
		[AutoComplete]
		void CreateInputProperties( BasePropsWriter aBasewriter, 
			IMTServicedConnection aConn, 
			IMTSessionContext apCTX, 
			IAdjustmentType pAdjustmentType)
		{
			//iterate through all required inputs, create
			//t_base_props entries and t_adjustmet_type_prop entries
            using (IMTAdapterStatement stmt = aConn.CreateAdapterStatement("queries\\Adjustments", "__CREATE_ADJUSTMENTTYPE_PROP__"))
            {
                foreach (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData prop in pAdjustmentType.RequiredInputs)
                {
                    stmt.ClearQuery();
                    stmt.QueryTag = "__CREATE_ADJUSTMENTTYPE_PROP__";

                    int id_prop = aBasewriter.CreateWithDisplayName(
                        apCTX,
                        (int)MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE_PROP,
                        prop.Name, prop.DisplayName, prop.DisplayName);
                    stmt.AddParam("%%ID_PROP%%", id_prop);
                    //HACK: need to fit direction of the parameter somewhere.
                    //Assume that if it's not required, then it's an output property
                    stmt.AddParam("%%DIRECTION%%", ParameterDirection.In);
                    // we should store the MSIX data type not the DBDataType
                    stmt.AddParam("%%NM_DATATYPE%%", prop.DataTypeAsString);
                    stmt.AddParam("%%ID_ADJUSTMENT_TYPE%%", pAdjustmentType.ID);
                    stmt.ExecuteNonQuery();
                }
            
                foreach (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData prop in pAdjustmentType.ExpectedOutputs)
                {
                    //See if there are tax properties specified.
                    //If not, still create them with some default display names
                    string propname = prop.Name;
                    mSpecifiedTaxProps |= (string.Compare(propname, "AJ_TAX_FEDERAL", true) == 0) ? (long)TaxProps.Federal : 0;
                    mSpecifiedTaxProps |= (string.Compare(propname, "AJ_TAX_STATE", true) == 0) ? (long)TaxProps.State : 0;
                    mSpecifiedTaxProps |= (string.Compare(propname, "AJ_TAX_COUNTY", true) == 0) ? (long)TaxProps.County : 0;
                    mSpecifiedTaxProps |= (string.Compare(propname, "AJ_TAX_LOCAL", true) == 0) ? (long)TaxProps.Local : 0;
                    mSpecifiedTaxProps |= (string.Compare(propname, "AJ_TAX_OTHER", true) == 0) ? (long)TaxProps.Other : 0;
                    mSpecifiedTaxProps |= (string.Compare(propname, "TOTALTAXADJUSTMENTAMOUNT", true) == 0) ? (long)TaxProps.Total : 0;

                    //create tax related properties that are missing in the metadata specification
                    stmt.ClearQuery();
                    stmt.QueryTag = "__CREATE_ADJUSTMENTTYPE_PROP__";
                    int id_prop = aBasewriter.CreateWithDisplayName(
                        apCTX,
                        (int)MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE_PROP,
                        prop.Name, prop.DisplayName, prop.DisplayName);
                    stmt.AddParam("%%ID_PROP%%", id_prop);
                    //HACK: need to fit direction of the parameter somewhere.
                    //Assume that if it's not required, then it's an output property
                    stmt.AddParam("%%DIRECTION%%", ParameterDirection.Out);
                    // we should store the MSIX data type not the DBDataType
                    stmt.AddParam("%%NM_DATATYPE%%", prop.DataTypeAsString);
                    stmt.AddParam("%%ID_ADJUSTMENT_TYPE%%", pAdjustmentType.ID);
                    stmt.ExecuteNonQuery();
                }

                CreateMissingTaxProperties(aBasewriter, stmt, apCTX, mSpecifiedTaxProps, pAdjustmentType.ID);

            }

			
		}

		private void CreateMissingTaxProperties(BasePropsWriter aBasewriter, 
			IMTAdapterStatement aStmt,
			IMTSessionContext apCTX,
			long taxprops,
			int aAdjustmentTypeID)
		{
			ArrayList propnames = new ArrayList();
			if(taxprops != (taxprops | (long)TaxProps.Federal))
				propnames.Add(new string[]{"aj_tax_federal", "Adjustment To Federal Tax"});
			if(taxprops != (taxprops | (long)TaxProps.State))
				propnames.Add(new string[]{"aj_tax_state", "Adjustment To State Tax"});
			if(taxprops != (taxprops | (long)TaxProps.County))
				propnames.Add(new string[]{"aj_tax_county", "Adjustment To County Tax"});
			if(taxprops != (taxprops | (long)TaxProps.Local))
				propnames.Add(new string[]{"aj_tax_local", "Adjustment To Local Tax"});
			if(taxprops != (taxprops | (long)TaxProps.Other))
				propnames.Add(new string[]{"aj_tax_other", "Adjustment To Other Tax"});
			//TotalTaxAdjustmentAmount field is not persisted, it's always a SUM of all
			//tax adjustment amounts. We save it in meta data collection for MAM display purposes
			if(taxprops != (taxprops | (long)TaxProps.Total))
				propnames.Add(new string[]{"TotalTaxAdjustmentAmount", "Total Tax Adjustment Amount"});
			
			for(int i = 0; i < propnames.Count; i++)
			{
				aStmt.ClearQuery();
				aStmt.QueryTag = "__CREATE_ADJUSTMENTTYPE_PROP__";
				string name = ((string[])propnames[i])[0];
				string dispname = ((string[])propnames[i])[1];
				int id_prop = aBasewriter.CreateWithDisplayName(
					apCTX,
					(int)MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENTTYPE_PROP,
					name, dispname, dispname);
				aStmt.AddParam("%%ID_PROP%%", id_prop); 
				//HACK: need to fit direction of the parameter somewhere.
				//Assume that if it's not required, then it's an output property
				aStmt.AddParam("%%DIRECTION%%", ParameterDirection.Out); 
				aStmt.AddParam("%%NM_DATATYPE%%", "decimal"); 
				aStmt.AddParam("%%ID_ADJUSTMENT_TYPE%%", aAdjustmentTypeID);
				aStmt.ExecuteNonQuery();

			}
		}

		/// <summary>
		/// This function was used to update an existing adjustment type
		/// </summary>
		/// <param name="apCTX"></param>
		/// <param name="pAdjustmentType"></param>
		[AutoComplete]
		public void Update(IMTSessionContext apCTX, IAdjustmentType pAdjustmentType)
		{
			//CR 12996: check if the name collides with any other adjustment type
			new AdjustmentTypeReader().CheckExistingAdjustmentType
				(apCTX, pAdjustmentType.Name, pAdjustmentType.PriceableItemTypeID);
			
			FormulaWriter formulaWriter = new FormulaWriter();
			formulaWriter.UpdateByAdjustmentTypeID(apCTX, pAdjustmentType.AdjustmentFormula, pAdjustmentType.ID);
			BasePropsWriter basewriter = new BasePropsWriter();
			IApplicabilityRuleWriter applicWriter = new ApplicabilityRuleWriter();
			basewriter.UpdateWithDisplayName(
				apCTX,
				pAdjustmentType.Name, pAdjustmentType.Description, pAdjustmentType.DisplayName,pAdjustmentType.ID);

			if( !pAdjustmentType.IsCompositeType )
			{
				using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
				{
					//delete adjustment properties first
                    using (IMTCallableStatement delstmt = conn.CreateCallableStatement("RemoveAdjustmentTypeProps"))
                    {
                        delstmt.AddParam("p_id_prop", MTParameterType.Integer, pAdjustmentType.ID);
                        delstmt.ExecuteNonQuery();
                    }

                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__UPDATE_ADJUSTMENT_TYPE__"))
                    {
                        stmt.AddParam("%%UOM%%", pAdjustmentType.Kind);
                        stmt.AddParam("%%SUPPORTS_BULK%%", pAdjustmentType.SupportsBulk ? "Y" : "N");
                        IAdjustmentDescription ajdesc = pAdjustmentType.DefaultAdjustmentDescription;
                        stmt.AddParam("%%DEFAULT_DESC%%", ajdesc != null ? ajdesc.DefaultDescription : "");
                        stmt.AddParam("%%ID_PROP%%", pAdjustmentType.ID);
                        stmt.ExecuteNonQuery();
                    }

					CreateInputProperties(basewriter, conn, apCTX, pAdjustmentType);

					//remove applicability mappings
					applicWriter.RemoveMappings(apCTX, pAdjustmentType);
					//create applicability rule mappings
					foreach(IApplicabilityRule rule in pAdjustmentType.GetApplicabilityRules())
					{
						//part of CR 9482 fix: do not assume that applicability rule is
						//already in the database
						rule.Save();
						applicWriter.CreateMapping(apCTX, rule, pAdjustmentType);
					}
				}
			}
			else
			{
				using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
				{
					//delete adjustment properties first
                    using (IMTCallableStatement delstmt = conn.CreateCallableStatement("RemoveAdjustmentTypeProps"))
                    {
                        delstmt.AddParam("p_id_prop", MTParameterType.Integer, pAdjustmentType.ID);
                        delstmt.ExecuteNonQuery();
                    }

					CreateInputProperties(basewriter, conn, apCTX, pAdjustmentType);
				}

				using(IMTServicedConnection conn1 = ConnectionManager.CreateConnection())
				{
                    using (IMTCallableStatement delstmt = conn1.CreateCallableStatement("RemoveCompositeAdjDetails"))
                    {
                        delstmt.AddParam("p_id_prop", MTParameterType.Integer, pAdjustmentType.ID);
                        delstmt.ExecuteNonQuery();
                    }

					foreach(IAdjustmentType adjustmenttype in pAdjustmentType.ChildAdjustmentCollection)
					{
                        using (IMTCallableStatement stmt = conn1.CreateCallableStatement("CreateCompositeAdjDetails"))
                        {
                            stmt.AddParam("p_id_prop", MTParameterType.Integer, pAdjustmentType.ID);
                            stmt.AddParam("p_id_pi_type", MTParameterType.Integer, pAdjustmentType.PriceableItemTypeID);
                            stmt.AddParam("p_pi_name", MTParameterType.String, adjustmenttype.PIName);
                            stmt.AddParam("p_adjustment_type_name", MTParameterType.String, adjustmenttype.Name);
                            stmt.ExecuteNonQuery();
                        }
					}
				}
			}
    
		}

		/// <summary>
		/// This function was used to remove the adjustment type from the DB
		/// </summary>
		/// <param name="apCTX"></param>
		/// <param name="pAdjustmentType"></param>
		[AutoComplete]
		public void Remove(IMTSessionContext apCTX, IAdjustmentType pAdjustmentType)
		{
			BasePropsWriter basewriter = new BasePropsWriter();
			IApplicabilityRuleWriter applicWriter = new ApplicabilityRuleWriter();

			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
				if (!pAdjustmentType.IsCompositeType)
				{ 
					// Remove applicability mappings
					applicWriter.RemoveMappings(apCTX, pAdjustmentType);
				}
		
				// Remove adjustment transaction and all associated properties.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__REMOVE_ADJUSTMENT_TYPE__"))
                {
                    stmt.AddParam("%%ID_PROP%%", pAdjustmentType.ID);
                    stmt.ExecuteNonQuery();
                }

				basewriter.Delete(apCTX, pAdjustmentType.ID);
				if (pAdjustmentType.IsCompositeType )
				{
                    using (IMTCallableStatement delstmt = conn.CreateCallableStatement("RemoveCompositeAdjDetails"))
                    {
                        delstmt.AddParam("p_id_prop", MTParameterType.Integer, pAdjustmentType.ID);
                        delstmt.ExecuteNonQuery();
                    }
				}
			}
		}

		[AutoComplete]
		public void SynchronizeTypes(IMTSessionContext apCTX)
		{
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(
                    "GenerateAdjustmentTables"))
                {
                    stmt.ExecuteNonQuery();
                }
			}
		}

		[AutoComplete]
		public void DropAndCreateAdjustmentTable(IMTSessionContext apCTX, int aPITypeID)
		{
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(
                    "DropAndCreateAdjustmentTable"))
                {
                    stmt.AddParam("p_id_pi_type", MTParameterType.Integer, aPITypeID);
                    stmt.AddOutputParam("p_status", MTParameterType.Integer);
                    stmt.AddOutputParam("p_err_msg", MTParameterType.String, 512);
                    stmt.ExecuteNonQuery();

                    int returncode;
                    returncode = (int)stmt.GetOutputValue("p_status");
                    if (0 != returncode)
                    {
                        string msg = (string)stmt.GetOutputValue("p_err_msg");
                        new Logger("[Adjustments]").LogInfo(msg);
                        throw new AdjustmentException(msg);
                    }
                }
			}
		}

		[AutoComplete]
		public void CreateAdjustmentTable(IMTSessionContext apCTX, int aPITypeID)
		{
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(
                    "CreateAdjustmentTable"))
                {
                    stmt.AddParam("p_id_pi_type", MTParameterType.Integer, aPITypeID);
                    stmt.AddOutputParam("p_status", MTParameterType.Integer);
                    stmt.AddOutputParam("p_err_msg", MTParameterType.String, 512);
                    stmt.ExecuteNonQuery();
                    int returncode;
                    returncode = (int)stmt.GetOutputValue("p_status");
                    if (0 != returncode)
                    {
                        string msg = (string)stmt.GetOutputValue("p_err_msg");
                        new Logger("[Adjustments]").LogInfo(msg);
                        throw new AdjustmentException(msg);
                    }
                }
			}
		}

		[AutoComplete]
		public MetraTech.Interop.Rowset.IMTRowSet CreateAdjustmentRecords
			(
			IMTSessionContext apCTX,
			IAdjustmentTransactionSet sTrxSet,
			IAdjustmentType aType,
			object aProgress
			)
		{
			Logger logger = new Logger("[Adjustments]");
			RS.IMTSQLRowset errs = Utils.CreateWarningsRowset();
			string capname = "Apply Adjustments";
			MTAuditEntityType entity = MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT;
      
			int id = 0;
			int countAdjustable = 0;
      			    
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{			
				string BaseTableName = "t_adjustment_transaction";
				string DeltaTableName = BaseTableName; 

				bool bDeltaTableCreated = false;

				//iterate over the collection of adjustment transactions
				
				IMTCollection coll = (IMTCollection)sTrxSet.GetAdjustmentTransactions();
				if(sTrxSet.ReasonCode == null)
					throw new AdjustmentException("Reason Code has to be specified");

				if (coll.Count != 0)
				{
					foreach(IAdjustmentTransaction trx in coll)
					{
						if(((AdjustmentTransaction)trx).IsAdjustable != false)
							countAdjustable++;
					}
				}
				
                    if (countAdjustable <= 0)
					Utils.InsertWarningRecord(ref errs,0,"No transactions will be saved. Has calculation failed for all the transactions?");

				// Initialize on first use.
				if (mMaterializedViewMgr == null)
				{
					mMaterializedViewMgr = new Manager();
					mMaterializedViewMgr.Initialize();
				}

				// If MVM is enabled do some preprocessing.
				if (mMaterializedViewMgr.IsMetraViewSupportEnabled)
				{
					// Get name for transactional delta table
					DeltaTableName = mMaterializedViewMgr.GenerateDeltaInsertTableName(BaseTableName);

					// Generate relationship map between Base Table and Adjustment transaction delta table. 
					mMaterializedViewMgr.AddInsertBinding(BaseTableName, DeltaTableName);

					// Create a temp table to write delta data into.
					using(IMTAdapterStatement createStmt = conn.CreateAdapterStatement("queries\\Adjustments",
																				 "__CREATE_ADJUSTMENT_TRANSACTION_TEMP_TABLE__"))
                                                                                 {
					createStmt.AddParam("%%TABLE_NAME%%", BaseTableName);
					createStmt.AddParam("%%DELTA_TABLE_NAME%%", DeltaTableName);
					createStmt.ExecuteNonQuery();
                    }
					bDeltaTableCreated = true;
				}

				// Process all adjustment transactions.
				int iTransactionCounter = 0;
				bool firstId = true;
				StringBuilder commaSeparatedSessionIds = new StringBuilder();
				IdGenerator idgen = new IdGenerator("adjustment", coll.Count);

                using (IMTAdapterStatement summarystmt = conn.CreateAdapterStatement("queries\\Adjustments", "__WRITE_ADJUSTMENT_RECORD__"))
                {
                    using (IMTAdapterStatement detailsstmt = conn.CreateAdapterStatement("queries\\Adjustments", "__WRITE_ADJUSTMENT_DETAILS__"))
                    {
                        foreach (IAdjustmentTransaction trx in coll)
                        {
                            iTransactionCounter++;

                            // Skip not adjustable.
                            if (((AdjustmentTransaction)trx).IsAdjustable == false)
                                continue;

                            // Figure out the status of adujustment record.
                            AdjustmentStatus status = AdjustmentStatus.PENDING;
                            decimal ajAmount = trx.TotalAdjustmentAmount > 0 ? trx.TotalAdjustmentAmount : -trx.TotalAdjustmentAmount;

                            MetraTech.Interop.MTAuthExec.IMTCompositeCapabilityTypeReader capReader =
                                new MetraTech.Interop.MTAuthExec.MTCompositeCapabilityTypeReaderClass();

                            MetraTech.Interop.MTAuth.IMTCompositeCapability requiredCap =
                                ((MetraTech.Interop.MTAuth.IMTCompositeCapabilityType)capReader.GetByName(capname)).CreateInstance();

                            // MTDecimalCapability atomic = (MTDecimalCapability)requiredCap.GetAtomicDecimalCapability();
                            MetraTech.Interop.MTAuth.IMTAtomicCapability atomic = (MetraTech.Interop.MTAuth.IMTAtomicCapability)requiredCap.GetAtomicDecimalCapability();
                            if (atomic == null)
                                throw new AdjustmentException("ApplyAdjustmentsCapability is missing atomic decimal capability!");
                            MetraTech.Interop.MTAuth.IMTAtomicCapability atomic1 = (MetraTech.Interop.MTAuth.IMTAtomicCapability)requiredCap.GetAtomicEnumCapability();
                            if (atomic1 == null)
                                throw new AdjustmentException("ApplyAdjustmentsCapability is missing atomic enum capability!");

                            // TODO: hmmm... why do I have to do that? Getting atomic directly as IMTDecimalCapability
                            // would result in runtime crash
                            MetraTech.Interop.MTAuth.IMTDecimalCapability decatomic =
                                (MetraTech.Interop.MTAuth.IMTDecimalCapability)atomic;
                            decatomic.SetParameter(ajAmount, MetraTech.Interop.MTAuth.MTOperatorType.OPERATOR_TYPE_EQUAL);

                            MetraTech.Interop.MTAuth.IMTEnumTypeCapability enumatomic =
                                (MetraTech.Interop.MTAuth.IMTEnumTypeCapability)atomic1;
                            string sCurrency = (string)trx.UsageRecord["am_currency"];
                            enumatomic.SetParameter(sCurrency);

                            MTAuditEvent auditevent = trx.IsPrebill ?
                                MTAuditEvent.AUDITEVENT_PREBILL_ADJUSTMENT_CREATE :
                                MTAuditEvent.AUDITEVENT_POSTBILL_ADJUSTMENT_CREATE;
                            //1. see if a caller can perform "Apply Adjustments" operation for
                            // the specified amount.
                            if (!((MetraTech.Interop.MTAuth.IMTSecurityContext)apCTX.SecurityContext).HasAccess(requiredCap))
                            {
                                status = AdjustmentStatus.PENDING;
                                Utils.InsertWarningRecord(ref errs, trx.SessionID, "Adjustment Amount Exceeded Authorized, adjustment created as pending");
                                auditevent = trx.IsPrebill ?
                                    MTAuditEvent.AUDITEVENT_PREBILL_ADJUSTMENT_CREATE_PENDING :
                                    MTAuditEvent.AUDITEVENT_POSTBILL_ADJUSTMENT_CREATE_PENDING;
                            }
                            else
                                status = AdjustmentStatus.APPROVED;

                            // set status to REBILL if the transacion is Pre Bill
                            // and type is rebill
                            //also set SessionID to NULL, because transaction is going to be backed out
                            object oSessionID = trx.SessionID;
                            if (trx.IsPrebill && aType.Kind == AdjustmentKind.REBILL)
                            {
                                status = AdjustmentStatus.PREBILL_REBILL;
                                oSessionID = null;
                            }

                            id = idgen.NextId;

                            summarystmt.ClearQuery();
                            summarystmt.AddParam("%%TABLE_NAME%%", DeltaTableName);
                            summarystmt.AddParam("%%ID_ADJUSTMENT%%", (int)id);
                            summarystmt.AddParam("%%ID_SESS%%", oSessionID);
                            summarystmt.AddParam("%%ID_PARENT_SESS%%", trx.UsageRecord["id_parent_sess"]);
                            summarystmt.AddParam("%%ID_REASON_CODE%%", sTrxSet.ReasonCode.ID);
                            summarystmt.AddParam("%%ID_ACC_CREATOR%%", apCTX.AccountID);
                            summarystmt.AddParam("%%ID_ACC_PAYER%%", trx.UsageRecord["id_acc"]);

                            summarystmt.AddParam("%%STATUS%%", TypeConverter.ConvertAdjustmentStatus(status));
                            summarystmt.AddParam("%%ADJUSTMENT_TYPE%%", trx.IsPrebill ? 0 : 1);
                            summarystmt.AddParam("%%ID_AJ_TEMPLATE%%", sTrxSet.AdjustmentTemplateID);
                            int ajinstance = sTrxSet.AdjustmentInstanceID;
                            if (ajinstance > 0)
                                summarystmt.AddParam("%%ID_AJ_INSTANCE%%", ajinstance);
                            else
                                summarystmt.AddParam("%%ID_AJ_INSTANCE%%", null);
                            summarystmt.AddParam("%%ID_AJ_TYPE%%",
                                ((AdjustmentTransactionSet)sTrxSet).AdjustmentType.ID);
                            int idacc = TypeConverter.ConvertInteger(trx.UsageRecord["id_acc"]);
                            summarystmt.AddParam("%%ID_USAGE_INTERVAL%%", trx.IsPrebill ? trx.UsageRecord["id_usage_interval"] : Utils.GetOpenInterval(idacc));
                            summarystmt.AddParam("%%AMOUNT%%", -trx.TotalAdjustmentAmount);
                            summarystmt.AddParam("%%AJ_TAX_FEDERAL%%", -trx.FederalTaxAdjustmentAmount);
                            summarystmt.AddParam("%%AJ_TAX_STATE%%", -trx.StateTaxAdjustmentAmount);
                            summarystmt.AddParam("%%AJ_TAX_COUNTY%%", -trx.CountyTaxAdjustmentAmount);
                            summarystmt.AddParam("%%AJ_TAX_LOCAL%%", -trx.LocalTaxAdjustmentAmount);
                            summarystmt.AddParam("%%AJ_TAX_OTHER%%", -trx.OtherTaxAdjustmentAmount);
                            summarystmt.AddParam("%%CURRENCY%%", trx.UsageRecord["am_currency"]);
                            string defaultdesc = string.Empty;
                            string desc = string.Empty;
                            if (sTrxSet.ApplyDefaultDescription)
                            {
                                IAdjustmentDescription ajdesc = ((AdjustmentTransactionSet)sTrxSet).AdjustmentType.DefaultAdjustmentDescription;
                                if (ajdesc != null)
                                    defaultdesc = ((AdjustmentTransactionSet)sTrxSet).AdjustmentType.DefaultAdjustmentDescription.Expand(trx);
                            }

                            desc = sTrxSet.Description;

                            summarystmt.AddParam("%%DEFAULTDESC%%", defaultdesc.Length > 0 ? defaultdesc : null);
                            summarystmt.AddParam("%%DESC%%", desc);
                            summarystmt.AddParam("%%DIVISION_CURRENCY%%", (string.IsNullOrEmpty(trx.DivisionCurrency) ? "NULL" : string.Format("N'{0}'", trx.DivisionCurrency)), true);
                            summarystmt.AddParam("%%DIVISION_AMOUNT%%", -trx.DivisionAmount);
                            summarystmt.ExecuteNonQuery();

                            detailsstmt.ClearQuery();
                            detailsstmt.AddParam("%%DETAIL_TABLE%%", aType.AdjustmentTable);
                            detailsstmt.AddParam("%%COLUMNS%%", GenerateColumnsPredicate(trx));
                            detailsstmt.AddParam("%%VALUELIST%%",
                                System.String.Format("{0} {1}", id, GenerateValuesPredicate(trx)));
                            detailsstmt.ExecuteNonQuery();

                            if (aType.Kind == AdjustmentKind.REBILL)
                            {
                                auditevent = trx.IsPrebill ?
                                    MTAuditEvent.AUDITEVENT_PREBILL_REASSIGN_CREATE :
                                    MTAuditEvent.AUDITEVENT_POSTBILL_REASSIGN_CREATE;
                            }


                            AdjustmentCache.GetInstance().GetAuditor().FireEvent
                                ((int)auditevent,
                                apCTX != null ? apCTX.AccountID : -1,
                                (int)entity,
                                TypeConverter.ConvertInteger(trx.UsageRecord["id_acc"]),
                                aType.DisplayName);

                            // Setting the Progress.
                            if (aProgress != null && aProgress != System.DBNull.Value)
                                ((IMTProgress)aProgress).SetProgress(iTransactionCounter, coll.Count);

                            // CR 14236 - Build a comma separated list of session id's. 
                            // Required for __GET_DUPLICATE_ADJUSTMENTS__ query used later.
                            if (firstId)
                            {
                                commaSeparatedSessionIds.Append(trx.SessionID);
                                firstId = false;
                            }
                            else
                            {
                                commaSeparatedSessionIds.Append(",");
                                commaSeparatedSessionIds.Append(trx.SessionID);
                            }
                        } // foreach
                    }
                }

				// Start Fix for CR 14236.
				// Check to see if we've inserted more than one pre-bill or post-bill adjustment
				// for a given session id.
				if (commaSeparatedSessionIds.Length > 0)
				{
                    bool abort = false;
                            
                    using (IMTAdapterStatement stmt =
                    conn.CreateAdapterStatement(@"Queries\Adjustments", "__GET_DUPLICATE_ADJUSTMENTS__"))
                    {
                        stmt.AddParam("%%TABLE_NAME%%", BaseTableName, true);
                        stmt.AddParam("%%ID_SESS_LIST%%", commaSeparatedSessionIds.ToString(), true);

                        StringBuilder displayMsg = new StringBuilder();

                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                long sessionId = reader.GetInt64("id_sess");
                                int adjustmentType = reader.GetInt32("n_adjustmenttype");
                                if (adjustmentType == 0)
                                {
                                    displayMsg.Append("Cannot create more than one prebill adjustment for [" + sessionId + "]\n");
                                }
                                else
                                {
                                    displayMsg.Append("Cannot create more than one postbill adjustment for [" + sessionId + "]\n");
                                }

                                abort = true;
                            }
                        }

                        // Abort this transaction if necessary
                        if (abort)
                        {
                            new Logger("[Adjustments]").LogInfo(displayMsg.ToString());
                            throw new AdjustmentException(displayMsg.ToString());
                        }
                    }
				}
				// End Fix for CR 14236.

				// Process materialized views.
				if (bDeltaTableCreated)
				{
					// Copy data from adjustment transaction temp table to base table.
                    using (IMTAdapterStatement stmt2 = conn.CreateAdapterStatement("queries\\Adjustments",
                                                                                            "__INSERT_INTO_ADJUSTMENT_TRANSACTION_TABLE__"))
                    {
                        stmt2.AddParam("%%TABLE_NAME%%", BaseTableName);
                        stmt2.AddParam("%%DELTA_TABLE_NAME%%", DeltaTableName);
                        stmt2.ExecuteNonQuery();
                    }
					// Prepare trigger list.
					string[] Triggers = new string[1];
					Triggers[0] = BaseTableName;

					// Get queries to execute.
					string QueriesToExecute = mMaterializedViewMgr.GetMaterializedViewInsertQuery(Triggers);
					if (QueriesToExecute != null)
					{
						// Execute the queries.
                        using (IMTStatement stmtNQ = conn.CreateStatement(QueriesToExecute))
                        {
                            stmtNQ.ExecuteNonQuery();
                        }
					}

					// Truncate the transaction delta table.
                    using (IMTAdapterStatement stmt2 = conn.CreateAdapterStatement("queries\\Adjustments", "__TRUNCATE_ADJUSTMENT_DELTA_TABLE__"))
                    {
                        stmt2.AddParam("%%DELTA_TABLE_NAME%%", DeltaTableName);
                        stmt2.ExecuteNonQuery();
                    }
				} // If mvm enabled
			} // using

			return errs;
		}

		private string GenerateColumnsPredicate(IAdjustmentTransaction trx)
		{
			string cols = "";
			foreach(IMTProperty prop in trx.Outputs)
			{
				//TotalAdjustmentAmount is a special case
				//and doesn't live on the details table
				if(prop.Name.ToUpper().CompareTo("TOTALADJUSTMENTAMOUNT") == 0)
					continue;
				//Tax related fields are also a special case
				//they doen't live on the details table (at least for now)
        
				if(	prop.Name.ToUpper().CompareTo("TOTALTAXADJUSTMENTAMOUNT") == 0 || 
					prop.Name.ToUpper().StartsWith("AJ_TAX"))
					continue;
        
				cols += System.String.Format(", c_{0}", prop.Name);
			}

			return cols;
		}

		private string GenerateValuesPredicate(IAdjustmentTransaction trx)
		{
			string vals = "";
			string outstr = "";
      
			foreach(IMTProperty prop in trx.Outputs)
			{
				//TotalAdjustmentAmount is a special case
				//and doesn't live on the details table
				if(prop.Name.ToUpper().CompareTo("TOTALADJUSTMENTAMOUNT") == 0)
					continue;
				//Tax related fields are also a special case
				//they doen't live on the details table (at least for now)
        
				if(	prop.Name.ToUpper().CompareTo("TOTALTAXADJUSTMENTAMOUNT") == 0 || 
					prop.Name.ToUpper().StartsWith("AJ_TAX"))
					continue;
        
				vals += ", ";
				//only decimal properties
				decimal decval = -TypeConverter.ConvertDecimal(prop.Value);
				vals += decval;
			}
			outstr = System.String.Format("{0}", vals);
			return outstr;

		}
   }
}
