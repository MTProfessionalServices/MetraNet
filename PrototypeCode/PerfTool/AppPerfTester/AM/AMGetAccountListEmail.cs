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
    public class AMGetAccountListEmail : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        AccountServiceClient client = null;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMGetAccountListEmail));

        public AMGetAccountListEmail()
        {
            group = "account";

            name = "GetAccountListEmail";
            fullName = "Get Account List Email";
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
            client = null;
        }


        public void dispose()
        {
            disposeClient(client);
            client = null;
        }

        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();

            int id_acc = Framework.netMeter.pickReadableAccountID();

            Account acct;

            log.DebugFormat("id_acc = {0}", id_acc);
            
            client.LoadAccountWithViews(new AccountIdentifier(id_acc), DateTime.Now, out acct);

            Dictionary<string, List<View>> acctViews = acct.GetViews();

            foreach (var viewName in acctViews.Keys)
            {
                log.DebugFormat("viewName={0}", viewName);
            }

            List<View> contactViews = acctViews["LDAP"];

            // Retrieve the email address on the specified account
            string emailValue = "";
            foreach (var contactView in contactViews)
            {
                emailValue = (string) contactView.GetValue("Email");
                if (emailValue.Length > 0)
                {
                    break;
                }
            }

            MTList<Account> accounts = new MTList<Account>();
            accounts.PageSize = 10;
            accounts.CurrentPage = 1;
            accounts.Filters.Add(new MTFilterElement("Email", MTFilterElement.OperationType.Equal, emailValue));

            watch.Restart();
            client.GetAccountList(DateTime.Now, ref accounts, false);
            watch.Stop();

            int numRetrievedAccounts = accounts.Items.Count;
            statistic.addSample(watch.ElapsedMilliseconds, string.Format("Retrieved {0} accounts", numRetrievedAccounts));

            if (numRetrievedAccounts < 1)
            {
                throw new InvalidOperationException(
                    String.Format("Expected to retrieve 1 or more accounts, but retrieved {0} instead", numRetrievedAccounts));
            }
        }

    }
}
