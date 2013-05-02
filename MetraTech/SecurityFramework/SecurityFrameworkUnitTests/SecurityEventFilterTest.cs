using System;
using System.Reflection;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Serialization;
using MetraTech.SecurityFramework.Core.SecurityMonitor;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.IO;

namespace MetraTech.SecurityFrameworkUnitTests
{
    
    
    /// <summary>
    ///This is a test class for SecurityEventFilterTest and is intended
    ///to contain all SecurityEventFilterTest Unit Tests
    ///</summary>
    [TestClass()]
    public class SecurityEventFilterTest
    {


        private TestContext testContextInstance;

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get
            {
                return testContextInstance;
            }
            set
            {
                testContextInstance = value;
            }
        }

        #region Additional test attributes
        // 
        //You can use the following additional attributes as you write your tests:
        //
        
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            string sfPropsStoreLocation = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "MtSfConfigurationLoader.xml");
			ISerializer serializer = new XmlSerializer();
			SecurityKernel.Initialize(serializer, sfPropsStoreLocation);
        }
        
        //Use ClassCleanup to run code after all tests in a class have run
        [ClassCleanup()]
        public static void MyClassCleanup()
        {
            SecurityKernel.Shutdown();
        }
        
        //Use TestInitialize to run code before running each test
        //[TestInitialize()]
        //public void MyTestInitialize()
        //{
        //}
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion

        #region IsMatched tests

        /// <summary>
        ///A test for IsMatched with proper arguments.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Positive_AnyEvent()
        {
            SecurityEventFilter target = CreateTarget(SecurityEventType.Unknown, null, null);
            ISecurityEvent securityEvent = new SecurityEvent();
            bool expected = true;
            bool actual;
            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with proper arguments.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Positive_InputData()
        {
            SecurityEventFilter target = CreateTarget(SecurityEventType.InputDataProcessingEventType, null, null);
            ISecurityEvent securityEvent = new SecurityEvent() { EventType = SecurityEventType.InputDataProcessingEventType };
            bool expected = true;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with non-matched event type.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Negative_InputData()
        {
            SecurityEventFilter target = CreateTarget(SecurityEventType.InputDataProcessingEventType, null, null);
            ISecurityEvent securityEvent = new SecurityEvent() { EventType = SecurityEventType.OutputDataProcessingEventType };
            bool expected = false;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with proper arguments.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Positive_AnySubsystem()
        {
            SecurityEventFilter target = CreateTarget(SecurityEventType.InputDataProcessingEventType, null, null);
            ISecurityEvent securityEvent =
                new SecurityEvent()
                {
                    EventType = SecurityEventType.InputDataProcessingEventType,
                    SubsystemName = SecurityKernel.Detector.SubsystemName
                };
            bool expected = true;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with non-matched subsystem.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Negative_DetectorSubsystem()
        {
            SecurityEventFilter target =
                CreateTarget(SecurityEventType.InputDataProcessingEventType, SecurityKernel.Detector.SubsystemName, null);
            ISecurityEvent securityEvent =
                new SecurityEvent()
                {
                    EventType = SecurityEventType.InputDataProcessingEventType,
                    SubsystemName = SecurityKernel.Encoder.SubsystemName
                };
            bool expected = false;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with proper arguments.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Positive_AnyCategory()
        {
            SecurityEventFilter target =
                CreateTarget(SecurityEventType.InputDataProcessingEventType, SecurityKernel.Detector.SubsystemName, null);
            ISecurityEvent securityEvent =
                new SecurityEvent()
                {
                    EventType = SecurityEventType.InputDataProcessingEventType,
                    SubsystemName = SecurityKernel.Detector.SubsystemName,
                    CategoryName = SecurityKernel.Detector.Api.CategoryNames[0]
                };
            bool expected = true;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with proper arguments.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Positive_Category()
        {
            SecurityEventFilter target = CreateTarget(
                SecurityEventType.InputDataProcessingEventType,
                SecurityKernel.Detector.SubsystemName,
                SecurityKernel.Detector.Api.CategoryNames[0]);
            ISecurityEvent securityEvent =
                new SecurityEvent()
                {
                    EventType = SecurityEventType.InputDataProcessingEventType,
                    SubsystemName = SecurityKernel.Detector.SubsystemName,
                    CategoryName = SecurityKernel.Detector.Api.CategoryNames[0]
                };
            bool expected = true;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with non-matched category.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Negative_Category()
        {
            SecurityEventFilter target = CreateTarget(
                SecurityEventType.InputDataProcessingEventType,
                SecurityKernel.Detector.SubsystemName,
                SecurityKernel.Detector.Api.CategoryNames[0]);
            ISecurityEvent securityEvent =
                new SecurityEvent()
                {
                    EventType = SecurityEventType.InputDataProcessingEventType,
                    SubsystemName = SecurityKernel.Detector.SubsystemName,
                    CategoryName = SecurityKernel.Detector.Api.CategoryNames[1]
                };
            bool expected = false;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with proper arguments.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Positive_CustomFilter()
        {
            SecurityEventFilter target = CreateTarget(
                SecurityEventType.InputDataProcessingEventType,
                SecurityKernel.Detector.SubsystemName,
                SecurityKernel.Detector.Api.CategoryNames[0]);
            target.CustomFilter += new CustomFilterEventHandler(
                delegate(object sender, CustomFilterEventArgs e)
                {
                    e.Matched = true;
                });
            ISecurityEvent securityEvent =
                new SecurityEvent()
                {
                    EventType = SecurityEventType.InputDataProcessingEventType,
                    SubsystemName = SecurityKernel.Detector.SubsystemName,
                    CategoryName = SecurityKernel.Detector.Api.CategoryNames[0]
                };
            bool expected = true;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with custom filter failing.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Negative_CustomFilter1()
        {
            SecurityEventFilter target = CreateTarget(
                SecurityEventType.InputDataProcessingEventType,
                SecurityKernel.Detector.SubsystemName,
                SecurityKernel.Detector.Api.CategoryNames[0]);
            target.CustomFilter += new CustomFilterEventHandler(
                delegate(object sender, CustomFilterEventArgs e)
                {
                    e.Matched = false;
                });
            ISecurityEvent securityEvent =
                new SecurityEvent()
                {
                    EventType = SecurityEventType.InputDataProcessingEventType,
                    SubsystemName = SecurityKernel.Detector.SubsystemName,
                    CategoryName = SecurityKernel.Detector.Api.CategoryNames[0]
                };
            bool expected = false;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for IsMatched with non-matched category.
        ///</summary>
        [TestMethod()]
        public void IsMatchedTest_Negative_CustomFilter2()
        {
            SecurityEventFilter target = CreateTarget(
                SecurityEventType.InputDataProcessingEventType,
                SecurityKernel.Detector.SubsystemName,
                SecurityKernel.Detector.Api.CategoryNames[0]);
            target.CustomFilter += new CustomFilterEventHandler(
                delegate(object sender, CustomFilterEventArgs e)
                {
                    e.Matched = true;
                });
            ISecurityEvent securityEvent =
                new SecurityEvent()
                {
                    EventType = SecurityEventType.InputDataProcessingEventType,
                    SubsystemName = SecurityKernel.Detector.SubsystemName,
                    CategoryName = SecurityKernel.Detector.Api.CategoryNames[1]
                };
            bool expected = false;
            bool actual;

            actual = target.IsMatched(securityEvent);
            Assert.AreEqual(expected, actual);
        }

        #endregion

        #region Private methods

        private SecurityEventFilter CreateTarget(SecurityEventType eventType, string subsystemName, string categoryName)
        {
            SecurityEventFilter result =
                new SecurityEventFilter()
                {
                    EventType = eventType,
                    SubsystemName = subsystemName,
                    SubsystemCategoryName = categoryName
                };

            return result;
        }

        #endregion
    }
}
