using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Core.Services.ClientProxies;

using System.ServiceModel;
using System.ServiceModel.Channels;
using log4net;

namespace BaselineGUI
{
    public class FCActSvcClient : FrameworkComponentBase, IFrameworkComponent
    {
      private static readonly ILog log = LogManager.GetLogger(typeof(FCActSvcClient));

        public static string authName { get { return PrefRepo.active.actSvcs.authName; } }
        public static string authPwd { get { return PrefRepo.active.actSvcs.authPassword; } }


        public FCActSvcClient()
        {
            name = "ActivityServices";
            fullName = "Activity Services Client";
            priority = 2;
        }

        public void Bringup()
        {
            bool success = false;

            try
            {
                AccountServiceClient client;
                client = new AccountServiceClient();
                client.ClientCredentials.UserName.UserName = authName;
                client.ClientCredentials.UserName.Password = authPwd;
                client.Open();
                client.Close();
                success = true;
            }
            catch(Exception ex)
            {
              log.ErrorFormat("Failed: {0}", ex.ToString());
            }

            if (success)
            {
                bringupState.message = "Connected";
            }
            else
            {
                bringupState.message = "Connection failed";
            }
        }


        public void Teardown()
        {
        }
    }
}
