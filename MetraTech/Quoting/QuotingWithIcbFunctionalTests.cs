using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTProductCatalog;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.Shared.Test;

namespace MetraTech.Quoting.Test
{
    [TestClass]
    public class QuotingWithIcbFunctionalTests
    {
        #region Setup/Teardown

        [ClassInitialize]
        public static void InitTests(TestContext testContext)
        {
            SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
            SharedTestCode.MakeSureServiceIsStarted("Pipeline");
        }

        #endregion

        [TestMethod]
        [TestCategory("FunctionalTest")]
        public void QuotingWithIcbPricePositiveTest()
        {
            #region Prepare

            const string testName = "Quote_Basic";
            const string testShortName = "Q_Basic";
            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
            string testRunUniqueIdentifier = MetraTime.Now.ToString(CultureInfo.InvariantCulture); //Identifier to make this run unique

            // Create account
            var corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
            corpAccountHolder.Instantiate();

            var idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

            // Create/Verify Product Offering Exists
            var pofConfiguration = new ProductOfferingFactoryConfiguration(testName, testRunUniqueIdentifier);
            pofConfiguration.CountNRCs = 1;
            pofConfiguration.CountPairRCs = 1;
            pofConfiguration.CountPairUDRCs = 1;

            //IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
            var productOffering = ProductOfferingFactory.Create(pofConfiguration);
            int idProductOfferingToQuoteFor = productOffering.ID;

            using (var client = new PriceListServiceClient())
            {
                if (client.ClientCredentials != null)
                {
                    client.ClientCredentials.UserName.UserName = "su";
                    client.ClientCredentials.UserName.Password = "su123";
                }

                IMTCollection instances = productOffering.GetPriceableItems();

                ProductOfferingFactory productOfferingFactory = new ProductOfferingFactory();
                productOfferingFactory.Initialize(testName, testRunUniqueIdentifier);

                var parameterTableFlatRc =
                    productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(
                        "metratech.com/flatrecurringcharge");
                var parameterTableNonRc =
                    productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(
                        "metratech.com/nonrecurringcharge");
                var parameterTableUdrcTapered = productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName("metratech.com/udrctapered");
                var parameterTableUdrcTiered = productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName("metratech.com/udrctiered");


                PriceListMapping plMappingForRc, plMappingForNonRc, plMappingForUdrc;

                foreach (IMTPriceableItem possibleRC in instances)
                {
                    if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
                    {
                        IMTRecurringCharge udrcTapered = (IMTRecurringCharge)possibleRC;
                        client.GetPriceListMappingForProductOffering(
                            new PCIdentifier(productOffering.ID),
                            new PCIdentifier(udrcTapered.ID),
                            new PCIdentifier(parameterTableUdrcTapered.ID),
                            out plMappingForUdrc);
                        plMappingForUdrc.CanICB = true;
                        client.SavePriceListMappingForProductOffering
                            (new PCIdentifier(productOffering.ID),
                             new PCIdentifier(udrcTapered.ID),
                             new PCIdentifier(parameterTableUdrcTapered.ID),
                             ref plMappingForUdrc);

                        var piAndPTParameters = new PIAndPTParameters
                        {
                            ParameterTableId = parameterTableUdrcTapered.ID,
                            ParameterTableName = "metratech.com/udrctapered",
                            PriceableItemId = udrcTapered.ID
                        };
                        pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);

                        IMTRecurringCharge udrcTiered = (IMTRecurringCharge)possibleRC;
                        client.GetPriceListMappingForProductOffering(
                            new PCIdentifier(productOffering.ID),
                            new PCIdentifier(udrcTiered.ID),
                            new PCIdentifier(parameterTableUdrcTiered.ID),
                            out plMappingForUdrc);
                        plMappingForUdrc.CanICB = true;
                        client.SavePriceListMappingForProductOffering
                            (new PCIdentifier(productOffering.ID),
                             new PCIdentifier(udrcTiered.ID),
                             new PCIdentifier(parameterTableUdrcTiered.ID),
                             ref plMappingForUdrc);

                        piAndPTParameters = new PIAndPTParameters
                        {
                            ParameterTableId = parameterTableUdrcTiered.ID,
                            ParameterTableName = "metratech.com/udrctiered",
                            PriceableItemId = udrcTiered.ID
                        };
                        pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);
                    }
                    else if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING)
                    {
                        IMTRecurringCharge rc = (IMTRecurringCharge)possibleRC;
                        client.GetPriceListMappingForProductOffering(
                            new PCIdentifier(productOffering.ID),
                            new PCIdentifier(rc.ID),
                            new PCIdentifier(parameterTableFlatRc.ID),
                            out plMappingForUdrc);
                        plMappingForUdrc.CanICB = true;
                        client.SavePriceListMappingForProductOffering
                            (new PCIdentifier(productOffering.ID),
                             new PCIdentifier(rc.ID),
                             new PCIdentifier(parameterTableFlatRc.ID),
                             ref plMappingForUdrc);

                        var piAndPTParameters = new PIAndPTParameters
                        {
                            ParameterTableId = parameterTableFlatRc.ID,
                            ParameterTableName = "metratech.com/flatrecurringcharge",
                            PriceableItemId = rc.ID
                        };
                        pofConfiguration.PriceableItemsAndParameterTableForRc.Add(piAndPTParameters);

                    }
                    else if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_NON_RECURRING)
                    {
                        IMTNonRecurringCharge nonrc = (IMTNonRecurringCharge)possibleRC;

                        client.GetPriceListMappingForProductOffering(
                            new PCIdentifier(productOffering.ID),
                            new PCIdentifier(nonrc.ID),
                            new PCIdentifier(parameterTableNonRc.ID),
                            out plMappingForNonRc);
                        plMappingForNonRc.CanICB = true;
                        client.SavePriceListMappingForProductOffering
                            (new PCIdentifier(productOffering.ID),
                             new PCIdentifier(nonrc.ID),
                             new PCIdentifier(parameterTableNonRc.ID),
                             ref plMappingForNonRc);

                        var piAndPTParameters = new PIAndPTParameters
                        {
                            ParameterTableId = parameterTableNonRc.ID,
                            ParameterTableName = "metratech.com/nonrecurringcharge",
                            PriceableItemId = nonrc.ID
                        };
                        pofConfiguration.PriceableItemsAndParameterTableForNonRc.Add(piAndPTParameters);
                    }
                }
            }

            //Values to use for verification
            string expectedQuoteCurrency = "USD";

            #endregion

            #region Test

            // Ask backend to start quote

            //Prepare request
            QuoteRequest request = new QuoteRequest();
            request.Accounts.Add(idAccountToQuoteFor);
            request.ProductOfferings.Add(idProductOfferingToQuoteFor);
            request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
            request.QuoteDescription = "Quote generated by Automated Test: " + testName;
            request.ReportParameters = new ReportParams()
            {
                PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
            };
            request.EffectiveDate = MetraTime.Now;
            request.EffectiveEndDate = MetraTime.Now;
            request.Localization = "en-US";
            request.SubscriptionParameters.UDRCValues =
                SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering);

            int numOfAccounts = request.Accounts.Count;
            int expectedQuoteNRCsCount = pofConfiguration.CountNRCs * numOfAccounts;
            int expectedQuoteFlatRCsCount = pofConfiguration.CountPairRCs +
                                            (pofConfiguration.CountPairRCs * numOfAccounts);
            int expectedQuoteUDRCsCount = pofConfiguration.CountPairUDRCs +
                                          (pofConfiguration.CountPairUDRCs * numOfAccounts);

            pofConfiguration.RCAmount = 66.66m;
            pofConfiguration.NRCAmount = 77.77m;
            decimal totalAmountForUDRC = 15 * 16.6m + 5 * 13m;

            decimal expectedQuoteTotal = (expectedQuoteFlatRCsCount * pofConfiguration.RCAmount) +
                                         (expectedQuoteUDRCsCount * totalAmountForUDRC) +
                                         (expectedQuoteNRCsCount * pofConfiguration.NRCAmount);

            #region Initialize ICB prices

            var quoteId = DateTime.Now.Millisecond;

            request.IcbPrices = new List<QuoteIndividualPrice>();
            foreach (var ptrc in pofConfiguration.PriceableItemsAndParameterTableForRc)
            {
                var qip = new QuoteIndividualPrice
                {
                    QuoteId = quoteId,
                    ParameterTableId = ptrc.ParameterTableId,
                    PriceableItemInstanceId = ptrc.PriceableItemId,
                    ProductOfferingId = productOffering.ID,
                    RateSchedules = new List<BaseRateSchedule> { GetFlatRcRateSchedule(66.66m) }
                };
                request.IcbPrices.Add(qip);
            }

            foreach (var ptUDRC in pofConfiguration.PriceableItemsAndParameterTableForUdrc)
            {
                var qip = new QuoteIndividualPrice
                {
                    QuoteId = quoteId,
                    ParameterTableId = ptUDRC.ParameterTableId,
                    PriceableItemInstanceId = ptUDRC.PriceableItemId,
                    ProductOfferingId = productOffering.ID
                };

                if (ptUDRC.ParameterTableName == "metratech.com/udrctapered")
                {
                    qip.RateSchedules = new List<BaseRateSchedule>
                        {
                            GetTaperedUdrcRateSchedule(new Dictionary<decimal, decimal>
                                {
                                    {15, 16.6m},
                                    {40, 13m}
                                })
                        };
                }
                else
                {
                    qip.RateSchedules = new List<BaseRateSchedule>
                        {
                            GetTieredUdrcRateSchedule(20, 16.6m, 10m)
                        };
                }

                request.IcbPrices.Add(qip);
            }

            foreach (var ptNRC in pofConfiguration.PriceableItemsAndParameterTableForNonRc)
            {
                var qip = new QuoteIndividualPrice
                {
                    QuoteId = quoteId,
                    ParameterTableId = ptNRC.ParameterTableId,
                    PriceableItemInstanceId = ptNRC.PriceableItemId,
                    ProductOfferingId = productOffering.ID,
                    RateSchedules = new List<BaseRateSchedule> { GetNonRcRateSchedule(77.77m) }
                };
                request.IcbPrices.Add(qip);
            }

            #endregion

            //Give request to testing scenario along with expected results for verification; get back response for further verification
            QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                      expectedQuoteTotal,
                                                                                      expectedQuoteCurrency,
                                                                                      expectedQuoteFlatRCsCount,
                                                                                      expectedQuoteNRCsCount,
                                                                                      expectedQuoteUDRCsCount);


            #endregion

        }

        #region Helpers


        private static BaseRateSchedule GetFlatRcRateSchedule(decimal price)
        {
            return new RateSchedule<Metratech_com_FlatRecurringChargeRateEntry, Metratech_com_FlatRecurringChargeDefaultRateEntry>
            {
                EffectiveDate = new ProdCatTimeSpan
                {
                    StartDate = DateTime.Parse("1/1/2000"),
                    StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
                    EndDate = DateTime.Parse("1/1/2038"),
                    EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
                },
                /*
                    sched.EffectiveDate.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
        sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
        sched.EffectiveDate.EndDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
        sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
                    */
                RateEntries = new List<Metratech_com_FlatRecurringChargeRateEntry>
           {
              new Metratech_com_FlatRecurringChargeRateEntry { RCAmount = price }
           }
            };
        }

        private static BaseRateSchedule GetNonRcRateSchedule(decimal price)
        {
            return new RateSchedule<Metratech_com_NonRecurringChargeRateEntry, Metratech_com_NonRecurringChargeDefaultRateEntry>
            {
                EffectiveDate = new ProdCatTimeSpan
                {
                    StartDate = MetraTime.Now,
                    StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
                    EndDate = MetraTime.Now.AddHours(1),
                    EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
                },
                RateEntries = new List<Metratech_com_NonRecurringChargeRateEntry>
           {
              new Metratech_com_NonRecurringChargeRateEntry { NRCAmount = price }
           }
            };
        }

        private static BaseRateSchedule GetTaperedUdrcRateSchedule(Dictionary<decimal, decimal> unitValuesAndAmounts)
        {
            var rates = new List<Metratech_com_UDRCTaperedRateEntry>();
            var i = 0;
            foreach (var val in unitValuesAndAmounts)
            {
                rates.Add(new Metratech_com_UDRCTaperedRateEntry
                {
                    Index = i,
                    UnitValue = val.Key,
                    UnitAmount = val.Value
                });
                i++;
            }

            return new RateSchedule<Metratech_com_UDRCTaperedRateEntry, Metratech_com_UDRCTaperedDefaultRateEntry>
            {
                EffectiveDate = new ProdCatTimeSpan
                {
                    StartDate = DateTime.Parse("1/1/2000"),
                    StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
                    EndDate = DateTime.Parse("1/1/2038"),
                    EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
                },
                RateEntries = rates
            };
        }

        private static BaseRateSchedule GetTieredUdrcRateSchedule(decimal unitValue, decimal unitAmount, decimal baseAmount)
        {
            var rates = new List<Metratech_com_UDRCTieredRateEntry>();
            var i = 0;
            rates.Add(new Metratech_com_UDRCTieredRateEntry
            {
                Index = i,
                UnitValue = unitValue,
                UnitAmount = unitAmount,
                BaseAmount = baseAmount
            });

            return new RateSchedule<Metratech_com_UDRCTieredRateEntry, Metratech_com_UDRCTieredDefaultRateEntry>
            {
                EffectiveDate = new ProdCatTimeSpan
                {
                    StartDate = DateTime.Parse("1/1/2000"),
                    StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
                    EndDate = DateTime.Parse("1/1/2038"),
                    EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
                },
                RateEntries = rates
            };
        }

        #endregion

    }
}
