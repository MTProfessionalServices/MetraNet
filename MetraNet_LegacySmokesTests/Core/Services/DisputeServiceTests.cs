using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.Collections;
using System.Runtime.InteropServices;
using NUnit.Framework;
//MetraTech
using MetraTech;
using MetraTech.Test.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DataAccess;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using RS = MetraTech.Interop.Rowset;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess;
using MetraTech.Core.Services;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using Core.Core;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.DisputeServiceTests /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//

namespace MetraTech.Core.Services.Test
{
  /// <summary>
  /// Dispute Service Tests
  /// </summary>
  /// <remarks>
  /// The DisputeServiceTests class implements NUnit tests for the core DisputeService.
  /// This service provides methods that allow clients to interact with the subscriptions feature
  /// of the MetraNet system.  These methods include retrieving a list of current subscriptions, 
  /// details for a give subscription and a list of available product offerings for which the 
  /// account is eligible to subscribe.  It also provides methods to add, update and delete
  /// subscriptions.
  /// </remarks>
  [Category("NoAutoRun")]
  [TestFixture]
  public class DisputeServiceTests
  {
    #region Members

    private PCIdentifier mPCIdent;
    private Random random;

    #endregion

    #region Test Initialization and Cleanup
    /// <summary>
    /// Initializes subscription service tests by creating a new corporate and core subscriber
    /// accounts for the test.  Also initializes the product catalog objects used by the tests.
    /// </summary>
    [TestFixtureSetUp]
    public void InitTests()
    {

      // Random # generator...used for creating invoices.
      random = new Random();

      // Setup PCIdentifier
      int pcID = 1010;
      string pcName = "metratech.com/dispute";
      mPCIdent = new PCIdentifier(pcID, pcName);

      RepositoryAccess.Instance.Initialize();
    }

    /// <summary>
    /// Restore system to state prior the test run.  This currently does nothing.
    /// </summary>
    [TestFixtureTearDown]
    public void UninitTests()
    {


    }
    #endregion

    #region Test Methods
    /// <summary>
    /// Test GetDispute Method
    /// </summary>
    /// <remarks>
    /// This method tests the GetDispute method of the DisputeService.  
    /// 
    /// </remarks>
    [Test]
    [Category("GetDispute")]
    public void TestGetDispute()
    {

      #region Setup Test

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();


      // Assign Invoice ID and other fields
      dispute.invoiceId = 1000;
      dispute.description = "Test Get Dispute";
      dispute.title = "Dispute Title";
      dispute.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      // Save instance
      dispute.Save();

      DisputeBusinessKey key = dispute.DisputeBusinessKey;

      #endregion

      #region Get Dispute

      // Call Service Method
      Dispute disp;
      try
      {
        testClient.GetDispute(key, out disp);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        testClient.Close();

        throw new ApplicationException(err);
      }
      #endregion

      #region Validate results
      Assert.AreEqual(1000, dispute.invoiceId.Value);

      // Cleanup
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }

      #endregion


    }

    /// <summary>
    /// Test TestGetDisputes Method
    /// </summary>
    /// <remarks>
    /// This method tests the GetDisputes method of the DisputeService.  
    ///  
    /// </remarks>
    [Test]
    [Category("GetDisputes")]
    public void TestGetDisputes()
    {
      int ExpectedCnt = 3;


      #region  Test Setup Create Dispute List

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute disp1 = new Dispute();
      Dispute disp2 = new Dispute();
      Dispute disp3 = new Dispute();

      disp1.invoiceId = 1001;
      disp1.description = "Test Dispute Instance 1";
      disp1.title = "Dispute Title";
      disp1.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      disp2.invoiceId = 2001;
      disp2.description = "Test Dispute Instance 2";
      disp2.title = "Dispute Title";
      disp2.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      disp3.invoiceId = 3001;
      disp3.description = "Test Dispute Instance 3";
      disp3.title = "Dispute Title";
      disp3.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;


      // SAVE Disputes to be fetched
      disp1.Save();
      disp2.Save();
      disp3.Save();

      #endregion

      #region Get All Disputes
      MTList<Dispute> disputes = new MTList<Dispute>();

      try
      {
        testClient.GetDisputes(ref disputes);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        testClient.Close();

        throw new ApplicationException(err);
      }


      #endregion

      #region Validate results
      Assert.AreEqual(ExpectedCnt, disputes.TotalRows);

      // Cleanup
      StandardRepository.Instance.Delete<Dispute>(disp1);
      StandardRepository.Instance.Delete<Dispute>(disp2);
      StandardRepository.Instance.Delete<Dispute>(disp3);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }

      #endregion
    }

    /// <summary>
    /// Test SaveDispute Method
    /// </summary>
    /// <remarks>
    /// This method tests the SaveDispute method of the DisputeService.  
    /// 
    /// 
    /// </remarks>
    [Test]
    [Category("SaveDispute")]
    public void TestSaveDispute()
    {
      #region Create Dispute to Save

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 1234;
      dispute.description = "Test Save Dispute Instance";
      dispute.title = "Dispute Save";
      dispute.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      DisputeBusinessKey key;

      try
      {
        testClient.SaveDispute(ref dispute);

        // Get Key
        key = dispute.DisputeBusinessKey;
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        testClient.Close();

        throw new ApplicationException(err);
      }
      #endregion

      #region Validate Results

      // Go grab the saved disput
      Dispute retrieveDispute =
          StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);


      // Check returned Dispute Object
      Assert.IsNotNull(retrieveDispute);
      Assert.AreEqual(1234, retrieveDispute.invoiceId.Value);

      // Cleanup
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }

      #endregion
    }


    /// <summary>
    /// Test GetAdjustablePITemplates Method
    /// </summary>
    /// <remarks>
    /// This method tests the GetAdjustablePITemplates method of the DisputeService 
    /// 
    /// </remarks>
    [Test]
    [Category("GetAdjustablePITemplates")]
    public void TestGetAdjustablePITemplates()
    {
      #region Test Setup

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      // Insert Data into DB....AudioConfig setup.

      #endregion

      #region Get AdjustablePITemplates

      List<AdjustablePITemplate> tempList = new List<AdjustablePITemplate>();
      DomainModel.Enums.Core.Global.LanguageCode lang =
          DomainModel.Enums.Core.Global.LanguageCode.US;

      try
      {
        testClient.GetAdjustablePITemplates(lang, out tempList);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {

        string err = fe.Message;
        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results
      Assert.AreNotEqual(0, tempList.Count);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }

      #endregion
    }


    /// <summary>
    /// Test GetAdjustmentTypesForTemplate Method
    /// </summary>
    /// <remarks>
    /// This method tests the GetAdjustmentTypesForTemplate method of the DisputeService 
    /// 
    /// </remarks>
    [Test]
    [Category("GetAdjustmentTypesForTemplate")]
    public void TestGetAdjustmentTypesForTemplate()
    {
      #region Test Setup

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();


      #endregion

      #region Get Adjustment Types

      List<AdjustmentTemplateMetaData> adjList =
          new List<AdjustmentTemplateMetaData>();

      DomainModel.Enums.Core.Global.LanguageCode lang =
          DomainModel.Enums.Core.Global.LanguageCode.US;

      PCIdentifier piTemp = new PCIdentifier(120);


      try
      {
        testClient.GetAdjustmentTypesForTemplate(piTemp, lang, out adjList);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results
      Assert.AreNotEqual(0, adjList.Count);

      if (CommunicationState.Opened == testClient.State)
      {
        testClient.Close();
      }
      #endregion
    }

    /// <summary>
    /// Test AddInvoiceAdjustment Method 
    /// </summary>
    /// <remarks>
    /// This method tests the AddInvoiceAdjustment method of the DisputeService
    ///   
    /// </remarks>
    [Test]
    [Category("AddInvoiceAdjustment")]
    public void TestAddInvoiceAdjustment()
    {
      #region Setup Test Create and Save a Dispute
      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 9876;
      dispute.description = "Test Add Invoice Adjustment";
      dispute.title = "Add Invoice Adjustment";
      dispute.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      dispute.Save();

      // Get key
      DisputeBusinessKey key = dispute.DisputeBusinessKey;

      // Create and populate the Invoice Adjustment to be added.
      InvoiceAdjustment InvAdj = new InvoiceAdjustment();

      InvAdj.Amount = 25;
      InvAdj.InternalId = 9876;
      InvAdj.Currency = "EUR";
      InvAdj.ReasonCode = 1;
      InvAdj.PropId = 72;  // FK to Adjustment_type

      InvoiceAdjustmentBusinessKey bk = null;
      #endregion

      #region Add Invoice Adjustment

      try
      {
        testClient.AddInvoiceAdjustment(key, ref InvAdj);
        // Get key for validation purposes
        bk = InvAdj.InvoiceAdjustmentBusinessKey;
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results

      InvoiceAdjustment retrievAdj = StandardRepository.Instance.LoadInstanceByBusinessKey<InvoiceAdjustment, InvoiceAdjustmentBusinessKey>(bk);

      Assert.IsNotNull(retrievAdj);
      Assert.AreEqual(72, retrievAdj.PropId);

      // Cleanup  
      StandardRepository.Instance.Delete<InvoiceAdjustment>(InvAdj);
      StandardRepository.Instance.Delete<Dispute>(dispute);


      testClient.Close();
      #endregion
    }

    [Test]
    [Category("GetInvoiceAdjustmentsForDispute")]
    public void TestGetInvoiceAdjustmentsForDispute()
    {
      int ExpectedCnt = 1;
      #region Test Setup

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 2181;
      dispute.description = "Test Dispute Get Adjustments";
      dispute.title = "Dispute GetAdjustments";
      dispute.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      dispute.Save();

      DisputeBusinessKey key = dispute.DisputeBusinessKey;

      // Setup InvoiceAdjustment
      // Create and populate the Invoice Adjustment to be added.
      InvoiceAdjustment InvAdj = new InvoiceAdjustment();

      InvAdj.Amount = 150;
      InvAdj.InternalId = 3366;
      InvAdj.Currency = "EUR";
      InvAdj.ReasonCode = 1;
      InvAdj.PropId = 72;  // FK to Adjustment_type

      InvAdj.Save();

      InvAdj.Dispute = (Dispute)dispute;
      InvAdj.Save();

      dispute.Save();

      #endregion

      #region GetAdjustements

      MTList<AdjustmentBase> adjustments = new MTList<AdjustmentBase>();

      try
      {
        testClient.GetAdjustmentsForDispute(key, ref adjustments);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results
      Assert.IsNotNull(adjustments);
      Assert.AreEqual(ExpectedCnt, adjustments.TotalRows);
      Assert.AreEqual(3366, adjustments.Items[0].InternalId);


      //Cleanup
      StandardRepository.Instance.Delete<InvoiceAdjustment>(InvAdj);
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }

      #endregion
    }

    [Test]
    [Category("GetAdjustmentsForDispute")]
    public void TestGetAdjustmentsForDispute()
    {
      int ExpectedCnt = 2;
      #region Test Setup

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 7788;
      dispute.description = "Test Dispute Get Adjustments";
      dispute.title = "Dispute GetAdjustments";
      dispute.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      dispute.Save();

      DisputeBusinessKey key = dispute.DisputeBusinessKey;

      // // Setup ChargeAdjustment Objects 
      ChargeAdjustment adj1 = new ChargeAdjustment();
      ChargeAdjustment adj2 = new ChargeAdjustment();

      adj1.AdjustmentType = adj2.AdjustmentType = 72;
      adj1.InternalId = 3579;
      adj2.InternalId = 2468;
      adj1.Description = adj2.Description = "Test Charge Adjustment";
      adj1.ReasonCode = adj2.ReasonCode = 1;

      // Create relationships
      adj1.Dispute = (Dispute)dispute;
      adj2.Dispute = (Dispute)dispute;

      adj1.Save();
      adj2.Save();
      dispute.Save();

      #endregion

      #region GetAdjustements

      MTList<AdjustmentBase> adjustments = new MTList<AdjustmentBase>();

      try
      {
        testClient.GetAdjustmentsForDispute(key, ref adjustments);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results
      Assert.IsNotNull(adjustments);
      Assert.AreEqual(ExpectedCnt, adjustments.TotalRows);
      Assert.AreEqual(3579, adjustments.Items[0].InternalId);
      Assert.AreEqual(2468, adjustments.Items[1].InternalId);


      //Cleanup
      StandardRepository.Instance.Delete<ChargeAdjustment>(adj1);
      StandardRepository.Instance.Delete<ChargeAdjustment>(adj2);
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }

      #endregion
    }

    /// <summary>
    /// Test AddChargeAdjustment Method
    /// </summary>
    /// <remarks>
    /// This method tests the AddChargeAdjustment method of the DisputeService 
    /// 
    /// </remarks>
    [Test]
    [Category("CalculateChargeAdjustment")]
    public void TestCalculateChargeAdjustment()
    {
      #region Setup Test
      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 4321;
      dispute.description = "Test Calc Charge Adjustment";
      dispute.title = "Dispute Calc Charge Adjustment";
      dispute.status =
          DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      dispute.Save();

      // Get key
      DisputeBusinessKey key = dispute.DisputeBusinessKey;

      // Create ChargeAdjustment Object
      var chargeAdj = new ChargeAdjustment();
      //chargeAdj.AdjustmentType = 72;
      chargeAdj.AdjustmentType = 88;
      chargeAdj.InternalId = 6006;
      chargeAdj.Description = "Test Calc Charge Adjustment";
      chargeAdj.ReasonCode = 1;
      chargeAdj.Save();

      // Key for validation
      ChargeAdjustmentBusinessKey chrgBK = null;

      // Create Sessions
      var sess = new ChargeAdjustmentSession();
      sess.SessionId = 6006;
      // Setup Relationship  ChargeAdjustment <---> ChargeAdjustmentSession
      sess.ChargeAdjustment = chargeAdj;
      sess.Save();

      AdjustmentInput input = null;

      /*
      System.Type t =
              System.Type.GetType("MetraTech.DomainModel.ProductCatalog.CallPercentAdjustmentInputs");
                              
      input = System.Activator.CreateInstance(t) as AdjustmentInput;
      */

      AdjustmentOutput outputs;

      #endregion

      #region Add Charge Adjustment


      try
      {
        testClient.CalculateChargeAdjustment(key,
                                             chargeAdj,
                                             input,
                                             out outputs);

        chrgBK = chargeAdj.ChargeAdjustmentBusinessKey;
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {

        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results

      ChargeAdjustment adjustment =
          StandardRepository.Instance.LoadInstanceByBusinessKey<ChargeAdjustment, ChargeAdjustmentBusinessKey>(chrgBK);
      Assert.IsNotNull(adjustment);
      Assert.AreEqual(adjustment.InternalId, 6006);

      //Cleanup
      StandardRepository.Instance.Delete<ChargeAdjustmentSession>(sess);
      StandardRepository.Instance.Delete<ChargeAdjustment>(adjustment);
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (CommunicationState.Opened == testClient.State)
      {
        testClient.Close();
      }


      #endregion

    }

    /// <summary>
    /// Test AddChargeAdjustment Method
    /// </summary>
    /// <remarks>
    /// This method tests the AddChargeAdjustment method of the DisputeService 
    /// 
    /// </remarks>
    [Test]
    [Category("AddChargeAdjustment")]
    public void TestAddChargeAdjustment()
    {
      #region Setup Test
      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 1234;
      dispute.description = "Test Add Charge Adjustment";
      dispute.title = "Dispute Charge Adjustment";
      dispute.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      dispute.Save();

      // Get key
      DisputeBusinessKey key = dispute.DisputeBusinessKey;

      // Create ChargeAdjustment Object
      var chargeAdj = new ChargeAdjustment();
      chargeAdj.AdjustmentType = 72;
      chargeAdj.InternalId = 3434;
      chargeAdj.Description = "Test Charge Adjustment";
      chargeAdj.ReasonCode = 1;
      chargeAdj.Save();

      // Key for validation
      ChargeAdjustmentBusinessKey chrgBK;

      // Create Sessions
      var sess = new ChargeAdjustmentSession();
      sess.SessionId = 7001;
      // Setup Relationship  ChargeAdjustment <---> ChargeAdjustmentSession
      sess.ChargeAdjustment = chargeAdj;

      sess.Save();
      chargeAdj.Save();

      AdjustmentInput input = null;
      AdjustmentOutput outputs;

      #endregion

      #region Add Charge Adjustment


      try
      {
        testClient.AddChargeAdjustment(key,
                                       chargeAdj,
                                       input,
                                       out outputs);

        chrgBK = chargeAdj.ChargeAdjustmentBusinessKey;
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results

      ChargeAdjustment adjustment = StandardRepository.Instance.LoadInstanceByBusinessKey<ChargeAdjustment, ChargeAdjustmentBusinessKey>(chrgBK);
      Assert.IsNotNull(adjustment);
      Assert.AreEqual(adjustment.InternalId, 3434);

      //Cleanup
      StandardRepository.Instance.Delete<ChargeAdjustmentSession>(sess);
      StandardRepository.Instance.Delete<ChargeAdjustment>(adjustment);
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (CommunicationState.Opened == testClient.State)
      {
        testClient.Close();
      }
      #endregion
    }

    /// <summary>
    /// Test SubmitForApproval Method
    /// </summary>
    /// <remarks>
    /// This method tests the SubmitForApproval method of the DisputeService 
    /// 
    /// </remarks>
    [Test]
    [Category("SubmitForApproval")]
    public void TestSubmitForApproval()
    {
      #region Setup Test

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 1313;
      dispute.description = "Test SubmitApproval Dispute Object";
      dispute.title = "SubmitApproval Dispute";
      dispute.status = DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;
      dispute.invoiceNum = "34345656";
      dispute.Save();

      // Get key
      DisputeBusinessKey key = dispute.DisputeBusinessKey;

      // Setup InvoiceAdjustment
      // Create and populate the Invoice Adjustment to be added.            
      InvoiceAdjustment InvAdj = new InvoiceAdjustment();

      InvAdj.Amount = 99;
      InvAdj.InternalId = 4488;
      InvAdj.Currency = "EUR";
      InvAdj.ReasonCode = 1;
      InvAdj.PropId = 72;  // FK to Adjustment_type

      InvAdj.Save();

      InvAdj.Dispute = (Dispute)dispute;
      InvAdj.Save();

      // Get key
      InvoiceAdjustmentBusinessKey invBK = InvAdj.InvoiceAdjustmentBusinessKey;

      #endregion

      #region Submit Approval

      try
      {
        testClient.SubmitForApproval(key);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results
      Dispute disp = new Dispute();

      // Load Dispute and check Status
      try
      {
        testClient.GetDispute(key, out disp);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        throw new ApplicationException(err);
      }

      Assert.AreEqual(disp.status,
          DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Approved);

      testClient.Close();
      #endregion
    }

    /// <summary>
    /// Test ApproveDispute Method
    /// </summary>
    /// <remarks>
    /// This method tests the ApproveDispute method of the DisputeService 
    ///  for Charge Adjustments
    /// </remarks>
    [Test]
    [Category("ApproveDisputeForCharge")]
    public void TestApproveDisputeForCharge()
    {
      #region Setup Test
      //String insertSQL = "INSERT INTO dbo.t_pv_AccountCreditRequest " +
      //    "VALUES (3333, 500, 1, 'Other', 'Pending', 10, null, null, 555, 'Desc', 123, 0)";

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 6363;
      dispute.description = "Test Reject Dispute Object";
      dispute.title = "Approve Dispute";
      dispute.status =
          DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;
      dispute.Save();

      // // Setup ChargeAdjustment Objects 
      ChargeAdjustment adj1 = new ChargeAdjustment();
      ChargeAdjustment adj2 = new ChargeAdjustment();

      adj1.AdjustmentType = adj2.AdjustmentType = 72;
      adj1.InternalId = 2244;
      adj2.InternalId = 7799;
      adj1.Description = adj2.Description = "Test Reject Dispute";
      adj1.ReasonCode = adj2.ReasonCode = 1;

      // Save in repository
      adj1.Save();
      adj2.Save();

      // Create relationships
      adj1.Dispute = (Dispute)dispute;
      adj2.Dispute = (Dispute)dispute;

      adj1.Save();
      adj2.Save();

      // Create Sessions
      var sess1 = new ChargeAdjustmentSession();
      sess1.SessionId = 3333;
      // Setup Relationship  ChargeAdjustment <---> ChargeAdjustmentSession
      sess1.ChargeAdjustment = adj1;
      sess1.Save();

      var sess2 = new ChargeAdjustmentSession();
      sess2.SessionId = 4444;
      // Setup Relationship  ChargeAdjustment <---> ChargeAdjustmentSession
      sess2.ChargeAdjustment = adj2;
      sess2.Save();

      adj1.Save();
      adj2.Save();


      // Get keys
      dispute.Save();
      DisputeBusinessKey key = dispute.DisputeBusinessKey;

      #endregion

      #region Approve Dispute

      try
      {
        testClient.ApproveDispute(key);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        //Issue from ClientSrvc throwing exception
        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results
      Dispute disp = new Dispute();

      // Load Dispute and check Status           
      Dispute disputeOut =
          StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

      Assert.IsNotNull(disputeOut);
      Assert.AreEqual(6363, disputeOut.invoiceId.Value);
      Assert.AreEqual(DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Approved,
                      disputeOut.status);

      // Cleanup
      StandardRepository.Instance.Delete(sess1);
      StandardRepository.Instance.Delete(sess2);
      StandardRepository.Instance.Delete(adj1);
      StandardRepository.Instance.Delete(adj2);
      StandardRepository.Instance.Delete(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }
      #endregion
    }

    /// <summary>
    /// Test ApproveDispute Method
    /// </summary>
    /// <remarks>
    /// This method tests the ApproveDispute method of the DisputeService 
    /// for Invoice Adjustments
    /// </remarks>
    [Test]
    [Category("ApproveDisputeForInvoice")]
    public void TestApproveDisputeForInvoice()
    {
      #region Setup Test
      //String insertSQL = "INSERT INTO dbo.t_pv_AccountCreditRequest " +
      //    "VALUES (3333, 500, 1, 'Other', 'Pending', 10, null, null, 555, 'Desc', 123, 0)";

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 6363;
      dispute.description = "Test Reject Dispute Object";
      dispute.title = "Approve Dispute";
      dispute.status =
          DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;
      dispute.Save();

      // Setup InvoiceAdjustment
      // Create and populate the Invoice Adjustment to be added.            
      InvoiceAdjustment InvAdj = new InvoiceAdjustment();

      InvAdj.Amount = 55;
      InvAdj.InternalId = 3636;
      InvAdj.Currency = "EUR";
      InvAdj.ReasonCode = 1;
      InvAdj.PropId = 72;  // FK to Adjustment_type

      InvAdj.Save();

      InvAdj.Dispute = (Dispute)dispute;
      InvAdj.Save();

      // Get keys
      DisputeBusinessKey key = dispute.DisputeBusinessKey;
      InvoiceAdjustmentBusinessKey invBK = InvAdj.InvoiceAdjustmentBusinessKey;

      // Get keys
      dispute.Save();

      #endregion

      #region Approve Dispute

      try
      {
        testClient.ApproveDispute(key);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        //Issue from ClientSrvc throwing exception
        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results
      Dispute disp = new Dispute();

      // Load Dispute and check Status           
      Dispute disputeOut =
          StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

      Assert.IsNotNull(disputeOut);
      Assert.AreEqual(6363, disputeOut.invoiceId.Value);
      Assert.AreEqual(DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Approved,
                      disputeOut.status);

      // Cleanup
      StandardRepository.Instance.Delete(InvAdj);
      StandardRepository.Instance.Delete(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }
      #endregion
    }
    /// <summary>
    /// Test RejectDispute Method
    /// </summary>
    /// <remarks>
    /// This method tests the RejectDispute method of the DisputeService 
    /// for Charge Adjustments
    /// </remarks>
    [Test]
    [Category("RejectDisputeForCharge")]
    public void TestRejectDisputeCharge()
    {
      #region Setup Test

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();
      dispute.invoiceId = 9009;
      dispute.description = "Test Reject Dispute Object";
      dispute.title = "Reject Dispute";
      dispute.status =
          DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;
      dispute.Save();

      // Setup ChargeAdjustment Objects 
      ChargeAdjustment adj1 = new ChargeAdjustment();
      ChargeAdjustment adj2 = new ChargeAdjustment();

      adj1.AdjustmentType = adj2.AdjustmentType = 72;
      adj1.InternalId = 2244;
      adj2.InternalId = 7799;
      adj1.Description = adj2.Description = "Test Reject Dispute";
      adj1.ReasonCode = adj2.ReasonCode = 1;

      // Save in repository
      adj1.Save();
      adj2.Save();

      // Create relationships
      adj1.Dispute = (Dispute)dispute;
      adj2.Dispute = (Dispute)dispute;

      adj1.Save();
      adj2.Save();

      // Create Sessions
      var sess1 = new ChargeAdjustmentSession();
      sess1.SessionId = 1111;
      // Setup Relationship  ChargeAdjustment <---> ChargeAdjustmentSession
      sess1.ChargeAdjustment = adj1;
      sess1.Save();

      var sess2 = new ChargeAdjustmentSession();
      sess2.SessionId = 2222;
      // Setup Relationship  ChargeAdjustment <---> ChargeAdjustmentSession
      sess2.ChargeAdjustment = adj2;
      sess2.Save();

      adj1.Save();
      adj2.Save();


      // Get keys
      dispute.Save();
      DisputeBusinessKey key = dispute.DisputeBusinessKey;

      #endregion

      #region Reject Dispute

      try
      {
        testClient.RejectDispute(key);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results
      Dispute disp = new Dispute();

      // Load Dispute and check Status           
      Dispute disputeOut = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

      Assert.IsNotNull(disputeOut);
      Assert.AreEqual(9009, disputeOut.invoiceId.Value);
      Assert.AreEqual(DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Rejected,
                      disputeOut.status);

      // Cleanup
      StandardRepository.Instance.Delete<ChargeAdjustmentSession>(sess1);
      StandardRepository.Instance.Delete<ChargeAdjustmentSession>(sess2);
      StandardRepository.Instance.Delete<ChargeAdjustment>(adj1);
      StandardRepository.Instance.Delete<ChargeAdjustment>(adj2);
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }
      #endregion
    }

    /// <summary>
    /// Test RejectDispute Method
    /// </summary>
    /// <remarks>
    /// This method tests the RejectDispute method of the DisputeService 
    /// for Invoice Adjustments.
    /// </remarks>
    [Test]
    [Category("RejectDisputeForInvoice")]
    public void TestRejectDisputeForInvoice()
    {
      #region Setup Test


      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();

      dispute.invoiceId = 2266;
      dispute.description = "Test Reject Dispute";
      dispute.title = "Dispute Rejection";
      dispute.status =
          DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      dispute.Save();

      // Setup InvoiceAdjustment
      // Create and populate the Invoice Adjustment to be added.            
      InvoiceAdjustment InvAdj = new InvoiceAdjustment();

      InvAdj.Amount = 10;
      InvAdj.InternalId = 3233;
      InvAdj.Currency = "EUR";
      InvAdj.ReasonCode = 1;
      InvAdj.PropId = 72;  // FK to Adjustment_type

      InvAdj.Save();

      InvAdj.Dispute = (Dispute)dispute;
      InvAdj.Save();

      // Get keys
      DisputeBusinessKey key = dispute.DisputeBusinessKey;
      InvoiceAdjustmentBusinessKey invBK = InvAdj.InvoiceAdjustmentBusinessKey;


      #endregion

      #region Reject Dispute

      try
      {
        testClient.RejectDispute(key);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results

      // Load Dispute and check Status
      Dispute dispOut =
         StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);
      Assert.IsNotNull(dispOut);
      Assert.AreEqual(2266, dispute.invoiceId);

      InvoiceAdjustment invAdj2 =
          StandardRepository.Instance.LoadInstanceByBusinessKey<InvoiceAdjustment, InvoiceAdjustmentBusinessKey>(invBK);

      Assert.IsNotNull(invAdj2);
      Assert.AreEqual(4488, invAdj2.InternalId);

      Assert.AreEqual(DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Rejected,
                                  invAdj2.Dispute.status);

      // Cleanup
      StandardRepository.Instance.Delete<InvoiceAdjustment>(InvAdj);
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }

      #endregion
    }

    [Test]
    [Category("ReverseApprovedDisputeForInvoice")]
    public void TestReverseApprovedDisputeForInvoice()
    {
      #region Setup Test

      String insertSQL = "INSERT INTO dbo.t_pv_AccountCreditRequest " +
          "VALUES (6789, 500, 1, 'Other', 'APPROVED', 25, null, null, 3478, 'Desc', 123, 0)";

      // Insert Data
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTPreparedStatement prepStmt =
              conn.CreatePreparedStatement(insertSQL))
          {
            // Insert Data
            prepStmt.ExecuteNonQuery();
          } // end Using Statement
        } // end Using Connection
      }
      catch (Exception e)
      {
        throw e;
      }

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();

      dispute.invoiceId = 3478;
      dispute.description = "Test Dispute Reversal";
      dispute.title = "Dispute Reversal";
      // Approve status so it can be reversed.
      dispute.status =
          DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Approved;

      dispute.Save();

      // Setup InvoiceAdjustment
      // Create and populate the Invoice Adjustment to be added.            
      InvoiceAdjustment InvAdj = new InvoiceAdjustment();

      InvAdj.Amount = 25;
      InvAdj.InternalId = 3233;
      InvAdj.Currency = "EUR";
      InvAdj.ReasonCode = 1;
      InvAdj.PropId = 72;  // FK to Adjustment_type

      InvAdj.Save();

      InvAdj.Dispute = (Dispute)dispute;
      InvAdj.Save();

      // Get keys
      DisputeBusinessKey key = dispute.DisputeBusinessKey;
      InvoiceAdjustmentBusinessKey invBK = InvAdj.InvoiceAdjustmentBusinessKey;


      #endregion

      #region Reverse Approved Dispute

      try
      {
        testClient.ReverseApprovedDispute(key);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results
      // Load Dispute and check Status           
      Dispute disputeOut =
          StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

      Assert.IsNotNull(disputeOut);
      Assert.AreEqual(3478, disputeOut.invoiceId.Value);
      Assert.AreEqual(DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Rejected,
                      disputeOut.status);

      // Cleanup
      StandardRepository.Instance.Delete<InvoiceAdjustment>(InvAdj);
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }
      #endregion
    }

    [Test]
    [Category("ReverseApprovedDisputeForAdjustments")]
    public void TestReverseApprovedDisputeForAdjustments()
    {
      #region Setup Test

      String insertSQL = "INSERT INTO dbo.t_pv_AccountCredit " +
          "VALUES (6790, 500, 1, 'APPROVED', null, 3575, null, null, null, 'CCard', 1, null, null, null, null, null, null, null)";

      // Insert Data
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTPreparedStatement prepStmt =
              conn.CreatePreparedStatement(insertSQL))
          {
            // Insert Data
            prepStmt.ExecuteNonQuery();
          } // end Using Statement
        } // end Using Connection
      }
      catch (Exception e)
      {
        throw e;
      }

      DisputeServiceClient testClient = new DisputeServiceClient();
      testClient.ClientCredentials.UserName.UserName = "su";
      testClient.ClientCredentials.UserName.Password = "su123";

      testClient.Open();

      Dispute dispute = new Dispute();

      dispute.invoiceId = 3575;
      dispute.description = "Test Dispute Reversal";
      dispute.title = "Dispute Reversal";
      // Approve status so it can be reversed.
      dispute.status =
          DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Approved;

      dispute.Save();

      // Setup ChargeAdjustment Objects 
      ChargeAdjustment adj1 = new ChargeAdjustment();
      ChargeAdjustment adj2 = new ChargeAdjustment();

      adj1.AdjustmentType = adj2.AdjustmentType = 72;
      adj1.InternalId = 2131;
      adj2.InternalId = 4252;
      adj1.Description = adj2.Description = "Test Reverse Dispute";
      adj1.ReasonCode = adj2.ReasonCode = 0;

      // Save in repository
      adj1.Save();
      adj2.Save();

      // Create relationships
      adj1.Dispute = (Dispute)dispute;
      adj2.Dispute = (Dispute)dispute;

      adj1.Save();
      adj2.Save();

      // Create Sessions
      var sess1 = new ChargeAdjustmentSession();
      sess1.SessionId = 5555;
      // Setup Relationship  ChargeAdjustment <---> ChargeAdjustmentSession
      sess1.ChargeAdjustment = adj1;
      sess1.Save();

      var sess2 = new ChargeAdjustmentSession();
      sess2.SessionId = 7777;
      // Setup Relationship  ChargeAdjustment <---> ChargeAdjustmentSession
      sess2.ChargeAdjustment = adj2;
      sess2.Save();

      adj1.Save();
      adj2.Save();

      dispute.Save();

      // Get keys
      DisputeBusinessKey key = dispute.DisputeBusinessKey;


      #endregion

      #region Reverse Approved Dispute

      try
      {
        testClient.ReverseApprovedDispute(key);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        testClient.Close();

        throw new ApplicationException(err);
      }

      #endregion

      #region Validate Results


      // Load Dispute and check Status           
      Dispute disputeOut =
          StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

      Assert.IsNotNull(disputeOut);
      Assert.AreEqual(3575, disputeOut.invoiceId.Value);
      Assert.AreEqual(DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Rejected,
                      disputeOut.status);

      // Cleanup
      StandardRepository.Instance.Delete<ChargeAdjustmentSession>(sess1);
      StandardRepository.Instance.Delete<ChargeAdjustmentSession>(sess2);
      StandardRepository.Instance.Delete<ChargeAdjustment>(adj1);
      StandardRepository.Instance.Delete<ChargeAdjustment>(adj2);
      StandardRepository.Instance.Delete<Dispute>(dispute);

      if (testClient.State == CommunicationState.Opened)
      {
        testClient.Close();
      }
      #endregion
    }
    #endregion
  } // End DisputeServiceTests Class
} // End MetraTech.Core.Services.Test Namespace