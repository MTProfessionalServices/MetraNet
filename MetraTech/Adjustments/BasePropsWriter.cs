using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;

using MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.Interop.MTProductCatalog;

namespace MetraTech.Adjustments
{
  [Guid("dd241c9e-d6fa-4358-a22f-06374c266740")]
  public interface IBasePropsWriter
  {
    int Create(IMTSessionContext apCTX, int aKind, String aName, String aDescription);
    int CreateWithDisplayName(IMTSessionContext apCTX, 
      int aKind, 
      String aName, 
      String aDescription,
      String aDisplayName);
    void Update(IMTSessionContext apCTX, 
      String aName, 
      String aDescription,
      int aID);
    void UpdateWithDisplayName(IMTSessionContext apCTX, 
      String aName, 
      String aDescription,
      String aDisplayName, 
      int aID);
    void Delete(IMTSessionContext apCTX, 
      int aID);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("4f05a256-6231-49e0-8a3c-07fce774788b")]
  public class BasePropsWriter : ServicedComponent, IBasePropsWriter
  {
    protected IMTSessionContext mCTX;
 
    // looks like this is necessary for COM+?
    public BasePropsWriter() { }
 
    [AutoComplete]
    public int Create(IMTSessionContext apCTX, int aKind, String aName, String aDescription)
    {
      return CreateWithDisplayName(apCTX, aKind, aName, aDescription, null);
    }
 
    [AutoComplete]
    public int CreateWithDisplayName(IMTSessionContext apCTX, 
      int aKind, 
      String aName, 
      String aDescription,
      String aDisplayName) 
    {
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("InsertBaseProps"))
          {
              stmt.AddParam("id_lang_code", MTParameterType.Integer, apCTX.LanguageID);
              stmt.AddParam("a_kind", MTParameterType.Integer, aKind);
              stmt.AddParam("a_approved", MTParameterType.String, "N");
              stmt.AddParam("a_archive", MTParameterType.String, "N");
              stmt.AddParam("a_nm_name", MTParameterType.WideString, aName);
              stmt.AddParam("a_nm_desc", MTParameterType.WideString, aDescription);
              stmt.AddParam("a_nm_display_name", MTParameterType.WideString, aDisplayName);
              stmt.AddOutputParam("a_id_prop", MTParameterType.Integer);
              stmt.ExecuteNonQuery();
              //Get PK from newly created entry
              return (int)stmt.GetOutputValue("a_id_prop");
          }
      }
    }
 
    [AutoComplete]
    public void Update(IMTSessionContext apCTX, 
      String aName, 
      String aDescription,
      int aID)
    {
      UpdateWithDisplayName(apCTX, aName, aDescription, null, aID);
    }
 
    [AutoComplete]
    public void UpdateWithDisplayName(IMTSessionContext apCTX, 
      String aName, 
      String aDescription,
      String aDisplayName, 
      int aID)
    {
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpdateBaseProps"))
          {
              stmt.AddParam("a_id_prop", MTParameterType.Integer, aID);
              stmt.AddParam("a_id_lang", MTParameterType.Integer, apCTX.LanguageID);
              stmt.AddParam("a_nm_name", MTParameterType.WideString, aName.Length > 0 ? aName : null);
              stmt.AddParam("a_nm_desc", MTParameterType.WideString, aDescription.Length > 0 ? aDescription : null);
              stmt.AddParam("a_nm_display_name", MTParameterType.WideString, aDisplayName.Length > 0 ? aDisplayName : null);
              stmt.ExecuteNonQuery();
          }
      }
    }
 
    [AutoComplete]
    public void Delete(IMTSessionContext apCTX, 
      int aID)
    {
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("DeleteBaseProps"))
          {
              stmt.AddParam("a_id_prop", MTParameterType.Integer, aID);
              stmt.ExecuteNonQuery();
          }
      }
    }
  }
 

}