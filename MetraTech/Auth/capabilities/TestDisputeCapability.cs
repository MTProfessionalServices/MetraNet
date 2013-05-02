namespace MetraTech.Auth.Test
{
    using System;
    using System.Runtime.InteropServices;
    using System.Collections;
    using System.Transactions;

    using NUnit.Framework;
    using MetraTech.Interop.MTAuth;
    using MetraTech.Test;
    using MetraTech.Interop.GenericCollection;
    using MetraTech.Localization;
    using MetraTech.Auth.Capabilities;

    //
    // To run the this test fixture:
    // nunit-console /fixture:MetraTech.Accounts.Ownership.Tests /assembly:O:\debug\bin\MetraTech.Accounts.Ownership.Test.dll
    //
    [TestFixture]
    [ComVisible(false)]
    public class Tests
    {
        //        const string mTestDir = "t:\\Development\\Core\\MTAuth\\";

        /// <summary>
        /// Tests implies for CreateDisputesCapability
        /// </summary>
        [Test]
        public void TestCreateDisputesCapability()
        {
            IMTSecurity sec = new MTSecurityClass();
            IMTCompositeCapability createDispCap = sec.GetCapabilityTypeByName("Create Disputes").CreateInstance();
            IMTCompositeCapability applAdjCap = sec.GetCapabilityTypeByName("Apply Adjustments").CreateInstance();
            Assert.IsTrue(createDispCap.Implies(applAdjCap, false));
            Assert.IsTrue(createDispCap.Implies(createDispCap, true));
            IMTCompositeCapability randomCap = sec.GetCapabilityTypeByName("Delete Rates").CreateInstance();
            Assert.IsFalse(createDispCap.Implies(randomCap, true));
        }

        [Test]
        /// <summary>
        /// Tests implies for ManageDisputesCapability
        /// </summary>
        public void TestAddStringCollectionCapability()
        {
            IMTSecurity sec = new MTSecurityClass();
            IMTCompositeCapability manDispCap = sec.GetCapabilityTypeByName("Manage Disputes").CreateInstance();
            IMTCompositeCapability createDispCap = sec.GetCapabilityTypeByName("Create Disputes").CreateInstance();
            IMTCompositeCapability applAdjCap = sec.GetCapabilityTypeByName("Apply Adjustments").CreateInstance();
            Assert.IsTrue(manDispCap.Implies(applAdjCap, true));
            Assert.IsTrue(manDispCap.Implies(createDispCap, true));
            IMTCompositeCapability randomCap = sec.GetCapabilityTypeByName("Delete Rates").CreateInstance();
            Assert.IsFalse(createDispCap.Implies(randomCap, true));
        }
    }
 
}
