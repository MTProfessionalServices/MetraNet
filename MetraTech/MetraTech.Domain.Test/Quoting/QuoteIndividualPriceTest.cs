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
            var price = new QuoteIndividualPrice { ChargesRates = PrepareSampleChargesRates() };
            // The sample XML string was received as result of serialization of the list of the prices 
            // which is used in the UpdateICBRates functional  test.
            // C:\dev\MetraNet\RMP\Extensions\FunctionalTests_Internal\MetraNet_LegacySmokesTests\Core\Services\PriceListService.Tests.cs
            var expectedResult = Properties.Resources.SampleRateSchedules_txt;
            //Assert.AreEqual(expectedResult, price.ChargesRatesXml);
        }

        [TestMethod]
        [TestCategory(UnitTestCategory)]
        public void RateSchedulesXmlWithStringIsDeserializedToObjectsPositiveTest()
        {
            // The sample XML string was received as result of serialization of the list of the prices
            // which is used in the UpdateICBRates functional  test.
            // C:\dev\MetraNet\RMP\Extensions\FunctionalTests_Internal\MetraNet_LegacySmokesTests\Core\Services\PriceListService.Tests.cs
            /*var stringOfRates = Properties.Resources.SampleRateSchedules_txt;
            var price = new QuoteIndividualPrice { ChargesRatesXml = stringOfRates };
            var expectedRates = PrepareSampleRates();

            Assert.IsNotNull(price.ChargesRates);
            Assert.AreEqual(expectedRates.Count, price.ChargesRates.Count);
            for (var i = 0; i < expectedRates.Count; i++)
            {
                var expRate = (RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>)expectedRates[i];
                var actRate = (RateSchedule<Metratech_com_minchargeRateEntry, Metratech_com_minchargeDefaultRateEntry>)price.ChargesRates[i];
                CompareProductCatalogTimeSpan(expRate.EffectiveDate, actRate.EffectiveDate);
                Assert.AreEqual(expRate.RateEntries.Single().ConfChargeMinimum,
                                actRate.RateEntries.Single().ConfChargeMinimum);
                Assert.AreEqual(expRate.DefaultRateEntry.ConfChargeMinimum,
                                actRate.DefaultRateEntry.ConfChargeMinimum);
            }*/
        }

        [TestMethod]
        [TestCategory(UnitTestCategory)]
        public void RateSchedulesXmlWithIncorrectStringNegativeTest()
        {
            var price = new QuoteIndividualPrice();
            //ExceptionAssert.ExpectedExactly<SerializationException>(() => price.RateSchedulesXml = "<SomeIncorrectXmlString>");
        }

        #region Helper methods

        /// <summary>
        /// Compare QuoteIndividualPrice objects property by property
        /// </summary>
        /// <param name="expected">Expected quote individual prie</param>
        /// <param name="actual">Actual quote individual price</param>
        public static void CompareQuoteIndividualPrice(QuoteIndividualPrice expected, QuoteIndividualPrice actual)
        {
            Assert.AreEqual(expected.Id, actual.Id);
            Assert.AreEqual(expected.QuoteId, actual.QuoteId);
            Assert.AreEqual(expected.ProductOfferingId, actual.ProductOfferingId);
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
        public static List<ChargesRate> PrepareSampleChargesRates()
        {
            var rates = new List<ChargesRate>();

            var chargeRateRC = new ChargesRate { Price = 66.66m };
            var chargeRateUDRCTapered1 = new ChargesRate {UnitValue = 15, UnitAmount = 16.6m};
            var chargeRateUDRCTapered2 = new ChargesRate {UnitValue = 40, UnitAmount = 13m};
            var chargeRateUDRCTiered = new ChargesRate { UnitValue = 20, UnitAmount = 16.6m, BaseAmount = 10m };

            rates.Add(chargeRateRC);
            rates.Add(chargeRateUDRCTapered1);
            rates.Add(chargeRateUDRCTapered2);
            rates.Add(chargeRateUDRCTiered);

            return rates;
        }

        #endregion
    }
}
