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
  class AMGetAccountIDList : AppMethodBase, AppMethodI
  {
    Statistic statistic;
    AccountServiceClient client = null;

    public AMGetAccountIDList()
    {
      group = "account";

      name = "getAccountIDList";
      fullName = "Get AccountID List";
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

      DateTime timeStamp = DateTime.Now;
      MTList<Account> accounts = new MTList<Account>();
      accounts.PageSize = 10;
      accounts.CurrentPage = 1;

      watch.Restart();
      List<int> accountIDs = new List<int>();
      client.GetAccountIdList(timeStamp, ref accounts, false, out accountIDs);
      watch.Stop();
      statistic.addSample(watch.ElapsedMilliseconds);
    }
  }
}
