namespace MetraTech.Auth.Test
{
    using System;
    using System.Runtime.InteropServices;
    using System.Collections;
    using System.Transactions;

    using NUnit.Framework;
    using MetraTech.Interop.MTAuth;
    using ServerAccess = MetraTech.Interop.MTServerAccess;
    using MetraTech.Test;
    using MetraTech.Interop.GenericCollection;
    using YAAC = MetraTech.Interop.MTYAAC;
    using MetraTech.Localization;

    //
    // To run the this test fixture:
    // nunit-console /fixture:MetraTech.Accounts.Ownership.Tests /assembly:O:\debug\bin\MetraTech.Accounts.Ownership.Test.dll
    //
    [TestFixture]
    [ComVisible(false)]
    public class Tests
    {
        const string mTestDir = "t:\\Development\\Core\\MTAuth\\";

        /// <summary>
        /// Tests Creation of ownersip manager from YAAC object
        /// </summary>
        [Test]
        public void TestPathParameterLeafNode()
        {
            IMTSessionContext ctx = LoginAsSU();
            IMTSecurity pol = new MTSecurityClass();
            IMTCompositeCapability mah = pol.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance();
            mah.GetAtomicPathCapability().SetParameter("/-", 0);
            Assert.AreEqual("", mah.GetAtomicPathCapability().GetParameter().LeafNode);
            mah.GetAtomicPathCapability().SetParameter("/", 0);
            Assert.AreEqual("", mah.GetAtomicPathCapability().GetParameter().LeafNode);
            mah.GetAtomicPathCapability().SetParameter("/*", 0);
            Assert.AreEqual("", mah.GetAtomicPathCapability().GetParameter().LeafNode);
            mah.GetAtomicPathCapability().SetParameter("/123", 0);
            Assert.AreEqual("123", mah.GetAtomicPathCapability().GetParameter().LeafNode);
            mah.GetAtomicPathCapability().SetParameter("/123/124/125/*", 0);
            Assert.AreEqual("125", mah.GetAtomicPathCapability().GetParameter().LeafNode);
            mah.GetAtomicPathCapability().SetParameter("/123/124/126/-", 0);
            Assert.AreEqual("126", mah.GetAtomicPathCapability().GetParameter().LeafNode);
            mah.GetAtomicPathCapability().SetParameter("/123/124/126/", 0);
            Assert.AreEqual("126", mah.GetAtomicPathCapability().GetParameter().LeafNode);
            mah.GetAtomicPathCapability().SetParameter("/123/124/126", 0);
            Assert.AreEqual("126", mah.GetAtomicPathCapability().GetParameter().LeafNode);
        }

        [Test]
        public void TestAddStringCollectionCapability()
        {
            IMTSessionContext ctx = LoginAsSU();
            YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
            cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
            YAAC.IMTYAAC demoUser1 = cat.GetAccountByName("Admin", "system_user", MetraTime.Now);
            IMTSecurity pol = new MTSecurityClass();
            IMTYAAC demoUser = pol.GetAccountByID((MTSessionContext)ctx, demoUser1.AccountID, MetraTime.Now);

            MetraTech.Interop.MTAuth.IMTCollection parameters = (MetraTech.Interop.MTAuth.IMTCollection)(new MTCollectionClass());
            parameters.Add("testString1");
            parameters.Add("YetAnotherString");
            IMTCompositeCapability mah = pol.GetCapabilityTypeByName("Apply Adjustments").CreateInstance();
            mah.GetAtomicCollectionCapability().InitParams();
            MetraTech.Interop.MTAuth.IMTCollection p = mah.GetAtomicCollectionCapability().GetParameter();
            Assert.AreEqual(0, p.Count);

            //Now insert a parameter
            mah.GetAtomicCollectionCapability().SetParameter(parameters);
            Assert.AreEqual(2, mah.GetAtomicCollectionCapability().GetParameter().Count);
            Assert.AreEqual("testString1", mah.GetAtomicCollectionCapability().GetParameter()[1]);

            //Save it out to the DB.  Now when we call InitParams(), we should get the capability back.
            MTPrincipalPolicy activePol = demoUser.GetActivePolicy((MTSessionContext)ctx);
            activePol.RemoveCapabilityAt(1);
            int polCount = activePol.Capabilities.Count;
            activePol.AddCapability(mah);
            activePol.Save();
        }

        [Test]
        public void TestRetrieveStringCollectionCapability()
        {
            IMTSessionContext ctx = LoginAsSU();
            YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
            cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
            YAAC.IMTYAAC demoUser1 = cat.GetAccountByName("Admin", "system_user", MetraTime.Now);
            IMTSecurity pol = new MTSecurityClass();
            IMTYAAC demoUser = pol.GetAccountByID((MTSessionContext)ctx, demoUser1.AccountID, MetraTime.Now);
            MTPrincipalPolicy activePol = demoUser.GetActivePolicy((MTSessionContext)ctx);

            IMTCompositeCapability mah = pol.GetCapabilityTypeByName("Apply Adjustments").CreateInstance();
            mah.GetAtomicCollectionCapability().GetParameter().Add("testString1");
            ((IMTCompositeCapability)(activePol.Capabilities[1])).GetAtomicCollectionCapability().InitParams();
            IMTCompositeCapability dummyCap = (IMTCompositeCapability)(activePol.Capabilities[1]);
            int count = dummyCap.GetAtomicCollectionCapability().GetParameter().Count;
//            mah.GetAtomicCollectionCapability().SetParameter(parameters);
            MTStringCollectionCapability strCap = dummyCap.GetAtomicCollectionCapability();
            MTAtomicCapability dummyAtomicCap = (MTAtomicCapability)(dummyCap.GetAtomicCollectionCapability());
            Assert.IsFalse(mah.GetAtomicCollectionCapability().Implies(dummyAtomicCap));
            Assert.IsTrue(dummyAtomicCap.Implies((MTAtomicCapability)(mah.GetAtomicCollectionCapability())));
        }
        
        private IMTSessionContext LoginAsSU()
        {
            // sets the SU session context on the client
            IMTLoginContext loginContext = new MTLoginContextClass();
            ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
            sa.Initialize();
            ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
            string suName = accessData.UserName;
            string suPassword = accessData.Password;
            return loginContext.Login(suName, "system_user", suPassword);
        }

    }
}
