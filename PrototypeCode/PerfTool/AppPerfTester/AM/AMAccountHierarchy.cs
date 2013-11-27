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
using BaselineGUI.AccountHierarchy;
using websvcs;

namespace BaselineGUI
{
    public class AMAccountHierarchy : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        private AccountHierarchy.MAMHierarchyWebSvc service = null;
        AccountServiceClient accountClient = null;

        public AMAccountHierarchy()
        {
            group = "account";
            name = "accountHierarchy";
            fullName = "Account Hierarchy";
            statistic = useStatistic(name);

            commands.Add("go", cmdGo);
        }

        public void setup()
        {
            acquireClient(out accountClient);
        }

        public void teardown()
        {
            releaseClient(accountClient);
            accountClient = null;
        }

        public void dispose()
        {
            disposeClient(accountClient);
            accountClient = null;
        }
        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();
            service = new MAMHierarchyWebSvc();
            DateTime timeStamp = DateTime.Now;
           
            object[] visibleAccounts = new object[0];

            watch.Restart();
            object[] nodes  =  service.GetHierarchyLevel("system_mps", 1, DateTime.Now,
              "PHNlY3VyaXR5Y29udGV4dD48aWRfYWNjPjEzNzwvaWRfYWNjPjxyb2xlcz48cm9sZT5TdXBlciBVc2VyPC9yb2xlPjwvcm9sZXM+PGNvbXBvc2l0ZWNhcGFiaWxpdGllcz48Y29tcG9zaXRlY2FwYWJpbGl0eT48bmFtZT5VbmxpbWl0ZWQgQ2FwYWJpbGl0eTwvbmFtZT48cHJvZ2lkPk1ldHJhdGVjaC5NVEFsbENhcGFiaWxpdHk8L3Byb2dpZD48ZGJpZD41MDwvZGJpZD48L2NvbXBvc2l0ZWNhcGFiaWxpdHk+PGNvbXBvc2l0ZWNhcGFiaWxpdHk+PG5hbWU+TWFuYWdlIEFjY291bnQgSGllcmFyY2hpZXM8L25hbWU+PHByb2dpZD5NZXRyYXRlY2guTVRNYW5hZ2VBSENhcGFiaWxpdHk8L3Byb2dpZD48ZGJpZD45NDwvZGJpZD48YXRvbWljY2FwYWJpbGl0aWVzPjxtdGVudW10eXBlY2FwYWJpbGl0eT48dmFsdWU+V1JJVEU8L3ZhbHVlPjwvbXRlbnVtdHlwZWNhcGFiaWxpdHk+PG10cGF0aGNhcGFiaWxpdHk+PHZhbHVlPi8xMzcvPC92YWx1ZT48d2lsZGNhcmQ+MDwvd2lsZGNhcmQ+PC9tdHBhdGhjYXBhYmlsaXR5PjwvYXRvbWljY2FwYWJpbGl0aWVzPjwvY29tcG9zaXRlY2FwYWJpbGl0eT48L2NvbXBvc2l0ZWNhcGFiaWxpdGllcz48YXBwbGljYXRpb25uYW1lPk1ldHJhTmV0PC9hcHBsaWNhdGlvbm5hbWU+PGxvZ2dlZGluYXM+YWRtaW48L2xvZ2dlZGluYXM+PC9zZWN1cml0eWNvbnRleHQ+",
              true, visibleAccounts, string.Empty, string.Empty, 1);

            watch.Stop();
            statistic.addSample(watch.ElapsedMilliseconds);
        }

    }
}
