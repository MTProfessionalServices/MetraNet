#region

using System;
using MetraTech.DataAccess;

#endregion

namespace MetraTech.Tax.Framework.DataAccess
{
  /// <summary>
  /// The TaxManagerPersistenceObject class is used by other concrete objects to allow them to specify 
  /// their imple of how to persist the object. That way the table writer can simply hold a collection
  /// and call the Persist implementation for the object directly without having to care which 
  /// type of objects it is persisting.
  /// </summary>
  public class TaxManagerPersistenceObject
  {
    /// <summary>
    /// This method pertains to SQLServer only.
    /// Store the current values for the row in
    /// the given BCP Bulk Insert object. Later, other
    /// classes write the BCP Bulk Insert objects 
    /// to the database.
    /// </summary>
    /// <param name="bcpObj"></param>
    public virtual void Persist(ref BCPBulkInsert bcpObj)
    {
      throw new NotImplementedException();
    }

    ///<summary>
    /// This method pertains to Oracle only.
    /// Store the current values for the row in
    /// the given BCP Bulk Insert object. Later, other
    /// classes write the BCP Bulk Insert objects 
    /// to the database.
    ///</summary>
    public virtual void Persist(ref ArrayBulkInsert arrayBulkInsert)
    {
        throw new NotImplementedException();
    }

  }
}
