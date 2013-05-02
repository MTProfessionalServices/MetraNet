using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTYAAC;
using NUnit.Framework;

using MetraTech;

using MetraTech.DomainModel.Common;
using MetraTech.Core.Services;



using System.Collections;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.BaseTypes;
using IMTCompositeCapability = MetraTech.Interop.MTAuth.IMTCompositeCapability;
using IMTYAAC = MetraTech.Interop.MTAuth.IMTYAAC;


//
// To Run this fixture
// c:\dev\MetraNetDEV\Source\Thirdparty\NUnit260\bin\nunit-console-x86.exe /run:MetraTech.Core.Services.UnitTests.AuditLogServiceTest O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll /output=testOutput.txt
//
namespace MetraTech.Core.Services.UnitTests
{
    [TestFixture]
    public class AuditLogServiceTest
    {

        /// <summary>
        ///    Runs once before any of the tests are run.
        /// </summary>
        [TestFixtureSetUp]
        public void Init()
        {
            try
            {
#if false
                // Create a client for interacting with the TaxService
                AuditLogServiceClient client = new AuditLogServiceClient();
                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                // Delete all rows from t_tax_billsoft_exemptions
                MTList<BillSoftExemption> exemptionsToDelete = new MTList<BillSoftExemption>();

                client.GetBillSoftExemptions(ref exemptionsToDelete);

                List<BillSoftExemption> tmpBillSoftExemptionsToDelete = exemptionsToDelete.Items;
                Console.WriteLine("tmpBillSoftExemptionsToDelete.Count={0}", tmpBillSoftExemptionsToDelete.Count);

                foreach (var tmpBillSoftExemption in tmpBillSoftExemptionsToDelete)
                {
                    client.DeleteBillSoftExemption(tmpBillSoftExemption.UniqueId);
                }

                // Delete all rows from t_tax_billsoft_overrides
                MTList<BillSoftOverride> overridesToDelete = new MTList<BillSoftOverride>();
                client.GetBillSoftOverrides(ref overridesToDelete);
                List<BillSoftOverride> tmpBillSoftOverridesToDelete = overridesToDelete.Items;
                Console.WriteLine("tmpBillSoftOverridesToDelete.Count={0}", tmpBillSoftOverridesToDelete.Count);

                foreach (var tmpBillSoftOverride in tmpBillSoftOverridesToDelete)
                {
                    client.DeleteBillSoftOverride(tmpBillSoftOverride.UniqueId);
                }
#endif
            }
            catch (Exception e)
            {
                Console.WriteLine("caught exception {0}", e.Message);
                throw;
            }
        }

        [Test]
        [Category("TestAuditLogFunctionality")]
        public void TestAuditLogFunctionality()
        {
            AuditLogServiceClient client = new AuditLogServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            
            client.InsertAuditLogEntry(129, 5002, 123, 1, "XXXXX Testing 123");

            MTList<AuditLogEntry> auditLogEntries = new MTList<AuditLogEntry>();
            client.RetrieveAuditLogEntriesForEntity(123, ref auditLogEntries);

            Console.WriteLine("XXXXX number of audit logs = {0}", auditLogEntries.Items.Count);

#if false
            // There should be zero exemption now, so check it
            // Delete all rows from t_tax_billsoft_exemptions
            MTList<BillSoftExemption> exemptions = new MTList<BillSoftExemption>();
            client.GetBillSoftExemptions(ref exemptions);
            List<BillSoftExemption> tmpBillSoftExemptions = exemptions.Items;
            Console.WriteLine("tmpBillSoftExemptions.Count={0}", tmpBillSoftExemptions.Count);
            Assert.IsTrue(tmpBillSoftExemptions.Count == 0);
#endif

        }



    }
}
