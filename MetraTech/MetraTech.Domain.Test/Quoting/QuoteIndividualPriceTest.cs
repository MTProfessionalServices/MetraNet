using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Runtime.Serialization;

namespace MetraTech.Domain.Test.Quoting
{
    [TestClass]
    public class QuoteIndividualPriceTest
    {
        private const string UnitTestCategory = "UnitTest";
        
        [TestMethod]
        [TestCategory(UnitTestCategory)]
        public void RateScheduleslWithObjectsIsSerializedToStringPositiveTest()
        {
            var price = new QuoteIndividualPrice { RateSchedules = PrepareSamplpeRates() };
            // The sample XML string was received as result of serialization of the list of the prices 
            // which is used in the UpdateICBRates functional  test.
            // C:\dev\MetraNet\RMP\Extensions\FunctionalTests_Internal\MetraNet_LegacySmokesTests\Core\Services\PriceListService.Tests.cs
            var expectedResult = Properties.Resources.SampleRateSchedules_txt;
            Assert.AreEqual(expectedResult, price.RateSchedulesXml);
        }

        [TestMethod]
        [TestCategory(UnitTestCategory)]
        public void RateSchedulesXmlWithStringIsDeserializedToObjectsPositiveTest()
        {
            // The sample XML string was received as result of serialization of the list of the prices
            // which is used in the UpdateICBRates functional  test.
            // C:\dev\MetraNet\RMP\Extensions\FunctionalTests_Internal\MetraNet_LegacySmokesTests\Core\Services\PriceListService.Tests.cs
            var stringOfRates = Properties.Resources.SampleRateSchedules_txt;
            var price = new QuoteIndividualPrice { RateSchedulesXml = stringOfRates };
            var expectedRates = PrepareSamplpeRates();

            Assert.IsNotNull(price.RateSchedules);
            Assert.AreEqual(expectedRates.Count, price.RateSchedules.Count);
            for (var i = 0; i < expectedRates.Count; i++)
            {
                var expRate = (RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>)expectedRates[i];
                var actRate = (RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>)price.RateSchedules[i];
                CompareProductCatalogTimeSpan(expRate.EffectiveDate, actRate.EffectiveDate);
                Assert.AreEqual(expRate.RateEntries.Single().ConfChargeMinimum,
                                actRate.RateEntries.Single().ConfChargeMinimum);
                Assert.AreEqual(expRate.DefaultRateEntry.ConfChargeMinimum,
                                actRate.DefaultRateEntry.ConfChargeMinimum);
            }
        }

        [TestMethod]
        [TestCategory(UnitTestCategory)]
        public void RateSchedulesXmlWithIncorrectStringNegativeTest()
        {
            var price = new QuoteIndividualPrice();
            ExceptionAssert.ExpectedExactly<SerializationException>(() => price.RateSchedulesXml = "<SomeIncorrectXmlString>");
        }

        [TestMethod]
        [TestCategory(UnitTestCategory)]
        public void RateSchedulesWithNullPositiveTest()
        {
            var price = new QuoteIndividualPrice { RateSchedules = null };
            Assert.IsNull(price.RateSchedulesXml);
        }

        [TestMethod]
        [TestCategory(UnitTestCategory)]
        public void RateSchedulesXmlWithNullPositiveTest()
        {
            var price = new QuoteIndividualPrice { RateSchedulesXml = null };
            Assert.IsNull(price.RateSchedules);
        }

        #region Helper methods

        /// <summary>
        /// Compare QuoteIndividualPrice objects property by property
        /// </summary>
        /// <param name="expected">Expected quote individual prie</param>
        /// <param name="actual">Actual quote individual price</param>
        private static void CompareQuoteIndividualPrice(QuoteIndividualPrice expected, QuoteIndividualPrice actual)
        {
            Assert.AreEqual(expected.Id, actual.Id);
            Assert.AreEqual(expected.QuoteId, actual.QuoteId);
            Assert.AreEqual(expected.ProductOfferingId, actual.ProductOfferingId);
            Assert.AreEqual(expected.PriceableItemInstanceId, actual.PriceableItemInstanceId);
            Assert.AreEqual(expected.ParameterTableId, actual.ParameterTableId);
            Assert.AreEqual(expected.RateSchedulesXml, actual.RateSchedulesXml);
        }

        /// <summary>
        /// Compare ProdCatTimeSpan objects
        /// </summary>
        /// <param name="expected">Expected time span</param>
        /// <param name="actual">Actual time span</param>
        private static void CompareProductCatalogTimeSpan(ProdCatTimeSpan expected, ProdCatTimeSpan actual)
        {
            Assert.AreEqual(expected.TimeSpanId, actual.TimeSpanId);
            Assert.AreEqual(expected.StartDate, actual.StartDate);
            Assert.AreEqual(expected.StartDateOffset, actual.StartDateOffset);
            Assert.AreEqual(expected.StartDateType, actual.StartDateType);
            Assert.AreEqual(expected.EndDate, actual.EndDate);
            Assert.AreEqual(expected.EndDateOffset, actual.EndDateOffset);
            Assert.AreEqual(expected.EndDateType, actual.EndDateType);
        }

        /// <summary>
        /// Prepare sample of rate schedules
        /// </summary>
        /// <returns>List of sample rate schedules</returns>
        private static List<BaseRateSchedule> PrepareSamplpeRates()
        {
            var rates = new List<BaseRateSchedule>();

            var julyRateEntry = new RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>
                {
                    EffectiveDate = new ProdCatTimeSpan
                        {
                            StartDate = new DateTime(2013, 07, 01),
                            StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
                            EndDate = new DateTime(2013, 07, 31),
                            EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
                        },
                    RateEntries = new List<Metratech_com_minchargeRateEntry>
                        {
                            new Metratech_com_minchargeRateEntry
                                {
                                    ConfChargeMinimumApplicBool = true,
                                    ConfChargeMinimum = 23.00m
                                }
                        },
                    DefaultRateEntry = new Metratech_com_minchargeDefaultRateEntry
                        {
                            ConfChargeMinimum = 33.00m
                        }
                };
            var septemberRateEntry = new RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>
            {
                EffectiveDate = new ProdCatTimeSpan
                {
                    StartDate = new DateTime(2013, 08, 01),
                    StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
                    EndDate = null
                },
                RateEntries = new List<Metratech_com_minchargeRateEntry>
                        {
                            new Metratech_com_minchargeRateEntry
                                {
                                    ConfChargeMinimumApplicBool = true,
                                    ConfChargeMinimum = 27.00m
                                }
                        },
                DefaultRateEntry = new Metratech_com_minchargeDefaultRateEntry
                {
                    ConfChargeMinimum = 37.00m
                }
            };

            rates.Add(julyRateEntry);
            rates.Add(septemberRateEntry);

            return rates;
        }

        #endregion
    }
}
