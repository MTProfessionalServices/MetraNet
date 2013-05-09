using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.ServiceModel;
using System.Threading;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Billing;


namespace BaselineGUI
{
    public class AMAddAccountWithoutWorkFlow : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMAddAccountWithoutWorkFlow));
        AccountServiceClient client = null;

        public AMAddAccountWithoutWorkFlow()
        {
            group = "account";

            name = "addAccountWithoutWorkFlow";
            fullName = "Add Account Without Work Flow";
            statistic = useStatistic(name);

            commands.Add("go", cmdGo);
        }

        public void setup()
        {
            acquireClient(out client);
        }

        public void teardown()
        {
            releaseClient(client);
        }


        public void dispose()
        {
            disposeClient(client);
            client = null;
        }
        
        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();

            MASAccount masAccount = new MASAccount();

            MetraTech.DomainModel.BaseTypes.Account custAcct = masAccount.makeCustomerAccount();
            log.DebugFormat("custAcct.UserName={0}", custAcct.UserName);

            watch.Restart();
            client.AddAccountWithoutWorkflow(ref custAcct);
            watch.Stop();
            statistic.addSample(watch.ElapsedMilliseconds);

#if true

            // Retrieve the added account to make sure it exists
            DateTime timeStamp = DateTime.Now;
            MTList<Account> accounts = new MTList<Account>();
            accounts.PageSize = 10;
            accounts.CurrentPage = 1;
            accounts.Filters.Add(new MTFilterElement("username", MTFilterElement.OperationType.Like, custAcct.UserName));
            client.GetAccountList(DateTime.Now, ref accounts, false);
            log.DebugFormat("accounts.TotalRows={0}", accounts.TotalRows);
            if (accounts.TotalRows < 1)
            {
                throw new InvalidOperationException(
                    String.Format("AddAccountWithoutWorkflow: failed to retrieve added account with username={0}", 
                    custAcct.UserName));
            }
#endif
        }

    }
}
