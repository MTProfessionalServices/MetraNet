using System;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.Xml;
using MetraTech.ActivityServices.Configuration;
using MetraTech.Interop.RCD;
using System.Configuration;
using System.IO;

namespace MetraTech.ActivityServices.Services.Common
{
    internal class MASPerfConfigWatcher
    {
        private static MASPerfLoggingConfig mCurrentConfig;
        private static FileSystemWatcher mFileSystemWatcher;

        private static string mFilePath;
        private const string CONFIG_FILENAME = "masperflogging.config";

        public delegate void MASPerfConfigChanged();

        public static event MASPerfConfigChanged ConfigChanged;

        static MASPerfConfigWatcher()
        {
            IMTRcd rcd = new MTRcd();
            mFilePath = Path.Combine(rcd.ConfigDir, @"Logging\ActivityServices\Perf");

            LoadConfig();

            mFileSystemWatcher = new FileSystemWatcher(mFilePath, CONFIG_FILENAME);
            mFileSystemWatcher.Changed += new FileSystemEventHandler(mFileSystemWatcher_Changed);
            mFileSystemWatcher.EnableRaisingEvents = true;
        }

        private static void LoadConfig()
        {
            ExeConfigurationFileMap map = new ExeConfigurationFileMap();
            map.ExeConfigFilename = Path.Combine(mFilePath, CONFIG_FILENAME);
            System.Configuration.Configuration config = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);
            mCurrentConfig = (MASPerfLoggingConfig)config.GetSection("MASPerfLoggingConfig");
        }

        static void mFileSystemWatcher_Changed(object sender, FileSystemEventArgs e)
        {
            LoadConfig();

            ConfigChanged();
        }

        public static bool GetServiceConfig(string serviceName, out Dictionary<string, bool> operationConfigs)
        {
            bool serviceEnabled = false;
            operationConfigs = new Dictionary<string, bool>(StringComparer.InvariantCultureIgnoreCase);

            MASPerfLoggingConfig config = mCurrentConfig;

            if (config.Services[serviceName] != null)
            {
                serviceEnabled = config.Services[serviceName].Enabled;

                foreach (MASPerfLoggingOperation operation in config.Services[serviceName].Operations)
                {
                    operationConfigs[operation.Name] = operation.Enabled;
                }
            }

            return serviceEnabled;
        }
    }

    internal class MASRequestLogger
    {
        private Logger mLogger = new Logger(@"Logging\ActivityServices\Perf", "[RequestLogger]");
        private string mServiceName;
        private ConcurrentDictionary<UniqueId, RequestPerformanceRecord> mActiveRequests = new ConcurrentDictionary<UniqueId, RequestPerformanceRecord>();
        private bool mServiceLoggingEnabled = false;
        private Dictionary<string, bool> mOperationConfigurations;

        public MASRequestLogger(string serviceName)
        {
            mServiceName = serviceName;

            MASPerfConfigWatcher.ConfigChanged += new MASPerfConfigWatcher.MASPerfConfigChanged(MASPerfConfigWatcher_ConfigChanged);

            MASPerfConfigWatcher_ConfigChanged();
        }

        void MASPerfConfigWatcher_ConfigChanged()
        {
            Dictionary<string, bool> operationConfigs = null;
            mServiceLoggingEnabled = MASPerfConfigWatcher.GetServiceConfig(mServiceName, out operationConfigs);

            mOperationConfigurations = operationConfigs;
        }

        public void MessageStarted(UniqueId messageId, string action)
        {
            Uri actionUri = new Uri(action);
            string operation = actionUri.Segments[actionUri.Segments.Length - 1];

            Dictionary<string, bool> operationConfigs = mOperationConfigurations;
            bool enabled;

            if (!operationConfigs.TryGetValue(operation, out enabled))
            {
                enabled = false;
            }

            if (mServiceLoggingEnabled && enabled)
            {
                RequestPerformanceRecord perfRec = new RequestPerformanceRecord(mLogger, messageId, mServiceName, operation);

                mActiveRequests[messageId] = perfRec;
            }
        }

        public void MessageCompleted(UniqueId messageId)
        {
            if (mActiveRequests.ContainsKey(messageId))
            {
                RequestPerformanceRecord perfReq = mActiveRequests[messageId];

                perfReq.CompleteRequest();

                RequestPerformanceRecord removedValue;
                if (mActiveRequests.TryRemove(messageId, out removedValue) == false)
                {
                    mLogger.LogError(
                        "MASRequestLogger::MessageCompleted(): failed to remove entry with key {0} from mActiveRequests, ignoring this failure",
                        messageId);
                }
         
            }
        }
    }


    internal class RequestPerformanceRecord
    {
        private readonly Stopwatch mStopwatch = new Stopwatch();
        private readonly UniqueId mMessageId;
        private readonly string mServiceName;
        private readonly string mOperation;
        private readonly DateTime mStartTime = DateTime.Now;
        private Logger mLogger;

        public RequestPerformanceRecord(Logger logger, UniqueId messageId, string serviceName, string operation)
        {
            mLogger = logger;
            mMessageId = messageId;
            mServiceName = serviceName;
            mOperation = operation;
            mStopwatch.Start();
        }

        public void CompleteRequest()
        {
            mStopwatch.Stop();
            DateTime endTime = DateTime.Now;

            mLogger.LogInfo(",{0},{1},{2},{3},{4},{5}", mServiceName, mOperation, mMessageId, mStartTime.ToString("o"), endTime.ToString("o"), mStopwatch.ElapsedMilliseconds);
        }
    }
}
