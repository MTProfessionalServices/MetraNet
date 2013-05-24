using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
using MetraTech.Interop.MTProductCatalog;


using MetraTech.DataAccess;



namespace  MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for AdjustmentWriter.
  /// </summary>
  /// 

  [Guid("e0fa98d4-dcaa-4d11-8191-f5b9d14441eb")]
  public interface IAdjustmentWriter
  {
    int Create(IMTSessionContext apCTX, IAdjustment pAdjustment);
    void Update(IMTSessionContext apCTX, IAdjustment pAdjustment);
    void Remove(IMTSessionContext apCTX, IAdjustment pAdjustment);
  }

	[ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("1da1753b-bc73-44ee-ae88-c8de27ab3082")]
  public class AdjustmentWriter : ServicedComponent, IAdjustmentWriter
  {
    protected IMTSessionContext mCTX;

    // looks like this is necessary for COM+?
    public AdjustmentWriter() { }

    [AutoComplete]
    public int Create(IMTSessionContext apCTX, IAdjustment pAdjustment)
    {
      //CR 9160: check that al least 1 reason code is specified in this adjustment template
      if(pAdjustment.IsTemplate && pAdjustment.GetApplicableReasonCodes().Count < 1)
        throw new AdjustmentException(String.Format("At least one reason code has to be specified in {0} Adjustment Template", pAdjustment.DisplayName));

      ReasonCodeWriter rcwriter = new ReasonCodeWriter();
      
      
      BasePropsWriter basewriter = new BasePropsWriter();
      int ajID = basewriter.CreateWithDisplayName(
        apCTX,(int)MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENT,
        pAdjustment.Name, pAdjustment.Description, pAdjustment.DisplayName);

      // set the type ID in the adjustment
      pAdjustment.ID = ajID;

      string picolumn = ((Adjustment)pAdjustment).IsTemplate ? "id_pi_template" : "id_pi_instance";
    
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__CREATE_ADJUSTMENT_TEMPLATE_OR_INSTANCE__"))
          {
              stmt.AddParam("%%PI_COLUMN%%", picolumn);
              stmt.AddParam("%%ID_PROP%%", ajID);
              stmt.AddParam("%%GUID%%", "0xABCD");//TODO: fix GUIDs System.Guid.NewGuid().ToByteArray());
              stmt.AddParam("%%PI_ID%%", ((Adjustment)pAdjustment).PriceableItemID);
              stmt.AddParam("%%ID_ADJUSTMENT_TYPE%%", pAdjustment.AdjustmentType.ID);
              stmt.ExecuteNonQuery();
          }
      }

      //Save localized display names
      int displaynameid = -1;
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__GET_DISPLAYNAME_DESC_ID_FOR_PC_ITEM__"))
          {
              stmt.AddParam("%%ID_PROP%%", pAdjustment.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  if (reader.Read())
                  {
                      displaynameid = reader.GetInt32("n_display_name");
                  }
              }
          }
      }
      
      if (displaynameid!=-1)
        pAdjustment.DisplayNames.SaveWithID(displaynameid);

      if (pAdjustment.IsTemplate)
      {
        rcwriter.RemoveMappings(apCTX, pAdjustment);
        foreach (IReasonCode rc in pAdjustment.GetApplicableReasonCodes())
        {
          rc.Save();
          rcwriter.CreateMapping(apCTX, rc, pAdjustment);
        }
      }
      return ajID;
    }

    [AutoComplete]
    public void Update(IMTSessionContext apCTX, IAdjustment pAdjustment)
    {
      ReasonCodeWriter rcwriter = new ReasonCodeWriter();

      //CR 9408: check that at least 1 reason code is specified in this adjustment template
      if(pAdjustment.IsTemplate && pAdjustment.GetApplicableReasonCodes().Count < 1)
        throw new AdjustmentException(String.Format("At least one reason code has to be specified in {0} Adjustment Template", pAdjustment.DisplayName));


      if (pAdjustment.IsTemplate)
      {
        rcwriter.RemoveMappings(apCTX, pAdjustment);
        foreach (IReasonCode rc in pAdjustment.GetApplicableReasonCodes())
        {
          rc.Save();
          rcwriter.CreateMapping(apCTX, rc, pAdjustment);
        }
      }
      
      BasePropsWriter basewriter = new BasePropsWriter();
      basewriter.UpdateWithDisplayName(apCTX,
        pAdjustment.Name, pAdjustment.Description, pAdjustment.DisplayName,pAdjustment.ID);

      //Save localized display names
      int displaynameid = -1;
      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__GET_DISPLAYNAME_DESC_ID_FOR_PC_ITEM__"))
          {
              stmt.AddParam("%%ID_PROP%%", pAdjustment.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  if (reader.Read())
                  {
                      displaynameid = reader.GetInt32("n_display_name");
                  }
              }
          }
      }
      
      if (displaynameid!=-1)
        pAdjustment.DisplayNames.SaveWithID(displaynameid);

    }
    [AutoComplete]
    public void Remove(IMTSessionContext apCTX, IAdjustment pAdjustment)
    {
      BasePropsWriter basewriter = new BasePropsWriter();
      //First remove reason code mappings
      ReasonCodeWriter rcwriter = new ReasonCodeWriter();
      AdjustmentTransactionReader reader = new AdjustmentTransactionReader();


      //CR 9701: check if adjustments were already created against this template or instance
      if(reader.GetAdjustmentRecordsByPI(apCTX, pAdjustment).RecordCount > 0)
        throw new AdjustmentException
          (String.Format("Adjustment {0} with ID {1} can not be removed, because it was used during adjustment process", 
          pAdjustment.IsTemplate ? "Template" : "Instance", pAdjustment.ID ));


      if (pAdjustment.IsTemplate)
      {
        rcwriter.RemoveMappings(apCTX, pAdjustment);
      }

      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__REMOVE_ADJUSTMENT_TEMPLATE_OR_INSTANCE__"))
          {
              stmt.AddParam("%%ID_PROP%%", pAdjustment.ID);
              stmt.ExecuteNonQuery();
          }

          basewriter.Delete(apCTX, pAdjustment.ID);

      }
    
    }
    
  }

 
}
