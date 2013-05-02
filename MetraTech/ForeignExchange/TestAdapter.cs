using System;
using System.IO;
using MetraTech.Interop.MTAuth;
using MetraTech.UsageServer;
using MetraTech.UsageServer.Adapters;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ForeignExchange
{
    [TestClass]
    public class TestAdapter
    {
        [TestMethod]
        public void TestAdapterConfig()
        {
            var context = new MTSessionContext {AccountID = 1};
            const string filename = "tmpadapterconfig";
            using (var writer = File.CreateText(filename))
            {
                writer.WriteLine(
                    @"<?xml version=""1.0""?><xmlconfig><Provider><AssemblyName>MetraTech.UsageServer.Adapters</AssemblyName><ClassName>MetraTech.ForeignExchange.XeForeignExchangeRateProvider</ClassName><ProviderConfig><CurrencyConfig><BaseCurrency>USD</BaseCurrency><URL>http://www.xe.com/dfs/sample-usd.xml</URL><FileNameFormat>O:\xyz\usd.xml</FileNameFormat></CurrencyConfig><CurrencyConfig><BaseCurrency>EUR</BaseCurrency><URL>http://www.xe.com/dfs/sample-eur.xml</URL><FileNameFormat>O:\xyz\eur.xml</FileNameFormat></CurrencyConfig><CurrencyConfig><BaseCurrency>GBP</BaseCurrency><URL>http://www.xe.com/dfs/sample-gbp.xml</URL><FileNameFormat>O:\xyz\gbp.xml</FileNameFormat></CurrencyConfig></ProviderConfig></Provider><PricelistName>CurrencyPricelist</PricelistName><SystemCurrency>USD</SystemCurrency><ParamTableName>t_pt_currencyexchangerate</ParamTableName><SourceCurrencyColumn>c_SourceCurrency></SourceCurrencyColumn><RateColumn>c_ExchangeRate</RateColumn><TargetCurrencyColumn>c_TargetCurrency</TargetCurrencyColumn><AddIdentityRates>true</AddIdentityRates><AddInverseRates>true</AddInverseRates></xmlconfig>");
            }
            var adapter = new ForeignExchangeRateAdapter();
            adapter.Initialize("EventName", filename, context, false);
        }

        [TestMethod()]
        public void TestAdapterRun()
        {
            var context = new MTSessionContext { AccountID = 1 };
            var context2 = new RecurringEventRunContext {RunID = 0, EndDate = DateTime.Now, StartDate = DateTime.Now};
            const string filename = "tmpadapterconfig";
            using (var writer = File.CreateText(filename))
            {
                writer.WriteLine(
                    @"<?xml version=""1.0""?>
<xmlconfig>
 <!-- Can specify a list of providers here -->
 <Provider>
  <!-- each provider must specify which assembly and what class to load for the provider -->
  <AssemblyName>MetraTech.UsageServer.Adapters</AssemblyName>
  <ClassName>MetraTech.ForeignExchange.XeForeignExchangeRateProvider</ClassName>
  <ProviderConfig>
   <Name>XE for USD/EUR/GBP</Name>
   <CurrencyConfig>
    <!-- The Base (Source) currency -->
    <BaseCurrency>USD</BaseCurrency>
	<!-- the xe.com URL used for retrieving the rates, can omit if adapter is not retrieving rates from XE directly -->
	<URL>http://www.xe.com/dfs/sample-usd.xml</URL>
	<!-- the filename format specifies where to look for the files, and where to store them if they are downloaded -->
	<FileNameFormat>O:\xyz\%%NM_CURRENCY%%-%%DT_START%%.xml</FileNameFormat>
	<!-- Turn off ValidateDates when using samples -->
	<ValidateDates>false</ValidateDates>
	<!-- use the following section to specify the proxy settings if required -->
    <!--Proxy>
     <Address>MyProxy.com</Address>
     <UseDefaultCredentials>false</UseDefaultCredentials>
     <Bypass>127.0.0.1</Bypass>
     <Bypass>myurl.com</Bypass>
     <Credentials>
      <UserName>me</UserName>
      <Password encrypted=""true"">encrypted_password</Password>
      <Domain>mydomain</Domain>
     </Credentials>
    </Proxy-->
   </CurrencyConfig>
   <CurrencyConfig>
    <!-- The Base (Source) currency -->
    <BaseCurrency>GBP</BaseCurrency>
	<!-- the xe.com URL used for retrieving the rates, can omit if adapter is not retrieving rates from XE directly -->
	<URL>http://www.xe.com/dfs/sample-gbp.xml</URL>
	<!-- the filename format specifies where to look for the files, and where to store them if they are downloaded -->
	<FileNameFormat>O:\xyz\%%NM_CURRENCY%%-%%DT_START%%.xml</FileNameFormat>
	<!-- Turn off ValidateDates when using samples -->
	<ValidateDates>false</ValidateDates>
	<!-- use the following section to specify the proxy settings if required -->
    <!--Proxy>
     <Address>MyProxy.com</Address>
     <UseDefaultCredentials>false</UseDefaultCredentials>
     <Bypass>127.0.0.1</Bypass>
     <Bypass>myurl.com</Bypass>
     <Credentials>
      <UserName>me</UserName>
      <Password encrypted=""true"">encrypted_password</Password>
      <Domain>mydomain</Domain>
     </Credentials>
    </Proxy-->
   </CurrencyConfig>
   <CurrencyConfig>
    <!-- The Base (Source) currency -->
    <BaseCurrency>EUR</BaseCurrency>
	<!-- the xe.com URL used for retrieving the rates, can omit if adapter is not retrieving rates from XE directly -->
	<URL>http://www.xe.com/dfs/sample-eur.xml</URL>
	<!-- the filename format specifies where to look for the files, and where to store them if they are downloaded -->
	<FileNameFormat>O:\xyz\%%NM_CURRENCY%%-%%DT_START%%.xml</FileNameFormat>
	<!-- Turn off ValidateDates when using samples -->
	<ValidateDates>false</ValidateDates>
	<!-- use the following section to specify the proxy settings if required -->
    <!--Proxy>
     <Address>MyProxy.com</Address>
     <UseDefaultCredentials>false</UseDefaultCredentials>
     <Bypass>127.0.0.1</Bypass>
     <Bypass>myurl.com</Bypass>
     <Credentials>
      <UserName>me</UserName>
      <Password encrypted=""true"">encrypted_password</Password>
      <Domain>mydomain</Domain>
     </Credentials>
    </Proxy-->
   </CurrencyConfig>
  </ProviderConfig>
 </Provider>
 
 <!-- The SystemCurrency is used to define what currency is used for cross-rates (if applicable) -->
 <SystemCurrency>USD</SystemCurrency>

 <!-- Can use either PricelistName or PricelistLogin/PricelistLoginSpace to pick the correct pricelist -->
 <!-- PricelistName looks up a shared pricelist by name -->
 <PricelistName>Currency Exchange Pricelist</PricelistName>
 <!--PricelistLogin>demo</PricelistLoginSpace>
 <PricelistLoginSpace>metratech.com</PricelistLoginSpace-->

 <CalculateInverseRates>false</CalculateInverseRates>
 <AddIdentityRates>true</AddIdentityRates>
 <AddInverseRates>true</AddInverseRates>
 <AddCrossRates>false</AddCrossRates>
 <AddCalculatedRates>false</AddCalculatedRates>

 <!-- CurrencyFilters can be used to filter the retrieved set of currencies down
 the following sample filter would filter the exchange rates down to only list:
 - USD -> USD
 - USD -> GBP
 - USD -> EUR
 -->
 <CurrencyFilter>
   <BaseCurrency>USD</BaseCurrency>
   <Currency>GBP</Currency>
   <Currency>USD</Currency>
   <Currency>EUR</Currency>
 </CurrencyFilter>

 <!-- following can be used for custom parameter table mapping
 -->
 <!--
 <ParamTableName>t_pt_currencyexchangerates</ParamTableName>
 <SourceCurrencyColumn>c_SourceCurrency</SourceCurrencyColumn>
 <TargetCurrencyColumn>c_TargetCurrency</TargetCurrencyColumn>
 <RateColumn>c_ExchangeRates</RateColumn>
 -->

 <!-- following can be used for more advanced custom parameter table mapping
 -->
 <!--
 <CategoryColumn>c_Category</CategoryColumn>
 <CrossCurrencyColumn>c_CrossCurrency</CrossCurrencyColumn>
 <CrossRateColumn>c_CrossRate</CrossRateColumn>
 <ProviderColumn>c_Provider</ProviderColumn>
 -->

</xmlconfig>
");
            }
            var adapter = new ForeignExchangeRateAdapter();
            adapter.Initialize("EventName", filename, context, false);
            adapter.Execute(context2);
        }
    }
}