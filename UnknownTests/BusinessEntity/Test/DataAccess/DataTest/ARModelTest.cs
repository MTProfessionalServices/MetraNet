using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Transactions;
using AccountsReceivable.Account;
using AccountsReceivable.Allocation;
using AccountsReceivable.Debt;
using AccountsReceivable.Domain;
using AccountsReceivable.Payment;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.DomainModel.Enums.AccountsReceivable.Metratech_com_MetraAR;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using NHibernate;
using NHibernate.Criterion;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.DataTest.ARModelTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.DataTest
{
  
  [TestFixture]
  public class ARModelTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      DataTest.Initialize();
    }

    [Test]
    [Category("TestDemandForPaymentHistory")]
    public void TestDemandForPaymentHistory()
    {
      var demandForPayment = CreateDemandForPayment();
      demandForPayment.Save();

      demandForPayment.Status = DFPStatus.Open;
      demandForPayment.Save();
    }

    [Test]
    [Category("TestPaymentReceiptEnums")]
    public void TestPaymentReceiptEnums()
    {
      var paymentReceipt = CreatePaymentReceipt();
      paymentReceipt.PaymentType = PaymentReceiptType.Check;
      paymentReceipt.Currency = SystemCurrencies.CAD;
      paymentReceipt.Save();

      paymentReceipt = StandardRepository.Instance.LoadInstance<PaymentReceipt>(paymentReceipt.Id);
      Assert.AreEqual(PaymentReceiptType.Check, paymentReceipt.PaymentType);
      Assert.AreEqual(SystemCurrencies.CAD, paymentReceipt.Currency);
    }


    [Test]
    [Category("TestTransaction")]
    public void TestTransaction()
    {
      var account = CreateARAccount();
      account.Save();
      AccountNote accountNote = CreateAccountNote();

      try
      {
        using (var unitOfWorkScope = new UnitOfWorkScope(typeof(AccountNote).FullName))
        using (var transactionScope = new TransactionScope())
        {
          account.PhoneNumber = "555-555-5555";
          account.Save();
          accountNote.Save();
          throw new ApplicationException("TestTransaction");
          transactionScope.Complete();
        }
      }
      catch (Exception e)
      {
        Assert.AreEqual("TestTransaction", e.Message);
      }

      account = StandardRepository.Instance.LoadInstance<ARAccount>(account.Id);
      Assert.IsNotNull(account);
      Assert.AreNotEqual("555-555-5555", account.PhoneNumber);

      accountNote = StandardRepository.Instance.LoadInstance<AccountNote>(accountNote.Id);
      Assert.IsNull(accountNote);
    }


    [Test]
    [Category("TestUniqueIndexForRemittanceInstructionDetail")]
    public void TestUniqueIndexForRemittanceInstructionDetail()
    {
      var demandForPayment = CreateDemandForPayment();
      demandForPayment.Save();

      var remittanceInstructionDetail1 = CreateRemittanceInstructionDetail();
      remittanceInstructionDetail1.DemandForPayment = demandForPayment;

      remittanceInstructionDetail1.Save();

      var paymentDistribution = CreatePaymentDistribution();
      paymentDistribution.Save();

      var remittanceInstructionDetail2 = CreateRemittanceInstructionDetail();
      remittanceInstructionDetail2.PaymentDistribution = paymentDistribution;
      remittanceInstructionDetail2.Save();

      var remittanceInstructionDetail3 = CreateRemittanceInstructionDetail();
      remittanceInstructionDetail3.PaymentDistribution = paymentDistribution;
      try
      {
        remittanceInstructionDetail3.Save();
      }
      catch (UniqueKeyViolationException e)
      {
        Assert.IsTrue(
          e.InnerMessage.Contains(
            "Cannot insert duplicate key row in object 'dbo.t_be_ar_all_remittanceinstd' with unique index 'uix_pd_dfp'"));
      }
    }

    [Test]
    [Category("TestARAccount_LoadManagedBy")]
    public void TestARAccount_LoadManagedBy()
    {
      var parentAccount = CreateARAccount();
      parentAccount.Save();

      var childAccount = CreateARAccount();
      childAccount.ManagedBy = parentAccount;
      childAccount.Save();

      var grandChildAccount = CreateARAccount();
      grandChildAccount.ManagedBy = childAccount;
      grandChildAccount.Save();

      var loadParentAccount = childAccount.LoadManagedBy();
      Assert.IsNotNull(loadParentAccount);
      Assert.IsTrue(parentAccount.Equals(loadParentAccount));

      var loadChildAccount = grandChildAccount.LoadManagedBy();
      Assert.IsNotNull(loadChildAccount);
      Assert.IsTrue(childAccount.Equals(loadChildAccount));

      var loadNull = parentAccount.LoadManagedBy();
      Assert.IsNull(loadNull);
    }

    [Test]
    [Category("TestDFPSplitMerge_LoadParent")]
    public void TestDFPSplitMerge_LoadParent()
    {
      var parentDfp = CreateDemandForPayment();
      parentDfp.Save();
      var childDfp = CreateDemandForPayment();
      childDfp.Save();

      var dfpSplitMerge = new DFPSplitMerge();
      dfpSplitMerge.Parent = parentDfp;
      dfpSplitMerge.Child = childDfp;
      dfpSplitMerge.Save();

      var loadParentDfp = (DemandForPayment)dfpSplitMerge.LoadParent();
      Assert.IsNotNull(loadParentDfp);
      Assert.IsTrue(parentDfp.Equals(loadParentDfp));

      var loadChildDfp = (DemandForPayment)dfpSplitMerge.LoadChild();
      Assert.IsNotNull(loadChildDfp);
      Assert.IsTrue(childDfp.Equals(loadChildDfp));
    }

    [Test]
    [Category("TestTransactionAbort")]
    public void TestTransactionAbort()
    {
      var paymentReceipt = CreatePaymentReceipt();
      paymentReceipt.Save();

      var paymentDistribution = CreatePaymentDistribution();
      paymentDistribution.Save();

      var payingAccount = CreateARAccount();
      payingAccount.Save();

      var demandForPayment = CreateDemandForPayment();
      demandForPayment.PayingAccount = payingAccount;
      demandForPayment.Save();

      var remittanceInstruction = CreateRemittanceInstruction();
      remittanceInstruction.Save();

      var loadRemittanceInstruction =
        StandardRepository.Instance.LoadInstanceByBusinessKey
          <RemittanceInstruction, RemittanceInstructionBusinessKey>(remittanceInstruction.RemittanceInstructionBusinessKey);
      Assert.IsNotNull(loadRemittanceInstruction);

      var loadDemandForPayment = 
          StandardRepository.Instance.LoadInstance<DemandForPayment>(demandForPayment.Id);
      Assert.IsNotNull(loadDemandForPayment);
      loadDemandForPayment.Status = DFPStatus.Pending;

      var remittanceInstructionDetail = CreateRemittanceInstructionDetail();
      remittanceInstructionDetail.DemandForPayment = loadDemandForPayment;
      remittanceInstructionDetail.RemittanceInstruction = loadRemittanceInstruction;
      remittanceInstructionDetail.PaymentDistribution = paymentDistribution;

      using (var scope = new TransactionScope())
      {
        loadDemandForPayment.Save();
        remittanceInstructionDetail.Save();
        scope.Complete();
      }
    }

    [Test]
    [Category("TestLoadInstancesForSetRelationshipProperty")]
    public void TestLoadInstancesForSetRelationshipProperty()
    {
      var account = CreateARAccount();
      account.Save();

      var accountNote = CreateAccountNote();
      accountNote.ARAccount = account;
      accountNote.Save();

      var mtListAccountNotes = new MTList<AccountNote>();
      StandardRepository.Instance.LoadInstancesFor<ARAccount, AccountNote>(account, ref mtListAccountNotes);
      Assert.AreEqual(1, mtListAccountNotes.Items.Count);
      Assert.IsNotNull(mtListAccountNotes.Items[0].ARAccount);
      Assert.IsTrue(accountNote.Equals(mtListAccountNotes.Items[0]));

      var mtListARAccount = new MTList<ARAccount>();
      StandardRepository.Instance.LoadInstancesFor<AccountNote, ARAccount>(accountNote, ref mtListARAccount);
      Assert.AreEqual(1, mtListARAccount.Items.Count);
      Assert.IsTrue(account.Equals(mtListARAccount.Items[0]));
    }

    [Test]
    [Category("TestDateTimeEquality")]
    [Ignore]
    public void TestDateTimeEquality()
    {
      var invoice = CreateARInvoice();
      invoice.Save();

      var loadInvoice = StandardRepository.Instance.LoadInstance<ARInvoice>(invoice.Id);
      Assert.IsTrue(invoice.IssueDate.Equals(loadInvoice.IssueDate));
    }

    [Test]
    [Category("TestTotalRows")]
    public void TestTotalRows()
    {
      var accounts = new List<ARAccount>();
      for (int i = 0; i < 5; i++)
      {
        accounts.Add(CreateARAccount());
      }

      StandardRepository.Instance.SaveInstances(ref accounts);

      var mtListARAccount = new MTList<ARAccount>();
      StandardRepository.Instance.LoadInstances(ref mtListARAccount);
      Assert.IsTrue(mtListARAccount.TotalRows > 0);

      var accountNotes = new List<AccountNote>();
      for (int i = 0; i < 5; i++)
      {
        var accountNote = CreateAccountNote();
        accountNote.ARAccount = accounts[0];
        accountNotes.Add(accountNote);
      }

      var mtListAccountNotes = new MTList<AccountNote>();
      StandardRepository.Instance.SaveInstances(ref accountNotes);
      StandardRepository.Instance.LoadInstancesFor<ARAccount, AccountNote>(accounts[0].Id, ref mtListAccountNotes);
      Assert.IsTrue(mtListAccountNotes.TotalRows > 0);
    }

    [Test]
    [Category("TestAccountNoteUpdate")]
    public void TestAccountNoteUpdate()
    {
      var account = CreateARAccount();
      account.Save();

      var accountNote = CreateAccountNote();
      accountNote.ARAccount = account;
      accountNote.Save();

      var loadAccountNote =
        StandardRepository.Instance.LoadInstanceFor<ARAccount, AccountNote>(account.Id);
      Assert.IsNotNull(loadAccountNote);
      Assert.AreEqual(accountNote.Id, loadAccountNote.Id);
      Assert.IsTrue(accountNote.AccountNoteBusinessKey.Equals(loadAccountNote.AccountNoteBusinessKey));
      // The ARAccount property must be null
      Assert.IsNull(loadAccountNote.ARAccount);
      // The ARAccountId property must be not null and must equal the value of account.Id
      Assert.IsNotNull(loadAccountNote.ARAccountId);
      // The ARAccountBusinessKey property must be not null
      Assert.IsNotNull(loadAccountNote.ARAccountBusinessKey);
      // The ARAccountBusinessKey property must equal the value of account.ARAccountBusinessKey
      Assert.IsTrue(account.ARAccountBusinessKey.Equals(loadAccountNote.ARAccountBusinessKey));

      // Update loadAccountNote
      loadAccountNote.ActiveFollowUp = true;
   
      loadAccountNote.Save();

      // The foreign key to ARAccount should be valid
      // var loadAccount = StandardRepository.Instance.LoadInstanceFor<AccountNote, ARAccount>(loadAccountNote.Id);
      var loadAccount = (ARAccount)loadAccountNote.LoadARAccount();
      Assert.IsNotNull(loadAccount);
      Assert.IsTrue(account.ARAccountBusinessKey.Equals(loadAccount.ARAccountBusinessKey));

      // Update loadAccountNote again
      loadAccountNote.ArchivedFlag = false;
      loadAccountNote.Save();

      // The foreign key to ARAccount should still be valid
      loadAccount = (ARAccount)loadAccountNote.LoadARAccount();
      Assert.IsNotNull(loadAccount);
      Assert.IsTrue(account.ARAccountBusinessKey.Equals(loadAccount.ARAccountBusinessKey));

      // Clear the relationship
      loadAccountNote.ClearARAccount();
      loadAccountNote.Save();

      // Must not be able to retrieve the ARAccount
      loadAccount = (ARAccount)loadAccountNote.LoadARAccount();
      Assert.IsNull(loadAccount);
    }

    [Test]
    [Category("TestGetDatabaseProperties")]
    public void TestGetDatabaseProperties()
    {
      Entity entity = MetadataRepository.Instance.GetEntity(typeof (AccountNote).FullName);
      Assert.IsNotNull(entity);

      List<MetraTech.BusinessEntity.DataAccess.Metadata.Property> dbProperties = entity.GetDatabaseProperties();
      var property = dbProperties.Find(p => p.Name == "ARAccount");
      Assert.IsNotNull(property);
      Assert.AreEqual("System.Guid", property.TypeName);
      Assert.AreEqual("c_araccount_id", property.ColumnName.ToLower());
    }

    [Test]
    [Category("TestLoadInstanceFor_AccountNote_ARAccount")]
    public void TestLoadInstanceFor_AccountNote_ARAccount()
    {
      var account = CreateARAccount();
      account.Save();

      var accountNote = CreateAccountNote();
      accountNote.ARAccount = account;
      accountNote.Save();

      var loadAccountNote =
        StandardRepository.Instance.LoadInstanceFor<ARAccount, AccountNote>(account.Id);
      Assert.IsNotNull(loadAccountNote);
      Assert.AreEqual(accountNote.Id, loadAccountNote.Id);
      Assert.IsTrue(accountNote.AccountNoteBusinessKey.Equals(loadAccountNote.AccountNoteBusinessKey));


      var loadARAccount = (ARAccount)loadAccountNote.LoadARAccount();
      Assert.IsNotNull(loadARAccount);
      Assert.AreEqual(account.Id, loadARAccount.Id);
      Assert.IsTrue(account.ARAccountBusinessKey.Equals(loadARAccount.ARAccountBusinessKey));
    }

    [Test]
    [Category("TestLoadInstanceFor_DemandForPayment_PaymentDistributionAllocation")]
    public void TestLoadInstanceFor_DemandForPayment_PaymentDistributionAllocation()
    {
      var demandForPayment = CreateDemandForPayment();
      demandForPayment.Save();

      var paymentDistribution = CreatePaymentDistribution();
      paymentDistribution.Save();


      var paymentDistributionAllocation = CreatePaymentDistributionAllocation();
      paymentDistributionAllocation.DemandForPayment = demandForPayment;
      paymentDistributionAllocation.PaymentDistribution = paymentDistribution;

      paymentDistributionAllocation.Save();

      var loadDemandForPayment = (DemandForPayment)paymentDistributionAllocation.LoadDemandForPayment();
      //  StandardRepository.Instance.LoadInstanceFor<PaymentDistributionAllocation, DemandForPayment>(paymentDistributionAllocation.Id);
      Assert.IsNotNull(loadDemandForPayment);
      Assert.AreEqual(demandForPayment.Id, loadDemandForPayment.Id);
      Assert.IsTrue(demandForPayment.DemandForPaymentBusinessKey.Equals(loadDemandForPayment.DemandForPaymentBusinessKey));

      //var loadPaymentDistributionAllocation = (PaymentDistributionAllocation)demandForPayment.LoadPaymentDistributionAllocation();
      ////  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, PaymentDistributionAllocation>(demandForPayment.Id);
      //Assert.IsNotNull(loadPaymentDistributionAllocation);
      //Assert.AreEqual(paymentDistributionAllocation.Id, loadPaymentDistributionAllocation.Id);
      //Assert.IsTrue(paymentDistributionAllocation.PaymentDistributionAllocationBusinessKey.Equals(loadPaymentDistributionAllocation.PaymentDistributionAllocationBusinessKey));
      
    }

    [Test]
    [Category("TestRemittanceInstructionDetail")]
    public void TestRemittanceInstructionDetail()
    {
      var remittanceInstruction = CreateRemittanceInstruction();
      remittanceInstruction.Save();

      var demandForPayment = CreateDemandForPayment();
      demandForPayment.Save();

      var paymentDistribution = CreatePaymentDistribution();
      paymentDistribution.Save();

      var remittanceInstructionDetail = CreateRemittanceInstructionDetail();
      remittanceInstructionDetail.RemittanceInstruction = remittanceInstruction;
      remittanceInstructionDetail.DemandForPayment = demandForPayment;
      remittanceInstructionDetail.PaymentDistribution = paymentDistribution;

      remittanceInstructionDetail.Save();
      Assert.AreNotEqual(Guid.Empty, remittanceInstructionDetail.Id);
    }

    [Test]
    [Category("TestDomainProfile")]
    public void TestDomainProfile()
    {
      var domainProfile = CreateDomainProfile();
      domainProfile.Save();

      domainProfile.AllowPayments = false;
      domainProfile.AllowPDFGeneration = true;
      domainProfile.AllowSubLedger = false;
      domainProfile.AllowTransfers = true;

      domainProfile.Save();
    }

    [Test]
    [Category("TestARAccount")]
    public void TestARAccount()
    {
      
      // Create account1
      var account1 = CreateARAccount();
      account1.Save();
      Assert.AreNotEqual(Guid.Empty, account1.Id);

      // Load account1
      var loadAccount1 = StandardRepository.Instance.LoadInstance<ARAccount>(account1.Id);
      Assert.IsNotNull(loadAccount1);
      Assert.AreEqual(account1.Id, loadAccount1.Id);
      Assert.AreEqual(account1.ARAccountBusinessKey.ExternalAccountId,
                      loadAccount1.ARAccountBusinessKey.ExternalAccountId);
      Assert.IsNull(loadAccount1.ManagedBy);
      Assert.AreEqual(0, loadAccount1.ManagedAccounts.Count);
      Assert.AreEqual(account1.LastName, loadAccount1.LastName);

      // Create account2 with ManagedBy set to account1
      var account2 = CreateARAccount();
      account2.ManagedBy = account1;
      account2.Save();
      Assert.AreNotEqual(Guid.Empty, account2.Id);

      // Load account2
      var loadAccount2 = StandardRepository.Instance.LoadInstance<ARAccount>(account2.Id);
      Assert.AreEqual(account2.Id, loadAccount2.Id);
      Assert.AreEqual(account2.ARAccountBusinessKey.ExternalAccountId,
                      loadAccount2.ARAccountBusinessKey.ExternalAccountId);
      Assert.IsNull(loadAccount2.ManagedBy);

      // Create account3 with ManagedBy set to account1
      var account3 = CreateARAccount();
      account3.ManagedBy = account1;
      account3.Save();
      Assert.AreNotEqual(Guid.Empty, account3.Id);

      // Load account3
      var loadAccount3 = StandardRepository.Instance.LoadInstance<ARAccount>(account3.Id);
      Assert.AreEqual(account3.Id, loadAccount3.Id);
      Assert.AreEqual(account3.ARAccountBusinessKey.ExternalAccountId,
                      loadAccount3.ARAccountBusinessKey.ExternalAccountId);
      Assert.IsNull(loadAccount3.ManagedBy);

      // Load accounts managed by account1 (expect account2 and account3)
      var mtListAccounts = new MTList<ARAccount>();
      StandardRepository.Instance.LoadChildren(account1.Id, ref mtListAccounts, ARAccount.Relationship_ManagedBy);

      Assert.AreEqual(2, mtListAccounts.Items.Count);
      Assert.IsNotNull(mtListAccounts.Items.Find(a => a.Id == account2.Id));
      Assert.IsNotNull(mtListAccounts.Items.Find(a => a.Id == account3.Id));

      // Load account that manages account2
      ARAccount parentAccount = StandardRepository.Instance.LoadParent<ARAccount>(account2.Id);
      Assert.IsNotNull(parentAccount);
      Assert.AreEqual(account1.Id, parentAccount.Id);
      
      // Create AccountNote1 for account1
      var accountNote1 = CreateAccountNote();
      accountNote1.ARAccount = account1;

      // Create AccountNote2 for account1
      var accountNote2 = CreateAccountNote();
      accountNote2.ARAccount = account1;

      // Save AccountNotes
      var accountNotes = new List<AccountNote>() {accountNote1, accountNote2};
      StandardRepository.Instance.SaveInstances(ref accountNotes);

      // Load AccountNotes for account1
      var mtListAccountNotes = new MTList<AccountNote>();
      StandardRepository.Instance.LoadInstancesFor<ARAccount, AccountNote>(account1.Id, ref mtListAccountNotes);
      Assert.AreEqual(2, mtListAccountNotes.Items.Count);
      Assert.IsNotNull(mtListAccountNotes.Items.Find(a => a.Id == accountNote1.Id));
      Assert.IsNotNull(mtListAccountNotes.Items.Find(a => a.Id == accountNote2.Id));

      // Create DebtTreatmentQueue
      var debtTreatmentQueue = CreateDebtTreatmentQueue();
      debtTreatmentQueue.ARAccount = account1;
      debtTreatmentQueue.Save();

      // Load DebtTreatmentQueue for account1
      var loadDebtTreatmentQueue = (DebtTreatmentQueue)account1.LoadDebtTreatmentQueue();
      //  StandardRepository.Instance.LoadInstanceFor<ARAccount, DebtTreatmentQueue>(account1.Id);
      Assert.IsNotNull(loadDebtTreatmentQueue);
      Assert.AreEqual(debtTreatmentQueue.Id, loadDebtTreatmentQueue.Id);

      // Delete 
      StandardRepository.Instance.Delete(loadDebtTreatmentQueue);
      StandardRepository.Instance.Delete<ARAccount>(account1.Id);
    }

    [Test]
    [Category("TestARInvoice")]
    public void TestARInvoice()
    {
      var account = CreateARAccount();
      account.Save();

      var invoice = CreateARInvoice();
      invoice.ARAccount = account;
      invoice.Save();

      var loadInvoice = StandardRepository.Instance.LoadInstance<ARInvoice>(invoice.Id);
      Assert.IsNotNull(loadInvoice);
      Assert.AreEqual(invoice.ARInvoiceBusinessKey.InvoiceString, loadInvoice.ARInvoiceBusinessKey.InvoiceString);
    }

    [Test]
    [Category("TestBusinessKeyProperty")]
    public void TestBusinessKeyProperty()
    {
      var account = CreateARAccount();
      account.Save();

      var invoice = CreateARInvoice();
      invoice.ARAccount = account;
      invoice.Save();

      var loadInvoice = StandardRepository.Instance.LoadInstance<ARInvoice>(invoice.Id);
      Assert.IsNotNull(loadInvoice);
      Assert.IsTrue(invoice.ARInvoiceBusinessKey.Equals(loadInvoice.ARInvoiceBusinessKey));
      Assert.IsNotNull(loadInvoice.ARAccountBusinessKey);
      Assert.IsTrue(account.ARAccountBusinessKey.Equals(loadInvoice.ARAccountBusinessKey));
    }

    [Test]
    [Category("TestTransferDomains")]
    public void TestTransferDomains()
    {
      var root = CreateDomain();
      var child1 = CreateDomain();
      var child2  = CreateDomain();
      var child3 = CreateDomain();
      

      // Save
      var domains = new List<Domain>() {root, child1, child2, child3};
      StandardRepository.Instance.SaveInstances(ref domains);

      // Create the edge (root -> child1)
      var transferDomainEdge1 = new TransferDomain();
      transferDomainEdge1.Parent = root;
      transferDomainEdge1.Child = child1;

      // Create the edge (root -> child2)
      var transferDomainEdge2 = new TransferDomain();
      transferDomainEdge2.Parent = root;
      transferDomainEdge2.Child = child2;

      // Create the edge (Child1 -> child3)
      var transferDomainEdge3 = new TransferDomain();
      transferDomainEdge3.Parent = child1;
      transferDomainEdge3.Child = child3;

      // Create the edge (child2 -> child3)
      var transferDomainEdge4 = new TransferDomain();
      transferDomainEdge4.Parent = child2;
      transferDomainEdge4.Child = child3;

      // Save edges
      var transferDomains = new List<TransferDomain>() { transferDomainEdge1, transferDomainEdge2, transferDomainEdge3, transferDomainEdge4 };
      StandardRepository.Instance.SaveInstances(ref transferDomains);

      // Get Children for root (Expect child1, child2)
      var children = new MTList<Domain>();
      StandardRepository.Instance.LoadChildren(root.Id, ref children);
      Assert.AreEqual(2, children.Items.Count);
      Assert.IsNotNull(children.Items.Find(a => a.Id == child1.Id));
      Assert.IsNotNull(children.Items.Find(a => a.Id == child2.Id));

      // // Get Parents for child3 (Expect child1, child2)
      var parents = new MTList<Domain>();
      StandardRepository.Instance.LoadParents(child3.Id, ref parents);
      Assert.AreEqual(2, parents.Items.Count);
      Assert.IsNotNull(parents.Items.Find(a => a.Id == child1.Id));
      Assert.IsNotNull(parents.Items.Find(a => a.Id == child2.Id));

      // Load TransferDomain whose Parent = child1 and Child = child3
      TransferDomain transferDomain = StandardRepository.Instance.LoadEdge<TransferDomain>(child1.Id, child3.Id);
      Assert.IsNotNull(transferDomain);
      Assert.AreEqual(transferDomainEdge3.Id, transferDomain.Id);

      // Delete the TransferDomain
      StandardRepository.Instance.Delete(transferDomain);

      // Check that it has gone away
      transferDomain = StandardRepository.Instance.LoadEdge<TransferDomain>(child1.Id, child3.Id);
      Assert.IsNull(transferDomain);
   
    }

    [Test]
    [Category("TestMultipleRelationships")]
    public void TestMultipleRelationships()
    {
      var originalPayingAccount = CreateARAccount();
      var payingAccount = CreateARAccount();
      var accounts = new List<ARAccount>() {originalPayingAccount, payingAccount};
      StandardRepository.Instance.SaveInstances(ref accounts);

      var dfp1 = CreateDemandForPayment();
      dfp1.OriginalPayingAccount = originalPayingAccount;
      dfp1.PayingAccount = payingAccount;
      dfp1.Save();

      var loadDfp = StandardRepository.Instance.LoadInstance<DemandForPayment>(dfp1.Id);
      Assert.IsNotNull(loadDfp);
      Assert.AreEqual(dfp1.DemandForPaymentBusinessKey.InternalKey,
                      loadDfp.DemandForPaymentBusinessKey.InternalKey);

      var loadOriginalPayingAccount = dfp1.LoadOriginalPayingAccount();
        //StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>
        //  (dfp1.Id, DemandForPayment.Relationship_OriginalPayingAccount);
      Assert.AreEqual(loadOriginalPayingAccount.Id, originalPayingAccount.Id);

      var loadPayingAccount = dfp1.LoadPayingAccount();
        // StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>
        //  (dfp1.Id, DemandForPayment.Relationship_PayingAccount);
      Assert.AreEqual(loadPayingAccount.Id, payingAccount.Id);
    }

    [Test]
    [Category("TestDemandForPaymentSplitMerge")]
    public void TestDemandForPaymentSplitMerge()
    {
      using (var transactionScope = new TransactionScope())
      using (var unitOfWorkScope = new UnitOfWorkScope(typeof(DemandForPayment).FullName))
      {
        // Create, save root
        var dfpRoot = CreateDemandForPayment();
        dfpRoot.Save();

        // Create split1
        var dfpSplit1 = dfpRoot.Clone() as DemandForPayment;
        dfpSplit1.Status = DFPStatus.Open;
        
        // Create split2
        var dfpSplit2 = dfpRoot.Clone() as DemandForPayment;
        dfpSplit2.Status = DFPStatus.Open;

        // Create split3
        var dfpSplit3 = dfpRoot.Clone() as DemandForPayment;
        dfpSplit3.Status = DFPStatus.Open;

        // Update root
        dfpRoot.Status = DFPStatus.Closed;

        // Save root, split1, split2, split3
        var instances = new List<DemandForPayment>() {dfpRoot, dfpSplit1, dfpSplit2, dfpSplit3};
        StandardRepository.Instance.SaveInstances(ref instances);

        // Create edge for root -> split1
        var dfpSplitMerge1 = new DFPSplitMerge();
        dfpSplitMerge1.Parent = dfpRoot;
        dfpSplitMerge1.Child = dfpSplit1;

        // Create edge for root -> split2
        var dfpSplitMerge2 = new DFPSplitMerge();
        dfpSplitMerge2.Parent = dfpRoot;
        dfpSplitMerge2.Child = dfpSplit2;

        // Create edge for split1 -> split3
        var dfpSplitMerge3 = new DFPSplitMerge();
        dfpSplitMerge3.Parent = dfpSplit1;
        dfpSplitMerge3.Child = dfpSplit3;

        // Create edge for split2 -> split3
        var dfpSplitMerge4 = new DFPSplitMerge();
        dfpSplitMerge4.Parent = dfpSplit2;
        dfpSplitMerge4.Child = dfpSplit3;

        // Save edges
        var splitMerges = new List<DFPSplitMerge>() { dfpSplitMerge1, dfpSplitMerge2, dfpSplitMerge3, dfpSplitMerge4 };
        StandardRepository.Instance.SaveInstances(ref splitMerges);

        // Load children for dfpRoot
        var childDfps = new MTList<DemandForPayment>();
        StandardRepository.Instance.LoadChildren(dfpRoot.Id, ref childDfps);
        Assert.AreEqual(2, childDfps.Items.Count);
        Assert.IsNotNull(childDfps.Items.Find(a => a.Id == dfpSplit1.Id));
        Assert.IsNotNull(childDfps.Items.Find(a => a.Id == dfpSplit2.Id));

        // Load parents for dfpSplit3 (expect dfpSplit1 and dfpSplit2)
        var parentDfps = new MTList<DemandForPayment>();
        StandardRepository.Instance.LoadParents(dfpSplit3.Id, ref parentDfps);
        Assert.AreEqual(2, parentDfps.Items.Count);
        Assert.IsNotNull(parentDfps.Items.Find(a => a.Id == dfpSplit1.Id));
        Assert.IsNotNull(parentDfps.Items.Find(a => a.Id == dfpSplit2.Id));

        #region Test using ISession directly
        //ISession session = RepositoryAccess.Instance.GetSession(typeof (DFPSplitMerge).FullName);


        //var dfpSplitMergeChildren =
        //  DetachedCriteria.For<DFPSplitMerge>()
        //  .SetProjection(Projections.Distinct(Projections.Property("Child.Id")))
        //  .Add(Restrictions.Eq("Parent.Id", dfpRoot.Id));

        //var dfpChildrenCriteria =
        //  session.CreateCriteria<DemandForPayment>()
        //    .Add(Subqueries.PropertyIn("Id", dfpSplitMergeChildren))
        //    .List<DemandForPayment>();
        //Assert.AreEqual(2, dfpChildrenCriteria.Count);

       // var dfpChildrenCriteria1 =
       //   session.CreateCriteria<DemandForPayment>()
       //   .CreateAlias("ChildDFPSplitMerges", "children")
       //   .Add(Restrictions.Eq("children.Parent.Id", dfpRoot.Id))
       //   .List<DemandForPayment>();

        //var dfpSplitMergeParents =
        //   DetachedCriteria.For<DFPSplitMerge>()
        //   .SetProjection(Projections.Distinct(Projections.Property("Parent.Id")))
        //   .Add(Restrictions.Eq("Child.Id", dfpSplit3.Id));

        //var dfpParentsCriteria =
        //  session.CreateCriteria<DemandForPayment>()
        //    .Add(Subqueries.PropertyIn("Id", dfpSplitMergeParents))
        //    .List<DemandForPayment>();
        //Assert.AreEqual(2, dfpParentsCriteria.Count);
        #endregion

        transactionScope.Complete();
      }
   }

    [Test]
    [Category("TestDemandForPayment")]
    public void TestDemandForPayment()
    {
      var payingAccount = CreateARAccount();
      payingAccount.Save();

      var originalPayingAccount = CreateARAccount();
      originalPayingAccount.Save();

      var invoice = CreateARInvoice();
      invoice.Save();

      var demandForPayment = CreateDemandForPayment();
      demandForPayment.PayingAccount = payingAccount;
      demandForPayment.OriginalPayingAccount = originalPayingAccount;
      demandForPayment.ARInvoice = invoice;
      demandForPayment.Save();
      Assert.AreNotEqual(Guid.Empty, demandForPayment.Id);

      var loadDemandForPayment = StandardRepository.Instance.LoadInstance<DemandForPayment>(demandForPayment.Id);
      Assert.IsNotNull(loadDemandForPayment);
      Assert.IsNotNull(loadDemandForPayment.PayingAccountBusinessKey);
      Assert.IsNotNull(loadDemandForPayment.PayingAccountId);
      Assert.IsNotNull(loadDemandForPayment.OriginalPayingAccountBusinessKey);
      Assert.IsNotNull(loadDemandForPayment.OriginalPayingAccountId);
      Assert.IsNotNull(loadDemandForPayment.ARInvoiceBusinessKey);
      Assert.IsNotNull(loadDemandForPayment.ARInvoiceId);

      // Update loadDemandForPayment
      loadDemandForPayment.Status = DFPStatus.Closed;

      // Save
      StandardRepository.Instance.SaveInstance(ref loadDemandForPayment);

      // Ensure foreign keys are still valid
      var loadPayingAccount = (ARAccount)loadDemandForPayment.LoadPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_PayingAccount);
      Assert.IsNotNull(loadPayingAccount);

      var loadOriginalPayingAccount = (ARAccount)loadDemandForPayment.LoadOriginalPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_OriginalPayingAccount);
      Assert.IsNotNull(loadOriginalPayingAccount);

      var loadInvoice = (ARInvoice)loadDemandForPayment.LoadARInvoice();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARInvoice>(loadDemandForPayment.Id);
      Assert.IsNotNull(loadInvoice);

      #region Clear invoice
      loadDemandForPayment.ClearARInvoice();
      loadDemandForPayment.Save();

      loadInvoice = (ARInvoice)loadDemandForPayment.LoadARInvoice();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARInvoice>(loadDemandForPayment.Id);
      Assert.IsNull(loadInvoice);

      loadPayingAccount = (ARAccount)loadDemandForPayment.LoadPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_PayingAccount);
      Assert.IsNotNull(loadPayingAccount);

      loadOriginalPayingAccount = (ARAccount)loadDemandForPayment.LoadOriginalPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_OriginalPayingAccount);
      Assert.IsNotNull(loadOriginalPayingAccount);
      #endregion

      #region Clear PayingAccount
      loadDemandForPayment.ClearPayingAccount();
      loadDemandForPayment.Save();

      loadPayingAccount = (ARAccount)loadDemandForPayment.LoadPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_PayingAccount);
      Assert.IsNull(loadPayingAccount);

      loadOriginalPayingAccount = (ARAccount)loadDemandForPayment.LoadOriginalPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_OriginalPayingAccount);
      Assert.IsNotNull(loadOriginalPayingAccount);

      loadInvoice = (ARInvoice)loadDemandForPayment.LoadARInvoice();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARInvoice>(loadDemandForPayment.Id);
      Assert.IsNull(loadInvoice);

      #endregion

      #region Clear OriginalPayingAccount
      loadDemandForPayment.ClearOriginalPayingAccount();
      loadDemandForPayment.Save();

      loadPayingAccount = (ARAccount)loadDemandForPayment.LoadPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_PayingAccount);
      Assert.IsNull(loadPayingAccount);

      loadOriginalPayingAccount = (ARAccount)loadDemandForPayment.LoadOriginalPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_OriginalPayingAccount);
      Assert.IsNull(loadOriginalPayingAccount);

      loadInvoice = (ARInvoice)loadDemandForPayment.LoadARInvoice();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARInvoice>(loadDemandForPayment.Id);
      Assert.IsNull(loadInvoice);

      #endregion

      #region Add Invoice back

      loadDemandForPayment.ARInvoice = invoice;
      loadDemandForPayment.Save();

      loadInvoice = (ARInvoice)loadDemandForPayment.LoadARInvoice();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARInvoice>(loadDemandForPayment.Id);
      Assert.IsNotNull(loadInvoice);

      loadPayingAccount = (ARAccount)loadDemandForPayment.LoadPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_PayingAccount);
      Assert.IsNull(loadPayingAccount);

      loadOriginalPayingAccount = (ARAccount)loadDemandForPayment.LoadOriginalPayingAccount();
      //  StandardRepository.Instance.LoadInstanceFor<DemandForPayment, ARAccount>(loadDemandForPayment.Id, DemandForPayment.Relationship_OriginalPayingAccount);
      Assert.IsNull(loadOriginalPayingAccount);
      #endregion
    }

    private ARAccount CreateARAccount()
    {
      var account = new ARAccount();
      account.ARAccountBusinessKey.ExternalAccountId = DataTest.Random.Next();
      account.Company = "MetraTech";
      account.Country = CountryName.USA;
      account.City = "Waltham";
      account.State = "MA";
      account.Email = "test@metratech.com";
      account.Zip = "02451";

      return account;
    }

    private DemandForPayment CreateDemandForPayment()
    {
      var dfp = new DemandForPayment();

      dfp.OriginalDueDate = System.DateTime.Now;
      dfp.Taxes = 0.0M;
      dfp.Status = DomainModel.Enums.AccountsReceivable.Metratech_com_MetraAR.DFPStatus.Open;
      dfp.Amount = 123.0M;
      dfp.DivAmount = 100.0M;
      dfp.Description = "DemandForPayment - " + DataTest.Random.Next();
      dfp.Currency = DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.USD;
      dfp.DivCurrency = DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.GBP;
      dfp.Disputed = false;
      dfp.DueDate = System.DateTime.Now;
      dfp.RootId = Guid.NewGuid();

      return dfp;
    }

    private AccountNote CreateAccountNote()
    {
      var accountNote = new AccountNote();
      accountNote.AccountNoteBusinessKey.UniqueNoteId = DataTest.Random.Next();
      accountNote.Text = "abc";
      accountNote.ArchivedFlag = true;
      accountNote.TopNote = false;

      return accountNote;
    }

    private DebtTreatmentQueue CreateDebtTreatmentQueue()
    {
      var debtTreatmentQueue = new DebtTreatmentQueue();
      debtTreatmentQueue.TotalDebt = 0.0m;
      debtTreatmentQueue.TotalAmountByIC = 0.0m;
      debtTreatmentQueue.TotalAmountByDC = 0.0m;

      return debtTreatmentQueue;
    }

    private ARInvoice CreateARInvoice()
    {
      var invoice = new ARInvoice();
      invoice.ARInvoiceBusinessKey.InvoiceString = "Invoice - " + DataTest.Random.Next();
      invoice.IssueDate = DateTime.Now;
      invoice.InvoiceType = InvoiceType.EOP;
      invoice.Taxes = 0.0m;
      invoice.DivTaxes = 0.0m;
      invoice.DivAmount = 0.0m;
      invoice.DivCurrency = 0.0m;
      invoice.Currency = 0.0m;
      invoice.Amount = 0.0m;

      return invoice;
    }

    private Domain CreateDomain()
    {
      var domain = new Domain();
      domain.DomainBusinessKey.Name = "Domain - " + DataTest.Random.Next();
      domain.Currency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.USD;
      return domain;
    }

    private DomainProfile CreateDomainProfile()
    {
      var domainProfile = new DomainProfile();
      domainProfile.AllowAdjustments = true;
      domainProfile.AllowCredits = false;
      domainProfile.AllowDisputes = true;
      domainProfile.AllowDTQAging = false;
      domainProfile.AllowElectronicPayments = true;
      domainProfile.AllowOutgoingPayments = false;
      domainProfile.AllowPayments = true;
      domainProfile.AllowPDFGeneration = false;
      domainProfile.AllowSubLedger = true;
      domainProfile.AllowTransfers = false;

      domainProfile.DomainProfileBusinessKey.Name = Guid.NewGuid().ToString("B");

      return domainProfile;

    }

    private RemittanceInstruction CreateRemittanceInstruction()
    {
      var remittanceInstruction = new RemittanceInstruction();
      remittanceInstruction.Status = RemittanceStatus.Unexecuted;
      return remittanceInstruction;

    }

    private RemittanceInstructionDetail CreateRemittanceInstructionDetail()
    {
      var remittanceInstructionDetail = new RemittanceInstructionDetail();
      remittanceInstructionDetail.Amount = 0.0m;
      remittanceInstructionDetail.RemittanceDetailType = MetraTech.DomainModel.Enums.AccountsReceivable.Metratech_com_MetraAR.RemittanceDetailType.Payment;
      return remittanceInstructionDetail;

    }

    private PaymentDistributionAllocation CreatePaymentDistributionAllocation()
    {
      var paymentDistributionAllocation = new PaymentDistributionAllocation();
      return paymentDistributionAllocation;

    }

    private PaymentDistribution CreatePaymentDistribution()
    {
      var paymentDistribution = new PaymentDistribution();
      paymentDistribution.Amount = 50.0M;
      paymentDistribution.Currency = SystemCurrencies.USD;
      paymentDistribution.Status = MetraTech.DomainModel.Enums.AccountsReceivable.Metratech_com_MetraAR.PDStatus.Closed;
      paymentDistribution.DivAmount = 100.0M;
      paymentDistribution.Description = "trest";
      paymentDistribution.Currency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.USD;
      paymentDistribution.DivCurrency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.GBP;
      paymentDistribution.OriginType = OriginType.PaymentReceipt;

      return paymentDistribution;
    }

    private PaymentReceipt CreatePaymentReceipt()
    {
      var paymentReceipt = new PaymentReceipt();
      paymentReceipt.Currency = SystemCurrencies.USD;
      paymentReceipt.Amount = 100.00M;
      paymentReceipt.DivCurrency = SystemCurrencies.EUR;
      paymentReceipt.DivAmount = 123.0M;
      paymentReceipt.PaymentType = PaymentReceiptType.CreditCard;
      paymentReceipt.CcType = CreditCardType.Visa;
      paymentReceipt.Status = PaymentReceiptStatus.Open;

      return paymentReceipt;
    }
  }
  
}
