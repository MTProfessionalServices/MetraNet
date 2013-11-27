using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    static class MsgLoggerFactory
    {
        public static Dictionary<string, MsgLogger> loggers;

        static MsgLoggerFactory()
        {
            loggers = new Dictionary<string, MsgLogger>();
        }

        public static void init()
        {
        }

        public static MsgLogger getLogger(string name)
        {
            if (loggers.ContainsKey(name))
                return loggers[name];
            MsgLogger log = new MsgLogger();
            loggers.Add(name, log);
            return log;
        }

        public static int NumErrors
        {
            get
            {
                int n = 0;
                foreach (MsgLogger logger in loggers.Values)
                {
                    n += logger.NumErrors;
                }
                return n;
            }
        }

        public static int NumWarnings
        {
            get
            {
                int n = 0;
                foreach (MsgLogger logger in loggers.Values)
                {
                    n += logger.NumWarnings;
                }
                return n;
            }
        }

    }
}
