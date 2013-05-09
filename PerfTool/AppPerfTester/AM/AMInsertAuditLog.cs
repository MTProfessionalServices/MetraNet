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
    public class AMInsertAuditLog : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        AuditLogServiceClient client = null;

        public AMInsertAuditLog()
        {
            group = "Audit";

            name = "InsertAuditLog";
            fullName = "Insert Audit Log";
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

            int id_acc = Framework.netMeter.pickModifiableAccountID();

            MTList<AuditLogEntry> auditLogEntries = new MTList<AuditLogEntry>();
            auditLogEntries.PageSize = 10;
            auditLogEntries.CurrentPage = 1;

            client.RetrieveAuditLogEntriesForEntity(id_acc, ref auditLogEntries);
            int beforeCount = auditLogEntries.TotalRows;
            
            watch.Restart();
            client.InsertAuditLogEntry(129, 5002, id_acc, 1, string.Format("XXXXX Testing {0}", id_acc));
            watch.Stop();

            client.RetrieveAuditLogEntriesForEntity(id_acc, ref auditLogEntries);
            
            if (auditLogEntries.TotalRows <= beforeCount)
            {
                throw new InvalidOperationException(string.Format("after insertion expected {0} rows, but got {1}",
                                                                  beforeCount + 1, auditLogEntries.Items.Count));
            }
            statistic.addSample(watch.ElapsedMilliseconds, string.Format("successfully inserted audit log, now have {0}",
                auditLogEntries.TotalRows));
        }

    }
}
