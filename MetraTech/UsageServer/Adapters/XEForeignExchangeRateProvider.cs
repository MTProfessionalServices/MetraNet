using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Xml;
using MetraTech.Crypto;
using MetraTech.UsageServer;

namespace MetraTech.ForeignExchange
{
    /// <summary>
    /// configuration items for XE
    /// </summary>
    public class XeConfig
    {
        /// <summary>
        /// The URL for this config row
        /// </summary>
        public string Url { get; set; }

        /// <summary>
        /// The base currency for this URL
        /// </summary>
        public string BaseCurrency { get; set; }

        /// <summary>
        /// The filename format to use
        /// </summary>
        public string FilenameFormat { get; set; }

        /// <summary>
        /// An optional proxy to use for contacting XE
        /// </summary>
        public IWebProxy Proxy { get; set; }

        /// <summary>
        /// Whether to validate the dates in the file with the run's dates, this is useful for testing
        /// </summary>
        public bool ValidateDates { get; set; }
    }

    /// <summary>
    /// XE.com class to handle calling XE and grabbing their exchange rates
    /// Supports multiple exchange rates etc.
    /// </summary>
    public class XeForeignExchangeRateProvider : IForeignExchangeRateProvider
    {
        private readonly List<XeConfig> _configs = new List<XeConfig>();

        /// <summary>
        /// private data members
        /// </summary>
        private readonly Logger _logger = new Logger("[XE]");

        #region IForeignExchangeRateProvider Members

        /// <summary>
        /// Initializes the provider with the provided reader.
        /// The reader will be positioned on the ProviderConfig Element, and should be returned with it positioned on the ProviderConfig EndElement
        /// 
        /// This will read in a set of XEConfig's, with URL's, currencies, and formats.
        /// 
        /// XML Format is:
        /// <![CDATA[
        /// <ProviderConfig>
        ///  <CurrencyConfig>
        ///   <BaseCurrency>USD</BaseCurrency>
        ///   <URL>http://xe.com/blah/usd.xml</URL>
        ///   <FileNameFormat>D:\MetraTech\Data\%%DT_START%%\USD.xml</FileNameFormat>
        ///   <ValidateDates>true</ValidateDates>
        ///   <Proxy>
        ///    <Address>MyProxy.com</Address>
        ///    <UseDefaultCredentials>false</UseDefaultCredentials>
        ///    <Bypass>127.0.0.1</Bypass>
        ///    <Bypass>myurl.com</Bypass>
        ///    <Credentials>
        ///     <UserName>me</UserName>
        ///     <Password encyrpted="true">encrypted_password</Password>
        ///     <Domain>mydomain</Domain>
        ///    </Credentials>
        ///   </Proxy>
        ///  </CurrencyConfig>
        ///  <CurrencyConfig>...</CurrencyConfig>
        /// </ProviderConfig>
        /// ]]>
        /// </summary>
        /// <param name="reader">The reader positoned at the ProviderConfig Element</param>
        public void Init(XmlReader reader)
        {
            Name = "XE";
            if (reader == null)
            {
                throw new ArgumentNullException("reader");
            }
            if (reader.NodeType != XmlNodeType.Element || !reader.Name.Equals("ProviderConfig"))
            {
                throw new ArgumentException("reader is not positioned on ProviderConfig Element", "reader");
            }
            if (reader.IsEmptyElement)
            {
                throw new Exception("ProviderConfig can not be empty");
            }
            if (!reader.Read())
            {
                throw new Exception("Failed to read ProviderConfig element");
            }
            while (!(reader.NodeType == XmlNodeType.EndElement && reader.Name.Equals("ProviderConfig")))
            {
                if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Name"))
                {
                    Name = reader.ReadElementContentAsString();
                }
                else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("CurrencyConfig"))
                {
                    // 1) load the CurrencyConfig rows
                    if (reader.IsEmptyElement)
                    {
                        if (!reader.Read())
                        {
                            throw new Exception("Failed to read CurrencyConfig element");
                        }
                        continue;
                    }
                    if (!reader.Read())
                    {
                        throw new Exception("Failed to read CurrencyConfig element");
                    }
                    var config = new XeConfig();
                    while (!(reader.NodeType == XmlNodeType.EndElement && reader.Name.Equals("CurrencyConfig")))
                    {
                        if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("BaseCurrency"))
                        {
                            config.BaseCurrency = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("URL"))
                        {
                            config.Url = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("FileNameFormat"))
                        {
                            config.FilenameFormat = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("ValidateDates"))
                        {
                            config.ValidateDates = reader.ReadElementContentAsBoolean();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Proxy"))
                        {
                            var proxy = new WebProxy();
                            var bypasses = new List<string>();
                            if (reader.IsEmptyElement)
                            {
                                if (!reader.Read())
                                {
                                    throw new Exception("Failed to read Proxy element");
                                }
                                continue;
                            }
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read Proxy element");
                            }
                            while (!(reader.NodeType == XmlNodeType.EndElement && reader.Name.Equals("Proxy")))
                            {
                                if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Address"))
                                {
                                    proxy.Address = new Uri(reader.ReadElementContentAsString());
                                }
                                else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("UseDefaultCredentials"))
                                {
                                    proxy.UseDefaultCredentials = reader.ReadElementContentAsBoolean();
                                }
                                else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Bypass"))
                                {
                                    bypasses.Add(reader.ReadElementContentAsString());
                                }
                                else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Credentials"))
                                {
                                    var creds = new NetworkCredential();
                                    if (reader.IsEmptyElement)
                                    {
                                        if (!reader.Read())
                                        {
                                            throw new Exception("Failed to read Credentials element");
                                        }
                                        continue;
                                    }
                                    if (!reader.Read())
                                    {
                                        throw new Exception("Failed to read Credentials element");
                                    }
                                    while (!(reader.NodeType == XmlNodeType.EndElement && reader.Name.Equals("Credentials")))
                                    {
                                        if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("UserName"))
                                        {
                                            creds.UserName = reader.ReadElementContentAsString();
                                        }
                                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Password"))
                                        {
                                            string attrib = reader.GetAttribute("encrypted");
                                            if ((!string.IsNullOrEmpty(attrib)) && attrib.Equals("true"))
                                            {
                                                var decryptor = new Decryptor();
                                                decryptor.Initialize();
                                                creds.Password = decryptor.Decrypt(reader.ReadElementContentAsString());
                                                decryptor.Dispose();

                                            }
                                            else
                                            {
                                                creds.Password = reader.ReadElementContentAsString();
                                            }
                                        }
                                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Domain"))
                                        {
                                            creds.Domain = reader.ReadElementContentAsString();
                                        }
                                        else
                                        {
                                            _logger.LogWarning(string.Format("Ignoring unknown XML node: {0} ({1})", reader.Name,
                                                                             reader.NodeType));
                                            if (!reader.Read())
                                            {
                                                throw new Exception("Failed to read Credentials element");
                                            }
                                        }
                                    }
                                    if (!reader.Read())
                                    {
                                        throw new Exception("Failed to read Credentials element");
                                    }
                                    proxy.Credentials = creds;
                                }
                                else
                                {
                                    _logger.LogWarning(string.Format("Ignoring unknown XML node: {0} ({1})", reader.Name,
                                                                    reader.NodeType));
                                    if (!reader.Read())
                                    {
                                        throw new Exception("Failed to read Proxy element");
                                    }
                                }
                            }
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read Proxy element");
                            }
                            //proxy.Credentials;
                            if (bypasses.Count > 0)
                            {
                                proxy.BypassList = bypasses.ToArray();
                            }
                            if (proxy.Address == null)
                            {
                                throw new Exception("Proxy Address must be set");
                            }
                            config.Proxy = proxy;
                        }
                        else
                        {
                            _logger.LogWarning(string.Format("Ignoring unknown XML node: {0} ({1})", reader.Name,
                                                            reader.NodeType));
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read CurrencyConfig element");
                            }
                        }
                    }
                    if (!reader.Read())
                    {
                        throw new Exception("Failed to read CurrencyConfig element");
                    }
                    if (string.IsNullOrEmpty(config.BaseCurrency))
                    {
                        throw new Exception("XE CurrencyConfig must contain a BaseCurrency");
                    }
                    if (string.IsNullOrEmpty(config.Url))
                    {
                        _logger.LogWarning("No URL configured for XE.  File must be provided.");
                    }
                    if (string.IsNullOrEmpty(config.FilenameFormat))
                    {
                        throw new Exception("XE CurrencyConfig must contain a FileNameFormat");
                    }
                    _configs.Add(config);
                }
                else
                {
                    _logger.LogWarning(string.Format("Ignoring unknown XML node: {0} ({1})", reader.Name, reader.NodeType));
                    if (!reader.Read())
                    {
                        throw new Exception("Failed to read ProviderConfig element");
                    }
                }
            }
            if (_configs.Count <= 0)
            {
                throw new Exception(
                    "No provider configuration provided for XE.  Must provide set of CurrencyConfig elements, with BaseCurrency, URL and FileNameFormat");
            }
        }

        public string Name
        {
            get;
            set;
        }

        /// <summary>
        /// Retrieve the base XE exchange rates
        /// </summary>
        /// <param name="date">The date to fetch for</param>
        /// <param name="context">The run context</param>
        /// <param name="baseCurrencies">The set of base currencies loaded</param>
        /// <returns>The exchange rates</returns>
        public List<ExchangeRateDetails> GetExchangeRates(DateTime date, IRecurringEventRunContext context,
                                                          out List<string> baseCurrencies)
        {
            var rates = new List<ExchangeRateDetails>();
            if (context != null && context.RunID != 0)
            {
                context.RecordInfo(string.Format("Loading XE rates for date: {0}", date));
            }
            _logger.LogInfo(string.Format("Loading XE rates for date: {0}", date));
            if (_configs == null || _configs.Count <= 0)
            {
                throw new Exception("No XE configurations loaded");
            }
            baseCurrencies = new List<string>();
            // 1) loop through the configured currencies
            foreach (XeConfig config in _configs)
            {
                if (string.IsNullOrEmpty(config.Url))
                {
                    throw new Exception("URL must be set in XE config");
                }
                if (string.IsNullOrEmpty(config.BaseCurrency))
                {
                    throw new Exception("BaseCurrency must be set in XE config");
                }
                if (string.IsNullOrEmpty(config.FilenameFormat))
                {
                    throw new Exception("FilenameFormat must be set in XE config");
                }
                baseCurrencies.Add(config.BaseCurrency);
                // 2) Generate the filename
                var filename = GenerateFilename(config.FilenameFormat, date, context, config.BaseCurrency);
                _logger.LogInfo(string.Format("Filename for this exchange rate run: {0}", filename));
                if (context != null && context.RunID != 0)
                {
                    context.RecordInfo(string.Format("Filename for this exchange rate run: {0}", filename));
                }
                // 3) get the rate file (this may or may not call the URL, depending on whether the file exists)
                GetRateFile(filename, config.Url, config.Proxy);
                // 4) validate the rate file
                ValidateRateFile(config.BaseCurrency, filename, date, config.ValidateDates);
                // 5) append all of the rates
                rates.AddRange(LoadExchangeRates(filename, config.BaseCurrency));
            }
            _logger.LogInfo(string.Format("Loaded {0} rates", rates.Count));
            if (context != null && context.RunID != 0)
            {
                context.RecordInfo(string.Format("Loaded {0} rates", rates.Count));
            }
            return rates;
        }

        #endregion

        /// <summary>
        /// Retrieve the rate file from XE and store it locally.
        /// </summary>
        /// <param name="writer">The stream to write the file to</param>
        /// <param name="url">The URL to call</param>
        /// <param name="proxy">Optional proxy to use if needed</param>
        private static void RetrieveRateFile(Stream writer, string url, IWebProxy proxy)
        {
            if (writer == null)
            {
                throw new ArgumentNullException("writer");
            }
            var request = WebRequest.Create(url);
            request.Proxy = proxy;
            var response = request.GetResponse();
            if (response == null)
            {
                throw new Exception("Web request returned no response data");
            }
            var stream = response.GetResponseStream();
            if (stream == null)
            {
                throw new Exception("Web request returned no response data in the stream");
            }
            stream.CopyTo(writer);
        }

        /// <summary>
        /// Get the rate file (either if it already exists, or a refetch
        /// </summary>
        /// <param name="filename">The filename to use</param>
        /// <param name="url">The URL to use</param>
        /// <param name="proxy">An optional web proxy to use</param>
        private void GetRateFile(string filename, string url, IWebProxy proxy)
        {
            if (string.IsNullOrEmpty(filename))
            {
                throw new ArgumentNullException("filename");
            }
            lock (this)
            {
                if (!File.Exists(filename))
                {
                    if (string.IsNullOrEmpty(url))
                    {
                        throw new Exception(string.Format("Filename {0} is empty and no URL has been configured to fetch the file", filename));
                    }
                    var dir = Directory.GetParent(filename);
                    dir.Create();
                    using (var writer = new FileStream(filename, FileMode.CreateNew))
                    {
                        RetrieveRateFile(writer, url, proxy);
                    }
                }
            }
        }

        /// <summary>
        /// Validate a rate file to ensure that it matches the dates and has correct fields, etc.
        /// </summary>
        /// <param name="baseCurrency">The base currency of the rates</param>
        /// <param name="filename">The filename to check</param>
        /// <param name="date">The effective date that the file should contain rates for</param>
        /// <param name="validateDates">whether to validate the date in the file</param>
        private void ValidateRateFile(string baseCurrency, string filename, DateTime date, bool validateDates)
        {
            if (string.IsNullOrEmpty(baseCurrency))
            {
                throw new ArgumentNullException("baseCurrency");
            }
            if (string.IsNullOrEmpty(filename))
            {
                throw new ArgumentNullException("filename");
            }
            var headers = new Dictionary<string, object>();
            var settings = new XmlReaderSettings { DtdProcessing = DtdProcessing.Parse, IgnoreComments = true, IgnoreWhitespace = true };
            // 1: loop through and build up the header table
            using (var reader = XmlReader.Create(filename, settings))
            {
                while (reader.Read() && reader.NodeType == XmlNodeType.XmlDeclaration)
                { }
                if (!(reader.Name.Equals("xe-datafeed") && reader.NodeType == XmlNodeType.DocumentType))
                {
                    throw new Exception("Failed to read xmlconfig element");
                }
                if (reader.IsEmptyElement || !reader.Read())
                {
                    throw new Exception("xe-datafeed can not be empty");
                }
                while (!(reader.NodeType == XmlNodeType.EndElement && reader.Name.Equals("xe-datafeed")))
                {
                    if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("header"))
                    {
                        if (reader.IsEmptyElement)
                        {
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read header element");
                            }
                            continue;
                        }
                        if (!reader.Read())
                        {
                            throw new Exception("Failed to read header element");
                        }
                        var key = string.Empty;
                        while (!(reader.Name.Equals("header") && reader.NodeType == XmlNodeType.EndElement))
                        {
                            if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("hname"))
                            {
                                key = reader.ReadElementContentAsString();
                            }
                            else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("hvalue"))
                            {
                                if (string.IsNullOrEmpty(key))
                                {
                                    throw new Exception("Invalid header.  Key is null");
                                }
                                if (key.Equals("UTC Timestamp"))
                                {
                                    headers[key] = Convert.ToDateTime(reader.ReadElementContentAsString());
                                }
                                else
                                {
                                    headers[key] = reader.ReadElementContentAsString();
                                }
                            }
                            else
                            {
                                _logger.LogWarning(string.Format("Ignoring unknown XML node: {0} ({1})", reader.Name,
                                                                reader.NodeType));
                                if (!reader.Read())
                                {
                                    throw new Exception("Failed to read header element");
                                }
                            }
                        }
                        if (!reader.Read())
                        {
                            throw new Exception("Failed to read header element");
                        }
                    }
                    else
                    {
                        if (!reader.Read())
                        {
                            throw new Exception("Failed to read xe-datafeed element");
                        }
                    }
                }
            }
            // 2) just validate some of the header fields
            if (!headers.ContainsKey("Base Currency"))
            {
                throw new Exception("Missing Base currency");
            }
            if (!baseCurrency.Equals(headers["Base Currency"]))
            {
                throw new Exception("Base Currency Mismatch");
            }
            if (!headers.ContainsKey("UTC Timestamp"))
            {
                throw new Exception("Missing UTC Timestamp");
            }
            if (validateDates && !date.Date.Equals(((DateTime)headers["UTC Timestamp"]).Date))
            {
                throw new Exception("UTC Timestamp Mismatch.  File timestamp does not match the requested date");
            }
            if (!headers.ContainsKey("UTC Time of Your Next Update"))
            {
                throw new Exception("Missing UTC Time of Your Next Update");
            }
        }

        /// <summary>
        /// Loads exchange rates from an XE.com file
        /// </summary>
        /// <param name="filename">The filename to load the rates from</param>
        /// <param name="baseCurrency">The base currency for the file to be loaded</param>
        /// <returns>The list of exchange rates</returns>
        private List<ExchangeRateDetails> LoadExchangeRates(string filename, string baseCurrency)
        {
            if (string.IsNullOrEmpty(filename))
            {
                throw new ArgumentNullException("filename");
            }
            if (string.IsNullOrEmpty(baseCurrency))
            {
                throw new ArgumentNullException("baseCurrency");
            }
            var list = new List<ExchangeRateDetails>();
            var settings = new XmlReaderSettings { DtdProcessing = DtdProcessing.Parse, IgnoreComments = true, IgnoreWhitespace = true };
            using (var reader = XmlReader.Create(filename, settings))
            {
                while (reader.Read() && reader.NodeType == XmlNodeType.XmlDeclaration)
                { }
                if (!(reader.Name.Equals("xe-datafeed") && reader.NodeType == XmlNodeType.DocumentType))
                {
                    throw new Exception("Failed to read xmlconfig element");
                }
                if (reader.IsEmptyElement || !reader.Read())
                {
                    throw new Exception("xe-datafeed can not be empty");
                }
                while (!(reader.NodeType == XmlNodeType.EndElement && reader.Name.Equals("xe-datafeed")))
                {
                    // 1) load the currency rows
                    if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("currency"))
                    {
                        if (reader.IsEmptyElement)
                        {
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read currency element");
                            }
                            continue;
                        }
                        if (!reader.Read())
                        {
                            throw new Exception("Failed to read currency element");
                        }
                        var currency = string.Empty;
                        var valid = true;
                        var rate = new ExchangeRateDetails { BaseCurrency = baseCurrency, Source = "XE", Type = "Base" };
                        while (!(reader.Name.Equals("currency") && reader.NodeType == XmlNodeType.EndElement))
                        {
                            if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("csymbol"))
                            {
                                currency = reader.ReadElementContentAsString();
                                if (rate.ValidCurrency(currency))
                                {
                                    rate.Currency = currency;
                                }
                                else
                                {
                                    valid = false;
                                }
                            }
                            else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("cname"))
                            {
                                reader.ReadElementContentAsString();
                            }
                            else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("crate"))
                            {
                                rate.Rate = reader.ReadElementContentAsDecimal();
                            }
                            else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("cinverse"))
                            {
                                rate.InverseRate = reader.ReadElementContentAsDecimal();
                            }
                            else
                            {
                                _logger.LogWarning(string.Format("Ignoring unknown XML node: {0} ({1})", reader.Name,
                                                                reader.NodeType));
                                if (!reader.Read())
                                {
                                    throw new Exception("Failed to read currency element");
                                }
                            }
                        }
                        reader.Read();
                        if (valid)
                        {
                            list.Add(rate);
                        }
                        else
                        {
                            _logger.LogWarning(string.Format("Invalid Currency: {0}", currency));
                        }
                    }
                    else
                    {
                        if (!reader.Read())
                        {
                            throw new Exception("Failed to read currency element");
                        }
                    }
                }
            }
            return list;
        }

        /// <summary>
        /// Generates a filename (and path) from a format string, and the context
        /// Replacement strings available are:
        /// %%DT_NOW%%       - today's date (in yyyyMMdd format)
        /// %%NM_SOURCE%%    - the source of the file (XE)
        /// %%NM_CURRENCY%%  - the base currency
        /// %%ID_BILLGROUP%% - the billgroup id (if EOP)
        /// %%DT_END%%       - the end date of the run (in yyyyMMdd format)
        /// %%ID_RUN%%       - the id of the run
        /// %%ID_REVERSE%%   - the id of the run to reverse
        /// %%DT_START%%     - the start date of the run (in yyyyMMdd format)
        /// %%ID_INTERVAL%%  - the interval id (if EOP)
        /// %%DT_EFFECTIVE%% - the date of the run (in yyyyMMdd format)
        /// </summary>
        /// <param name="format">The string format to replace the values in</param>
        /// <param name="date">The date to fetch exchange rates for</param>
        /// <param name="context">The adapter context</param>
        /// <param name="baseCurrency">The base currency</param>
        /// <returns>The generated filename, with replacements</returns>
        private static string GenerateFilename(string format, DateTime date, IRecurringEventRunContext context,
                                        string baseCurrency)
        {
            if (string.IsNullOrEmpty(format))
            {
                throw new ArgumentNullException("format");
            }
            if (string.IsNullOrEmpty(baseCurrency))
            {
                throw new ArgumentNullException("baseCurrency");
            }
            // 1) do all of the field replacements (make sure the first one is off of format, not str)
            var str = format.Replace("%%DT_NOW%%", MetraTime.Now.ToString("yyyyMMdd"));
            str = str.Replace("%%NM_SOURCE%%", "XE");
            str = str.Replace("%%NM_CURRENCY%%", baseCurrency);
            str = str.Replace("%%DT_EFFECTIVE%%", date.ToString("yyyyMMdd"));
            if (context != null)
            {
                str = str.Replace("%%ID_BILLGROUP%%", context.BillingGroupID.ToString());
                str = str.Replace("%%DT_END%%", context.EndDate.ToString("yyyyMMdd"));
                str = str.Replace("%%ID_RUN%%", context.RunID.ToString());
                str = str.Replace("%%ID_REVERSE%%", context.RunIDToReverse.ToString());
                str = str.Replace("%%DT_START%%", context.StartDate.ToString("yyyyMMdd"));
                str = str.Replace("%%ID_INTERVAL%%", context.UsageIntervalID.ToString());
            }
            return str;
        }
    }
}