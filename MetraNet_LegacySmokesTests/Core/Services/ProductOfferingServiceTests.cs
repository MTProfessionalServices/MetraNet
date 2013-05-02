using System;
using System.Collections.Generic;
using System.Diagnostics;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using NUnit.Framework;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech;
using MetraTech.Test.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;

using MetraTech.Core.Services;
using System.ServiceModel;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.MetraPay;
using System.Collections;
using MetraTech.ActivityServices.Services.Common;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.ProductOfferingServiceTests /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
  public class ProductOfferingServiceTests : ServiceTestsBase
  {

      #region Test init and cleanup
    [TestFixtureSetUp]
    public void InitTests()
    {
        m_Logger = new Logger("[POTestLogger]");
      //m_namespace = "mt";
      //m_username = "abcdef1234567890";
    }

    [TestFixtureTearDown]
    public void UninitTests()
    {

    }
    #endregion

    #region Test Methods
    /*
    //created for troubleshooting bug.
    [Test]
    [Category("GetPOTS")]
    public void GetPOTS()
    {
        ProductOfferingServiceClient client = new ProductOfferingServiceClient();
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";

        ProductOffering po;

        client.GetProductOffering(new PCIdentifier(178094), out po);

        Assert.IsNotNull(po, "po is not null check");
        Assert.AreEqual(string.Empty, po.Name);

    }
    */
    [Test]
    [Category("SaveProductOffering")]
    public void T01SaveProductOfferingTest()
    {
      ProductOfferingServiceClient client = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      ProductOffering po = SetUpProductOffering();

      try
      {
        client.Open();
        client.SaveProductOffering(ref po);
        bool foundPo = false;
        m_pId = po.ProductOfferingId.Value;

        MTList<ProductOffering> productOfferings = new MTList<ProductOffering>();
        productOfferings.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, po.Name));
        client.GetProductOfferings(ref productOfferings);

        for (int i = 0; i < productOfferings.Items.Count; i++)
        {
          ProductOffering checkPo = productOfferings.Items[i];
          if (checkPo.ProductOfferingId.Value == m_pId)
          {
            m_Logger.LogDebug("Verifying po id {0}", m_pId);
            Assert.AreEqual(po.Name, checkPo.Name, "po name are equal");
            Assert.AreEqual(po.DisplayName, checkPo.DisplayName, "display name are equal");
            Assert.AreEqual(po.CanUserSubscribe, checkPo.CanUserSubscribe, "can user subscribe");
            Assert.AreEqual(po.CanUserUnsubscribe, checkPo.CanUserUnsubscribe, "can user unsubscribe");
            Assert.AreEqual(po.IsHidden, checkPo.IsHidden, "ishidden");
            Assert.AreEqual(po.CurrencyValueDisplayName, checkPo.CurrencyValueDisplayName, "curency value display name");

            Assert.AreEqual(po.AvailableTimeSpan.EndDate, checkPo.AvailableTimeSpan.EndDate, "available timespan end date");
            
            // available date is created during po creation if one is not specified
            if (po.AvailableTimeSpan.EndDateOffset.HasValue)
            {
              Assert.AreEqual(po.AvailableTimeSpan.EndDateOffset, checkPo.AvailableTimeSpan.EndDateOffset, "enddateoffset");
            }
            else
            {
              Assert.AreEqual(0, checkPo.AvailableTimeSpan.EndDateOffset, "enddateoffset");
            }

            Assert.AreEqual(po.EffectiveTimeSpan.EndDateType, checkPo.EffectiveTimeSpan.EndDateType, "enddatetype");
            Assert.AreEqual(po.EffectiveTimeSpan.EndDate.ToString().Trim(), checkPo.EffectiveTimeSpan.EndDate.ToString().Trim(), "enddate");
            Assert.AreEqual(po.EffectiveTimeSpan.EndDateOffset, checkPo.EffectiveTimeSpan.EndDateOffset, "enddateoffset for effecctive");
            Assert.AreEqual(po.EffectiveTimeSpan.EndDateType, checkPo.EffectiveTimeSpan.EndDateType, "effective date end date type");
            Assert.AreEqual(po.LocalizedDisplayNames.Count, checkPo.LocalizedDisplayNames.Count, "localized display name count");
            foreach (KeyValuePair<LanguageCode, string> kvp in po.LocalizedDisplayNames)
            {
              foreach (KeyValuePair<LanguageCode, string> kvp2 in checkPo.LocalizedDisplayNames)
              {
                if (kvp.Key.ToString().Trim().Equals(kvp2.Key.ToString().Trim()))
                {
                  Assert.AreEqual(kvp.Key.ToString().Trim(), kvp2.Key.ToString().Trim());
                  Assert.AreEqual(kvp.Value.ToString().Trim(), kvp2.Value.ToString().Trim());
                  break;
                }
              }
            }

            Assert.AreEqual(po.LocalizedDescriptions.Count, checkPo.LocalizedDescriptions.Count, "localized desc count");
            foreach (KeyValuePair<LanguageCode, string> kvp3 in po.LocalizedDescriptions)
            {
              foreach (KeyValuePair<LanguageCode, string> kvp4 in checkPo.LocalizedDescriptions)
              {
                if (kvp3.Key.ToString().Trim().Equals(kvp4.Key.ToString().Trim()))
                {
                  Assert.AreEqual(kvp3.Key.ToString().Trim(), kvp4.Key.ToString().Trim());
                  Assert.AreEqual(kvp3.Value.ToString().Trim(), kvp4.Value.ToString().Trim());
                  break;
                }
              }
            }

            Assert.AreEqual(po.SelfSubscribable, checkPo.SelfSubscribable);
            Assert.AreEqual(po.SelfUnsubscribable, checkPo.SelfUnsubscribable);
            Assert.AreEqual(po.CanUserSubscribe, checkPo.CanUserSubscribe);
            Assert.AreEqual(po.CanUserUnsubscribe, checkPo.CanUserUnsubscribe);
            Assert.AreEqual(po.Currency, checkPo.Currency);
            Assert.AreEqual(po.CurrencyValueDisplayName, checkPo.CurrencyValueDisplayName);
            m_Logger.LogDebug("About to validate po low level properties.");
            foundPo = true;
          }
        }

        m_Logger.LogDebug("Validated Summary Properties.");
        if (!foundPo)
          throw new MASBasicException("Unable to retrieve newly created po.");

        ProductOffering poDetails;
        PCIdentifier verifyPO = new PCIdentifier(m_pId);
        client.GetProductOffering(verifyPO, out poDetails);
        if (poDetails.ProductOfferingId.Value != m_pId)
          throw new MASBasicException("Product Offering Id's do not match");
        else
        {
          Assert.AreEqual(poDetails.SupportedAccountTypes.Count, 0);
        }

        // Update PO
        m_Logger.LogDebug("Trying to update the account properties.");
        List<string> supportedAccs = new List<string>();
        supportedAccs.Add("Root");
        supportedAccs.Add("SystemAccount");
        supportedAccs.Add("GSMServiceAccount");
        poDetails.SupportedAccountTypes = supportedAccs;
        client.SaveProductOffering(ref poDetails);

        ProductOffering partialUpdate;
        client.GetProductOffering(verifyPO, out partialUpdate);
        //client.Close();

        Assert.AreEqual(poDetails.SupportedAccountTypes.Count, partialUpdate.SupportedAccountTypes.Count);
        foreach (string s in poDetails.SupportedAccountTypes)
        {
          foreach (string s1 in partialUpdate.SupportedAccountTypes)
          { 
            if (s.Trim().Equals(s1.Trim()))
            {
              Assert.AreEqual(s.Trim(), s1.Trim());
              break;
            }
          }
        }

        m_Logger.LogDebug("Verified Partial Update.");

        PCIdentifier pc = new PCIdentifier(po.ProductOfferingId.Value);
        ProductOffering piInstanceCheck;
        client.GetProductOffering(pc, out piInstanceCheck);
        List<BasePriceableItemInstance> poInstances = piInstanceCheck.PriceableItems;
        MTList<BasePriceableItemInstance> checkPIInstances = new MTList<BasePriceableItemInstance>();
        client.GetPIInstancesForPO(pc, ref checkPIInstances);

        Assert.AreEqual(poInstances.Count, checkPIInstances.Items.Count);

        m_Logger.LogDebug("End of test");
        client.Close();
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception", e);
        client.Abort();
        throw;
      }
    }

    [Test]
    [Category("AddPIInstanceToPO")]
    public void T02AddPIInstanceToPO()
    {
        ProductOfferingServiceClient client = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";

        try
        {
         SaveProductOffering();

          BasePriceableItemInstance pi = PopulateFlatDicountPIInstance();
          BasePriceableItemInstance checkDiscount = null;
          BasePriceableItemInstance checkNRC = null;
          BasePriceableItemInstance checkRC = null;
          BasePriceableItemInstance checkUDRC = null;

            client.Open();

            try
            {
                if (pi != null)
                {
                    client.AddPIInstanceToPO(new PCIdentifier(m_pId), ref pi);
                    client.GetPIInstanceForPO(new PCIdentifier(m_pId), new PCIdentifier(pi.ID.Value), out checkDiscount);
                    VerifyPIInstance(checkDiscount, pi);
                }
            }
            catch (Exception e)
            {
                m_Logger.LogError("Error while adding/getting/verifying Flat Discount PIInstance");
                client.Abort();
                throw e;
            }

            try
            {
                // TODO: We need to save the template first for NRC stuff to work . . .
                BasePriceableItemInstance pi2 = PopulateNRC();
                if (pi2 != null)
                {
                    client.AddPIInstanceToPO(new PCIdentifier(m_pId), ref pi2);

                    if (pi2.ID.HasValue)
                    {
                        m_Logger.LogDebug("The pi instance id for the nrc should be {0} and the po is {1}", pi2.ID.Value, m_pId);
                        client.GetPIInstanceForPO(new PCIdentifier(m_pId), new PCIdentifier(pi2.ID.Value), out checkNRC);

                        m_Logger.LogDebug("Verifying NRC instance");
                        VerifyPIInstance(checkNRC, pi2);
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogError("Error while adding/getting/verifying Non Recurring PIInstance");
                client.Abort();
                throw e;
            }

            try
            {
                BasePriceableItemInstance pi3 = PopulateRC();
                m_Logger.LogDebug("Adding RC item to po");
                if (pi3 != null)
                {
                    client.AddPIInstanceToPO(new PCIdentifier(m_pId), ref pi3);

                    if (pi3.ID.HasValue)
                    {
                        m_Logger.LogDebug("Added pi instance to po");
                        client.GetPIInstanceForPO(new PCIdentifier(m_pId), new PCIdentifier(pi3.ID.Value), out checkRC);
                        m_Logger.LogDebug("Verifying RC pi instance");
                        VerifyPIInstance(checkRC, pi3);
                    }
                }

            }
            catch (Exception e)
            {
                m_Logger.LogError("Error while adding/getting/verifying Recurring PIInstance");
                client.Abort();
                throw e;
            }

            try
            {
                BasePriceableItemInstance pi4 = PopulateUDRC();
                m_Logger.LogDebug("Adding UDRC item to po");

                if (pi4 != null)
                {
                    client.AddPIInstanceToPO(new PCIdentifier(m_pId), ref pi4);

                    if (pi4.ID.HasValue)
                    {
                        m_Logger.LogDebug("Added pi instance to po");
                        client.GetPIInstanceForPO(new PCIdentifier(m_pId), new PCIdentifier(pi4.ID.Value), out checkUDRC);
                        m_Logger.LogDebug("Verifying UDRC pi instance");

                        VerifyPIInstance(checkUDRC, pi4);
                    }
                }

            }
            catch (Exception e)
            {
                m_Logger.LogError("Error while adding/getting/verifying UDRecurring PIInstance");
                client.Abort();
                throw e;
            }
            
            client.Close();

        }
        catch (Exception e)
        {
            client.Abort();

            throw e;
        }
    }


    [Test]
    [Category("RemovePIInstanceFromPO")]
    public void T03RemovePIInstanceFromPO()
    {
        ProductOfferingServiceClient client = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");

        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";

        ProductOffering po = SetUpProductOffering();
        BasePriceableItemInstance bpi = null;
        try
        {
            //Save Product Offering first
            client.Open();
            client.SaveProductOffering(ref po);
            m_pId = po.ProductOfferingId.Value;
            
            //Verify PI Instance created.
            
            client.GetPIInstanceForPO(new PCIdentifier((int)po.ProductOfferingId), new  PCIdentifier(po.PriceableItems[0].ID.Value), out bpi);
            Assert.IsNotNull(bpi);


            //Remove pi instance from PO.
            client.RemovePIInstanceFromPO(new PCIdentifier((int)po.ProductOfferingId), new PCIdentifier(bpi.ID.Value));
        }
        catch (Exception)
        {
            client.Abort();

            throw;
        }

        try
        {
            BasePriceableItemInstance removedbpi = null;
            client.GetPIInstanceForPO(new PCIdentifier((int)po.ProductOfferingId), new PCIdentifier(bpi.ID.Value), out removedbpi);
            Assert.IsNull(removedbpi);

            client.Close();
        }
        catch (FaultException<MASBasicFaultDetail> masE)
        {
            client.Abort();

            string err = masE.Detail.ErrorMessages[0];
            Assert.AreEqual("Invalid priceable item instance specified", err);
        }
    }
     

    [Test]
    [Category("GetPIInstanceForPO")]
    public void T04GetPIInstanceForPO()
    {
        ProductOffering po = null;
        BasePriceableItemInstance bpi = null;
        GetPIInstanceForPO(out po, out bpi);
        Assert.IsNotNull(bpi);
    }

    [Test]
    [Category("GetPIInstancesForPO")]
    public void T05GetPIInstancesForPO()
    {
        ProductOfferingServiceClient client = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");

        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";

        ProductOffering po = SetUpProductOffering();
        try
        {
            //Save Product Offering first
            client.Open();
            client.SaveProductOffering(ref po);

            PCIdentifier poID = new PCIdentifier(po.ProductOfferingId.Value);
            MTList<BasePriceableItemInstance> piInstances = new MTList<BasePriceableItemInstance>();

            client.GetPIInstancesForPO(poID, ref piInstances);
            Assert.Greater(piInstances.Items.Count, 0);
        }
        catch (Exception e)
        {
            client.Abort();

            throw e;
        }
    }

    [Test]
    [Category("Change Availability For PO")]
    public void T06ChangeAvailabilityForPO()
    {
        ProductOfferingServiceClient client = new ProductOfferingServiceClient();

        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";

        try
        {
            ProductOffering po = SetUpProductOffering(true, false);
            client.SaveProductOffering(ref po);

            ProductOffering availablePO = null;
            client.GetProductOffering(new PCIdentifier(po.ProductOfferingId.Value), out availablePO);

            po.AvailableTimeSpan.StartDate = null;
            client.SaveProductOffering(ref po);

            ProductOffering retPO = null;
            client.GetProductOffering(new PCIdentifier(po.ProductOfferingId.Value), out retPO);
            Assert.IsNotNull(availablePO);
        }
        catch (Exception e)
        {
            client.Abort();

            throw e;
        }


    }

    #endregion

    #region private methods

    private BasePriceableItemInstance PopulateFlatDicountPIInstance()
    {
      BasePriceableItemInstance discountInstance = null;
      ProductCatalogService_GetPriceableItemTemplates_Client templates = new ProductCatalogService_GetPriceableItemTemplates_Client();
      templates.UserName = "su";
      templates.Password = "su123";
      m_PiTemplates = new MTList<BasePriceableItemTemplate>();
      m_PiTemplates.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Equal, (int)PriceableItemKinds.Discount));
      m_PiTemplates.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Discount"));
      m_PiTemplates.PageSize = 10;

      templates.InOut_piTemplates = m_PiTemplates;
      templates.Invoke();
      m_PiTemplates = templates.InOut_piTemplates;

      //foreach (BasePriceableItemTemplate t in m_PiTemplates)
      for (int i = 0; i < m_PiTemplates.Items.Count; i++)
      {
        BasePriceableItemTemplate t = m_PiTemplates.Items[i];
        if (t.PIKind == PriceableItemKinds.Discount)
        {

          ProductCatalogService_CreatePIInstanceFromTemplate_Client tClient = new ProductCatalogService_CreatePIInstanceFromTemplate_Client();
          tClient.UserName = "su";
          tClient.Password = "su123";
          tClient.In_piTemplateID = new PCIdentifier(t.ID.Value);
          tClient.Invoke();
          BasePriceableItemInstance item = tClient.Out_piInstance;

          Flat_DiscountPIInstance flatDiscTemp = (Flat_DiscountPIInstance)item;
          flatDiscTemp.DisplayName = "Flat Discount Display Name";
          flatDiscTemp.Description = "Flat Discount Description";
          flatDiscTemp.Name = "Flat Discount Name";

          flatDiscTemp.LocalizedDisplayNames = SetLocalizedData("flat discount", false);
          flatDiscTemp.LocalizedDescriptions = SetLocalizedData("flat discount", true);


          WeeklyUsageCycyleInfo weeklyCycle = new WeeklyUsageCycyleInfo();
          weeklyCycle.DayOfWeek = DayOfWeek.Monday;
          flatDiscTemp.Cycle = weeklyCycle;

          /*SumOfOnePropertyCounter counter = new SumOfOnePropertyCounter();
          counter.A = "metratech.com/songsessionchild_temp/songs";
          counter.Description = "soa";
          counter.DisplayName = "Discount sum of one property counter";
          counter.Name = "Flat Discount counter";

          counter.LocalizedDisplayNames = SetLocalizedData("counter", false);
          counter.LocalizedDescriptions = SetLocalizedData("counter", true);      
           * */
          List<RateSchedule<Metratech_com_FlatDiscountRateEntry, Metratech_com_FlatDiscountDefaultRateEntry>> rscheds = new List<RateSchedule<Metratech_com_FlatDiscountRateEntry, Metratech_com_FlatDiscountDefaultRateEntry>>();          
          Metratech_com_FlatDiscountRateEntry entry = new Metratech_com_FlatDiscountRateEntry();
          entry.FlatDiscountAmount = 25.0M;
          entry.FlatRateQualifier = 10.0M;
          entry.FlatRateQualifier_op = RateEntryOperators.Greater;
          RateSchedule<Metratech_com_FlatDiscountRateEntry, Metratech_com_FlatDiscountDefaultRateEntry> sched = new RateSchedule<Metratech_com_FlatDiscountRateEntry, Metratech_com_FlatDiscountDefaultRateEntry>();
          sched.RateEntries.Add(entry);
          rscheds.Add(sched);
          flatDiscTemp.Metratech_com_flatdiscount_RateSchedules = rscheds;
          discountInstance = item;
          break;
        }
      }
      return discountInstance;
    }

    private BasePriceableItemInstance PopulateNRC()
    {
      BasePriceableItemInstance instance = null;

      ProductCatalogService_GetPriceableItemTemplates_Client templates = new ProductCatalogService_GetPriceableItemTemplates_Client();
      templates.UserName = "su";
      templates.Password = "su123";

      m_PiTemplates = new MTList<BasePriceableItemTemplate>();
      m_PiTemplates.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Equal, (int)PriceableItemKinds.NonRecurring));
      m_PiTemplates.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Rate Non Recurring Charge"));  
      m_PiTemplates.PageSize = 10;

      templates.InOut_piTemplates = m_PiTemplates;
      templates.Invoke();
      m_PiTemplates = templates.InOut_piTemplates;

      for (int i = 0; i < m_PiTemplates.Items.Count; i++)
      {
        BasePriceableItemTemplate t = m_PiTemplates.Items[i];
        if (t.PIKind == PriceableItemKinds.NonRecurring)
        {
          m_Logger.LogDebug("The template id is {0}", t.ID.Value);
          ProductCatalogService_CreatePIInstanceFromTemplate_Client tClient = new ProductCatalogService_CreatePIInstanceFromTemplate_Client();
          tClient.UserName = "su";
          tClient.Password = "su123";
          tClient.In_piTemplateID = new PCIdentifier(t.ID.Value);
          tClient.Invoke();
          BasePriceableItemInstance item = tClient.Out_piInstance;
          Flat_Rate_Non_Recurring_ChargePIInstance nrc = (Flat_Rate_Non_Recurring_ChargePIInstance)item;
          nrc.Name = "Qwenchnito";
          nrc.Description = "Qwenchnito Description";
          nrc.DisplayName = "Qwenchnito Displayname";
          nrc.EventType = NonRecurringChargeEvents.Subscribe;
          nrc.LocalizedDisplayNames = SetLocalizedData("NRC Smoke", false);
          nrc.LocalizedDescriptions = SetLocalizedData("NRC Smoke", true);
          instance = nrc;
          break;
        }
      }

      return instance;
    }

    private BasePriceableItemInstance PopulateUDRC()
    {
        BasePriceableItemInstance instance = null;

        ProductCatalogService_GetPriceableItemTemplates_Client templates = new ProductCatalogService_GetPriceableItemTemplates_Client();
        templates.UserName = "su";
        templates.Password = "su123";
        m_PiTemplates = new MTList<BasePriceableItemTemplate>();
        m_PiTemplates.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Equal, (int)PriceableItemKinds.UnitDependentRecurring));
        m_PiTemplates.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Unit Dependent Recurring Charge"));
        m_PiTemplates.PageSize = 10;

        templates.InOut_piTemplates = m_PiTemplates;
        templates.Invoke();
        m_PiTemplates = templates.InOut_piTemplates;

        for (int i = 0; i < m_PiTemplates.Items.Count; i++)
        {
            BasePriceableItemTemplate t = m_PiTemplates.Items[i];
            if (t.PIKind == PriceableItemKinds.UnitDependentRecurring)
            {
                ProductCatalogService_CreatePIInstanceFromTemplate_Client tClient = new ProductCatalogService_CreatePIInstanceFromTemplate_Client();
                tClient.UserName = "su";
                tClient.Password = "su123";
                tClient.In_piTemplateID = new PCIdentifier(t.ID.Value);
                tClient.Invoke();
                BasePriceableItemInstance item = tClient.Out_piInstance;

                Unit_Dependent_Recurring_ChargePIInstance udrc = (Unit_Dependent_Recurring_ChargePIInstance)item;
                udrc.Name = "udRC smoke";
                udrc.Description = "udRC description";
                udrc.DisplayName = "udrc display name";
                udrc.LocalizedDisplayNames = SetLocalizedData("udRC smoke", false);
                udrc.LocalizedDescriptions = SetLocalizedData("udRC smoke", true);
                udrc.ProrateOnActivation = false;
                udrc.ProrateOnDeactivation = false;
                udrc.ChargePerParticipant = false;
                udrc.ChargeAdvance = true;
                udrc.FixedProrationLength = false;
                ExtendedRelativeUsageCycleInfo cycle = new ExtendedRelativeUsageCycleInfo();
                cycle.ExtendedUsageCycle = ExtendedCycleType.Monthly;
                udrc.Cycle = cycle;
                udrc.Glcode = "abc";
                // TODO: Adjustments instance testing

                List<RateSchedule<Metratech_com_UDRCTieredRateEntry, Metratech_com_UDRCTieredDefaultRateEntry>> rscheds = new List<RateSchedule<Metratech_com_UDRCTieredRateEntry, Metratech_com_UDRCTieredDefaultRateEntry>>();
                Metratech_com_UDRCTieredRateEntry entry = new Metratech_com_UDRCTieredRateEntry();
                entry.BaseAmount = 210.0M;
                entry.UnitAmount = 100.0M;
                RateSchedule<Metratech_com_UDRCTieredRateEntry, Metratech_com_UDRCTieredDefaultRateEntry> sched = new RateSchedule<Metratech_com_UDRCTieredRateEntry, Metratech_com_UDRCTieredDefaultRateEntry>();
                sched.RateEntries.Add(entry);
                rscheds.Add(sched);
                udrc.Metratech_com_udrctiered_RateSchedules = rscheds;
                udrc.AllowedUnitValues = new List<decimal>() { 10.00M, 11.00M, 12.00M };
                
                udrc.MinUnitValue = 5.00M;
                udrc.MaxUnitValue = 15.00M;
                instance = item;
                break;
            }
        }
        return instance;
    }

    private BasePriceableItemInstance PopulateRC()
    {
      BasePriceableItemInstance instance = null;

      ProductCatalogService_GetPriceableItemTemplates_Client templates = new ProductCatalogService_GetPriceableItemTemplates_Client();
      templates.UserName = "su";
      templates.Password = "su123";
      m_PiTemplates = new MTList<BasePriceableItemTemplate>();
      m_PiTemplates.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Equal, (int)PriceableItemKinds.Recurring));
      m_PiTemplates.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Rate Recurring Charge"));  
      m_PiTemplates.PageSize = 10;

      templates.InOut_piTemplates = m_PiTemplates;
      templates.Invoke();
      m_PiTemplates = templates.InOut_piTemplates;

      for (int i = 0; i < m_PiTemplates.Items.Count; i++)
      {
        BasePriceableItemTemplate t = m_PiTemplates.Items[i];
        if (t.PIKind == PriceableItemKinds.Recurring)
        {
          ProductCatalogService_CreatePIInstanceFromTemplate_Client tClient = new ProductCatalogService_CreatePIInstanceFromTemplate_Client();
          tClient.UserName = "su";
          tClient.Password = "su123";
          tClient.In_piTemplateID = new PCIdentifier(t.ID.Value);
          tClient.Invoke();
          BasePriceableItemInstance item = tClient.Out_piInstance;

          Flat_Rate_Recurring_ChargePIInstance rc = (Flat_Rate_Recurring_ChargePIInstance)item;
          rc.Name = "RC smoke";
          rc.Description = "RC description";
          rc.DisplayName = "rc display name";
          rc.LocalizedDisplayNames = SetLocalizedData("RC smoke", false);
          rc.LocalizedDescriptions = SetLocalizedData("RC smoke", true);
          rc.ProrateOnActivation = false;
          rc.ProrateOnDeactivation = false;
          rc.ChargePerParticipant = false;
          rc.ChargeAdvance = true;
          rc.FixedProrationLength = false;
          ExtendedRelativeUsageCycleInfo cycle = new ExtendedRelativeUsageCycleInfo();
          cycle.ExtendedUsageCycle = ExtendedCycleType.Monthly;
          rc.Cycle = cycle;
          // TODO: Adjustments instance testing

          List<RateSchedule<Metratech_com_FlatRecurringChargeRateEntry, Metratech_com_FlatRecurringChargeDefaultRateEntry>> rscheds = new List<RateSchedule<Metratech_com_FlatRecurringChargeRateEntry, Metratech_com_FlatRecurringChargeDefaultRateEntry>>();
          Metratech_com_FlatRecurringChargeRateEntry entry = new Metratech_com_FlatRecurringChargeRateEntry();
          entry.RCAmount = 210.0M;
          RateSchedule<Metratech_com_FlatRecurringChargeRateEntry, Metratech_com_FlatRecurringChargeDefaultRateEntry> sched = new RateSchedule<Metratech_com_FlatRecurringChargeRateEntry, Metratech_com_FlatRecurringChargeDefaultRateEntry>();
          sched.RateEntries.Add(entry);
          rscheds.Add(sched);
          rc.Metratech_com_flatrecurringcharge_RateSchedules = rscheds;
          instance = item;
        }
      }
      return instance;
    }

    private Dictionary<LanguageCode, string> SetLocalizedData(string name, bool popDesc)
    {
      Dictionary<LanguageCode, string> dict = new Dictionary<LanguageCode, string>();
      if (popDesc)
      {
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, String.Format("{0} English Description", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, String.Format("{0} Japanese Description", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, String.Format("{0} Italian Description", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, String.Format("{0} French Description", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, String.Format("{0} German Description", name));
  }
      else
      {
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, String.Format("{0} English names", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, String.Format("{0} Japanese Names", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, String.Format("{0} Italian Names", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, String.Format("{0} French Names", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, String.Format("{0} German Names", name));
      }
      return dict;
    }

    private void VerifyPIInstance(BasePriceableItemInstance retrieved, BasePriceableItemInstance created)
    {
        try
        {
            //TODO: check for property override settings before verification.
            Assert.AreEqual(retrieved.Name, created.Name, "Equal Check | Name");

            if (PCConfigManager.IsPropertyOverridable((int)retrieved.PIKind, "DisplayName"))
            {
                Assert.AreEqual(retrieved.DisplayName, created.DisplayName, "Equal Check | DisplayName");
            }

            Assert.AreEqual(retrieved.ID, created.ID, "Equal Check | ID");
            m_Logger.LogDebug("Verifying stage 1");

            created.Description = string.IsNullOrEmpty(created.Description) ? null : created.Description;

            if (PCConfigManager.IsPropertyOverridable((int)retrieved.PIKind, "Description"))
            {
                Assert.AreEqual(retrieved.Description, created.Description, "Equal Check | Description");
            }

            m_Logger.LogDebug("Verifying stage 2");
            Assert.AreEqual(retrieved.PITemplate.ID, created.PITemplate.ID, "Equal Check | PITemplate.ID");
            Assert.AreEqual(retrieved.PIKind, created.PIKind, "Equal Check | PIKind");
            m_Logger.LogDebug("Verifying stage 3");

            if (PCConfigManager.IsPropertyOverridable((int)retrieved.PIKind, "Descriptions"))
            {
                ValidateLocalizationDetails(retrieved.LocalizedDescriptions, created.LocalizedDescriptions);
            }

            if (PCConfigManager.IsPropertyOverridable((int)retrieved.PIKind, "DisplayNames"))
            {
                ValidateLocalizationDetails(retrieved.LocalizedDisplayNames, created.LocalizedDisplayNames);
            }

            m_Logger.LogDebug("Verifying stage 4");
            if (retrieved.PIKind == PriceableItemKinds.AggregateCharge)
            {
                AggregateChargePIInstance retrievedAgg = (AggregateChargePIInstance)retrieved;
                AggregateChargePIInstance createdAgg = (AggregateChargePIInstance)created;
                m_Logger.LogDebug("Verifying Aggregate Charge");
                Assert.AreEqual(retrievedAgg.Cycle, createdAgg.Cycle, "Equal Check | Cycle in AggregateChargePIInstance");
                m_Logger.LogDebug("Verifying stage 5");
                Assert.AreEqual(retrievedAgg.CycleValueDisplayName, createdAgg.CycleValueDisplayName, "Equal Check | CycleValueDisplayName in AggregateChargePIInstance");
                m_Logger.LogDebug("Verified Aggregate Charge");
                m_Logger.LogDebug("Verifying stage 6");
            }
            else if (retrieved.PIKind == PriceableItemKinds.Discount)
            {
                m_Logger.LogDebug("Verifying Discount Charge");
                Flat_DiscountPIInstance retrievedDisc = (Flat_DiscountPIInstance)retrieved;
                Flat_DiscountPIInstance createdDisc = (Flat_DiscountPIInstance)created;
                m_Logger.LogDebug("Verifying stage 7");
                //Assert.AreEqual(retrievedDisc.Cycle, createdDisc.Cycle);
                Assert.AreEqual(retrievedDisc.Metratech_com_flatdiscount_RateSchedules.Count, createdDisc.Metratech_com_flatdiscount_RateSchedules.Count, "Equal Check | RateSchedules Count in Flat_DiscountPIInstance");
                m_Logger.LogDebug("Verified Discount Charge");
                m_Logger.LogDebug("Verifying stage 8");
            }
            else if (retrieved.PIKind == PriceableItemKinds.NonRecurring)
            {
                m_Logger.LogDebug("Verifying stage 9");
                m_Logger.LogDebug("Verifying NRC Charge");
                Flat_Rate_Non_Recurring_ChargePIInstance retrievedNRC = (Flat_Rate_Non_Recurring_ChargePIInstance)retrieved;
                Flat_Rate_Non_Recurring_ChargePIInstance createdNRC = (Flat_Rate_Non_Recurring_ChargePIInstance)created;
                m_Logger.LogDebug("Verifying stage 10");
                m_Logger.LogDebug("Verifying flat adjustments");
                Assert.AreEqual(retrievedNRC.FlatNonRecurringChargeFlatAdjustment, createdNRC.FlatNonRecurringChargeFlatAdjustment, "Equal Check | FlatNonRecurringChargeFlatAdjustment");
                m_Logger.LogDebug("Verifying stage 11");
                m_Logger.LogDebug("Verifying percent adjustments");
                Assert.AreEqual(retrievedNRC.FlatNonRecurringChargePercentAdjustment, createdNRC.FlatNonRecurringChargePercentAdjustment, "Equal Check | FlatNonRecurringChargePercentAdjustment");
                m_Logger.LogDebug("Verifying stage 12");
                m_Logger.LogDebug("Verifying rscheds");
                //Assert.AreEqual(retrievedNRC.Metratech_com_nonrecurringcharge_RateSchedules, createdNRC.Metratech_com_nonrecurringcharge_RateSchedules);

                // TODO: Fix after ed check makes fix
                Assert.AreEqual(retrievedNRC.EventType, createdNRC.EventType, "Equal Check | EventType");
                m_Logger.LogDebug("Verified NRC Charge");
                m_Logger.LogDebug("Verifying stage 13");
            }
            else if (retrieved.PIKind == PriceableItemKinds.Recurring)
            {
                m_Logger.LogDebug("Verifying stage 14");
                m_Logger.LogDebug("Verifying RC Charge");
                Flat_Rate_Recurring_ChargePIInstance retrievedRC = (Flat_Rate_Recurring_ChargePIInstance)retrieved;
                Flat_Rate_Recurring_ChargePIInstance createdRC = (Flat_Rate_Recurring_ChargePIInstance)created;
                m_Logger.LogDebug("Verifying stage 15");
                Assert.AreEqual(retrievedRC.ChargeAdvance, createdRC.ChargeAdvance, "Equal Check | ChargeAdvance");
                Assert.AreEqual(retrievedRC.ChargePerParticipant, createdRC.ChargePerParticipant, "Equal Check | ChargePerParticipant");
                m_Logger.LogDebug("Verifying stage 16");
                // TODO: issue with cycles m_Logger.LogDebug("Verifying cycle . . . ");
                //Assert.AreEqual(retrievedRC.Cycle, createdRC.Cycle);
                m_Logger.LogDebug("Verifying stage 17");
                Assert.AreEqual(retrievedRC.FlatRecurringChargeFlatAdjustment, createdRC.FlatRecurringChargeFlatAdjustment, "Equal Check | FlatRecurringChargeFlatAdjustment");
                Assert.AreEqual(retrievedRC.FlatRecurringChargePercentAdjustment, createdRC.FlatRecurringChargePercentAdjustment, "Equal Check | FlatRecurringChargePercentAdjustment");
                m_Logger.LogDebug("Verifying stage 18");
                Assert.AreEqual(retrievedRC.Metratech_com_flatrecurringcharge_RateSchedules.Count, createdRC.Metratech_com_flatrecurringcharge_RateSchedules.Count, "Equal Check | RateSchedules count in recurring");
                Assert.AreEqual(retrievedRC.ProrateOnActivation, createdRC.ProrateOnActivation, "Equal Check | ChargePerParticipant");
                m_Logger.LogDebug("Verifying stage 19");
            }
            else if (retrieved.PIKind == PriceableItemKinds.Usage)
            {
                m_Logger.LogDebug("Verifying stage 20");
                m_Logger.LogDebug("Verifying Usage Charge");
                // TODO:
                m_Logger.LogDebug("Verified Usage Charge");
            }
        }
        catch (Exception e)
        {
            m_Logger.LogError("Error occurred @ VerifyPIInstance", e);
            throw e;
        }
    }

    private void ValidateLocalizationDetails(Dictionary<LanguageCode, string> created, Dictionary<LanguageCode, string> verify)
    {
        try
        {
            //TODO: Check for property overrides before verification.
            bool createdObjectExists = (created != null) ? true : false ;
            bool VerificationObjectExists = (verify != null) ? true : false;

            Assert.AreEqual(createdObjectExists, VerificationObjectExists);

            if (created != null && verify != null)
            {
                Assert.AreEqual(created.Count, verify.Count);

                foreach (KeyValuePair<LanguageCode, string> kvp in created)
                {
                    Assert.IsTrue(verify.ContainsKey(kvp.Key));

                    if (verify.ContainsKey(kvp.Key))
                    {
                        Assert.AreEqual(string.IsNullOrEmpty(kvp.Value) ? null : kvp.Value.ToString().Trim(), string.IsNullOrEmpty(verify[kvp.Key]) ? null : verify[kvp.Key].ToString().Trim());
                    }
                }
            }
        }
        catch (Exception e)
        {
            m_Logger.LogError("Error occurred while validating localization details");
            throw e;
        }

    }

    #endregion
  }

}
