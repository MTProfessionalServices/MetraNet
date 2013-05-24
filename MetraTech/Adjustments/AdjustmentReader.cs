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
	internal class AdjustmentProxy
	{
		public IAdjustment Adjustment;
		public int AdjustmentTypeID;
		
		internal AdjustmentProxy(Adjustment adj, int adjustmentTypeID)
		{
			Adjustment = adj;
			AdjustmentTypeID = adjustmentTypeID;
		}
	}

	/// <summary>
	/// Summary description for AdjustmentReader.
	/// </summary>
	/// 
  [Guid("630c95ed-eb12-444e-bc5b-351f03a5c773")]
  public interface IAdjustmentReader
  {
    MetraTech.Interop.GenericCollection.IMTCollection GetAdjustments
      (IMTSessionContext apCTX,
      IMTPriceableItem aPI);
    IAdjustment FindAdjustmentTemplate
      (IMTSessionContext apCTX, int aPIID, int aAdjustmentTypeID);
    MetraTech.Interop.Rowset.IMTRowSet GetAvailableAdjustmentTypesAsRowset
		  (IMTSessionContext apCTX, int aPIID, bool isTemplate);
   
  }

  // readers support transactions but do not require them
	[ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Supported, Isolation=TransactionIsolationLevel.Any)]
  [Guid("8089fd8b-1143-4443-a6f2-1ba821379a61")]
  public class AdjustmentReader : ServicedComponent, IAdjustmentReader
  {
    protected IMTSessionContext mCTX;

    // looks like this is necessary for COM+?
    public AdjustmentReader()
    { 
    }

    [AutoComplete]
    public MetraTech.Interop.GenericCollection.IMTCollection GetAdjustments
      (IMTSessionContext apCTX, IMTPriceableItem aPI)
    {
      string column = aPI.IsTemplate() ? "id_pi_template" : "id_pi_instance";
      IReasonCodeReader rcreader = new ReasonCodeReader();
      MetraTech.Interop.GenericCollection.IMTCollection adjustments;
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__GET_ADJUSTMENT_TEMPLATES_OR_INSTANCES__"))
          {
              stmt.AddParam("%%PI_COLUMN%%", column);
              stmt.AddParam("%%ID_PI%%", aPI.ID);

              //stmt.AddParam("%%ID_LANG_CODE%%", 840);//aCtx.LanguageCode);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  // step 3: populate the collection
                  adjustments = GetAdjustmentsInternal(apCTX, reader, aPI.ID, aPI);
              }
          }

        // set reason codes
        foreach(IAdjustment aj in adjustments)
        {
          ((Adjustment)aj).SetApplicableReasonCodes(rcreader.GetReasonCodesForAdjustmentTemplate(apCTX, aj.ID));
        }

        return adjustments;
      }
      
    }
    
   
    [AutoComplete]
    public IAdjustment FindAdjustmentTemplate
      (IMTSessionContext apCTX, int aPIID, int aAdjustmentTypeID)
    {
      IReasonCodeReader rcreader = new ReasonCodeReader();
      MetraTech.Interop.GenericCollection.IMTCollection adjustments;
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__GET_ADJUSTMENT_TEMPLATE__"))
          {
              stmt.AddParam("%%PI_COLUMN%%", "id_pi_template");
              stmt.AddParam("%%ID_PI%%", aPIID);
              stmt.AddParam("%%ID_AJ_TYPE%%", aAdjustmentTypeID);

              //stmt.AddParam("%%ID_LANG_CODE%%", 840);//aCtx.LanguageCode);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  // step 3: populate the collection
                  adjustments = GetAdjustmentsInternal(apCTX, reader, aPIID, null);
              }
          }

        // set reason codes
        foreach(IAdjustment aj in adjustments)
        {
          ((Adjustment)aj).SetApplicableReasonCodes(rcreader.GetReasonCodesForAdjustmentTemplate(apCTX, aj.ID));
        }
        if(adjustments.Count < 1)
          throw new AdjustmentException(String.Format("No Adjustment Templates found for PI template {0} and Adjustment Type {1}", aPIID, aAdjustmentTypeID));
        if(adjustments.Count > 1)
          throw new AdjustmentException(String.Format("More then 1 Adjustment Templates found for PI template {0} and Adjustment Type {1}", aPIID, aAdjustmentTypeID));

        return (IAdjustment)adjustments[1];
      }
      
    }


		private void ResolveProxies(IMTSessionContext apCTX, ArrayList proxies)
		{
			AdjustmentCatalog acat = new AdjustmentCatalog();
			acat.Initialize(apCTX);
			
      IMTProductCatalog pcat = new MTProductCatalogClass();
      pcat.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)apCTX);

			foreach(AdjustmentProxy ap in proxies)
			{
				ap.Adjustment.AdjustmentType = acat.GetAdjustmentType(ap.AdjustmentTypeID);
			}
		}

    
    [AutoComplete]
    //protected MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentsInternal(IMTSessionContext apCTX, IMTDataReader reader, IMTPriceableItem aPI) 
    protected MetraTech.Interop.GenericCollection.IMTCollection GetAdjustmentsInternal(IMTSessionContext apCTX, IMTDataReader reader, int aPIID, IMTPriceableItem aPI)  
    {
			ArrayList proxies = new ArrayList();
      
      // TODO: should we seed the array list with the size of the collection. We 
      // know it because it is the record count
      MetraTech.Interop.GenericCollection.IMTCollection mRetCol = new MetraTech.Interop.GenericCollection.MTCollectionClass();
      int previd = 0;
      Adjustment aj = null;
      while(reader.Read())
      {
				int currid = reader.GetInt32("id_prop");
				if (currid != previd)
				{
					aj = new Adjustment();
					aj.ID = currid;
					mRetCol.Add(aj);

					// TODO: Fix GUID handling
					aj.GUID = "0xABCD";
					aj.Name = reader.GetString("nm_name");
					aj.DisplayName = reader.GetString("nm_display_name");
          aj.DisplayNames.ID = reader.GetInt32("n_display_name");
					aj.Description = reader.GetString("nm_desc");
					// Set the priceable item since a call to GetPriceableItem will cause
					// an infinite loop!
          if(aPI != null)
					  aj.PriceableItem = aPI;
					aj.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)apCTX);
          proxies.Add(new AdjustmentProxy(aj, reader.GetInt32("id_adjustment_type")));
				}
			}
			// Close up the reader so that we can execute the queries to resolve proxies
			reader.Close();
			// Resolve the proxies
			ResolveProxies(apCTX, proxies);
					
			return mRetCol;
		}

    [AutoComplete]
    public MetraTech.Interop.Rowset.IMTRowSet GetAvailableAdjustmentTypesAsRowset
		  (IMTSessionContext apCTX, int aPIID, bool isTemplate)
		{
      MetraTech.Interop.Rowset.IMTSQLRowset rs = new MetraTech.Interop.Rowset.MTSQLRowsetClass();
      rs.Init("Queries\\Adjustments");
			if (isTemplate)
			{
				rs.SetQueryTag("__GET_AVAILABLE_ADJUSTMENT_TYPES_FOR_TEMPLATE__"); 
			}
			else
			{
				rs.SetQueryTag("__GET_AVAILABLE_ADJUSTMENT_TYPES_FOR_INSTANCE__"); 
			}

      rs.AddParam("%%ID_PI%%", aPIID, true);
      rs.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID, true);
			rs.Execute();
			return rs;
		}

  }

 
}
