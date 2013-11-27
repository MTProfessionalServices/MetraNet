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
    public class AMGetAccountListFirstLastName : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        AccountServiceClient client = null;

        public AMGetAccountListFirstLastName()
        {
            group = "account";

            name = "GetAccountListFirstLastName";
            fullName = "Get Account List First and Last Name";
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

            client.LoadAccountWithViews(new AccountIdentifier(id_acc), DateTime.Now, out acct);

            Dictionary<string, List<View>> acctViews = acct.GetViews();

            List<View> contactViews = acctViews["LDAP"];

            // Change the email address so that something is written to the DB
            string firstName = "";
            string lastName = "";
            foreach (var contactView in contactViews)
            {
                lastName = (string)contactView.GetValue("LastName");

                firstName = (string)contactView.GetValue("FirstName");
                if (lastName.Length > 0)
                {
                    break;
                }
            }

            //NetMeterObj.AvContact avContact = NetMeterObj.NetMeter.AvContactList[id_acc];

            DateTime timeStamp = DateTime.Now;
            MTList<Account> accounts = new MTList<Account>();
            accounts.PageSize = 10;
            accounts.CurrentPage = 1;
            

            accounts.Filters.Add(new MTFilterElement("LastName", MTFilterElement.OperationType.Equal, lastName));
            accounts.Filters.Add(new MTFilterElement("FirstName", MTFilterElement.OperationType.Equal, firstName));


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
