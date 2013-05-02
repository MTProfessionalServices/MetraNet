using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using MetraTech.DomainModel.AccountTypes;
using RS = MetraTech.Interop.Rowset;


//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.SubscriptionServiceTests /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//

namespace MetraTech.Core.Services.Test
{
  using MetraTech;
  using MetraTech.Test.Common;
  using MetraTech.DomainModel.Common;
  using MetraTech.Core.Services;
  using System.ServiceModel;
  using MetraTech.Core.Services.ClientProxies;
  using MetraTech.ActivityServices.Common;
  using System.Collections;
  using MetraTech.Interop.MTProductCatalog;
  using MetraTech.Interop.MTAuth;
  using System.Runtime.InteropServices;
  using MetraTech.DomainModel.ProductCatalog;
  using MetraTech.DomainModel.BaseTypes;

  /// <summary>
  /// Subscription Service Tests
  /// </summary>
  /// <remarks>
  /// The SubscriptionServiceTests class implements NUnit tests for the core SubscriptionService.
  /// This service provides methods that allow clients to interact with the subscriptions feature
  /// of the MetraNet system.  These methods include retrieving a list of current subscriptions, 
  /// details for a give subscription and a list of available product offerings for which the 
  /// account is eligible to subscribe.  It also provides methods to add, update and delete
  /// subscriptions.
  /// </remarks>
  [Category("NoAutoRun")]
  [TestFixture]
  public class SubscriptionServiceTests
  {
    #region Members
    private int m_CoreSubId;
    private ProductOffering m_ProductOffering = null;
    private Subscription m_Subscription;
    private DateTime m_SubStartDate;

    MetraTech.Interop.MTProductCatalog.IMTSessionContext m_SessionContext;

    private SubscriptionServiceClient m_ServiceClient = null;

    IMTProductCatalog m_ProductCatalog;
    IMTPCAccount m_pcAcct;

    Dictionary<string, List<UDRCInstanceValue>> m_UDRCInstanceValues = new Dictionary<string, List<UDRCInstanceValue>>();
    #endregion

      public SubscriptionServiceClient Client
      {
          get
          {
              if (m_ServiceClient == null)
              {
                  m_ServiceClient = new SubscriptionServiceClient();
                  m_ServiceClient.ClientCredentials.UserName.UserName = "su";
                  m_ServiceClient.ClientCredentials.UserName.Password = "su123";
              }

              return m_ServiceClient;
          }
      }

    #region Test Initialization and Cleanup
    /// <summary>
    /// Initializes subscription service tests by creating a new corporate and core subscriber
    /// accounts for the test.  Also initializes the product catalog objects used by the tests.
    /// </summary>
    [TestFixtureSetUp]
    public void InitTests()
    {
      IMTLoginContext loginContext = new MTLoginContextClass();
      m_SessionContext = (MetraTech.Interop.MTProductCatalog.IMTSessionContext)loginContext.Login("su", "system_user", "su123");

      m_ProductCatalog = new MTProductCatalogClass();
      m_ProductCatalog.SetSessionContext(m_SessionContext);

      // Create corporate account.
      string corporate = String.Format("SubSvcTests_CorpAccount_{0}", Utils.GetTestId());
      Utils.CreateCorporation(corporate, MetraTime.Now);
      int corporateAccountId = Utils.GetSubscriberAccountID(corporate);


      // Create Core Subscriber
      ArrayList accountSpecs = new ArrayList();

      string coreSubName = String.Format("SubSvcTests_CoreSub_{0}", Utils.GetTestId());
      Utils.BillingCycle cycle = new Utils.BillingCycle(Utils.CycleType.MONTHLY, 1);
      Utils.AccountParameters param = new Utils.AccountParameters(coreSubName, cycle);
      accountSpecs.Add(param);

      Utils.CreateSubscriberAccounts(corporate, accountSpecs, MetraTime.Now);

      m_CoreSubId = Utils.GetSubscriberAccountID(coreSubName);

      m_pcAcct = m_ProductCatalog.GetAccount(m_CoreSubId);
      m_pcAcct.SetSessionContext(m_SessionContext);
    }

    /// <summary>
    /// Restore system to state prior the test run.  This currently does nothing.
    /// </summary>
    [TestFixtureTearDown]
    public void UninitTests()
    {
        if (m_ServiceClient != null)
        {
            if (m_ServiceClient.State == CommunicationState.Opened)
            {
                m_ServiceClient.Close();
            }
            else
            {
                m_ServiceClient.Abort();
            }

            m_ServiceClient = null;
        }
    }
    #endregion

    #region Test Methods
    /// <summary>
    /// Test GetEligiblePOsForSubscription Method
    /// </summary>
    /// <remarks>
    /// This method tests the GetEligiblePOsForSubscription method of the SubscriptionService.  
    /// This compares the results from the SubscriptionService to the results from the legacy
    /// APIs.  If everything succeeds, it selects a Product Offering to which the core subscriber
    /// account created during test initialization will be subscribed.
    /// </remarks>
    [Test]
    public void T01TestGetEligiblePOs()
    {
      DateTime refDate = MetraTime.Now;

      #region Get Product Catalog results
      

      MetraTech.Interop.MTProductCatalog.IMTDataFilter filter = (MetraTech.Interop.MTProductCatalog.IMTDataFilter)new RS.MTDataFilterClass();

      MetraTech.Interop.MTProductCatalog.IMTRowSet pcPOs = m_pcAcct.FindSubscribableProductOfferingsAsRowset(filter, refDate);

      pcPOs.MoveFirst();

      Assert.Greater(pcPOs.RecordCount, 0);
      #endregion

      #region Get Service Results
      MTList<ProductOffering> productOfferings = new MTList<ProductOffering>();

      try
      {
        Client.GetEligiblePOsForSubscription(new AccountIdentifier(m_CoreSubId), refDate, ref productOfferings);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }

      Assert.Greater(productOfferings.TotalRows, 0);
      #endregion

      #region Validate results and select PO for subscription
      Assert.AreEqual(pcPOs.RecordCount, productOfferings.TotalRows);

      while (!Convert.ToBoolean(pcPOs.EOF))
      {
        ProductOffering po = null;

        int id_po = (int)pcPOs.get_Value("id_po");

        foreach (ProductOffering prodOffering in productOfferings.Items)
        {
          if (prodOffering.ProductOfferingId == id_po)
          {
            po = prodOffering;
            break;
          }
        }

        Assert.IsNotNull(po, "Cannot locate product offering {0} in collection from service", id_po);
        Assert.AreEqual(pcPOs.get_Value("nm_name"), po.Name, "Name mismatch for product offering {0}", id_po);
        Assert.AreEqual(pcPOs.get_Value("nm_display_name"), po.DisplayName, "Display name mismatch for product offering {0}", id_po);

        if (m_ProductOffering == null)
        {
          m_ProductOffering = po;
        }

        pcPOs.MoveNext();
      }
      
      #endregion
    }

    /// <summary>
    /// Test GetUDRCInstancesForPO Method
    /// </summary>
    /// <remarks>
    /// This method tests the GetUDRCInstancesForPO method of the SubscriptionService.  
    /// This compares the results from the SubscriptionService to the results from the legacy
    /// APIs.  If everything succeeds, it sets up UDRC instance values for the AddSubscription
    /// call.
    /// </remarks>
    [Test]
    public void T02TestGetUDRCInstancesForPO()
    {
      #region Get UDRC Instances from Product Catalog
      //IMTPriceableItemType piType = m_ProductCatalog.GetPriceableItemTypeByName("Unit Dependent Recurring Charge");
      IMTProductOffering po = m_ProductCatalog.GetProductOffering(m_ProductOffering.ProductOfferingId.Value);
      //MetraTech.Interop.MTProductCatalog.IMTCollection instances = po.GetPriceableItemsOfType(piType.ID);
      
      MetraTech.Interop.MTProductCatalog.IMTCollection possibleInstances = po.GetPriceableItems();
      List<IMTRecurringCharge> actualUDRCInstances = new List<IMTRecurringCharge>();
      foreach (IMTPriceableItem possibleUDRC in possibleInstances)
      {
        if (possibleUDRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
        {
          actualUDRCInstances.Add((IMTRecurringCharge)possibleUDRC);
        }
      }
      #endregion

      #region Get UDRC Instances from Service
      List<UDRCInstance> udrcInstances = null;

      try
      {
        Client.GetUDRCInstancesForPO((int)m_ProductOffering.ProductOfferingId, out udrcInstances);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }
      #endregion

      #region Validate Results and Set up Instance Values
      Assert.AreEqual(actualUDRCInstances.Count, udrcInstances.Count);

      UDRCInstance sel = null;
      foreach (IMTRecurringCharge rc in actualUDRCInstances)
      {
        sel = null;
        foreach (UDRCInstance inst in udrcInstances)
        {
          if (rc.ID == inst.ID)
          {
            sel = inst;
            break;
          }
        }

        if (sel != null)
        {
          Assert.AreEqual(rc.MaxUnitValue, sel.MaxValue);
          Assert.AreEqual(rc.MinUnitValue, sel.MinValue);
          Assert.AreEqual(sel.DisplayName, rc.DisplayName);
          Assert.AreEqual(sel.Name, rc.Name);
          Assert.AreEqual(sel.IsIntegerValue, rc.IntegerUnitValue);

          if (rc.UnitValueEnumeration.Count != 0)
          {
            Assert.IsNotNull(sel.UnitValueEnumeration);
            Assert.AreEqual(sel.UnitValueEnumeration.Count, rc.UnitValueEnumeration.Count);
          }
          else
          {
            Assert.IsNull(sel.UnitValueEnumeration);
          }

          UDRCInstanceValue instVal = new UDRCInstanceValue();
          instVal.UDRC_Id = sel.ID;
          
          if( sel.UnitValueEnumeration != null && sel.UnitValueEnumeration.Count != 0)
          {
            instVal.Value = sel.UnitValueEnumeration[sel.UnitValueEnumeration.Count - 1];
          }
          else
          {
            instVal.Value = sel.MinValue;
          }

          List<UDRCInstanceValue> vals = new List<UDRCInstanceValue>();
          vals.Add(instVal);

          m_UDRCInstanceValues.Add(sel.ID.ToString(), vals);
        }
        else
        {
          throw new ApplicationException(string.Format("Recurring Charge ID: {0} is not in service results",rc.ID));
        }
      }
      #endregion
    }


    /// <summary>
    /// Test AddSubscription Method
    /// </summary>
    /// <remarks>
    /// This method tests the AddSubscription method of the SubscriptionService.  
    /// This adds a subscription to the Product Offering selected in the TestGetEligiblePOs 
    /// method to the core subscriber account created during test initialization.
    /// </remarks>
    [Test]
    public void T03TestAddSubscription()
    {
      Subscription sub = new Subscription();

      sub.ProductOfferingId = m_ProductOffering.ProductOfferingId.Value;
      sub.SubscriptionSpan = new ProdCatTimeSpan();

      m_SubStartDate = MetraTime.Now;
      m_SubStartDate = new DateTime(m_SubStartDate.Year, m_SubStartDate.Month, m_SubStartDate.Day, 0, 0, 0);
      sub.SubscriptionSpan.StartDate = m_SubStartDate;

      if (m_UDRCInstanceValues.Count != 0)
      {
        sub.UDRCValues = m_UDRCInstanceValues;
      }

      try
      {
        Client.AddSubscription(new AccountIdentifier(m_CoreSubId), ref sub);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }
    }

    /// <summary>
    /// Test GetSubscriptions Method
    /// </summary>
    /// <remarks>
    /// This method tests the GetSubscriptions method of the SubscriptionService.  
    /// This compares the results from the SubscriptionService to the results from the legacy
    /// APIs.  
    /// </remarks>
    [Test]
    public void T04TestGetSubscriptions()
    {
      #region Get Product Catalog results
      MetraTech.Interop.MTProductCatalog.IMTCollection pcPOs = m_pcAcct.GetSubscriptions();

      Assert.AreEqual(1, pcPOs.Count);
      #endregion

      #region Get Service Results
      MTList<Subscription> subscriptions = new MTList<Subscription>();

      try
      {
        Client.GetSubscriptions(new AccountIdentifier(m_CoreSubId), ref subscriptions);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }


      Assert.AreEqual(1, subscriptions.TotalRows);
      #endregion

      #region Validate results
      Subscription sub = subscriptions.Items[0];

      Assert.AreEqual(m_ProductOffering.ProductOfferingId, sub.ProductOfferingId);
      Assert.AreEqual(m_ProductOffering.Name, sub.ProductOffering.Name);

      Assert.AreEqual(m_SubStartDate, sub.SubscriptionSpan.StartDate);

      m_Subscription = sub;
      #endregion
    }

    /// <summary>
    /// Test GetSubscriptionDetail Method
    /// </summary>
    /// <remarks>
    /// This method tests the GetSubscriptionDetail method of the SubscriptionService.  
    /// This compares the results from the SubscriptionService to the results from the legacy
    /// APIs.  
    /// </remarks>
    [Test]
    public void T05TestGetSubscriptionDetail()
    {
      #region Get Product Catalog Results
      IMTSubscriptionBase subBase = m_pcAcct.GetSubscription((int)m_Subscription.SubscriptionId);

      Assert.AreNotEqual(null, subBase);
      #endregion

      #region Get Service Results
      Subscription subDetails = null;

      try
      {
        Client.GetSubscriptionDetail(new AccountIdentifier(m_CoreSubId), (int)m_Subscription.SubscriptionId, out subDetails);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }
        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }

      Assert.AreNotEqual(null, subDetails);
      #endregion

      #region Validate Results
      Assert.AreEqual(subBase.ID, subDetails.SubscriptionId);
      Assert.AreEqual(subBase.ProductOfferingID, subDetails.ProductOfferingId);
      Assert.AreEqual(subBase.WarnOnEBCRStartDateChange, subDetails.WarnOnEBCRStartDateChange);

      Assert.AreEqual(subBase.EffectiveDate.StartDate, subDetails.SubscriptionSpan.StartDate);
      Assert.AreEqual(subBase.EffectiveDate.EndDate, subDetails.SubscriptionSpan.EndDate);

      Assert.AreEqual(m_ProductOffering.Name, subDetails.ProductOffering.Name);
      Assert.AreEqual(m_ProductOffering.DisplayName, subDetails.ProductOffering.DisplayName);

      Assert.AreEqual(m_ProductOffering.AvailableTimeSpan.StartDate, subDetails.ProductOffering.AvailableTimeSpan.StartDate);
      Assert.AreEqual(m_ProductOffering.AvailableTimeSpan.EndDate, subDetails.ProductOffering.AvailableTimeSpan.EndDate);

      Assert.AreEqual(m_ProductOffering.EffectiveTimeSpan.StartDate, subDetails.ProductOffering.EffectiveTimeSpan.StartDate);
      Assert.AreEqual(m_ProductOffering.EffectiveTimeSpan.EndDate, subDetails.ProductOffering.EffectiveTimeSpan.EndDate);
      #endregion
    }

    /// <summary>
    /// Test UpdateSubscription Method by updating start date
    /// </summary>
    /// <remarks>
    /// This method tests the UpdateSubscription method of the SubscriptionService by updating
    /// the start date of the subscription created in the TestAddSubscription test.  
    /// The method then validates the results from the SubscriptionService with the results from 
    /// the legacy APIs.  
    /// </remarks>
    [Test]
    public void T06TestUpdateSubscriptionStartDate()
    {
      #region Update Subscription Start Date
      Subscription updateSub = new Subscription();
      updateSub.SubscriptionId = m_Subscription.SubscriptionId;
      updateSub.SubscriptionSpan = new ProdCatTimeSpan();
      updateSub.SubscriptionSpan.StartDate = m_Subscription.SubscriptionSpan.StartDate.Value.AddDays(2);

      try
      {
        Client.UpdateSubscription(new AccountIdentifier(m_CoreSubId), updateSub);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }
      #endregion

      #region Get Update Subcription Details
      Subscription subDetails = null;

      try
      {
        Client.GetSubscriptionDetail(new AccountIdentifier(m_CoreSubId), (int)m_Subscription.SubscriptionId, out subDetails);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }

      Assert.AreNotEqual(null, subDetails);
      #endregion

      #region Validate Results
      Assert.AreEqual(m_Subscription.SubscriptionId, subDetails.SubscriptionId);
      Assert.AreEqual(m_Subscription.ProductOfferingId, subDetails.ProductOfferingId);

      DateTime startDate = m_Subscription.SubscriptionSpan.StartDate.Value.AddDays(2);
      DateTime testDate = new DateTime(startDate.Year, startDate.Month, startDate.Day, 0, 0, 0);
      Assert.AreEqual(testDate, subDetails.SubscriptionSpan.StartDate);
      #endregion
    }

    /// <summary>
    /// Test UpdateSubscription Method by updating end date
    /// </summary>
    /// <remarks>
    /// This method tests the UpdateSubscription method of the SubscriptionService by updating
    /// the end date of the subscription created in the TestAddSubscription test.  
    /// The method then validates the results from the SubscriptionService with the results from 
    /// the legacy APIs.  
    /// </remarks>
    [Test]
    public void T07TestUpdateSubscriptionEndDate()
    {
      #region Update Subscription Start Date
      Subscription updateSub = new Subscription();
      updateSub.SubscriptionId = m_Subscription.SubscriptionId;
      updateSub.SubscriptionSpan = new ProdCatTimeSpan();
      updateSub.SubscriptionSpan.EndDate = m_Subscription.SubscriptionSpan.EndDate.Value.AddDays(-10);

      try
      {
        Client.UpdateSubscription(new AccountIdentifier(m_CoreSubId), updateSub);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }
      #endregion

      #region Get Update Subcription Details
      Subscription subDetails = null;

      try
      {
        Client.GetSubscriptionDetail(new AccountIdentifier(m_CoreSubId), (int)m_Subscription.SubscriptionId, out subDetails);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }


      Assert.AreNotEqual(null, subDetails);
      #endregion

      #region Validate Results
      Assert.AreEqual(m_Subscription.SubscriptionId, subDetails.SubscriptionId);
      Assert.AreEqual(m_Subscription.ProductOfferingId, subDetails.ProductOfferingId);

      // Need to subtract only 9 days and one second to get the correct end date/time
      DateTime endDate = m_Subscription.SubscriptionSpan.EndDate.Value.AddDays(-10);
      DateTime testDate = new DateTime(endDate.Year, endDate.Month, endDate.Day, 23, 59, 59);
      Assert.AreEqual(testDate, subDetails.SubscriptionSpan.EndDate);
      #endregion
    }

    /// <summary>
    /// Test DeleteSubscription Method
    /// </summary>
    /// <remarks>
    /// This method tests the DeleteSubscription method of the SubscriptionService by deleting
    /// the subscription created in the TestAddSubscription test.  The method then validates 
    /// the results by querying for the subscription existence from boht the SubscriptionService 
    /// and the legacy APIs.  
    /// </remarks>
    [Test]
    public void T08TestDeleteSubscription()
    {
      #region Delete subscription
      try
      {
        Client.DeleteSubscription(new AccountIdentifier(m_CoreSubId), (int)m_Subscription.SubscriptionId);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        string err = fe.Message;

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          err += "\\n" + msg;
        }

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        throw new ApplicationException(err);
      }

      #endregion

      string svcError = "";
      string prodCatError = "";
      #region Try getting service sub details
      try
      {
        Subscription subDetails = null;

        Client.GetSubscriptionDetail(new AccountIdentifier(m_CoreSubId), (int)m_Subscription.SubscriptionId, out subDetails);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        svcError = fe.Detail.ErrorMessages[0];

        m_ServiceClient.Abort();
        m_ServiceClient = null;

        Assert.AreEqual("The specified subscription could not be found", svcError);
      }
      #endregion

      #region Try getting product catalog subscription
      try
      {
        IMTSubscriptionBase subBase = m_pcAcct.GetSubscription((int)m_Subscription.SubscriptionId);

        Assert.AreEqual(null, subBase);
      }
      catch (COMException comE)
      {
        prodCatError = comE.Message;

        Assert.AreNotEqual("", prodCatError);
      }
      #endregion
    }
    #endregion

  }
}
