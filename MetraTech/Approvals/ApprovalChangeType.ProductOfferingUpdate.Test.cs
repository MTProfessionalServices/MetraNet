//using MetraTech.Security;
//using MetraTech.DomainModel.Common;
//using MetraTech.Core.Services.ClientProxies;
using System;
using System.Collections.Generic;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.ProductCatalog;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PC = MetraTech.Interop.MTProductCatalog;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.ProductOfferingUpdateTest /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
//

namespace MetraTech.Approvals.Test
{
    [TestClass]
    //[Ignore("Product Offering update tests not ready for prime time")]
    public class ProductOfferingUpdateTest
    {
        #region Setup/Teardown

        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
            SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
        }

        #endregion

        private static ProductOffering GetProductOffering(bool reset)
        {
            var po = new ProductOffering();
            var pos = new MTList<ProductOffering> {Filters = new List<MTBaseFilterElement>()};
            var filter = new MTFilterElement("name",
                                             MTFilterElement.OperationType.Equal,
                                             "Approvals Unit Test PO");
            pos.Filters.Add(filter);
            using (var client = new ProductOfferingServiceClient())
            {
                if (client.ClientCredentials != null)
                {
                    client.ClientCredentials.UserName.UserName = "su";
                    client.ClientCredentials.UserName.Password = "su123";
                }

                client.GetProductOfferings(ref pos);
            }
            if (pos.Items.Count <= 0)
            {
                using (var client = new ProductOfferingServiceClient())
                {
                    if (client.ClientCredentials != null)
                    {
                        client.ClientCredentials.UserName.UserName = "su";
                        client.ClientCredentials.UserName.Password = "su123";
                    }

                    po.Name = "Approvals Unit Test PO";
                    po.AvailableTimeSpan = new ProdCatTimeSpan();
                    po.AvailableTimeSpan.EndDateType = ProdCatTimeSpan.MTPCDateType.Null;
                    po.AvailableTimeSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.Null;
                    po.EffectiveTimeSpan = new ProdCatTimeSpan();
                    po.EffectiveTimeSpan.EndDateType = ProdCatTimeSpan.MTPCDateType.Null;
                    po.EffectiveTimeSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.Null;
                    po.CanUserSubscribe = false;
                    po.CanUserUnsubscribe = false;
                    po.Currency = SystemCurrencies.USD;
                    po.Description = "Approvals Unit Test PO";
                    po.IsHidden = true;
                    client.SaveProductOffering(ref po);
                }
            }
            else
            {
                po = pos.Items[0];
                if (reset && po.AvailableTimeSpan.StartDateType != ProdCatTimeSpan.MTPCDateType.Null)
                {
                    using (var client = new ProductOfferingServiceClient())
                    {
                        if (client.ClientCredentials != null)
                        {
                            client.ClientCredentials.UserName.UserName = "su";
                            client.ClientCredentials.UserName.Password = "su123";
                        }

                        po.AvailableTimeSpan.StartDate = null;
                        po.AvailableTimeSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.Null;
                        client.SaveProductOffering(ref po);
                    }
                }
            }
            return po;
        }

        [TestMethod]
        [TestCategory("SubmitAndApproveProductOfferingUpdate")]
        public void SubmitAndApproveProductOfferingUpdate()
        {
            const string unitTestName = "SubmitAndApproveProductOfferingUpdate";

            //Create the change
            ProductOffering po = GetProductOffering(true);

            //Because we cannot have more than one pending change, before we start our test
            //need to clear out any pending changes for this item from previous or failed tests
            SharedTestCodeApprovals.DenyOrDismissAllChangesThatMatch("ProductOfferingUpdate",
                                                                     po.ProductOfferingId.ToString());

            po.AvailableTimeSpan.StartDate = DateTime.UtcNow;
            po.AvailableTimeSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;

            //Now serialize it
            var changeDetailsOut = new ChangeDetailsHelper();
            changeDetailsOut["productOffering"] = po;

            string buffer = changeDetailsOut.ToXml();

            //Create and submit this change
            //Turn on approvals for Product Offering update
            ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
            approvalsConfig["ProductOfferingUpdate"].Enabled = true;

            var approvalFramework = new ApprovalManagementImplementation(approvalsConfig, SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges());

            var pendingChangesBefore = new MTList<ChangeSummary>();
            approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

            var myNewChange = new Change
                                  {
                                      ChangeType = "ProductOfferingUpdate",
                                      UniqueItemId = po.ProductOfferingId.ToString(),
                                      ChangeDetailsBlob = buffer,
                                      ItemDisplayName = po.DisplayName + " " + po.ProductOfferingId,
                                      Comment = "Unit Test " + unitTestName + " on " + DateTime.Now
                                  };

            int myChangeId;
            approvalFramework.SubmitChange(myNewChange, out myChangeId);

            var po2 = GetProductOffering(false);
            Assert.AreEqual(po.ProductOfferingId, po2.ProductOfferingId,
                            "Expected product offering ids to be the same");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.Absolute, po.AvailableTimeSpan.StartDateType,
                            "Expected pending product offering to have absolute start date");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.NoDate, po2.AvailableTimeSpan.StartDateType,
                            "Expected active product offering to have no start date");

            var pendingChangesAfter = new MTList<ChangeSummary>();
            approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

            Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1,
                            "Expected pending changes count to be one more than before we submitted");

            string changeDetailsRetrieved;
            approvalFramework.GetChangeDetails(myChangeId, out changeDetailsRetrieved);

            //Login in as admin user and approve the change
            approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanApproveAccountUpdate();

            approvalFramework.ApproveChange(myChangeId, "Approved by approval framework unit test");

            po2 = GetProductOffering(false);
            Assert.AreEqual(po.ProductOfferingId, po2.ProductOfferingId,
                            "Expected product offering ids to be the same");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.Absolute, po.AvailableTimeSpan.StartDateType,
                            "Expected submitted product offering to have absolute start date");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.Absolute, po2.AvailableTimeSpan.StartDateType,
                            "Expected active product offering to have absolute start date");

            var pendingChangesAfterApproval = new MTList<ChangeSummary>();
            approvalFramework.GetPendingChangesSummary(ref pendingChangesAfterApproval);

            var changesAfterApproval = new MTList<ChangeSummary>();
            approvalFramework.GetChangesSummary(ref changesAfterApproval);

            //Find our change and make sure state is approved
            ChangeSummary change = null;
            bool foundIt = false;
            foreach (ChangeSummary t in changesAfterApproval.Items)
            {
                change = t;
                if (change.Id == myChangeId)
                {
                    foundIt = true;
                    break;
                }
            }

            Assert.IsTrue(foundIt, "Couldn't find our approved change with id " + myChangeId);
            Assert.AreEqual(change.CurrentState, ChangeState.Applied,
                            string.Format(
                                "Found the approved change with id {0} but the state was '{1}' and not 'Approved'",
                                myChangeId, change.CurrentState));
        }

        [TestMethod]
        [TestCategory("VerifyProductOfferingUpdateWorksIndependentOfApprovals")]
        public void VerifyProductOfferingUpdateWorksIndependentOfApprovals()
        {
            //Create the change

            using (var client = new ProductOfferingServiceClient())
            {
                if (client.ClientCredentials != null)
                {
                    client.ClientCredentials.UserName.UserName = "su";
                    client.ClientCredentials.UserName.Password = "su123";
                }

                var list = new MTList<ProductOffering>();
                client.GetProductOfferings(ref list);
                if (list.Items.Count > 0)
                {
                    ProductOffering po = list.Items[0];
                    //Apply the change
                    client.SaveProductOffering(ref po);
                }
            }
        }

        [TestMethod]
        [TestCategory("VerifyWeCanSerializeProductOffering")]
        public void VerifyWeCanSerializeProductOffering()
        {
            var po = new ProductOffering
                         {
                             Name = "My Name<>",
                             LocalizedDescriptions = new Dictionary<LanguageCode, string>()
                         };

            po.LocalizedDescriptions[LanguageCode.US] = "blah";
            po.AvailableTimeSpan = new ProdCatTimeSpan {EndDate = DateTime.UtcNow};

            //Now serialize it

            var changeDetailsOut = new ChangeDetailsHelper();
            changeDetailsOut["productOffering"] = po;

            string buffer = changeDetailsOut.ToXml();

            var changeDetailsIn = new ChangeDetailsHelper();
            changeDetailsIn.KnownTypes.Add(typeof (ProductOffering));
            changeDetailsIn.FromXml(buffer);

            object o = changeDetailsIn["productOffering"];
            var po2 = (ProductOffering) o;

            Assert.AreEqual(po.Name, po2.Name);
        }
    }
}