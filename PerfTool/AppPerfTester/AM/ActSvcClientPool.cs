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

namespace BaselineGUI
{
    public static class ActSvcClientPool
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ActSvcClientPool));

        static Object mutex = new Object();

        public static List<ActSvcClient> clients = new List<ActSvcClient>();

        public static bool acquire<T>(out T client) where T : ICommunicationObject, new()
        {
            client = default(T);

            lock (mutex)
            {
                foreach (ActSvcClient c in clients)
                {
                    if (c.allocated)
                        continue;
                    if (c.client is T)
                    {
                        c.allocated = true;
                        client = (T)c.client;
                        return true;
                    }
                }
            }

            ActSvcClient ac = ActSvcClient.makeClient<T>();
            ac.Open();
            ac.allocated = true;

            lock (mutex)
            {
                clients.Add(ac);
                client = (T)ac.client;
            }

            return true;
        }

        public static void release(ICommunicationObject client)
        {
            foreach (ActSvcClient c in clients)
            {
                if (c.client == client)
                {
                    c.allocated = false;
                }
            }
        }

        public static void closeAll()
        {
            foreach (ActSvcClient c in clients)
            {
                c.Close();
            }
        }

        internal static void dispose(ICommunicationObject client)
        {
            if (null == client)
                return;
            else
            {
                try
                {
                    client.Abort();
                }
                finally
                {
                    client.Close();
                }
            }
        }        
    }
}
