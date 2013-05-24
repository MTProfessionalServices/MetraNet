using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
//
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.Pipeline;
using MetraTech.Interop.MTProductCatalog;
using Coll =  MetraTech.Interop.GenericCollection;
using PC = MetraTech.Interop.MTProductCatalog;


using MetraTech.Interop.NameID;
using System.Diagnostics;

using MetraTech.Interop.MeterRowset;



namespace  MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for AdjustmentTransactionReader.
  /// </summary>
  /// 
  [Guid("7ec76bb0-7e99-423d-9e2c-e5dca19785c9")]
  public interface IAdjustmentTransactionReader
  {
    PC.IMTCollection GetAdjustmentTransactions
      (IAdjustmentTransactionSet aSet,
      PC.IMTCollection sessions,
      bool aKids
      );

    PC.IMTCollection GetOrphanAdjustments
      (
      IMTSessionContext apCTX,
      IAdjustmentTransactionSet aSet,
      PC.IMTCollection aAdjustmentTrxIDs
      );
    IRebillTransaction CreateRebillTransaction
      (IMTSessionContext apCTX, 
      long SessionID);
		RS.IMTSQLRowset GetAdjustedTransactionsAsRowset
      (
      IMTSessionContext apCTX,
      RS.IMTDataFilter filter
      );
    RS.IMTSQLRowset GetOrphanAdjustmentsAsRowset
      (
      IMTSessionContext apCTX,
      RS.IMTDataFilter filter
      );
    RS.IMTSQLRowset GetAdjustmentDetailsAsRowset
      ( IMTSessionContext apCTX,
      int aTrxID
      );
    RS.IMTSQLRowset GetAdjustmentRecordsByPI
      (
      IMTSessionContext apCTX,
      IAdjustment aAJTemplateOrInstance
      );
		IRebillTransactionSet CreateRebillTransactions
			(IMTSessionContext apCTX, 
			 MetraTech.Interop.GenericCollection.IMTCollection aTrxIDs);
    
  }

  // readers support transactions but do not require them
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Supported, Isolation=TransactionIsolationLevel.Any)]
  [Guid("91448b19-64be-4295-8add-4802298cf56d")]
  public class AdjustmentTransactionReader : ServicedComponent,IAdjustmentTransactionReader// this makes it a COM+ object.  Woohoo!
  {
    protected IMTSessionContext mCTX;
		protected bool mIsOracle;

    // looks like this is necessary for COM+?
    public AdjustmentTransactionReader()
    { 
			ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
			mIsOracle = (connInfo.DatabaseType == DBType.Oracle) ? true : false;
    }

    [AutoComplete]
    public PC.IMTCollection GetAdjustmentTransactions
      (IAdjustmentTransactionSet aSet,
      PC.IMTCollection sessions, bool aKids
      )
    {
      MetraTech.Interop.MTProductCatalog.IMTCollection retcol = null;

      //if adjustment type is not null then the operation is apply adjustments
      //otherwise, some one is selecting adjusted transactions across adjustment
      //types for management
      string querytag = (((AdjustmentTransactionSet)aSet).AdjustmentType == null) ? 
        "__GET_TRANSACTIONS_FOR_ADJUSTMENT_MANAGEMENT__" : 
        "__GET_TRANSACTIONS_FOR_ADJUSMENT__";

      
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
        bool bAtLeastOne = false;
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", querytag))
        {
            string predicate = Utils.CreateSessionListWherePredicate(sessions, aKids);
            string pvtable = string.Empty;
            int ajtype = -1;
            stmt.AddParam("%%PREDICATE%%", predicate);
            if (((AdjustmentTransactionSet)aSet).AdjustmentType != null)
            {
                ajtype = ((AdjustmentTransactionSet)aSet).AdjustmentType.ID;
                pvtable = Utils.PVTableFromAJTable(((AdjustmentTransactionSet)aSet).AdjustmentType.AdjustmentTable);
                stmt.AddParam("%%PVTABLE%%", pvtable);
                stmt.AddParam("%%ID_AJ_TYPE%%", ajtype);
            }
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                // step 3: populate the collection
                if (((AdjustmentTransactionSet)aSet).AdjustmentType == null)
                {
                    retcol = GetAdjustmentTransactionsForManagementInternal
                      (aSet.GetSessionContext(), (AdjustmentTransactionSet)aSet, reader, out bAtLeastOne);
                    //sanity check: could only happen through incorrect back end scripts
                    //if(!bAtLeastOne)
                    //	throw new AdjustmentException(String.Format(@"No transactions were found. +
                    //	Predicate: {0}", predicate));
                }
                else
                {
                    retcol = GetAdjustmentTransactionsInternal
                      (aSet.GetSessionContext(), (AdjustmentTransactionSet)aSet, reader, out bAtLeastOne);
                    //sanity check: could only happen through incorrect back end scripts
                    // if(((AdjustmentTransactionSet)aSet).AdjustmentType.IsCompositeType == false)
                    // {
                    //	  if(!bAtLeastOne)
                    //		  throw new AdjustmentException(String.Format(@"No usage transactions were found. +
                    //    Predicate: {0}, PV Table: {1}, Adjustment Type: {2}", predicate, pvtable, ajtype));
                    // }
                }
            }
        }

        return retcol;
      }
    }

    [AutoComplete]
    public PC.IMTCollection GetOrphanAdjustments
      (
      IMTSessionContext apCTX,
      IAdjustmentTransactionSet aSet,
      PC.IMTCollection aAdjustmentTransactionIDs
      )
    {
      MetraTech.Interop.GenericCollection.IMTCollection retcol = 
        new MetraTech.Interop.GenericCollection.MTCollectionClass();

      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__GET_ORPHAN_TRANSACTIONS__"))
          {
              string predicate = Utils.CreateAdjustmentIDListWherePredicate(aAdjustmentTransactionIDs);
              stmt.AddParam("%%PREDICATE%%", predicate);
              stmt.AddParam("%%FILTER%%", "", true);
              stmt.AddParam("%%ID_LANG%%", apCTX.LanguageID, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  return GetOrphanAdjustmentsInternal
                    (aSet.GetSessionContext(), (AdjustmentTransactionSet)aSet, reader);
              }
          }
      }
    }
		

		private MetraTech.Interop.GenericCollection.IMTCollection CreateRebillTransactionsInternal
			(IMTSessionContext apCTX, MetraTech.Interop.GenericCollection.IMTCollection aTrxIds)
		{
			MetraTech.Interop.GenericCollection.IMTCollection retcol = 
				new MetraTech.Interop.GenericCollection.MTCollectionClass();
			bool single = aTrxIds.Count == 1;
			string predicate = string.Empty;
			if(single)
			{
				predicate = string.Format("= {0}", aTrxIds[1]);
			}
			else
			{
				string sesslist = "";
				bool first = true;
				foreach(object id in aTrxIds)
				{
					if(!first)
					{
						sesslist += ",";
					}
					sesslist += System.String.Format("{0}", id);
					first = false;
				}
				predicate = System.String.Format("in ({0})", sesslist);
			}

			MeterRowset meterrs = new MeterRowsetClass();
			IAdjustmentReader ajreader = new AdjustmentReader();
			RS.IMTSQLRowset rs = new RS.MTSQLRowsetClass();
			IMTNameID nameid = new MTNameIDClass();
			int PITypeID = 0;
			int PITemplateID = 0;
			int SvcID;
			int iOriginalPayer = -1;
			bool brebill = false;
			bool brebillaj = false;
			bool postbillaj = false;
			bool bCanRebill = false;
			string sServiceDef;
			string uid = "";
			Hashtable record = null;
      
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
				//get pi template and type based on session id

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    ("queries\\Adjustments", "__GET_TRANSACTION_INFO_ADJUSTMENTS__"))
                {
                    stmt.AddParam("%%PREDICATE%%", predicate);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            IRebillTransaction trx = new RebillTransaction(apCTX);
                            //throw new AdjustmentException(String.Format("Usage not found for transaction {0}", SessionID));
                            record = new Hashtable();

                            for (int ordinal = 0; ordinal < reader.FieldCount; ordinal++)
                            {
                                string col = reader.GetName(ordinal);
                                object val = reader.GetValue(ordinal);
                                if (!record.Contains(col))
                                    record.Add(col, val);
                            }

                            if (reader.IsDBNull("id_pi_template"))
                                throw new AdjustmentException
                                    (String.Format("Unable to find id_pi_template for for session with id {0} (non ProdCat usage?)", reader.GetInt64("id_sess")));
                            PITemplateID = reader.GetInt32("id_pi_template");
                            PITypeID = reader.GetInt32("PITypeID");
                            SvcID = reader.GetInt32("id_svc");
                            brebill = (reader.GetString("IsPrebill")[0] == 'Y') ? true : false;
                            brebillaj = reader.GetString("IsPrebillAdjusted")[0] == 'Y' ? true : false;
                            postbillaj = reader.GetString("IsPostbillAdjusted")[0] == 'Y' ? true : false;
                            uid = reader.GetConvertedString("tx_uid");
                            sServiceDef = reader.GetString("nm_servicedef");
                            iOriginalPayer = reader.GetInt32("id_acc");
                            bool bSoftClosed = reader.GetBoolean("IsIntervalSoftClosed");
                            bCanRebill = reader.GetBoolean("CanRebill");
                            long SessionID = reader.GetInt64("id_sess");
                            if (bSoftClosed)
                                throw new SoftClosedIntervalException(reader.GetInt32("id_usage_interval"), SessionID);
                            ServiceDefinition serviceDef = CreateServiceDef(sServiceDef);
                            IMTProperties accids = null;
                            Hashtable typemappings = null;
                            CreateAccountIdentifiers(serviceDef, out accids, out typemappings);
                            ((RebillTransaction)trx).OriginalPayerID = iOriginalPayer;
                            ((RebillTransaction)trx).SetAccountIdentifiers(accids);
                            ((RebillTransaction)trx).SetTypeMappings(typemappings);
                            ((RebillTransaction)trx).SetSD(serviceDef);
                            ((RebillTransaction)trx).SetPIType(PITypeID);
                            ((RebillTransaction)trx).AdjustmentType = GetRebillAdjustmentType(apCTX, PITypeID);
                            ((RebillTransaction)trx).SetCanRebill(bCanRebill);


                            trx.SessionUID = uid;
                            trx.SessionID = SessionID;

                            ((RebillTransaction)trx).SetPIType(PITypeID);
                            ((RebillTransaction)trx).SetPITemplate(PITemplateID);
                            ((RebillTransaction)trx).SetPrebillFlag(brebill);
                            ((RebillTransaction)trx).SetIsPrebillAdjustedFlag(brebillaj);
                            ((RebillTransaction)trx).SetIsPostbillAdjustedFlag(postbillaj);
                            ((RebillTransaction)trx).AdjustmentTemplate = ajreader.FindAdjustmentTemplate(apCTX, PITemplateID, trx.AdjustmentType.ID);
                            ((RebillTransaction)trx).SetUsageRecord(record);

                            retcol.Add(trx);
                        }
                    }
                }
			}
			return retcol;
		}

    [AutoComplete]
    public IRebillTransaction CreateRebillTransaction(IMTSessionContext apCTX, long SessionID)
    {
			MetraTech.Interop.GenericCollection.IMTCollection col = 
				new MetraTech.Interop.GenericCollection.MTCollectionClass();
			col.Add(SessionID);
			MetraTech.Interop.GenericCollection.IMTCollection retcol = CreateRebillTransactionsInternal(apCTX, col);
			if (retcol.Count  == 0)
				throw new AdjustmentException(string.Format("Usage record for session id {0} not found", SessionID));
      return (IRebillTransaction)retcol[1];
    }
		[AutoComplete]
		public IRebillTransactionSet CreateRebillTransactions(IMTSessionContext apCTX, 
			MetraTech.Interop.GenericCollection.IMTCollection aTrxIds)
		{
			int requestcount = aTrxIds.Count;
			MetraTech.Interop.GenericCollection.IMTCollection retcol = CreateRebillTransactionsInternal(apCTX, aTrxIds);
			Debug.Assert(requestcount == retcol.Count, "Number if usage records is not the same as number of input session ids");
			return new RebillTransactionSet(retcol);
		}
    [AutoComplete]
    public MeterRowset CreateMeterRowset(IRebillTransaction trx, IMTPriceableItemType aPIType)
    {
      //all account identifiers have to be set at this point
      IMTProperties ids = trx.AccountIdentifiers;

      MeterRowset meterrs = new MeterRowsetClass();
      //TODO: Is it safe?
      meterrs.InitSDK("AccountPipeline");
      RS.IMTSQLRowset rs = new RS.MTSQLRowsetClass();
      IMTNameID nameid = new MTNameIDClass();
      bool kidsadjusted = false;
      bool noAdjustedKids = true;
			Hashtable ProductViews = new Hashtable();
      
      rs.Init("Queries\\Adjustments");
      rs.SetQueryTag("__GET_REBILL_REMETER_ROWSET__");

      string sPVTableName = aPIType.GetProductViewObject().TableName;

      //support Prebill rebill for aggregate priceable items.
      //Is it safe to just append "_temp" to table name
      if(aPIType.Kind == MTPCEntityType.PCENTITY_TYPE_AGGREGATE_CHARGE && trx.IsPrebill)
      {
        sPVTableName += "_temp";
        //CR 12050: prevent prebill aggregate reassignment until it is fully baked
        throw new RebillUserException
          (String.Format("Session {0} can not be reassigned, because it is a prebill aggregate charge", trx.SessionID));
      }

      rs.AddParam("%%PREDICATE%%", CreateWherePredicate(trx.SessionID), true);
      rs.AddParam("%%PV_COLUMNS%%",
        GeneratePVSelectPropList(CreateServiceDef(aPIType.ServiceDefinition),
        trx.AccountIdentifiers), true);
      rs.AddParam("%%PVTABLE%%", sPVTableName, true);
      rs.ExecuteDisconnected();

      if(rs.RecordCount == 0)
      {
        throw new AdjustmentException(string.Format("Session {0} not found in {1} product view.", trx.SessionID, sPVTableName));
      }

      
      bool adjusted = ((string)rs.get_Value("CanAdjust"))[0] == 'Y' ? false : true;
      if(trx.IsPrebill && adjusted)
        throw new RebillUserException
          (String.Format("Session {0} can not be rebilled, because it has been adjusted. Remove adjustments first", trx.SessionID));

      meterrs.InitializeFromRowset
        ((MetraTech.Interop.MeterRowset.IMTSQLRowset)rs,
        trx.ServiceDefinition.Name);

      //now get rowset for children and add them to the meter rowset

      foreach(IMTPriceableItemType child in aPIType.GetChildren())
      {

				//CR 13027 - handle pi types that share same product view
				//BP: Review carefully: what if we have multiple
				//service defs at a child pi type level that share the same product view?
				//Maybe we should insert service def ids into the hash table as opposed to product views.
				//In any case, this approach works for XPedite
				if(ProductViews.ContainsKey(child.ProductView) == false)
					ProductViews[child.ProductView] = child;
				else
					//we already created remeter rowset for that product view
					continue;
        string servicedef = child.ServiceDefinition;
        int svcid = nameid.GetNameID(servicedef);
        RS.IMTSQLRowset childrs = new RS.MTSQLRowsetClass();
        childrs.Init("Queries\\Adjustments");
        childrs.SetQueryTag("__GET_REBILL_REMETER_ROWSET__"); 
        childrs.AddParam("%%PREDICATE%%",
          String.Format("WHERE ajv.id_parent_sess = {0} and ajv.id_svc = {1}", trx.SessionID, svcid), true);
        childrs.AddParam("%%PVTABLE%%", child.GetProductViewObject().TableName, true);
        childrs.AddParam("%%PV_COLUMNS%%",
          GeneratePVSelectPropList(CreateServiceDef(servicedef),
          trx.AccountIdentifiers), true);
        childrs.ExecuteDisconnected();
        
        //scan children for adjustment records
        if(noAdjustedKids && trx.IsPrebill)
        {
          while(System.Convert.ToBoolean(childrs.EOF) == false)
          {
            kidsadjusted = ((string)childrs.get_Value("CanAdjust"))[0] == 'Y' ? false : true;
            if (kidsadjusted)
            {
              noAdjustedKids = false;
              //found at least one adjusted kid
              //break;
              if(trx.IsPrebill && kidsadjusted)
                throw new RebillUserException
                  (String.Format("Session {0} can not be rebilled, because at least one child transaction has been adjusted. Remove adjustments first", trx.SessionID));

            }
            childrs.MoveNext();
          }
        }
        if(childrs.RecordCount > 0)
          childrs.MoveFirst();
        meterrs.AddChildRowset((MetraTech.Interop.MeterRowset.IMTSQLRowset)childrs, servicedef);
      }
      return meterrs;
     
    }

    [AutoComplete]
    public RS.IMTSQLRowset GetAdjustedTransactionsAsRowset
      ( IMTSessionContext apCTX,
      RS.IMTDataFilter filter
      )
    {
      RS.IMTSQLRowset rs = new RS.MTSQLRowsetClass();
      rs.Init("Queries\\Adjustments");
      rs.SetQueryTag("__GET_ADJUSTED_TRANSACTIONS__"); 
      string filterString = " ";
      if(filter != null && filter.FilterString.Length > 0)
        filterString = String.Format("AND {0}", filter.FilterString);
      rs.AddParam("%%FILTER%%", filterString, true);
      rs.AddParam("%%ID_LANG%%", apCTX.LanguageID, true);
      rs.Execute();
      return rs;
    }

     [AutoComplete]
    public RS.IMTSQLRowset GetAdjustmentRecordsByPI
      ( IMTSessionContext apCTX,
      IAdjustment aAJTemplateOrInstance
      )
    {
      RS.IMTSQLRowset rs = new RS.MTSQLRowsetClass();
      string ajcolumn = aAJTemplateOrInstance.IsTemplate ? "id_aj_template" : "id_aj_instance";
      rs.Init("Queries\\Adjustments");
      rs.SetQueryTag("__GET_ADJUSTMENT_RECORDS_BY_PI__"); 
      rs.AddParam("%%AJ_COLUMN%%", ajcolumn, true);
       rs.AddParam("%%AJ_ID%%", aAJTemplateOrInstance.ID, true);
      rs.Execute();
      return rs;
    }

    [AutoComplete]
    public RS.IMTSQLRowset GetOrphanAdjustmentsAsRowset
      ( IMTSessionContext apCTX,
      RS.IMTDataFilter filter
      )
    {
      RS.IMTSQLRowset rs = new RS.MTSQLRowsetClass();
      rs.Init("Queries\\Adjustments");
      rs.SetQueryTag("__GET_ORPHAN_TRANSACTIONS__"); 
      string filterString = " ";
      if(filter != null && filter.FilterString.Length > 0)
        filterString = String.Format("AND {0}", filter.FilterString);
      rs.AddParam("%%FILTER%%", filterString, true);
      rs.AddParam("%%ID_LANG%%", apCTX.LanguageID, true);
      rs.AddParam("%%PREDICATE%%", "\nWHERE 1=1", true);
      rs.Execute();
      return rs;
    }

    [AutoComplete]
    public RS.IMTSQLRowset GetAdjustmentDetailsAsRowset
      ( IMTSessionContext apCTX,
      int aTrxID
      )
    {
      //IMTQueryAdapterPtr
      //__GET_AJ_DETAIL_ROW__
      IAdjustmentType ajtype = null;
      bool first = true;
      string query = "";
      string detailrow = "";
      RS.IMTSQLRowset rs = new RS.MTSQLRowsetClass();
      IAdjustmentTypeReader typereader = new AdjustmentTypeReader();
      int typeid = Utils.GetAdjustmentTransactionInfo(aTrxID).AJTypeID;
      ajtype = typereader.FindAdjustmentType(apCTX, typeid);
      if(ajtype == null)
        throw new AdjustmentException(string.Format("Adjustment Type with id {0} not found", typeid));
      MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet 
        outputs = ajtype.ExpectedOutputs;
      rs.Init("Queries\\Adjustments");
      foreach (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData md
                 in outputs)
      {
        rs.Clear();
        rs.SetQueryTag("__GET_AJ_DETAIL_ROW__"); 
        string propname = md.Name;
        //skip total adjustment amount and adjustment to taxes
				if(propname.ToUpper().StartsWith("AJ_") == false ||
					propname.ToUpper().StartsWith("AJ_TAX"))
          continue;
        rs.AddParam("%%PROPNAME%%", propname, true);
        rs.AddParam("%%AJTABLE%%", ajtype.AdjustmentTable, true);
        rs.AddParam("%%ID_LANG%%", apCTX.LanguageID, true);
        rs.AddParam("%%ID_AJ_TRX%%", aTrxID, true);
        
        
        if (first == false)
          query += "\nUNION ALL\n";
        
        first = false;
        detailrow = rs.GetQueryString();
        query += detailrow;
      }
      
      rs.Clear();
      rs.SetQueryString(query);
      rs.Execute();
      return rs;
    }




    protected PC.IMTCollection GetAdjustmentTransactionsInternal
      (
      MetraTech.Interop.MTProductCatalog.IMTSessionContext apCTX, 
      AdjustmentTransactionSet aSet, 
      IMTDataReader reader,
      out bool abAtLeastOne
      ) 
    {
      
      PC.IMTCollection mRetCol = (PC.IMTCollection)new MetraTech.Interop.GenericCollection.MTCollectionClass();
      IAdjustmentTransaction aj = null;
      System.Collections.Hashtable record = null;
      long prevID = -1;
      int prevPITemplateID = 0;
      bool bAtLeastOne = false;
      while(reader.Read())
      {
        bAtLeastOne = true;
       
        //only product catalog usage can be adjusted
        if(reader.IsDBNull("id_pi_template"))
          throw new AdjustmentException("Only Product Catalog usage can be adjusted");


        int pitemplateid = reader.GetInt32("id_pi_template");
        
        //verify that transactions selected to be bulk adjusted all belong to the
        //same pi template
        if(prevPITemplateID == 0)
          prevPITemplateID = pitemplateid;
        else if(prevPITemplateID != pitemplateid)
          throw new AdjustmentException
            (String.Format("Only usage against the same PI Template can be simultaneously adjusted ( {0} != {1})",prevPITemplateID,  pitemplateid));
        //Adjustment template will never be NULL, because pi template doesn't support ANY adjustment
        //types until adjustment templates are created. The only way we could hit null condition is somehow
        //through incorrect back end scripts.
        if(reader.IsDBNull("AdjustmentTemplateID"))
          throw new AdjustmentException(String.Format
            ("PI Template <{0}> has no adjustment template for adjustment type <{1}>", pitemplateid, aSet.AdjustmentType.ID));

        int ajtemplateid = reader.GetInt32("AdjustmentTemplateID");
        aSet.AdjustmentTemplateID = ajtemplateid;
        aSet.AdjustmentInstanceID = reader.IsDBNull("AdjustmentInstanceID") ? -1 : reader.GetInt32("AdjustmentInstanceID");

				long sessid;
				if (mIsOracle)
					sessid = Convert.ToInt64(reader.GetDecimal("id_sess"));
				else
					sessid = reader.GetInt64("id_sess");

        bool pre = reader.GetString("IsPrebillAdjusted")[0] == 'Y' ? true : false;
        bool post = reader.GetString("IsPostbillAdjusted")[0] == 'Y' ? true : false;

        //There could be 1 or 2 records coming back for the outer join
        // At the most - 1 record for Prebill adjusted transaction and 1 for postbill
        //bill adjusted.
        //If it's the second row, then dont' insert a new object, just complement ***adjusted flags on
        //the previous one
        if(prevID == sessid)
        {
          Debug.Assert(aj != null);
          if(pre && !aj.IsPrebillAdjusted)
            aj.IsPrebillAdjusted = pre;
          if(post && !aj.IsPostbillAdjusted)
            aj.IsPostbillAdjusted = post;
        }
        else
        {
          aj = new AdjustmentTransaction((IMTSessionContext)apCTX);
          record = new Hashtable();

          for(int ordinal = 0; ordinal < reader.FieldCount; ordinal++)
          {
            string col = reader.GetName(ordinal);
            object val = reader.GetValue(ordinal);
            if(!record.Contains(col))
              record.Add(col, val);
          }
          aj.SessionID = sessid;
          aj.IsPrebill = (reader.GetString("IsPrebill")[0] == 'Y') ? true : false;
          aj.Status = TypeConverter.ConvertAdjustmentStatus(reader.GetString("AdjustmentStatus"));
          aj.PrebillAdjustmentAmount  = reader.GetDecimal("AtomicPrebillAdjAmt");
          aj.PostbillAdjustmentAmount  = reader.GetDecimal("AtomicPostbillAdjAmt");
          aj.OriginalTransactionAmount = reader.GetDecimal("amount");
          aj.IsPrebillAdjusted = reader.GetString("IsPrebillAdjusted")[0] == 'Y' ? true : false;
          aj.IsPostbillAdjusted = reader.GetString("IsPostbillAdjusted")[0] == 'Y' ? true : false;
          aj.IsIntervalSoftClosed = reader.GetString("IsIntervalSoftClosed")[0] == 'Y' ? true : false;
					((AdjustmentTransaction)aj).IsParentSession = reader.GetString("IsParentSession")[0] == 'Y' ? true : false;
					((AdjustmentTransaction)aj).IsParentSessionPostbillRebilled = reader.GetString("IsParentSessPostbillRebilled")[0] == 'Y' ? true : false;
          ((AdjustmentTransaction)aj).SetUsageRecord(record);
          //aj.AdjustmentType = reader.IsDBNull("id_aj_type") ? null :
          //  mAJC.GetAdjustmentType(reader.GetInt32("id_aj_type"));
          mRetCol.Add(aj);
          prevID = sessid;
        }
        
      }

      //sanity check. should never happen, only through incorrect back end scripts
      abAtLeastOne = bAtLeastOne;
      return mRetCol;
    }
    protected PC.IMTCollection GetAdjustmentTransactionsForManagementInternal
      (
      MetraTech.Interop.MTProductCatalog.IMTSessionContext apCTX, 
      AdjustmentTransactionSet aSet, 
      IMTDataReader reader, 
      out bool abAtLeastOne
      ) 
    {
      PC.IMTCollection mRetCol = (PC.IMTCollection)new MetraTech.Interop.GenericCollection.MTCollectionClass();
      IAdjustmentTransaction aj = null;
      System.Collections.Hashtable record = null;
      long prevID = -1;
      bool bAtLeastOne = false;
      while(reader.Read())
      {
        bAtLeastOne = true;
       
        //only product catalog usage can be adjusted
        if(reader.IsDBNull("id_pi_template"))
          throw new AdjustmentException("Only Product Catalog usage can be adjusted");


        int pitemplateid = reader.GetInt32("id_pi_template");
        
        int ajtemplateid = reader.GetInt32("id_aj_template");
        aSet.AdjustmentTemplateID = ajtemplateid;
        aSet.AdjustmentInstanceID = reader.IsDBNull("id_aj_instance") ? -1 : reader.GetInt32("id_aj_instance");

        long sessid = reader.GetInt64("id_sess");
        bool pre = reader.GetString("IsPrebillAdjusted")[0] == 'Y' ? true : false;
        bool post = reader.GetString("IsPostbillAdjusted")[0] == 'Y' ? true : false;

        aj = new AdjustmentTransaction((IMTSessionContext)apCTX);
        record = new Hashtable();

        for(int ordinal = 0; ordinal < reader.FieldCount; ordinal++)
        {
          string col = reader.GetName(ordinal);
          object val = reader.GetValue(ordinal);
          if(!record.Contains(col))
            record.Add(col, val);
        }
        aj.SessionID = sessid;
        ((AdjustmentTransaction)aj).PayerAccountID = reader.GetInt32("id_acc_payer");
        ((AdjustmentTransaction)aj).Currency = reader.GetString("am_currency");
        aj.IntervalID = reader.IsDBNull("AdjustmentUsageInterval") ? -1 : reader.GetInt32("AdjustmentUsageInterval");
        aj.IsPrebill = (reader.GetString("IsPrebill")[0] == 'Y') ? true : false;
        aj.Status = TypeConverter.ConvertAdjustmentStatus(reader.GetString("AdjustmentStatus"));
        aj.PrebillAdjustmentAmount = reader.GetDecimal("AtomicPrebillAdjAmt");
        aj.PostbillAdjustmentAmount = reader.GetDecimal("AtomicPostbillAdjAmt");
        aj.OriginalTransactionAmount = reader.GetDecimal("amount");
        aj.IsPrebillAdjusted = reader.GetString("IsPrebillAdjusted")[0] == 'Y' ? true : false;
        aj.IsPostbillAdjusted = reader.GetString("IsPostbillAdjusted")[0] == 'Y' ? true : false;
        aj.IsIntervalSoftClosed = reader.GetString("IsIntervalSoftClosed")[0] == 'Y' ? true : false;

        if (reader.GetInt32("PostbilladjustmentID") > 0)
        {
            if (!reader.IsDBNull("PostbillAdjustmentDescription"))
                aj.Description = reader.GetString("PostbillAdjustmentDescription");
        }
        else if (!reader.IsDBNull("PostbillAdjustmentDescription"))
            aj.Description = reader.GetString("PostbillAdjustmentDescription");
         
        ((AdjustmentTransaction)aj).SetUsageRecord(record);
        mRetCol.Add(aj);
        prevID = sessid;
      }
      
      //sanity check. should never happen, only through incorrect backe end scripts
      abAtLeastOne = bAtLeastOne;
      return mRetCol;
    }
   
   

    protected PC.IMTCollection GetOrphanAdjustmentsInternal
      (
      MetraTech.Interop.MTProductCatalog.IMTSessionContext apCTX, 
      AdjustmentTransactionSet aSet, 
      IMTDataReader reader
      ) 
    {
      PC.IMTCollection mRetCol = (PC.IMTCollection)new MetraTech.Interop.GenericCollection.MTCollectionClass();
      IAdjustmentTransaction aj = null;
      while(reader.Read())
      {
        int ajtemplateid = reader.GetInt32("id_aj_template");
        aSet.AdjustmentTemplateID = ajtemplateid;
        aSet.AdjustmentInstanceID = reader.IsDBNull("id_aj_instance") ? -1 : reader.GetInt32("id_aj_instance");
        aj = new AdjustmentTransaction((IMTSessionContext)apCTX);
        
        aj.SessionID = -1;
        ((AdjustmentTransaction)aj).PayerAccountID = reader.GetInt32("id_acc_payer");
        ((AdjustmentTransaction)aj).Currency = reader.GetString("am_currency");
        aj.IntervalID = reader.IsDBNull("id_usage_interval") ? -1 : reader.GetInt32("id_usage_interval");
        aj.Status = TypeConverter.ConvertAdjustmentStatus(reader.GetString("c_Status"));
        aj.PrebillAdjustmentAmount = reader.GetDecimal("AdjustmentAmount");

        //There is no way for an adjustment transaction to be in orphan state
        //and be PostBill
        aj.PostbillAdjustmentAmount = 0.0M;

        //we don't know original transaction amount
        aj.OriginalTransactionAmount = 0.0M;
        aj.IsPrebillAdjusted = true;
        aj.IsPostbillAdjusted = false;
        aj.IsIntervalSoftClosed = false;
        //there is no usage record in this case
        ((AdjustmentTransaction)aj).SetUsageRecord(new Hashtable());
        mRetCol.Add(aj);
      }
   
      return mRetCol;
    }
   
    protected string CreateWherePredicate
      (long SessionID)
    {
      string outstr = "";
      outstr = System.String.Format("WHERE ajv.id_sess = ({0})", SessionID);
      return outstr;
    }


    private string GeneratePVSelectPropList(ServiceDefinition service, 
      MetraTech.Interop.MTProductCatalog.IMTProperties accids)
    {
      string proplist = "";
      bool first = true;
      
      //create ',' separated select list where account identifier properties
      //are replaced by the string literals in ids collection
      foreach (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData prop in service)
      {
        string propname = prop.Name;
        bool bAccId = false;
        //bool bSEId = false;
        bool bSkipped = false;
        
        string comma = string.Empty;
        
        if(!first)
        {
          comma = ", ";
        }

        //OK! this property is an account or service endpoint identifier
        //preprend it with the string literal
        if(accids.Exist(propname))
        {
          MetraTech.Interop.MTProductCatalog.IMTProperty accid = null;
          if(accids.Exist(propname))
          {
            accid = ((MetraTech.Interop.MTProductCatalog.IMTProperty)accids[propname]);
            Debug.Assert(accid != null);
            bAccId = true;
          }
 
          if(bAccId)
          {
            if(!IsEmpty(accid))
            {
              //for every ' in the accid.Value, prepend it by '' (The "'QuoteMan'" bug)
              string name;
              name = accid.Value.ToString();
              if (-1 != name.IndexOf(@"'"))
              {
                // there could be more than one quote, each needs to be escaped.
                name = name.Replace(@"'", @"''");
                proplist += System.String.Format(@"{0} '{1}' AS c_{2}", comma, name, propname);
              }
              else
                proplist += System.String.Format("{0} '{1}' AS c_{2}", comma, accid.Value, propname);

            }
            else if (accid.Required == true)
              throw new AdjustmentException(String.Format("Identifer {0} is Required in MSIX but it's value was not set", accid.Name));
            else
              bSkipped = true;
          }
   
        }
        else
        {
          if(bSkipped)
          {
            comma = string.Empty;
          }
          if(!accids.Exist(propname))
            proplist += System.String.Format("{0} pvtable.c_{1}", comma, propname);
        }
        first = false;
      }
          
      return proplist;
    }

    private  ServiceDefinition CreateServiceDef(string service)
    {
      ServiceDefinitionCollection collection = new ServiceDefinitionCollection();
      IServiceDefinition serviceDef = collection.GetServiceDefinition(service);
      return (ServiceDefinition)serviceDef;
    }


    private  void CreateAccountIdentifiers(
      ServiceDefinition service,
      out MetraTech.Interop.MTProductCatalog.IMTProperties accmtprops,
      out Hashtable typemappings
      )
    {
      accmtprops = new MTPropertiesClass();
      typemappings = new Hashtable();
      
      IEnumerable accountIdentifiers = service.AccountIdentifiers;
      foreach (AccountIdentifier accountID in accountIdentifiers)
      {
        MetraTech.Interop.MTProductCatalog.MTPropertyMetaData prop = 
          (MetraTech.Interop.MTProductCatalog.MTPropertyMetaData)accountID.MSIXProperty;
        if(accountID.IsAccountIdentifier())
          accmtprops.Add(prop);
        typemappings.Add(accountID.IdentifierType, accountID.MSIXProperty);
      }
    }


    private IAdjustmentType GetRebillAdjustmentType
      ( IMTSessionContext apCTX, 
      int aPITypeID)
    {
      IAdjustmentTypeReader reader = new AdjustmentTypeReader();
      Coll.IMTCollection ajtypes = reader.GetAdjustmentTypesForPIType(apCTX, aPITypeID);
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

    private bool IsEmpty(MetraTech.Interop.MTProductCatalog.IMTProperty prop)
    {
      return prop.Empty || System.Convert.ToString(prop.Value).Length < 1;
    }

  }

  



 
}


