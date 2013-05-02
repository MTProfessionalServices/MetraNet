namespace MetraTech.Audit.Test
{
  using System;
  using MetraTech.Audit;
  using MetraTech.Test;
	using NUnit.Framework;
	using System.Runtime.InteropServices;
  using Rowset=MetraTech.Interop.Rowset;
  using System.Text;

  //
  // To run the this test fixture:
  // nunit-console /fixture:MetraTech.Localization.Test.Tests /assembly:O:\debug\bin\MetraTech.Localization.Test.dll
  //
  [TestFixture]
  [ComVisible(false)]
  public class AuditLogTests 
  {
    /// <summary>
    /// Test timezone configuration
    /// </summary>
    [Test]
    public void TestRetrieveAuditLog()
    {
      Console.WriteLine("Starting TestRetrieveAuditLog");
      IAuditLogManager alm = new AuditLogManager();

      Rowset.IMTSQLRowset rowset = alm.GetAuditLogAsRowset(null);
      
      Console.WriteLine(String.Format("Retrieved audit log with null filter that returned {0} records",rowset.RecordCount));
      
      alm.MaximumNumberRecords = 0;
      Console.WriteLine(String.Format("The maximum number of rows returned should now be {0}", alm.MaximumNumberRecords));
      rowset = alm.GetAuditLogAsRowset(null);
      
      Console.WriteLine(String.Format("Retrieved audit log with null filter that returned all the audit log records which is {0} records",rowset.RecordCount));

    }

    [Test]
    public void TestRetrieveAuditLogWithFilter()
    {
      Console.WriteLine("Starting TestRetrieveAuditLogWithFilter");
      IAuditLogManager alm = new AuditLogManager();

      Rowset.IMTDataFilter filter = new Rowset.MTDataFilter();
      filter.Add("EntityType", (int) Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL, 2);

      alm.MaximumNumberRecords = 0;
      Rowset.IMTSQLRowset rowset = alm.GetAuditLogAsRowset(filter);
      
      Console.WriteLine(String.Format("Retrieved audit log with only Product Catalog events filter that returned {0} records",rowset.RecordCount));
      

    }

  }
}
