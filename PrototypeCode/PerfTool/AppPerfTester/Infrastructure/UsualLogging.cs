using System;

using log4net;
using log4net.Config;

namespace BaselineGUI
{
    public class UsualLogging
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(UsualLogging));

        public static void SetUp()
        {
            Console.WriteLine("Init logger");
            XmlConfigurator.Configure(new System.IO.FileInfo(@"assets\log4netConfig.xml"));
            log.Info("Hi there");
        }

    }
}
