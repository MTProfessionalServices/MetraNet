using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;
using System.Xml.Xsl;
using MetraTech.ForeignExchange;
using MetraTech.UsageServer.Adapters;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace TestForeignExchange
{
    [TestClass]
    public class XeTests
    {
        [TestMethod]
        public void TestConfig()
        {
            var provider = new XeForeignExchangeRateProvider();

            using (
                var stringReader =
                    new StringReader(
                        @"<ProviderConfig><CurrencyConfig><BaseCurrency>USD</BaseCurrency><URL>http://www.xe.com/dfs/sample-usd.xml</URL><FileNameFormat>D:\xyz\usd.xml</FileNameFormat></CurrencyConfig><CurrencyConfig><BaseCurrency>GBP</BaseCurrency><URL>http://www.xe.com/dfs/sample-gbp.xml</URL><FileNameFormat>D:\xyz\gbp.xml</FileNameFormat></CurrencyConfig></ProviderConfig>")
                )
            {
                using (var xmlReader = new XmlTextReader(stringReader))
                {
                    while (xmlReader.Read() && xmlReader.NodeType != XmlNodeType.Element &&
                           !xmlReader.Name.Equals("ProviderConfig"))
                    {
                    }
                    provider.Init(xmlReader);
                }
            }
            /*
            List<string> baseCurrencies;
            var rates = xe.GetExchangeRates(Convert.ToDateTime("04/27/2008 21:00:00"), (MetraTech.UsageServer.IRecurringEventRunContext)null, out baseCurrencies);
            foreach (var rate in rates)
            {
                System.Console.WriteLine("Exchange rate from {0} to {1} of type {2} is {3}", rate.BaseCurrency, rate.Currency, rate.Type, rate.Rate);
            }
            MetraTech.Adapters.ForeignExchangeRate.ExchangeRateManager.CalculateInverseRates(rates);
            MetraTech.Adapters.ForeignExchangeRate.ExchangeRateManager.AddInverseRates(rates, baseCurrencies);
            MetraTech.Adapters.ForeignExchangeRate.ExchangeRateManager.AddIdentityRates(rates, baseCurrencies);
            MetraTech.Adapters.ForeignExchangeRate.ExchangeRateManager.AddCrossRates(rates, baseCurrencies, "USD");
            MetraTech.Adapters.ForeignExchangeRate.ExchangeRateManager.AddCalculatedRates(rates, baseCurrencies, "USD");
            MetraTech.Adapters.ForeignExchangeRate.ExchangeRateManager.FilterRates(rates, null);
            MetraTech.Adapters.ForeignExchangeRate.ExchangeRateManager.ValidateRates(rates);
            System.Console.WriteLine("After Mods");
            foreach (var rate in rates)
            {
                System.Console.WriteLine("{0} to {1} {4}of type {2} is {3}{5}", rate.BaseCurrency, rate.Currency, rate.Type, rate.Rate, rate.CrossCurrencyEnum.HasValue ? ("via " + rate.CrossCurrency + " ") : "", rate.CrossCurrencyEnum.HasValue ? (" " + rate.CrossRate) : "");
            }
             * */
        }

        [TestMethod]
        public void TestDownloadUsd()
        {
            var provider = new XeForeignExchangeRateProvider();

            try
            {
                File.Delete(@"O:\xyz\usd.xml");
            }
            catch
            {
            }
            using (
                var stringReader =
                    new StringReader(
                        @"<ProviderConfig><CurrencyConfig><BaseCurrency>USD</BaseCurrency><URL>http://www.xe.com/dfs/sample-usd.xml</URL><FileNameFormat>O:\xyz\usd.xml</FileNameFormat></CurrencyConfig></ProviderConfig>")
                )
            {
                using (var xmlReader = new XmlTextReader(stringReader))
                {
                    while (xmlReader.Read() && xmlReader.NodeType != XmlNodeType.Element &&
                           !xmlReader.Name.Equals("ProviderConfig"))
                    {
                    }
                    provider.Init(xmlReader);
                }
            }
            List<string> baseCurrencies;
            List<ExchangeRateDetails> rates = provider.GetExchangeRates(Convert.ToDateTime("04/27/2008 21:00:00"),
                                                                        null, out baseCurrencies);
            if (!File.Exists(@"O:\xyz\usd.xml"))
            {
                throw new Exception("Did not download file...");
            }
            foreach (ExchangeRateDetails rate in rates)
            {
                Console.WriteLine("Exchange rate from {0} to {1} of type {2} is {3}", rate.BaseCurrency, rate.Currency,
                                  rate.Type, rate.Rate);
            }
        }

        [TestMethod]
        public void TestProxyConfig()
        {
            var provider = new XeForeignExchangeRateProvider();

            using (
                var stringReader =
                    new StringReader(
                        @"<ProviderConfig><CurrencyConfig><BaseCurrency>USD</BaseCurrency><URL>http://www.xe.com/dfs/sample-usd.xml</URL><FileNameFormat>D:\xyz\usd.xml</FileNameFormat></CurrencyConfig><CurrencyConfig><BaseCurrency>GBP</BaseCurrency><URL>http://www.xe.com/dfs/sample-gbp.xml</URL><FileNameFormat>D:\xyz\gbp.xml</FileNameFormat><Proxy><Address>http://192.168.0.1</Address><Credentials><UserName>aknowles</UserName><Password encrypted=""true"">cbb23d8d-8189-4039-a575-a7388c369d99Tiwu7gtSCe1iUiB0sRcLpM1OdX2LOlY/hokZvOCqg8s=</Password></Credentials></Proxy></CurrencyConfig></ProviderConfig>")
                )
            {
                using (var xmlReader = new XmlTextReader(stringReader))
                {
                    while (xmlReader.Read() && xmlReader.NodeType != XmlNodeType.Element &&
                           !xmlReader.Name.Equals("ProviderConfig"))
                    {
                    }
                    provider.Init(xmlReader);
                }
            }
        }

    }
}