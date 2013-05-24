using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.Interop.MTProductCatalog;




namespace  MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for ReasonCodeReader.
  /// </summary>
  /// 
  [Guid("3feef780-3d10-4fc7-b009-0c898efe5d85")]
  public interface IReasonCodeReader
  {
    IReasonCode FindReasonCode(IMTSessionContext apCTX, int aID);
    IReasonCode FindReasonCodeByName(IMTSessionContext apCTX, string aName);
    MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodes(IMTSessionContext apCTX);
    RS.IMTSQLRowset GetReasonCodesAsRowset(IMTSessionContext apCTX);
    MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodesForAdjustmentTemplate(IMTSessionContext apCTX, int ajTemplateID);
	MetraTech.Interop.GenericCollection.IMTCollection GetCommonReasonCodesForAdjustmentTemplate(IMTSessionContext apCTX, MetraTech.Interop.GenericCollection.IMTCollection aTempIds);
  }

  // readers support transactions but do not require them
	[ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Supported, Isolation=TransactionIsolationLevel.Any)]
  [Guid("a7919b8b-4114-4bf2-994d-58de8fd0a707")]
  public class ReasonCodeReader : ServicedComponent, IReasonCodeReader
  {
    protected IMTSessionContext mCTX;

    public ReasonCodeReader()
    { 
    }

    [AutoComplete]
    public MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodes(IMTSessionContext apCTX)
    {
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_REASON_CODES__"))
          {
              stmt.AddParam("%%PREDICATE%%", "");
              // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
              stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  MetraTech.Interop.GenericCollection.IMTCollection coll =
                    GetReasonCodesInternal(apCTX, reader);
                  return coll;
              }
          }
      }
    
    }
    [AutoComplete]
    public RS.IMTSQLRowset GetReasonCodesAsRowset(IMTSessionContext apCTX)
    {

      RS.IMTSQLRowset rs = new RS.MTSQLRowsetClass();
      rs.Init("Queries\\Adjustments");
      rs.SetQueryTag("__LOAD_REASON_CODES__"); 
      rs.AddParam("%%PREDICATE%%","", true);
	  // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
	  rs.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID, true);
      rs.Execute();
      return rs;
    }

    [AutoComplete]
    public MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodesForAdjustmentTemplate(IMTSessionContext apCTX, int aAJTemplateID)
    {
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_REASON_CODES_FOR_AJ_TEMPLATE__"))
          {
              // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
              stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
              stmt.AddParam("%%ID_AJ%%", aAJTemplateID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  MetraTech.Interop.GenericCollection.IMTCollection coll =
                    GetReasonCodesInternal(apCTX, reader);
                  return coll;
              }
          }
      }
    
    }
	[AutoComplete]
	public MetraTech.Interop.GenericCollection.IMTCollection GetCommonReasonCodesForAdjustmentTemplate(IMTSessionContext apCTX, MetraTech.Interop.GenericCollection.IMTCollection aTempIds)
	{
		string ajTempIds = "";
        using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
		{
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_COMMONREASON_CODES_FOR_AJ_TEMPLATE__"))
            {
                // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
                stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                foreach (int aAJTemplateID in aTempIds)
                {
                    ajTempIds += (aAJTemplateID.ToString() + ",");
                }
                ajTempIds = ajTempIds.Remove(ajTempIds.Length - 1, 1);
                stmt.AddParam("%%ID_AJLIST%%", ajTempIds);
                stmt.AddParam("%%ID_COUNT%%", aTempIds.Count);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    MetraTech.Interop.GenericCollection.IMTCollection coll =
                        GetReasonCodesInternal(apCTX, reader);
                    return coll;
                }
            }
		}
	}
    [AutoComplete]
    public IReasonCode FindReasonCodeByName(IMTSessionContext apCTX, string aName)
    {
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_REASON_CODES__"))
            {
                stmt.AddParam("%%PREDICATE%%", String.Format("AND base1.nm_name = N'{0}'", aName), true);
                // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
                stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    MetraTech.Interop.GenericCollection.IMTCollection coll =
                    GetReasonCodesInternal(apCTX, reader);
                    if (coll.Count == 0)
                        return null;
                    return (IReasonCode)coll[1];
                }
            }
        }
    }
    
    [AutoComplete]
    public IReasonCode FindReasonCode(IMTSessionContext apCTX, int aID)
    {
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_REASON_CODES__"))
            {
                stmt.AddParam("%%PREDICATE%%", String.Format("AND rc.id_prop = {0}", aID));
                // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
                stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    MetraTech.Interop.GenericCollection.IMTCollection coll =
          GetReasonCodesInternal(apCTX, reader);
                    if (coll.Count == 0)
                        return null;
                    return (IReasonCode)coll[1];
                }
            }
        }
    }

    protected MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodesInternal(IMTSessionContext apCTX, IMTDataReader reader) 
    {
      MetraTech.Interop.GenericCollection.IMTCollection mRetCol = new MetraTech.Interop.GenericCollection.MTCollectionClass();
      int previd = 0;
      while(reader.Read())
      {
        int codeid = reader.GetInt32("ReasonCodeID");
        if(codeid != previd)
        {
          IReasonCode code = new ReasonCode();
          string name = reader.GetString("ReasonCodeName");
					//CR 10645 fix
          string desc = reader.IsDBNull("ReasonCodeDescription") ? string.Empty : reader.GetString("ReasonCodeDescription");
			
		  //CR 11420 fix
		  string dispname = reader.IsDBNull("ReasonCodeDisplayName") ? string.Empty : reader.GetString("ReasonCodeDisplayName");
		  int displaynameid = reader.GetInt32("ReasonCodeDisplayNameID");
          object guid = reader.IsDBNull("ReasonCodeGUID") ? null : reader.GetValue("ReasonCodeGUID");
          
          code.ID = codeid;
          code.Name = name;
          code.DisplayName = dispname;
          code.DisplayNames.ID = displaynameid;
          code.Description = desc;
          code.GUID = guid.ToString();
          code.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)apCTX);
          mRetCol.Add(code);
          previd = codeid;
        }
      }
      return mRetCol;
    }

   
  }

 
}
