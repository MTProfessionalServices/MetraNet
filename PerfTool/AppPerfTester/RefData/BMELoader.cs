using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BaselineGUI;
using NetMeterObj;
using log4net;
using System.Data.SqlClient;

namespace AppRefData
{
    public class BMELoader
    {
        public int numToLoad;
        private static readonly ILog log = LogManager.GetLogger(typeof(BMELoader));
        Progressable progress;

        public BMELoader()
        {
            progress = ProgressableFactory.find("BME Loader");
        }


        internal void addCallLogEntries(SqlConnection sqlConnection)
        {
            log.Info(String.Format("Adding {0} call log entries", numToLoad));
            int entriesAdded = 0;

            progress.Minimum = 0;
            progress.Value = 0;
            progress.Maximum = numToLoad;
            progress.isRunning = true;
            ProgressableFactory.active = progress;

            try
            {
                while (entriesAdded < numToLoad)
                {
                    BeLdpAudCalllogentry calllogentry = new BeLdpAudCalllogentry();
                    calllogentry.c_CallLogEntry_Id = Guid.NewGuid();
                    calllogentry.c_CallLogReasonId = 0;
                    calllogentry.c_CallReasonEntryType = 0;
                    calllogentry.c_CreationDate = DateTime.UtcNow;
                    calllogentry.c_EntityId = 0;
                    calllogentry.c_OccurrenceTime = DateTime.UtcNow;
                    calllogentry.c_UpdateDate = DateTime.UtcNow;
                    calllogentry.c_UID = 0;
                    calllogentry.c_UpdateDate = DateTime.UtcNow;
                    calllogentry.c__version = 0;
                    calllogentry.c_internal_key = Guid.NewGuid();

                    calllogentry.insert();
                    ++entriesAdded;
                }
                BeLdpAudCalllogentry.adapterWidget.flush();
                //flushToDB();

                progress.isRunning = false;
                
            }
            catch (Exception ex)
            {
                log.Error("Caught exception while adding call log entries", ex);
                throw ex;
            }
        }

        internal void addCallLogReasons(SqlConnection sqlConnection)
        {
            log.Info(String.Format("Adding {0} call log reasons", numToLoad));
            int entriesAdded = 0;

            progress.Minimum = 0;
            progress.Value = 0;
            progress.Maximum = numToLoad;
            progress.isRunning = true;
            ProgressableFactory.active = progress;

            try
            {
                while (entriesAdded < numToLoad)
                {
                    BeLdpAudCalllogreason  calllogreason = new BeLdpAudCalllogreason();
                    calllogreason.c_CallLogReasonDesc = "";
                    calllogreason.c_CallLogReason_Id = Guid.NewGuid();
                    calllogreason.c_CreationDate = DateTime.UtcNow;
                    calllogreason.c_IsActive = "";
                    calllogreason.c_UID = 0;
                    calllogreason.c_UpdateDate = DateTime.UtcNow;
                    calllogreason.c_ViewIndexId = 0;
                    calllogreason.c__version = 0;
                    calllogreason.c_internal_key = Guid.NewGuid();
                    

                    calllogreason.insert();
                    ++entriesAdded;
                }
                BeLdpAudCalllogreason.adapterWidget.flush();
                progress.isRunning = false;

            }
            catch (Exception ex)
            {
                log.Error("Caught exception while adding call log reasons", ex);
                throw ex;
            }

        }

        private void flushToDB()
        {
            for (int pass = 0; pass < 4; pass++)
            {
                foreach (var kvp in AdapterWidgetFactory.widgets)
                {
                    AdapterWidget aw = kvp.Value;
                    // Console.WriteLine("Flushing {0}", aw.tableName);
                    aw.flush();
                }
            }
        }
    }
}
