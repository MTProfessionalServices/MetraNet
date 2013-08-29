using System;
using MetraTech.ActivityServices.Common;
using MetraTech.Application.ProductManagement;
using MetraTech.DataAccess;
using MetraTech.Interop.MTAuth;

namespace MetraTech.Application
{

  /// <summary>
  /// Represents utilities for work with base properties
  /// </summary>
  public static class BasePropsUtils
  {
    public static int CreateBaseProps(IMTSessionContext apCTX, string aName, string aDescription, string aDisplayName, int nKind)
    {
      int retVal;
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("InsertBasePropsV2"))
        {
          stmt.AddParam("id_lang_code", MTParameterType.Integer, apCTX.LanguageID);
          stmt.AddParam("a_kind", MTParameterType.Integer, nKind);
          stmt.AddParam("a_approved", MTParameterType.WideString, "N");
          stmt.AddParam("a_archive", MTParameterType.WideString, "N");
          stmt.AddParam("a_nm_name", MTParameterType.WideString, !String.IsNullOrEmpty(aName) ? aName : null);
          stmt.AddParam("a_nm_desc", MTParameterType.WideString, !String.IsNullOrEmpty(aDescription) ? aDescription : null);
          stmt.AddParam("a_nm_display_name", MTParameterType.WideString, !String.IsNullOrEmpty(aDisplayName) ? aDisplayName : null);
          stmt.AddOutputParam("a_id_prop", MTParameterType.Integer);
          stmt.ExecuteNonQuery();
          retVal = (int)stmt.GetOutputValue("a_id_prop");
        }
      }
      return retVal;
    }

    public static void UpdateBaseProps(IMTSessionContext apCtx, string aDescription, bool isDescriptionDirty, string aDisplayName, bool isDisplayNameDirty, int aID)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        string oldName;
        string oldDesc;
        string oldDispName;
        using (var stmt = conn.CreateAdapterStatement(PriceListService.PCWS_QUERY_FOLDER, "__GET_BASE_PROPS_FOR_UPDATE__"))
        {
          stmt.AddParam("%%ID_PROP%%", aID);

          using (var rdr = stmt.ExecuteReader())
          {
            if (rdr.Read())
            {
              oldName = (!rdr.IsDBNull("nm_name")) ? rdr.GetString("nm_name") : null;
              oldDesc = (!rdr.IsDBNull("nm_desc")) ? rdr.GetString("nm_desc") : null;
              oldDispName = (!rdr.IsDBNull("nm_display_name")) ? rdr.GetString("nm_display_name") : null;
            }
            else
            {
              throw new MASBasicException(String.Format("Base properties for {0} do not exist for update", aID));
            }
          }
        }


        using (var callableStmt = conn.CreateCallableStatement("UpdateBaseProps"))
        {
          callableStmt.AddParam("a_id_prop", MTParameterType.Integer, aID);
          callableStmt.AddParam("a_id_lang", MTParameterType.Integer, apCtx.LanguageID);
          callableStmt.AddParam("a_nm_name", MTParameterType.WideString, oldName);
          callableStmt.AddParam("a_nm_desc", MTParameterType.WideString, isDescriptionDirty ? (aDescription.Length > 0 ? aDescription : null) : oldDesc);
          callableStmt.AddParam("a_nm_display_name", MTParameterType.WideString, isDisplayNameDirty ? (aDisplayName.Length > 0 ? aDisplayName : null) : oldDispName);
          callableStmt.ExecuteNonQuery();
        }
      }
    }
  }
}
