using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using log4net;

namespace BaselineGUI
{
    public class StressTask
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(StressTask));

        public bool complete;
        public string appMethodKey;

        public void execute()
        {
            log.DebugFormat("executing {0}", appMethodKey);
            AppMethodI am = AppMethodFactory.create(appMethodKey);
            try
            {
                am.setup();
                am.executeOnce("go");
                am.teardown();
                log.DebugFormat("success {0}", appMethodKey);
            }
            catch
            {
            }
        }
    }
}
