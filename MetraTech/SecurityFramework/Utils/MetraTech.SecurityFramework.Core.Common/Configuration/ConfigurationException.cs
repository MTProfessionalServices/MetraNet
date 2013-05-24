using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework;

namespace MetraTech.SecurityFramework.Core.Common.Configuration
{
    /// <summary>
    /// This class describes the configuration error
    /// </summary>
    public class ConfigurationException : SecurityFrameworkException
    { 
        public ConfigurationException() : base() { }
        public ConfigurationException(string message) : base(message) {}
        public ConfigurationException(string message, Exception inner) : base(message, inner) { }
    }
}
