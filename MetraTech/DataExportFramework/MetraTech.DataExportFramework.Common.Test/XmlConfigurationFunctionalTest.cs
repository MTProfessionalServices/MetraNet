using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Interop.RCD;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.DataExportFramework.Common.Test
{
    [TestClass]
    public class XmlConfigurationFunctionalTest
    {
        private const string ExtensionName = "DataExport";

        [TestMethod, MTFunctionalTest(TestAreas.Reporting)]
        public void XmlConfigurationReadConfigurationFromXml_Positive()
        {
            IConfiguration config = XmlConfiguration.Instance;

            IMTRcd rcd = new MetraTech.Interop.RCD.MTRcdClass();
            rcd.Init();

            Assert.AreEqual(Path.Combine(rcd.ExtensionDir, ExtensionName), config.PathToExtensionDir, "Something wrong in configuration file, because extensions are not equal");
            Assert.AreEqual(Path.Combine(rcd.ExtensionDir, ExtensionName, @"Config\SqlCustom\Queries\Custom"), config.PathToCustomQueryDir, "Something wrong in configuration file, because dir for Custom queries are not equal");
            Assert.AreEqual(Path.Combine(rcd.ExtensionDir, ExtensionName, @"Config\SqlCustom\Queries\Service"), config.PathToServiceQueryDir, "Something wrong in configuration file, because dir for Service queries are not equal");
            Assert.AreEqual(Path.Combine(rcd.ExtensionDir, ExtensionName, @"Config\WorkingFolder"), config.WorkingFolder, "Something wrong in configuration file, because dir for the saving reports are not equal");
            Assert.AreEqual(Path.Combine(rcd.ExtensionDir, ExtensionName, @"Config\fieldDef"), config.PathToReportFieldDefDir, "Something wrong in configuration file, because dir for definition field reports are not equal");
        }

        //TODO: Need created positive test for working with other xml configuration,
        // 1 use SetNewFileConfiguration() method
        // 2.for example with <service pathtype="absolute">...</service> paths
        // 3 use UseDefaultConfiguration() method
        public void XmlConfigurationReadFromCustomConfiguration_Positive()
        { }

        [TestMethod, MTFunctionalTest(TestAreas.Reporting)]
        [ExpectedException(typeof(FileNotFoundException))]
        public void XmlConfigurationReadConfigurationFromXml_Negative()
        {
            IConfiguration config = XmlConfiguration.Instance;
            config.SetNewFileConfiguration("____test_file_configuration_name____.xxx");
        }
    }
}
