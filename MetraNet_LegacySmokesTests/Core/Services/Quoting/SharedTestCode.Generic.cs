using System;
using System.Collections.Generic;
using System.Globalization;
using System.ServiceProcess;
using System.Text;
using MetraTech.Account.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DataAccess;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTRuleSet;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using IMTConfigPropSet = MetraTech.Interop.MTProductCatalog.IMTConfigPropSet;
using IMTRule = MetraTech.Interop.MTProductCatalog.IMTRule;

namespace MetraTech.Core.Services.Test.Quoting
{
    #region Shared Helper Methods That Should Be In Different Library

    public class SharedTestCode
    {
        public const string MetratechComFlatrecurringcharge = "metratech.com/flatrecurringcharge";
        public const string MetratechComUdrctapered = "metratech.com/udrctapered";
        public const string MetratechComNonrecurringcharge = "metratech.com/nonrecurringcharge";
        public const string MetratechComUdrctiered = "metratech.com/udrctiered";

        #region Windows Service Related
        public static void MakeSureServiceIsStarted(string serviceName)
        {
            MakeSureServiceIsStarted(serviceName, 180);
        }

        public static void MakeSureServiceIsStarted(string serviceName, int timeoutSeconds)
        {
            ServiceController sc = new ServiceController(serviceName);

            if (sc.Status != ServiceControllerStatus.Running)
            {
                Console.WriteLine("The " + serviceName + " service status is currently set to {0}",
                                   sc.Status.ToString());
            }

            if (sc.Status == ServiceControllerStatus.Stopped)
            {
                // Start the service if the current status is stopped.

                try
                {
                    // Start the service, and wait until its status is "Running".
                    Console.WriteLine("Starting " + serviceName + "....");
                    sc.Start();
                    sc.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromSeconds(timeoutSeconds));

                    // Display the current service status.
                    Console.WriteLine("The " + serviceName + " service status is now set to {0}.",
                                       sc.Status.ToString());
                }
                catch (System.ServiceProcess.TimeoutException)
                {
                    throw new Exception(string.Format("Timed out after {0} seconds waiting for {1} service to start", timeoutSeconds, serviceName));
                }
                catch (InvalidOperationException)
                {
                    throw new Exception(string.Format("Unable to start the service {0}", serviceName));
                }
            }
        }
        #endregion

        #region Authorization/Authentication Related
        public static Interop.MTAuth.IMTSessionContext LoginAsSU()
        {
            IMTLoginContext loginContext = new MTLoginContextClass();
            //ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
            //sa.Initialize();
            //ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
            string suName = "su";
            string suPassword = "su123";
            try
            {
                return loginContext.Login(suName, "system_user", suPassword);
            }
            catch (Exception ex)
            {
                throw new Exception("LoginAsSU failed:" + ex.Message, ex);
            }
        }

        //Because admin password 'expires' and some unit tests update it
        //Admin password can be different at different times
        //This is the 'hacky' way of trying both ways so we don't depend on when the unit test is run
        //or if someone has logged in already manually
        protected static string adminPasswordToTryFirst = "123";
        public static Interop.MTAuth.IMTSessionContext LoginAsAdmin()
        {
            IMTLoginContext loginContext = new MTLoginContextClass();

            string suName = "admin";
            string suPassword = adminPasswordToTryFirst;
            try
            {
                return loginContext.Login(suName, "system_user", suPassword);
            }
            catch (Exception)
            {
                try
                {
                    suPassword = "Admin123";
                    MetraTech.Interop.MTAuth.IMTSessionContext sessionContext = loginContext.Login(suName, "system_user", suPassword);
                    adminPasswordToTryFirst = suPassword;
                    return sessionContext;
                }
                catch (Exception)
                {
                    try
                    {
                        suPassword = "1";
                        MetraTech.Interop.MTAuth.IMTSessionContext sessionContext = loginContext.Login(suName, "system_user", suPassword);
                        adminPasswordToTryFirst = suPassword;
                        return sessionContext;
                    }
                    catch (Exception ex)
                    {
                        throw new Exception("LoginAsAdmin failed:" + ex.Message, ex);
                    }
                }
            }
        }
        #endregion

        #region Group Subscription Related
        public static MTList<GroupSubscriptionMember> GetMembersOfGroupSubscription(int idGroupSubscription)
        {
            MTList<GroupSubscriptionMember> results = new MTList<GroupSubscriptionMember>();

            GroupSubscriptionService_GetMembersForGroupSubscription2_Client getGroupSubMembers =
              new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
            getGroupSubMembers.In_groupSubscriptionId = idGroupSubscription;
            getGroupSubMembers.InOut_groupSubscriptionMembers = results;
            getGroupSubMembers.UserName = "su";
            getGroupSubMembers.Password = "su123";
            getGroupSubMembers.Invoke();

            results = getGroupSubMembers.InOut_groupSubscriptionMembers;

            return results;
        }
        #endregion

        #region Product Catalog

        private static IMTProductCatalog mProductCatalog = null;
        public static IMTProductCatalog CurrentProductCatalog
        {
            get
            {
                //TODO: Cache this and return pre-initialized one
                MetraTech.Interop.MTProductCatalog.IMTSessionContext sessionContext = GetSessionContextForProductCatalog();

                mProductCatalog = new MTProductCatalogClass();
                mProductCatalog.SetSessionContext(sessionContext);

                return mProductCatalog;
            }
        }

        protected static MetraTech.Interop.MTProductCatalog.IMTSessionContext GetSessionContextForProductCatalog()
        {
            //Todo: Fix to read from server access file if we decide to use SuperUser as opposed to user generating quote
            Interop.MTAuth.IMTLoginContext loginContext = new Interop.MTAuth.MTLoginContextClass();
            //ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
            //sa.Initialize();
            //ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
            string suName = "su";
            string suPassword = "su123";
            try
            {
                return (MetraTech.Interop.MTProductCatalog.IMTSessionContext)loginContext.Login(suName, "system_user", suPassword);
            }
            catch (Exception ex)
            {
                throw new Exception("GetSessionContextForProductCatalog: Login failed:" + ex.Message, ex);
            }

        }

        #endregion

        /// <summary> Helper to populate SubscriptionParameters with default UDRCInstanceValues
        /// </summary>
        /// <param name="productOffering">Product offering to populate for</param>
        /// <param name="value">Value of UDRC metrics</param>
        /// <param name="idUDRC">Sets UDRC ID if passed (used to test failing case)</param>
        public static Dictionary<string, List<UDRCInstanceValueBase>> GetUDRCInstanceValuesSetToMiddleValues(IMTProductOffering productOffering, decimal value = 20m, int? idUDRC = null)
        {
            var dictionaryToReturn = new Dictionary<string, List<UDRCInstanceValueBase>>();

            Interop.MTProductCatalog.IMTCollection possibleInstances = productOffering.GetPriceableItems();
            var actualUDRCInstances = new List<IMTRecurringCharge>();
            foreach (IMTPriceableItem possibleUDRC in possibleInstances)
            {
                if (possibleUDRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
                {
                    actualUDRCInstances.Add((IMTRecurringCharge)possibleUDRC);

                    var udrcValue = new UDRCInstanceValueBase
                    {
                        UDRC_Id = idUDRC.HasValue ? idUDRC.Value : possibleUDRC.ID,
						//StartDate = MetraTime.Now,
                        //EndDate = MetraTime.Now.AddYears(1),
                        StartDate = new DateTime(2000,01,01),
                        EndDate = new DateTime(2020, 01, 01),
                        Value = value
                    };

                    if (dictionaryToReturn.ContainsKey(productOffering.ID.ToString()))
                    {
                        dictionaryToReturn[productOffering.ID.ToString()].Add(udrcValue);
                    }
                    else
                    {
                        dictionaryToReturn.Add(productOffering.ID.ToString(), new List<UDRCInstanceValueBase>() { udrcValue });
                    }
                }
            }

            return dictionaryToReturn;
        }


        /// <summary> Set AllowICB flag for PI
        /// </summary>
        /// <param name="pi">Pi to set flag</param>
        /// <param name="client">PriceListServiceClient </param>
        /// <param name="poId">Id of PO that has referred PI</param>
        /// <param name="ptId">Parameter table ID</param>
        /// <param name="ptName">Parameter table name</param>
        /// <param name="allowICBFlag"></param>
        /// <returns></returns>
        public static PIAndPTParameters SetAllowICBForPI(IMTPriceableItem pi, PriceListServiceClient client,
                                      int poId, int ptId, string ptName, bool allowICBFlag = true)
        {
            PriceListMapping plMappingForUdrc;
            int chargeId;
            if (pi.Kind == MTPCEntityType.PCENTITY_TYPE_NON_RECURRING)
            {
                var charge = pi as IMTNonRecurringCharge;
                Assert.IsNotNull(charge, "Charge in SetAllowICBForPI should be null");
                chargeId = charge.ID;
            }

            else
            {
                var charge = pi as IMTRecurringCharge;
                Assert.IsNotNull(charge, "Charge in SetAllowICBForPI should be null");
                chargeId = charge.ID;
            }


            client.GetPriceListMappingForProductOffering(
                new PCIdentifier(poId),
                new PCIdentifier(chargeId),
                new PCIdentifier(ptId),
                out plMappingForUdrc);
            plMappingForUdrc.CanICB = allowICBFlag;
            client.SavePriceListMappingForProductOffering
                (new PCIdentifier(poId),
                 new PCIdentifier(chargeId),
                 new PCIdentifier(ptId),
                 ref plMappingForUdrc);

            return new PIAndPTParameters
            {
                ParameterTableId = ptId,
                ParameterTableName = ptName,
                PriceableItemId = chargeId
            };
        }

        public static ProductOfferingFactoryConfiguration CreateProductOfferingConfiguration(string testName, string testRunUniqueIdentifier,
                                                                           out IMTProductOffering productOffering)
        {
            var pofConfiguration = new ProductOfferingFactoryConfiguration(testName, testRunUniqueIdentifier);
            pofConfiguration.CountNRCs = 1;
            pofConfiguration.CountPairRCs = 1;
            pofConfiguration.CountPairUDRCs = 0;
            pofConfiguration.Cycle.CycleTypeID = (int)CycleType.Annually;
            pofConfiguration.Cycle.StartDay = 1;
            pofConfiguration.Cycle.StartMonth = 1;

            productOffering = ProductOfferingFactory.Create(pofConfiguration);
            //Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
            Console.WriteLine("Product Offering for quote:" + productOffering.ID + "; " + productOffering.DisplayName);
            return pofConfiguration;
        }

        public static List<MetraTech.DomainModel.BaseTypes.Account> CreateHierarchyofAccounts(string billcycle, string testShortName,
                                                                       string testRunUniqueIdentifier)
        {
            var Hierarchy = new List<DomainModel.BaseTypes.Account>();
            var corpAccountHolder = new CorporateAccountFactory(testShortName + "0", testRunUniqueIdentifier);
            testRunUniqueIdentifier = MetraTime.NowWithMilliSec;
            var deptAccountHolder1 = new DepartmentAccountFactory(testShortName + "1", testRunUniqueIdentifier);
            testRunUniqueIdentifier = MetraTime.NowWithMilliSec;
            var coresubscriberAccountHolder = new CoreSubscriberAccountFactory(testShortName, testRunUniqueIdentifier);
            switch (billcycle)
            {
                case "Semi_Annually":
                    GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1,
                                 ref coresubscriberAccountHolder, UsageCycleType.Semi_Annually);
                    break;

                case "Quarterly":
                    GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1,
                                 ref coresubscriberAccountHolder, UsageCycleType.Quarterly);
                    break;
                case "Monthly":
                    GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1,
                                 ref coresubscriberAccountHolder, UsageCycleType.Monthly);
                    break;
                case "Semi_monthly":
                    GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1,
                                 ref coresubscriberAccountHolder, UsageCycleType.Semi_monthly);
                    break;
                case "Bi_weekly":
                    GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1,
                                 ref coresubscriberAccountHolder, UsageCycleType.Bi_weekly);
                    break;
                case "Weekly":
                    GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1,
                                 ref coresubscriberAccountHolder, UsageCycleType.Weekly);
                    break;
                case "Daily":
                    GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1,
                                 ref coresubscriberAccountHolder, UsageCycleType.Monthly);
                    break;
                default:
                    GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1,
                                 ref coresubscriberAccountHolder, UsageCycleType.Annually);
                    break;
            }
            Hierarchy.Add(corpAccountHolder.Item);
            Hierarchy.Add(deptAccountHolder1.Item);
            Hierarchy.Add(coresubscriberAccountHolder.Item);
            Console.WriteLine("Billing Cycle:" + corpAccountHolder.CycleType);
            Console.WriteLine("Corporate Account:" + corpAccountHolder.Item._AccountID + "; Account name:" + corpAccountHolder.Item.UserName);
            Console.WriteLine("1st Department Account:" + deptAccountHolder1.Item._AccountID + "; Account name:" + deptAccountHolder1.Item.UserName);
            Console.WriteLine("CoreSubscriber Account:" + coresubscriberAccountHolder.Item._AccountID + "; Account name:" + coresubscriberAccountHolder.Item.UserName);
            return Hierarchy;
        }
        private static void GetHierarchy(ref CorporateAccountFactory corpAccountHolder,
                            ref DepartmentAccountFactory deptAccountHolder1,
                            ref CoreSubscriberAccountFactory coresubscriberAccountHolder, UsageCycleType usageCycleType)
        {
            // Create account #1 Corporate root
            corpAccountHolder.CycleType = usageCycleType;
            corpAccountHolder.Instantiate();
            //Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create corporate account for test run");
            // Create account #2 Department child
            deptAccountHolder1.CycleType = usageCycleType;
            deptAccountHolder1 = createDeptAccount(deptAccountHolder1, corpAccountHolder.Item._AccountID.Value);
            //Create account #3 CoreSubscriber child
            //coresubscriberAccountHolder.is
            //coresubscriberAccountHolder = deptAccountHolder2.AddCoreSubscriber("User");
            coresubscriberAccountHolder.AncestorID = deptAccountHolder1.Item._AccountID.Value;
            coresubscriberAccountHolder.CycleType = usageCycleType;
            coresubscriberAccountHolder.Instantiate();
            //Assert.IsNotNull(coresubscriberAccountHolder.Item._AccountID, "Unable to create CoreSubscriber account for test run");
        }

        public static DepartmentAccountFactory createDeptAccount(DepartmentAccountFactory dept, int ancestorID)
        {
            dept.AncestorID = ancestorID;
            dept.Instantiate();
            //Assert.IsNotNull(dept.Item._AccountID, "Unable to create department account for test run");
            return dept;
        }

    }

    #region Product Catalog Related Classes

    /// <summary>
    /// Parameters for product offering factory
    /// </summary>
    public class ProductOfferingFactoryConfiguration
    {
        public string Name { get; set; }
        public string DisplayName { get; set; }
        public string UniqueIdentifier { get; set; }

        public IMTPCCycle Cycle { get; set; }

        public string Currency { get; set; }

        public short CountPairRCs { get; set; } //????

        public short CountPairUDRCs { get; set; }

        public short CountNRCs { get; set; }

        public decimal RCAmount { get; set; }

        public decimal NRCAmount { get; set; }

        public decimal RCPerSubscriptionAmount { get; set; }

        public decimal TotalAmount { get; set; } //???

        public bool AddCharges { get; set; }

        public bool AllowIcbPrices { get; set; }
        public CorporateAccountFactory AccountFactory { get; set; }

        public List<PIAndPTParameters> PriceableItemsAndParameterTableForRc { get; set; }
        public List<PIAndPTParameters> PriceableItemsAndParameterTableForNonRc { get; set; }
        public List<PIAndPTParameters> PriceableItemsAndParameterTableForUdrc { get; set; }

        protected ProductOfferingFactoryConfiguration()
        {
            SetDefaults();
        }

        public ProductOfferingFactoryConfiguration(string baseName, string uniquifier)
        {
            SetDefaults();
            Name = baseName;
            UniqueIdentifier = uniquifier;
        }

        protected void SetDefaults()
        {
            Name = string.Empty;
            UniqueIdentifier = string.Empty;
            RCAmount = 19.95M;
            NRCAmount = 9.95M;
            RCPerSubscriptionAmount = 19.95M;

            CountNRCs = 1;
            CountPairRCs = 1;
            CountPairUDRCs = 0;

            TotalAmount = CountPairRCs * RCAmount * 2 + CountNRCs * NRCAmount;

            Currency = SystemCurrencies.USD.ToString();

            AddCharges = true;

            PriceableItemsAndParameterTableForRc = new List<PIAndPTParameters>();
            PriceableItemsAndParameterTableForNonRc = new List<PIAndPTParameters>();
            PriceableItemsAndParameterTableForUdrc = new List<PIAndPTParameters>();

            Cycle = new MTPCCycle();
        }
    }

    public class RCParameters
    {
         public bool ChargeInAdvance;
         public bool ProrateOnActivation;
         public bool ProrateOnDeactivation;
         public bool ProrateOnRateChange;
         public bool FixedProrationLength;
         public bool ChargePerParticipant;
    }

    public class PIAndPTParameters
    {
        public int ParameterTableId { get; set; }
        public string ParameterTableName { get; set; }
        public int PriceableItemId { get; set; }
    }

    public class ProductOfferingFactory
    {
        public int IdUdrc { get; set; }

        private IMTProductOffering mProductOffering;

        public IMTProductOffering Item
        {
            get { return mProductOffering; }
            set { mProductOffering = value; }
        }

        public IMTProductCatalog ProductCatalog { get; private set; }

        private List<IMTRecurringCharge> piTemplate_FRRC_ChargePerParticipantList;
        public List<IMTRecurringCharge> piTemplate_FRRC_ChargePerSubList;
        private List<IMTRecurringCharge> piTemplate_UDRC_ChargePerParticipantList;
        private List<IMTRecurringCharge> piTemplate_UDRC_ChargePerSubList;

        private List<IMTNonRecurringCharge> piTemplate_NRC_ChargeOnSubscribeList;


        private int chargeCounter = 1;
        private int ChargeCounter
        {
            get
            {
                return chargeCounter++;
            }
        }

        protected string baseName = "";
        protected virtual string BaseName
        {
            get { return baseName; }
        }

        protected string uniqueInstanceIdentifier = "";
        protected virtual string UniqueInstanceIdentifier
        {
            get { return uniqueInstanceIdentifier; }
        }

        Dictionary<string, List<UDRCInstanceValue>> m_UDRCInstanceValues = new Dictionary<string, List<UDRCInstanceValue>>();

        public virtual MetraTech.Interop.MTProductCatalog.IMTSessionContext GetSessionContextForCreate()
        {
            return (MetraTech.Interop.MTProductCatalog.IMTSessionContext)SharedTestCode.LoginAsSU();
        }

        /// <summary>
        /// <see cref="MetraTech.Core.Services.BaseSubscriptionService.CastCycle(Cycle)"/>
        /// </summary>
        /// <param name="name"></param>
        /// <param name="uniqueIdentifier"></param>
        /// <param name="cycle"></param>
        /// <param name="addCharges"></param>
        /// <param name="countNRCs"></param>
        /// <param name="countRCs"></param>
        /// <param name="countUDRCs"></param>
        /// <returns></returns>
        public static IMTProductOffering Create(string name, string uniqueIdentifier, IMTPCCycle cycle, bool addCharges = true,
                                                Int16 countNRCs = 1, Int16 countRCs = 1, Int16 countUDRCs = 0)
        {
            ProductOfferingFactory productOfferingHolder = new ProductOfferingFactory();
            productOfferingHolder.Initialize(name, uniqueIdentifier);

            //Create priceableitems
            List<IMTRecurringCharge> charges = new List<IMTRecurringCharge>();

            if (addCharges)
            {
                productOfferingHolder.piTemplate_NRC_ChargeOnSubscribeList =
                      productOfferingHolder.AddNonRecurringCharge("Setup Charge_" + uniqueIdentifier,
                                                                MTNonRecurringEventType.NREVENT_TYPE_SUBSCRIBE, countNRCs);
                productOfferingHolder.piTemplate_FRRC_ChargePerParticipantList =
                      productOfferingHolder.CreateFlatRateRecurringCharge(countRCs, cycle, new RCParameters() { ChargePerParticipant = true});

                productOfferingHolder.piTemplate_FRRC_ChargePerSubList =
                    productOfferingHolder.CreateFlatRateRecurringCharge(countRCs, cycle, new RCParameters() { ChargePerParticipant = false});


                productOfferingHolder.piTemplate_UDRC_ChargePerParticipantList = productOfferingHolder.CreateUDRC(countUDRCs, cycle, new RCParameters() { ChargePerParticipant = true });

                productOfferingHolder.piTemplate_UDRC_ChargePerSubList = productOfferingHolder.CreateUDRC(countUDRCs, cycle, new RCParameters() { ChargePerParticipant = false });

                //Create a Product Offering
                charges.AddRange(productOfferingHolder.piTemplate_FRRC_ChargePerParticipantList);
                charges.AddRange(productOfferingHolder.piTemplate_FRRC_ChargePerSubList);
                charges.AddRange(productOfferingHolder.piTemplate_UDRC_ChargePerParticipantList);
                charges.AddRange(productOfferingHolder.piTemplate_UDRC_ChargePerSubList);
            }

            productOfferingHolder.mProductOffering = productOfferingHolder.CreateProductOffering(charges);

            return productOfferingHolder.mProductOffering;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="configuration"></param>
        /// <returns></returns>
        public static IMTProductOffering Create(ProductOfferingFactoryConfiguration configuration)
        {
            var productOfferingHolder = new ProductOfferingFactory();
            productOfferingHolder.Initialize(configuration.Name, configuration.UniqueIdentifier);

            //Create priceableitems
            productOfferingHolder.piTemplate_NRC_ChargeOnSubscribeList = productOfferingHolder.AddNonRecurringCharge("Setup Charge",
                                                               MTNonRecurringEventType.NREVENT_TYPE_SUBSCRIBE, configuration.CountNRCs);
            productOfferingHolder.piTemplate_FRRC_ChargePerParticipantList = productOfferingHolder.CreateFlatRateRecurringCharge(configuration.CountPairRCs, configuration.Cycle, new RCParameters() { ChargePerParticipant = true });
            productOfferingHolder.piTemplate_FRRC_ChargePerSubList = productOfferingHolder.CreateFlatRateRecurringCharge(configuration.CountPairRCs, configuration.Cycle, new RCParameters() { ChargePerParticipant = false });
            productOfferingHolder.piTemplate_UDRC_ChargePerParticipantList = productOfferingHolder.CreateUDRC(configuration.CountPairUDRCs, configuration.Cycle, new RCParameters() { ChargePerParticipant = true });
            productOfferingHolder.piTemplate_UDRC_ChargePerSubList = productOfferingHolder.CreateUDRC(configuration.CountPairUDRCs, configuration.Cycle, new RCParameters() { ChargePerParticipant = false });


            //Create Product Offering
            var charges = new List<IMTPriceableItem>();
            charges.AddRange(productOfferingHolder.piTemplate_NRC_ChargeOnSubscribeList);
            charges.AddRange(productOfferingHolder.piTemplate_FRRC_ChargePerParticipantList);
            charges.AddRange(productOfferingHolder.piTemplate_FRRC_ChargePerSubList);
            charges.AddRange(productOfferingHolder.piTemplate_UDRC_ChargePerParticipantList);
            charges.AddRange(productOfferingHolder.piTemplate_UDRC_ChargePerSubList);
            productOfferingHolder.mProductOffering = productOfferingHolder.CreateProductOffering(charges);

            //Add rate schedules and rates
            for (var i = 0; i < configuration.CountNRCs; i++) // nonrecurringcharge
            {
                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/nonrecurringcharge",
                                                                          productOfferingHolder.mProductOffering.NonSharedPriceListID,
                                                                          productOfferingHolder.piTemplate_NRC_ChargeOnSubscribeList[i].ID,
                                                                          string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), "nrcsubrules1.xml"));
            }
            for (var i = 0; i < configuration.CountPairRCs; i++) // flatrecurringcharge
            {
                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/flatrecurringcharge",
                                                                          productOfferingHolder.mProductOffering.NonSharedPriceListID,
                                                                          productOfferingHolder.piTemplate_FRRC_ChargePerSubList[i].ID,
                                                                          string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), "flatrcrules1.xml"));

                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/flatrecurringcharge",
                                                                          productOfferingHolder.mProductOffering.NonSharedPriceListID,
                                                                          productOfferingHolder.piTemplate_FRRC_ChargePerParticipantList[i].ID,
                                                                          string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), "flatrcrules1.xml"));
            }
            for (var i = 0; i < configuration.CountPairUDRCs; i++) // udrc
            {
                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/udrctapered",
                                                                          productOfferingHolder.mProductOffering.NonSharedPriceListID,
                                                                          productOfferingHolder.piTemplate_UDRC_ChargePerParticipantList[i].ID,
                                                                          string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), "udrctaperrulespersub1.xml"));

                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/udrctapered",
                                                                           productOfferingHolder.mProductOffering.NonSharedPriceListID,
                                                                           productOfferingHolder.piTemplate_UDRC_ChargePerSubList[i].ID,
                                                                           string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), "udrctaperrulespersub1.xml"));
            }

            return productOfferingHolder.mProductOffering;
        }

        public static IMTProductOffering CreateWithoutPerParticipantCharges(ProductOfferingFactoryConfiguration configuration, out ProductOfferingFactory productOfferingHolder)
        {
            productOfferingHolder = new ProductOfferingFactory();
            productOfferingHolder.Initialize(configuration.Name, configuration.UniqueIdentifier);

            //Create priceableitems
            productOfferingHolder.piTemplate_FRRC_ChargePerSubList = productOfferingHolder.CreateFlatRateRecurringCharge(configuration.CountPairRCs, configuration.Cycle, new RCParameters() { ChargePerParticipant = false });
            productOfferingHolder.piTemplate_UDRC_ChargePerSubList = productOfferingHolder.CreateUDRC(configuration.CountPairUDRCs, configuration.Cycle, new RCParameters() { ChargePerParticipant = false });
            productOfferingHolder.piTemplate_NRC_ChargeOnSubscribeList = productOfferingHolder.AddNonRecurringCharge("Setup Charge",
              MTNonRecurringEventType.NREVENT_TYPE_SUBSCRIBE, configuration.CountNRCs);


            //Create Product Offering
            var charges = new List<IMTPriceableItem>();
            charges.AddRange(productOfferingHolder.piTemplate_NRC_ChargeOnSubscribeList);
            charges.AddRange(productOfferingHolder.piTemplate_FRRC_ChargePerSubList);
            charges.AddRange(productOfferingHolder.piTemplate_UDRC_ChargePerSubList);
            productOfferingHolder.mProductOffering = productOfferingHolder.CreateProductOffering(charges);

            //Add rate schedules and rates
            for (var i = 0; i < configuration.CountNRCs; i++) // nonrecurringcharge
            {
                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/nonrecurringcharge",
                                                                          productOfferingHolder.mProductOffering.NonSharedPriceListID,
                                                                          productOfferingHolder.piTemplate_NRC_ChargeOnSubscribeList[i].ID,
                                                                          string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), "nrcsubrules1.xml"));
            }
            for (var i = 0; i < configuration.CountPairRCs; i++) // flatrecurringcharge
            {
                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/flatrecurringcharge",
                                                                          productOfferingHolder.mProductOffering.NonSharedPriceListID,
                                                                          productOfferingHolder.piTemplate_FRRC_ChargePerSubList[i].ID,
                                                                          string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), "flatrcrules1.xml"));
            }
            for (var i = 0; i < configuration.CountPairUDRCs; i++) // udrc
            {
                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/udrctapered",
                                                                           productOfferingHolder.mProductOffering.NonSharedPriceListID,
                                                                           productOfferingHolder.piTemplate_UDRC_ChargePerSubList[i].ID,
                                                                           string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), "udrctaperrulespersub1.xml"));
            }

            return productOfferingHolder.mProductOffering;
        }

        public static IMTProductOffering CreateWithRCMissingRates(string name, string uniqueIdentifier, IMTPCCycle cycle = null, Int16 countRCs = 1, Int16 countUDRCs = 0)
        {
            var productOfferingHolder = new ProductOfferingFactory();
            productOfferingHolder.Initialize(name, uniqueIdentifier);

            //Create priceableitems

            //productOfferingHolder.piTemplate_NRC_ChargeOnSubscribe = productOfferingHolder.AddNonRecurringCharge("Setup Charge",
            //                                                   MTNonRecurringEventType.NREVENT_TYPE_SUBSCRIBE);

            productOfferingHolder.piTemplate_FRRC_ChargePerParticipantList = productOfferingHolder.CreateFlatRateRecurringCharge(countRCs, cycle, new RCParameters() { ChargePerParticipant = true });

            productOfferingHolder.piTemplate_FRRC_ChargePerSubList = productOfferingHolder.CreateFlatRateRecurringCharge(countRCs, cycle, new RCParameters() { ChargePerParticipant = false });


            productOfferingHolder.piTemplate_UDRC_ChargePerParticipantList = productOfferingHolder.CreateUDRC(countUDRCs, cycle, new RCParameters() { ChargePerParticipant = true });

            productOfferingHolder.piTemplate_UDRC_ChargePerSubList = productOfferingHolder.CreateUDRC(countUDRCs, cycle, new RCParameters() { ChargePerParticipant = false });


            //Create a Product Offering
            List<IMTPriceableItem> charges = new List<IMTPriceableItem>();
            charges.AddRange(productOfferingHolder.piTemplate_FRRC_ChargePerParticipantList);
            charges.AddRange(productOfferingHolder.piTemplate_FRRC_ChargePerSubList);
            charges.AddRange(productOfferingHolder.piTemplate_UDRC_ChargePerParticipantList);
            charges.AddRange(productOfferingHolder.piTemplate_UDRC_ChargePerSubList);

            productOfferingHolder.mProductOffering = productOfferingHolder.CreateProductOffering(charges);

            ////Add rate schedules and rates
            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/nonrecurringcharge",
            //                                    productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                                    productOfferingHolder.piTemplate_NRC_ChargeOnSubscribe.ID,
            //                                    string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                                  Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                                  "nrcsubrules1.xml"));

            ////productOfferingHolder.CreateRecurringChargeRateSchedule("metratech.com/flatrecurringcharge",
            ////                              productOfferingHolder.mProductOffering.NonSharedPriceListID,
            ////                              productOfferingHolder.piTemplate_FRRC_ChargePerParticipant.ID,
            ////                              RCAmount);

            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/flatrecurringcharge",
            //                               productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                               productOfferingHolder.piTemplate_FRRC_ChargePerSub.ID,
            //                               string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                             Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                             "flatrcrules1.xml"));

            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/flatrecurringcharge",
            //                         productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                         productOfferingHolder.piTemplate_FRRC_ChargePerParticipant.ID,
            //                         string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                       "flatrcrules1.xml"));

            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/udrctapered",
            //                              productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                              productOfferingHolder.piTemplate_UDRC_ChargePerParticipant.ID,
            //                              string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                            "udrctaperrulespersub1.xml"));

            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/udrctapered",
            //                              productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                              productOfferingHolder.piTemplate_FRRC_ChargePerSub.ID,
            //                              string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                            "udrctaperrulespersub1.xml"));

            return productOfferingHolder.mProductOffering;
        }

        public static IMTProductOffering CreateWithNRCMissingRates(string name, string uniqueIdentifier, IMTPCCycle cycle = null, Int16 countRCs = 1, Int16 countUDRCs = 0)
        {
            ProductOfferingFactory productOfferingHolder = new ProductOfferingFactory();
            productOfferingHolder.Initialize(name, uniqueIdentifier);

            //Create priceableitems

            productOfferingHolder.piTemplate_NRC_ChargeOnSubscribeList = productOfferingHolder.AddNonRecurringCharge("Setup Charge_" + uniqueIdentifier, MTNonRecurringEventType.NREVENT_TYPE_SUBSCRIBE, 1);

            productOfferingHolder.piTemplate_FRRC_ChargePerParticipantList = productOfferingHolder.CreateFlatRateRecurringCharge(countRCs, cycle, new RCParameters() { ChargePerParticipant = true });

            productOfferingHolder.piTemplate_FRRC_ChargePerSubList = productOfferingHolder.CreateFlatRateRecurringCharge(countRCs, cycle, new RCParameters() { ChargePerParticipant = false });


            productOfferingHolder.piTemplate_UDRC_ChargePerParticipantList = productOfferingHolder.CreateUDRC(countUDRCs, cycle, new RCParameters() { ChargePerParticipant = true });

            productOfferingHolder.piTemplate_UDRC_ChargePerSubList = productOfferingHolder.CreateUDRC(countUDRCs, cycle, new RCParameters() { ChargePerParticipant = false });


            //Create a Product Offering
            List<IMTPriceableItem> charges = new List<IMTPriceableItem>();
            charges.AddRange(productOfferingHolder.piTemplate_NRC_ChargeOnSubscribeList);
            charges.AddRange(productOfferingHolder.piTemplate_FRRC_ChargePerParticipantList);
            charges.AddRange(productOfferingHolder.piTemplate_FRRC_ChargePerSubList);
            charges.AddRange(productOfferingHolder.piTemplate_UDRC_ChargePerParticipantList);
            charges.AddRange(productOfferingHolder.piTemplate_UDRC_ChargePerSubList);

            productOfferingHolder.mProductOffering = productOfferingHolder.CreateProductOffering(charges);

            ////Add rate schedules and rates
            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/nonrecurringcharge",
            //                                    productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                                    productOfferingHolder.piTemplate_NRC_ChargeOnSubscribe.ID,
            //                                    string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                                  Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                                  "nrcsubrules1.xml"));

            for (int i = 0; i < countRCs; i++)
            {
                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/flatrecurringcharge",
                                                                          productOfferingHolder.mProductOffering
                                                                                               .NonSharedPriceListID,
                                                                          productOfferingHolder.piTemplate_FRRC_ChargePerSubList[i].ID,
                                                                          string.Format(
                                                                              "{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                              Environment.GetEnvironmentVariable(
                                                                                  "METRATECHTESTDATABASE"),
                                                                              "flatrcrules1.xml"));

                productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/flatrecurringcharge",
                                                                          productOfferingHolder.mProductOffering
                                                                                               .NonSharedPriceListID,
                                                                          productOfferingHolder
                                                                              .piTemplate_FRRC_ChargePerParticipantList[i].ID,
                                                                          string.Format(
                                                                              "{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                                                              Environment.GetEnvironmentVariable(
                                                                                  "METRATECHTESTDATABASE"),
                                                                              "flatrcrules1.xml"));
            }

            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/flatrecurringcharge",
            //                               productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                               productOfferingHolder.piTemplate_FRRC_ChargePerSub.ID,
            //                               string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                             Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                             "flatrcrules1.xml"));

            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/flatrecurringcharge",
            //                         productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                         productOfferingHolder.piTemplate_FRRC_ChargePerParticipant.ID,
            //                         string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                       "flatrcrules1.xml"));

            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/udrctapered",
            //                              productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                              productOfferingHolder.piTemplate_UDRC_ChargePerParticipant.ID,
            //                              string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                            "udrctaperrulespersub1.xml"));

            //productOfferingHolder.CreateRateScheduleWithRulesFromFile("metratech.com/udrctapered",
            //                              productOfferingHolder.mProductOffering.NonSharedPriceListID,
            //                              productOfferingHolder.piTemplate_FRRC_ChargePerSub.ID,
            //                              string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
            //                                            Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
            //                                            "udrctaperrulespersub1.xml"));

            return productOfferingHolder.mProductOffering;
        }

        //TODO: Fix this to be able to set rates in test instead of loading from file
        public IMTRateSchedule CreateRecurringChargeRateSchedule(string paramTableName, int idPriceList, int idPITemplate,
                                                                 decimal RCAmount)
        {
            //Would have been nice to do this programatically but setting rules is tooo cumbersome using api
            //Taking the 'easy' way out and just creating xml for what we want and using that to set the rate
            string xmlFlatRecurringChargeRulesBase = @"<?xml version=""1.0"" encoding=""UTF-8""?>
                                                  <xmlconfig>
                                                    <configdata>
                                                      <default_actions>
                                                          <action>
                                                            <prop_name>RCAmount</prop_name>
                                                            <prop_value ptype=""DECIMAL"">%%RCAmount%%</prop_value>
                                                          </action>
                                                      </default_actions>
                                                    </configdata>
                                                  </xmlconfig>";

            string xmlFlatRecurringChargeRules = xmlFlatRecurringChargeRulesBase.Replace("%%RCAmount%%", RCAmount.ToString());

            return CreateRateScheduleWithRules(paramTableName, idPriceList, idPITemplate, xmlFlatRecurringChargeRules);
        }

        public IMTRateSchedule CreateFlatRecurringChargeRateSchedule(int idPriceList, int idPriceableItem, decimal amount)
        {
            var sched = CreateRateSchedule("metratech.com/flatrecurringcharge", idPriceList, idPriceableItem);

            var actions = new MTActionSet
       {
        new MTAssignmentAction
          {
            PropertyName = "RCAmount",
            PropertyType = Interop.MTRuleSet.PropValType.PROP_TYPE_DECIMAL,
            PropertyValue = amount
          }
        };
            var rule = new MTRule
            {
                Actions = actions
            };

            sched.RuleSet.Add((IMTRule)rule);

            sched.Save();

            return sched;
        }
        public IMTRateSchedule CreateNonRecurringChargeRateSchedule(int idPriceList, int idPriceableItem, decimal amount)
        {
            return CreateSimpleRecurringRateSchedule("metratech.com/nonrecurringcharge", idPriceList, idPriceableItem, "NRCAmount", amount);
        }
        //TODO: Fix this to be able to set rates in test instead of loading from file
        private IMTRateSchedule CreateSimpleRecurringRateSchedule(string paramTableName, int idPriceList, int idPriceableItem, string type, decimal amount)
        {
            //Would have been nice to do this programatically but setting rules is tooo cumbersome using api
            //Taking the 'easy' way out and just creating xml for what we want and using that to set the rate
            const string xmlFlatRecurringChargeRules = @"<?xml version=""1.0"" encoding=""UTF-8""?>
                                                  <xmlconfig>
                                                    <configdata>
                                                      <default_actions>
                                                          <action>
                                                            <prop_name>{0}</prop_name>
                                                            <prop_value ptype=""DECIMAL"">{1}</prop_value>
                                                          </action>
                                                      </default_actions>
                                                    </configdata>
                                                  </xmlconfig>";
            return CreateRateScheduleWithRules(paramTableName, idPriceList, idPriceableItem,
              string.Format(CultureInfo.InvariantCulture, xmlFlatRecurringChargeRules, type, amount));
        }
        public IMTRateSchedule CreateTaperedUdrcRateSchedule(int idPriceList, int idPriceableItem, Dictionary<decimal, decimal> values)
        {
            const string rateSet = @"<constraint_set>
                                <actions>
                                  <action>
                                    <prop_name>UnitAmount</prop_name>
                                    <prop_value ptype=""DECIMAL"">{1}</prop_value>
                                  </action>
                                </actions>
                                <constraint>
                                  <prop_name>UnitValue</prop_name>
                                  <condition>less_equal</condition>
                                  <prop_value ptype=""DECIMAL"">{0}</prop_value>
                                </constraint>
                              </constraint_set>";

            var rateBuilder = new StringBuilder(@"<?xml version=""1.0"" encoding=""UTF-8""?><xmlconfig>");
            foreach (var unit in values)
                rateBuilder.AppendFormat(CultureInfo.InvariantCulture, rateSet, unit.Key, unit.Value);
            rateBuilder.Append(@"</configdata></xmlconfig>");

            return CreateRateScheduleWithRules("metratech.com/udrctapered", idPriceList, idPriceableItem, rateBuilder.ToString());
        }

        public IMTRateSchedule CreateRateScheduleWithRules(string paramTableName, int idPriceList, int idPITemplate, string xmlRuleSetBuffer)
        {
            IMTRateSchedule sched = CreateRateSchedule(paramTableName, idPriceList, idPITemplate);

            Interop.PropSet.IMTConfig propset = new Interop.PropSet.MTConfig();

            bool checksumsMatch;
            Interop.PropSet.IMTConfigPropSet configSetIn = propset.ReadConfigurationFromString(xmlRuleSetBuffer, out checksumsMatch);

            sched.RuleSet.ReadFromSet((IMTConfigPropSet)configSetIn);

            sched.SaveWithRules();

            return sched;
        }

        public IMTRateSchedule CreateRateScheduleWithRulesFromFile(string paramTableName, int idPriceList, int idPITemplate, string xmlRuleSetFilePath)
        {
            //Create rate schedule and add rates
            // Put rates onto a shared pricelist
            var sched = CreateRateSchedule(paramTableName, idPriceList, idPITemplate);
            sched.RuleSet.Read(xmlRuleSetFilePath);
            sched.SaveWithRules();
            return sched;
        }

        public IMTRateSchedule CreateRateSchedule(string paramTableName, int idPriceList, int idPITemplate)
        {
            //Create rate schedule and add rates
            // Put rates onto a shared pricelist
            IMTParamTableDefinition pt = ProductCatalog.GetParamTableDefinitionByName(paramTableName);
            IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, idPITemplate);
            sched.ParameterTableID = pt.ID;
            sched.Description = "Unit Test Rates";
            sched.EffectiveDate.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
            sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
            sched.EffectiveDate.EndDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
            sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
            sched.Save();

            return sched;
        }

        public void Initialize(string name, string uniqueIdentifier)
        {
            baseName = name;
            uniqueInstanceIdentifier = uniqueIdentifier;

            MetraTech.Interop.MTProductCatalog.IMTSessionContext sessionContext = GetSessionContextForCreate();

            ProductCatalog = new MTProductCatalogClass();
            ProductCatalog.SetSessionContext(sessionContext);
        }

        protected virtual IMTProductOffering CreateProductOffering(List<IMTRecurringCharge> charges)
        {
            IMTProductOffering productOffering = ProductCatalog.CreateProductOffering();
            productOffering.Name = string.Format("{0}_PO_{1}", BaseName, UniqueInstanceIdentifier);
            productOffering.DisplayName = productOffering.Name;
            ((MetraTech.Localization.LocalizedEntity)productOffering.DisplayNames).SetMapping("DE", "{DE} " + productOffering.DisplayName);

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

            //productOffering.AddPriceableItem((MTPriceableItem) piTemplate_NRC_ChargeOnSubscribe);

            productOffering.AvailabilityDate.StartDate = DateTime.Parse("1/1/2008");
            productOffering.AvailabilityDate.SetEndDateNull();
            productOffering.SetCurrencyCode("USD");
            productOffering.Save();

            return productOffering;
        }

        protected virtual IMTProductOffering CreateProductOffering(List<IMTPriceableItem> priceableItems)
        {
            IMTProductOffering productOffering = ProductCatalog.CreateProductOffering();
            productOffering.Name = string.Format("{0}_PO_{1}", BaseName, UniqueInstanceIdentifier);
            productOffering.DisplayName = productOffering.Name;
            ((MetraTech.Localization.LocalizedEntity)productOffering.DisplayNames).SetMapping("DE", "{DE} " + productOffering.DisplayName);

            productOffering.Description = productOffering.Name;
            productOffering.SelfSubscribable = true;
            productOffering.SelfUnsubscribable = false;
            productOffering.EffectiveDate.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
            productOffering.EffectiveDate.StartDate = DateTime.Parse("1/1/2008");
            productOffering.EffectiveDate.EndDateType = MTPCDateType.PCDATE_TYPE_NULL;
            productOffering.EffectiveDate.SetEndDateNull();

            foreach (IMTPriceableItem priceableItem in priceableItems)
            {
                productOffering.AddPriceableItem((MTPriceableItem)priceableItem);
            }

            //productOffering.AddPriceableItem((MTPriceableItem) piTemplate_NRC_ChargeOnSubscribe);

            productOffering.AvailabilityDate.StartDate = DateTime.Parse("1/1/2008");
            productOffering.AvailabilityDate.SetEndDateNull();
            productOffering.SetCurrencyCode("USD");
            productOffering.Save();

            return productOffering;
        }

        private List<IMTNonRecurringCharge> AddNonRecurringCharge(string name, MTNonRecurringEventType eventType,
                                                                  Int16 countNRCs)
        {
            IMTPriceableItemType priceableItemTypeNRC =
                ProductCatalog.GetPriceableItemTypeByName("Flat Rate Non Recurring Charge");

            if (priceableItemTypeNRC == null)
            {
                throw new ApplicationException("'Flat Rate Non Recurring Charge' Priceable Item Type not found");
            }

            List<IMTNonRecurringCharge> piTemplate_NRCList = new List<IMTNonRecurringCharge>();
            for (int i = 0; i < countNRCs; i++)
            {
                IMTNonRecurringCharge piTemplate_NRC = (IMTNonRecurringCharge)priceableItemTypeNRC.CreateTemplate(false);
                piTemplate_NRC.Name = string.Format("{0}_{1}_#{2}", name, UniqueInstanceIdentifier, i + 1);
                var dName = string.Format("{0}_{1}", name, i + 1);
                piTemplate_NRC.DisplayName = dName;
                ((MetraTech.Localization.LocalizedEntity)piTemplate_NRC.DisplayNames).SetMapping("DE", "{DE} " + piTemplate_NRC.DisplayName);

                piTemplate_NRC.Description = dName;
                piTemplate_NRC.NonRecurringChargeEvent = MTNonRecurringEventType.NREVENT_TYPE_SUBSCRIBE;

                piTemplate_NRC.Save();
                piTemplate_NRCList.Add(piTemplate_NRC);
            }


            return piTemplate_NRCList;
        }

        public List<IMTRecurringCharge> CreateFlatRateRecurringCharge(short countRCs, IMTPCCycle cycle, RCParameters rcParameters)
        {
            IMTPriceableItemType priceableItemTypeFRRC = ProductCatalog.GetPriceableItemTypeByName("Flat Rate Recurring Charge");

            if (priceableItemTypeFRRC == null)
            {
                throw new ApplicationException("'Flat Rate Recurring Charge' Priceable Item Type not found");
            }

            var recuringChargeList = new List<IMTRecurringCharge>();

            for (var i = 0; i < countRCs; i++)
            {
                var name = rcParameters.ChargePerParticipant ? "FRRC_CPP" : "FRRC_CPS";

                var fullName = string.Format("{0}_{1}_{2}_#{3}", name, ChargeCounter, UniqueInstanceIdentifier, i);

                var piTemplate_FRRC = (IMTRecurringCharge)priceableItemTypeFRRC.CreateTemplate(false);
                piTemplate_FRRC.Name = fullName;
                piTemplate_FRRC.DisplayName = fullName;
                ((Localization.LocalizedEntity)piTemplate_FRRC.DisplayNames).SetMapping("DE", "{DE} " + piTemplate_FRRC.DisplayName);

                piTemplate_FRRC.Description = fullName;
                piTemplate_FRRC.ChargeInAdvance = rcParameters.ChargeInAdvance;
                piTemplate_FRRC.ProrateOnActivation = rcParameters.ProrateOnActivation;
                piTemplate_FRRC.ProrateOnDeactivation = rcParameters.ProrateOnDeactivation;
                piTemplate_FRRC.ProrateOnRateChange = rcParameters.ProrateOnRateChange;
                piTemplate_FRRC.FixedProrationLength = rcParameters.FixedProrationLength;
                piTemplate_FRRC.ChargePerParticipant = rcParameters.ChargePerParticipant;
                IMTPCCycle pcCycle = piTemplate_FRRC.Cycle;

                if (cycle != null && cycle.CycleTypeID > 0)
                {
                    pcCycle.CycleTypeID = cycle.CycleTypeID;
                    pcCycle.EndDayOfMonth = cycle.EndDayOfMonth;
                    pcCycle.EndDayOfMonth2 = cycle.EndDayOfMonth2;
                    pcCycle.EndDayOfWeek = cycle.EndDayOfWeek;
                    pcCycle.Mode = cycle.Mode;
                    pcCycle.StartDay = cycle.StartDay;
                    pcCycle.StartMonth = cycle.StartMonth;
                    pcCycle.StartYear = cycle.StartYear;
                }
                else
                {
                    pcCycle.CycleTypeID = (int)CycleType.Monthly;
                    pcCycle.EndDayOfMonth = 31;
                }

                piTemplate_FRRC.Save();

                recuringChargeList.Add(piTemplate_FRRC);
            }

            return recuringChargeList;
        }

        private List<IMTRecurringCharge> CreateUDRC(short countUDRCs, IMTPCCycle cycle, RCParameters rcParameters)
        {
            IMTPriceableItemType priceableItemTypeUDRC =
                ProductCatalog.GetPriceableItemTypeByName("Unit Dependent Recurring Charge");

            if (priceableItemTypeUDRC == null)
            {
                throw new ApplicationException("'Unit Dependent Recurring Charge' Priceable Item Type not found");
            }

            var udrList = new List<IMTRecurringCharge>();

            for (short i = 0; i < countUDRCs; i++)
            {
                var name = rcParameters.ChargePerParticipant
                  ? string.Format("UDRC_CPP_{0}_{1}_{2}", ChargeCounter, UniqueInstanceIdentifier, i)
                  : string.Format("UDRC_CPS_{0}_{1}_{2}", ChargeCounter, UniqueInstanceIdentifier, i);

                var piTemplateUdrc = (IMTRecurringCharge)priceableItemTypeUDRC.CreateTemplate(false);
                piTemplateUdrc.Name = name;
                piTemplateUdrc.DisplayName = name;
                ((Localization.LocalizedEntity)piTemplateUdrc.DisplayNames).SetMapping("DE", "{DE} " + piTemplateUdrc.DisplayName);
                piTemplateUdrc.Description = name;
                piTemplateUdrc.ChargeInAdvance = rcParameters.ChargeInAdvance;
                piTemplateUdrc.ProrateOnActivation = rcParameters.ProrateOnActivation;
                piTemplateUdrc.ProrateOnDeactivation = rcParameters.ProrateOnDeactivation;
                piTemplateUdrc.ProrateOnRateChange = rcParameters.ProrateOnRateChange;
                piTemplateUdrc.FixedProrationLength = rcParameters.FixedProrationLength;
                piTemplateUdrc.ChargePerParticipant = rcParameters.ChargePerParticipant;
                piTemplateUdrc.UnitName = string.Format("UNIT_{0}_{1}", ChargeCounter, UniqueInstanceIdentifier);
                piTemplateUdrc.RatingType = MTUDRCRatingType.UDRCRATING_TYPE_TAPERED;
                piTemplateUdrc.IntegerUnitValue = true;
                piTemplateUdrc.MinUnitValue = 10;
                piTemplateUdrc.MaxUnitValue = 1000;
                IMTPCCycle pcCycle = piTemplateUdrc.Cycle;

                if (cycle != null && cycle.CycleTypeID > 0)
                {
                    pcCycle.CycleTypeID = cycle.CycleTypeID;
                    pcCycle.EndDayOfMonth = cycle.EndDayOfMonth;
                    pcCycle.EndDayOfMonth2 = cycle.EndDayOfMonth2;
                    pcCycle.EndDayOfWeek = cycle.EndDayOfWeek;
                    pcCycle.Mode = cycle.Mode;
                    pcCycle.StartDay = cycle.StartDay;
                    pcCycle.StartMonth = cycle.StartMonth;
                    pcCycle.StartYear = cycle.StartYear;
                }
                else
                {
                    pcCycle.CycleTypeID = (int)CycleType.Monthly;
                    pcCycle.EndDayOfMonth = 31;
                }

                piTemplateUdrc.Save();

                udrList.Add(piTemplateUdrc);
            }

            return udrList;
        }


    }

    #endregion

    #region Account Related Classes

    public class BaseAccountFactory : DomainModel.BaseTypes.Account
    {
      protected int ancestorID = 1;
      public int AncestorID
      {
        get { return ancestorID; }
        set { ancestorID = value; }
      }
      
      protected int? payerID = null;
      public new int? PayerID
      {
        get { return payerID; }
        set { payerID = value; }
      }

      protected string baseName = "";
      protected virtual string BaseName
      {
        get { return baseName; }
      }

      protected string uniqueInstanceIdentifier = "";
      protected virtual string UniqueInstanceIdentifier
      {
        get { return uniqueInstanceIdentifier; }
      }

      protected InternalView internalView;
      protected UsageCycleType usageCycleType = UsageCycleType.Monthly;
      public UsageCycleType CycleType
      {
        get { return usageCycleType; }
        set { usageCycleType = value; }
      }
      protected ContactView billToContactView;
      protected ContactView shipToContactView;

      protected DomainModel.BaseTypes.Account CreateBaseAccount(string typeName, ref string userName, ref string nameSpace)
      {
        var account = CreateAccount(typeName);
        userName = string.Format("{0}_{1}_{2}", userName, BaseName, UniqueInstanceIdentifier);

        if (userName.Length > 255)
        {
          throw new Exception(string.Format("Username '{0}' is too long. It is {1} and should be 255 or less.", userName, userName.Length));
        }

        if (String.IsNullOrEmpty(nameSpace))
        {
          nameSpace = "mt";
        }

        account.PayerID = PayerID;
        account.UserName = userName;
        account.Password_ = "123";
        account.Name_Space = nameSpace;
        account.AccountStatus = DomainModel.Enums.Account.Metratech_com_accountcreation.AccountStatus.Active;

        account.AncestorAccountID = AncestorID;
        account.AccountStartDate = MetraTime.Now;

        //var dateTime = DateTime.Today;
        //var y2k = new DateTime(2000, 1, 1);
        //TimeSpan tsDiffBnNowAndY2K = dateTime.Subtract(y2k);
        //int diffDaysBnNowAndY2K = Math.Abs(tsDiffBnNowAndY2K.Days);
        //if (account.StartDay >= 14)
        //{
        //  account.StartDay = (diffDaysBnNowAndY2K + 1) % 14;
        //}
        account.StartDay = 1; //DateTime.Now.Day;
        account.StartMonth = MonthOfTheYear.January; //DateTime.Now.Year;
        account.StartYear = 2000; //(MonthOfTheYear)(DateTime.Now.Month - 1);

        account.DayOfMonth = 1;
        account.DayOfWeek = DayOfTheWeek.Sunday;

        account.FirstDayOfMonth = 1;
        account.SecondDayOfMonth = 15;
        
        return account;
      }
    }

    public class CorporateAccountFactory : BaseAccountFactory
    {
        protected CorporateAccount mCorporateAccount;
        public CorporateAccount Item
        {
            get { return mCorporateAccount; }
        }
      
        AccountCreation_AddAccount_Client webServiceClient;

        public virtual MetraTech.Interop.MTAuth.IMTSessionContext GetSessionContextForCreate()
        {
            return SharedTestCode.LoginAsSU();
        }

        public virtual AccountCreation_AddAccount_Client WebServiceClient
        {
            get
            {
                if (webServiceClient == null)
                {
                    webServiceClient = new AccountCreation_AddAccount_Client();
                    webServiceClient.UserName = "su";
                    webServiceClient.Password = "su123";
                }

                return webServiceClient;
            }
        }

        private CorporateAccountFactory() { }
        public CorporateAccountFactory(string name, string uniqueIdentifier)
        {
            baseName = name;
            uniqueInstanceIdentifier = uniqueIdentifier;
        }

        public static CorporateAccount Create(string name, string uniqueIdentifier)
        {
            CorporateAccountFactory accountHolder = new CorporateAccountFactory(name, uniqueIdentifier);
            accountHolder.Instantiate();

            return accountHolder.Item;
        }
      
        public virtual void Instantiate()
        {
            // Create the internal view
            internalView = (InternalView)View.CreateView(@"metratech.com/internal");
            internalView.UsageCycleType = CycleType;
            internalView.Billable = true;
            internalView.SecurityQuestion = SecurityQuestion.MothersMaidenName;
            internalView.Language = LanguageCode.US;
            internalView.Currency = SystemCurrencies.USD.ToString();
            internalView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

            // Create the billToContactView
            billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            billToContactView.ContactType = ContactType.Bill_To;
            billToContactView.FirstName = "Rudi";
            billToContactView.LastName = "Perkins";
            billToContactView.Address1 = "c/o Test " + baseName + " " + uniqueInstanceIdentifier;
            billToContactView.Address2 = "528 Wellman Ave.";
            billToContactView.City = "North Chelmsford";
            billToContactView.Country = CountryName.USA;
            billToContactView.Company = string.Format("{0}, Inc.", baseName);
            billToContactView.Email = "rperkins@amit.com";
            billToContactView.PhoneNumber = "617-555-1212";
            billToContactView.Zip = "01863";

            // Create the shipToContactView
            shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            shipToContactView.ContactType = ContactType.Ship_To;
            shipToContactView.FirstName = string.Format("Ship_to_{0}", baseName);
            shipToContactView.LastName = string.Format("Ship_to_{0}", uniqueInstanceIdentifier);
            shipToContactView.Country = CountryName.India;
            shipToContactView.City = string.Format("City for ship to {0}", baseName);
            shipToContactView.Company = string.Format("Company for ship to {0}", baseName);
            shipToContactView.Email = string.Format("Email for ship to {0}", baseName);
            shipToContactView.PhoneNumber = string.Format("Phone number for ship to {0}", baseName);
            shipToContactView.Address1 = string.Format("Address for ship to {0}", baseName);
            shipToContactView.Zip = string.Format("ZIP code for ship to {0}", baseName);

            mCorporateAccount = CreateCorporateAccount();

            //Add role for login to MetraView
            if (mCorporateAccount._AccountID != null)
            {
                var ctx = SharedTestCode.LoginAsSU();
                IMTSecurity sec = new MTSecurityClass();

                IMTYAAC cap1 = sec.GetAccountByID((MTSessionContext)ctx, (int)mCorporateAccount._AccountID, MetraTime.Now);

                MTRole specifiedRole = sec.GetRoleByName((MTSessionContext)ctx, "Subscriber (MetraView)");

                cap1.GetActivePolicy((MTSessionContext)ctx).AddRole(specifiedRole);
                cap1.GetActivePolicy((MTSessionContext)ctx).Save();
            }
        }
      
        protected virtual CorporateAccount CreateCorporateAccount()
        {
            string username = "Corp";
            string nameSpace = String.Empty;
            var account = (CorporateAccount)CreateBaseAccount("CorporateAccount", ref username, ref nameSpace);
            
            // Set the internal view
            account.Internal = internalView;

            // Add the contact views
            account.LDAP.Add(shipToContactView);
            account.LDAP.Add(billToContactView);
            
            // Create the account
            WebServiceClient.InOut_Account = account;
            WebServiceClient.Invoke();
            return (CorporateAccount)WebServiceClient.InOut_Account;
        }
      
        public CoreSubscriber AddCoreSubscriber(string name)
        {
            string username = name;
            string nameSpace = String.Empty;

            CoreSubscriber account = (CoreSubscriber)CreateBaseAccount("CoreSubscriber", ref username, ref nameSpace);
            account.AncestorAccountID = mCorporateAccount._AccountID;
            account.AccountStartDate = MetraTime.Now;

            account.Internal = internalView;

            // Add the contact views
            //account.LDAP.Add(shipToContactView);
            //account.LDAP.Add(billToContactView);

            // Create the billToContactView
            ContactView billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            billToContactView.ContactType = ContactType.Bill_To;
            billToContactView.FirstName = username;
            billToContactView.LastName = "Perkins";

            // Create the shipToContactView
            ContactView shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            shipToContactView.ContactType = ContactType.Ship_To;
            shipToContactView.FirstName = username;
            shipToContactView.LastName = "Perkins";

            // Create the account
            WebServiceClient.InOut_Account = account;
            WebServiceClient.Invoke();

            return (CoreSubscriber)WebServiceClient.InOut_Account;
        }
    }

    public class DepartmentAccountFactory : BaseAccountFactory
    {
        protected DepartmentAccount mDepartmentAccount;
        public DepartmentAccount Item
        {
            get { return mDepartmentAccount; }
        }

        AccountCreation_AddAccount_Client webServiceClient;

        public virtual MetraTech.Interop.MTAuth.IMTSessionContext GetSessionContextForCreate()
        {
            return SharedTestCode.LoginAsSU();
        }

        public virtual AccountCreation_AddAccount_Client WebServiceClient
        {
            get
            {
                if (webServiceClient == null)
                {
                    webServiceClient = new AccountCreation_AddAccount_Client();
                    webServiceClient.UserName = "su";
                    webServiceClient.Password = "su123";
                }

                return webServiceClient;
            }
        }

        private DepartmentAccountFactory() { }
        public DepartmentAccountFactory(string name, string uniqueIdentifier)
        {
            baseName = name;
            uniqueInstanceIdentifier = uniqueIdentifier;
        }

        public static DepartmentAccount Create(string name, string uniqueIdentifier)
        {
            var accountHolder = new DepartmentAccountFactory(name, uniqueIdentifier);
            accountHolder.Instantiate();

            return accountHolder.Item;
        }

        public virtual void Instantiate()
        {

            // Create the internal view
            internalView = (InternalView)View.CreateView(@"metratech.com/internal");
            internalView.UsageCycleType = CycleType;
            internalView.Billable = true;
            internalView.SecurityQuestion = SecurityQuestion.MothersMaidenName;
            internalView.Language = LanguageCode.US;
            internalView.Currency = SystemCurrencies.USD.ToString();
            internalView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

            // Create the billToContactView
            billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            billToContactView.ContactType = ContactType.Bill_To;
            billToContactView.FirstName = "Rudi";
            billToContactView.LastName = "Perkins";
            billToContactView.Address1 = "c/o Test " + baseName + " " + uniqueInstanceIdentifier;
            billToContactView.Address2 = "528 Wellman Ave.";
            billToContactView.City = "North Chelmsford";
            billToContactView.Country = CountryName.USA;
            billToContactView.Company = string.Format("{0}, Inc.", baseName);
            billToContactView.Email = "rperkins@amit.com";
            billToContactView.PhoneNumber = "617-555-1212";
            billToContactView.Zip = "01863";

            // Create the shipToContactView
            shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            shipToContactView.ContactType = ContactType.Ship_To;
            shipToContactView.FirstName = string.Format("Ship_to_{0}", baseName);
            shipToContactView.LastName = string.Format("Ship_to_{0}", uniqueInstanceIdentifier);
            shipToContactView.Country = CountryName.India;
            shipToContactView.City = string.Format("City for ship to {0}", baseName);
            shipToContactView.Company = string.Format("Company for ship to {0}", baseName);
            shipToContactView.Email = string.Format("Email for ship to {0}", baseName);
            shipToContactView.PhoneNumber = string.Format("Phone number for ship to {0}", baseName);
            shipToContactView.Address1 = string.Format("Address for ship to {0}", baseName);
            shipToContactView.Zip = string.Format("ZIP code for ship to {0}", baseName);

            mDepartmentAccount = CreateDepartmentAccount();

            //Add role for login to MetraView
            if (mDepartmentAccount._AccountID != null)
            {
                var ctx = SharedTestCode.LoginAsSU();
                IMTSecurity sec = new MTSecurityClass();

                IMTYAAC cap1 = sec.GetAccountByID((MTSessionContext)ctx, (int)mDepartmentAccount._AccountID, MetraTime.Now);

                MTRole specifiedRole = sec.GetRoleByName((MTSessionContext)ctx, "Subscriber (MetraView)");

                cap1.GetActivePolicy((MTSessionContext)ctx).AddRole(specifiedRole);
                cap1.GetActivePolicy((MTSessionContext)ctx).Save();
            }
        }

        protected virtual DepartmentAccount CreateDepartmentAccount()
        {
            var username = "Dep";
            var nameSpace = String.Empty;
            var account = (DepartmentAccount)CreateBaseAccount("DepartmentAccount", ref username, ref nameSpace);

            // Set the internal view
            account.Internal = internalView;

            // Add the contact views
            account.LDAP.Add(shipToContactView);
            account.LDAP.Add(billToContactView);

            // Create the account
            WebServiceClient.InOut_Account = account;
            WebServiceClient.Invoke();

            return (DepartmentAccount)WebServiceClient.InOut_Account;
        }

        public CoreSubscriber AddCoreSubscriber(string name)
        {
            string username = name;
            string nameSpace = String.Empty;

            var account = (CoreSubscriber)CreateBaseAccount("CoreSubscriber", ref username, ref nameSpace);
            account.AncestorAccountID = mDepartmentAccount._AccountID;
            account.Internal = internalView;
          
            // Add the contact views
            //account.LDAP.Add(shipToContactView);
            //account.LDAP.Add(billToContactView);

            // Create the billToContactView
            ContactView billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            billToContactView.ContactType = ContactType.Bill_To;
            billToContactView.FirstName = username;
            billToContactView.LastName = "Perkins";

            // Create the shipToContactView
            ContactView shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            shipToContactView.ContactType = ContactType.Ship_To;
            shipToContactView.FirstName = username;
            shipToContactView.LastName = "Perkins";

            // Create the account
            WebServiceClient.InOut_Account = account;
            WebServiceClient.Invoke();

            return (CoreSubscriber)WebServiceClient.InOut_Account;
        }
    }

    public class CoreSubscriberAccountFactory : BaseAccountFactory
    {
        protected CoreSubscriber mCoreSubscriberAccount;
        public CoreSubscriber Item
        {
            get { return mCoreSubscriberAccount; }
        }

        AccountCreation_AddAccount_Client webServiceClient;

        public virtual Interop.MTAuth.IMTSessionContext GetSessionContextForCreate()
        {
            return SharedTestCode.LoginAsSU();
        }

        public virtual AccountCreation_AddAccount_Client WebServiceClient
        {
            get
            {
                if (webServiceClient == null)
                {
                    webServiceClient = new AccountCreation_AddAccount_Client();
                    webServiceClient.UserName = "su";
                    webServiceClient.Password = "su123";
                }

                return webServiceClient;
            }
        }

        private CoreSubscriberAccountFactory() { }
        public CoreSubscriberAccountFactory(string name, string uniqueIdentifier)
        {
            baseName = name;
            uniqueInstanceIdentifier = uniqueIdentifier;
        }

        public static CoreSubscriber Create(string name, string uniqueIdentifier)
        {
            CoreSubscriberAccountFactory accountHolder = new CoreSubscriberAccountFactory(name, uniqueIdentifier);
            accountHolder.Instantiate();

            return accountHolder.Item;
        }

        public virtual void Instantiate()
        {
            // Create the internal view
            internalView = (InternalView)View.CreateView(@"metratech.com/internal");
            internalView.UsageCycleType = CycleType;
            internalView.Billable = true;
            internalView.SecurityQuestion = SecurityQuestion.MothersMaidenName;
            internalView.Language = LanguageCode.US;
            internalView.Currency = SystemCurrencies.USD.ToString();
            internalView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

            // Create the billToContactView
            billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            billToContactView.ContactType = ContactType.Bill_To;
            billToContactView.FirstName = "Rudi";
            billToContactView.LastName = "Perkins";
            billToContactView.Address1 = "c/o Test " + baseName + " " + uniqueInstanceIdentifier;
            billToContactView.Address2 = "528 Wellman Ave.";
            billToContactView.City = "North Chelmsford";
            billToContactView.Country = CountryName.USA;
            billToContactView.Company = string.Format("{0}, Inc.", baseName);
            billToContactView.Email = "rperkins@amit.com";
            billToContactView.PhoneNumber = "617-555-1212";
            billToContactView.Zip = "01863";

            // Create the shipToContactView
            shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            shipToContactView.ContactType = ContactType.Ship_To;
            shipToContactView.FirstName = string.Format("Ship_to_{0}", baseName);
            shipToContactView.LastName = string.Format("Ship_to_{0}", uniqueInstanceIdentifier);
            shipToContactView.Country = CountryName.India;
            shipToContactView.City = string.Format("City for ship to {0}", baseName);
            shipToContactView.Company = string.Format("Company for ship to {0}", baseName);
            shipToContactView.Email = string.Format("Email for ship to {0}", baseName);
            shipToContactView.PhoneNumber = string.Format("Phone number for ship to {0}", baseName);
            shipToContactView.Address1 = string.Format("Address for ship to {0}", baseName);
            shipToContactView.Zip = string.Format("ZIP code for ship to {0}", baseName);

            mCoreSubscriberAccount = CreateCoreSubscriberAccount();

            //Add role for login to MetraView
            if (mCoreSubscriberAccount._AccountID != null)
            {
                var ctx = SharedTestCode.LoginAsSU();
                IMTSecurity sec = new MTSecurityClass();

                IMTYAAC cap1 = sec.GetAccountByID((MTSessionContext)ctx, (int)mCoreSubscriberAccount._AccountID, MetraTime.Now);

                MTRole specifiedRole = sec.GetRoleByName((MTSessionContext)ctx, "Subscriber (MetraView)");

                cap1.GetActivePolicy((MTSessionContext)ctx).AddRole(specifiedRole);
                cap1.GetActivePolicy((MTSessionContext)ctx).Save();
            }
        }

        protected virtual CoreSubscriber CreateCoreSubscriberAccount()
        {
            var username = "CoreSub";
            var nameSpace = String.Empty;
            var account = (CoreSubscriber)CreateBaseAccount("CoreSubscriber", ref username, ref nameSpace);

            // Set the internal view
            account.Internal = internalView;

            // Add the contact views
            account.LDAP.Add(shipToContactView);
            account.LDAP.Add(billToContactView);

            // Create the account
            WebServiceClient.InOut_Account = account;
            WebServiceClient.Invoke();

            return (CoreSubscriber)WebServiceClient.InOut_Account;
        }
    }

    public class IndependentAccountFactory
    {
        protected IndependentAccount mIndependentAccount;
        public IndependentAccount Item
        {
            get { return mIndependentAccount; }
        }

        protected string baseName = "";
        protected virtual string BaseName
        {
            get { return baseName; }
        }

        protected string uniqueInstanceIdentifier = "";
        protected virtual string UniqueInstanceIdentifier
        {
            get { return uniqueInstanceIdentifier; }
        }

        protected UsageCycleType usageCycleType = UsageCycleType.Monthly;
        public UsageCycleType CycleType
        {
            get { return usageCycleType; }
            set { usageCycleType = value; }
        }

        protected int? payerID = null;
        public int? PayerID
        {
            get { return payerID; }
            set { payerID = value; }
        }

        protected int ancestorID = 1;
        public int AncestorID
        {
            get { return ancestorID; }
            set { ancestorID = value; }
        }

        protected InternalView internalView;
        protected ContactView billToContactView;
        protected ContactView shipToContactView;

        AccountCreation_AddAccount_Client webServiceClient;

        public virtual MetraTech.Interop.MTAuth.IMTSessionContext GetSessionContextForCreate()
        {
            return SharedTestCode.LoginAsSU();
        }

        public virtual AccountCreation_AddAccount_Client WebServiceClient
        {
            get
            {
                if (webServiceClient == null)
                {
                    webServiceClient = new AccountCreation_AddAccount_Client();
                    webServiceClient.UserName = "su";
                    webServiceClient.Password = "su123";
                }

                return webServiceClient;
            }
        }

        private IndependentAccountFactory() { }
        public IndependentAccountFactory(string name, string uniqueIdentifier)
        {
            baseName = name;
            uniqueInstanceIdentifier = uniqueIdentifier;
        }

        public static IndependentAccount Create(string name, string uniqueIdentifier)
        {
            IndependentAccountFactory accountHolder = new IndependentAccountFactory(name, uniqueIdentifier);
            accountHolder.Instantiate();

            return accountHolder.Item;
        }

        public virtual void Instantiate()
        {
            // Create the internal view
            internalView = (InternalView)View.CreateView(@"metratech.com/internal");
            internalView.UsageCycleType = CycleType;
            internalView.Billable = true;
            internalView.SecurityQuestion = SecurityQuestion.MothersMaidenName;
            internalView.Language = LanguageCode.US;
            internalView.Currency = SystemCurrencies.USD.ToString();
            internalView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

            // Create the billToContactView
            billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            billToContactView.ContactType = ContactType.Bill_To;
            billToContactView.FirstName = "Rudi";
            billToContactView.LastName = "Perkins";
            billToContactView.Address1 = "c/o Test " + baseName + " " + uniqueInstanceIdentifier;
            billToContactView.Address2 = "528 Wellman Ave.";
            billToContactView.City = "North Chelmsford";
            billToContactView.Country = CountryName.USA;
            billToContactView.Company = string.Format("{0}, Inc.", baseName);
            billToContactView.Email = "rperkins@amit.com";
            billToContactView.PhoneNumber = "617-555-1212";
            billToContactView.Zip = "01863";

            // Create the shipToContactView
            shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
            shipToContactView.ContactType = ContactType.Ship_To;
            shipToContactView.FirstName = string.Format("Ship_to_{0}", baseName);
            shipToContactView.LastName = string.Format("Ship_to_{0}", uniqueInstanceIdentifier);
            shipToContactView.Country = CountryName.India;
            shipToContactView.City = string.Format("City for ship to {0}", baseName);
            shipToContactView.Company = string.Format("Company for ship to {0}", baseName);
            shipToContactView.Email = string.Format("Email for ship to {0}", baseName);
            shipToContactView.PhoneNumber = string.Format("Phone number for ship to {0}", baseName);
            shipToContactView.Address1 = string.Format("Address for ship to {0}", baseName);
            shipToContactView.Zip = string.Format("ZIP code for ship to {0}", baseName);

            mIndependentAccount = CreateIndependentAccount();

            //Add role for login to MetraView
            if (mIndependentAccount._AccountID != null)
            {
                var ctx = SharedTestCode.LoginAsSU();
                IMTSecurity sec = new MTSecurityClass();

                IMTYAAC cap1 = sec.GetAccountByID((MTSessionContext)ctx, (int)mIndependentAccount._AccountID, MetraTime.Now);

                MTRole specifiedRole = sec.GetRoleByName((MTSessionContext)ctx, "Subscriber (MetraView)");

                cap1.GetActivePolicy((MTSessionContext)ctx).AddRole(specifiedRole);
                cap1.GetActivePolicy((MTSessionContext)ctx).Save();
            }
        }

        protected virtual IndependentAccount CreateIndependentAccount()
        {
            string username = "Indp";
            string nameSpace = String.Empty;
            IndependentAccount account = (IndependentAccount)CreateBaseAccount("IndependentAccount", ref username, ref nameSpace);
            account.AccountStartDate = MetraTime.Now;

            // Set the internal view
            account.Internal = internalView;

            // Add the contact views
            account.LDAP.Add(shipToContactView);
            account.LDAP.Add(billToContactView);

            account.StartYear = DateTime.Now.Year;
            account.StartMonth = (MonthOfTheYear)(DateTime.Now.Month - 1);
            account.StartDay = DateTime.Now.Day; 
            
            account.FirstDayOfMonth = 1;
            account.DayOfMonth = 1;
            account.DayOfWeek = DayOfTheWeek.Sunday;
            account.SecondDayOfMonth = 15;

            account.PayerID = PayerID;

            // Create the account
            WebServiceClient.InOut_Account = account;
            WebServiceClient.Invoke();

            return (IndependentAccount)WebServiceClient.InOut_Account;
        }

        private DomainModel.BaseTypes.Account CreateBaseAccount(string typeName, ref string userName, ref string nameSpace)
        {
            MetraTech.DomainModel.BaseTypes.Account account =
              MetraTech.DomainModel.BaseTypes.Account.CreateAccount(typeName);

            //userName = typeName + "_" + DateTime.Now.ToString("MM/dd HH:mm:ss.") + DateTime.Now.Millisecond.ToString();

            userName = string.Format("{0}_{1}_{2}", userName, BaseName, UniqueInstanceIdentifier);

            if (userName.Length > 40)
            {
                throw new Exception(string.Format("Username '{0}' is too long. It is {1} and should be 40 or less.", userName, userName.Length));
            }

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
    }

    public class GroupSubscriptionFactory
    {
        protected GroupSubscription mGroupSubscription;
        public GroupSubscription Item
        {
            get { return mGroupSubscription; }
        }

        protected string mUserName = "";
        protected string mPassword = "";

        protected string baseName = "";
        protected virtual string BaseName
        {
            get { return baseName; }
        }

        protected string uniqueInstanceIdentifier = "";
        protected virtual string UniqueInstanceIdentifier
        {
            get { return uniqueInstanceIdentifier; }
        }

        public static GroupSubscription Create(string name, string uniqueIdentifier, int productOfferingId,
                                                          int corporateAccountId,
                                                          List<int> memberAccountIds, string userName, string password)
        {
            GroupSubscriptionFactory groupSubscriptionHolder = new GroupSubscriptionFactory();
            groupSubscriptionHolder.baseName = name;
            groupSubscriptionHolder.uniqueInstanceIdentifier = uniqueIdentifier;
            groupSubscriptionHolder.mUserName = userName;
            groupSubscriptionHolder.mPassword = password;

            groupSubscriptionHolder.CreateGroupSubscription(productOfferingId, corporateAccountId, memberAccountIds);

            return groupSubscriptionHolder.Item;
        }

        public GroupSubscription CreateGroupSubscription(int productOfferingId,
                                                          int corporateAccountId,
                                                          List<int> memberAccountIds)
        {
            GroupSubscription groupSubscription = new GroupSubscription();

            #region Initialize

            groupSubscription.SubscriptionSpan = new ProdCatTimeSpan();

            DateTime start = MetraTime.Now.AddDays(1);
            //Round to nearest second for easier comparison with database timestamp later
            groupSubscription.SubscriptionSpan.StartDate = start.RoundToSecond();

            groupSubscription.ProductOfferingId = productOfferingId;
            groupSubscription.ProportionalDistribution = false;
            groupSubscription.DiscountAccountId = memberAccountIds[0];

            groupSubscription.Name = string.Format("{0}_GS_{1}", BaseName, UniqueInstanceIdentifier);
            groupSubscription.Description = "Unit Test";
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
            udrcClient.UserName = mUserName;
            udrcClient.Password = mPassword;
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
            flatRateClient.UserName = mUserName;
            flatRateClient.Password = mPassword;
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
            addClient.UserName = mUserName;
            addClient.Password = mPassword;
            addClient.InOut_groupSubscription = groupSubscription;
            addClient.Invoke();

            groupSubscription.GroupId = addClient.InOut_groupSubscription.GroupId.Value;
            #endregion

            mGroupSubscription = groupSubscription;

            return mGroupSubscription;
        }
    }

    #endregion

    #region DateTime Related Extension Methods
    public static class DateTimeExtensionMethods
    {
        public static DateTime? TruncatedToSecond(this DateTime? dateTime)
        {
            if (dateTime != null)
                return new DateTime(dateTime.Value.Ticks - (dateTime.Value.Ticks % TimeSpan.TicksPerSecond), dateTime.Value.Kind);
            else
                return null;
        }

        public static DateTime? RoundToSecond(this DateTime? dateTime)
        {
            if (dateTime != null)
            {
                DateTime result = new DateTime(dateTime.Value.Year, dateTime.Value.Month, dateTime.Value.Day, dateTime.Value.Hour, dateTime.Value.Minute, dateTime.Value.Second, dateTime.Value.Kind);
                if (dateTime.Value.Millisecond >= 500)
                {
                    result.AddSeconds(1);
                }

                return result;
            }
            else
            {
                return null;
            }
        }

        public static DateTime RoundToSecond(this DateTime dateTime)
        {
            DateTime result = new DateTime(dateTime.Year, dateTime.Month, dateTime.Day, dateTime.Hour, dateTime.Minute, dateTime.Second, dateTime.Kind);
            if (dateTime.Millisecond >= 500)
            {
                result.AddSeconds(1);
            }

            return result;
        }

        //  milliseconds modulo 10:    0    1    2    3    4    5    6    7    8    9
        private static readonly int[] OFFSET = { 0, -1, +1, 0, -1, +2, +1, 0, -1, +1 };
        private static readonly DateTime SQL_SERVER_DATETIME_MIN = new DateTime(1753, 01, 01, 00, 00, 00, 000);
        private static readonly DateTime SQL_SERVER_DATETIME_MAX = new DateTime(9999, 12, 31, 23, 59, 59, 997);

        public static DateTime? RoundToSqlServerDateTime(this DateTime? dateTime)
        {
            DateTime dt = new DateTime(dateTime.Value.Year, dateTime.Value.Month, dateTime.Value.Day, dateTime.Value.Hour, dateTime.Value.Minute, dateTime.Value.Second, dateTime.Value.Millisecond);
            int milliseconds = dateTime.Value.Millisecond;
            int t = milliseconds % 10;
            int offset = OFFSET[t];
            DateTime rounded = dt.AddMilliseconds(offset);

            if (rounded < SQL_SERVER_DATETIME_MIN) throw new ArgumentOutOfRangeException("value");
            if (rounded > SQL_SERVER_DATETIME_MAX) throw new ArgumentOutOfRangeException("value");

            return rounded;
        }
    }
    #endregion

    #region Usage Related
    public class UsageAndFailedTransactionCount
    {
        public int InitialUsageCount { get; set; }
        public int InitialFailedTransactionCount { get; set; }
        protected UsageAndFailedTransactionCount()
        { }

        public static UsageAndFailedTransactionCount CreateSnapshot()
        {
            UsageAndFailedTransactionCount result = new UsageAndFailedTransactionCount();
            result.InitialUsageCount = GetUsageCount();
            result.InitialFailedTransactionCount = GetFailedTransactionCount();

            return result;
        }

        public void VerifyCountChanged(int deltaUsage, int deltaFailedTransactions)
        {
            int CurrentUsageCount = GetUsageCount();
            int CurrentFailedTransactionCount = GetFailedTransactionCount();

            string message = "";
            bool matched = true;
            if (InitialUsageCount + deltaUsage != CurrentUsageCount)
            {
                matched = false;
                message += string.Format("Expected usage count in system to change by {0} but the change was {1}", deltaUsage, CurrentUsageCount - InitialUsageCount);
            }
            if (InitialFailedTransactionCount + deltaFailedTransactions != CurrentFailedTransactionCount)
            {
                matched = false;
                message += string.Format("Expected failed transaction count in system to change by {0} records but the change was {1}", deltaFailedTransactions, CurrentFailedTransactionCount - InitialFailedTransactionCount);
            }

            if (!matched)
            {
                Assert.Fail(message);
            }
        }

        public void VerifyNoChange()
        {
            VerifyCountChanged(0, 0);
        }

        public static int GetUsageCount()
        {
            const string queryCheckIfAccountUsageCleanedUp =
            @"select * from t_acc_usage au inner join t_batch b on au.tx_batch=b.tx_batch";

            using (var conn = MetraTech.DataAccess.ConnectionManager.CreateConnection())
            {
                using (var stmt = conn.CreateStatement(queryCheckIfAccountUsageCleanedUp))
                {
                    IMTDataReader reader = stmt.ExecuteReader();
                    return reader.FieldCount;
                }
            }
        }


        public static int GetFailedTransactionCount()
        {
            const string queryCheckIfFailedTransactionsCleanedUp =
            @"select * from t_failed_transaction ft inner join t_batch b on ft.tx_batch=b.tx_batch";

            using (var conn = MetraTech.DataAccess.ConnectionManager.CreateConnection())
            {
                using (var stmt = conn.CreateStatement(queryCheckIfFailedTransactionsCleanedUp))
                {
                    IMTDataReader reader = stmt.ExecuteReader();
                    return reader.FieldCount;
                }
            }
        }





    }
    #endregion
}
    #endregion