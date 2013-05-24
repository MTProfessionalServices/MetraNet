using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.Globalization;
using System.IO;
using System.Runtime.Caching;
using System.Runtime.Serialization;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;
using MetraTech.DataAccess;
using MetraTech.Interop.MTAuth;

namespace MetraTech.UsageServer.Adapters
{
    /// <summary>
    /// How to handle duplicate files
    /// </summary>
    public enum DuplicateFileBehaviour
    {
        /// <summary>
        /// Overwrite the file
        /// </summary>
        OverWrite,
        /// <summary>
        /// throw an exception
        /// </summary>
        Error,
        /// <summary>
        /// backup the original file
        /// </summary>
        Backup
    }

    /// <summary>
    /// How to backup a file
    /// </summary>
    [DataContract(Namespace = "")]
    public class FileBackupSettings
    {
        /// <summary>
        /// The file path template
        /// </summary>
        [DataMember(IsRequired = false)]
        public string FilePath { get; set; }

        /// <summary>
        /// The filename template
        /// </summary>
        [DataMember(IsRequired = false)]
        public string FileName { get; set; }

        /// <summary>
        /// If rerunning multiple times, and the backup already exists, and the filename has a counter in it, what is the maximum number of backups
        /// </summary>
        [DataMember(IsRequired = false)]
        public int MaxBackupsPerFile { get; set; }
    }

    /// <summary>
    /// Represents all the configuration information required by the adapter.
    /// This information is loaded from the XML configuration file by using XML
    /// deserialization.
    /// </summary>
    [DataContract(Namespace = "")]
    public class QueryXsltAdapterConfiguration
    {
        /// <summary>
        /// Name of the adapter instance being executed
        /// </summary>
        [DataMember(IsRequired = false)]
        public string AdapterName { get; set; }

        /// <summary>
        /// Whether each row of the query results should be called against the xslt, or just once.
        /// </summary>
        [DataMember(IsRequired = true)]
        public bool PerRow { get; set; }

        /// <summary>
        /// Query Path
        /// </summary>
        [DataMember(IsRequired = true)]
        public string QueryPath { get; set; }

        /// <summary>
        /// Query Tag
        /// </summary>
        [DataMember(IsRequired = true)]
        public string QueryTag { get; set; }

        /// <summary>
        /// Used to specify the naming convention when saving an invoice HTML file
        /// </summary>
        [DataMember(IsRequired = true)]
        public string StorageFilenameFormat { get; set; }

        /// <summary>
        /// The XSLT file used to transform the query results.
        /// </summary>
        [DataMember(IsRequired = true)]
        public string XsltFileName { get; set; }

        /// <summary>
        /// What to do with duplicate files
        /// </summary>
        [DataMember(IsRequired = true)]
        public DuplicateFileBehaviour RerunStrategy { get; set; }

        /// <summary>
        /// When we have duplicate files and we are backing them up, how to name them
        /// </summary>
        [DataMember(IsRequired = false)]
        public FileBackupSettings BackupSettings { get; set; }

        /// <summary>
        /// Serializes the adapter configuration into a config file
        /// </summary>
        public void SaveConfiguration(string fileName)
        {
            using (var configFile = new StreamWriter(fileName))
            {
                var adapterConfigSerializer = new DataContractSerializer(typeof(QueryXsltAdapterConfiguration));
                adapterConfigSerializer.WriteObject(configFile.BaseStream, this);
            }
        }
    }

    /// <summary>
    /// Adapter to process a query via an XSTL stylesheer
    /// </summary>
    public class QueryXsltAdapter : IRecurringEventAdapter2
    {
        /// <summary>
        /// The adapter name
        /// </summary>
        private const string MAdapterName = "QueryXsltAdapter";
        /// <summary>
        /// The adapter configuration
        /// </summary>
        private QueryXsltAdapterConfiguration _adapterConfiguration;
        /// <summary>
        /// The logger
        /// </summary>
        private Logger _logger;

        /// <summary>
        /// XSLT transformer used for these invoices
        /// </summary>
        public XslCompiledTransform XsltTransformer { get; set; }

        #region IRecurringEventAdapter2 Members

        /// <summary>
        /// Does this adapter support running in scheduled mode
        /// </summary>
        public bool SupportsScheduledEvents
        {
            get { return true; }
        }

        /// <summary>
        /// Does this adapter support running in end-of-period mode
        /// </summary>
        public bool SupportsEndOfPeriodEvents
        {
            get { return true; }
        }

        /// <summary>
        /// Can this adapter be reversed
        /// </summary>
        public ReverseMode Reversibility
        {
            get { return ReverseMode.Custom; }
        }

        /// <summary>
        /// Can this adapter run multiple instances
        /// </summary>
        public bool AllowMultipleInstances
        {
            get { return true; }
        }

        /// <summary>
        /// Specifies whether the adapter can process billing groups as a group
        /// of accounts, as individual accounts or if it
        /// cannot process billing groups at all.
        /// This setting is only valid for end-of-period adapters.
        /// </summary>
        /// <returns>BillingGroupSupportType</returns>
        public BillingGroupSupportType BillingGroupSupport
        {
            get { return BillingGroupSupportType.Account; }
        }

        /// <summary>
        /// Specifies whether this adapter has special constraints on the membership
        /// of a billing group.
        /// This setting is only valid for adapters that support billing groups.
        /// </summary>
        /// <returns>True if constraints exist, false otherwise</returns>
        public bool HasBillingGroupConstraints
        {
            get { return false; }
        }

        // Member Variables

        /// <summary>
        /// Perform any one time or start up initialization, including reading our config file
        /// for instance specific information
        /// </summary>
        /// <param name="eventName">The name of the event</param>
        /// <param name="configFile">The configuration file to use</param>
        /// <param name="context">The auth context</param>
        /// <param name="limitedInit">Whether to perform limited init or not</param>
        public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
        {
            if (limitedInit)
            {
                _logger = new Logger(string.Format("[{0}]", typeof(QueryXsltAdapterConfiguration).Name));
                _logger.LogDebug("Intializing " + MAdapterName + " (limited)");
            }
            else
            {
                if (_logger == null)
                {
                    _logger = new Logger(string.Format("[{0}]", typeof(QueryXsltAdapterConfiguration).Name));
                }

                Debug.Assert(context != null);

                //Load the custom adapter settings from the given config file
                try
                {
                    using (var configStream = new StreamReader(configFile))
                    {
                        var invoiceSerializer = new DataContractSerializer(typeof(QueryXsltAdapterConfiguration));
                        _adapterConfiguration =
                            (QueryXsltAdapterConfiguration)invoiceSerializer.ReadObject(configStream.BaseStream);
                    }

                    if (_adapterConfiguration.QueryPath == null)
                    {
                        throw new NotSupportedException("QueryPath must be specified in adapter configuration.");
                    }
                    if (_adapterConfiguration.QueryTag == null)
                    {
                        throw new NotSupportedException("QueryTag must be specified in adapter configuration.");
                    }
                    if (_adapterConfiguration.XsltFileName == null)
                    {
                        throw new NotSupportedException("XsltFileName must be specified in adapter configuration.");
                    }
                    if (_adapterConfiguration.RerunStrategy == DuplicateFileBehaviour.Backup && _adapterConfiguration.BackupSettings == null)
                    {
                        throw new NotSupportedException("BackupSettings must be set when RerunStrategy is set to Backup.");
                    }
                    _logger.LogDebug(string.Format("Loading XSLT transformer: {0}",
                                                   _adapterConfiguration.XsltFileName));
                    XsltTransformer = new XslCompiledTransform();
                    using (var reader = XmlReader.Create(_adapterConfiguration.XsltFileName))
                    {
                        XsltTransformer.Load(reader);
                    }
                    _logger.LogDebug(string.Format("Finished Loading XSLT transformer: {0}",
                                                   _adapterConfiguration.XsltFileName));
                }
                catch (Exception ex)
                {
                    var info = string.Format(CultureInfo.InvariantCulture,
                                                "Adapter[{0}]: Unable to read configuration file [{1}]:{2}",
                                                MAdapterName, configFile, ex.Message);
                    _logger.LogError(info);
                    throw new InvalidConfigurationException(info, ex);
                }

                _logger.LogDebug(string.Format("Read configuration for {0} from {1}", _adapterConfiguration.AdapterName,
                                               configFile));
            }
        }

        /// <summary>
        /// Perform the actual work of the adapter
        /// </summary>
        /// <param name="context">the event context</param>
        /// <returns>status</returns>
        public string Execute(IRecurringEventRunContext context)
        {
            if (context == null)
            {
                throw new ArgumentNullException("context");
            }
            var culture = Thread.CurrentThread.CurrentCulture;
            try
            {
                var info = string.Format(CultureInfo.InvariantCulture, "Executing {0} in context: {1}", MAdapterName,
                                            context);
                _logger.LogInfo(info);
                if (context.RunID != 0)
                {
                    context.RecordInfo(info);
                }

                if (context.EventType == RecurringEventType.EndOfPeriod)
                {
                    var intervalId = context.UsageIntervalID;

                    info = string.Format(CultureInfo.InvariantCulture,
                                         "Executing in EOP mode for Interval {0} and Billing Group {1}", intervalId,
                                         context.BillingGroupID);
                    _logger.LogInfo(info);
                }
                else
                {
                    info = string.Format(CultureInfo.InvariantCulture,
                                         "Executing in Scheduled mode for Start Date {0} and End Date {1}",
                                         context.StartDate, context.EndDate);

                    _logger.LogInfo(info);
                }

                // Common (EOP/Scheduled) Execute code here...
                using (var conn = ConnectionManager.CreateConnection())
                {
                    using (
                        var stmt = conn.CreateAdapterStatement(_adapterConfiguration.QueryPath, _adapterConfiguration.QueryTag)
                                           )
                    {
                        Bind(context, stmt);
                        if (_adapterConfiguration.PerRow)
                        {
                            var tasks = new List<Task>();
                            using (var reader = stmt.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    using (var buffer = new StringWriter())
                                    {
                                        buffer.Write("<rows><row");
                                        for (var i = 0; i < reader.FieldCount; i++)
                                        {
                                            if (!reader.IsDBNull(i))
                                            {
                                                var val = reader.GetValue(i);
                                                if (val is DateTime)
                                                {
                                                    buffer.Write(" {0}=\"{1}\"", reader.GetName(i), ((DateTime)val).ToString("o"));
                                                }
                                                else
                                                {
                                                    buffer.Write(" {0}=\"{1}\"", reader.GetName(i), val);
                                                }
                                            }
                                        }
                                        buffer.WriteLine("/></rows>");
                                        var filename = FormatString(context, FormatString(reader, _adapterConfiguration.StorageFilenameFormat));
                                        var dir = Path.GetDirectoryName(filename);
                                        if ((!string.IsNullOrEmpty(dir)) && (!Directory.Exists(dir)))
                                        {
                                            Directory.CreateDirectory(dir);
                                        }
                                        tasks.Add(Task.Factory.StartNew(() => Process(context, buffer.ToString(), filename),
                                                                        TaskCreationOptions.LongRunning));
                                    }
                                }
                            }
                            Task.WaitAll(tasks.ToArray());
                        }
                        else
                        {
                            Process(context, stmt.ExecuteReader());
                        }
                    }
                }

                info = "Success";
                _logger.LogInfo(info);
                if (context.RunID != 0)
                {
                    context.RecordInfo(info);
                }
                return info;
            }
            finally
            {
                Thread.CurrentThread.CurrentCulture = culture;
            }
        }

        /// <summary>
        /// Undo or reverse any work done by the adapter during the call to Execute for the same interval or period
        /// </summary>
        /// <param name="context">The recurring event run context</param>
        /// <returns>the reversal status</returns>
        public string Reverse(IRecurringEventRunContext context)
        {
            if (context == null)
            {
                throw new ArgumentNullException("context");
            }

            string info;
            if (context.EventType == RecurringEventType.EndOfPeriod)
            {
                info = string.Format(CultureInfo.InvariantCulture,
                                     "Reversing in EOP mode for Interval {0} and Billing Group {1}",
                                     context.UsageIntervalID, context.BillingGroupID);
                // EOP Adapter code here...
            }
            else
            {
                info = string.Format(CultureInfo.InvariantCulture,
                                     "Reversing in Scheduled mode for Start Date {0} and End Date {1}",
                                     context.StartDate, context.EndDate);
                // Scheduled Adapter code here...
            }

            // Common (EOP/Scheduled) Reverse/Undo code here...

            _logger.LogInfo(info);
            context.RecordInfo(info);

            info = "Success";
            _logger.LogInfo(info);
            context.RecordInfo(info);
            return info;
        }


        /// <summary>
        /// Used to create constraints for adapters that require certain accounts to be in the same
        /// billing group. For example, if the adapter implements logic that should execute on
        /// complete corporate accounts, then all the child accounts should be in the same
        /// billing group.
        /// </summary>
        /// <param name="intervalId">The interval that is being closed</param>
        /// <param name="materializationId">The ID of the materialization that defined the billing group</param>
        public void CreateBillingGroupConstraints(int intervalId, int materializationId)
        {
            throw new InvalidOperationException(string.Concat(MAdapterName,
                                                              ". Create Billing Group Constraints should not have been called: billing group constraints are not enforced by this adapter - check the Has Billing Group Constraints property."));
        }

        /// <summary>
        /// Not implemented
        /// </summary>
        /// <param name="parentRunId">Not implemented</param>
        /// <param name="parentBillingGroupId">Not implemented</param>
        /// <param name="childRunId">Not implemented</param>
        /// <param name="childBillingGroupId">Not implemented</param>
        public void SplitReverseState(int parentRunId, int parentBillingGroupId, int childRunId, int childBillingGroupId)
        {
            //throw new InvalidOperationException(string.Concat(MAdapterName, ". Split Reverse State should not have been called: reverse is not needed for this adapter - check the Reversibility property."));
            _logger.LogDebug("Splitting reverse state of QueryXsltAdapterAdapter");
        }

        /// <summary>
        /// Used at the end of the adapter execution to release appropriate resources
        /// </summary>
        public void Shutdown()
        {
            _logger.LogDebug("Shutdown");
        }

        #endregion

        /// <summary>
        /// Process the query results with a single XSLT call
        /// </summary>
        /// <param name="context">the recurring event run context</param>
        /// <param name="reader">The query to use</param>
        public void Process(IRecurringEventRunContext context, IMTDataReader reader)
        {
            var filename = FormatString(context, _adapterConfiguration.StorageFilenameFormat);
            var dir = Path.GetDirectoryName(filename);
            if ((!string.IsNullOrEmpty(dir)) && (!Directory.Exists(dir)))
            {
                Directory.CreateDirectory(dir);
            }
            Process(context, new CachedXPathNavigator(reader), filename);
        }

        /// <summary>
        /// Process the query results with one XSLT call per row
        /// </summary>
        /// <param name="xml">The xml to use</param>
        /// <param name="context">the recurring event run context</param>
        /// <param name="filename">The file to write to</param>
        public void Process(IRecurringEventRunContext context, string xml, string filename)
        {
            try
            {
                using (var stream = new StringReader(xml))
                {
                    Process(context, new XPathDocument(stream).CreateNavigator(), filename);
                }
            }
            catch (Exception ex)
            {
                _logger.LogException(string.Format("Failed to process XSLT for row: {0}: {1}", xml, ex.Message), ex);
                throw;
            }
        }

        /// <summary>
        /// Perform the XSLT transform
        /// </summary>
        /// <param name="context">The recurring event run context</param>
        /// <param name="nav">The navigator to use</param>
        /// <param name="filename">The file to write to</param>
        protected void Process(IRecurringEventRunContext context, XPathNavigator nav, string filename)
        {

          //ESR-5647 fix to avoid printing Unicode Chars at the beginning of output fileprinting 
          var writerSettings = new XmlWriterSettings { Encoding = new System.Text.UTF8Encoding(false), ConformanceLevel = ConformanceLevel.Fragment };
          //var writerSettings = new XmlWriterSettings { ConformanceLevel = ConformanceLevel.Fragment };

            if (File.Exists(filename))
            {
                XsltExtension.HandleDuplicateFile(_adapterConfiguration.RerunStrategy, _adapterConfiguration.BackupSettings, filename);
            }
            using (var stream = File.Create(filename))
            {
                using (var wrapper = new WrapperStream(stream))
                {
                    using (var writer = XmlWriter.Create(wrapper, writerSettings))
                    {
                        var xslte = new XsltExtension(nav, wrapper)
                                        {
                                            RerunStrategy = _adapterConfiguration.RerunStrategy,
                                            BackupSettings = _adapterConfiguration.BackupSettings
                                        };
                        var xsltContext = new CustomXsltContext();
                        xsltContext.AddParam("billingGroupId", string.Empty, context.BillingGroupID);
                        xsltContext.AddParam("endDate", string.Empty, context.EndDate);
                        xsltContext.AddParam("eventType", string.Empty, context.EventType);
                        xsltContext.AddParam("runId", string.Empty, context.RunID);
                        xsltContext.AddParam("runIdToReverse", string.Empty, context.RunIDToReverse);
                        xsltContext.AddParam("startDate", string.Empty, context.StartDate);
                        xsltContext.AddParam("usageIntervalId", string.Empty, context.UsageIntervalID);
                        xsltContext.AddExtensionObject("urn:metratech", xslte);
                        xslte.Context = xsltContext;
                        XsltTransformer.Transform(nav, xsltContext.ArgumentList, writer);
                        writer.Close();
                    }
                    wrapper.Close();
                }
                stream.Close();
            }
        }

        protected void Bind(IRecurringEventRunContext context, IMTAdapterStatement stmt)
        {
            if (context != null)
            {
                stmt.AddParamIfFound("%%ID_BILLGROUP%%", context.BillingGroupID);
                stmt.AddParamIfFound("%%DT_END%%", context.EndDate);
                stmt.AddParamIfFound("%%ID_RUN%%", context.RunID);
                stmt.AddParamIfFound("%%ID_REVERSE%%", context.RunIDToReverse);
                stmt.AddParamIfFound("%%DT_START%%", context.StartDate);
                stmt.AddParamIfFound("%%ID_INTERVAL%%", context.UsageIntervalID);
            }
        }

        protected void Bind(IMTDataReader cursor, IMTAdapterStatement stmt)
        {
            if (cursor != null)
            {
                for (int i = 0; i < cursor.FieldCount; i++)
                {
                    stmt.AddParamIfFound("%%" + cursor.GetName(i).ToUpper() + "%%", cursor.GetValue(i));
                }
            }
        }

        protected string FormatString(IRecurringEventRunContext context, string str)
        {
            if (context != null)
            {
                str = str.Replace("%%ID_BILLGROUP%%", context.BillingGroupID.ToString(CultureInfo.InvariantCulture));
                str = str.Replace("%%DT_END%%", context.EndDate.ToString("yyyyMMdd"));
                str = str.Replace("%%ID_RUN%%", context.RunID.ToString(CultureInfo.InvariantCulture));
                str = str.Replace("%%ID_REVERSE%%", context.RunIDToReverse.ToString(CultureInfo.InvariantCulture));
                str = str.Replace("%%DT_START%%", context.StartDate.ToString("yyyyMMdd"));
                str = str.Replace("%%DT_NOW%%", DateTime.Now.ToString("yyyyMMddHHmmss"));
                str = str.Replace("%%ID_INTERVAL%%", context.UsageIntervalID.ToString(CultureInfo.InvariantCulture));
            }
            return str;
        }

        protected string FormatString(IMTDataReader cursor, string str)
        {
            if (cursor != null)
            {
                for (int i = 0; i < cursor.FieldCount; i++)
                {
                    str = str.Replace("%%" + cursor.GetName(i).ToUpper() + "%%", cursor.GetValue(i).ToString());
                }
            }
            return str;
        }
    }

    /// <summary>
    /// Simple XsltVariable class to return simple bind variables
    /// </summary>
    public class CustomXsltVariable : IXsltContextVariable
    {
        /// <summary>
        /// the value of the variable
        /// </summary>
        private readonly object _value;

        /// <summary>
        /// create a custom variable binding
        /// </summary>
        /// <param name="value">the value of the variable</param>
        public CustomXsltVariable(object value)
        {
            _value = value;
            if (value == null)
            {
                _value = string.Empty;
            }
        }

        #region IXsltContextVariable Members

        /// <summary>
        /// just return the value
        /// </summary>
        /// <param name="context">ignored</param>
        /// <returns>the value</returns>
        public object Evaluate(XsltContext context)
        {
            return _value;
        }

        /// <summary>
        /// Is this a local variable.  we will hardcode to true
        /// </summary>
        public bool IsLocal
        {
            get { return true; }
        }

        /// <summary>
        /// Is this a parameter.  we will hardcode to true
        /// </summary>
        public bool IsParam
        {
            get { return true; }
        }

        /// <summary>
        /// Get the type of the variable.  we will base it off of the underlying value's type
        /// </summary>
        public XPathResultType VariableType
        {
            get
            {
                switch (Type.GetTypeCode(_value.GetType()))
                {
                    case TypeCode.Boolean:
                        return XPathResultType.Boolean;
                    case TypeCode.Byte:
                    case TypeCode.SByte:
                    case TypeCode.UInt16:
                    case TypeCode.UInt32:
                    case TypeCode.UInt64:
                    case TypeCode.Int16:
                    case TypeCode.Int32:
                    case TypeCode.Int64:
                    case TypeCode.Decimal:
                    case TypeCode.Double:
                    case TypeCode.Single:
                        return XPathResultType.Number;
                    case TypeCode.String:
                    case TypeCode.Char:
                    case TypeCode.DBNull:
                    case TypeCode.Empty:
                        return XPathResultType.String;
                    /*case TypeCode.Object:
        case TypeCode.DateTime:*/
                    default:
                        return XPathResultType.Any;
                }
            }
        }

        #endregion
    }

    /// <summary>
    /// Custom XSLT context to house our parameters, and also keep XSLT argument list up to date
    /// </summary>
    public class CustomXsltContext : XsltContext
    {
        /// <summary>
        /// The embedded XSLT argument list.  We just wrap it so that we can keep the parameters in sync
        /// </summary>
        private readonly XsltArgumentList _argumentList = new XsltArgumentList();

        /// <summary>
        /// The XSLT variables we have
        /// </summary>
        public Dictionary<string, Dictionary<string, CustomXsltVariable>> Parameters =
            new Dictionary<string, Dictionary<string, CustomXsltVariable>>();

        /// <summary>
        /// The embedded XSLT argument list.  We just wrap it so that we can keep the parameters in sync
        /// </summary>
        public XsltArgumentList ArgumentList
        {
            get { return _argumentList; }
        }

        /// <summary>
        /// not implemented
        /// </summary>
        /// <exception cref="NotImplementedException">Not Implemented</exception>
        public override bool Whitespace
        {
            get { throw new NotImplementedException(); }
        }

        /// <summary>
        /// add an XSLT variable
        /// </summary>
        /// <param name="name">the variable name</param>
        /// <param name="nmspace">the variable namespace</param>
        /// <param name="value">the value</param>
        public void AddParam(string name, string nmspace, object value)
        {
            string prefix = string.Empty;

            if (!string.IsNullOrEmpty(nmspace))
            {
                prefix = LookupPrefix(nmspace);
            }

            // add it to the embedded argument list first
            _argumentList.AddParam(name, nmspace ?? string.Empty, value);

            // look for the namespace first
            if (!Parameters.ContainsKey(prefix ?? string.Empty))
            {
                // if it does not exist add it
                lock (Parameters)
                {
                    if (!Parameters.ContainsKey(prefix ?? string.Empty))
                    {
                        Parameters.Add(prefix ?? string.Empty, new Dictionary<string, CustomXsltVariable>());
                    }
                }
            }

            // add the variable (or replace it)
            Dictionary<string, CustomXsltVariable> space = Parameters[prefix ?? string.Empty];
            if (space.ContainsKey(name))
            {
                space[name] = new CustomXsltVariable(value);
            }
            else
            {
                space.Add(name, new CustomXsltVariable(value));
            }
        }

        /// <summary>
        /// Just a delegate to the embedded XSLTArgument lists method
        /// </summary>
        /// <param name="namespaceUri">the namespace URI</param>
        /// <param name="extension">the extension object</param>
        public void AddExtensionObject(string namespaceUri, object extension)
        {
            _argumentList.AddExtensionObject(namespaceUri, extension);
        }

        /// <summary>
        /// Resolve the variable
        /// </summary>
        /// <param name="prefix">the namespace prefix</param>
        /// <param name="name">the variable name</param>
        /// <returns>the variable</returns>
        public override IXsltContextVariable ResolveVariable(string prefix, string name)
        {
            if (Parameters.ContainsKey(prefix))
            {
                Dictionary<string, CustomXsltVariable> space = Parameters[prefix];
                if (space.ContainsKey(name))
                {
                    return space[name];
                }
            }
            return null;
        }

        /// <summary>
        /// not implemented
        /// </summary>
        /// <param name="baseUri"></param>
        /// <param name="nextbaseUri"></param>
        /// <exception cref="NotImplementedException">Not Implemented</exception>
        /// <returns></returns>
        public override int CompareDocument(string baseUri, string nextbaseUri)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// not implemented
        /// </summary>
        /// <param name="node"></param>
        /// <exception cref="NotImplementedException">Not Implemented</exception>
        /// <returns></returns>
        public override bool PreserveWhitespace(XPathNavigator node)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// not implemented
        /// </summary>
        /// <param name="prefix"></param>
        /// <param name="name"></param>
        /// <param name="argTypes"></param>
        /// <exception cref="NotImplementedException">Not Implemented</exception>
        /// <returns></returns>
        public override IXsltContextFunction ResolveFunction(string prefix, string name, XPathResultType[] argTypes)
        {
            throw new NotImplementedException();
        }
    }

    /// <summary>
    /// Simple class to hold a parsed query and its parameters
    /// </summary>
    internal class ParsedQuery
    {
        /// <summary>
        /// the parsed query text
        /// </summary>
        public string QueryText { get; set; }

        /// <summary>
        /// the parsed/compiled parameters
        /// </summary>
        public Dictionary<string, XPathExpression> Params { get; set; }
    }

    /// <summary>
    /// XSLTExtension adds extension methods to XSLT
    /// </summary>
    public class XsltExtension
    {
        /// <summary>
        /// the rerun strategy
        /// </summary>
        public DuplicateFileBehaviour RerunStrategy { get; set; }
        /// <summary>
        /// the backup settings
        /// </summary>
        public FileBackupSettings BackupSettings { get; set; }

        /// <summary>
        /// The stream wrapper being used
        /// </summary>
        private readonly WrapperStream _wrapper;

        /// <summary>
        /// The logger being used
        /// </summary>
        private static readonly Logger Logger = new Logger(string.Format("[{0}]", typeof(XsltExtension).Name));

        /// <summary>
        /// cache of created statements (we need to clean them up later)
        /// </summary>
        private static readonly Dictionary<IMTDataReader, IMTAdapterStatement> Statements =
            new Dictionary<IMTDataReader, IMTAdapterStatement>();

        /// <summary>
        /// cache of created connections (we need to clean them up later)
        /// </summary>
        private static readonly Dictionary<IMTAdapterStatement, IMTServicedConnection> Connections =
            new Dictionary<IMTAdapterStatement, IMTServicedConnection>();

        /// <summary>
        /// queryCache to maintain a cache of parsed queries
        /// </summary>
        private readonly ObjectCache _queryCache = new MemoryCache(@"XSLTQueryCache");

        /// <summary>
        /// compiled regex for query variable replacement
        /// </summary>
        private readonly Regex _regex = new Regex(@"%%(\w+)%%");

        /// <summary>
        /// constructor based off of a navigator (for variable resolution later)
        /// </summary>
        /// <param name="nav">the base navigator to use</param>
        /// <param name="wrapper">The stream wrapper being used</param>
        public XsltExtension(XPathNavigator nav, WrapperStream wrapper)
        {
            _wrapper = wrapper;
            Navigator = nav;
        }

        /// <summary>
        /// the associated xslt context
        /// </summary>
        public XsltContext Context { get; set; }

        /// <summary>
        /// The Navigator to use for XPath variable resolution
        /// </summary>
        private XPathNavigator Navigator { get; set; }

        /// <summary>
        /// formats a string ala c#
        /// </summary>
        /// <param name="format">The format of the string</param>
        /// <param name="value">The value to format</param>
        /// <returns>The formatted string</returns>
        public string Format(string format, object value)
        {
            return string.Format(format, value);
        }

        /// <summary>
        /// pads a string
        /// </summary>
        /// <param name="format">The format of the string</param>
        /// <param name="width">The width to format to (negative means left padded)</param>
        /// <returns>The formatted string</returns>
        public string FormatField(string format, int width)
        {
            return FormatField(format, width, ' ');
        }

        /// <summary>
        /// pads a string
        /// </summary>
        /// <param name="format">The format of the string</param>
        /// <param name="width">The width to format to (negative means left padded)</param>
        /// <param name="pad">The character to pad with</param>
        /// <returns>The formatted string</returns>
        public string FormatField(string format, int width, char pad)
        {
            if (format == null)
            {
                format = string.Empty;
            }
            return width < 0 ? format.PadLeft(-width, pad) : format.PadRight(width, pad);
        }

        /// <summary>
        /// formats a decimal
        /// </summary>
        /// <param name="amount">The amount to format</param>
        /// <param name="width">The width to format to (negative means left padded)</param>
        /// <returns>The formatted string</returns>
        public string FormatDecimal(decimal amount, int width)
        {
            return FormatDecimal(amount, width, 0, ' ');
        }

        /// <summary>
        /// formats a date
        /// </summary>
        /// <param name="date">The date to format</param>
        /// <param name="format">The format to use</param>
        /// <returns>The formatted string</returns>
        public string FormatDate(DateTime date, string format)
        {
            return date.ToString(format);
        }

        /// <summary>
        /// formats a decimal
        /// </summary>
        /// <param name="amount">The amount to format</param>
        /// <param name="width">The width to format to (negative means left padded)</param>
        /// <param name="implied">the number of implied decimals</param>
        /// <returns>The formatted string</returns>
        public string FormatDecimal(decimal amount, int width, int implied)
        {
            return FormatDecimal(amount, width, implied, ' ');
        }

        /// <summary>
        /// formats a decimal
        /// </summary>
        /// <param name="amount">The amount to format</param>
        /// <param name="width">The width to format to (negative means left padded)</param>
        /// <param name="implied">the number of implied decimals</param>
        /// <param name="pad">The character to pad with</param>
        /// <returns>The formatted string</returns>
        public string FormatDecimal(decimal amount, int width, int implied, char pad)
        {
            if (implied < 0)
            {
                throw new ArgumentOutOfRangeException("implied");
            }
            for (var i = 0; i < implied; i++)
            {
                amount = amount * 10.0m;
            }
            if (implied > 0)
            {
                amount = decimal.Round(amount);
            }
            return FormatField(amount.ToString(CultureInfo.InvariantCulture), width, pad);
        }

        /// <summary>
        /// Formats a currency amount
        /// </summary>
        /// <param name="currency">the corresponding currency</param>
        /// <param name="amount">the value to format</param>
        /// <returns>The formatted currency amount string</returns>
        public string FormatCurrency(string currency, decimal amount)
        {
            var format = CultureInfo.CurrentCulture.NumberFormat.Clone() as NumberFormatInfo;
            if (format != null)
            {
                switch (currency)
                {
                    case "USD":
                        format.CurrencySymbol = "$";
                        break;
                    case "ALL":
                        format.CurrencySymbol = "Lek";
                        break;
                    case "ARS":
                        format.CurrencySymbol = "$";
                        break;
                    case "AWG":
                        format.CurrencySymbol = "ƒ";
                        break;
                    case "AUD":
                        format.CurrencySymbol = "$";
                        break;
                    case "BSD":
                        format.CurrencySymbol = "$";
                        break;
                    case "BBD":
                        format.CurrencySymbol = "$";
                        break;
                    case "BYR":
                        format.CurrencySymbol = "p.";
                        break;
                    case "BZD":
                        format.CurrencySymbol = "BZ$";
                        break;
                    case "BMD":
                        format.CurrencySymbol = "$";
                        break;
                    case "BOB":
                        format.CurrencySymbol = "$b";
                        break;
                    case "BAM":
                        format.CurrencySymbol = "KM";
                        break;
                    case "BWP":
                        format.CurrencySymbol = "P";
                        break;
                    case "BRL":
                        format.CurrencySymbol = "R$";
                        break;
                    case "BND":
                        format.CurrencySymbol = "$";
                        break;
                    case "CAD":
                        format.CurrencySymbol = "$";
                        break;
                    case "KYD":
                        format.CurrencySymbol = "$";
                        break;
                    case "CLP":
                        format.CurrencySymbol = "$";
                        break;
                    case "CNY":
                        format.CurrencySymbol = "¥";
                        break;
                    case "COP":
                        format.CurrencySymbol = "$";
                        break;
                    case "CRC":
                        format.CurrencySymbol = "¢";
                        break;
                    case "HRK":
                        format.CurrencySymbol = "kn";
                        break;
                    case "CZK":
                        format.CurrencySymbol = "Kc";
                        break;
                    case "DKK":
                        format.CurrencySymbol = "kr";
                        break;
                    case "DOP":
                        format.CurrencySymbol = "RD$";
                        break;
                    case "XCD":
                        format.CurrencySymbol = "$";
                        break;
                    case "EGP":
                        format.CurrencySymbol = "£";
                        break;
                    case "SVC":
                        format.CurrencySymbol = "$";
                        break;
                    case "EEK":
                        format.CurrencySymbol = "kr";
                        break;
                    case "EUR":
                        format.CurrencySymbol = "€";
                        break;
                    case "FKP":
                        format.CurrencySymbol = "£";
                        break;
                    case "FJD":
                        format.CurrencySymbol = "$";
                        break;
                    case "GHC":
                        format.CurrencySymbol = "¢";
                        break;
                    case "GIP":
                        format.CurrencySymbol = "£";
                        break;
                    case "GTQ":
                        format.CurrencySymbol = "Q";
                        break;
                    case "GGP":
                        format.CurrencySymbol = "£";
                        break;
                    case "GYD":
                        format.CurrencySymbol = "$";
                        break;
                    case "HNL":
                        format.CurrencySymbol = "L";
                        break;
                    case "HKD":
                        format.CurrencySymbol = "$";
                        break;
                    case "HUF":
                        format.CurrencySymbol = "Ft";
                        break;
                    case "ISK":
                        format.CurrencySymbol = "kr";
                        break;
                    case "INR":
                        format.CurrencySymbol = "Rs";
                        break;
                    case "IDR":
                        format.CurrencySymbol = "Rp";
                        break;
                    case "IMP":
                        format.CurrencySymbol = "£";
                        break;
                    case "JMD":
                        format.CurrencySymbol = "J$";
                        break;
                    case "JPY":
                        format.CurrencySymbol = "¥";
                        break;
                    case "JEP":
                        format.CurrencySymbol = "£";
                        break;
                    case "LVL":
                        format.CurrencySymbol = "Ls";
                        break;
                    case "LBP":
                        format.CurrencySymbol = "£";
                        break;
                    case "LRD":
                        format.CurrencySymbol = "$";
                        break;
                    case "LTL":
                        format.CurrencySymbol = "Lt";
                        break;
                    case "MYR":
                        format.CurrencySymbol = "RM";
                        break;
                    case "MXN":
                        format.CurrencySymbol = "$";
                        break;
                    case "MZN":
                        format.CurrencySymbol = "MT";
                        break;
                    case "NAD":
                        format.CurrencySymbol = "$";
                        break;
                    case "ANG":
                        format.CurrencySymbol = "ƒ";
                        break;
                    case "NZD":
                        format.CurrencySymbol = "$";
                        break;
                    case "NIO":
                        format.CurrencySymbol = "C$";
                        break;
                    case "NOK":
                        format.CurrencySymbol = "kr";
                        break;
                    case "PAB":
                        format.CurrencySymbol = "B/.";
                        break;
                    case "PYG":
                        format.CurrencySymbol = "Gs";
                        break;
                    case "PEN":
                        format.CurrencySymbol = "S/.";
                        break;
                    case "PLN":
                        format.CurrencySymbol = "zl";
                        break;
                    case "RON":
                        format.CurrencySymbol = "lei";
                        break;
                    case "SHP":
                        format.CurrencySymbol = "£";
                        break;
                    case "SGD":
                        format.CurrencySymbol = "$";
                        break;
                    case "SBD":
                        format.CurrencySymbol = "$";
                        break;
                    case "SOS":
                        format.CurrencySymbol = "S";
                        break;
                    case "ZAR":
                        format.CurrencySymbol = "R";
                        break;
                    case "SEK":
                        format.CurrencySymbol = "kr";
                        break;
                    case "CHF":
                        format.CurrencySymbol = "CHF";
                        break;
                    case "SRD":
                        format.CurrencySymbol = "$";
                        break;
                    case "SYP":
                        format.CurrencySymbol = "£";
                        break;
                    case "TWD":
                        format.CurrencySymbol = "NT$";
                        break;
                    case "TTD":
                        format.CurrencySymbol = "TT$";
                        break;
                    case "TRY":
                        format.CurrencySymbol = "TL";
                        break;
                    case "TRL":
                        format.CurrencySymbol = "£";
                        break;
                    case "TVD":
                        format.CurrencySymbol = "$";
                        break;
                    case "GBP":
                        format.CurrencySymbol = "£";
                        break;
                    case "UYU":
                        format.CurrencySymbol = "$U";
                        break;
                    case "VEF":
                        format.CurrencySymbol = "Bs";
                        break;
                    case "VND":
                        format.CurrencySymbol = "VND";
                        break;
                    case "ZWD":
                        format.CurrencySymbol = "Z$";
                        break;
                    default:
                        format.CurrencySymbol = currency;
                        break;
                }
            }

            return string.Format(format, "{0:C} ", amount);
        }

        /// <summary>
        /// Handle a duplicate filename based on the configuration
        /// </summary>
        /// <param name="rerunStrategy">rerun strategy</param>
        /// <param name="backupSettings">backup settings</param>
        /// <param name="filename">The name of the file</param>
        public static void HandleDuplicateFile(DuplicateFileBehaviour rerunStrategy, FileBackupSettings backupSettings, string filename)
        {
            switch (rerunStrategy)
            {
                case DuplicateFileBehaviour.OverWrite:
                    Logger.LogInfo(string.Format("Overwriting existing file: {0}", filename));
                    break;
                case DuplicateFileBehaviour.Error:
                    Logger.LogError(string.Format("File already exists: {0}", filename));
                    throw new ApplicationException(string.Format("File already exists: {0}", filename));
                case DuplicateFileBehaviour.Backup:
                    var origPath = Directory.GetParent(filename);
                    var origName = Path.GetFileName(filename);
                    var newPath = origPath.FullName;
                    var newName = origName;
                    if (!string.IsNullOrEmpty(backupSettings.FilePath))
                    {
                        newPath = backupSettings.FilePath;
                    }
                    if (!string.IsNullOrEmpty(backupSettings.FileName))
                    {
                        newName = backupSettings.FileName;
                    }
                    var newfile = newPath + Path.DirectorySeparatorChar + newName;
                    var counter = 1;
                    newfile = newfile.Replace("%%ORIG_PATH%%", origPath.FullName).Replace("%%ORIG_NAME%%", origName);
                    var actual = newfile.Replace("%%COUNTER%%", counter.ToString(CultureInfo.InvariantCulture));
                    while (File.Exists(actual) && actual.Contains("%%COUNTER%%") && (backupSettings.MaxBackupsPerFile == 0) || (counter <= backupSettings.MaxBackupsPerFile))
                    {
                        actual = newfile.Replace("%%COUNTER%%", counter.ToString(CultureInfo.InvariantCulture));
                        counter++;
                    }
                    var newdir = Directory.GetParent(newfile);
                    if (!newdir.Exists)
                    {
                        newdir.Create();
                    }
                    Logger.LogDebug(string.Format("Backing up file from: {0} to: {1}", filename, newfile));
                    if (File.Exists(newfile))
                    {
                        File.Delete(newfile);
                    }
                    File.Move(filename, newfile);
                    break;
            }
        }

        /// <summary>
        /// Set the file to output to, which will close the existing output
        /// </summary>
        /// <param name="filename">The filename to write to</param>
        public void SetFile(string filename)
        {
            var dir = Path.GetDirectoryName(filename);
            if ((!string.IsNullOrEmpty(dir)) && (!Directory.Exists(dir)))
            {
                Directory.CreateDirectory(dir);
            }
            if (File.Exists(filename))
            {
                HandleDuplicateFile(RerunStrategy, BackupSettings, filename);
            }
            _wrapper.SetWrapper(File.Create(filename), true);
        }

        /// <summary>
        /// Set the locale to the corresponding locale of the identified account
        /// </summary>
        /// <param name="idAcc">The id of the account</param>
        public void SetLocale(int idAcc)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// clear up all resources.
        /// </summary>
        public void Close()
        {
            lock (Statements)
            {
                var readers = new List<IMTDataReader>();
                readers.AddRange(Statements.Keys);
                foreach (var reader in readers)
                {
                    try
                    {
                        Close(reader);
                    }
                    catch (Exception ex)
                    {
                        Logger.LogException(
                            "Failed to close nested reader/statement/connection opened by XSLTExtension", ex);
                    }
                }
            }
        }

        /// <summary>
        /// support method to cleanup resources, called from CachedXPathNavigator
        /// </summary>
        /// <param name="reader">the reader to free up resources for</param>
        public static void Close(IMTDataReader reader)
        {
            lock (Statements)
            {
                if (!Statements.ContainsKey(reader))
                {
                }
                else
                {
                    try
                    {
                        var statement = Statements[reader];
                        Statements.Remove(reader);
                        reader.Close();
                        reader.Dispose();
                        statement.Dispose();
                        var connection = Connections[statement];
                        Connections.Remove(statement);
                        connection.Close();
                        connection.Dispose();
                    }
                    catch (Exception ex)
                    {
                        Logger.LogException(
                            "Failed to close nested reader/statement/connection opened by XSLTExtension", ex);
                    }
                }
            }
        }

        /// <summary>
        /// Parse a query and pull out variables...
        /// uses a cache to avoid reprocessing...
        /// supports an optional quote character that will be replaced with an actual single quote...
        /// </summary>
        /// <param name="node">the node to use for context evaluation of variables, etc.</param>
        /// <param name="queryText">the query text</param>
        /// <param name="quoteCharacter">what to use for a single quote character</param>
        /// <returns>the parsed query</returns>
        private ParsedQuery ParseQuery(XPathNavigator node, string queryText, string quoteCharacter)
        {
            if (string.IsNullOrEmpty(queryText))
            {
                throw new ArgumentNullException(queryText);
            }

            // check the cache first
            if (_queryCache.Contains(queryText))
            {
                return _queryCache[queryText] as ParsedQuery;
            }

            // handle single quotes, since getting single quotes into XPath expressions is painful (this allows you to use something like '~' instead)
            var query = queryText;
            if ((!string.IsNullOrEmpty(quoteCharacter)) && (!@"'".Equals(quoteCharacter)))
            {
                query = queryText.Replace(quoteCharacter, @"'");
            }

            lock (_queryCache)
            {
                if (_queryCache.Contains(queryText))
                {
                    return _queryCache[queryText] as ParsedQuery;
                }
                // parse the query using the regex
                var parameters = new Dictionary<string, XPathExpression>();
                foreach (Match match in _regex.Matches(query))
                {
                    var split = match.Groups[1].Value;
                    // NOTE: this works with attributes only right now, we could add full xpath easily, but variables do not work for some reason
                    var expression = node.Compile("@" + split);
                    expression.SetContext(Context);
                    parameters.Add("%%" + split + "%%", expression);
                }
                var parsed = new ParsedQuery { QueryText = query, Params = parameters };
                _queryCache.Set(queryText, parsed, null);
                return parsed;
            }
        }

        /// <summary>
        /// execute the query with no special quote character
        /// </summary>
        /// <param name="queryText">the query to execute</param>
        /// <returns>the query results as an xpathnavigator</returns>
        public XPathNavigator ExecuteQuery(string queryText)
        {
            return ExecuteQuery(Navigator, queryText, @"'");
        }

        /// <summary>
        /// execute the adapter query with no special quote character
        /// </summary>
        /// <param name="queryPath">the path containing the query</param>
        /// <param name="queryTag">the query tag to run</param>
        /// <returns>the query results as an xpathnavigator</returns>
        public XPathNavigator ExecuteAdapterQuery(string queryPath, string queryTag)
        {
            return ExecuteAdapterQuery(Navigator, queryPath, queryTag);
        }

        /// <summary>
        /// execute the query
        /// </summary>
        /// <param name="queryText">the query to execute</param>
        /// <param name="quoteCharacter">the character to use as a quote character, or null for no replacement</param>
        /// <returns>the query results as an xpathnavigator</returns>
        public XPathNavigator ExecuteQuery(string queryText, string quoteCharacter)
        {
            return ExecuteQuery(Navigator, queryText, quoteCharacter);
        }

        /// <summary>
        /// execute the adapter query
        /// the results navigator will be present in the form of:
        /// <![CDATA[
        /// <rows>
        ///     <row column1name="column1value" column2name="column2value" .../>
        /// </rows>
        /// ]]>
        /// </summary>
        /// <param name="node">the node to use for context evaluation of variables, etc.</param>
        /// <param name="queryPath">the path containing the query</param>
        /// <param name="queryTag">the query tag to run</param>
        /// <returns>the query results as an xpathnavigator</returns>
        public XPathNavigator ExecuteAdapterQuery(XPathNavigator node, string queryPath, string queryTag)
        {
            string sql;
            using (var conn = ConnectionManager.CreateConnection())
            {
                using (var stmt = conn.CreateAdapterStatement(queryPath, queryTag))
                {
                    sql = stmt.Query;
                }
            }
            return ExecuteQuery(node, sql, @"'");
        }

        /// <summary>
        /// execute the query
        /// the results navigator will be present in the form of:
        /// <![CDATA[
        /// <rows>
        ///     <row column1name="column1value" column2name="column2value" .../>
        /// </rows>
        /// ]]>
        /// </summary>
        /// <param name="node">the node to use for context evaluation of variables, etc.</param>
        /// <param name="queryText">the query to execute</param>
        /// <param name="quoteCharacter">the character to use as a quote character, or null for no replacement</param>
        /// <returns>the query results as an xpathnavigator</returns>
        public XPathNavigator ExecuteQuery(XPathNavigator node, string queryText, string quoteCharacter)
        {
            if (node == null)
            {
                node = Navigator;
            }
            var query = ParseQuery(node, queryText, quoteCharacter);
            IMTAdapterStatement statement = null;
            IMTServicedConnection connection = null;
            IMTDataReader reader = null;
            try
            {
                connection = ConnectionManager.CreateConnection();
                {
                    statement = connection.CreateAdapterStatement(query.QueryText);
                    {
                        foreach (var param in query.Params.Keys)
                        {
                            var value = node.Evaluate(query.Params[param]);
                            if (value is XPathNodeIterator)
                            {
                                var iter = (XPathNodeIterator)value;
                                if (iter.MoveNext())
                                {
                                    if (iter.Current != null)
                                    {
                                        value = iter.Current.Value;
                                    }
                                }
                                else
                                {
                                    value = null;
                                }
                            }
                            else if (value is double) // statement does not like double...
                            {
                                value = Convert.ToDecimal(value);
                            }

                            if (value != null)
                            {
                                statement.AddParam(param, value.ToString());
                            }
                            else
                            {
                                statement.OmitParam(param);
                            }
                        }
                        Logger.LogDebug("Executing nested query: {0}", queryText);
                        reader = statement.ExecuteReader();
                        {
                            lock (Statements)
                            {
                                // keep track of the resources
                                Statements.Add(reader, statement);
                                Connections.Add(statement, connection);
                            }
                            return new CachedXPathNavigator(reader);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                Logger.LogException("Failed to execute query", e);
                try
                {
                    if (reader != null)
                    {
                        reader.Close();
                        reader.Dispose();
                    }
                }
                catch (Exception e2)
                {
                    Logger.LogException("Failed to dispose reader", e2);
                }
                try
                {
                    if (statement != null)
                    {
                        statement.Dispose();
                    }
                }
                catch (Exception e2)
                {
                    Logger.LogException("Failed to dispose statement", e2);
                }
                try
                {
                    if (connection != null)
                    {
                        connection.Close();
                        connection.Dispose();
                    }
                }
                catch (Exception e2)
                {
                    Logger.LogException("Failed to dispose connection", e2);
                }
                throw;
            }
        }
    }

    /// <summary>
    /// used to keep track of where the navigator is
    /// </summary>
    internal enum CursorPositionType
    {
        /// <summary>
        /// at the root /
        /// </summary>
        Root,
        /// <summary>
        /// at <rows></rows>
        /// </summary>
        Results,
        /// <summary>
        /// at <row></row>
        /// </summary>
        Row,
        /// <summary>
        /// inside of <row/> on an attribute
        /// </summary>
        Column
    } ;

    /// <summary>
    /// manager class to process the cursor and keep track of passed results so that we can scroll backwards
    /// </summary>
    public class CursorManager
    {
        private static readonly Logger Logger = new Logger(string.Format("[{0}]", typeof(CursorManager).Name));

        /// <summary>
        /// the cache of results
        /// </summary>
        //        private readonly List<object[]> _cache = new List<object[]>();
        private readonly DiskBackedList<object[]> _cache = new DiskBackedList<object[]>();

        /// <summary>
        /// reverse lookup for field names
        /// </summary>
        private readonly Dictionary<string, int> _names = new Dictionary<string, int>();

        /// <summary>
        /// the current position of the cursor
        /// </summary>
        private int _currentPosition = -1;

        /// <summary>
        /// whether the cursor is done
        /// </summary>
        private bool _done;

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="reader">the cursor to use</param>
        public CursorManager(IMTDataReader reader)
        {
            Reader = reader;
            for (int i = 0; i < reader.FieldCount; i++)
            {
                _names[reader.GetName(i)] = i;
            }
        }

        /// <summary>
        /// the current position
        /// </summary>
        public int CurrentPosition
        {
            get { return _currentPosition; }
        }

        /// <summary>
        /// the cursor itself
        /// </summary>
        public IMTDataReader Reader { get; set; }

        /// <summary>
        /// retrieve the column name for a specific index
        /// </summary>
        /// <param name="col">the index</param>
        /// <returns>the name</returns>
        public string GetName(int col)
        {
            return Reader.GetName(col);
        }

        /// <summary>
        /// returns the index for a given column name
        /// </summary>
        /// <param name="name">the column name</param>
        /// <returns>the column index</returns>
        public int GetPosition(string name)
        {
            if (_names.ContainsKey(name))
            {
                return _names[name];
            }
            return -1;
        }

        /// <summary>
        /// attempts to load up to the desired row number
        /// </summary>
        /// <param name="row">the row number to load up until</param>
        private void LoadRow(int row)
        {
            if (row >= _cache.Count)
            {
                lock (this)
                {
                    while (_cache.Count <= row && !_done)
                    {
                        Logger.LogTrace("Fetching row (current={0})", _currentPosition);
                        if (!Reader.Read())
                        {
                            _done = true;
                            try
                            {
                                XsltExtension.Close(Reader);
                            }
                            catch (Exception ex)
                            {
                                Logger.LogWarning("Failed to close reader {0}", ex.Message);
                            }
                            break;
                        }
                        _currentPosition++;
                        var vals = new object[Reader.FieldCount];
                        for (int i = 0; i < Reader.FieldCount; i++)
                        {
                            if (Reader.IsDBNull(i))
                            {
                                vals[i] = string.Empty;
                            }
                            else
                            {
                                vals[i] = Reader.GetValue(i);
                            }
                        }
                        _cache.Add(vals);
                    }
                }
            }
        }

        /// <summary>
        /// retrieve the corresponding column value
        /// </summary>
        /// <param name="row">the row number</param>
        /// <param name="col">the column number</param>
        /// <returns>the column value, or empty if the row does not exist</returns>
        public object GetValue(int row, int col)
        {
            LoadRow(row);
            if (_cache.Count > row)
            {
                return _cache[row][col];
            }
            return string.Empty;
        }

        /// <summary>
        /// retrieve the corresponding column value
        /// </summary>
        /// <param name="row">the row number</param>
        /// <param name="col">the column name</param>
        /// <returns>the column value, or empty if the row does not exist</returns>
        public object GetValue(int row, string col)
        {
            return GetValue(row, _names[col]);
        }

        /// <summary>
        /// whether the cursor has the row or not
        /// </summary>
        /// <param name="row">the row number</param>
        /// <returns>whether the row exists</returns>
        public bool HasRow(int row)
        {
            if (_cache.Count > row)
            {
                return true;
            }

            LoadRow(row);

            if (_cache.Count > row)
            {
                return true;
            }
            return false;
        }
    }

    /// <summary>
    /// CachedXPathNavigator performs xpath navigation over a cached SQL cursor
    /// </summary>
    public class CachedXPathNavigator : XPathNavigator
    {
        /// <summary>
        /// the cached cursor
        /// </summary>
        private readonly CursorManager _cursor;

        /// <summary>
        /// the internal NameTable to use
        /// </summary>
        private readonly XmlNameTable _nameTable = new NameTable();

        /// <summary>
        /// what column we are on (if inside a row), or -1 if not positioned on a column
        /// </summary>
        private int _col = -1;

        /// <summary>
        /// current node type of the navigator
        /// </summary>
        private CursorPositionType _currentPosition;

        /// <summary>
        /// what row we are on, or -1 for not in rows
        /// </summary>
        private int _row = -1;

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="reader">the cursor to use</param>
        public CachedXPathNavigator(IMTDataReader reader)
        {
            _cursor = new CursorManager(reader);
        }

        /// <summary>
        /// constructor used in cloning
        /// </summary>
        /// <param name="reader">the cursor</param>
        /// <param name="row">current row</param>
        /// <param name="col">current column</param>
        public CachedXPathNavigator(CursorManager reader, int row, int col)
        {
            _cursor = reader;
            _row = row;
            _col = col;
        }

        /// <summary>
        /// NodeType property
        /// </summary>
        public override XPathNodeType NodeType
        {
            get
            {
                switch (_currentPosition)
                {
                    case CursorPositionType.Root:
                        return XPathNodeType.Root;
                    case CursorPositionType.Results:
                        return XPathNodeType.Element;
                    case CursorPositionType.Row:
                        return XPathNodeType.Element;
                    case CursorPositionType.Column:
                        return XPathNodeType.Attribute;
                }
                throw new Exception("Unknown NodeType");
            }
        }

        /// <summary>
        /// The LocalName
        /// </summary>
        public override string LocalName
        {
            get
            {
                switch (_currentPosition)
                {
                    case CursorPositionType.Root:
                        return string.Empty;
                    case CursorPositionType.Results:
                        return "rows";
                    case CursorPositionType.Row:
                        return "row";
                    case CursorPositionType.Column:
                        if (_col >= 0 && _col < _cursor.Reader.FieldCount)
                        {
                            return _cursor.GetName(_col);
                        }
                        return "unknown" + _col;
                }
                throw new Exception("Unknown Node");
            }
        }

        /// <summary>
        /// The name
        /// </summary>
        public override string Name
        {
            get
            {
                switch (_currentPosition)
                {
                    case CursorPositionType.Root:
                        return string.Empty;
                    case CursorPositionType.Results:
                        return "rows";
                    case CursorPositionType.Row:
                        return "row";
                    case CursorPositionType.Column:
                        if (_col >= 0 && _col < _cursor.Reader.FieldCount)
                        {
                            return _cursor.GetName(_col);
                        }
                        return "unknown" + _col;
                }
                throw new Exception("Unknown Node");
            }
        }

        /// <summary>
        /// The NamespaceURI
        /// </summary>
        public override string NamespaceURI
        {
            get { return string.Empty; /* "http://metratech.com/datareader";*/ }
        }

        /// <summary>
        /// The Prefix
        /// </summary>
        public override string Prefix
        {
            get { return string.Empty; }
        }

        /// <summary>
        /// The Value
        /// </summary>
        public override string Value
        {
            get
            {
                switch (_currentPosition)
                {
                    case CursorPositionType.Root:
                        return string.Empty;
                    case CursorPositionType.Results:
                        return string.Empty;
                    case CursorPositionType.Row:
                        return string.Empty;
                    case CursorPositionType.Column:
                        if (_row < 0)
                        {
                            throw new Exception("No row");
                        }
                        object val = _cursor.GetValue(_row, _col);
                        if (val != null)
                        {
                            return Convert.ToString(val);
                        }
                        return string.Empty;
                }
                throw new Exception("Unknown NodeType");
            }
        }

        /// <summary>
        /// The BaseURI
        /// </summary>
        public override String BaseURI
        {
            get { return string.Empty; }
        }

        /// <summary>
        ///  The XmlLang
        /// </summary>
        public override String XmlLang
        {
            get { return string.Empty; }
        }

        /// <summary>
        /// Is this an empty element
        /// </summary>
        public override bool IsEmptyElement
        {
            get { return _currentPosition == CursorPositionType.Results && !_cursor.HasRow(0); }
        }

        /// <summary>
        /// The nametable
        /// </summary>
        public override XmlNameTable NameTable
        {
            get { return _nameTable; }
        }

        /// <summary>
        /// Does it have attributes
        /// </summary>
        public override bool HasAttributes
        {
            get { return _currentPosition == CursorPositionType.Row && _cursor.Reader.FieldCount > 0; }
        }

        /// <summary>
        /// Has children?
        /// </summary>
        public override bool HasChildren
        {
            get
            {
                if (_currentPosition == CursorPositionType.Results && !_cursor.HasRow(0))
                {
                    return false;
                }
                if (_currentPosition == CursorPositionType.Row)
                {
                    return false;
                }
                return true;
            }
        }

        /// <summary>
        /// clone the navigator
        /// </summary>
        /// <returns>a clone</returns>
        public override XPathNavigator Clone()
        {
            var other = new CachedXPathNavigator(_cursor, _row, _col) { _currentPosition = _currentPosition };
            return other;
        }

        /// <summary>
        /// Get an attribute
        /// </summary>
        /// <param name="localName">the localname of the attribute</param>
        /// <param name="namespaceUri">the namespaceURI of the attribute</param>
        /// <returns>the attribute value</returns>
        public override string GetAttribute(string localName, string namespaceUri)
        {
            return GetAttribute(localName);
        }

        /// <summary>
        /// retrieve the attribute value
        /// </summary>
        /// <param name="name">name of the attribute</param>
        /// <returns>the attribute value</returns>
        private string GetAttribute(string name)
        {
            object val = _cursor.GetValue(_row, name);
            if (val != null)
            {
                return val.ToString();
            }
            return string.Empty;
        }

        /// <summary>
        /// Move th navigator to the specified attribute
        /// </summary>
        /// <param name="localName">the localname of the attribute</param>
        /// <param name="namespaceUri">the namespaceURI of the attribute</param>
        /// <returns>whether it successfully moved</returns>
        public override bool MoveToAttribute(string localName, string namespaceUri)
        {
            if (!string.IsNullOrEmpty(namespaceUri))
            {
                throw new Exception("Namespace not supported.");
            }
            if (_currentPosition == CursorPositionType.Row)
            {
                int avail = _cursor.GetPosition(localName);
                if (avail >= 0)
                {
                    _currentPosition = CursorPositionType.Column;
                    _col = avail;
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// Move the navigator to the first attribute
        /// </summary>
        /// <returns>whether it succeeded</returns>
        public override bool MoveToFirstAttribute()
        {
            switch (_currentPosition)
            {
                case CursorPositionType.Row:
                    _currentPosition = CursorPositionType.Column;
                    _col = 0;
                    return true;

                case CursorPositionType.Column:
                    _col = 0;
                    return true;

                default:
                    return false;
            }
        }

        /// <summary>
        /// Move the navigator to the next attribute
        /// </summary>
        /// <returns>whether it succeeded</returns>
        public override bool MoveToNextAttribute()
        {
            if (_col >= (_cursor.Reader.FieldCount - 1))
            {
                return false;
            }
            _col++;
            return true;
        }

        /// <summary>
        /// Get the namespace of the specified localname attribute
        /// </summary>
        /// <param name="name">the localname</param>
        /// <returns>the namespace</returns>
        public override string GetNamespace(string name)
        {
            return string.Empty; // "metratech";
        }

        /// <summary>
        /// Move the navigator to the namespace
        /// </summary>
        /// <param name="name">the localname of the attribute</param>
        /// <returns>whether it succeeded</returns>
        public override bool MoveToNamespace(string name)
        {
            return false; // "metratech".Equals(name);
        }

        /// <summary>
        /// Move the navigator to the first namespace
        /// </summary>
        /// <param name="namespaceScope">the namespace scope</param>
        /// <returns>whether it succeeded</returns>
        public override bool MoveToFirstNamespace(XPathNamespaceScope namespaceScope)
        {
            return false; // true;
        }

        /// <summary>
        /// Move to next namespace
        /// </summary>
        /// <param name="namespaceScope">the namespace scope</param>
        /// <returns>whether it succeeded</returns>
        public override bool MoveToNextNamespace(XPathNamespaceScope namespaceScope)
        {
            return false;
        }

        /// <summary>
        /// Move to next node
        /// </summary>
        /// <returns>whether it succeeded</returns>
        public override bool MoveToNext()
        {
            if (_currentPosition == CursorPositionType.Row && _cursor.HasRow(_row + 1))
            {
                _row++;
                return true;
            }
            return false;
        }

        /// <summary>
        /// Move to previous node
        /// </summary>
        /// <returns>whether it succeeded</returns>
        [SuppressMessage("Microsoft.Naming", "CA2204:Literals should be spelled correctly", MessageId = "XPath")]
        public override bool MoveToPrevious()
        {
            if (_currentPosition == CursorPositionType.Row && _row > 0)
            {
                _row--;
                return true;
            }
            return false;
        }

        /// <summary>
        /// Move to first node
        /// </summary>
        /// <returns>whether it succeeded</returns>
        [SuppressMessage("Microsoft.Naming", "CA2204:Literals should be spelled correctly", MessageId = "XPath")]
        public override bool MoveToFirst()
        {
            if (_currentPosition == CursorPositionType.Row && _cursor.HasRow(0))
            {
                _row = 0;
                return true;
            }
            return false;
        }

        /// <summary>
        /// Move to first child node
        /// </summary>
        /// <returns>whether it succeeded</returns>
        public override bool MoveToFirstChild()
        {
            switch (_currentPosition)
            {
                case CursorPositionType.Root:
                    _currentPosition = CursorPositionType.Results;
                    break;

                case CursorPositionType.Results:
                    _currentPosition = CursorPositionType.Row;
                    _row = 0;
                    break;

                default:
                    return false;
            }
            return true;
        }

        /// <summary>
        /// Move to parent node
        /// </summary>
        /// <returns>whether it succeeded</returns>
        public override bool MoveToParent()
        {
            switch (_currentPosition)
            {
                case CursorPositionType.Root:
                    return false;

                case CursorPositionType.Results:
                    _currentPosition = CursorPositionType.Root;
                    return true;

                case CursorPositionType.Row:
                    _currentPosition = CursorPositionType.Results;
                    _row = -1;
                    return true;

                case CursorPositionType.Column:
                    _currentPosition = CursorPositionType.Row;
                    _col = -1;
                    return true;

                default:
                    return false;
            }
        }

        /// <summary>
        /// Move to root
        /// </summary>
        public override void MoveToRoot()
        {
            _currentPosition = CursorPositionType.Root;
            _col = -1;
            _row = -1;
        }

        /// <summary>
        /// move to same place as other navigator (aka sync)
        /// </summary>
        /// <param name="other">the other navigator to sync with</param>
        /// <returns>whether it succeeded</returns>
        [SuppressMessage("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        public override bool MoveTo(XPathNavigator other)
        {
            var o = other as CachedXPathNavigator;
            if (o != null)
            {
                _currentPosition = o._currentPosition;
                _row = o._row;
                _col = o._col;
                return true;
            }
            return false;
        }

        /// <summary>
        /// Move to ID (not supported)
        /// </summary>
        /// <param name="id">the id to move to</param>
        /// <returns>whether it succeeded (it will not)</returns>
        public override bool MoveToId(string id)
        {
            return false;
        }

        /// <summary>
        /// If it is located at the same position as the other navigator
        /// </summary>
        /// <param name="other">the other navigator</param>
        /// <returns>whether it is in the same position</returns>
        public override bool IsSamePosition(XPathNavigator other)
        {
            var o = other as CachedXPathNavigator;
            if (o != null)
            {
                if (o._currentPosition == _currentPosition && o._row == _row && o._col == _col)
                {
                    return true;
                }
            }
            return false;
        }
    }

    /// <summary>
    /// Disk Backed List to hold records and cache to disk
    /// </summary>
    /// <typeparam name="T">The type of object to persist to disk</typeparam>
    public class DiskBackedList<T> : IDisposable
        where T : class
    {
        /// <summary>
        /// the logger
        /// </summary>
        private readonly Logger _logger = new Logger(string.Format("[{0}]", typeof(DiskBackedList<>).Name));
        /// <summary>
        /// the cache
        /// </summary>
        private readonly ObjectCache _cache = new MemoryCache(@"XSLTResultCache");
        /// <summary>
        /// the filename
        /// </summary>
        private readonly string _filename;
        /// <summary>
        /// the headers
        /// </summary>
        private readonly Dictionary<long, long> _headers = new Dictionary<long, long>();
        /// <summary>
        /// the read stream
        /// </summary>
        private readonly FileStream _readStream;
        /// <summary>
        /// the serializer
        /// </summary>
        private readonly DataContractSerializer _srlzr;
        /// <summary>
        /// the write stream
        /// </summary>
        private readonly FileStream _writeStream;
        /// <summary>
        /// the count
        /// </summary>
        private volatile int _count;

        /// <summary>
        /// constructor
        /// </summary>
        public DiskBackedList()
        {
            _filename = Path.GetTempFileName();
            _writeStream = new FileStream(
                _filename, FileMode.Create, FileAccess.Write, FileShare.Read);
            _readStream = new FileStream(_filename, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            _srlzr = new DataContractSerializer(typeof(T));
        }

        /// <summary>
        /// the count
        /// </summary>
        public int Count
        {
            get { return _count; }
        }

        /// <summary>
        /// number of pages
        /// </summary>
        public int PageSize { get; set; }

        /// <summary>
        /// retrieve the value
        /// </summary>
        /// <param name="row">what row to retrieve</param>
        /// <returns>the row value</returns>
        public T this[int row]
        {
            get
            {
                var offset = _headers[row];
                var value = _cache.Get(row.ToString(CultureInfo.InvariantCulture)) as T;
                if (value == null && !_cache.Contains(row.ToString(CultureInfo.InvariantCulture)))
                {
                    _readStream.Seek(offset, SeekOrigin.Begin);
                    value = (T)_srlzr.ReadObject(_readStream);
                    _cache.Set(row.ToString(CultureInfo.InvariantCulture), value, null);
                }
                return value;
            }
        }

        #region IDisposable Members

        /// <summary>
        /// dispose of the resources
        /// </summary>
        public void Dispose()
        {
            if (_readStream != null)
            {
                try
                {
                    _readStream.Dispose();
                }
                catch (Exception ex)
                {
                    _logger.LogException("Unable to close read stream", ex);
                }
            }
            if (_writeStream != null)
            {
                try
                {
                    _writeStream.Dispose();
                }
                catch (Exception ex)
                {
                    _logger.LogException("Unable to close write stream", ex);
                }
            }
            File.Delete(_filename);
        }

        #endregion

        /// <summary>
        /// Add object to the cache
        /// </summary>
        /// <param name="obj">The object</param>
        public void Add(T obj)
        {
            lock (this)
            {
                _headers[Count] = _writeStream.Position;
                _srlzr.WriteObject(_writeStream, obj);
                _count++;
            }
        }
    }

    /// <summary>
    /// Simple wrapper class to allow us to reopen streams for new files
    /// </summary>
    public class WrapperStream : Stream
    {
        /// <summary>
        /// The wrapped stream to delegate calls to
        /// </summary>
        private Stream _wrapper;
        /// <summary>
        /// Whether to dispose of the wrapped stream
        /// </summary>
        private bool _dispose;

        public void SetWrapper(Stream wrapper, bool dispose = false)
        {
            _wrapper.Close();
            if (_dispose)
            {
                _wrapper.Dispose();
            }
            _wrapper = wrapper;
            _dispose = dispose;
        }

        /// <summary>
        /// create a new wrapper stream with the supplied stream
        /// </summary>
        /// <param name="wrapper">The stream to delegate all calls to</param>
        public WrapperStream(Stream wrapper)
        {
            _wrapper = wrapper;
            _dispose = false;
        }

        #region WrappedCalls
        public override void Flush()
        {
            _wrapper.Flush();
        }

        public override long Seek(long offset, SeekOrigin origin)
        {
            return _wrapper.Seek(offset, origin);
        }

        public override void SetLength(long value)
        {
            _wrapper.SetLength(value);
        }

        public override int Read(byte[] buffer, int offset, int count)
        {
            return _wrapper.Read(buffer, offset, count);
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            _wrapper.Write(buffer, offset, count);
        }

        public override bool CanRead
        {
            get { return _wrapper.CanRead; }
        }

        public override bool CanSeek
        {
            get { return _wrapper.CanSeek; }
        }

        public override bool CanWrite
        {
            get { return _wrapper.CanWrite; }
        }

        public override long Length
        {
            get { return _wrapper.Length; }
        }

        public override long Position { get { return _wrapper.Position; } set { _wrapper.Position = value; } }

        public override IAsyncResult BeginRead(byte[] buffer, int offset, int count, AsyncCallback callback, object state)
        {
            return _wrapper.BeginRead(buffer, offset, count, callback, state);
        }
        public override IAsyncResult BeginWrite(byte[] buffer, int offset, int count, AsyncCallback callback, object state)
        {
            return _wrapper.BeginWrite(buffer, offset, count, callback, state);
        }
        public override bool CanTimeout
        {
            get
            {
                return _wrapper.CanTimeout;
            }
        }
        public override void Close()
        {
            _wrapper.Close();
        }
        public override System.Runtime.Remoting.ObjRef CreateObjRef(Type requestedType)
        {
            return _wrapper.CreateObjRef(requestedType);
        }
        protected override void Dispose(bool disposing)
        {
            if (_dispose)
            {
                _wrapper.Dispose();
            }
            base.Dispose(disposing);
        }
        public override int EndRead(IAsyncResult asyncResult)
        {
            return _wrapper.EndRead(asyncResult);
        }
        public override void EndWrite(IAsyncResult asyncResult)
        {
            _wrapper.EndWrite(asyncResult);
        }
        public override bool Equals(object obj)
        {
            return _wrapper.Equals(obj);
        }
        public override int GetHashCode()
        {
            return _wrapper.GetHashCode();
        }
        public override object InitializeLifetimeService()
        {
            return _wrapper.InitializeLifetimeService();
        }
        public override int ReadByte()
        {
            return _wrapper.ReadByte();
        }
        public override int ReadTimeout
        {
            get
            {
                return _wrapper.ReadTimeout;
            }
            set
            {
                _wrapper.ReadTimeout = value;
            }
        }
        public override string ToString()
        {
            return _wrapper.ToString();
        }
        public override void WriteByte(byte value)
        {
            _wrapper.WriteByte(value);
        }
        public override int WriteTimeout
        {
            get
            {
                return _wrapper.WriteTimeout;
            }
            set
            {
                _wrapper.WriteTimeout = value;
            }
        }
        #endregion
    }
}
