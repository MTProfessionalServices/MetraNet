
using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.MTSQL;
using MetraTech.Interop.MTProductCatalog;




namespace  MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for ReasonCodeWriter.
  /// </summary>
  /// 
  
  [Guid("49de6065-4660-4a10-8df5-631a5e51ee78")]
  public interface IReasonCodeWriter
  {
    int Create(IMTSessionContext apCTX, IReasonCode pCode);
    void Update(IMTSessionContext apCTX, IReasonCode pCode);
    void Remove(IMTSessionContext apCTX, IReasonCode pCode);
    void CreateMapping(IMTSessionContext apCTX, IReasonCode pCode, IAdjustment aAdjustment);
    void RemoveMapping(IMTSessionContext apCTX, IReasonCode pCode, IAdjustment aAdjustment);
    void RemoveMappings(IMTSessionContext apCTX, IAdjustment aAdjustment);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("e9131c88-fa48-47c6-9e9f-466a40d1ea73")]
  public class ReasonCodeWriter : ServicedComponent, IReasonCodeWriter
  {
    protected IMTSessionContext mCTX;

    // looks like this is necessary for COM+?
    public ReasonCodeWriter() { }

    [AutoComplete]
    public int Create(IMTSessionContext apCTX, IReasonCode pCode)
    {
      BasePropsWriter basewriter = new BasePropsWriter();
      int reasonCodeID = basewriter.CreateWithDisplayName(
        apCTX,
        (int)MTPCEntityType.PCENTITY_TYPE_ADJUSTMENT_REASON_CODE,
        pCode.Name, pCode.Description, pCode.DisplayName);

      // set the type ID in the adjustment
      pCode.ID = reasonCodeID;
    
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
        //delete adjustment properties first
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__CREATE_REASON_CODE__"))
          {
              stmt.AddParam("%%ID_PROP%%", pCode.ID);
              stmt.AddParam("%%GUID%%", "0xABCD");//pCode.GUID); TODO: Fix me
              stmt.ExecuteNonQuery();
          }
      }

      //Save localized display names
      int displaynameid = -1;
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__GET_DISPLAYNAME_DESC_ID_FOR_PC_ITEM__"))
          {
              stmt.AddParam("%%ID_PROP%%", pCode.ID);
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
        pCode.DisplayNames.SaveWithID(displaynameid);
      
      return reasonCodeID;
    }
    
    
    [AutoComplete]
    public void Update(IMTSessionContext apCTX, IReasonCode pCode)
    {
      BasePropsWriter basewriter = new BasePropsWriter();
      basewriter.UpdateWithDisplayName(
        apCTX,
        pCode.Name, pCode.Description, pCode.DisplayName,pCode.ID);

      //Save localized display names
      int displaynameid = -1;
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__GET_DISPLAYNAME_DESC_ID_FOR_PC_ITEM__"))
          {
              stmt.AddParam("%%ID_PROP%%", pCode.ID);
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
        pCode.DisplayNames.SaveWithID(displaynameid);

      
    }
    [AutoComplete]
    public void Remove(IMTSessionContext apCTX, IReasonCode pCode)
    {
      //check if it's used and return error
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__REMOVE_REASON_CODE__"))
          {
              stmt.AddParam("%%ID_PROP%%", pCode.ID);
              stmt.ExecuteNonQuery();
          }
      }
      BasePropsWriter basewriter = new BasePropsWriter();
      basewriter.Delete(apCTX, pCode.ID);
    }
    [AutoComplete]
    public void CreateMapping(IMTSessionContext apCTX, IReasonCode pCode, IAdjustment aAdjustment)
    {
      //check if it's used and return error
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__CREATE_REASON_CODE_MAPPING__"))
          {
              stmt.AddParam("%%ID_ADJUSTMENT%%", aAdjustment.ID);
              stmt.AddParam("%%ID_REASON_CODE%%", pCode.ID);
              stmt.ExecuteNonQuery();
          }
      }
    }

    [AutoComplete]
    public void RemoveMapping(IMTSessionContext apCTX, IReasonCode pCode, IAdjustment aAdjustment)
    {
      //check if it's used and return error
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__REMOVE_REASON_CODE_MAPPING__"))
          {
              stmt.AddParam("%%ID_ADJUSTMENT%%", aAdjustment.ID);
              stmt.AddParam("%%ID_REASON_CODE%%", pCode.ID);
              stmt.ExecuteNonQuery();
          }
      }
    }

    [AutoComplete]
    public void RemoveMappings(IMTSessionContext apCTX,IAdjustment aAdjustment)
    {
      //check if it's used and return error
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__REMOVE_REASON_CODE_MAPPINGS__"))
          {
              stmt.AddParam("%%ID_ADJUSTMENT%%", aAdjustment.ID);
              stmt.ExecuteNonQuery();
          }
      }
    }

    


  }
  

 
}

