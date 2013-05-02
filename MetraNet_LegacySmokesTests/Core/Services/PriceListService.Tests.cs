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
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfconnection;

using MetraTech.Core.Services;
using System.ServiceModel;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.MetraPay;
using System.Collections;
using System.Linq;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.PriceListServiceTests /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
    public class PriceListServiceTests : ServiceTestsBase
    {
        #region Instance variables.
        string m_PriceListName = string.Empty;
        int? m_PriceListID;
        PriceList m_PriceList;
        #endregion
        #region Test init and cleanup
        [TestFixtureSetUp]
        public void InitTests()
        {
            m_Logger = new Logger("[PriceListTestLogger]");
        }

        [TestFixtureTearDown]
        public void UninitTests()
        {
        }
        #endregion

        #region Test Methods

        [Test]
        [Category("SaveRateScheduleForPriceList")]
        public void SaveRateScheduleForPriceList()
        {
            PriceListServiceClient client = new PriceListServiceClient("WSHttpBinding_IPriceListService");
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            SaveSharedPriceList();


            client.Open();

            ProductCatalogServiceClient pcClient = new ProductCatalogServiceClient();
            pcClient.ClientCredentials.UserName.UserName = "su";
            pcClient.ClientCredentials.UserName.Password = "su123";

            MTList<BasePriceableItemTemplate> mtlist = new MTList<BasePriceableItemTemplate>();
            mtlist.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "AudioConfCall"));
            mtlist.PageSize = 10;
            mtlist.CurrentPage = 1;

            pcClient.GetPriceableItemTemplates(ref mtlist);

            pcClient.Close();

            RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry> ratesched = new RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry>();
            Metratech_com_cancelrateRateEntry cre = new Metratech_com_cancelrateRateEntry();

            cre.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            cre.CancelMaxCharge = 10.00M;
            cre.CancelRate = 14.00M;
            cre.ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Executive;
            cre.Index = 1;

            Metratech_com_cancelrateRateEntry cre1 = new Metratech_com_cancelrateRateEntry();
            cre1.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            cre1.CancelMaxCharge = 8.00M;
            cre1.CancelRate = 13.00M;
            cre1.ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Basic;
            cre1.Index = 2;

            ratesched.Description = "my sample rate schedule description";

            ProdCatTimeSpan effectiveDate = new ProdCatTimeSpan();
            effectiveDate.StartDate = System.DateTime.Now.AddDays(-1);
            effectiveDate.StartDateOffset = 0;
            effectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            effectiveDate.EndDate = System.DateTime.Now.AddYears(5);
            effectiveDate.EndDateOffset = 0;
            effectiveDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;

            ratesched.EffectiveDate = effectiveDate;
            ratesched.RateEntries.Add(cre);
            ratesched.RateEntries.Add(cre1);
            ratesched.DefaultRateEntry = new Metratech_com_cancelrateDefaultRateEntry();
            ratesched.DefaultRateEntry.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            ratesched.DefaultRateEntry.CancelMaxCharge = 11.00M;
            ratesched.DefaultRateEntry.CancelRate = 15.00M;

            List<BaseRateSchedule> brs = new List<BaseRateSchedule>();
            brs.Add(ratesched);

            client.SaveRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value), 
                                                        new PCIdentifier(mtlist.Items[0].ID.Value),
                                                        new PCIdentifier("metratech.com/cancelrate"),
                                                        brs);

            #region GetRateScheduleForSharedPriceList and verify.
            List<BaseRateSchedule> brs1 = new List<BaseRateSchedule>();
            client.GetRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value), new PCIdentifier("metratech.com/cancelrate"), out brs1);
            Assert.AreEqual(1, brs1.Count(), "get rate schedule count didn't match 1");
            RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry> rs1 = brs1[0] as RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry>;

            Assert.IsNotNull(rs1.EffectiveDate, "rate schedule effective date is empty");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.Absolute, rs1.EffectiveDate.EndDateType, "end date type didnt match");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.Absolute, rs1.EffectiveDate.StartDateType, "start date type didnt match");
            Assert.Greater(rs1.EffectiveDate.TimeSpanId, 1, "timespanid not greater than 1");
            //Assert.AreEqual(System.DateTime.Now.AddDays(-1), rs1.EffectiveDate.StartDate, "start date didnt match");
            //Assert.AreEqual(System.DateTime.Now.AddYears(5), rs1.EffectiveDate.EndDate, "end date didnt match");
            Assert.AreEqual(0, rs1.EffectiveDate.StartDateOffset, "start date offset didnt match");
            Assert.AreEqual(0, rs1.EffectiveDate.EndDateOffset, "end date offset didnt match");

            Assert.AreEqual("my sample rate schedule description", rs1.Description, "rate schedule description not fetched");

            Assert.AreEqual(ratesched.DefaultRateEntry.CancelChargeType, rs1.DefaultRateEntry.CancelChargeType, "cancel charge type didnt match on default rate entry");
            Assert.AreEqual(ratesched.DefaultRateEntry.CancelMaxCharge, rs1.DefaultRateEntry.CancelMaxCharge, "cancel max didnt match on default rate entry");
            Assert.AreEqual(ratesched.DefaultRateEntry.CancelRate, rs1.DefaultRateEntry.CancelRate, "cancel rate didnt match on default rate entry");

            Assert.AreEqual(2, rs1.RateEntries.Count, "rate entries count on setting didn't match");
            Assert.IsNotNull(rs1.RateEntries, "rate entries object in rs1 is null");
            Assert.AreEqual(ratesched.RateEntries.Count, rs1.RateEntries.Count, "rate entries count on get didnt match");

            Assert.AreEqual(ratesched.RateEntries.Count, rs1.RateEntries.Count, "rate entries count didnt match");

            Assert.AreEqual(cre.CancelChargeType, rs1.RateEntries[0].CancelChargeType, "cancel charge type didnt match on rate entry");
            Assert.AreEqual(cre.CancelMaxCharge, rs1.RateEntries[0].CancelMaxCharge, "cancel max charge didnt match on rate entry");
            Assert.AreEqual(cre.CancelRate, rs1.RateEntries[0].CancelRate, "cancel rate didnt match on rate entry");
            Assert.AreEqual(cre.ServiceLevel, rs1.RateEntries[0].ServiceLevel, "servicelevel didn't match");

            Assert.AreEqual(cre1.CancelChargeType, rs1.RateEntries[1].CancelChargeType, "cancel charge type didnt match on rate entry");
            Assert.AreEqual(cre1.CancelMaxCharge, rs1.RateEntries[1].CancelMaxCharge, "cancel max charge didnt match on rate entry");
            Assert.AreEqual(cre1.CancelRate, rs1.RateEntries[1].CancelRate, "cancel rate didnt match on rate entry");
            Assert.AreEqual(cre1.ServiceLevel, rs1.RateEntries[1].ServiceLevel, "servicelevel didn't match");


            Assert.AreEqual(rs1.ID.Value, rs1.RateEntries[0].RateScheduleId, "rate schedule id didnt match with rate entries rate schedule id");
            Assert.AreEqual(rs1.ID.Value, rs1.RateEntries[1].RateScheduleId, "rate schedule id didnt match with rate entries rate schedule id");
            Assert.AreEqual(rs1.ID.Value, rs1.DefaultRateEntry.RateScheduleId, "rate schedule id didnt match with default rate entry rate schedule id");
            Assert.IsNotNull(rs1.ParameterTableName, "parameter table name on rate schedule is empty");
            Assert.Greater(rs1.ParameterTableName.Length, 0, "parameter table name is empty");
            #endregion


            #region Get Non existing RateSchedule and verify

            List<BaseRateSchedule> brs2 = new List<BaseRateSchedule>();

            client.GetRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value),
                                                        new PCIdentifier("metratech.com/mincharge"),
                                                        out brs2);

            Assert.AreEqual(0, brs2.Count);
            #endregion

            #region Add another rate schedule for the same shareprice list.
            RateSchedule<Metratech_com_unusedportrateRateEntry, Metratech_com_unusedportrateDefaultRateEntry> rsuuport = new RateSchedule<Metratech_com_unusedportrateRateEntry, Metratech_com_unusedportrateDefaultRateEntry>();
            rsuuport.RateEntries.Add(new Metratech_com_unusedportrateRateEntry() { Index = 1, 
                                                                                   NumUnusedPorts = 1, 
                                                                                   UnusedChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed, 
                                                                                    ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Basic,
                                                                                    ServiceLevel_op = RateEntryOperators.Equal,
                                                                                    UnusedPortRate = 10.00M,
                                                                                    ScheduledConnections = 10,
                                                                                    NumUnusedPorts_op = RateEntryOperators.GreaterEqual,
                                                                                     ScheduledConnections_op = RateEntryOperators.LessEqual });
            rsuuport.DefaultRateEntry = new Metratech_com_unusedportrateDefaultRateEntry() {
                        Index = 2, UnusedChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed, UnusedPortRate = 16.00M};

            rsuuport.Description = "unused port rate charge rate entry schedule desc";
            rsuuport.EffectiveDate = effectiveDate;

            List<BaseRateSchedule> brsUnusedPorts = new List<BaseRateSchedule>();
            brsUnusedPorts.Add(rsuuport);

            client.SaveRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value),
                                                        new PCIdentifier(mtlist.Items[0].ID.Value),
                                                        new PCIdentifier("metratech.com/unusedportrate"),
                                                        brsUnusedPorts);

            #endregion


            #region Update Mode check

            List<BaseRateSchedule> brs21 = new List<BaseRateSchedule>();
            client.GetRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value),
                                                        new PCIdentifier("metratech.com/cancelrate"),
                                                        out brs21);

            Assert.Greater(brs21.Count, 0);

            RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry> rs21 = brs21[0] as RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry>;

            Assert.AreEqual(2, rs21.RateEntries.Count);

            rs21.RateEntries.RemoveAt(0);

            rs21.Description = "updated" + rs21.Description;
            rs21.EffectiveDate.EndDate = DateTime.Now.AddYears(10);

            rs21.DefaultRateEntry.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.PerPort;
            rs21.DefaultRateEntry.CancelMaxCharge = 100.00M;
            rs21.DefaultRateEntry.CancelRate = 200.00M;

            rs21.RateEntries[0].CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.PerPort;
            rs21.RateEntries[0].CancelMaxCharge = 101.00M;
            rs21.RateEntries[0].CancelRate = 201.00M;
            rs21.RateEntries[0].Notice = 21;
            rs21.RateEntries[0].Notice_op = RateEntryOperators.LessEqual;
            rs21.RateEntries[0].ScheduledConnections = 21;
            rs21.RateEntries[0].ScheduledConnections_op = RateEntryOperators.GreaterEqual;
            rs21.RateEntries[0].ScheduledDuration = 11;
            rs21.RateEntries[0].ScheduledDuration_op = RateEntryOperators.Equal;
            rs21.RateEntries[0].ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Premiere;
            rs21.RateEntries[0].ServiceLevel_op = RateEntryOperators.Less;

            List<BaseRateSchedule> brs22 = new List<BaseRateSchedule>();
            brs22.Add(rs21);
            client.SaveRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value), new PCIdentifier(mtlist.Items[0].ID.Value), new PCIdentifier("metratech.com/cancelrate"), brs22);

            List<BaseRateSchedule> brs23;
            client.GetRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value), new PCIdentifier("metratech.com/cancelrate"), out brs23);

            Assert.IsNotNull(brs23);
            Assert.AreEqual(1, brs23.Count);

            RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry> rs22 = brs23[0] as RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry>;

            Assert.AreEqual(1, rs22.RateEntries.Count);
            Assert.AreEqual("updated", rs22.Description.Substring(0, 7));
            Assert.IsNotNull(rs22.EffectiveDate);

            Assert.AreEqual(MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.PerPort, rs22.DefaultRateEntry.CancelChargeType);
            Assert.AreEqual(200.00M, rs22.DefaultRateEntry.CancelRate);

            Assert.AreEqual(MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.PerPort, rs22.RateEntries[0].CancelChargeType);
            Assert.AreEqual(101.00M, rs22.RateEntries[0].CancelMaxCharge);
            Assert.AreEqual(201.00M, rs22.RateEntries[0].CancelRate);
            Assert.AreEqual(21, rs22.RateEntries[0].Notice);
            Assert.AreEqual(RateEntryOperators.LessEqual, rs22.RateEntries[0].Notice_op);
            Assert.AreEqual(21, rs22.RateEntries[0].ScheduledConnections);
            Assert.AreEqual(RateEntryOperators.GreaterEqual, rs22.RateEntries[0].ScheduledConnections_op);
            Assert.AreEqual(11, rs22.RateEntries[0].ScheduledDuration);
            Assert.AreEqual(RateEntryOperators.Equal, rs22.RateEntries[0].ScheduledDuration_op);
            Assert.AreEqual(MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Premiere, rs22.RateEntries[0].ServiceLevel);
            Assert.AreEqual(RateEntryOperators.Less, rs22.RateEntries[0].ServiceLevel_op);

            #endregion


            #region GetRateScheduleForSharedPriceList and verify .
            List<BaseRateSchedule> brs1unused = new List<BaseRateSchedule>();
            client.GetRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value), new PCIdentifier("metratech.com/unusedportrate"), out brs1unused);
            Assert.AreEqual(1, brs1unused.Count(), "get rate schedule count didn't match 1");
            RateSchedule<Metratech_com_unusedportrateRateEntry, Metratech_com_unusedportrateDefaultRateEntry> rs1unusedport = brs1unused[0] as RateSchedule<Metratech_com_unusedportrateRateEntry, Metratech_com_unusedportrateDefaultRateEntry>;

            Assert.IsNotNull(rs1unusedport.EffectiveDate, "rate schedule effective date is empty");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.Absolute, rs1unusedport.EffectiveDate.EndDateType, "end date type didnt match");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.Absolute, rs1unusedport.EffectiveDate.StartDateType, "start date type didnt match");
            Assert.Greater(rs1unusedport.EffectiveDate.TimeSpanId, 1, "timespanid not greater than 1");
            //Assert.AreEqual(System.DateTime.Now.AddDays(-1), rs1.EffectiveDate.StartDate, "start date didnt match");
            //Assert.AreEqual(System.DateTime.Now.AddYears(5), rs1.EffectiveDate.EndDate, "end date didnt match");
            Assert.AreEqual(0, rs1unusedport.EffectiveDate.StartDateOffset, "start date offset didnt match");
            Assert.AreEqual(0, rs1unusedport.EffectiveDate.EndDateOffset, "end date offset didnt match");

            Assert.AreEqual("unused port rate charge rate entry schedule desc", rs1unusedport.Description, "rate schedule description not fetched");

            Assert.AreEqual(MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed, rs1unusedport.DefaultRateEntry.UnusedChargeType, "unused charge type didnt match on default rate entry");
            Assert.AreEqual(16.00M, rs1unusedport.DefaultRateEntry.UnusedPortRate, "unused port rate didnt match on default rate entry");


            Assert.IsNotNull(rs1unusedport.RateEntries, "rate entries object in rs1 is null");
            Assert.AreEqual(1, rs1unusedport.RateEntries.Count, "rate entries count didnt match");

            Assert.AreEqual(1, rs1unusedport.RateEntries[0].NumUnusedPorts, "cancel charge type didnt match on rate entry");
            Assert.AreEqual(MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed, rs1unusedport.RateEntries[0].UnusedChargeType, "un used port charge typedidnt match on rate entry");
            Assert.AreEqual(MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Basic, rs1unusedport.RateEntries[0].ServiceLevel, "unused port rate service level didnt match on rate entry");
            Assert.AreEqual(RateEntryOperators.Equal, rs1unusedport.RateEntries[0].ServiceLevel_op, "un used port rate servicelevel op didn't match");
            Assert.AreEqual(10.00M, rs1unusedport.RateEntries[0].UnusedPortRate, "un used port rate didn't match");
            Assert.AreEqual(10, rs1unusedport.RateEntries[0].ScheduledConnections, "un used port rate scheduled connections didn't match");
            Assert.AreEqual(RateEntryOperators.GreaterEqual, rs1unusedport.RateEntries[0].NumUnusedPorts_op, "un used port rate num unused ports operator op didn't match");
            Assert.AreEqual(RateEntryOperators.LessEqual, rs1unusedport.RateEntries[0].ScheduledConnections_op, "un used port rate scheduled connections operator op didn't match");

            Assert.AreEqual(rs1unusedport.ID.Value, rs1unusedport.RateEntries[0].RateScheduleId, "rate schedule id didnt match with rate entries rate schedule id");
            Assert.AreEqual(rs1unusedport.ID.Value, rs1unusedport.DefaultRateEntry.RateScheduleId, "rate schedule id didnt match with default rate entry rate schedule id");
            Assert.IsNotNull(rs1unusedport.ParameterTableName, "parameter table name on rate schedule is empty");
            Assert.Greater(rs1unusedport.ParameterTableName.Length, 0, "parameter table name is empty");
            #endregion

            #region Get Rate schedule and remove and verify
            List<BaseRateSchedule> brs1remove = new List<BaseRateSchedule>();
            client.GetRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value), new PCIdentifier("metratech.com/unusedportrate"), out brs1remove);
            
            Assert.IsNotNull(brs1remove);
            Assert.AreEqual(1, brs1remove.Count);
            
            client.RemoveRateScheduleFromSharedPriceList(new PCIdentifier(m_PriceListID.Value), brs1[0].ID.Value);

            List<BaseRateSchedule> brs1removed = new List<BaseRateSchedule>();
            client.GetRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value), new PCIdentifier("metratech.com/unusedportrate"), out brs1remove);

            Assert.IsNotNull(brs1removed);
            Assert.AreEqual(0, brs1removed.Count);


            #endregion


            #region Delete shared price list and verify its removed using get & gets method.
            client.DeleteSharedPriceList(new PCIdentifier(m_PriceListID.Value));

            MTList<PriceList> plafterremove = new MTList<PriceList>();
            plafterremove.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, m_PriceListName));
            plafterremove.PageSize = 10;
            plafterremove.CurrentPage = 1;

            client.GetSharedPriceLists(ref plafterremove);

            Assert.AreEqual(0, plafterremove.Items.Count);




            try
            {
                PriceList plst;
                client.GetSharedPriceList(new PCIdentifier(m_PriceListID.Value), out plst);
                Assert.Fail();
            }
            catch
            {
            }
            #endregion

            client.Close();                                            




        }

        [Test]
        [Category("ProductOfferingRateSchedules")]
        public void ProductOfferingRateSchedules()
        {
            SaveProductOffering();
            int poId = m_pId;

            ProductOfferingServiceClient poClient = new ProductOfferingServiceClient();
            poClient.ClientCredentials.UserName.UserName = "su";
            poClient.ClientCredentials.UserName.Password = "su123";
            poClient.Open();
            ProductOffering po;

            poClient.GetProductOffering(new PCIdentifier(poId), out po);

            PriceListServiceClient plClient = new PriceListServiceClient();
            plClient.ClientCredentials.UserName.UserName = "su";
            plClient.ClientCredentials.UserName.Password = "su123";
            plClient.Open();

            List<BaseRateSchedule> brs = new List<BaseRateSchedule>();

            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(poId), new PCIdentifier(po.PriceableItems[0].ID.Value), new PCIdentifier("metratech.com/mincharge"), out brs);

            Assert.AreEqual(1, brs.Count, "rate schedule count didnt match");

            BasePriceableItemInstance bpi;
            poClient.GetPIInstanceForPO(new PCIdentifier(poId), new PCIdentifier(po.PriceableItems[0].ID.Value), out bpi);

            Assert.IsNotNull(bpi);

            AudioConfCallPIInstance pinstance = bpi as AudioConfCallPIInstance;

            Assert.IsNotNull(pinstance.Metratech_com_mincharge_RateSchedules);
            Assert.IsNotNull(brs[0]);
            Assert.AreEqual(pinstance.Metratech_com_mincharge_RateSchedules.Count, brs.Count, "count didnt match");

            RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry> ers = pinstance.Metratech_com_mincharge_RateSchedules[0];
            RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry> ars = brs[0] as RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>;

            Assert.IsNotNull(ers.DefaultRateEntry);
            Assert.IsNotNull(ars.DefaultRateEntry);
            Assert.AreEqual(ers.DefaultRateEntry.ConfChargeMinimum, ars.DefaultRateEntry.ConfChargeMinimum);
            Assert.AreEqual(ers.DefaultRateEntry.Index, ars.DefaultRateEntry.Index);
            Assert.AreEqual(ers.ID, ars.ID);
            Assert.AreEqual(ers.Description, ars.Description);
            Assert.AreEqual(ers.ParameterTableID, ars.ParameterTableID);
            Assert.AreEqual(ers.ParameterTableName, ars.ParameterTableName);
            Assert.AreEqual(ers.RateEntries.Count, ars.RateEntries.Count);

            Metratech_com_minchargeRateEntry ere = ers.RateEntries[0];
            Metratech_com_minchargeRateEntry are = ars.RateEntries[0];

            Assert.AreEqual(ere.ConfChargeMinimum, are.ConfChargeMinimum);
            Assert.AreEqual(ere.ConfChargeMinimumApplicBool, are.ConfChargeMinimumApplicBool);
            Assert.AreEqual(ere.Index, are.Index);
            Assert.AreEqual(ere.RateScheduleId, are.RateScheduleId);


            ars.DefaultRateEntry.ConfChargeMinimum = 100.00M;
            ars.RateEntries.Add(new Metratech_com_minchargeRateEntry() { ConfChargeMinimum = 11.00M, Index = 2, ConfChargeMinimumApplicBool = true });

            
            plClient.SaveRateScheduleForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), brs);

            /*
            PriceListMapping plMap = new PriceListMapping();
            plMap.CanICB = false;
            plMap.piInstanceID = pinstance.ID.Value;
            */

            PriceListMapping pricelistmap;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out pricelistmap);
            Assert.IsNotNull(pricelistmap);
            Assert.Greater(pricelistmap.priceListID, 0);

            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out brs);
            ars = brs[0] as RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>;

            Assert.AreEqual(1, brs.Count);
            Assert.IsNotNull(ars);
            Assert.AreEqual(100.00M, ars.DefaultRateEntry.ConfChargeMinimum);
            Assert.AreEqual(11.00M, ars.RateEntries[1].ConfChargeMinimum, "conf charge min didnt match");
            Assert.AreEqual(true, ars.RateEntries[1].ConfChargeMinimumApplicBool);
            Assert.AreEqual(ars.ID, ars.RateEntries[1].RateScheduleId);
            Assert.AreEqual(ars.ID, ars.DefaultRateEntry.RateScheduleId);


            #region Add another rate schedule and verify

            RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry> ratesched = new RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry>();
            Metratech_com_cancelrateRateEntry cre = new Metratech_com_cancelrateRateEntry();

            cre.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            cre.CancelMaxCharge = 10.00M;
            cre.CancelRate = 14.00M;
            cre.ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Executive;
            cre.Index = 1;

            Metratech_com_cancelrateRateEntry cre1 = new Metratech_com_cancelrateRateEntry();
            cre1.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            cre1.CancelMaxCharge = 8.00M;
            cre1.CancelRate = 13.00M;
            cre1.ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Basic;
            cre1.Index = 2;

            ratesched.Description = "my sample rate schedule description";

            ProdCatTimeSpan effectiveDate = new ProdCatTimeSpan();
            effectiveDate.StartDate = System.DateTime.Now.AddDays(-1);
            effectiveDate.StartDateOffset = 0;
            effectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            effectiveDate.EndDate = System.DateTime.Now.AddYears(5);
            effectiveDate.EndDateOffset = 0;
            effectiveDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;

            ratesched.EffectiveDate = effectiveDate;
            ratesched.RateEntries.Add(cre);
            ratesched.RateEntries.Add(cre1);
            ratesched.DefaultRateEntry = new Metratech_com_cancelrateDefaultRateEntry();
            ratesched.DefaultRateEntry.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            ratesched.DefaultRateEntry.CancelMaxCharge = 11.00M;
            ratesched.DefaultRateEntry.CancelRate = 15.00M;

            List<BaseRateSchedule> cbrs = new List<BaseRateSchedule>();
            cbrs.Add(ratesched);

            plClient.SaveRateScheduleForProductOffering(new PCIdentifier(poId),
                                                        new PCIdentifier(bpi.ID.Value),
                                                        new PCIdentifier("metratech.com/cancelrate"),
                                                        cbrs);

            #region GetRateScheduleForSharedPriceList and verify.
            List<BaseRateSchedule> brs1 = new List<BaseRateSchedule>();
            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/cancelrate"), out brs1);
            Assert.AreEqual(1, brs1.Count(), "get rate schedule count didn't match 1");
            RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry> rs1 = brs1[0] as RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry>;

            Assert.IsNotNull(rs1.EffectiveDate, "rate schedule effective date is empty");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.Absolute, rs1.EffectiveDate.EndDateType, "end date type didnt match");
            Assert.AreEqual(ProdCatTimeSpan.MTPCDateType.Absolute, rs1.EffectiveDate.StartDateType, "start date type didnt match");
            Assert.Greater(rs1.EffectiveDate.TimeSpanId, 1, "timespanid not greater than 1");
            //Assert.AreEqual(System.DateTime.Now.AddDays(-1), rs1.EffectiveDate.StartDate, "start date didnt match");
            //Assert.AreEqual(System.DateTime.Now.AddYears(5), rs1.EffectiveDate.EndDate, "end date didnt match");
            Assert.AreEqual(0, rs1.EffectiveDate.StartDateOffset, "start date offset didnt match");
            Assert.AreEqual(0, rs1.EffectiveDate.EndDateOffset, "end date offset didnt match");

            Assert.AreEqual("my sample rate schedule description", rs1.Description, "rate schedule description not fetched");

            Assert.AreEqual(ratesched.DefaultRateEntry.CancelChargeType, rs1.DefaultRateEntry.CancelChargeType, "cancel charge type didnt match on default rate entry");
            Assert.AreEqual(ratesched.DefaultRateEntry.CancelMaxCharge, rs1.DefaultRateEntry.CancelMaxCharge, "cancel max didnt match on default rate entry");
            Assert.AreEqual(ratesched.DefaultRateEntry.CancelRate, rs1.DefaultRateEntry.CancelRate, "cancel rate didnt match on default rate entry");

            Assert.AreEqual(2, rs1.RateEntries.Count, "rate entries count on setting didn't match");
            Assert.IsNotNull(rs1.RateEntries, "rate entries object in rs1 is null");
            Assert.AreEqual(ratesched.RateEntries.Count, rs1.RateEntries.Count, "rate entries count on get didnt match");

            Assert.AreEqual(ratesched.RateEntries.Count, rs1.RateEntries.Count, "rate entries count didnt match");

            Assert.AreEqual(cre.CancelChargeType, rs1.RateEntries[0].CancelChargeType, "cancel charge type didnt match on rate entry");
            Assert.AreEqual(cre.CancelMaxCharge, rs1.RateEntries[0].CancelMaxCharge, "cancel max charge didnt match on rate entry");
            Assert.AreEqual(cre.CancelRate, rs1.RateEntries[0].CancelRate, "cancel rate didnt match on rate entry");
            Assert.AreEqual(cre.ServiceLevel, rs1.RateEntries[0].ServiceLevel, "servicelevel didn't match");

            Assert.AreEqual(cre1.CancelChargeType, rs1.RateEntries[1].CancelChargeType, "cancel charge type didnt match on rate entry");
            Assert.AreEqual(cre1.CancelMaxCharge, rs1.RateEntries[1].CancelMaxCharge, "cancel max charge didnt match on rate entry");
            Assert.AreEqual(cre1.CancelRate, rs1.RateEntries[1].CancelRate, "cancel rate didnt match on rate entry");
            Assert.AreEqual(cre1.ServiceLevel, rs1.RateEntries[1].ServiceLevel, "servicelevel didn't match");


            Assert.AreEqual(rs1.ID.Value, rs1.RateEntries[0].RateScheduleId, "rate schedule id didnt match with rate entries rate schedule id");
            Assert.AreEqual(rs1.ID.Value, rs1.RateEntries[1].RateScheduleId, "rate schedule id didnt match with rate entries rate schedule id");
            Assert.AreEqual(rs1.ID.Value, rs1.DefaultRateEntry.RateScheduleId, "rate schedule id didnt match with default rate entry rate schedule id");
            Assert.IsNotNull(rs1.ParameterTableName, "parameter table name on rate schedule is empty");
            Assert.Greater(rs1.ParameterTableName.Length, 0, "parameter table name is empty");
            #endregion


            plClient.RemoveRateScheduleFromProductOffering(new PCIdentifier(poId), rs1.ID.Value);

            List<BaseRateSchedule> nrs = new List<BaseRateSchedule>();
            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/cancelrate"), out nrs);

            Assert.AreEqual(0, nrs.Count);
            


            #endregion


            /*

o	Call SaveRateSchedulesForProductOffering to add new rate schedules and to update existing ones for mapped parameter tables
o	Call GetRateSchedulesForProductOffering to validate changes for mapped parameter tables
o	Call RemoveRateSchedulesForProductOffering to remove a rate schedule for mapped parameter tables
o	Call GetRateSchedulesForProductOffering to validate removal for mapped parameter tables
o	Call SavePriceListMappings to map parameter tables back to default price list
o	Call GetRateSchedulesForProductOffering to ensure that previously mapped parameter tables match original rate schedules

             */

            SaveSharedPriceList();

            ProductOffering oldpo = po;

            SaveProductOffering();
            poId = m_pId;
            poClient.GetProductOffering(new PCIdentifier(poId), out po);

            poClient.GetPIInstanceForPO(new PCIdentifier(poId), new PCIdentifier(po.PriceableItems[0].ID.Value), out bpi);


            ratesched = new RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry>();
            cre = new Metratech_com_cancelrateRateEntry();

            cre.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            cre.CancelMaxCharge = 10.00M;
            cre.CancelRate = 14.00M;
            cre.ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Executive;
            cre.Index = 1;

            cre1 = new Metratech_com_cancelrateRateEntry();
            cre1.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            cre1.CancelMaxCharge = 8.00M;
            cre1.CancelRate = 13.00M;
            cre1.ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Basic;
            cre1.Index = 2;

            ratesched.Description = "my sample rate schedule description";

            effectiveDate = new ProdCatTimeSpan();
            effectiveDate.StartDate = System.DateTime.Now.AddDays(-1);
            effectiveDate.StartDateOffset = 0;
            effectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            effectiveDate.EndDate = System.DateTime.Now.AddYears(5);
            effectiveDate.EndDateOffset = 0;
            effectiveDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;

            ratesched.EffectiveDate = effectiveDate;
            ratesched.RateEntries.Add(cre);
            ratesched.RateEntries.Add(cre1);
            ratesched.DefaultRateEntry = new Metratech_com_cancelrateDefaultRateEntry();
            ratesched.DefaultRateEntry.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            ratesched.DefaultRateEntry.CancelMaxCharge = 11.00M;
            ratesched.DefaultRateEntry.CancelRate = 15.00M;

            cbrs = new List<BaseRateSchedule>();
            cbrs.Add(ratesched);

            plClient.SaveRateScheduleForProductOffering(new PCIdentifier(poId),
                                                        new PCIdentifier(bpi.ID.Value),
                                                        new PCIdentifier("metratech.com/cancelrate"),
                                                        cbrs);

            PriceListMapping plmap;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/cancelrate"), out plmap);
            Assert.IsNotNull(plmap.SharedPriceList);
            Assert.AreEqual(false, plmap.SharedPriceList);

            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out plmap);
            Assert.IsNotNull(plmap.SharedPriceList);
            Assert.AreEqual(false, plmap.SharedPriceList);

            plmap.priceListID = m_PriceListID.Value;
            plmap.CanICB = false;
            plClient.SavePriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), ref plmap);

            PriceListMapping plmap1;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out plmap1);
            Assert.IsNotNull(plmap1.SharedPriceList);
            Assert.AreEqual(true, plmap1.SharedPriceList);
            Assert.AreEqual(m_PriceListID.Value, plmap1.priceListID);

            PriceListMapping plmap2;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/cancelrate"), out plmap2);
            m_Logger.LogInfo("default non-shared priceist " + plmap2.priceListID);
            Assert.IsNotNull(plmap2.SharedPriceList);
            Assert.AreEqual(false, plmap2.SharedPriceList);

            //moving from nonshared to another po's non shared- expected to fail.
            plmap2.priceListID = pricelistmap.priceListID;
            
            plmap2.CanICB = true;
            Assert.Greater(pricelistmap.priceListID, 0, "pricelist id is present" + pricelistmap.priceListID);
            try
            {
                m_Logger.LogInfo("saving -> moving from nonshared to another po's non shared- expected to fail. id = " + plmap2.priceListID + " poid = " + poId);
                plClient.SavePriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/cancelrate"), ref plmap2);
                Assert.Fail("saved another po's non-shared price list id");
            }
            catch { }

            PriceListMapping plmap3;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out plmap3);
            m_Logger.LogInfo("min charge r e pricelist.id " + plmap3.priceListID + " isshared? => " + plmap3.SharedPriceList);
            plmap3.priceListID = pricelistmap.priceListID;
            plmap3.CanICB = false;
            try
            {
                plClient.SavePriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), ref plmap3);
                Assert.Fail("saved another po's non-shared price list id from Shared price list");
            }
            catch { }

            PriceListMapping plmap4;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out plmap4);
            m_Logger.LogInfo("min charge r e pricelist.id " + plmap4.priceListID + " isshared? => " + plmap4.SharedPriceList);

            PriceList oldpricelist = m_PriceList;

            SaveSharedPriceList();

            //moving from shared to another shared pricelist. - should allow.
            
            plmap4.priceListID = m_PriceListID.Value;

            plClient.SavePriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), ref plmap4);

            plmap4 = null;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out plmap4);
            Assert.AreEqual(m_PriceListID.Value, plmap4.priceListID);

            //changing from shared to default non-shared pricelist for po - should save.
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/cancelrate"), out plmap2);
            plmap4.priceListID = plmap2.priceListID;
            m_Logger.LogInfo("plmap4 pricelist id => " + plmap4.priceListID + "  plmap2.pricelistid => " + plmap2.priceListID);
            plmap4.CanICB = true;

            plClient.SavePriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), ref plmap4);
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out plmap4);
            Assert.AreEqual(plmap2.priceListID, plmap4.priceListID);

            plmap4.priceListID = oldpricelist.ID.Value;
            plmap4.CanICB = true;
            //move to initial shared pricelist.
            plClient.SavePriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), ref plmap4);
            plmap4 = null;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out plmap4);
            Assert.AreEqual(oldpricelist.ID.Value, plmap4.priceListID);
            m_PriceList = oldpricelist;
            m_PriceListID = oldpricelist.ID;
            m_PriceListName = oldpricelist.Name;


            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/cancelrate"), out plmap2);
            Assert.IsNotNull(plmap2.SharedPriceList);
            Assert.AreEqual(false, plmap2.SharedPriceList);

            poClient.Close();
            plClient.Close();
        }

        [Test]
        [Category("PoPriceListMapAndRateSchedule")]
        public void PoPriceListMapAndRateSchedule()
        {

            SaveProductOffering();
            int poId = m_pId;

            ProductOfferingServiceClient poClient = new ProductOfferingServiceClient();
            poClient.ClientCredentials.UserName.UserName = "su";
            poClient.ClientCredentials.UserName.Password = "su123";
            poClient.Open();
            ProductOffering po;
            List<BaseRateSchedule> origRS;
            //List<RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>> origRS = new List<RateSchedule<Metratech_com_minchargeRateEntry,Metratech_com_minchargeDefaultRateEntry>>();

            poClient.GetProductOffering(new PCIdentifier(poId), out po);
            
            PriceListServiceClient plClient = new PriceListServiceClient();
            plClient.ClientCredentials.UserName.UserName = "su";
            plClient.ClientCredentials.UserName.Password = "su123";
            plClient.Open();

            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(po.ProductOfferingId.Value), new PCIdentifier(po.PriceableItems[0].ID.Value),
                                                        new PCIdentifier("metratech.com/mincharge"), out origRS);
                                                        

            Assert.IsNotNull(origRS);
            Assert.IsNotNull(origRS[0]);

            BasePriceableItemInstance bpi;
            poClient.GetPIInstanceForPO(new PCIdentifier(poId), new PCIdentifier(po.PriceableItems[0].ID.Value), out bpi);

            AudioConfCallPIInstance pinstance = bpi as AudioConfCallPIInstance;

            RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry> ers = pinstance.Metratech_com_mincharge_RateSchedules[0];

            PriceListMapping plmap;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out plmap);
            Assert.IsNotNull(plmap);

            SaveSharedPriceList();

            plmap.priceListID = m_PriceList.ID.Value;

            plClient.SavePriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), ref plmap);


            #region add new rate schedule for cancel rate.
            RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry> ratesched;
            ratesched = new RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry>();

            Metratech_com_cancelrateRateEntry cre = new Metratech_com_cancelrateRateEntry();

            cre.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            cre.CancelMaxCharge = 10.00M;
            cre.CancelRate = 14.00M;
            cre.ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Executive;
            cre.Index = 1;

            Metratech_com_cancelrateRateEntry cre1 = new Metratech_com_cancelrateRateEntry();
            cre1.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            cre1.CancelMaxCharge = 8.00M;
            cre1.CancelRate = 13.00M;
            cre1.ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Basic;
            cre1.Index = 2;

            ratesched.Description = "my sample rate schedule description";

            ProdCatTimeSpan effectiveDate = new ProdCatTimeSpan();
            effectiveDate.StartDate = System.DateTime.Now.AddDays(-1);
            effectiveDate.StartDateOffset = 0;
            effectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            effectiveDate.EndDate = System.DateTime.Now.AddYears(5);
            effectiveDate.EndDateOffset = 0;
            effectiveDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;

            ratesched.EffectiveDate = effectiveDate;
            ratesched.RateEntries.Add(cre);
            ratesched.RateEntries.Add(cre1);
            ratesched.DefaultRateEntry = new Metratech_com_cancelrateDefaultRateEntry();
            ratesched.DefaultRateEntry.CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed;
            ratesched.DefaultRateEntry.CancelMaxCharge = 11.00M;
            ratesched.DefaultRateEntry.CancelRate = 15.00M;

            List<BaseRateSchedule> cbrs = new List<BaseRateSchedule>();
            cbrs.Add(ratesched);

            plClient.SaveRateScheduleForProductOffering(new PCIdentifier(poId),
                                                        new PCIdentifier(bpi.ID.Value),
                                                        new PCIdentifier("metratech.com/cancelrate"),
                                                        cbrs);

            #endregion

            #region add new rate schedule for shared price list
            RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry> ratesched1;
            ratesched1 = new RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>();

            Metratech_com_minchargeRateEntry cre2 = new Metratech_com_minchargeRateEntry();

            cre2.ConfChargeMinimum = 10.00M;
            cre2.ConfChargeMinimumApplicBool = false;
            cre2.Index = 1;

            Metratech_com_minchargeRateEntry cre3 = new Metratech_com_minchargeRateEntry();
            cre3.ConfChargeMinimum = 8.00M;
            cre3.ConfChargeMinimumApplicBool = true;
            cre3.Index = 2;

            ratesched1.Description = "my sample rate schedule description";

            effectiveDate = new ProdCatTimeSpan();
            effectiveDate.StartDate = System.DateTime.Now.AddDays(-1);
            effectiveDate.StartDateOffset = 0;
            effectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
            effectiveDate.EndDate = System.DateTime.Now.AddYears(5);
            effectiveDate.EndDateOffset = 0;
            effectiveDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;

            ratesched1.EffectiveDate = effectiveDate;
            ratesched1.RateEntries.Add(cre2);
            ratesched1.RateEntries.Add(cre3);
            ratesched1.DefaultRateEntry = new Metratech_com_minchargeDefaultRateEntry();
            ratesched1.DefaultRateEntry.ConfChargeMinimum = 20.00M;

            List<BaseRateSchedule> cbrs1 = new List<BaseRateSchedule>();
            cbrs1.Add(ratesched1);

            #region get template for AudioConfCall
            ProductCatalogServiceClient pcClient = new ProductCatalogServiceClient();
            pcClient.ClientCredentials.UserName.UserName = "su";
            pcClient.ClientCredentials.UserName.Password = "su123";

            MTList<BasePriceableItemTemplate> mtlist = new MTList<BasePriceableItemTemplate>();
            mtlist.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "AudioConfCall"));
            mtlist.PageSize = 10;
            mtlist.CurrentPage = 1;

            pcClient.GetPriceableItemTemplates(ref mtlist);

            pcClient.Close();

            #endregion

            plClient.SaveRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceList.ID.Value), new PCIdentifier(mtlist.Items[0].ID.Value), new PCIdentifier("metratech.com/mincharge"),
                                                           cbrs1);
            #endregion

            m_Logger.LogInfo("piinstance id " + bpi.ID.Value);
            poClient.GetPIInstanceForPO(new PCIdentifier(poId), new PCIdentifier(bpi.ID.Value), out bpi);
            pinstance = bpi as AudioConfCallPIInstance;
            
            List<BaseRateSchedule> rs3;
            m_Logger.LogInfo("Shared pricelist id " + m_PriceListID.Value);
            plClient.GetRateSchedulesForSharedPriceList(new PCIdentifier(m_PriceListID.Value), new PCIdentifier("metratech.com/mincharge"), out rs3);


            Assert.AreEqual(pinstance.Metratech_com_mincharge_RateSchedules[0].ParameterTableID, rs3[0].ParameterTableID);
            m_Logger.LogInfo("rs id on shared price list " + rs3[0].ID.Value + "  rs id on pi instance - " + pinstance.Metratech_com_mincharge_RateSchedules[0].ID.Value);
            m_Logger.LogInfo("count rate schedules on piinstance " + pinstance.Metratech_com_mincharge_RateSchedules.Count);
            Assert.AreEqual(pinstance.Metratech_com_mincharge_RateSchedules[0].ID, rs3[0].ID.Value);

            #region add new rs and upd exist rate schedule for a shared pricelist

            RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>
                newRS = new RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>();

            newRS.DefaultRateEntry = new Metratech_com_minchargeDefaultRateEntry() { ConfChargeMinimum = 100.0M};
            newRS.RateEntries.Add(new Metratech_com_minchargeRateEntry() { ConfChargeMinimum = 10.00M, ConfChargeMinimumApplicBool = false });
            newRS.Description = "new rate schedule";
            newRS.EffectiveDate = new ProdCatTimeSpan() { EndDate = System.DateTime.Now.AddYears(10),
                                                          StartDate = System.DateTime.Now.AddYears(9),
                                                          StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
                                                          EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
                                                           EndDateOffset = 0, StartDateOffset = 0};
            rs3.Add(newRS);
            rs3[0].Description = "updated" + rs3[0].Description;
            rs3[0].EffectiveDate.StartDate = rs3[0].EffectiveDate.StartDate.Value.AddDays(1);



                                                                                    

            #endregion

            plClient.SaveRateScheduleForProductOffering(new PCIdentifier(poId), new PCIdentifier(pinstance.ID.Value), new PCIdentifier("metratech.com/mincharge"),
                                                           rs3);
            List<BaseRateSchedule> newrs3;
            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(poId), new PCIdentifier(pinstance.ID.Value), new PCIdentifier("metratech.com/mincharge"),
                                                           out newrs3);

            Assert.AreEqual(rs3.Count, newrs3.Count);

            plClient.RemoveRateScheduleFromProductOffering(new PCIdentifier(poId), newrs3[1].ID.Value);

            List<BaseRateSchedule> newrs5;
            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(poId), new PCIdentifier(pinstance.ID.Value), new PCIdentifier("metratech.com/mincharge"),
                                                           out newrs5);

            Assert.AreEqual(rs3.Count - 1, newrs5.Count);

            PriceListMapping defPricelistmap;

            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(pinstance.ID.Value), new PCIdentifier("metratech.com/cancelrate"), out defPricelistmap);

            PriceListMapping minchargeplmap;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(pinstance.ID.Value), new PCIdentifier("metratech.com/mincharge"), out minchargeplmap);

            minchargeplmap.priceListID = defPricelistmap.priceListID;

            plClient.SavePriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(pinstance.ID.Value), new PCIdentifier("metratech.com/mincharge"), ref minchargeplmap);

            PriceListMapping updPLMap;
            plClient.GetPriceListMappingForProductOffering(new PCIdentifier(poId), new PCIdentifier(pinstance.ID.Value), new PCIdentifier("metratech.com/mincharge"), out updPLMap);

            Assert.AreEqual(updPLMap.priceListID, defPricelistmap.priceListID);

            List<BaseRateSchedule> finrs;
            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(poId), new PCIdentifier(pinstance.ID.Value), new PCIdentifier("metratech.com/mincharge"), out finrs);
            
            Assert.IsNotNull(finrs);
            Assert.IsNotNull(finrs[0]);
            Assert.IsNotNull(origRS);
            Assert.IsNotNull(origRS[0]);
            Assert.AreEqual(finrs[0].ID, origRS[0].ID);
            Assert.AreEqual(finrs[0].Description, origRS[0].Description);
            Assert.AreEqual(finrs[0].EffectiveDate.StartDate, origRS[0].EffectiveDate.StartDate);
            Assert.AreEqual(((IList)finrs[0].GetValue("RateEntries")).Count, ((IList)origRS[0].GetValue("RateEntries")).Count);
            Assert.AreEqual( (( Metratech_com_minchargeRateEntry)((IList)finrs[0].GetValue("RateEntries"))[0]).ConfChargeMinimum , ((Metratech_com_minchargeRateEntry)((IList)origRS[0].GetValue("RateEntries"))[0]).ConfChargeMinimum);
            


            #region add new rs and upd exist rate schedule for the default pricelist.
            List<BaseRateSchedule> rs4;
            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(poId),
                                                            new PCIdentifier(pinstance.ID.Value),
                                                            new PCIdentifier("metratech.com/cancelrate"),
                                                            out rs4);


            Assert.AreEqual(pinstance.Metratech_com_cancelrate_RateSchedules.Count, rs4.Count);
            Assert.AreEqual(pinstance.Metratech_com_cancelrate_RateSchedules[0].ParameterTableID, rs4[0].ParameterTableID);

            m_Logger.LogInfo("rs4[0].parametertableid " + rs4[0].ParameterTableID);

            rs4[0].Description = "updated" + rs4[0].Description;
            rs4[0].EffectiveDate.StartDate = rs4[0].EffectiveDate.StartDate.Value.AddDays(1);
            List<Metratech_com_cancelrateRateEntry> rateentries = rs4[0].GetValue("RateEntries") as List<Metratech_com_cancelrateRateEntry>;
            rateentries[0].CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.PerPort;
            rateentries[0].CancelMaxCharge = 100.00M;
            int idx = rateentries[0].Index;

            #region setup new rate schedule
            RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry> nrs = new RateSchedule<Metratech_com_cancelrateRateEntry, Metratech_com_cancelrateDefaultRateEntry>();
            nrs.Description = "future value";
            nrs.EffectiveDate = new ProdCatTimeSpan() { EndDate = System.DateTime.Now.AddYears(20),
                                                        StartDate = System.DateTime.Now.AddYears(21),
                                                        StartDateOffset = 0, EndDateOffset = 0,
                                                         EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
                                                         StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute};
            nrs.RateEntries.Add(new Metratech_com_cancelrateRateEntry() { CancelChargeType = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.PerPort,
                                                                          CancelMaxCharge = 20.00M,
                                                                          CancelRate = 10.00M,
                                                                          Notice = 1,
                                                                          Notice_op = RateEntryOperators.Less,
                                                                          ScheduledConnections = 4,
                                                                          ScheduledConnections_op = RateEntryOperators.Equal,
                                                                          ScheduledDuration = 2,
                                                                          ScheduledDuration_op = RateEntryOperators.Greater,
                                                                          ServiceLevel = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ServiceLevel.Basic,
                                                                          ServiceLevel_op = RateEntryOperators.Equal});
            nrs.DefaultRateEntry = new Metratech_com_cancelrateDefaultRateEntry() { CancelChargeType  = MetraTech.DomainModel.Enums.AudioConf.Metratech_com_audioconfcommon.ChargeType.Fixed,
                                                                                    CancelMaxCharge = 20.00M,
                                                                                    CancelRate = 30.00M};                                                                                    
            #endregion                                                                                    
                                                        
            rs4.Add(nrs);
            
            plClient.SaveRateScheduleForProductOffering(new PCIdentifier(poId),
                                                            new PCIdentifier(pinstance.ID.Value),
                                                            new PCIdentifier("metratech.com/cancelrate"),
                                                            rs4);
            List<BaseRateSchedule> rs5;
            m_Logger.LogInfo("get rate schedules for po rs5");
            plClient.GetRateSchedulesForProductOffering(new PCIdentifier(poId),
                                                            new PCIdentifier(pinstance.ID.Value),
                                                            new PCIdentifier("metratech.com/cancelrate"),
                                                            out rs5);

            foreach (BaseRateSchedule brs4 in rs4)
            {
                foreach (BaseRateSchedule brs5 in rs5)
                {
                    if (brs4.Description.Equals(brs5.Description, StringComparison.OrdinalIgnoreCase))
                    {
                        Assert.AreEqual(brs4.EffectiveDate.StartDate.Value.ToShortDateString(), brs5.EffectiveDate.StartDate.Value.ToShortDateString());
                        Assert.AreEqual(brs4.EffectiveDate.EndDate.Value.ToShortDateString(), brs5.EffectiveDate.EndDate.Value.ToShortDateString());
                        Assert.AreEqual(brs4.Description, brs5.Description);
                        Assert.AreEqual(rs5[0].ParameterTableID, rs5[1].ParameterTableID);
                        Assert.AreEqual(rs5[0].ParameterTableName, rs5[1].ParameterTableName);
                        Assert.AreEqual(((IList)brs4.GetValue("RateEntries")).Count, ((IList)brs5.GetValue("RateEntries")).Count);
                    }
                }
            }
         
            #endregion


            plClient.Close();
            poClient.Close();

        }

        [Test]
        [Category("TestGetSharedPriceLists")]
        public void TestGetSharedPriceLists()
        {
            PriceListServiceClient client = new PriceListServiceClient("WSHttpBinding_IPriceListService");
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";


                if (String.IsNullOrEmpty(m_PriceListName))
                {
                    SaveSharedPriceList();

                }

                client.Open();

                MTList<PriceList> priceLists = new MTList<PriceList>();
                priceLists.PageSize = 10;
                priceLists.CurrentPage = 1; 

                client.GetSharedPriceLists(ref priceLists);

                Assert.IsNotNull(priceLists);
                Assert.Greater(priceLists.TotalRows, 1, "pricelists count greater than 1");

                priceLists.Items.ForEach(pl1 => Assert.IsNotNull(pl1.ID, "pricelist not null"));


                MTList<PriceList> priceLists1 = new MTList<PriceList>();
                priceLists1.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, m_PriceListName));


                client.GetSharedPriceLists(ref priceLists1);

                Assert.IsNotNull(priceLists1);
                Assert.AreEqual(1, priceLists1.TotalRows, "GetPriceLists returned more than one record");
                Assert.AreEqual(priceLists1.Items[0].Name, m_PriceListName);

                Assert.IsNotNull(priceLists1.Items[0].ID);
                Assert.IsNotNull(m_PriceListID);
                

                PCIdentifier pl = new PCIdentifier(m_PriceListName);

                PriceList priceList;

                client.GetSharedPriceList(pl, out priceList);

                Assert.IsNotNull(priceList);
                Assert.AreEqual(priceList.Currency, m_PriceList.Currency);
                Assert.IsNotNull(priceList.CurrencyValueDisplayName, "currency value display name is null") ;
                Assert.AreEqual(priceList.Description, m_PriceList.Description);
                Assert.AreEqual(m_PriceListID, priceList.ID);

                Assert.AreEqual(m_PriceList.LocalizedDescriptions.Count, priceList.LocalizedDescriptions.Count);


                var Query = (from KeyValuePair<LanguageCode, string> r in priceList.LocalizedDescriptions
                             from KeyValuePair<LanguageCode, string> s in m_PriceList.LocalizedDescriptions
                             where r.Key == s.Key
                                 && r.Value == s.Value
                             select r).ToList();

                Assert.AreEqual(Query.Count, priceList.LocalizedDescriptions.Count);




                client.Close();

        }

        [Test]
        [Category("SaveSharedPriceList")]
        public void SaveSharedPriceList()
        {
            string GuidHashCode = Guid.NewGuid().GetHashCode().ToString();

            PriceList priceList = new PriceList();
            priceList.Name = string.Format("share pricelist name - {0}", GuidHashCode);
            priceList.Description = string.Format("share pricelist description - {0}", GuidHashCode);
            priceList.Currency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.USD;
            //priceList.CurrencyValueDisplayName = "USD Value Disp Name";
            priceList.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
            priceList.LocalizedDescriptions.Add(LanguageCode.FR, priceList.Description + "{FR}");
            priceList.LocalizedDescriptions.Add(LanguageCode.IT, priceList.Description + "{IT}");
            priceList.LocalizedDescriptions.Add(LanguageCode.US, priceList.Description + "{US}");
            

            PriceListServiceClient client = new PriceListServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            client.SaveSharedPriceList(ref priceList);

            m_PriceListName = priceList.Name;
            m_PriceListID = priceList.ID;

            Assert.IsNotNull(m_PriceListID, "m_PriceListID is null after initial save in SaveSharedPriceList method");

            priceList.Currency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.CAD;
            priceList.Description = "updated " + priceList.Description;
            priceList.LocalizedDescriptions.Add(LanguageCode.DE, priceList.Description + "{DE}");
            priceList.Currency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.CAD;

            client.SaveSharedPriceList(ref priceList);

            m_PriceListName = priceList.Name;
            m_PriceListID = priceList.ID;

            Assert.IsNotNull(m_PriceListID, "m_PriceListID is null in SaveSharedPriceList method");
            Assert.Greater(priceList.Description.IndexOf("updated"),-1);
            Assert.AreEqual(MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.CAD, priceList.Currency);
            Assert.AreEqual(4, priceList.LocalizedDescriptions.Count);

            m_PriceList = priceList;


        }

        [Test]
        [Category("RemoveRateScheduleFromSharedPriceList")]
        public void RemoveRateScheduleFromSharePriceList()
        {
            ProductOfferingServiceClient poClient = new ProductOfferingServiceClient();
            poClient.ClientCredentials.UserName.UserName = "su";
            poClient.ClientCredentials.UserName.Password = "su123";

            ProductOfferingServiceTests potest = new ProductOfferingServiceTests();
            ProductOffering po = potest.SetUpProductOffering();

            poClient.SaveProductOffering(ref po);


            SaveSharedPriceList();

            PriceListServiceClient client = new PriceListServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            AudioConfCallPIInstance accall = po.PriceableItems[0] as AudioConfCallPIInstance;
            int rschedId = accall.AudioConfFeature.Metratech_com_featuresetupcharge_RateSchedules[0].ID.Value;

            client.RemoveRateScheduleFromSharedPriceList(new PCIdentifier(m_PriceListName), rschedId);

        }

        [Test]
        [Category("GetSharedPriceList")]
        public void GetSharedPriceList()
        {
            PriceListServiceClient client = new PriceListServiceClient("WSHttpBinding_IPriceListService");
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                if (String.IsNullOrEmpty(m_PriceListName))
                {
                    SaveSharedPriceList();

                }
                PriceList priceList = null;
                PCIdentifier priceListID = new PCIdentifier(m_PriceListName);

                client.GetSharedPriceList(priceListID, out priceList);
                Assert.IsNotNull(priceList);

                client.Close();
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }

        }

        [Test]
        [Category("GetSharedPriceLists")]
        public void GetSharedPriceLists()
        {
            PriceListServiceClient client = new PriceListServiceClient("WSHttpBinding_IPriceListService");
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                MTList<PriceList> lists = new MTList<PriceList>();
                client.GetSharedPriceLists(ref lists);
                Assert.Greater(lists.Items.Count, 0);

            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }
        }

        [Test]
        [Category("GetPriceListMappingForProductOffering")]
        public void GetPriceListMappingForProductOffering()
        {
            ProductOffering po = null;
            BasePriceableItemInstance pi = null;
            GetPIInstanceForPO(out po, out pi);

            PriceListServiceClient client = new PriceListServiceClient("WSHttpBinding_IPriceListService");
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                PriceListMapping plm = null;

                PCIdentifier poID = new PCIdentifier(po.Name);
                PCIdentifier piID = new PCIdentifier(pi.Name);
                PCIdentifier ptID = new PCIdentifier("metratech.com/mincharge");

                client.GetPriceListMappingForProductOffering(poID, piID, ptID, out plm);
                Assert.IsNotNull(plm);


                client.Close();
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }

        }

        [Test]
        [Category("SavePriceListMappingForProductOffering")]
        public void SavePriceListMappingForProductOffering()
        {
            ProductOffering po = null;
            BasePriceableItemInstance pi = null;
            GetPIInstanceForPO(out po, out pi);

            PriceListServiceClient client = new PriceListServiceClient("WSHttpBinding_IPriceListService");
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            SaveSharedPriceList();

            try
            {
                //Add a new PriceListMapping
                PriceListMapping plm = new PriceListMapping();
                plm.priceListID = m_PriceListID.Value;

                PCIdentifier poID = new PCIdentifier(po.Name);
                PCIdentifier piID = new PCIdentifier(pi.Name);
                PCIdentifier ptID = new PCIdentifier("metratech.com/basetransportrate");

                client.SavePriceListMappingForProductOffering(poID, piID, ptID, ref plm);


                int oldParamTableId = plm.paramTableDefID;

                //Update a PriceListMapping
                ptID = new PCIdentifier("metratech.com/bridgerate");
                client.SavePriceListMappingForProductOffering(poID, piID, ptID, ref plm);

                plm = null;

                client.GetPriceListMappingForProductOffering(poID, piID, ptID, out plm);
                Assert.AreNotEqual(oldParamTableId, plm.paramTableDefID);


                client.Close();
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }
        }


        [Test]
        [Category("GetParamTablesForSubscription")]
        public void GetParamTablesForSubscription()
        {
            CorporateAccount corpAccount = null;
            ProductOffering po = null;
            Subscription sub = null;

            CreateSubscription(out corpAccount, out po, out sub);

            // Get the parameter tables and priceable items
            PriceListServiceClient client = new PriceListServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                List<PriceableItemParamTable> paramTables = new List<PriceableItemParamTable>();
                client.GetParamTablesForSubscription(sub.SubscriptionId.Value, ref paramTables);
                Assert.IsNotEmpty(paramTables);
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }
        }

        [Test]
        [Category("GetRateSchedulesForProductOffering")]
        public void GetRateSchedulesForProductOffering()
        {
            ProductOffering po = null;
            BasePriceableItemInstance bpi = null;
            GetPIInstanceForPO(out po, out bpi);
            Assert.IsNotNull(bpi);

            PriceListServiceClient client = new PriceListServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                List<BaseRateSchedule> rscheds = null;
                client.GetRateSchedulesForProductOffering(new PCIdentifier(po.ProductOfferingId.Value), new PCIdentifier(bpi.ID.Value), new PCIdentifier("metratech.com/mincharge"), out rscheds);
                Assert.Greater(rscheds.Count, 0);
                Assert.Greater(((RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>)rscheds[0]).RateEntries.Count, 0);
                Assert.IsNotNull(((RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>)rscheds[0]).DefaultRateEntry);
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }
        }

        [Test]
        [Category("GetRateSchedulesForSharedPriceList")]
        public void GetRateScheculesForSharedPriceList()
        {
            PriceListServiceClient client = new PriceListServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                /*string GuidHashCode = Guid.NewGuid().GetHashCode().ToString();

                PriceList priceList = new PriceList();
                priceList.Name = string.Format("share pricelist name - {0}", GuidHashCode);
                priceList.Description = string.Format("share pricelist description - {0}", GuidHashCode);
                priceList.Currency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.USD;


                client.SaveSharedPriceList(ref priceList);

                List<BaseRateSchedule> rsched = new List<BaseRateSchedule>();

                client.SaveRateSchedulesForSharedPriceList(new PCIdentifier(priceList.ID.Value), new PCIdentifier("metratech.com/mincharge"), 
                */

                List<BaseRateSchedule> rsched = null;
                client.GetRateSchedulesForSharedPriceList(new PCIdentifier(463), new PCIdentifier("metratech.com/mincharge"), out rsched);
                Assert.IsNotNull(rsched);
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }

        }

        [Test]
        [Category("SubscribeToProductOffering")]
        public void SubscribeToProductOffering()
        {
            CorporateAccount corpAccount = null;
            ProductOffering po = null;
            Subscription sub = null;

            CreateSubscription(out corpAccount, out po, out sub);
            Assert.IsNotNull(sub);
        }

        [Test]
        [Category("UpdateICBRates")]
        public void UpdateICBRates()
        {
            PriceListServiceClient client = new PriceListServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                SavePriceListMappingForProductOffering();
                ProductOffering po = GetProductOffering();
                BasePriceableItemInstance pi = null;
                GetPIInstanceForPO(po, out pi);

                #region	Subscribe to the PO created above

                CorporateAccount corpAcct = null;
                Subscription sub = null;
                po.AvailableTimeSpan = new ProdCatTimeSpan();
                po.AvailableTimeSpan.StartDate = MetraTime.Now;
                po.AvailableTimeSpan.EndDate = MetraTime.Max;
                po.EffectiveTimeSpan.StartDate = MetraTime.Now;
                po.EffectiveTimeSpan.EndDate = MetraTime.Max;

                SaveProductOffering(ref po);

                SubscribeToProductOffering(po, out corpAcct, out sub);

                #endregion

                #region	Update mappings for some parameter tables to allow ICB rates and others to not allow ICB rates

                PriceListMapping plmMinCharge = null;

                PCIdentifier poID = new PCIdentifier(po.Name);
                PCIdentifier piID = new PCIdentifier(pi.Name);
                PCIdentifier ptMinCharge = new PCIdentifier("metratech.com/mincharge");

                client.GetPriceListMappingForProductOffering(poID, piID, ptMinCharge, out plmMinCharge);

                PriceListMapping plmBaseTrasportRate = null;
                PCIdentifier ptBaseTransportRate = new PCIdentifier("metratech.com/basetransportrate");

                client.GetPriceListMappingForProductOffering(poID, piID, ptBaseTransportRate, out plmBaseTrasportRate);

                Assert.AreNotEqual(plmMinCharge.priceListID, plmBaseTrasportRate.priceListID, "Parameter tables specified belong to same price list");

                plmMinCharge.CanICB = true;
                plmBaseTrasportRate.CanICB = false;

                client.SavePriceListMappingForProductOffering(poID, piID, ptMinCharge, ref plmMinCharge);
                client.SavePriceListMappingForProductOffering(poID, piID, ptBaseTransportRate, ref plmBaseTrasportRate);

                #endregion

                #region	Call GetRateSchedulesForSubscription and ensure that no rate schedules are returned

                List<BaseRateSchedule> icbAllowedRateScheds = null;
                client.GetRateSchedulesForSubscription(sub.SubscriptionId.Value, piID, ptMinCharge, out icbAllowedRateScheds);
                Assert.AreEqual(icbAllowedRateScheds.Count, 0, "Rate schedule list is not empty");

                #endregion

                #region	Call SaveRateSchedulesForSubscription for parameter table that allow ICB rates and ensure that rate schedules are saved

                Metratech_com_minchargeRateEntry minimumChargeRateEntry = new Metratech_com_minchargeRateEntry();
                minimumChargeRateEntry.ConfChargeMinimum = 25.00M;
                minimumChargeRateEntry.ConfChargeMinimumApplicBool = true;
                Metratech_com_minchargeDefaultRateEntry minimumChargeDefaultRateEntry = new Metratech_com_minchargeDefaultRateEntry();
                minimumChargeDefaultRateEntry.ConfChargeMinimum = 35.00M;
                RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry> minimumChargeRateSched = new RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>();
                minimumChargeRateSched.RateEntries.Add(minimumChargeRateEntry);
                minimumChargeRateSched.DefaultRateEntry = minimumChargeDefaultRateEntry;
                icbAllowedRateScheds.Add(minimumChargeRateSched);


                client.SaveRateSchedulesForSubscription(sub.SubscriptionId.Value, piID, ptMinCharge, icbAllowedRateScheds);

                icbAllowedRateScheds = null;
                client.GetRateSchedulesForSubscription(sub.SubscriptionId.Value, piID, ptMinCharge, out icbAllowedRateScheds);
                Assert.Greater(icbAllowedRateScheds.Count, 0, "No rates were saved for ICB allowed price list mappings.");

                #endregion

                #region Call SaveRateSchedulesForSubscription for parameter table that do not allow ICB rates and ensure than an error is returned

                bool bCanNotSaveIfICBNotAllowed = false;
                List<BaseRateSchedule> icbNotAllowedRateSchedules = new List<BaseRateSchedule>();
                Metratech_com_basetransportrateRateEntry baseTransportrateRateEntry = new Metratech_com_basetransportrateRateEntry();
                baseTransportrateRateEntry.BaseTransportMinCharge = 10.00M;
                baseTransportrateRateEntry.BaseTransportRate = 5.00M;
                baseTransportrateRateEntry.BaseTransportSetupCharge = 27.95M;
                baseTransportrateRateEntry.Transport = Transport.International;
                baseTransportrateRateEntry.TransportMinUOM = UOM.Minutes;
                baseTransportrateRateEntry.Mode = Mode.Unattended;
                Metratech_com_basetransportrateDefaultRateEntry baseTransportrateDefaultRateEntry = new Metratech_com_basetransportrateDefaultRateEntry();
                baseTransportrateDefaultRateEntry.BaseTransportMinCharge = 3.00M;
                baseTransportrateDefaultRateEntry.BaseTransportRate = 4.00M;
                baseTransportrateDefaultRateEntry.BaseTransportSetupCharge = 15.95M;
                baseTransportrateDefaultRateEntry.TransportMinUOM = UOM.Minutes;
                RateSchedule<Metratech_com_basetransportrateRateEntry, Metratech_com_basetransportrateDefaultRateEntry> baseTransportrateRateSchedule = new RateSchedule<Metratech_com_basetransportrateRateEntry, Metratech_com_basetransportrateDefaultRateEntry>();
                baseTransportrateRateSchedule.DefaultRateEntry = baseTransportrateDefaultRateEntry;
                baseTransportrateRateSchedule.RateEntries.Add(baseTransportrateRateEntry);
                icbNotAllowedRateSchedules.Add(baseTransportrateRateSchedule);


                try
                {
                    client.SaveRateSchedulesForSubscription(sub.SubscriptionId.Value, piID, ptBaseTransportRate, icbNotAllowedRateSchedules);
                }
                catch (Exception)
                {
                    bCanNotSaveIfICBNotAllowed = true;
                }
                Assert.AreEqual(bCanNotSaveIfICBNotAllowed, true, "Rates were saved even though ICB rates were disallowed.");

                #endregion

                #region	For one of the rate schedules successfully saved above, call SaveRateSchedulesForSubscription to update existing and add new rate schedules
                icbAllowedRateScheds = new List<BaseRateSchedule>();

                // Update existing rate schedule
                minimumChargeRateEntry = new Metratech_com_minchargeRateEntry();
                minimumChargeRateEntry.ConfChargeMinimum = 23.00M;
                minimumChargeRateEntry.ConfChargeMinimumApplicBool = true;
                minimumChargeDefaultRateEntry = new Metratech_com_minchargeDefaultRateEntry();
                minimumChargeDefaultRateEntry.ConfChargeMinimum = 33.00M;
                minimumChargeRateSched = new RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>();
                minimumChargeRateSched.RateEntries.Add(minimumChargeRateEntry);
                minimumChargeRateSched.DefaultRateEntry = minimumChargeDefaultRateEntry;
                minimumChargeRateSched.EffectiveDate = new ProdCatTimeSpan();
                minimumChargeRateSched.EffectiveDate.StartDate = MetraTime.Now;
                minimumChargeRateSched.EffectiveDate.EndDate = MetraTime.Now + TimeSpan.FromDays(90);
                minimumChargeRateSched.EffectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
                minimumChargeRateSched.EffectiveDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
                icbAllowedRateScheds.Add(minimumChargeRateSched);

                // Add another rate schedule
                Metratech_com_minchargeRateEntry minimumChargeRateEntry2 = new Metratech_com_minchargeRateEntry();
                minimumChargeRateEntry2.ConfChargeMinimum = 27.00M;
                minimumChargeRateEntry2.ConfChargeMinimumApplicBool = true;
                Metratech_com_minchargeDefaultRateEntry minimumChargeDefaultRateEntry2 = new Metratech_com_minchargeDefaultRateEntry();
                minimumChargeDefaultRateEntry2.ConfChargeMinimum = 37.00M;
                RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry> minimumChargeRateSched2 = new RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>();
                minimumChargeRateSched2.RateEntries.Add(minimumChargeRateEntry2);
                minimumChargeRateSched2.DefaultRateEntry = minimumChargeDefaultRateEntry2;
                minimumChargeRateSched2.EffectiveDate = new ProdCatTimeSpan();
                minimumChargeRateSched2.EffectiveDate.StartDate = MetraTime.Now + TimeSpan.FromDays(91);
                minimumChargeRateSched2.EffectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
                icbAllowedRateScheds.Add(minimumChargeRateSched2);


                client.SaveRateSchedulesForSubscription(sub.SubscriptionId.Value, piID, ptMinCharge, icbAllowedRateScheds);

                icbAllowedRateScheds = null;
                client.GetRateSchedulesForSubscription(sub.SubscriptionId.Value, piID, ptMinCharge, out icbAllowedRateScheds);
                Assert.AreEqual(icbAllowedRateScheds.Count, 2);
                minimumChargeRateSched = null;
                bool bSuccess = false;
                decimal charge1 = ((RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>)icbAllowedRateScheds[0]).RateEntries[0].ConfChargeMinimum.Value;
                decimal charge2 = ((RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>)icbAllowedRateScheds[1]).RateEntries[0].ConfChargeMinimum.Value;
                if ((charge1 == 27.00M && charge2 == 23.00M) || (charge1 == 23.00M && charge2 == 27.00M))
                {
                    bSuccess = true;
                }
                Assert.AreEqual(bSuccess, true, "Rate schedule updates failed.");

                #endregion

                #region Remove rate schedules

                client.RemoveRateScheduleFromSubscription(sub.SubscriptionId.Value, icbAllowedRateScheds[1].ID.Value);

                client.GetRateSchedulesForSubscription(sub.SubscriptionId.Value, piID, ptMinCharge, out icbAllowedRateScheds);
                Assert.AreEqual(icbAllowedRateScheds.Count, 1, "Failed to remove rate schedules");

                #endregion

                client.Close();
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }

        }

        #endregion

    }
}