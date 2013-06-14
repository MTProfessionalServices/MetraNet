using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Diagnostics;
using System.ServiceModel;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Billing;


namespace BaselineGUI
{
    public class AMUpdateAccount : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        private Statistic clientCreationStats;
        AccountCreationClient client = null;
        private AccountServiceClient serviceClient = null;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMUpdateAccount));

        public AMUpdateAccount()
        {
            group = "account";

            name = "updateAccount";
            fullName = "Update Account";
            statistic = useStatistic(name);
            clientCreationStats = useStatistic("Account Creation Client");
            commands.Add("go", cmdGo);
        }

        public void setup()
        {
            Stopwatch creation = new Stopwatch();
            creation.Start();
            client = new AccountCreationClient();
            client.ClientCredentials.UserName.UserName = PrefRepo.active.actSvcs.authName;
            client.ClientCredentials.UserName.Password = PrefRepo.active.actSvcs.authPassword;
            client.Open();
            acquireClient(out serviceClient);
            creation.Stop();
            clientCreationStats.addSample(creation.ElapsedMilliseconds);
            log.Info(String.Format("Time to create client {0}", creation.ElapsedMilliseconds));
        }

        public void teardown()
        {
            releaseClient(serviceClient);
        }

        public void dispose()
        {
            client = null;
        }

        public void cmdGo()
        {
            int id_acc = Framework.netMeter.pickModifiableAccountID();
            DateTime timeStamp = DateTime.Now;
            Account acct;
            serviceClient.LoadAccountWithViews(new AccountIdentifier(id_acc), timeStamp, out acct);
            Dictionary<string, List<View>> acctViews = acct.GetViews();
            List<View> contactViews = acctViews["LDAP"];

            // Change the email address so that something is written to the DB
            foreach (var contactView in contactViews)
            {
                string emailValue = (string)contactView.GetValue("Email");

                Random random = new Random();

                // if the first three characters of the email address contain a number between [100,999],
                // then replace the first three numbers, otherwise prepend 3 numbers
                int prependedValue;
                if (int.TryParse(emailValue.Substring(0, 3), out prependedValue) &&
                    (prependedValue >= 100) &&
                    (prependedValue <= 999))
                {
                    // strip off the first three characters of the emailValue
                    emailValue = emailValue.Substring(3);
                }

                string randomNumberPrefix = random.Next(100, 999).ToString();
                string newEmailAddress = randomNumberPrefix + emailValue;

                contactView.SetValue("Email", newEmailAddress);
            }

            Stopwatch watch = new Stopwatch();
            watch.Restart();
            client.UpdateAccount(acct, false);
            watch.Stop();
            log.Info(String.Format("Time to update account {0}", watch.ElapsedMilliseconds));
            statistic.addSample(watch.ElapsedMilliseconds);
        }
    }
}
