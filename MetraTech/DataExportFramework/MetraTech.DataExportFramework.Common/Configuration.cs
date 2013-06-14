using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.DataExportFramework.Common
{
    public static class Configuration
    {
        /// <summary>
        /// Gets configuration instance
        /// </summary>
        public static IConfiguration Instance
        {
            get
            {
               return XmlConfiguration.Instance;
            }
        }
    }
}
