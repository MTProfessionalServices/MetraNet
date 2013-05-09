using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Core.Services.ClientProxies;

using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ComponentModel;
using System.Runtime;
using System.ServiceModel.Description;
using websvcs;


namespace BaselineGUI
{
    public class ActSvcClient
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ActSvcClient));

        public ICommunicationObject client = null;
        public bool allocated = false;

        public static string authName { get { return PrefRepo.active.actSvcs.authName; } }
        public static string authPwd { get { return PrefRepo.active.actSvcs.authPassword; } }

        public ClientCredentials credentials
        {
            get
            {
                if (client == null)
                {
                    log.Error("Trying to get credentials for null client?");
                    return null;
                }
                if (client is AccountServiceClient)
                {
                    return ((AccountServiceClient)client).ClientCredentials;
                }
                if (client is SubscriptionServiceClient)
                {
                    return ((SubscriptionServiceClient)client).ClientCredentials;
                }
                if (client is UsageHistoryServiceClient)
                {
                    return ((UsageHistoryServiceClient)client).ClientCredentials;
                }
                if (client is AuditLogServiceClient)
                {
                    return ((AuditLogServiceClient)client).ClientCredentials;
                }
                if (client is MAMHierarchyWebSvcSoapClient)
                {
                    return ((MAMHierarchyWebSvcSoapClient)client).ClientCredentials;
                }

                log.Error("Trying to get credentials for unknown client type?");
                return null;
            }
        }

        public static ActSvcClient makeClient<T>() where T : ICommunicationObject, new()
        {
            ActSvcClient wrapper = new ActSvcClient();
            wrapper.client = new T();
            if( wrapper.client != null)
            {
            log.Debug("MakeClient succeeded");
            }
            wrapper.credentials.UserName.UserName = authName;
            wrapper.credentials.UserName.Password = authPwd;
            return wrapper;
        }

        public void Open()
        {
            client.Open();
        }

        public void Close()
        {
            client.Close();
        }
    }
}
