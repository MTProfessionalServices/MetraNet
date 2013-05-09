using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using log4net;


namespace BaselineGUI
{
    public static class StatisticFactory
    {
        public static event EventHandler<EventArgs> OnModelChangeEvent;

        private static readonly ILog log = LogManager.GetLogger(typeof(StatisticFactory));

        public static Dictionary<string, Statistic> statistics;

        static StatisticFactory()
        {
            statistics = new Dictionary<string, Statistic>();
        }



        public static Statistic find(string name)
        {
            if (statistics.ContainsKey(name))
                return statistics[name];

            log.DebugFormat("Creating {0}", name);
            statistics[name] = new Statistic(name);
            RaiseModelChange();
            return statistics[name];
        }


        public static List<string> getKeyList()
        {
            List<string> list = new List<string>();

            foreach (string s in statistics.Keys)
            {
                list.Add(s);
            }
            return list;
        }


        public static void writeCSV(string fileName)
        {
            Statistic statistic;
            StringBuilder statsBuffer = new StringBuilder();

            statsBuffer.Clear();
            statsBuffer.AppendLine("name,average,myMin,myMax,numSamples,confidence,errCnt");

            foreach (KeyValuePair<string, Statistic> kvp in statistics)
            {
                statistic = kvp.Value;
                statsBuffer.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6}",
                                                     statistic.Name, statistic.average, statistic.myMin, statistic.myMax,
                                                     statistic.numSamples, statistic.confidence, statistic.errCnt));
            }

            StreamWriter sw = new StreamWriter(fileName);
            sw.WriteLine(statsBuffer);
            sw.Close();

            statsBuffer.Clear();
        }


        private static void RaiseModelChange()
        {
            EventArgs d = new EventArgs();
            if (OnModelChangeEvent != null)
                OnModelChangeEvent(null, d);
        }


    }
}
