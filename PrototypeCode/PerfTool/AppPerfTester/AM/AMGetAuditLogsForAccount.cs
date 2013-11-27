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
    public class AMGetAuditLogsForAccount : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        AuditLogServiceClient client = null;

        public AMGetAuditLogsForAccount()
        {
            group = "Audit";

            name = "GetAuditLogsForAccount";
            fullName = "Get Audit Logs For Account";
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


        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();

            int id_acc = Framework.netMeter.pickReadableAccountID();

            MTList<AuditLogEntry> auditLogEntries = new MTList<AuditLogEntry>();
            auditLogEntries.PageSize = 10;
            auditLogEntries.CurrentPage = 1;

            watch.Restart();
            client.RetrieveAuditLogEntriesForEntity(id_acc, ref auditLogEntries);
            watch.Stop();

            if (auditLogEntries.TotalRows == 0)
            {
                client.InsertAuditLogEntry(129, 5002, id_acc, 1, string.Format("XXXXX Testing {0}", id_acc));
                watch.Restart();
                client.RetrieveAuditLogEntriesForEntity(id_acc, ref auditLogEntries);
                watch.Stop();
            }

            if (auditLogEntries.Items.Count <= 0)
            {
                throw new InvalidOperationException(string.Format(
                    "expected to retrieve one or more audit logs, but got {0}",
                    auditLogEntries.Items.Count));
            }
                    
            statistic.addSample(watch.ElapsedMilliseconds, string.Format("retrieved {0} of {1} audit logs", 
                auditLogEntries.Items.Count, auditLogEntries.TotalRows));
        }

        public void dispose()
        {
            disposeClient(client);
            client = null;
        }

    }
}
