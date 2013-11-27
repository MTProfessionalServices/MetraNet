using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.Windows.Forms;
using System.IO;

namespace BaselineGUI
{

    public static class Framework
    {
        public static SqlConnection conn;
        public static Worker worker;
        public static Thread workerThread;

        public static FCSvcDefRepo SvcDefRepo;
        public static FCProductViewRepo ProdViewRepo;
        public static FCEnumRepo EnumRepo;

        public static FCDatabaseServer database;
        public static FCNetMeter netMeter;
        public static FCAccountLoadService accountLoadService;

        public static FCProductOffers productOffers;

        static Framework()
        {

            database = FrameworkComponentFactory.find<FCDatabaseServer>();
            netMeter = FrameworkComponentFactory.find<FCNetMeter>();
            SvcDefRepo = FrameworkComponentFactory.find<FCSvcDefRepo>();
            ProdViewRepo = FrameworkComponentFactory.find<FCProductViewRepo>();
            EnumRepo = FrameworkComponentFactory.find<FCEnumRepo>();
            productOffers = FrameworkComponentFactory.find<FCProductOffers>();
            accountLoadService = FrameworkComponentFactory.find<FCAccountLoadService>();
        }

        public static void init()
        {
        }


        public static void bringup()
        {
            foreach (var comp in FrameworkComponentFactory.Values)
            {
                comp.bringupState.state = BringupState.State.inProgress;
                comp.Bringup();
                comp.bringupState.state = BringupState.State.success;
            }

            // Now all of the services
            worker = new Worker();
            workerThread = new Thread(new ThreadStart(worker.Work));
            workerThread.Start();
        }

        public static void stop()
        {
            worker.runFlag = false;
            Thread.Sleep(2000);
            workerThread.Join();
            accountLoadService.Teardown();
        }



        private static void EnumHints()
        {
            StreamWriter writer = new StreamWriter(@"C:\temp\enum_suggestions.txt");

            foreach (string key in ProdViewRepo.prodViews.Keys)
            {
                ProductView pv = ProdViewRepo.prodViews[key];
                foreach (ProductView.Field f in pv.fields)
                {
                    if (f.theType == "enum")
                    {
                        string ename = f.enumSpace + "/" + f.enumType;
                        writer.WriteLine("pv {0} enum {1} [{2}] {3}/{4}", pv.shortName(), f.name, f.columnName, f.enumSpace, f.enumType);
                        Dictionary<string, FCEnumRepo.DbEnumPair> dict = EnumRepo.dbEnums[ename];
                        foreach (string kk in dict.Keys)
                        {
                            FCEnumRepo.DbEnumPair pair = dict[kk];
                            writer.WriteLine("    {0} {1} => {2}", ename, kk, pair.id_enum_data);
                        }
                    }
                }
            }
            writer.Close();

        }


    }
}
