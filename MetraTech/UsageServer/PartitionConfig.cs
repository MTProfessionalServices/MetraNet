using System;
using System.Collections.Specialized;
using System.Runtime.InteropServices;
using System.Xml;
using MetraTech.DataAccess;
using MetraTech.Xml;

namespace MetraTech.UsageServer
{
    /// <summary>
    /// Partition config information for reporting the outcome of sync ops.
    /// </summary>
    [ComVisible(false)] // Not yet.
    public class PartitionConfig : IPartitionConfig
    {
        #region Private Fields

        // Fields for partition configuration from DB
        private bool _enabled;
        private string _type;
        private int _dataSize;
        private int _logSize;
        private readonly StringCollection _storagePaths = new StringCollection();

        // Fields for partition configuration from config file
        private bool _enabledFromXml;
        private string _typeFromXml;
        private int _dataSizeFromXml;
        private int _logSizeFromXml;
        private readonly StringCollection _storagePathsFromXml = new StringCollection();

        private readonly ILogger _logger;
        private readonly CreateConnectionDelegate _createConnectionDelegate;
        private readonly CreateNonServicedConnectionDelegate _createNonServicedConnectionDelegate;

        #endregion

        public delegate IMTConnection CreateConnectionDelegate();
        public delegate IMTNonServicedConnection CreateNonServicedConnectionDelegate();

        /// <summary>
        /// Shows whether partition is enabled on current DB
        /// </summary>
        public bool IsPartitionEnabled
        {
            get { return _enabled; }
        }

        #region Constructors

        /// <summary>
        /// Constructor with default initialization
        /// </summary>
        public PartitionConfig()
            : this(ConnectionManager.CreateConnection, ConnectionManager.CreateNonServicedConnection,
                   new Logger("[PartitionCfg]"))
        {
        }

        public PartitionConfig(CreateConnectionDelegate createConnDelegate, CreateNonServicedConnectionDelegate createNonServConnDelegate, ILogger logger)
        {
            _createConnectionDelegate = createConnDelegate;
            _createNonServicedConnectionDelegate = createNonServConnDelegate;
            _logger = logger;
            AppendPartitionConfig();
        }

        #endregion

        /// <summary>
        /// Synchronizes the database with partition settings in any given file
        /// </summary>
        public void Synchronize()
        {
            _logger.LogDebug("Synchronizing partition settings from {0} configuration file",
                             UsageServerCommon.UsageServerConfigFile);

            // Loaded values from xml now put in the database
            using (var conn = _createNonServicedConnectionDelegate())
            {
                // Skip sync if configs are equivalent
                if (IsSynchronized())
                {
                    Console.WriteLine("  No Partitioning changes detected.");
                    return;
                }

                // Show changes
                ShowConfigDiffs();

                // Check path list in xml config
                if (_enabledFromXml && _storagePathsFromXml.Count < 1)
                    throw new InvalidConfigurationException("Partitioning requires at least one storage path.");

                // Can't turn partitioning off if it's already on
                if (_enabled && !_enabledFromXml)
                    throw new InvalidConfigurationException("Partitioning cannot be disabled once enabled.");

                try
                {
                    SynchronizeOptions(conn);
                    SynchronizeStoragePaths(conn);
                    conn.CommitTransaction();
                }
                catch (Exception e)
                {
                    conn.RollbackTransaction();
                    throw new UsageServerException("Unable to synchronize database with partition config file", e);
                }
            }
        }

        #region Private Methods

        private bool IsSynchronized()
        {
            return _enabled == _enabledFromXml &&
                   _type.Equals(_typeFromXml) &&
                   _dataSize == _dataSizeFromXml &&
                   _logSize == _logSizeFromXml &&
                   StoragePathsAreEqual();
        }

        private bool StoragePathsAreEqual()
        {
            // same number of paths
            if (_storagePaths.Count != _storagePathsFromXml.Count)
                return false;

            // same paths in same order
            for (int i = 0; i < _storagePaths.Count; i++)
                if (String.Compare(_storagePaths[i], _storagePathsFromXml[i], true) != 0)
                    return false;

            return true;
        }

        /// <summary>
        /// Stores options in database
        /// </summary>
        /// <param name="conn">An IMTConnection</param>
        /// <returns>Nothing</returns>
        private void SynchronizeOptions(IMTConnection conn)
        {
            _logger.LogInfo("Updating database with options, Enabled={0}, Type={1}, DataSize={2}, LogSize={3}",
                            _enabledFromXml, _typeFromXml, _dataSizeFromXml, _logSizeFromXml);

            using (IMTCallableStatement stmt = conn.CreateCallableStatement("SetPartitionOptions"))
            {
                stmt.AddParam("enable", MTParameterType.String, _enabledFromXml ? "Y" : "N");
                stmt.AddParam("type", MTParameterType.String, _typeFromXml);
                stmt.AddParam("datasize", MTParameterType.Integer, _dataSizeFromXml);
                stmt.AddParam("logsize", MTParameterType.Integer, _logSizeFromXml);

                stmt.ExecuteNonQuery();

            }
        }

        /// <summary>
        /// Updates partition storage path metadata in database
        /// </summary>
        /// <param name="conn">An IMTConnection</param>
        private void SynchronizeStoragePaths(IMTConnection conn)
        {
            _logger.LogInfo("Updating database with storage paths");

            // Delete all current pathes
            using (var stmt = conn.CreatePreparedStatement("delete from t_partition_storage"))
            {
                stmt.ExecuteNonQuery();
            }

            // Append t_partition_storage with paths from config file
            foreach (string path in _storagePathsFromXml)
            {
                _logger.LogInfo("Updating database with storage path {0}", path);
                using (var sp = conn.CreateCallableStatement("AddPartitionStoragePath"))
                {
                    sp.AddParam("path", MTParameterType.String, path);
                    sp.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Displays difference in config on console.
        /// </summary>
        private void ShowConfigDiffs()
        {
            _logger.LogDebug("Partitioning config changes:");
            if (_enabled != _enabledFromXml)
                _logger.LogDebug("  Enabled    : {0} => {1}", _enabled, _enabledFromXml);

            if (_type != _typeFromXml)
                _logger.LogDebug("  Type       : {0} => {1}", _type, _typeFromXml);

            if (_dataSize != _dataSizeFromXml)
                _logger.LogDebug("  DataSize   : {0} => {1}", _dataSize, _dataSizeFromXml);

            if (_logSize != _logSizeFromXml)
                _logger.LogDebug("  LogSize    : {0} => {1}", _logSize, _logSizeFromXml);

            if (!StoragePathsAreEqual())
                foreach (string path in _storagePathsFromXml)
                    _logger.LogDebug("  StoragePath: {0}", path);

            _logger.LogDebug("");
        }

        private void AppendPartitionConfig()
        {
            ParseOptionsFromDb();
            ParseOptionsFromXml(UsageServerCommon.UsageServerConfigFile);
        }

        /// <summary>
        /// Reads current partitioning config from DB
        /// </summary>
        private void ParseOptionsFromDb()
        {
            using (var conn = _createConnectionDelegate())
            {
                // Get scalar options first...
                const string qopts = @"select b_partitioning_enabled, partition_type, " +
                                     "partition_data_size, partition_log_size from t_usage_server";

                using (var stmt = conn.CreatePreparedStatement(qopts))
                {
                    using (var rdr = stmt.ExecuteReader())
                    {
                        int cnt = 0;
                        while (rdr.Read())
                        {
                            if (cnt++ > 1)
                                throw new ApplicationException("Too many rows in t_usage_server");

                            _enabled = rdr.GetBoolean("b_partitioning_enabled");
                            _type = rdr.GetString("partition_type");
                            _dataSize = rdr.GetInt32("partition_data_size");
                            _logSize = rdr.GetInt32("partition_log_size");
                        }

                        if (cnt < 1)
                            throw new ApplicationException("No row found in t_usage_server");

                    }
                }

                // ...and then the list of storage paths.
                const string qpaths = @"select path from t_partition_storage";
                using (var stmtPaths = conn.CreatePreparedStatement(qpaths))
                {
                    using (var rdr = stmtPaths.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            _storagePaths.Add(rdr.GetString("path").TrimEnd());
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Loads a partitioning config from an xml file
        /// </summary>
        private void ParseOptionsFromXml(string configFile)
        {
            var doc = new MTXmlDocument();
            doc.LoadConfigFile(configFile);

            // Check config file version
            int version = doc.GetNodeValueAsInt("/xmlconfig/version");
            if (version < 2)
                throw new InvalidConfigurationException("Partitioning requires a version 2 " +
                                                        " or greater config file.");

            // Get options
            _enabledFromXml = doc.GetNodeValueAsBool("/xmlconfig/Partitions/Enable", _enabledFromXml);
            _logger.LogDebug("Enable   : {0} ", _enabledFromXml);

            _typeFromXml = doc.GetNodeValueAsString("/xmlconfig/Partitions/Type", _typeFromXml);
            _logger.LogDebug("Type     : {0} ", _typeFromXml);

            _dataSizeFromXml = doc.GetNodeValueAsInt("/xmlconfig/Partitions/DataSize", _dataSizeFromXml);
            _logger.LogDebug("DataSize : {0} ", _dataSizeFromXml);

            _logSizeFromXml = doc.GetNodeValueAsInt("/xmlconfig/Partitions/LogSize", _logSizeFromXml);
            _logger.LogDebug("LogSize  : {0} ", _logSizeFromXml);

            // Get storage paths
            XmlNodeList paths = doc.SelectNodes("/xmlconfig/Partitions/StoragePaths/Path");
            foreach (XmlNode node in paths)
            {
                string path = MTXmlDocument.GetNodeValueAsString(node);
                _storagePathsFromXml.Add(path);
                _logger.LogDebug("StoragePath : {0} ", path);
            }
        }

        #endregion
    }
}