using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.ServiceModel;
using System.Text;
using System.Threading;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DataAccess;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.RCD;
using MetraTech.UsageServer;
using MetraTech.Xml;
using ServerAccess = MetraTech.Interop.MTServerAccess;

namespace MetraTech.UsageServer.Adapters
{
    public class CleanupFailedTransactionsAdapter : IRecurringEventAdapter
    {
        private Logger mLogger = new Logger("[CleanupFailedTransactionsAdapter]");
        private int mExpirationTime = 24;
        private int mMaxThreads = 0;
        private string mWCFConfigFile;
        private string mEndpointName;

        public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
        {
            mLogger.LogDebug("Initializing test adapter (config file = {0})",
                             configFile);
            ReadConfig(configFile);

            if (limitedInit)
                mLogger.LogDebug("Limited initialization requested");
            else
                mLogger.LogDebug("Full initialization requested");

        }

        public string Execute(IRecurringEventRunContext context)
        {
            ConvertOpenTransactions();
            if (mMaxThreads != 0)
            {
                ThreadPool.SetMaxThreads(mMaxThreads, mMaxThreads);
            }

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (
                    IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ElectronicPaymentService",
                                                                           "__GET_FAILED_TRANSACTIONS__"))
                {
                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            try
                            {
                                string temp = rdr.GetString("txId");
                                Guid txId = Guid.Parse(temp);
                                ThreadPool.QueueUserWorkItem(CleanUpTransaction, txId);
                            }
                            catch (Exception e)
                            {
                                mLogger.LogException("Couldn't void transaction.", e);
                            }
                        }
                    }
                }
            }

            var client = MASClientClassFactory.CreateClient<CleanupTransactionServiceClient>(mWCFConfigFile, mEndpointName);
            ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
            sa.Initialize();
            ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
            string suName = accessData.UserName;
            string suPassword = accessData.Password;
            client.ClientCredentials.UserName.UserName = suName;
            client.ClientCredentials.UserName.Password = suPassword;
            client.Open();
            client.ResetNumOpenTransactions();
            client.Close();

            return "cleanup adapter finished executing.";
        }

        public string Reverse(IRecurringEventRunContext context)
        {
            string detail;

            detail = string.Format("Reverse Not Needed/Not Implemented");
            return detail;
        }

        public void Shutdown()
        {
            mLogger.LogDebug("Shutting down cleanup Adapter");
        }

        public bool SupportsScheduledEvents{ get { return true; } }
        public bool SupportsEndOfPeriodEvents {get { return false; }}
        public ReverseMode Reversibility { get { return ReverseMode.NotNeeded; } }
        public bool AllowMultipleInstances{get { return false; }}

        private void ReadConfig(string configFile)
        {
            MTXmlDocument doc = new MTXmlDocument();
            doc.Load(configFile);

            mExpirationTime = doc.GetNodeValueAsInt("/xmlconfig/MaxOpenTransactionHours", 24);
            mMaxThreads = doc.GetNodeValueAsInt("/xmlconfig/MaxThreads", 20);
            mWCFConfigFile = doc.GetNodeValueAsString("/xmlconfig/ConfigFile", "CleanupService.xml");
            // Get the endpoint name etc from the config file
            Configuration config;
            ExeConfigurationFileMap map = new ExeConfigurationFileMap();
            MTRcd rcd = new MTRcdClass();
            map.ExeConfigFilename = Path.Combine(rcd.ExtensionDir, mWCFConfigFile);

            config = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

            if (!Path.IsPathRooted(mWCFConfigFile))
            {
                mWCFConfigFile = Path.Combine(rcd.ExtensionDir, mWCFConfigFile);
            }

            mLogger.LogDebug(mWCFConfigFile);

            mEndpointName = doc.GetNodeValueAsString("/xmlconfig/EndPoint");
        }


        //Covert open transactions older than mExpirationTime to be failed.
        private void ConvertOpenTransactions()
        {
            IMTQueryAdapter qa = new MTQueryAdapter();
            qa.Init("Queries\\ElectronicPaymentService");
            qa.SetQueryTag("__CONVERT_OPEN_TRANSACTIONS_TO_FAILED__");
            string updateTx = qa.GetQuery();

            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(updateTx))
                {

                    stmt.AddParam("end_time", MTParameterType.DateTime, MetraTime.Now.AddHours(0 - mExpirationTime));
                    stmt.ExecuteNonQuery();
                    stmt.ClearParams();
                }
            }
        }

        private void CleanUpTransaction(Object txId)
        {
            var client = MASClientClassFactory.CreateClient<CleanupTransactionServiceClient>(mWCFConfigFile, mEndpointName);
            ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
            sa.Initialize();
            ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
            client.ClientCredentials.UserName.UserName = accessData.UserName;
            client.ClientCredentials.UserName.Password = accessData.Password;
            client.Open();
            try
            {
                client.VoidTransaction((Guid)txId, 0, "");
            }
            catch (Exception e)
            {
                mLogger.LogException(String.Format("Voiding transaction {0} failed.", txId), e);
            }
            finally
            {
                client.Close();
            }
        }
    }
}
