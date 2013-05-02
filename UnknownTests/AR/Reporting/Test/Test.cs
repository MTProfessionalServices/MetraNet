// to run:
// nunit-console.exe /assembly:MetraTech.AR.Reporting.Test.dll

using System;
using NUnit.Framework;
using MetraTech.AR.Reporting;
using MetraTech.DataAccess;


namespace MetraTech.AR.Reporting.Test
{
	
  [TestFixture]
  public class ReportTest
  {
    [Test]
    public void TestInvoiceReport()
    {
      InvoiceReport rep = new InvoiceReport();
      
      int accountID;
      int intervalID;
      int languageCode;
      GetParams(out accountID, out intervalID, out languageCode);
      
      rep.Init(accountID, intervalID, languageCode ); 

      string xml = rep.GetInvoiceXml();
      Console.WriteLine("GetInvoiceXml returned: {0}", xml );

      xml = rep.GetBalanceXml();
      Console.WriteLine("GetBalanceXml() returned: {0}", xml);
    }

    [Test]
    public void TestPreviousChargesReport()
    {
      PreviousChargesReport rep = new PreviousChargesReport();
      
      int accountID;
      int intervalID;
      int languageCode;
      GetParams(out accountID, out intervalID, out languageCode);
      
      rep.Init(accountID, intervalID, languageCode); 

      string xml = rep.GetPreviousChargesXml();
      Console.WriteLine("GetPreviousChargesXml returned: {0}", xml );
    }

    /// <summary>
    /// return first account in t_acc_usage or 123
    /// </summary>
    private void GetParams(out int accountID, out int intervalID, out int languageCode)
    {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            string qry = @"select top 1 au.id_acc, id_usage_interval, c_Language
                       from t_acc_usage au
                       join t_av_internal av on au.id_acc = av.id_acc";
            using (IMTStatement stmt = conn.CreateStatement(qry))
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        accountID = reader.GetInt32("id_acc");
                        intervalID = reader.GetInt32("id_usage_interval");
                        languageCode = reader.GetInt32("c_Language");
                    }
                    else
                    {
                        accountID = 123;
                        intervalID = 34269;
                        languageCode = 834;
                    }
                }
            }
        }
    }
  }
}
