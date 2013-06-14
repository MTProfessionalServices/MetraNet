using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.TestCommon;

namespace MetraTech.Core.Services.UnitTests
{
    [TestClass]
    public class AccountTemplateServiceTests
    {
        private const string suName = "su";
        private const string suPassword = "su123";
        private static Account accCorp;
        private static Account accDep1;
        private static Account accDep2;
        private static Account accCore1;
        private static Account accCore2;
        private static int guid;

        /// <summary>
        /// Create new account template and check that new template is saved in database.
        /// </summary>
        [TestMethod, MTFunctionalTest]
        public void CreateAccountTemplate_Simple_Success()
        {
            AccountTemplateServiceClient tService = new AccountTemplateServiceClient();
            tService.ClientCredentials.UserName.UserName = suName;
            tService.ClientCredentials.UserName.Password = suPassword;
            Assert.IsNotNull(tService, "AccountTemplateServiceClient creation failed");
            AccountTemplate template = new AccountTemplate();
            template.AccountType = "CoreSubscriber";
            template.Description = "TestCreateAccountTemplate";
            template.Properties.Add("LDAP[ContactType=Bill_To].Address1", "Address 1");
            template.Properties.Add("Account.PayerID", accCorp._AccountID);
            AccountIdentifier acc = new AccountIdentifier((int)accCorp._AccountID);
            tService.SaveAccountTemplate(acc, "CoreSubscriber", DateTime.Today, ref template);
            AccountTemplate created;
            tService.GetTemplateDefForAccountType(acc, "CoreSubscriber", DateTime.Today, false, out created);
            Assert.AreNotEqual(created.ID, -1, "Template is not created");
        }

        /// <summary>
        /// Create new account template, update some template properties  and checks that changes are saved in database.
        /// </summary>
        [TestMethod, MTFunctionalTest]
        public void UpdateAccountTemplate_Simple_Success()
        {
            AccountTemplateServiceClient tService = new AccountTemplateServiceClient();
            tService.ClientCredentials.UserName.UserName = suName;
            tService.ClientCredentials.UserName.Password = suPassword;
            Assert.IsNotNull(tService, "AccountTemplateServiceClient creation failed");
            AccountTemplate template = new AccountTemplate();
            template.AccountType = "CoreSubscriber";
            template.Description = "TestUpdateAccountTemplate";
            template.Properties.Add("LDAP[ContactType=Bill_To].Address1", "Address 1");
            template.Properties.Add("Account.PayerID", accCorp._AccountID);
            AccountIdentifier acc = new AccountIdentifier((int)accDep1._AccountID);
            tService.SaveAccountTemplate(acc, "CoreSubscriber", DateTime.Today, ref template);

            AccountTemplate template2 = new AccountTemplate();
            tService.GetTemplateDefForAccountType(acc, "CoreSubscriber", DateTime.Today, false, out template2);
            template2.Properties["LDAP[ContactType=Bill_To].Address1"] = "Address updated";
            template2.Properties["Account.PayerID"] = accDep1._AccountID;
            tService.SaveAccountTemplate(acc, "CoreSubscriber", DateTime.Today, ref template2);

            AccountTemplate template3 = new AccountTemplate();
            tService.GetTemplateDefForAccountType(acc, "CoreSubscriber", DateTime.Today, false, out template3);
            Assert.AreEqual(template3.Properties["LDAP[ContactType=Bill_To].Address1"], "Address updated", "Address is not updated for template");
            Assert.AreEqual(template3.Properties["Account.PayerID"], accDep1._AccountID, "Payer is not updated for template");
        }

        /// <summary>
        /// Create new account template, delete this template and check that template deleted from database.
        /// </summary>
        [TestMethod, MTFunctionalTest]
        public void DeleteAccountTemplate_Simple_Success()
        {
            AccountTemplateServiceClient tService = new AccountTemplateServiceClient();
            tService.ClientCredentials.UserName.UserName = suName;
            tService.ClientCredentials.UserName.Password = suPassword;
            Assert.IsNotNull(tService, "AccountTemplateServiceClient creation failed");
            AccountTemplate template = new AccountTemplate();
            template.AccountType = "CoreSubscriber";
            template.Description = "TestUpdateAccountTemplate";
            template.Properties.Add("LDAP[ContactType=Bill_To].Address1", "Address 1");
            template.Properties.Add("Account.PayerID", accCorp._AccountID);
            AccountIdentifier acc = new AccountIdentifier((int)accDep2._AccountID);
            tService.SaveAccountTemplate(acc, "CoreSubscriber", DateTime.Today, ref template);
            tService.GetTemplateDefForAccountType(acc, "CoreSubscriber", DateTime.Today, false, out template);

            tService.DeleteAccountTemplate(acc, "CoreSubscriber", DateTime.Today);

            AccountTemplate deleted;
            tService.GetTemplateDefForAccountType(acc, "CoreSubscriber", DateTime.Today, false, out deleted);
            Assert.AreEqual(deleted.ID, -1, "Template is not deleted.");
        }

        /// <summary>
        /// Create new account template with subscription and check that new template is saved in database.
        /// Note: Any product offering should be created in database before run this test.
        /// </summary>
        [TestMethod, MTFunctionalTest]
        public void CreateAccountTemplate_WithSubscriptions_Success()
        {
            AccountTemplateServiceClient tService = new AccountTemplateServiceClient();
            tService.ClientCredentials.UserName.UserName = suName;
            tService.ClientCredentials.UserName.Password = suPassword;
            Assert.IsNotNull(tService, "AccountTemplateServiceClient creation failed");
            AccountTemplate template = new AccountTemplate();
            template.AccountType = "CoreSubscriber";
            template.Description = "TestCreateAccountTemplate";
            template.Properties.Add("LDAP[ContactType=Bill_To].Address1", "Address 1");
            template.Properties.Add("Account.PayerID", accCorp._AccountID);
            ProductOfferingServiceClient poService = new ProductOfferingServiceClient();
            poService.ClientCredentials.UserName.UserName = suName;
            poService.ClientCredentials.UserName.Password = suPassword;
            MTList<ProductOffering> POs = new MTList<ProductOffering>();
            poService.GetProductOfferings(ref POs);
            if (POs.Items.Count != 0)
            {
                ProductOffering po = POs.Items[0];
                AccountTemplateSubscription sub = new AccountTemplateSubscription();
                sub.ProductOfferingId = po.ProductOfferingId;
                template.Subscriptions.Add(sub);
            }
            AccountIdentifier acc = new AccountIdentifier((int)accCorp._AccountID);
            tService.SaveAccountTemplate(acc, "CoreSubscriber", DateTime.Today, ref template);
            AccountTemplate created;
            tService.GetTemplateDefForAccountType(acc, "CoreSubscriber", DateTime.Today, false, out created);
            Assert.AreNotEqual(created.ID, -1, "Template is not created");
            Assert.AreNotEqual(created.Subscriptions.Count, 1, "Subscription is not saved");
        }

        /// <summary>
        ///    Runs once before any of the tests are run.
        /// </summary>
        [ClassInitialize]
        public static void InitTests(TestContext testContext)
        {
            guid = Guid.NewGuid().GetHashCode();
            string userName = string.Format("{0}_{1}", "CorporateAccount", guid);
            accCorp = CreateAccount("CorporateAccount", "mt", 1, 0);
            accDep1 = CreateAccount("DepartmentAccount", "mt", accCorp._AccountID, 1);
            accDep2 = CreateAccount("DepartmentAccount", "mt", accCorp._AccountID, 2);
            accCore1 = CreateAccount("CoreSubscriber", "mt", accDep1._AccountID, 1);
            accCore2 = CreateAccount("CoreSubscriber", "mt", accDep2._AccountID, 2);
        }

        /// <summary>
        ///   Runs once after all the tests are run.
        /// </summary>
        [ClassCleanup]
        public static void Dispose()
        {
        }

        private static Account CreateAccount(string accountTypeName, string nameSpace, int? parentID, int num)
        {
            Account account = Account.CreateAccount(accountTypeName);
            string userName = string.Format("{0}_{1}_{2}", accountTypeName, guid, num);

            // Common properties
            account.AuthenticationType = MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.AuthenticationType.MetraNetInternal;
            if (String.IsNullOrEmpty(nameSpace))
            {
                nameSpace = "mt";
            }
            account.AncestorAccountID = parentID ?? 1;
            account.Password_ = "123";
            account.Name_Space = nameSpace;
            account.DayOfMonth = 1;
            account.AccountStatus = MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.AccountStatus.Active;

            account.UserName = userName;

            InternalView internalView = (InternalView)View.CreateView(@"metratech.com/internal");
            internalView.UsageCycleType = MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle.UsageCycleType.Monthly;
            internalView.Billable = true;
            internalView.Language = MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US;
            internalView.Currency = "USD";
            internalView.TimezoneID = MetraTech.DomainModel.Enums.Core.Global.TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

            account.AddView(internalView, "Internal");

            ContactView contactlView = (ContactView)View.CreateView(@"metratech.com/contact");
            contactlView.ContactType = MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.ContactType.Bill_To;
            contactlView.Address1 = "Address of " + userName;

            account.AddView(contactlView, "LDAP");

            AccountCreationClient client = null;

            client = new AccountCreationClient();
            client.ClientCredentials.UserName.UserName = suName;
            client.ClientCredentials.UserName.Password = suPassword;

            client.AddAccount(ref account, false);
            client.Close();
            return account;
        }
    }
}
