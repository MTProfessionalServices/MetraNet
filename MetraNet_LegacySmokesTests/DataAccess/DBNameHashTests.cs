
namespace MetraTech.DataAccess.Test
{
  using System;
  using System.Diagnostics;
  using MetraTech.DataAccess;
  using MetraTech.DataAccess.OleDb;
  using NUnit.Framework;

  // nunit-console /fixture:MetraTech.DataAccess.Test.ConnectionTests  /assembly:O:\debug\bin\MetraTech.DataAccess.Test.dll

  [Category("NoAutoRun")]
  [TestFixture] 
  public class DBNameHashTests
  {
    DBNameHash dbNameHash = new DBNameHash();

    /* 
     * The tests
     */

    [Test]
    public void GetDBNameHash_gt30()
    {
      string name = "dbnames-longer-than-30-characters-get-hashed";

      string n1 = dbNameHash.GetDBNameHash(name);
      string n2 = dbNameHash.GetDBNameHash(name);

      Assert.AreEqual(n1, n2);

      dbNameHash.showHash();
    }

    [Test]
    public void GetDBNameHash_le30()
    {
      string name = "names-under-31-chars-preserved";

      string n1 = dbNameHash.GetDBNameHash(name);
      string n2 = dbNameHash.GetDBNameHash(name);

      Assert.AreEqual(n1, n2);
      Assert.AreEqual(n1, name);

      dbNameHash.showHash();
    }

    [Test]
    public void GetDBName_known()
    {
      string n = "GetDBName_known_GetDBName_known_GetDBName_known";
      //Guid.NewGuid().ToString().Substring(0,30);

      string h = dbNameHash.GetDBNameHash(n);

      string n2 = dbNameHash.GetDBName(h);

      Assert.AreEqual(n, n2);
      dbNameHash.showHash();
    }

    [Test]
    public void GetDBName_unknown()
    {
      string h = "this-shouldn't-be-in-the-db-" + Guid.NewGuid().ToString().Substring(0,30);

      string n = dbNameHash.GetDBName(h);

      Assert.AreEqual(n.Length, 0);
      dbNameHash.showHash();
    }

    /* 
     * Helper funcs
     * 
     */
    ConnectionInfo connInfo = null;
    ConnectionInfo ConnInfo
    {
      get 
      {
        if (connInfo == null)
          connInfo = new ConnectionInfo("NetMeter");
        return connInfo;
      }
    }
    bool IsOracle { get { return (ConnInfo.DatabaseType == DBType.Oracle); } }
    bool IsSqlServer { get { return (ConnInfo.DatabaseType == DBType.SQLServer); } }
	
  }
}
