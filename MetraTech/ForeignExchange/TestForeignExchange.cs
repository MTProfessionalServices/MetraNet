using System;
using System.Collections.Generic;
using System.IO;
using System.ServiceModel;
using System.Xml;
using MetraTech.Account.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ForeignExchange;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ForeignExchange
{
    [TestClass]
    public class TestForeignExchange
    {
        #region Setup/Teardown

        [TestInitialize]
        public void EnsurePricelists()
        {
            PriceList pricelist;
            BasePriceableItemTemplate template;
            using (var client = new ProductCatalogServiceClient())
            {
                if (client.ClientCredentials != null)
                {
                    client.ClientCredentials.UserName.UserName = @"su";
                    client.ClientCredentials.UserName.Password = @"su123";
                }

                try
                {
                    client.GetPriceableItemTemplate(new PCIdentifier(@"Currency Conversion"), out template);
                }
                catch (FaultException<MASBasicFaultDetail> exception)
                {
                    Assert.AreEqual(@"Error retrieving priceable item template.",
                                    exception.Detail.ErrorMessages[0]);
                    template = null;
                }
                if (template == null)
                {
                    throw new Exception("Unable to find template");
                }
            }
            using (var client = new PriceListServiceClient())
            {
                if (client.ClientCredentials != null)
                {
                    client.ClientCredentials.UserName.UserName = @"su";
                    client.ClientCredentials.UserName.Password = @"su123";
                }

                try
                {
                    client.GetSharedPriceList(new PCIdentifier(@"Currency Exchange Pricelist"), out pricelist);
                }
                catch (FaultException<MASBasicFaultDetail> exception)
                {
                    Assert.AreEqual(@"Error while getting shared price list",
                                    exception.Detail.ErrorMessages[0]);
                    pricelist = null;
                }
                if (pricelist == null)
                {
                    var idPt = new PCIdentifier(
                        ForeignExchangeRateManager.GetIdParamtableByName(
                            @"t_pt_CurrencyExchangeRates"));
                    pricelist = new PriceList
                                    {
                                        Currency = SystemCurrencies.USD,
                                        Description = @"Currency Exchange Pricelist",
                                        Name = @"Currency Exchange Pricelist",
                                        ParameterTables = new List<PCIdentifier>
                                                              {
                                                                  idPt
                                                              }
                                    };
                    var scheds = new List<BaseRateSchedule>();
                    var sched =
                        new RateSchedule
                            <Metratech_com_CurrencyExchangeRatesRateEntry,
                                Metratech_com_CurrencyExchangeRatesDefaultRateEntry
                                >
                            {
                                EffectiveDate = new ProdCatTimeSpan
                                                    {
                                                        EndDateType = ProdCatTimeSpan.MTPCDateType.Null,
                                                        StartDateType = ProdCatTimeSpan.MTPCDateType.Null
                                                    }
                            };
                    scheds.Add(sched);
                    if (pricelist.ID != null && template.ID != null)
                    {
                        client.SaveRateSchedulesForSharedPriceList(new PCIdentifier(pricelist.ID.Value),
                                                                   new PCIdentifier(template.ID.Value), idPt, scheds);
                    }

                    try
                    {
                        client.SaveSharedPriceList(ref pricelist);
                    }
                    catch (FaultException<MASBasicFaultDetail> exception)
                    {
                        throw new Exception(exception.Detail.ErrorMessages[0]);
                    }
                }
            }
            using (var client = new AccountServiceClient())
            {
                if (client.ClientCredentials != null)
                {
                    client.ClientCredentials.UserName.UserName = @"su";
                    client.ClientCredentials.UserName.Password = @"su123";
                }
                Account account;
                try
                {
                    client.LoadAccount(new AccountIdentifier(@"demo", @"mt"), DateTime.UtcNow, out account);
                }
                catch (FaultException<MASBasicFaultDetail> exception)
                {
                    throw new Exception(exception.Detail.ErrorMessages[0]);
                }
                if (
                    !(((InternalView) account.GetInternalView()).PriceList.HasValue &&
                      ((InternalView) account.GetInternalView()).PriceList == pricelist.ID))
                {
                    ((InternalView) account.GetInternalView()).PriceList = pricelist.ID;
                    using (var client2 = new AccountCreationClient())
                    {
                        if (client2.ClientCredentials != null)
                        {
                            client2.ClientCredentials.UserName.UserName = @"su";
                            client2.ClientCredentials.UserName.Password = @"su123";
                        }
                        try
                        {
                            client2.UpdateAccount(account, false, null);
                        }
                        catch (FaultException<MASBasicFaultDetail> exception)
                        {
                            throw new Exception(exception.Detail.ErrorMessages[0]);
                        }
                    }
                }
            }
        }

        #endregion

        [TestMethod()]
        public void TestParamtableColumns()
        {
            const string nmParamtable = @"t_pt_CurrencyExchangeRates";
            ForeignExchangeRateManager.ValidateParameterTable(nmParamtable, @"c_sourcecurrency",
                                                              @"c_targetcurrency", @"c_exchangerates");
        }

        [TestMethod()]
        public void TestParamtableLookup()
        {
            const string nmParamtable = @"t_pt_CurrencyExchangeRates";
            int idParamtable = ForeignExchangeRateManager.GetIdParamtableByName(nmParamtable);
            if (idParamtable <= 0)
            {
                throw new Exception("Returned invalid id");
            }
        }

        [TestMethod()]
        public void TestPiTemplateLookup()
        {
            const string nmParamtable = @"t_pt_CurrencyExchangeRates";
            int idParamtable = ForeignExchangeRateManager.GetIdParamtableByName(nmParamtable);
            int idPricelist = ForeignExchangeRateManager.GetIdPricelistByAccount(@"mt", @"demo");
            int idPiTemplate = ForeignExchangeRateManager.GetIdPiTemplate(idPricelist,
                                                                          idParamtable,
                                                                          nmParamtable);
            if (idPiTemplate <= 0)
            {
                throw new Exception("Returned invalid id");
            }
        }

        [TestMethod()]
        public void TestPricelistLookupByAccount()
        {
            int idPricelistByAccount = ForeignExchangeRateManager.GetIdPricelistByAccount(@"mt", @"demo");
            if (idPricelistByAccount <= 0)
            {
                throw new Exception("Returned invalid id");
            }
        }

        [TestMethod()]
        public void TestPricelistLookupByName()
        {
            int idPricelistByName = ForeignExchangeRateManager.GetIdPricelistByName(@"Currency Exchange Pricelist");
            if (idPricelistByName <= 0)
            {
                throw new Exception("Returned invalid id");
            }
        }

        [TestMethod()]
        public void TestSchedLookup()
        {
            const string nmParamtable = @"t_pt_CurrencyExchangeRates";
            int idParamtable = ForeignExchangeRateManager.GetIdParamtableByName(nmParamtable);
            int idPricelist = ForeignExchangeRateManager.GetIdPricelistByAccount(@"mt", @"demo");
            int idPiTemplate = ForeignExchangeRateManager.GetIdPiTemplate(idPricelist,
                                                                          idParamtable,
                                                                          nmParamtable);
            int idSched = ForeignExchangeRateManager.GetIdSched(123, idPricelist, nmParamtable, idParamtable,
                                                                idPiTemplate, DateTime.Parse("01/01/2012 12:00:00 AM"));
            if (idSched <= 0)
            {
                throw new Exception("Returned invalid id");
            }
        }

        [TestMethod()]
        public void TestWriteRates()
        {
            const string nmParamtable = @"t_pt_CurrencyExchangeRates";
            var provider = new XeForeignExchangeRateProvider();
            using (
                var stringReader =
                    new StringReader(
                        @"<ProviderConfig><CurrencyConfig><BaseCurrency>USD</BaseCurrency><URL>http://www.xe.com/dfs/sample-usd.xml</URL><FileNameFormat>O:\xyz\usd.xml</FileNameFormat></CurrencyConfig><CurrencyConfig><BaseCurrency>EUR</BaseCurrency><URL>http://www.xe.com/dfs/sample-eur.xml</URL><FileNameFormat>O:\xyz\eur.xml</FileNameFormat></CurrencyConfig><CurrencyConfig><BaseCurrency>GBP</BaseCurrency><URL>http://www.xe.com/dfs/sample-gbp.xml</URL><FileNameFormat>O:\xyz\gbp.xml</FileNameFormat></CurrencyConfig></ProviderConfig>")
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
            List<ExchangeRateDetails> rates = provider.GetExchangeRates(Convert.ToDateTime(@"04/27/2008 21:00:00"),
                                                                        null, out baseCurrencies);
            ForeignExchangeRateManager.AddIdentityRates(rates, baseCurrencies);
            ForeignExchangeRateManager.AddInverseRates(rates, baseCurrencies);
            int idParamtable = ForeignExchangeRateManager.GetIdParamtableByName(nmParamtable);
            int idPricelist = ForeignExchangeRateManager.GetIdPricelistByAccount(@"mt", @"demo");
            int idPiTemplate = ForeignExchangeRateManager.GetIdPiTemplate(idPricelist,
                                                                          idParamtable,
                                                                          nmParamtable);
            int idSched = ForeignExchangeRateManager.GetIdSched(123, idPricelist, nmParamtable, idParamtable,
                                                                idPiTemplate, DateTime.Parse(@"01/01/2012 12:00:00 AM"));
            ForeignExchangeRateManager.WriteRates(123, idSched, idParamtable, nmParamtable, rates, @"c_sourcecurrency",
                                                  @"c_targetcurrency", @"c_exchangerates");
        }
    }
}