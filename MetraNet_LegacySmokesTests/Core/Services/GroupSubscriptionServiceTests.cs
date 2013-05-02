using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using NUnit.Framework;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.AccountTypes;


//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.GroupSubscriptionServiceTests /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//

namespace MetraTech.Core.Services.Test
{
  /// <summary>
  /// GroupSubscription Service Tests
  /// </summary>
  /// <remarks>
  /// The GroupSubscriptionServiceTests class implements NUnit tests for the core GroupSubscriptionService.
  /// This service provides methods that allow clients to interact with the group subscriptions feature
  /// of the MetraNet system.  
  /// </remarks>
  [Category("NoAutoRun")]
  [TestFixture]
  public class GroupSubscriptionServiceTests
  {
    #region Test Initialization and Cleanup
    /// <summary>
    ///   Initialize data for group subscription service tests.
    /// </summary>
    [TestFixtureSetUp]
    public void Setup()
    {
      try
      {
        logger = new Logger("Logging\\GroupSubscriptionServiceTests", "[GroupSubscriptionServiceTests]");

        #region Create the Product Catalog
        IMTLoginContext loginContext = new MTLoginContextClass();
        sessionContext =
          (MetraTech.Interop.MTProductCatalog.IMTSessionContext)loginContext.Login("su", "system_user", "su123");

        productCatalog = new MTProductCatalogClass();
        productCatalog.SetSessionContext(sessionContext);
        #endregion

        #region Create Flat Rate Recurring Charges

        #region Flat Rate Recurring Charge Per Participant
        piTemplate_FRRC_ChargePerParticipant = CreateFlatRateRecurringCharge(true);
        #endregion

        #region Flat Rate Recurring Charge Per Subscription
        piTemplate_FRRC_ChargePerSub = CreateFlatRateRecurringCharge(false);
        #endregion

        #endregion

        #region Create UDRC's

        #region UDRC Per Participant
        piTemplate_UDRC_ChargePerParticipant = CreateUDRC(true);
        #endregion

        #region UDRC Per Subscription
        piTemplate_UDRC_ChargePerSub = CreateUDRC(false);
        #endregion

        #endregion

        #region Create a Product Offering
        List<IMTRecurringCharge> charges = new List<IMTRecurringCharge>();
        charges.Add(piTemplate_FRRC_ChargePerParticipant);
        charges.Add(piTemplate_FRRC_ChargePerSub);
        charges.Add(piTemplate_UDRC_ChargePerParticipant);
        charges.Add(piTemplate_UDRC_ChargePerSub);

        mtProductOffering = CreateProductOffering(charges);
        #endregion

        #region Create a Corporate Account
        // Create the internal view
        internalView = (InternalView)View.CreateView(@"metratech.com/internal");
        internalView.UsageCycleType = UsageCycleType.Monthly;
        internalView.Billable = true;
        internalView.SecurityQuestion = SecurityQuestion.MothersMaidenName;
        internalView.Language = LanguageCode.US;
        internalView.Currency = SystemCurrencies.USD.ToString();
        internalView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

        // Create the billToContactView
        billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
        billToContactView.ContactType = ContactType.Bill_To;
        billToContactView.FirstName = "Boris";
        billToContactView.LastName = "Boruchovich";
        //billToContactView.Country = CountryName.Russia;

        // Create the shipToContactView
        shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
        shipToContactView.ContactType = ContactType.Ship_To;
        shipToContactView.FirstName = "Harvinder";
        shipToContactView.LastName = "Singh";
        //shipToContactView.Country = CountryName.India;

        // Create the AddAccount client
        addAccountClient = new AccountCreation_AddAccount_Client();
        addAccountClient.UserName = userName;
        addAccountClient.Password = password;

        corporateAccount = CreateCorporateAccount();
        #endregion
       
      }
      catch (Exception e)
      {
        logger.LogException("Error setting up GroupSubscriptionTests", e);
        throw e;
      }
    }

    /// <summary>
    /// Restore system to state prior the test run.  This currently does nothing.
    /// </summary>
    [TestFixtureTearDown]
    public void TearDown()
    {
      // Do nothing
    }
    #endregion

    #region Test Methods
    /// <summary>
    /// GetProductOfferingsForGroupSubscriptions Method
    /// </summary>
    /// <remarks>
    ///   Test that the product offering created during Setup() is found.
    /// </remarks>
    [Test]
    [Category("GetProductOfferingsForGroupSubscriptions")]
    public void T01GetProductOfferingsForGroupSubscriptions()
    {
      string method = "'GetProductOfferingsForGroupSubscriptions'";
      logger.LogDebug("Testing " + method);

      GroupSubscriptionService_GetProductOfferingsForGroupSubscriptions_Client
        client = new GroupSubscriptionService_GetProductOfferingsForGroupSubscriptions_Client();

      MTList<ProductOffering> productOfferings = new MTList<ProductOffering>();
      client.UserName = userName;
      client.Password = password;
      client.In_acct = new AccountIdentifier(corporateAccount._AccountID.Value);
      client.In_effectiveDate = DateTime.Now;
      client.InOut_productOfferings = productOfferings;
 
      client.Invoke();

      productOfferings = client.InOut_productOfferings;

      bool foundProductOffering = false;

      foreach (ProductOffering productOffering in productOfferings.Items)
      {
        if (productOffering.ProductOfferingId == mtProductOffering.ID)
        {
          foundProductOffering = true;
          break;
        }
      }

      Assert.IsTrue(foundProductOffering, 
                    String.Format("Expected to find Product Offering with name '{0}' and id '{1}'", 
                                  mtProductOffering.DisplayName, mtProductOffering.ID));

      logger.LogDebug("Finished testing " + method);
    }

    /// <summary>
    /// GetFlatRateRecurringChargeInstancesForPO Method
    /// </summary>
    /// <remarks>
    ///   Retrieve the Flat Rate Recurring Charges for the Product offering created during setup.
    /// </remarks>
    [Test]
    [Category("GetFlatRateRecurringChargeInstancesForPO")]
    public void T02GetFlatRateRecurringChargeInstancesForPO()
    {
      string method = "'GetFlatRateRecurringChargeInstancesForPO'";
      logger.LogDebug("Testing " + method);

      GroupSubscriptionService_GetFlatRateRecurringChargeInstancesForPO_Client
        flatRateClient = new GroupSubscriptionService_GetFlatRateRecurringChargeInstancesForPO_Client();
      flatRateClient.In_productOfferingId = mtProductOffering.ID;
      flatRateClient.UserName = userName;
      flatRateClient.Password = password;
      flatRateClient.Invoke();

      List<FlatRateRecurringChargeInstance> charges = flatRateClient.Out_flatRateRecurringChargeInstances;

      Assert.IsNotNull(charges, "Expected two flat rate recurring charges");
      Assert.AreEqual(2, charges.Count, "Expected two flat rate recurring charges");

      foreach (FlatRateRecurringChargeInstance charge in charges)
      {
        if (charge.Name == piTemplate_FRRC_ChargePerParticipant.Name)
        {
          Assert.AreEqual(true, charge.ChargePerParticipant, "Mismatched Flat Rate 'Charge Per Particpant");
        }
        else if (charge.Name == piTemplate_FRRC_ChargePerSub.Name)
        {
          Assert.AreEqual(false, charge.ChargePerParticipant, "Mismatched Flat Rate 'Charge Per Subscription");
        }
        else
        {
          Assert.Fail("Unexpected flat rate recurring charge found");
        }
      }

      logger.LogDebug("Finished testing " + method);
    }

    /// <summary>
    /// GetUDRCInstancesForPO Method
    /// </summary>
    /// <remarks>
    ///   Retrieve the UDRC's for the Product offering created during setup.
    /// </remarks>
    [Test]
    [Category("GetUDRCInstancesForPO")]
    public void T03GetUDRCInstancesForPO()
    {
      string method = "'GetUDRCInstancesForPO'";
      logger.LogDebug("Testing " + method);

      SubscriptionService_GetUDRCInstancesForPO_Client
        udrcClient = new SubscriptionService_GetUDRCInstancesForPO_Client();
      udrcClient.In_productOfferingId = mtProductOffering.ID;
      udrcClient.UserName = userName;
      udrcClient.Password = password;
      udrcClient.Invoke();

      List<UDRCInstance> charges = udrcClient.Out_udrcInstances;

      Assert.IsNotNull(charges, "Expected two UDRC's");
      Assert.AreEqual(2, charges.Count, "Expected two UDRC's");

      foreach (UDRCInstance charge in charges)
      {
        if (charge.Name == piTemplate_UDRC_ChargePerParticipant.Name)
        {
          Assert.AreEqual(true, charge.ChargePerParticipant, "Mismatched 'UDRC Charge Per Particpant");
        }
        else if (charge.Name == piTemplate_UDRC_ChargePerSub.Name)
        {
          Assert.AreEqual(false, charge.ChargePerParticipant, "Mismatched 'UDRC Charge Per Subscription");
        }
        else
        {
          Assert.Fail("Unexpected flat rate recurring charge found");
        }
      }

      logger.LogDebug("Finished testing " + method);
    }
    
     /// <summary>
    /// AddGroupSubscription Method
    /// </summary>
    /// <remarks>
    ///   Create a group subscription
    /// </remarks>
    [Test]
    [Category("AddGroupSubscription")]
    public void T04AddGroupSubscription()
    {
      string method = "'AddGroupSubscription'";
      logger.LogDebug("Testing " + method);

      List<int> accountIds = new List<int>();
      CoreSubscriber coreSubscriber = null;
      for (int i = 0; i < 3; i++)
      {
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        Assert.IsNotNull(coreSubscriber);

        accountIds.Add(coreSubscriber._AccountID.Value);
      }

      GroupSubscription groupSubscription = 
        CreateGroupSubscription(mtProductOffering.ID, 
                                corporateAccount._AccountID.Value, 
                                accountIds);

      CheckGroupSubscription(groupSubscription);
     
      logger.LogDebug("Finished testing " + method);
    }
    

    /// <summary>
    /// GetGroupSubscriptionsForMemberAccount Method
    /// </summary>
    /// <remarks>
    ///   Create two group subscriptions with the coreSubscriber accounts as members.
    ///   Check that the two group subscriptions are retrieved for a given coreSubscriber account.
    ///   
    /// </remarks>
    [Test]
    [Category("GetGroupSubscriptionsForMemberAccount")]
    public void T05GetGroupSubscriptionsForMemberAccount()
    {
      string method = "'GetGroupSubscriptionsForMemberAccount'";
      logger.LogDebug("Testing " + method);

      CoreSubscriber coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
      List<int> accountIds = new List<int>();
      accountIds.Add(coreSubscriber._AccountID.Value);

      GroupSubscription groupSub1 = 
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value, 
                                accountIds);

      List<IMTRecurringCharge> charges = new List<IMTRecurringCharge>();
      charges.Add(CreateUDRC(true));
      IMTProductOffering productOffering = CreateProductOffering(charges);
      GroupSubscription groupSub2 =
        CreateGroupSubscription(productOffering.ID,
                                corporateAccount._AccountID.Value, 
                                accountIds);

      MTList<GroupSubscription> groupSubscriptions = new MTList<GroupSubscription>();

      GroupSubscriptionService_GetGroupSubscriptionsForMemberAccount_Client
        client = new GroupSubscriptionService_GetGroupSubscriptionsForMemberAccount_Client();
      client.UserName = userName;
      client.Password = password;
      client.In_acct = new AccountIdentifier(coreSubscriber._AccountID.Value);
      client.InOut_groupSubs = groupSubscriptions;
      client.Invoke();

      Assert.AreEqual(2, client.InOut_groupSubs.Items.Count);

      foreach (GroupSubscription groupSubscription in client.InOut_groupSubs.Items)
      {
        if (groupSubscription.GroupId != groupSub1.GroupId &&
            groupSubscription.GroupId != groupSub2.GroupId)
        {
          Assert.Fail("Mismatched group subscriptions");
        }
      }

      logger.LogDebug("Finished testing " + method);
    }

    /// <summary>
    /// GetGroupSubscriptionsForCorporateAccount Method
    /// </summary>
    /// <remarks>
    ///   Create a corporate account.
    ///   Create two group subscriptions with the corporate account as the owner
    ///   Check that the two group subscriptions are retrieved for 
    ///   the given corporate account.
    ///   
    /// </remarks>
    [Test]
    [Category("GetGroupSubscriptionsForCorporateAccount")]
    public void T06GetGroupSubscriptionsForCorporateAccount()
    {
      string method = "'GetGroupSubscriptionsForCorporateAccount'";
      logger.LogDebug("Testing " + method);

      CorporateAccount account = CreateCorporateAccount();

      // Create member
      CoreSubscriber coreSubscriber = CreateCoreSubscriber(account._AccountID.Value);

      List<int> accountIds = new List<int>();
      accountIds.Add(coreSubscriber._AccountID.Value);
      
      // First group subscription
      GroupSubscription groupSub1 =
        CreateGroupSubscription(mtProductOffering.ID,
                                account._AccountID.Value,
                                accountIds);

      // New charge, new product offering
      List<IMTRecurringCharge> charges = new List<IMTRecurringCharge>();
      charges.Add(CreateUDRC(true));
      IMTProductOffering productOffering = CreateProductOffering(charges);
      // Second group subscription
      GroupSubscription groupSub2 =
        CreateGroupSubscription(productOffering.ID,
                                account._AccountID.Value,
                                accountIds);

      MTList<GroupSubscription> groupSubscriptions = new MTList<GroupSubscription>();

      GroupSubscriptionService_GetGroupSubscriptionsForCorporateAccount_Client
        client = new GroupSubscriptionService_GetGroupSubscriptionsForCorporateAccount_Client();
      client.UserName = userName;
      client.Password = password;
      client.In_acct = new AccountIdentifier(account._AccountID.Value);
      client.InOut_groupSubs = groupSubscriptions;
      client.Invoke();

      Assert.AreEqual(2, client.InOut_groupSubs.Items.Count);

      foreach (GroupSubscription groupSubscription in client.InOut_groupSubs.Items)
      {
        if (groupSubscription.GroupId != groupSub1.GroupId &&
            groupSubscription.GroupId != groupSub2.GroupId)
        {
          Assert.Fail("Mismatched group subscriptions");
        }
      }

      logger.LogDebug("Finished testing " + method);
    }
    
    
    
    /// <summary>
    /// AddMembersToGroupSubscription Method
    /// </summary>
    /// <remarks>
    ///   Create a group subscription.
    ///   Add new members.
    ///   Verify that new members were added
    ///    
    /// </remarks>
    [Test]
    [Category("AddMembersToGroupSubscription")]
    public void T07AddMembersToGroupSubscription()
    {
      string method = "'AddMembersToGroupSubscription'";
      logger.LogDebug("Testing " + method);

      CoreSubscriber coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
      List<int> accountIds = new List<int>();
      accountIds.Add(coreSubscriber._AccountID.Value);

      GroupSubscription groupSub =
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value,
                                accountIds);

      List<GroupSubscriptionMember> newMembers = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMember = null;

      for (int i = 0; i < 2; i++)
      {
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        gsubMember = new GroupSubscriptionMember();
        gsubMember.AccountId = coreSubscriber._AccountID.Value;
        gsubMember.MembershipSpan = new ProdCatTimeSpan();
        gsubMember.MembershipSpan.StartDate = groupSub.SubscriptionSpan.StartDate;
        newMembers.Add(gsubMember);
      }

      GroupSubscriptionService_AddMembersToGroupSubscription_Client addMembersClient =
        new GroupSubscriptionService_AddMembersToGroupSubscription_Client();
      addMembersClient.UserName = userName;
      addMembersClient.Password = password;
      addMembersClient.In_groupSubscriptionId = groupSub.GroupId.Value;
      addMembersClient.In_groupSubscriptionMembers = newMembers;
      addMembersClient.Invoke();

      MTList<GroupSubscriptionMember> outMembers = new MTList<GroupSubscriptionMember>();

      // Retrieve the members and check that they match
      GroupSubscriptionService_GetMembersForGroupSubscription2_Client getMembersClient =
        new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
      getMembersClient.UserName = userName;
      getMembersClient.Password = password;
      getMembersClient.In_groupSubscriptionId = groupSub.GroupId.Value;
      getMembersClient.InOut_groupSubscriptionMembers = outMembers;
      getMembersClient.Invoke();


      foreach (GroupSubscriptionMember newMember in newMembers)
      {
        bool found = false;
        foreach (GroupSubscriptionMember dbGsubMember in getMembersClient.InOut_groupSubscriptionMembers.Items)
        {
          if (dbGsubMember.AccountId.Value == newMember.AccountId.Value)
          {
            found = true;
            break;
          }
        }

        Assert.IsTrue(found, "Unable to find new member");
      }

      logger.LogDebug("Finished testing " + method);
    }

    
    /// <summary>
    /// DeleteMembersFromGroupSubscription Method
    /// </summary>
    /// <remarks>
    ///   Create a group subscription with members.
    ///   Delete some members.
    ///   Verify that deleted members are removed from database.
    ///    
    /// </remarks>
    [Test]
    [Category("DeleteMembersFromGroupSubscription")]
    public void T08DeleteMembersFromGroupSubscription()
    {
      string method = "'DeleteMembersFromGroupSubscription'";
      logger.LogDebug("Testing " + method);

      CoreSubscriber coreSubscriber = null;
      List<int> accountIds = new List<int>();
      for (int i = 0; i < 4; i++)
      {
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        accountIds.Add(coreSubscriber._AccountID.Value);
      }

      GroupSubscription groupSub =
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value,
                                accountIds);

      List<GroupSubscriptionMember> deletedMembers = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMember = null;

      for (int i = 0; i < 2; i++)
      {
        gsubMember = new GroupSubscriptionMember();
        gsubMember.AccountId = accountIds[i];
        gsubMember.MembershipSpan = new ProdCatTimeSpan();
        gsubMember.MembershipSpan.StartDate = groupSub.SubscriptionSpan.StartDate;
        gsubMember.MembershipSpan.EndDate = groupSub.SubscriptionSpan.EndDate;
        deletedMembers.Add(gsubMember);
      }

      GroupSubscriptionService_DeleteMembersFromGroupSubscription_Client deleteMembersClient =
        new GroupSubscriptionService_DeleteMembersFromGroupSubscription_Client();
      deleteMembersClient.UserName = userName;
      deleteMembersClient.Password = password;
      deleteMembersClient.In_groupSubscriptionId = groupSub.GroupId.Value;
      deleteMembersClient.In_groupSubscriptionMembers = deletedMembers;
      deleteMembersClient.Invoke();

      // Retrieve the members and check that two accounts have gone
      GroupSubscriptionService_GetMembersForGroupSubscription2_Client getMembersClient =
        new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
      getMembersClient.UserName = userName;
      getMembersClient.Password = password;
      getMembersClient.In_groupSubscriptionId = groupSub.GroupId.Value;
      MTList<GroupSubscriptionMember> outMembers = new MTList<GroupSubscriptionMember>();
      getMembersClient.InOut_groupSubscriptionMembers = outMembers;
      getMembersClient.Invoke();

      Assert.AreEqual(2, getMembersClient.InOut_groupSubscriptionMembers.Items.Count);

      foreach (GroupSubscriptionMember member in getMembersClient.InOut_groupSubscriptionMembers.Items)
      {
        if (member.AccountId.Value == accountIds[0] ||
            member.AccountId.Value == accountIds[1])
        {
          Assert.Fail("Deleted members found");
        }

        if (member.AccountId.Value != accountIds[2] &&
            member.AccountId.Value != accountIds[3])
        {
          Assert.Fail("Remaining members not found");
        }
      }

      logger.LogDebug("Finished testing " + method);
    }
    /*
    /// <summary>
    /// UpdateGroupSubscription Method
    /// </summary>
    /// <remarks>
    ///   Create a group subscription.
    ///   Update the group subscription.
    ///   Verify that updates are in the database.
    ///    
    /// </remarks>
    [Test]
    [Category("UpdateGroupSubscription")]
    public void UpdateGroupSubscription()
    {
      string method = "'UpdateGroupSubscription'";
      logger.LogDebug("Testing " + method);

      CoreSubscriber coreSubscriber = null;
      List<int> accountIds = new List<int>();
      for (int i = 0; i < 2; i++)
      {
        Thread.Sleep(1000);
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        accountIds.Add(coreSubscriber._AccountID.Value);
      }
      
      GroupSubscription groupSub =
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value,
                                accountIds);

      // Load
      GroupSubscriptionService_GetGroupSubscriptionDetail_Client detailClient =
        new GroupSubscriptionService_GetGroupSubscriptionDetail_Client();
      detailClient.UserName = userName;
      detailClient.Password = password;
      detailClient.In_groupSubscriptionId = groupSub.GroupId.Value;
      detailClient.Invoke();

      // Update
      GroupSubscription dbGroupSub = detailClient.Out_groupSubscription;
      dbGroupSub.Name = string.Format("GS_{0}_{1}", Counter, Uniqueifier);
      dbGroupSub.Description = "New Description";
      dbGroupSub.ProportionalDistribution = false;
      dbGroupSub.DiscountAccountId = accountIds[1];
      dbGroupSub.SupportsGroupOperations = true;

      // Save
      GroupSubscriptionService_UpdateGroupSubscription_Client updateClient = 
        new GroupSubscriptionService_UpdateGroupSubscription_Client();
      updateClient.UserName = userName;
      updateClient.Password = password;
      updateClient.In_groupSubscription = dbGroupSub;
      updateClient.Invoke();

      // Load
      detailClient.Invoke();

      // Validate
      GroupSubscription updatedGroupSub = detailClient.Out_groupSubscription;

      Assert.AreEqual(dbGroupSub.Name, updatedGroupSub.Name);
      Assert.AreEqual(dbGroupSub.Description, updatedGroupSub.Description);
      Assert.AreEqual(dbGroupSub.ProportionalDistribution, updatedGroupSub.ProportionalDistribution);
      Assert.AreEqual(dbGroupSub.DiscountAccountId, updatedGroupSub.DiscountAccountId);
      Assert.AreEqual(dbGroupSub.SupportsGroupOperations, updatedGroupSub.SupportsGroupOperations);


      logger.LogDebug("Finished testing " + method);
    }
 */


    /// <summary>
    /// AddMemberHierarchiesToGroupSubscription Method
    /// </summary>
    /// <remarks>
    ///  Add members hierarchies to a group subscription. 
    /// Verify that the member hieararchies get added to the group subscription.
    /// </remarks>
    [Test]
    [Category("AddMemberHierarchiesToGroupSubscription")]
    public void T10AddMemberHierarchiesToGroupSubscription()
    {
      string method = "'AddMemberHierarchiesToGroupSubscription'";
      logger.LogDebug("Testing " + method);

     CoreSubscriber coreSubscriber = null;
      List<int> accountIds = new List<int>();
      for (int i = 0; i < 2; i++)
      {
        Thread.Sleep(1000);
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        accountIds.Add(coreSubscriber._AccountID.Value);
      }

      GroupSubscription groupSub =
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value,
                                accountIds);

      GroupSubscriptionService_AddMemberHierarchiesToGroupSubscription_Client addMembHierToGroupSubscriptionClient =
        new  GroupSubscriptionService_AddMemberHierarchiesToGroupSubscription_Client();

      List<int> memberIds = new List<int>();
      for (int i = 0; i < 2; i++)
      {
        Thread.Sleep(1000);
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        memberIds.Add(coreSubscriber._AccountID.Value);
      }

      Dictionary<AccountIdentifier, AccountTemplateScope> dictionary = new Dictionary<AccountIdentifier, AccountTemplateScope>();
      AccountIdentifier accountIdentifier1 = new AccountIdentifier(memberIds[0]);
      AccountIdentifier accountIdentifier2 = new AccountIdentifier(memberIds[1]);
      dictionary.Add(accountIdentifier1, AccountTemplateScope.CURRENT_FOLDER);
      dictionary.Add(accountIdentifier2, AccountTemplateScope.CURRENT_FOLDER);

      addMembHierToGroupSubscriptionClient.In_accounts = dictionary;
      addMembHierToGroupSubscriptionClient.In_groupSubscriptionId = groupSub.GroupId.Value;
      addMembHierToGroupSubscriptionClient.In_subscriptionSpan = new ProdCatTimeSpan();
      addMembHierToGroupSubscriptionClient.In_subscriptionSpan.StartDate = groupSub.SubscriptionSpan.StartDate;
      addMembHierToGroupSubscriptionClient.In_subscriptionSpan.EndDate = groupSub.SubscriptionSpan.EndDate;
      addMembHierToGroupSubscriptionClient.UserName = userName;
      addMembHierToGroupSubscriptionClient.Password = password;
      addMembHierToGroupSubscriptionClient.Invoke();


      MTList<GroupSubscriptionMember> groupSubMembers = new MTList<GroupSubscriptionMember>();

      GroupSubscriptionService_GetMembersForGroupSubscription2_Client getGroupSubMembers =
        new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
      getGroupSubMembers.In_groupSubscriptionId = groupSub.GroupId.Value;
      getGroupSubMembers.InOut_groupSubscriptionMembers = groupSubMembers;
      getGroupSubMembers.UserName = userName;
      getGroupSubMembers.Password = password;
      getGroupSubMembers.Invoke();
      groupSubMembers = getGroupSubMembers.InOut_groupSubscriptionMembers;

      foreach (GroupSubscriptionMember gsubMember in groupSubMembers.Items)
      {
        if (gsubMember.AccountId == accountIdentifier1.AccountID)
        {
          Assert.AreEqual(gsubMember.AccountId, accountIdentifier1.AccountID);
        }
        else if (gsubMember.AccountId == accountIdentifier2.AccountID)
        {
          Assert.AreEqual(gsubMember.AccountId, accountIdentifier2.AccountID);
        }

      }

       logger.LogDebug("Finished testing " + method);
    }

    /*
    /// <summary>
    /// DeleteGroupSubscription Method
    /// </summary>
    /// <remarks>
    ///  Deletes a group subscription.
    /// </remarks>
    [Test]
    [Category("DeleteGroupSubscription")]
    public void DeleteGroupSubscription()
    {
      string method = "'DeleteGroupSubscription'";
      logger.LogDebug("Testing " + method);
      
      CoreSubscriber coreSubscriber = null;
      List<int> accountIds = new List<int>();
      for (int i = 0; i < 2; i++)
      {
        Thread.Sleep(1000);
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        accountIds.Add(coreSubscriber._AccountID.Value);
      }

      GroupSubscription groupSub =
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value,
                                accountIds);

      GroupSubscriptionService_DeleteGroupSubscription_Client deleteGroupSubscriptionClient =
        new GroupSubscriptionService_DeleteGroupSubscription_Client();
      deleteGroupSubscriptionClient.In_groupSubscriptionId = groupSub.GroupId.Value;
      deleteGroupSubscriptionClient.UserName = userName;
      deleteGroupSubscriptionClient.Password = password;
      deleteGroupSubscriptionClient.Invoke();
      
      logger.LogDebug("Finished testing " + method);
    }
    */

    /// <summary>
    /// GetGroupSubscriptionDetail Method
    /// </summary>
    /// <remarks>
    /// retrieves details of a group subscription.
    /// </remarks>
    [Test]
    [Category("GetGroupSubscriptionDetail")]
    public void T12GetGroupSubscriptionDetail()
    {
      string method = "'GetGroupSubscriptionDetail'";
      logger.LogDebug("Testing " + method);

      CoreSubscriber coreSubscriber = null;
      List<int> accountIds = new List<int>();
      for (int i = 0; i < 2; i++)
      {
        Thread.Sleep(1000);
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        accountIds.Add(coreSubscriber._AccountID.Value);
      }

      GroupSubscription groupSub =
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value,
                                accountIds);

     GroupSubscriptionService_GetGroupSubscriptionDetail_Client getGroupSubscriptionDetailClient =
        new GroupSubscriptionService_GetGroupSubscriptionDetail_Client();
     getGroupSubscriptionDetailClient.In_groupSubscriptionId = groupSub.GroupId.Value;
     getGroupSubscriptionDetailClient.UserName = userName;
     getGroupSubscriptionDetailClient.Password = password;
     getGroupSubscriptionDetailClient.Invoke();
     GroupSubscription outGroupSub = new GroupSubscription();
     outGroupSub = getGroupSubscriptionDetailClient.Out_groupSubscription;

     Assert.AreEqual(outGroupSub.Name, groupSub.Name);
     Assert.AreEqual(outGroupSub.Description, groupSub.Description);
     Assert.AreEqual(outGroupSub.ProportionalDistribution, groupSub.ProportionalDistribution);
     Assert.AreEqual(outGroupSub.DiscountAccountId, groupSub.DiscountAccountId);
     Assert.AreEqual(outGroupSub.SupportsGroupOperations, groupSub.SupportsGroupOperations);

     logger.LogDebug("Finished testing " + method);
    }



    /// <summary>
    /// GetMembersForGroupSubscription2 Method
    /// </summary>
    /// <remarks>
    /// retrieves group subscription members details for a specific group subscription
    /// </remarks>
    [Test]
    [Category("GetMembersForGroupSubscription2")]
    public void T13GetMembersForGroupSubscription2()
    {
      string method = "'GetMembersForGroupSubscription2'";
      logger.LogDebug("Testing " + method);

      CoreSubscriber coreSubscriber = null;
      List<int> accountIds = new List<int>();
      for (int i = 0; i < 2; i++)
      {
        Thread.Sleep(1000);
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        accountIds.Add(coreSubscriber._AccountID.Value);
      }

      GroupSubscription groupSub =
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value,
                                accountIds);

      MTList<GroupSubscriptionMember> groupSubMembers = new MTList<GroupSubscriptionMember>();

      GroupSubscriptionService_GetMembersForGroupSubscription2_Client getGroupSubMembers =
        new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
      getGroupSubMembers.In_groupSubscriptionId = groupSub.GroupId.Value;
      getGroupSubMembers.InOut_groupSubscriptionMembers = groupSubMembers;
      getGroupSubMembers.UserName = userName;
      getGroupSubMembers.Password = password;
      getGroupSubMembers.Invoke();
      groupSubMembers = getGroupSubMembers.InOut_groupSubscriptionMembers;

      foreach (GroupSubscriptionMember gsm in groupSubMembers.Items)
      {
        if (gsm.AccountId == accountIds[0])
        {
          Assert.AreEqual(gsm.AccountId, accountIds[0]);
        }
        else
        {
          if (gsm.AccountId == accountIds[1])
          {
            Assert.AreEqual(gsm.AccountId, accountIds[1]);
          }
        }
      }

      logger.LogDebug("Finished testing " + method);
    }

    /// <summary>
    ///UnsubscribeGroupSubscriptionMember Method
    /// </summary>
    /// <remarks>
    /// unsubscribes group subscription member/members from the group subscription
    /// </remarks>
    [Test]
    [Category("UnsubscribeGroupSubscriptionMembers")]
    public void T14UnsubscribeGroupSubscriptionMembers()
    {
      string method = "'UnsubscribeGroupSubscriptionMembers'";
      logger.LogDebug("Testing " + method);

      CoreSubscriber coreSubscriber = null;
      List<int> accountIds = new List<int>();
      for (int i = 0; i < 2; i++)
      {
        Thread.Sleep(1000);
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        accountIds.Add(coreSubscriber._AccountID.Value);
      }

      GroupSubscription groupSub =
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value,
                                accountIds);


      List<GroupSubscriptionMember> groupSubMembers = new List<GroupSubscriptionMember>();
      GroupSubscriptionService_UnsubscribeGroupSubscriptionMembers_Client unsubscribeGroupSubMemClient = new 
        GroupSubscriptionService_UnsubscribeGroupSubscriptionMembers_Client();
      GroupSubscriptionMember groupSubMember = new GroupSubscriptionMember();
      groupSubMember.GroupId = groupSub.GroupId;
      groupSubMember.MembershipSpan.StartDate = groupSub.SubscriptionSpan.StartDate;
      DateTime membershipEndDate = groupSubMember.MembershipSpan.StartDate.Value.AddDays(1);
      groupSubMember.MembershipSpan.EndDate = membershipEndDate;
      groupSubMember.AccountId = accountIds[0];
      groupSubMembers.Add(groupSubMember);
      unsubscribeGroupSubMemClient.In_groupSubscriptionMembers = groupSubMembers;
      unsubscribeGroupSubMemClient.UserName = userName;
      unsubscribeGroupSubMemClient.Password = password;
      unsubscribeGroupSubMemClient.Invoke();

      GroupSubscriptionService_GetMembersForGroupSubscription2_Client getGroupSubMembers =
        new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
      getGroupSubMembers.In_groupSubscriptionId = groupSub.GroupId.Value;
      getGroupSubMembers.UserName = userName;
      getGroupSubMembers.Password = password;
      MTList<GroupSubscriptionMember> groupSubMemList = new MTList<GroupSubscriptionMember>();
      getGroupSubMembers.InOut_groupSubscriptionMembers = groupSubMemList;
      getGroupSubMembers.Invoke();
    
      groupSubMemList = getGroupSubMembers.InOut_groupSubscriptionMembers;

      Assert.AreEqual(2, groupSubMemList.Items.Count);

      foreach (GroupSubscriptionMember member in groupSubMemList.Items)
      {
        if (member.AccountId == accountIds[0])
        {
          Assert.AreEqual(member.MembershipSpan.EndDate.Value.Date, membershipEndDate.Date);
        }
      }

      logger.LogDebug("Finished testing " + method);
    }


    /// <summary>
    ///UpdateGroupSubscriptionMember Method
    /// </summary>
    /// <remarks>
    /// update group subscription member's info
    /// </remarks>
    [Test]
    [Category("UpdateGroupSubscriptionMember")]
    public void T15UpdateGroupSubscriptionMember()
    {
      string method = "'UpdateGroupSubscriptionMember'";
      logger.LogDebug("Testing " + method);

      CoreSubscriber coreSubscriber = null;
      List<int> accountIds = new List<int>();
      for (int i = 0; i < 2; i++)
      {
        Thread.Sleep(1000);
        coreSubscriber = CreateCoreSubscriber(corporateAccount._AccountID.Value);
        accountIds.Add(coreSubscriber._AccountID.Value);
      }

      GroupSubscription groupSub =
        CreateGroupSubscription(mtProductOffering.ID,
                                corporateAccount._AccountID.Value,
                                accountIds);


      GroupSubscriptionService_UpdateGroupSubscriptionMember_Client updateGroupSubMemClient = new
        GroupSubscriptionService_UpdateGroupSubscriptionMember_Client();
      GroupSubscriptionMember groupSubMember = new GroupSubscriptionMember();
      groupSubMember.GroupId = groupSub.GroupId;
      DateTime membershipStartDate = groupSub.SubscriptionSpan.StartDate.Value.AddDays(1);
      groupSubMember.MembershipSpan.StartDate = membershipStartDate;
      groupSubMember.MembershipSpan.EndDate = groupSub.SubscriptionSpan.EndDate;
      groupSubMember.AccountId = accountIds[0];
      updateGroupSubMemClient.In_groupSubscriptionMember = groupSubMember;
      updateGroupSubMemClient.UserName = userName;
      updateGroupSubMemClient.Password = password;
      updateGroupSubMemClient.Invoke();

      MTList<GroupSubscriptionMember> groupSubMembers = new MTList<GroupSubscriptionMember>();
      GroupSubscriptionService_GetMembersForGroupSubscription2_Client getGroupSubMembers =
        new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
      getGroupSubMembers.In_groupSubscriptionId = groupSub.GroupId.Value;
      getGroupSubMembers.InOut_groupSubscriptionMembers = groupSubMembers;
      getGroupSubMembers.UserName = userName;
      getGroupSubMembers.Password = password;
      getGroupSubMembers.Invoke();
      groupSubMembers = getGroupSubMembers.InOut_groupSubscriptionMembers;

      Assert.AreEqual(2, groupSubMembers.Items.Count);

      foreach (GroupSubscriptionMember member in groupSubMembers.Items)
       {
         if(member.AccountId == accountIds[0])
         {
             Assert.AreEqual(member.MembershipSpan.StartDate.Value.Date, membershipStartDate.Date);
         }
       }

      logger.LogDebug("Finished testing " + method);
    }







    #endregion
    #region Private Properties
    private string Uniqueifier
    {
      get
      {
        return currentDate.ToString("s", DateTimeFormatInfo.InvariantInfo);
      }
    }

    private int counter = 0;
    private int Counter
    {
      get
      {
        return ++counter;
      }
    }
    #endregion

    #region Private Methods
    private GroupSubscription CreateGroupSubscription(int productOfferingId, 
                                                      int corporateAccountId, 
                                                      List<int> memberAccountIds)
    {
      GroupSubscription groupSubscription = new GroupSubscription();

      #region Initialize 
      
      groupSubscription.SubscriptionSpan = new ProdCatTimeSpan();
      groupSubscription.SubscriptionSpan.StartDate = DateTime.Now.AddDays(1);

      groupSubscription.ProductOfferingId = productOfferingId;
      groupSubscription.ProportionalDistribution = false;
      groupSubscription.DiscountAccountId = memberAccountIds[0];

      groupSubscription.Name = string.Format("GS_{0}_{1}", Counter, Uniqueifier);
      groupSubscription.Description = "Group Subscription Service Unit Test";
      groupSubscription.SupportsGroupOperations = true;
      groupSubscription.CorporateAccountId = corporateAccountId;
      Cycle cycle = new Cycle();
      cycle.CycleType = UsageCycleType.Monthly;
      cycle.DayOfMonth = 1;
      groupSubscription.Cycle = cycle;
      #endregion

      #region Create UDRCInstanceValue's

      SubscriptionService_GetUDRCInstancesForPO_Client udrcClient =
        new SubscriptionService_GetUDRCInstancesForPO_Client();
      udrcClient.In_productOfferingId = productOfferingId;
      udrcClient.UserName = userName;
      udrcClient.Password = password;
      udrcClient.Invoke();

      UDRCInstanceValue udrcInstanceValue = null;
      Dictionary<string, List<UDRCInstanceValue>> udrcValues =
        new Dictionary<string, List<UDRCInstanceValue>>();

      List<UDRCInstance> udrcInstances = udrcClient.Out_udrcInstances;
      foreach (UDRCInstance udrcInstance in udrcInstances)
      {
        List<UDRCInstanceValue> values = new List<UDRCInstanceValue>();

        udrcInstanceValue = new UDRCInstanceValue();
        udrcInstanceValue.UDRC_Id = udrcInstance.ID;
        udrcInstanceValue.Value = (udrcInstance.MinValue + udrcInstance.MaxValue) / 2;
        udrcInstanceValue.StartDate = groupSubscription.SubscriptionSpan.StartDate.Value;
        udrcInstanceValue.EndDate = MetraTime.Max;
        values.Add(udrcInstanceValue);

        udrcValues.Add(udrcInstance.ID.ToString(), values);

        // Setup Charge Account if necessary
        if (!udrcInstance.ChargePerParticipant)
        {
          // One of the core subscribers 
          udrcInstance.ChargeAccountId = memberAccountIds[0];
          udrcInstance.ChargeAccountSpan = new ProdCatTimeSpan();
          udrcInstance.ChargeAccountSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
        }
      }

      // Set the UDRCValues and UDRCInstances
      groupSubscription.UDRCValues = udrcValues;
      groupSubscription.UDRCInstances = udrcInstances;
      #endregion

      #region Set Flat Rate Recurring Charge Accounts
      GroupSubscriptionService_GetFlatRateRecurringChargeInstancesForPO_Client
        flatRateClient = new GroupSubscriptionService_GetFlatRateRecurringChargeInstancesForPO_Client();
      flatRateClient.In_productOfferingId = productOfferingId;
      flatRateClient.UserName = userName;
      flatRateClient.Password = password;
      flatRateClient.Invoke();

      List<FlatRateRecurringChargeInstance> flatRateRecurringChargeInstances =
        flatRateClient.Out_flatRateRecurringChargeInstances;

      foreach (FlatRateRecurringChargeInstance flatRateRC in
                flatRateRecurringChargeInstances)
      {
        if (!flatRateRC.ChargePerParticipant)
        {
          flatRateRC.ChargeAccountId = memberAccountIds[0];
          flatRateRC.ChargeAccountSpan = new ProdCatTimeSpan();
          flatRateRC.ChargeAccountSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
        }
      }

      groupSubscription.FlatRateRecurringChargeInstances = flatRateRecurringChargeInstances;
      #endregion

      #region Add Members
      groupSubscription.Members = new MTList<GroupSubscriptionMember>();

      foreach (int accountId in memberAccountIds)
      {
        GroupSubscriptionMember gSubMember = new GroupSubscriptionMember();
        gSubMember.AccountId = accountId;
        gSubMember.MembershipSpan = new ProdCatTimeSpan();
        gSubMember.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
        groupSubscription.Members.Items.Add(gSubMember);
      }
      #endregion

      #region Save the Group Subscription
      GroupSubscriptionService_AddGroupSubscription_Client addClient =
        new GroupSubscriptionService_AddGroupSubscription_Client();
      addClient.UserName = userName;
      addClient.Password = password;
      addClient.InOut_groupSubscription = groupSubscription;
      addClient.Invoke();

      groupSubscription.GroupId = addClient.InOut_groupSubscription.GroupId.Value;
      #endregion

      return groupSubscription;
    }

    /// <summary>
    ///   Load a GroupSubscription using groupSubscription.GroupId and
    ///   compare its properties with the given groupSubscription.
    /// </summary>
    /// <param name="groupSubscription"></param>
    private void CheckGroupSubscription(GroupSubscription groupSubscription)
    {
      #region Load the Group Subscription and validate data
      GroupSubscriptionService_GetGroupSubscriptionDetail_Client
        detailClient = new GroupSubscriptionService_GetGroupSubscriptionDetail_Client();

      detailClient.UserName = userName;
      detailClient.Password = password;
      detailClient.In_groupSubscriptionId = groupSubscription.GroupId.Value;
      detailClient.Invoke();

      GroupSubscription dbGroupSubscription = detailClient.Out_groupSubscription;

      Assert.IsNotNull(dbGroupSubscription, "Expected to find one group subscription");
      Assert.IsNotNull(dbGroupSubscription.UDRCValues, "Expected to find UDRC Values");
      Assert.IsNotNull(dbGroupSubscription.FlatRateRecurringChargeInstances, "Expected to find Flat Rate Recurring Charge Instances");
      Assert.IsNotNull(dbGroupSubscription.Members, "Expected to find group subscription members");

      Assert.AreEqual(groupSubscription.GroupId, dbGroupSubscription.GroupId);
      Assert.AreEqual(groupSubscription.Name, dbGroupSubscription.Name);
      Assert.AreEqual(groupSubscription.Description, dbGroupSubscription.Description);
      Assert.AreEqual(groupSubscription.CorporateAccountId, dbGroupSubscription.CorporateAccountId);
      Assert.AreEqual(groupSubscription.DiscountAccountId, dbGroupSubscription.DiscountAccountId);
      Assert.AreEqual(groupSubscription.UsageCycleId, dbGroupSubscription.UsageCycleId);
      Assert.AreEqual(groupSubscription.Visible, dbGroupSubscription.Visible);
      Assert.AreEqual(groupSubscription.ProportionalDistribution, dbGroupSubscription.ProportionalDistribution);
      Assert.AreEqual(groupSubscription.DiscountDistribution, dbGroupSubscription.DiscountDistribution);
      Assert.AreEqual(groupSubscription.Cycle.CycleType, dbGroupSubscription.Cycle.CycleType);
      Assert.AreEqual(groupSubscription.UDRCValues.Count, dbGroupSubscription.UDRCValues.Count);
      //Assert.AreEqual(groupSubscription.UDRCInstances.Count, dbGroupSubscription.UDRCInstances.Count);

      // Check UDRCInstance's
      foreach (UDRCInstance udrcInstanceAfter in dbGroupSubscription.UDRCInstances)
      {
        bool found = false;
        foreach (UDRCInstance udrcInstanceBefore in groupSubscription.UDRCInstances)
        {
          if (udrcInstanceBefore.ID == udrcInstanceAfter.ID)
          {
            found = true;
            break;
          }
        }
        Assert.IsTrue(found, "Mismatched UDRC instance");
      }

      // Check members
      Assert.AreEqual(groupSubscription.Members.Items.Count, dbGroupSubscription.Members.Items.Count);
      foreach (GroupSubscriptionMember gSubMemberAfter in dbGroupSubscription.Members.Items)
      {
        bool found = false;
        foreach (GroupSubscriptionMember gSubMemberBefore in groupSubscription.Members.Items)
        {
          if (gSubMemberBefore.AccountId == gSubMemberAfter.AccountId)
          {
            found = true;
            break;
          }
        }
        Assert.IsTrue(found, "Mismatched Group Subscription Member");
      }

      #endregion
    }

    private MetraTech.DomainModel.BaseTypes.Account CreateAccount(string typeName, out string userName, ref string nameSpace)
    {
      MetraTech.DomainModel.BaseTypes.Account account =
        MetraTech.DomainModel.BaseTypes.Account.CreateAccount(typeName);

      userName = typeName + "_" + DateTime.Now.ToString("MM/dd HH:mm:ss.") + DateTime.Now.Millisecond.ToString();
      if (String.IsNullOrEmpty(nameSpace))
      {
        nameSpace = "mt";
      }

      account.UserName = userName;
      account.Password_ = "123";
      account.Name_Space = nameSpace;
      account.DayOfMonth = 1;
      account.AccountStatus = AccountStatus.Active;

      return account;
    }

    private CoreSubscriber CreateCoreSubscriber(int ancestorAccountId)
    {
      string username;
      string nameSpace = String.Empty;

      CoreSubscriber account = (CoreSubscriber)CreateAccount("CoreSubscriber", out username, ref nameSpace);
      account.AncestorAccountID = ancestorAccountId;
      account.AccountStartDate = MetraTime.Now;

      account.Internal = internalView;

      // Add the contact views
      account.LDAP.Add(shipToContactView);
      account.LDAP.Add(billToContactView);

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      return (CoreSubscriber)addAccountClient.InOut_Account;
    }

    private CorporateAccount CreateCorporateAccount()
    {
      string username;
      string nameSpace = String.Empty;
      CorporateAccount account = (CorporateAccount)CreateAccount("CorporateAccount", out username, ref nameSpace);
      account.AncestorAccountID = 1;
      account.AccountStartDate = MetraTime.Now;

      
      // Set the internal view
      account.Internal = internalView;

      // Add the contact views
      account.LDAP.Add(shipToContactView);
      account.LDAP.Add(billToContactView);

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      return (CorporateAccount)addAccountClient.InOut_Account;
    }

    private IMTProductOffering CreateProductOffering(List<IMTRecurringCharge> charges)
    {
      IMTProductOffering productOffering = productCatalog.CreateProductOffering();
      productOffering.Name = string.Format("GS_Test_PO_{0}_{1}", Counter, Uniqueifier);
      productOffering.DisplayName = productOffering.Name;
      productOffering.Description = productOffering.Name;
      productOffering.SelfSubscribable = true;
      productOffering.SelfUnsubscribable = false;
      productOffering.EffectiveDate.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      productOffering.EffectiveDate.StartDate = DateTime.Parse("1/1/2008");
      productOffering.EffectiveDate.EndDateType = MTPCDateType.PCDATE_TYPE_NULL;
      productOffering.EffectiveDate.SetEndDateNull();

      foreach (IMTRecurringCharge recurringCharge in charges)
      {
        productOffering.AddPriceableItem((MTPriceableItem)recurringCharge);
      }

      productOffering.AvailabilityDate.StartDate = DateTime.Parse("1/1/2008");
      productOffering.AvailabilityDate.SetEndDateNull();
      productOffering.SetCurrencyCode("USD");
      productOffering.Save();

      return productOffering;
    }

    private IMTRecurringCharge CreateFlatRateRecurringCharge(bool chargePerParticipant)
    {
      IMTPriceableItemType priceableItemTypeFRRC =
          productCatalog.GetPriceableItemTypeByName("Flat Rate Recurring Charge");

      if (priceableItemTypeFRRC == null)
      {
        throw new ApplicationException("'Flat Rate Recurring Charge' Priceable Item Type not found");
      }

      string name = String.Empty;
      if (chargePerParticipant)
      {
        name = string.Format("FRRC_CPP_{0}_{1}", Counter, Uniqueifier);
      }
      else
      {
        name = string.Format("FRRC_CPS_{0}_{1}", Counter, Uniqueifier);
      }

      IMTRecurringCharge piTemplate_FRRC = (IMTRecurringCharge)priceableItemTypeFRRC.CreateTemplate(false);
      piTemplate_FRRC.Name = name;
      piTemplate_FRRC.DisplayName = name;
      piTemplate_FRRC.Description = name;
      piTemplate_FRRC.ChargeInAdvance = false;
      piTemplate_FRRC.ProrateOnActivation = true;
      piTemplate_FRRC.ProrateOnDeactivation = true;
      piTemplate_FRRC.ProrateOnRateChange = true;
      piTemplate_FRRC.FixedProrationLength = false;
      piTemplate_FRRC.ChargePerParticipant = chargePerParticipant;
      IMTPCCycle pcCycle = piTemplate_FRRC.Cycle;
      pcCycle.CycleTypeID = 1;
      pcCycle.EndDayOfMonth = 31;
      piTemplate_FRRC.Save();

      return piTemplate_FRRC;
    }
    private IMTRecurringCharge CreateUDRC(bool chargePerParticipant)
    {
      IMTPriceableItemType priceableItemTypeUDRC =
          productCatalog.GetPriceableItemTypeByName("Unit Dependent Recurring Charge");

      if (priceableItemTypeUDRC == null)
      {
        throw new ApplicationException("'Unit Dependent Recurring Charge' Priceable Item Type not found");
      }

      string name = String.Empty;
      if (chargePerParticipant)
      {
        name = string.Format("UDRC_CPP_{0}_{1}", Counter, Uniqueifier);
      }
      else
      {
        name = string.Format("UDRC_CPS_{0}_{1}", Counter, Uniqueifier);
      }

      IMTRecurringCharge piTemplate_UDRC = (IMTRecurringCharge)priceableItemTypeUDRC.CreateTemplate(false);
      piTemplate_UDRC.Name = name;
      piTemplate_UDRC.DisplayName = name;
      piTemplate_UDRC.Description = name;
      piTemplate_UDRC.ChargeInAdvance = false;
      piTemplate_UDRC.ProrateOnActivation = true;
      piTemplate_UDRC.ProrateOnDeactivation = true;
      piTemplate_UDRC.ProrateOnRateChange = true;
      piTemplate_UDRC.FixedProrationLength = false;
      piTemplate_UDRC.ChargePerParticipant = chargePerParticipant;
      piTemplate_UDRC.UnitName = string.Format("UNIT_{0}_{1}", Counter, Uniqueifier);
      piTemplate_UDRC.RatingType = MTUDRCRatingType.UDRCRATING_TYPE_TAPERED;
      piTemplate_UDRC.IntegerUnitValue = true;
      piTemplate_UDRC.MinUnitValue = 10;
      piTemplate_UDRC.MaxUnitValue = 1000;
      IMTPCCycle pcCycle = piTemplate_UDRC.Cycle;
      pcCycle.CycleTypeID = 1;
      pcCycle.EndDayOfMonth = 31;
      piTemplate_UDRC.Save();

      return piTemplate_UDRC;
    }
    #endregion

    #region Members
    private MetraTech.Interop.MTProductCatalog.IMTSessionContext sessionContext;
    private IMTProductCatalog productCatalog;
    private IMTRecurringCharge piTemplate_FRRC_ChargePerParticipant;
    private IMTRecurringCharge piTemplate_FRRC_ChargePerSub;
    private IMTRecurringCharge piTemplate_UDRC_ChargePerParticipant;
    private IMTRecurringCharge piTemplate_UDRC_ChargePerSub;
    private IMTProductOffering mtProductOffering;
    private CorporateAccount corporateAccount;
    AccountCreation_AddAccount_Client addAccountClient;
    InternalView internalView;
    ContactView shipToContactView;
    ContactView billToContactView;

    Dictionary<string, List<UDRCInstanceValue>> m_UDRCInstanceValues = new Dictionary<string, List<UDRCInstanceValue>>();

    private DateTime currentDate = MetraTime.Now;
    private Logger logger;
    private string userName = "su";
    private string password = "su123";
    #endregion
  }
}
