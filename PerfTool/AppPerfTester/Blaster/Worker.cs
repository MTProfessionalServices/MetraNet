using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Threading;
using System.IO;
using System.Data;
using System.Data.Odbc;

namespace BaselineGUI.Blaster
{
    public class Worker
    {
        private static log4net.ILog log4NetLogger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public void DoInserts(WorkerArgs workerArgs)
        {
            // good link on threading  http://www.albahari.com/threading/

            ODBCUtil odbcUtil = new ODBCUtil();
            odbcUtil.connString = workerArgs.connStr.ToString();
            try
            {
                odbcUtil.DriverConnect();
                log4NetLogger.Info("Thread started");

                //for (int i1 = 0; i1 < workerArgs.inserts_per_thread; i1++)
                while (!_shouldStop)
                {
                    if (workerArgs.Tables[0].totalRowsInserted >= workerArgs.Tables[0].totalRowsToInsert)
                        break;

                    workerArgs.Tables[0].InsertP(odbcUtil, workerArgs);

                    if (workerArgs.Tables[0].totalRowsInserted >= workerArgs.Tables[0].totalRowsToInsert)
                        break;
                }
            }
            finally
            {
                ConnectionState ret = odbcUtil.GetState();
                if (ret == ConnectionState.Open)
                    odbcUtil.Disconnect();
            }
        }

        public void RequestStop()
        {
            _shouldStop = true;
        }
        // Volatile is used as hint to the compiler that this data
        // member will be accessed by multiple threads.
        private volatile bool _shouldStop;
    }
}
