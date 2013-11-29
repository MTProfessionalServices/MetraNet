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
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;

using MetraTech.Core.Services;
using System.ServiceModel;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.MetraPay;
using System.Collections;


namespace MetraTech.Core.Services.Test
{
    abstract public class ServiceTestsBase
    {
        protected string m_TestPoName = "Testing ";
        protected Logger m_Logger = null;
        protected int m_pId = -1;
        protected MTList<BasePriceableItemTemplate> m_PiTemplates = new MTList<BasePriceableItemTemplate>();
        
        #region Helper Methods

        public ProductOffering SetUpProductOffering()
        {
            return SetUpProductOffering(m_TestPoName);
        }

        public ProductOffering SetUpProductOffering(bool bMakeAvailable, bool bStart)
        {
            return SetUpProductOffering(m_TestPoName, bMakeAvailable, bStart);
        }

        public ProductOffering SetUpProductOffering(string startName)
        {
            // Don't want to brake current unit tests,
            // so setup flags accordingly
            return SetUpProductOffering(startName, false, true);
        }

        public ProductOffering SetUpProductOffering(string startName, bool bMakeAvailable, bool bStart)
        {
            ProductOffering po = new ProductOffering();

            Guid testId = Guid.NewGuid();
            po.Name = startName + testId.ToString();
            po.Description = startName + testId.ToString();
            po.CanUserSubscribe = true;
            po.CanUserUnsubscribe = true;
            po.Currency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.USD;
            po.DisplayName = startName + testId.ToString();

            po.Glcode = "Test123";
            po.InternalInformationURL = "https://localhost/InternalInfo";
            po.ExternalInformationURL = "http://localhost/ExternalInfo";

            Dictionary<LanguageCode, string> localizedNames = new Dictionary<LanguageCode, string>();
            Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();

            po.LocalizedDisplayNames = localizedNames;
            po.LocalizedDescriptions = localizedDesc;

            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, "English Description");
            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, "Japanese Description");
            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, "Italian Description");
            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, "French Description");
            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, "German Description");
            
            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, "English names");
            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, "Japanese Names");
            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, "Italian Names");
            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, "French Names");
            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, "German Names");
            
            
            if (bStart)
            {
                ProdCatTimeSpan effectiveDate = new ProdCatTimeSpan();
                effectiveDate.StartDate = System.DateTime.Now;
                effectiveDate.StartDateOffset = 0;
                effectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
                effectiveDate.EndDate = System.DateTime.Now.AddYears(5);
                effectiveDate.EndDateOffset = 0;
                effectiveDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;


                po.EffectiveTimeSpan.StartDate = effectiveDate.StartDate.Value;
                po.EffectiveTimeSpan.StartDateType = effectiveDate.StartDateType; ;
                po.EffectiveTimeSpan.StartDateOffset = effectiveDate.StartDateOffset;
                po.EffectiveTimeSpan.EndDate = effectiveDate.EndDate.Value;
                po.EffectiveTimeSpan.EndDateType = effectiveDate.EndDateType; ;
                po.EffectiveTimeSpan.EndDateOffset = effectiveDate.EndDateOffset;
            }

            if (bMakeAvailable)
            {
                ProdCatTimeSpan availDate = new ProdCatTimeSpan();
                availDate.StartDate = System.DateTime.Now;
                availDate.StartDateOffset = 0;
                availDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
                availDate.EndDate = System.DateTime.Now.AddYears(5);
                availDate.EndDateOffset = 0;
                availDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;

                po.AvailableTimeSpan.StartDate = availDate.StartDate.Value;
                po.AvailableTimeSpan.StartDateType = availDate.StartDateType; ;
                po.AvailableTimeSpan.StartDateOffset = availDate.StartDateOffset;
                po.AvailableTimeSpan.EndDate = availDate.EndDate.Value;
                po.AvailableTimeSpan.EndDateType = availDate.EndDateType; ;
                po.AvailableTimeSpan.EndDateOffset = availDate.EndDateOffset;
                
            }

            po.Glcode = "ricked";

            List<string> supportedAccs = new List<string>();
            po.SupportedAccountTypes = supportedAccs;

            List<BasePriceableItemInstance> piInstances = new List<BasePriceableItemInstance>();

            ProductCatalogServiceClient catClient = new ProductCatalogServiceClient();
            catClient.ClientCredentials.UserName.UserName = "su";
            catClient.ClientCredentials.UserName.Password = "su123";
            catClient.Open();

            MTList<BasePriceableItemTemplate> templateList = new MTList<BasePriceableItemTemplate>();
            templateList.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, "AudioConfCall"));
            catClient.GetPriceableItemTemplates(ref templateList);

            Assert.Greater(templateList.Items.Count, 0);

            BasePriceableItemTemplate audioConfCallTemplate = templateList.Items[0];

            //catClient.GetPriceableItemTemplate(new PCIdentifier(audioConfCallTemplate.ID.Value), out audioConfCallTemplate);

            BasePriceableItemInstance bpInstance = null;
            catClient.CreatePIInstanceFromTemplate(new PCIdentifier(audioConfCallTemplate.ID.Value), out bpInstance);

            Assert.IsNotNull(bpInstance.PITemplate);
            Assert.Greater(bpInstance.PITemplate.ID, 0);

            AudioConfCallPIInstance audioConfCallInstance = bpInstance as AudioConfCallPIInstance;

            audioConfCallInstance.Description = "smoke test";
            audioConfCallInstance.DisplayName = "smoke test disp";
            audioConfCallInstance.Glcode = "GLCodeEP";

            Dictionary<LanguageCode, string> instanceLocalizedNames = new Dictionary<LanguageCode, string>();
            Dictionary<LanguageCode, string> instanceLocalizedDesc = new Dictionary<LanguageCode, string>();

            audioConfCallInstance.LocalizedDescriptions = instanceLocalizedDesc;
            audioConfCallInstance.LocalizedDisplayNames = instanceLocalizedNames;

            audioConfCallInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, "SMS English Description");
            audioConfCallInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, "SMS Japanese Description");
            audioConfCallInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, "SMS Italian Description");
            audioConfCallInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, "SMS French Description");
            audioConfCallInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, "SMS German Description");

            audioConfCallInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, "SMS English names");
            audioConfCallInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, "SMS Japanese Names");
            audioConfCallInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, "SMS Italian Names");
            audioConfCallInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, "SMS French Names");
            audioConfCallInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, "SMS German Names");

            audioConfCallInstance.Name = "Audio Conf Call Testing Name" + testId;


            //Feature Setup Rate Schedule
            List<RateSchedule<Metratech_com_featuresetupchargeRateEntry, Metratech_com_featuresetupchargeDefaultRateEntry>> featureSetupRateScheds = new List<RateSchedule<Metratech_com_featuresetupchargeRateEntry, Metratech_com_featuresetupchargeDefaultRateEntry>>();
            Metratech_com_featuresetupchargeRateEntry featureSetupRateEntry = new Metratech_com_featuresetupchargeRateEntry();
            featureSetupRateEntry.FeatureType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfFeature.FeatureType.TapesOriginals;
            featureSetupRateEntry.SetupCharge = 10.00M;
            RateSchedule<Metratech_com_featuresetupchargeRateEntry, Metratech_com_featuresetupchargeDefaultRateEntry> featureSetupRateSched = new RateSchedule<Metratech_com_featuresetupchargeRateEntry, Metratech_com_featuresetupchargeDefaultRateEntry>();
            featureSetupRateSched.RateEntries.Add(featureSetupRateEntry);
            featureSetupRateScheds.Add(featureSetupRateSched);
            audioConfCallInstance.AudioConfFeature.Metratech_com_featuresetupcharge_RateSchedules = featureSetupRateScheds;

            //Minimum Charge Rate Schedule
            List<RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>> minimumChargeRateScheds = new List<RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>>();
            Metratech_com_minchargeRateEntry minimumChargeRateEntry = new Metratech_com_minchargeRateEntry();
            minimumChargeRateEntry.ConfChargeMinimum = 20.00M;
            minimumChargeRateEntry.ConfChargeMinimumApplicBool = true;
            Metratech_com_minchargeDefaultRateEntry minimumChargeDefaultRateEntry = new Metratech_com_minchargeDefaultRateEntry();
            minimumChargeDefaultRateEntry.ConfChargeMinimum = 30.00M;
            RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry> minimumChargeRateSched = new RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>();
            minimumChargeRateSched.RateEntries.Add(minimumChargeRateEntry);
            minimumChargeRateSched.DefaultRateEntry = minimumChargeDefaultRateEntry;
            minimumChargeRateScheds.Add(minimumChargeRateSched);
            audioConfCallInstance.Metratech_com_mincharge_RateSchedules = minimumChargeRateScheds;

            piInstances.Add(audioConfCallInstance);
            po.PriceableItems = piInstances;
            catClient.Close();

            return po;
        }

        public ProductOffering SaveProductOffering()
        {
            ProductOfferingServiceClient client = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");

            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            return SaveProductOffering(client);
        }

        public ProductOffering SaveProductOffering(ProductOfferingServiceClient client)
        {
            ProductOffering po = SetUpProductOffering();
            SaveProductOffering(client, ref po);

            return po;
        }

        public void SaveProductOffering(ref ProductOffering po)
        {
            ProductOfferingServiceClient client = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");

            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            SaveProductOffering(client, ref po);
        }

        public void SaveProductOffering(ProductOfferingServiceClient client, ref ProductOffering po)
        {
            try
            {
                client.Open();
                client.SaveProductOffering(ref po);
                m_pId = po.ProductOfferingId.Value;
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }
       }

        public ProductOffering SetUpProductOffering_old()
        {
            ProductOffering po = new ProductOffering();
            //string name = "PCWSTestPO";
            Guid testId = Guid.NewGuid();
            po.Name = m_TestPoName + testId.ToString();
            po.Description = m_TestPoName + testId.ToString();
            po.CanUserSubscribe = true;
            po.CanUserUnsubscribe = true;
            po.Currency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.USD;
            po.DisplayName = m_TestPoName + testId.ToString();

            po.Glcode = "Test123";
            po.InternalInformationURL = "https://localhost/InternalInfo";
            po.ExternalInformationURL = "http://localhost/ExternalInfo";

            Dictionary<LanguageCode, string> localizedNames = new Dictionary<LanguageCode, string>();
            Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();

            po.LocalizedDisplayNames = localizedNames;
            po.LocalizedDescriptions = localizedDesc;

            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, "English Description");
            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, "Japanese Description");
            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, "Italian Description");
            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, "French Description");
            po.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, "German Description");

            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, "English names");
            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, "Japanese Names");
            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, "Italian Names");
            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, "French Names");
            po.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, "German Names");

            ProdCatTimeSpan effectiveDate = new ProdCatTimeSpan();
            effectiveDate.StartDate = System.DateTime.Now;
            effectiveDate.StartDateOffset = 0;
            effectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            effectiveDate.EndDate = System.DateTime.Now.AddYears(5);
            effectiveDate.EndDateOffset = 0;
            effectiveDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;


            po.EffectiveTimeSpan.StartDate = effectiveDate.StartDate.Value;
            po.EffectiveTimeSpan.StartDateType = effectiveDate.StartDateType; ;
            po.EffectiveTimeSpan.StartDateOffset = effectiveDate.StartDateOffset;
            po.EffectiveTimeSpan.EndDate = effectiveDate.EndDate.Value;
            po.EffectiveTimeSpan.EndDateType = effectiveDate.EndDateType; ;
            po.EffectiveTimeSpan.EndDateOffset = effectiveDate.EndDateOffset;

            /*ProdCatTimeSpan availDate = new ProdCatTimeSpan();
            availDate.StartDate = System.DateTime.Now;
            availDate.StartDateOffset = 0;
            availDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            availDate.EndDate = System.DateTime.Now.AddYears(5);
            availDate.EndDateOffset = 0;
            availDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;

            po.AvailableTimeSpan.StartDate = availDate.StartDate.Value;
            po.AvailableTimeSpan.StartDateType = availDate.StartDateType; ;
            po.AvailableTimeSpan.StartDateOffset = availDate.StartDateOffset;
            po.AvailableTimeSpan.EndDate = availDate.EndDate.Value;
            po.AvailableTimeSpan.EndDateType = availDate.EndDateType; ;
            po.AvailableTimeSpan.EndDateOffset = availDate.EndDateOffset;
            */
            po.Glcode = "ricked";

            List<string> supportedAccs = new List<string>();
            po.SupportedAccountTypes = supportedAccs;

            List<BasePriceableItemInstance> piInstances = new List<BasePriceableItemInstance>();
            SMSPIInstance smsInstance = new SMSPIInstance();
            smsInstance.Description = "SMS";
            smsInstance.DisplayName = "SMS";
            smsInstance.Glcode = "GlCodeEP";
            PCIdentifier pci = new PCIdentifier("SMS");

            smsInstance.PITemplate = pci;

            Dictionary<LanguageCode, string> instanceLocalizedNames = new Dictionary<LanguageCode, string>();
            Dictionary<LanguageCode, string> instanceLocalizedDesc = new Dictionary<LanguageCode, string>();

            smsInstance.LocalizedDescriptions = instanceLocalizedDesc;
            smsInstance.LocalizedDisplayNames = instanceLocalizedNames;

            smsInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, "SMS English Description");
            smsInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, "SMS Japanese Description");
            smsInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, "SMS Italian Description");
            smsInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, "SMS French Description");
            smsInstance.LocalizedDescriptions.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, "SMS German Description");

            smsInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, "SMS English names");
            smsInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, "SMS Japanese Names");
            smsInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, "SMS Italian Names");
            smsInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, "SMS French Names");
            smsInstance.LocalizedDisplayNames.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, "SMS German Names");

            List<RateSchedule<Metratech_com_rateSMSRateEntry, Metratech_com_rateSMSDefaultRateEntry>> rscheds = new List<RateSchedule<Metratech_com_rateSMSRateEntry, Metratech_com_rateSMSDefaultRateEntry>>();

            Metratech_com_rateSMSRateEntry entry = new Metratech_com_rateSMSRateEntry();
            entry.Rate = 10.0M;
            entry.SMStype = MetraTech.DomainModel.Enums.SMS.Metratech_com_SMSType.SMSType.Basic;
            entry.SMStype_op = RateEntryOperators.Greater;

            RateSchedule<Metratech_com_rateSMSRateEntry, Metratech_com_rateSMSDefaultRateEntry> sched = new RateSchedule<Metratech_com_rateSMSRateEntry, Metratech_com_rateSMSDefaultRateEntry>();
            sched.RateEntries.Add(entry);
            /*ProdCatTimeSpan rsEffDate = new ProdCatTimeSpan();
            rsEffDate.StartDate = System.DateTime.Now;
            rsEffDate.StartDateOffset = 0;
            rsEffDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            rsEffDate.EndDate = System.DateTime.Now.AddYears(5);
            rsEffDate.EndDateOffset = 0;
            rsEffDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            sched.EffectiveDate = rsEffDate;*/
            rscheds.Add(sched);

            smsInstance.Metratech_com_rateSMS_RateSchedules = rscheds;
            smsInstance.Name = "SMS Testing Name";
            smsInstance.PITemplate = smsInstance.PITemplate;
            piInstances.Add(smsInstance);
            po.PriceableItems = piInstances;

            return po;
        }

        protected AudioConfCallPIInstance SetUpConfCall()
        {
            AudioConfCallPIInstance instance = new AudioConfCallPIInstance();
            AudioConfConnPIInstance conn = new AudioConfConnPIInstance();
            AudioConfFeaturePIInstance feat = new AudioConfFeaturePIInstance();
            return instance;
        }

        protected void GetPIInstanceForPO(out ProductOffering po, out BasePriceableItemInstance pi)
        {
            ProductOfferingServiceClient client = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");

            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            po = SaveProductOffering(client);

            try
            {
                //Verify PI Instance created.
                pi = null;
                client.GetPIInstanceForPO(new PCIdentifier((int)po.ProductOfferingId), new PCIdentifier(po.PriceableItems[0].ID.Value), out pi);
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }
        }

        protected void GetPIInstanceForPO(ProductOffering po, out BasePriceableItemInstance pi)
        {
            ProductOfferingServiceClient client = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");

            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                //Verify PI Instance created.
                pi = null;
                client.GetPIInstanceForPO(new PCIdentifier((int)po.ProductOfferingId), new PCIdentifier(po.PriceableItems[0].ID.Value), out pi);
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }
        }

        protected void SubscribeToProductOffering(ProductOffering po, out CorporateAccount corpAccount, out Subscription sub)
        {
            Guid acctGuid = Guid.NewGuid();

            ///////////<<<<<<<>>>>>>>>>>>>>>>////////
            MetraTech.DomainModel.BaseTypes.Account parentAcct = MetraTech.DomainModel.BaseTypes.Account.CreateAccount("CorporateAccount");
            corpAccount = (CorporateAccount)parentAcct;

            corpAccount.UserName = "CP_" + acctGuid;
            corpAccount.Password_ = "123";
            corpAccount.Name_Space = "mt";
            corpAccount.DayOfMonth = 31;
            corpAccount.AccountStatus = AccountStatus.Active;

            // Create one contact view.
            ContactView shipView = new ContactView();
            shipView.FirstName = "TestCorp";
            shipView.LastName = "CA_" + acctGuid;
            shipView.ContactType = ContactType.Ship_To;

            // Create one contact view.
            ContactView billView = new ContactView();
            billView.FirstName = "TestCorp2";
            billView.LastName = "CB_" + acctGuid;
            billView.ContactType = ContactType.Bill_To;

            // Create one internal view.
            InternalView corpInternalView = new InternalView();
            corpInternalView.Billable = true;
            corpInternalView.Language = LanguageCode.FR;
            corpInternalView.SecurityQuestion = SecurityQuestion.MothersMaidenName;
            corpInternalView.SecurityAnswer = "CIV1_" + acctGuid;
            corpInternalView.UsageCycleType = UsageCycleType.Monthly;

            // Set the internal view
            corpAccount.Internal = corpInternalView;

            // Add the contact views
            corpAccount.LDAP.Add(shipView);
            corpAccount.LDAP.Add(billView);


            AccountCreationClient acc = new AccountCreationClient();
            acc.ClientCredentials.UserName.UserName = "su";
            acc.ClientCredentials.UserName.Password = "su123";

            MetraTech.DomainModel.BaseTypes.Account corpAcct = corpAccount as MetraTech.DomainModel.BaseTypes.Account;
            acc.AddAccount(ref corpAcct, false);


            // Subscribe to the product offering
            SubscriptionServiceClient ssc = new SubscriptionServiceClient();
            ssc.ClientCredentials.UserName.UserName = "su";
            ssc.ClientCredentials.UserName.Password = "su123";

            sub = new Subscription();
            sub.SubscriptionSpan.StartDate = MetraTime.Now + TimeSpan.FromDays(10);
            sub.SubscriptionSpan.EndDate = MetraTime.Now + TimeSpan.FromDays(500);
            sub.SubscriptionSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            sub.SubscriptionSpan.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            sub.ProductOfferingId = po.ProductOfferingId.Value;
            ssc.AddSubscription(new AccountIdentifier(corpAccount.UserName, corpAccount.Name_Space), ref sub);
        }

        protected void CreateSubscription(out CorporateAccount corpAccount, out ProductOffering po, out Subscription sub)
        {
            corpAccount = null;
            po = null;
            sub = null;

            // Create a product offering to subscribe to
            po = SetUpProductOffering();
            po.AvailableTimeSpan = new ProdCatTimeSpan();
            po.AvailableTimeSpan.StartDate = MetraTime.Now;
            po.AvailableTimeSpan.EndDate = MetraTime.Max;
            po.EffectiveTimeSpan.StartDate = MetraTime.Now;
            po.EffectiveTimeSpan.EndDate = MetraTime.Max;

            SaveProductOffering(ref po);


            SubscribeToProductOffering(po, out corpAccount, out sub);
        }

        protected ProductOffering GetProductOffering()
        {
            return GetProductOffering(m_pId);
        }

        protected ProductOffering GetProductOffering(int poID)
        {
            ProductOfferingServiceClient client = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");

            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            ProductOffering po = null;
            client.GetProductOffering(new PCIdentifier(poID), out po);

            return po;
        }

        #endregion
    }
}