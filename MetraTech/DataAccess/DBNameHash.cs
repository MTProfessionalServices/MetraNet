//
//
namespace MetraTech.DataAccess
{
  using System;
  using System.Diagnostics;
  using System.Collections;
  using System.Collections.Specialized;
  using System.EnterpriseServices;
  using System.Runtime.InteropServices;
  using MetraTech.DataAccess;

  /// <summary>
  /// Interface for the DBNameHash
  /// </summary>
  [Guid("a45b7fc4-d234-4505-9bca-4bc94f7948f3")]
  [ComVisible(true)]
  public interface IDBNameHash
  {
    string GetDBNameHash(string name);
    string GetDBName(string name);
  }

  /// <summary>
  /// Converts a long database identifier into a unique name that
  /// satisfies the restrictions on identifiers imposed by the 
  /// database vendor in use.  Supports Sql Server and Oracle.
  /// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.NotSupported)]
  [Guid("4e1b532e-520d-4702-8a0c-fca7f4714ec6")]
  [ComVisible(true)]
  public class DBNameHash :  ServicedComponent, IDBNameHash
  {
    // The internal cache using the long table name as the key and the
    // hashed name as the value.
    private static StringDictionary namecache = new StringDictionary();
    private static ConnectionInfo connInfo = new ConnectionInfo("NetMeter");

    bool isOracle { get { return (connInfo.DatabaseType == DBType.Oracle); } }
    bool isSqlServer { get { return (connInfo.DatabaseType == DBType.SQLServer); } }

    /// <summary>
    /// Converts a long database name into a 30 char name.
    /// </summary>
    /// <param name="name">Long name to hash</param>
    /// <returns>Hashed name</returns>
    public string  GetDBNameHash(string name)
    {
      // Hashing not needed for Sql Server
      if (isSqlServer)
        return name;

      // Find name in hash first.
      string namehash;

      lock(namecache) 
      {
        namehash = namecache[name];

        if (namehash == null)
        {
          namehash = getDBNameHash(name);
          namecache[name] = namehash;
        }
      }

      return namehash;
    }

    /// <summary>
    /// Finds the original name given a hashed database name.
    /// </summary>
    /// <param name="name">Hashed database name</param>
    /// <returns>Original name</returns>
    public string GetDBName(string namehash)
    {
      // Hashing not needed for Sql Server
      if (isSqlServer)
        return namehash;

      string name = getDBName(namehash);

      if (name.Length > 0)
        lock(namecache) 
          namecache[name] = namehash;

      return name;
    }

    /// <summary>
    /// Call the stored proc that hashes long names into short names.
    /// </summary>
    /// <param name="name">The long name</param>
    /// <returns>The hashed name</returns>
    private string getDBNameHash(string name)
    {
      string namehash = "";

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTCallableStatement gethash = conn.CreateCallableStatement("GetDBNameHash"))
          {
              gethash.AddParam("p_name", MTParameterType.String, name);
              gethash.AddOutputParam("p_name_hash", MTParameterType.String, 30);
              gethash.ExecuteNonQuery();

              namehash = (string)gethash.GetOutputValue("p_name_hash");
          }
      }

      return namehash;
    } // getDBNameHash
   
    /// <summary>
    /// Calls the stored procedure that finds the original database name
    /// given a hashed name.
    /// </summary>
    /// <param name="namehash">A hashed name.</param>
    /// <returns>Original long name</returns>
    private string getDBName(string namehash)
    {
      string name = "";

      using(IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTCallableStatement getname = conn.CreateCallableStatement("GetDBName"))
          {
              getname.AddParam("p_name_hash", MTParameterType.String, namehash);
              getname.AddOutputParam("p_name", MTParameterType.String, 128);
              getname.ExecuteNonQuery();

              name = getname.GetOutputValue("p_name").ToString();
          }

        return name;
      }
    } // getDBName()

    /// <summary>
    /// Prints cached names on console.
    /// </summary>
    public void showHash()
    {
      lock(namecache) 
      {
        Console.WriteLine("\nDBName cache:");
        foreach (DictionaryEntry de in namecache)
          Console.WriteLine("   {0} <=> {1}", de.Value, de.Key );
      }
    } // showHash()
  }
}
