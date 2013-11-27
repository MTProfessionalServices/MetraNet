using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.ServiceModel;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Billing;


namespace BaselineGUI
{
    public class AMOpenWebClient : AppMethodBase, AppMethodI
    {
        Statistic statistic;

        public AMOpenWebClient()
        {
            group = "other";
            name = "openWebClient";
            fullName = "Open Web Client";
            statistic = useStatistic(name);

            commands.Add("go", cmdGo);
        }

        public void setup() { }
        public void teardown() { }
        public void dispose() { }
        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();
            AccountServiceClient client;

            client = new AccountServiceClient();
            client.ClientCredentials.UserName.UserName = authName;
            client.ClientCredentials.UserName.Password = authPwd;
            watch.Restart();
            client.Open();
            watch.Stop();
            statistic.addSample(watch.ElapsedMilliseconds);
            client.Close();

            client = null;
        }

    }
}
