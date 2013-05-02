using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTYAAC;
using Microsoft.VisualStudio.TestTools.UnitTesting;

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
// c:\dev\MetraNetDEV\Source\Thirdparty\NUnit260\bin\nunit-console-x86.exe /run:MetraTech.Core.Services.UnitTests.TaxServiceTest O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll /output=testOutput.txt
//
namespace MetraTech.Core.Services.UnitTests
{
    [TestClass]
    public class TaxServiceTest
    {

        /// <summary>
        ///    Runs once before any of the tests are run.
        /// </summary>
        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
            try
            {
                // Create a client for interacting with the TaxService
                TaxServiceClient client = new TaxServiceClient();
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

#if true
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

        [TestMethod]
        [TestCategory("TestBasicExemptionFunctionality")]
        public void TestBasicExemptionFunctionality()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            // create a new exemption
            BillSoftExemption exemption1;
            client.CreateBillSoftExemption(111222, false, out exemption1);
            Console.WriteLine("UniqueId={0}, AccountId={1}, ApplyToAccountAndDescendents={2}",
                exemption1.UniqueId,
                exemption1.AccountId,
                exemption1.ApplyToAccountAndDescendents);

            Assert.IsTrue(exemption1.AccountId == 111222);
            Assert.IsTrue(exemption1.ApplyToAccountAndDescendents == false);
            Console.WriteLine("exemption1.StartDate={0}", exemption1.StartDate);
            Console.WriteLine("exemption1.EndDate={0}", exemption1.EndDate);
            Console.WriteLine("exemption1.CreateDate={0}", exemption1.CreateDate);
            Console.WriteLine("exemption1.UpdateDate={0}", exemption1.UpdateDate);

            DateTime dateTimeNow = DateTime.Now;

            // Sleep so that update date will change slightly
            System.Threading.Thread.Sleep(2000);

            // update the contents of the exemption and store it in the DB
            DateTime jan_1_2012 = new DateTime(2012, 1, 1);
            DateTime jan_1_2013 = new DateTime(2013, 1, 1);
            exemption1.AccountId = 111333;
            exemption1.ApplyToAccountAndDescendents = true;
            exemption1.CertificateId = "abcdefg";
            exemption1.PermanentLocationCode = 777;
            exemption1.TaxType = 45;
            exemption1.TaxLevel = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County;
            exemption1.StartDate = jan_1_2012;
            exemption1.EndDate = jan_1_2013;
            Assert.IsTrue(exemption1.IsAccountIdDirty == true);
            Assert.IsTrue(exemption1.IsApplyToAccountAndDescendentsDirty == true);
            Assert.IsTrue(exemption1.IsCertificateIdDirty == true);
            Assert.IsTrue(exemption1.IsPermanentLocationCodeDirty == true);
            Assert.IsTrue(exemption1.IsTaxTypeDirty == true);
            Assert.IsTrue(exemption1.IsTaxLevelDirty == true);
            Assert.IsTrue(exemption1.IsStartDateDirty == true);
            Assert.IsTrue(exemption1.IsEndDateDirty == true);
            Assert.IsTrue(exemption1.IsCreateDateDirty == true);
            Assert.IsTrue(exemption1.IsUpdateDateDirty == true);

            client.SaveBillSoftExemption(exemption1);

            // retrieve the updated exmption from the DB
            BillSoftExemption exemption2;
            client.GetBillSoftExemption(exemption1.UniqueId, out exemption2);
            Console.WriteLine("After updating values");
            Console.WriteLine("exemption2.StartDate={0}", exemption2.StartDate);
            Console.WriteLine("exemption2.EndDate={0}", exemption2.EndDate);
            Console.WriteLine("exemption2.CreateDate={0}", exemption2.CreateDate);
            Console.WriteLine("exemption2.UpdateDate={0}", exemption2.UpdateDate);
            Assert.IsTrue(exemption2.AccountId == 111333);
            Assert.IsTrue(exemption2.ApplyToAccountAndDescendents == true);
            Assert.IsTrue(exemption2.CertificateId == "abcdefg");
            Assert.IsTrue(exemption2.PermanentLocationCode == 777);
            Assert.IsTrue(exemption2.TaxType == 45);
            Assert.IsTrue(exemption2.TaxLevel == DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County);
            Assert.IsTrue(exemption2.StartDate == jan_1_2012);
            Assert.IsTrue(exemption2.EndDate == jan_1_2013);
            Assert.IsTrue(exemption2.UpdateDate > dateTimeNow);

            // Delete the exeption from the DB
            client.DeleteBillSoftExemption(exemption2.UniqueId);

            // There should be zero exemption now, so check it
            // Delete all rows from t_tax_billsoft_exemptions
            MTList<BillSoftExemption> exemptions = new MTList<BillSoftExemption>();
            client.GetBillSoftExemptions(ref exemptions);
            List<BillSoftExemption> tmpBillSoftExemptions = exemptions.Items;
            Console.WriteLine("tmpBillSoftExemptions.Count={0}", tmpBillSoftExemptions.Count);
            Assert.IsTrue(tmpBillSoftExemptions.Count == 0);

        }


        [TestMethod]
        [TestCategory("AttemptToUpdateExemptionUniqueId")]
        public void AttemptToUpdateExemptionUniqueId()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            // create a new exemption
            BillSoftExemption exemption1;
            client.CreateBillSoftExemption(111222, false, out exemption1);
            Console.WriteLine("UniqueId={0}, AccountId={1}",
                exemption1.UniqueId,
                exemption1.AccountId);
            Assert.IsTrue(exemption1.AccountId == 111222);
            Assert.IsTrue(exemption1.ApplyToAccountAndDescendents == false);

            // update the contents of the exemption and store it in the DB
            int realUniqueId = exemption1.UniqueId;
            exemption1.UniqueId = 7777777;
            exemption1.AccountId = 111333;

            try
            {
                // Exception should be thrown because client attempted to change uniqueId
                client.SaveBillSoftExemption(exemption1);
                Assert.Fail("should have thrown an exception because client changed uniqueId");
            }
            catch (Exception e)
            {
                Console.WriteLine("Received expected exception: {0}", e.Message);
            }

            // retrieve the non-updated exemption from the DB.  
            BillSoftExemption exemption2;
            client.GetBillSoftExemption(realUniqueId, out exemption2);
            Assert.IsTrue(exemption2.AccountId == 111222);

            client.DeleteBillSoftExemption(exemption2.UniqueId);
        }

        [TestMethod]
        [TestCategory("DeleteNonExistentExemption")]
        public void DeleteNonExistentExemption()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                // Exception should be thrown because client attempted to delete non-existent exemption
                client.DeleteBillSoftExemption(111222333);
                Assert.Fail("should have thrown an exception because client deleted non-existent exemption");
            }
            catch (Exception e)
            {
                Console.WriteLine("Received expected exception: {0}", e.Message);
            }
        }

        [TestMethod]
        [TestCategory("AddExemptionsAndChangeOne")]
        public void AddExemptionsAndChangeOne()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            DateTime jan_1_2012 = new DateTime(2012, 1, 1);
            DateTime jan_1_2013 = new DateTime(2013, 1, 1);

            int exemption8UniqueId = 0;

            for (int i = 1; i <= 10; i++)
            {
                // create a new exemption
                BillSoftExemption exemption;
                client.CreateBillSoftExemption(i, false, out exemption);
                Console.WriteLine("accountId={0}, uniqueId={1}",
                    exemption.AccountId, exemption.UniqueId);
                Assert.IsTrue(exemption.AccountId == i);
                Assert.IsTrue(exemption.ApplyToAccountAndDescendents == false);
                if (i == 8)
                {
                    exemption8UniqueId = exemption.UniqueId;
                }

                // update the contents of the exemption and store it in the DB
                exemption.ApplyToAccountAndDescendents = true;
                exemption.CertificateId = i.ToString();
                exemption.PermanentLocationCode = i;
                exemption.TaxType = i;
                exemption.TaxLevel = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County;
                exemption.StartDate = jan_1_2012;
                exemption.EndDate = jan_1_2013;
                client.SaveBillSoftExemption(exemption);
            }

            // retrieve the updated exmption from the DB
            BillSoftExemption exemption8;
            client.GetBillSoftExemption(exemption8UniqueId, out exemption8);
            Assert.IsTrue(exemption8.AccountId == 8);
            Assert.IsTrue(exemption8.ApplyToAccountAndDescendents == true);
            Assert.IsTrue(exemption8.CertificateId == "8");
            Assert.IsTrue(exemption8.PermanentLocationCode == 8);
            Assert.IsTrue(exemption8.TaxType == 8);
            Assert.IsTrue(exemption8.TaxLevel == DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County);
            Assert.IsTrue(exemption8.StartDate == jan_1_2012);
            Assert.IsTrue(exemption8.EndDate == jan_1_2013);

            // Delete the exeption from the DB
            client.DeleteBillSoftExemption(exemption8.UniqueId);

            // Delete all rows from t_tax_billsoft_exemptions
            MTList<BillSoftExemption> exemptionsToDelete = new MTList<BillSoftExemption>();
            client.GetBillSoftExemptions(ref exemptionsToDelete);
            List<BillSoftExemption> tmpBillSoftExemptionsToDelete = exemptionsToDelete.Items;
            Console.WriteLine("tmpBillSoftExemptionsToDelete.Count={0}", tmpBillSoftExemptionsToDelete.Count);
            Assert.IsTrue(tmpBillSoftExemptionsToDelete.Count == 9);

            foreach (var tmpBillSoftExemption in tmpBillSoftExemptionsToDelete)
            {
                client.DeleteBillSoftExemption(tmpBillSoftExemption.UniqueId);
            }
        }

        [TestMethod]
        [TestCategory("SortExemptions")]
        public void SortExemptions()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            DateTime jan_1_2012 = new DateTime(2012, 1, 1);
            DateTime jan_1_2013 = new DateTime(2013, 1, 1);

            int exemption3UniqueId = 0;

            for (int i = 1; i <= 5; i++)
            {
                // create a new exemption
                BillSoftExemption exemption;
                client.CreateBillSoftExemption(i, false, out exemption);
                Console.WriteLine("accountId={0}, uniqueId={1}",
                    exemption.AccountId, exemption.UniqueId);
                Assert.IsTrue(exemption.AccountId == i);
                Assert.IsTrue(exemption.ApplyToAccountAndDescendents == false);
                if (i == 3)
                {
                    exemption3UniqueId = exemption.UniqueId;
                }

                // update the contents of the exemption and store it in the DB
                exemption.ApplyToAccountAndDescendents = true;
                exemption.CertificateId = i.ToString();
                exemption.PermanentLocationCode = i;
                exemption.TaxType = i;
                exemption.TaxLevel = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County;
                exemption.StartDate = jan_1_2012;
                exemption.EndDate = jan_1_2013;
                client.SaveBillSoftExemption(exemption);

                // Sleep so that create date will change slightly
                System.Threading.Thread.Sleep(2000);
            }

            // retrieve the updated exmption from the DB
            BillSoftExemption exemption3;
            client.GetBillSoftExemption(exemption3UniqueId, out exemption3);
            client.SaveBillSoftExemption(exemption3);

            MTList<BillSoftExemption> listOfExemptions = new MTList<BillSoftExemption>();
            listOfExemptions.SortCriteria.Add(new SortCriteria("UpdateDate", SortType.Ascending));

            client.GetBillSoftExemptions(ref listOfExemptions);
            List<BillSoftExemption> tmpListOfExemptions = listOfExemptions.Items;

            foreach (var tmpExemption in tmpListOfExemptions)
            {
                Console.WriteLine("tmpExemption.AccountId={0}, tmpExemption.UpdateDate={1}", tmpExemption.AccountId, tmpExemption.UpdateDate);
            }

            if ((tmpListOfExemptions[0].AccountId == 1) &&
              (tmpListOfExemptions[1].AccountId == 2) &&
              (tmpListOfExemptions[2].AccountId == 4) &&
              (tmpListOfExemptions[3].AccountId == 5) &&
              (tmpListOfExemptions[4].AccountId == 3))
            {
                Console.WriteLine("received expected order");
            }
            else
            {
                Assert.Fail("Invalid sorting by UpdateDate");
            }

            // Retrieve exemptions associated with a specific permanent location code
            MTList<BillSoftExemption> exemptionsWithPCode4 = new MTList<BillSoftExemption>();
            exemptionsWithPCode4.Filters.Add(new MTFilterElement("PermanentLocationCode", MTFilterElement.OperationType.Equal, 4));
            client.GetBillSoftExemptions(ref exemptionsWithPCode4);
            tmpListOfExemptions = exemptionsWithPCode4.Items;
            Assert.AreEqual(tmpListOfExemptions.Count, 1);
            Assert.AreEqual(tmpListOfExemptions[0].AccountId, 4);
            foreach (var tmpExemption in tmpListOfExemptions)
            {
                Console.WriteLine("XXXXX tmpExemption.AccountId={0}, tmpExemption.UpdateDate={1}", tmpExemption.AccountId, tmpExemption.UpdateDate);
            }

            // Delete all rows from t_tax_billsoft_exemptions
            MTList<BillSoftExemption> exemptionsToDelete = new MTList<BillSoftExemption>();
            client.GetBillSoftExemptions(ref exemptionsToDelete);
            List<BillSoftExemption> tmpBillSoftExemptionsToDelete = exemptionsToDelete.Items;
            Console.WriteLine("tmpBillSoftExemptionsToDelete.Count={0}", tmpBillSoftExemptionsToDelete.Count);
            Assert.IsTrue(tmpBillSoftExemptionsToDelete.Count == 5);

            foreach (var tmpBillSoftExemption in tmpBillSoftExemptionsToDelete)
            {
                client.DeleteBillSoftExemption(tmpBillSoftExemption.UniqueId);
            }
        }

#if true
        [TestMethod]
        [TestCategory("TestBasicOverrideFunctionality")]
        public void TestBasicOverrideFunctionality()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            // create a new override
            BillSoftOverride override1;
            client.CreateBillSoftOverride(111222, false, out override1);
            Console.WriteLine("UniqueId={0}, AccountId={1}",
                override1.UniqueId,
                override1.AccountId);
            Assert.IsTrue(override1.AccountId == 111222);
            Assert.IsTrue(override1.ApplyToAccountAndDescendents == false);
            Console.WriteLine("override1.EffectiveDate={0}", override1.EffectiveDate);
            Console.WriteLine("override1.CreateDate={0}", override1.CreateDate);
            Console.WriteLine("override1.UpdateDate={0}", override1.UpdateDate);

            DateTime dateTimeNow = DateTime.Now;

            // Sleep so that update date will change slightly
            System.Threading.Thread.Sleep(2000);

            // update the contents of the override and store it in the DB
            DateTime jan_1_2012 = new DateTime(2012, 1, 1);
            DateTime jan_1_2013 = new DateTime(2013, 1, 1);
            override1.AccountId = 111333;
            override1.ApplyToAccountAndDescendents = true;
            override1.PermanentLocationCode = 777;
            override1.TaxType = 45;
            override1.TaxLevel = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County;
            override1.Scope = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.State;
            override1.EffectiveDate = jan_1_2013;
            override1.ExemptLevel = true;
            override1.MaximumBase = 78.33M;
            override1.ReplaceTaxLevel = false;
            override1.ExcessTaxRate = 0.33M;
            override1.TaxRate = 0.22M;


            client.SaveBillSoftOverride(override1);

            // retrieve the updated exmption from the DB
            BillSoftOverride override2;
            client.GetBillSoftOverride(override1.UniqueId, out override2);
            Console.WriteLine("After updating values");
            Console.WriteLine("override2.EffectiveDate={0}", override2.EffectiveDate);
            Console.WriteLine("override2.CreateDate={0}", override2.CreateDate);
            Console.WriteLine("override2.UpdateDate={0}", override2.UpdateDate);
            Assert.IsTrue(override2.AccountId == 111333);
            Assert.IsTrue(override2.ApplyToAccountAndDescendents == true);
            Assert.IsTrue(override2.PermanentLocationCode == 777);
            Assert.IsTrue(override2.TaxType == 45);
            Assert.IsTrue(override2.TaxLevel == DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County);
            Assert.IsTrue(override2.EffectiveDate == jan_1_2013);
            Assert.IsTrue(override2.UpdateDate > dateTimeNow);
            Assert.IsTrue(override2.ExemptLevel == true);
            Assert.IsTrue(override2.MaximumBase == 78.33M);
            Assert.IsTrue(override2.ReplaceTaxLevel == false);
            Assert.IsTrue(override2.ExcessTaxRate == 0.33M);
            Assert.IsTrue(override2.TaxRate == 0.22M);

            // Delete the exeption from the DB
            client.DeleteBillSoftOverride(override2.UniqueId);

            // There should be zero override now, so check it
            // Delete all rows from t_tax_billsoft_overrides
            MTList<BillSoftOverride> overrides = new MTList<BillSoftOverride>();
            client.GetBillSoftOverrides(ref overrides);
            List<BillSoftOverride> tmpBillSoftOverrides = overrides.Items;
            Console.WriteLine("tmpBillSoftOverrides.Count={0}", tmpBillSoftOverrides.Count);
            Assert.IsTrue(tmpBillSoftOverrides.Count == 0);
        }

        [TestMethod]
        [TestCategory("AttemptToUpdateOverrideUniqueId")]
        public void AttemptToUpdateOverrideUniqueId()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            // create a new override
            BillSoftOverride override1;
            client.CreateBillSoftOverride(111222, false, out override1);
            Console.WriteLine("UniqueId={0}, AccountId={1}",
                override1.UniqueId,
                override1.AccountId);
            Assert.IsTrue(override1.AccountId == 111222);
            Assert.IsTrue(override1.ApplyToAccountAndDescendents == false);

            // update the contents of the override and store it in the DB
            int realUniqueId = override1.UniqueId;
            override1.UniqueId = 7777777;
            override1.AccountId = 111333;

            try
            {
                // Exception should be thrown because client attempted to change uniqueId
                client.SaveBillSoftOverride(override1);
                Assert.Fail("should have thrown an exception because client changed uniqueId");
            }
            catch (Exception e)
            {
                Console.WriteLine("Received expected exception: {0}", e.Message);
            }

            // retrieve the non-updated override from the DB.  
            BillSoftOverride override2;
            client.GetBillSoftOverride(realUniqueId, out override2);
            Assert.IsTrue(override2.AccountId == 111222);

            client.DeleteBillSoftOverride(override2.UniqueId);
        }

        [TestMethod]
        [TestCategory("DeleteNonExistentOverride")]
        public void DeleteNonExistentOverride()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                // Exception should be thrown because client attempted to delete non-existent override
                client.DeleteBillSoftOverride(111222333);
                Assert.Fail("should have thrown an exception because client deleted non-existent override");
            }
            catch (Exception e)
            {
                Console.WriteLine("Received expected exception: {0}", e.Message);
            }
        }
#endif

#if true
        [TestMethod]
        [TestCategory("AddOverridesAndChangeOne")]
        public void AddOverridesAndChangeOne()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            DateTime jan_1_2012 = new DateTime(2012, 1, 1);
            DateTime jan_1_2013 = new DateTime(2013, 1, 1);

            int override8UniqueId = 0;

            for (int i = 1; i <= 10; i++)
            {
                // create a new myOverride
                BillSoftOverride myOverride;
                client.CreateBillSoftOverride(i, false, out myOverride);
                Console.WriteLine("accountId={0}, uniqueId={1}",
                    myOverride.AccountId, myOverride.UniqueId);
                Assert.IsTrue(myOverride.AccountId == i);
                Assert.IsTrue(myOverride.ApplyToAccountAndDescendents == false);
                if (i == 8)
                {
                    override8UniqueId = myOverride.UniqueId;
                }

                // update the contents of the myOverride and store it in the DB
                myOverride.ApplyToAccountAndDescendents = true;
                myOverride.PermanentLocationCode = i;
                myOverride.TaxType = i;
                myOverride.TaxLevel = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County;
                myOverride.EffectiveDate = jan_1_2012;
                myOverride.ExemptLevel = true;
                myOverride.MaximumBase = new Decimal(i * 0.01);
                myOverride.ReplaceTaxLevel = false;
                myOverride.ExcessTaxRate = new Decimal(i * 0.01);
                myOverride.TaxRate = new Decimal(i * 0.01);
                client.SaveBillSoftOverride(myOverride);
            }

            // retrieve the updated exmption from the DB
            BillSoftOverride override8;
            client.GetBillSoftOverride(override8UniqueId, out override8);
            Assert.IsTrue(override8.AccountId == 8);
            Assert.IsTrue(override8.ApplyToAccountAndDescendents == true);
            Assert.IsTrue(override8.PermanentLocationCode == 8);
            Assert.IsTrue(override8.TaxType == 8);
            Assert.IsTrue(override8.TaxLevel == DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County);
            Assert.IsTrue(override8.EffectiveDate == jan_1_2012);

            // Delete the exeption from the DB
            client.DeleteBillSoftOverride(override8.UniqueId);

            // Delete all rows from t_tax_billsoft_overrides
            MTList<BillSoftOverride> overridesToDelete = new MTList<BillSoftOverride>();
            client.GetBillSoftOverrides(ref overridesToDelete);
            List<BillSoftOverride> tmpBillSoftOverridesToDelete = overridesToDelete.Items;
            Console.WriteLine("tmpBillSoftOverridesToDelete.Count={0}", tmpBillSoftOverridesToDelete.Count);
            Assert.IsTrue(tmpBillSoftOverridesToDelete.Count == 9);

            foreach (var tmpBillSoftOverride in tmpBillSoftOverridesToDelete)
            {
                client.DeleteBillSoftOverride(tmpBillSoftOverride.UniqueId);
            }

        }
#endif

        [TestMethod]
        [TestCategory("SortOverrides")]
        public void SortOverrides()
        {
            TaxServiceClient client = new TaxServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            DateTime jan_1_2012 = new DateTime(2012, 1, 1);
            DateTime jan_1_2013 = new DateTime(2013, 1, 1);

            int myOverride3UniqueId = 0;

            for (int i = 1; i <= 5; i++)
            {
                // create a new myOverride
                BillSoftOverride myOverride;
                client.CreateBillSoftOverride(i, false, out myOverride);
                Console.WriteLine("accountId={0}, uniqueId={1}",
                    myOverride.AccountId, myOverride.UniqueId);
                Assert.IsTrue(myOverride.AccountId == i);
                Assert.IsTrue(myOverride.ApplyToAccountAndDescendents == false);
                if (i == 3)
                {
                    myOverride3UniqueId = myOverride.UniqueId;
                }

                // update the contents of the myOverride and store it in the DB
                myOverride.ApplyToAccountAndDescendents = true;
                myOverride.PermanentLocationCode = i;
                myOverride.TaxType = i;
                myOverride.TaxLevel = DomainModel.Enums.Tax.Metratech_com_tax.BillSoftTaxLevel.County;
                client.SaveBillSoftOverride(myOverride);

                // Sleep so that create date will change slightly
                System.Threading.Thread.Sleep(2000);
            }

            // retrieve the updated exmption from the DB
            BillSoftOverride myOverride3;
            client.GetBillSoftOverride(myOverride3UniqueId, out myOverride3);
            client.SaveBillSoftOverride(myOverride3);

            MTList<BillSoftOverride> listOfOverrides = new MTList<BillSoftOverride>();
            listOfOverrides.SortCriteria.Add(new SortCriteria("UpdateDate", SortType.Ascending));

            client.GetBillSoftOverrides(ref listOfOverrides);
            List<BillSoftOverride> tmpListOfOverrides = listOfOverrides.Items;

            foreach (var tmpOverride in tmpListOfOverrides)
            {
                Console.WriteLine("tmpOverride.AccountId={0}, tmpOverride.UpdateDate={1}", tmpOverride.AccountId, tmpOverride.UpdateDate);
            }

            if ((tmpListOfOverrides[0].AccountId == 1) &&
              (tmpListOfOverrides[1].AccountId == 2) &&
              (tmpListOfOverrides[2].AccountId == 4) &&
              (tmpListOfOverrides[3].AccountId == 5) &&
              (tmpListOfOverrides[4].AccountId == 3))
            {
                Console.WriteLine("received expected order");
            }
            else
            {
                Assert.Fail("Invalid sorting by UpdateDate");
            }

            // Delete all rows from t_tax_billsoft_myOverrides
            MTList<BillSoftOverride> myOverridesToDelete = new MTList<BillSoftOverride>();
            client.GetBillSoftOverrides(ref myOverridesToDelete);
            List<BillSoftOverride> tmpBillSoftOverridesToDelete = myOverridesToDelete.Items;
            Console.WriteLine("tmpBillSoftOverridesToDelete.Count={0}", tmpBillSoftOverridesToDelete.Count);
            Assert.IsTrue(tmpBillSoftOverridesToDelete.Count == 5);

            foreach (var tmpBillSoftOverride in tmpBillSoftOverridesToDelete)
            {
                client.DeleteBillSoftOverride(tmpBillSoftOverride.UniqueId);
            }
        }

        [TestMethod]
        [TestCategory("RetrieveExemptionsWithPermission")]
        public void RetrieveExemptionsWithPermission()
        {
            IMTLoginContext loginContext = new MTLoginContextClass();
            MTSessionContext loginSessionContext = loginContext.Login("su", "system_user", "su123");
            IMTSecurity securityObject = new MTSecurityClass();
            IMTAccountCatalog accountCatalog = new MTAccountCatalogClass();
            accountCatalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)loginSessionContext);

            MTYAAC userCsr1 = accountCatalog.GetAccountByName("csr1", "system_user", DateTime.Now);

            IMTYAAC csr1Account = securityObject.GetAccountByID((MTSessionContext)loginSessionContext, userCsr1.AccountID,
                                                                DateTime.Now);

            IMTCompositeCapability billSoftViewCapability =
                securityObject.GetCapabilityTypeByName("BillSoftViewCapability").CreateInstance();

            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).AddCapability(
                billSoftViewCapability);
            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).Save();

            try
            {
                TaxServiceClient client = new TaxServiceClient();
                client.ClientCredentials.UserName.UserName = "csr1";
                client.ClientCredentials.UserName.Password = "csr123";

                // Make sure we can read and write exemptions
                MTList<BillSoftExemption> listOfExemptions = new MTList<BillSoftExemption>();
                client.GetBillSoftExemptions(ref listOfExemptions);
                Console.WriteLine("numberOfExemptions={0}", listOfExemptions.Items.Count);
            }
            catch (Exception)
            {
                Assert.Fail("threw exception attempting to retrieve exemptions");
            }

            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).RemoveCapabilitiesOfType(
                securityObject.GetCapabilityTypeByName("BillSoftViewCapability").ID);
            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).Save();
        }

        [TestMethod]
        [TestCategory("RetrieveExemptionsWithoutPermission")]
        public void RetrieveExemptionsWithoutPermission()
        {
            IMTLoginContext loginContext = new MTLoginContextClass();
            MTSessionContext loginSessionContext = loginContext.Login("su", "system_user", "su123");
            IMTSecurity securityObject = new MTSecurityClass();
            IMTAccountCatalog accountCatalog = new MTAccountCatalogClass();
            accountCatalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)loginSessionContext);

            MTYAAC userCsr1 = accountCatalog.GetAccountByName("csr1", "system_user", DateTime.Now);

            IMTYAAC csr1Account = securityObject.GetAccountByID((MTSessionContext)loginSessionContext, userCsr1.AccountID,
                                                                DateTime.Now);

            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).RemoveCapabilitiesOfType(
                securityObject.GetCapabilityTypeByName("BillSoftViewCapability").ID);
            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).Save();

            try
            {
                TaxServiceClient client = new TaxServiceClient();
                client.ClientCredentials.UserName.UserName = "csr1";
                client.ClientCredentials.UserName.Password = "csr123";

                // Make sure we can read and write exemptions
                MTList<BillSoftExemption> listOfExemptions = new MTList<BillSoftExemption>();
                client.GetBillSoftExemptions(ref listOfExemptions);
                Assert.Fail("Retrieving exemptions should have failed because no BillSoftViewCapability");
            }
            catch (Exception)
            {
                Console.WriteLine("XXXXX threw exception attempting to retrieve exemptions");
            }

            
        }

        [TestMethod]
        [TestCategory("CreateExemptionWithPermission")]
        public void CreateExemptionWithPermission()
        {
            IMTLoginContext loginContext = new MTLoginContextClass();
            MTSessionContext loginSessionContext = loginContext.Login("su", "system_user", "su123");
            IMTSecurity securityObject = new MTSecurityClass();
            IMTAccountCatalog accountCatalog = new MTAccountCatalogClass();
            accountCatalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)loginSessionContext);

            MTYAAC userCsr1 = accountCatalog.GetAccountByName("csr1", "system_user", DateTime.Now);

            IMTYAAC csr1Account = securityObject.GetAccountByID((MTSessionContext)loginSessionContext, userCsr1.AccountID,
                                                                DateTime.Now);

            IMTCompositeCapability billSoftViewCapability =
                securityObject.GetCapabilityTypeByName("BillSoftManageCapability").CreateInstance();

            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).AddCapability(
                billSoftViewCapability);
            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).Save();
            try
            {
                TaxServiceClient client = new TaxServiceClient();
                client.ClientCredentials.UserName.UserName = "csr1";
                client.ClientCredentials.UserName.Password = "csr123";

                BillSoftExemption exemption1;
                client.CreateBillSoftExemption(111222, false, out exemption1);
                client.DeleteBillSoftExemption(exemption1.UniqueId);
                Console.WriteLine("PASSED: Successfully created/deleted exemption");
            }
            catch (Exception)
            {
                Assert.Fail("FAILED: threw exception attempting to create exemption");
            }

            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).RemoveCapabilitiesOfType(
                securityObject.GetCapabilityTypeByName("BillSoftManageCapability").ID);
            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).Save();
        }

        [TestMethod]
        [TestCategory("CreateExemptionWithoutPermission")]
        public void CreateExemptionWithoutPermission()
        {
            IMTLoginContext loginContext = new MTLoginContextClass();
            MTSessionContext loginSessionContext = loginContext.Login("su", "system_user", "su123");
            IMTSecurity securityObject = new MTSecurityClass();
            IMTAccountCatalog accountCatalog = new MTAccountCatalogClass();
            accountCatalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)loginSessionContext);

            MTYAAC userCsr1 = accountCatalog.GetAccountByName("csr1", "system_user", DateTime.Now);

            IMTYAAC csr1Account = securityObject.GetAccountByID((MTSessionContext)loginSessionContext, userCsr1.AccountID,
                                                                DateTime.Now);

            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).RemoveCapabilitiesOfType(
                securityObject.GetCapabilityTypeByName("BillSoftManageCapability").ID);
            csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).Save();

            try
            {
                TaxServiceClient client = new TaxServiceClient();
                client.ClientCredentials.UserName.UserName = "csr1";
                client.ClientCredentials.UserName.Password = "csr123";

                BillSoftExemption exemption1;
                client.CreateBillSoftExemption(111222, false, out exemption1);
                Assert.Fail("FAILED: Successfully created exemption without permission");
            }
            catch (Exception)
            {
                Console.WriteLine("PASSED: threw exception attempting to create exemption");
            }

            
        }




    }
}
