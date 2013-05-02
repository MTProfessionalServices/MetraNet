using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Detector;
using MetraTech.SecurityFramework.Core.SecurityMonitor;
using MetraTech.SecurityFramework.Core.SecurityMonitor.Policy;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Common.Testing;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    /// Summary description for SecurityMonitorTest
    /// </summary>
    [TestClass]
    public class SecurityMonitorTest
	{
		#region Inner classes

		private class EncoderTestException : BadInputDataException
        {
            public EncoderTestException(ExceptionId.Encoder id)
                : base(id.ToInt(), "Encoder", String.Empty, "Test monitor", SecurityEventType.Unknown)
            { }

            public EncoderTestException(ExceptionId.Encoder id, EncoderEngineCategory category)
                : base(id.ToInt(), "Encoder", Convert.ToString(category), "Test monitor", SecurityEventType.Unknown)
            { }

            public EncoderTestException(ExceptionId.Encoder id, EncoderEngineCategory category, SecurityEventType eventType)
                : base(id.ToInt(), "Encoder", Convert.ToString(category), "Test monitor", eventType)
            { }
        }

        private class DetectorTestException : BadInputDataException
        {
            public DetectorTestException(ExceptionId.Detector id, DetectorEngineCategory category)
                : base(id.ToInt(), "Detector", Convert.ToString(category), "Test monitor", SecurityEventType.Unknown)
            { }

            public DetectorTestException(ExceptionId.Detector id, DetectorEngineCategory category, SecurityEventType eventType)
                : base(id.ToInt(), "Detector", Convert.ToString(category), "Test monitor", eventType)
            { }
        }

		#endregion

		#region Constants

		private const string TestFakeHandlerId = "TestFakeHandler";
        private const string DuplicatedHandlerId = "DuplicatedHandler";
        private const string TestHandlerId = "TestHandler";
        private const string DefaultTestHandlerId = "DefaultTestHandler";
        private const string EncoderSubsystemName = "Encoder";
        private const string DetectorSubsystemName = "Detector";

        private const SecurityPolicyActionType AllActions =
            SecurityPolicyActionType.BlockAddress |
            SecurityPolicyActionType.BlockOperation |
            SecurityPolicyActionType.BlockUser |
            SecurityPolicyActionType.ChangeSessionParameter |
            SecurityPolicyActionType.Log |
            SecurityPolicyActionType.LogoutUser |
            SecurityPolicyActionType.RedirectOperation |
            SecurityPolicyActionType.RedirectUser |
            SecurityPolicyActionType.SendAdminNotification |
            SecurityPolicyActionType.SendSecurityWarningToUser;

        #endregion

        #region Inner types

        public delegate void SecurityEventHandler(PolicyAction policyAction, ISecurityEvent securityEvent);

        /// <summary>
        /// Provides a stub Security Policy action handler.
        /// </summary>
        public class FakeActionHandler : ISecurityPolicyActionHandler
        {
            public event SecurityEventHandler SecurityPolicyAction;

            public void Handle(SecurityFramework.Core.SecurityMonitor.Policy.PolicyAction policyAction, ISecurityEvent securityEvent)
            {
                if (SecurityPolicyAction != null)
                {
                    SecurityPolicyAction(policyAction, securityEvent);
                }
            }
        }

        #endregion

        #region Service members

        public SecurityMonitorTest()
        {
            //
            // TODO: Add constructor logic here
            //
        }

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

        #endregion

        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        // Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void SecurityKernelInitialize(TestContext testContext)
        {
            UnitTestUtility.InitFrameworkConfiguration(testContext);
        }

        // Use ClassCleanup to run code after all tests in a class have run
        [ClassCleanup()]
        public static void SecurityKernelClassCleanup()
        {
            UnitTestUtility.CleanupFrameworkConfiguration();
        }

        // Use TestInitialize to run code before running each test 
        [TestInitialize()]
        public void SecurityKernelAllTetsInitialize()
        {
            Assert.IsTrue(SecurityKernel.IsInitialized(), "SecurityKernel is not Initialized.");
        }

        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        #region AddPolicyActionHandler tests

        /// <summary>
        /// Test for AddPolicyActionHandler method with proper arguments.
        /// </summary>
        [TestMethod]
        public void AddPolicyActionHandlerTest_Positive()
        {
            ISecurityPolicyActionHandler handler = new FakeActionHandler();
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(TestFakeHandlerId, SecurityPolicyActionType.BlockAddress, handler);
        }

        /// <summary>
        /// Test for AddPolicyActionHandler method with null handler ID.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentNullException))]
        public void AddPolicyActionHandlerTest_NullId()
        {
            ISecurityPolicyActionHandler handler = new FakeActionHandler();
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(null, SecurityPolicyActionType.BlockAddress, handler);
        }

        /// <summary>
        /// Test for AddPolicyActionHandler method with null handler.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentNullException))]
        public void AddPolicyActionHandlerTest_NullHandler()
        {
            ISecurityPolicyActionHandler handler = null;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(TestFakeHandlerId, SecurityPolicyActionType.BlockAddress, handler);
        }

        /// <summary>
        /// Test for AddPolicyActionHandler method with duplicated handler ID.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(SubsystemInputParamException))]
        public void AddPolicyActionHandlerTest_DuplicatedId()
        {
            ISecurityPolicyActionHandler handler = new FakeActionHandler();

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(DuplicatedHandlerId, SecurityPolicyActionType.BlockAddress, handler);
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(DuplicatedHandlerId, SecurityPolicyActionType.BlockAddress, handler);
        }

        #endregion

        #region RemovePolicyActionHandler tests

        /// <summary>
        /// Test for RemovePolicyActionHandler method with proper arguments.
        /// </summary>
        [TestMethod]
        public void RemovePolicyActionHandler_Positive()
        {
            ISecurityPolicyActionHandler handler = new FakeActionHandler();
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(TestHandlerId, SecurityPolicyActionType.BlockAddress, handler);
            SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(TestHandlerId);
        }

        /// <summary>
        /// Test for RemovePolicyActionHandler method with null handler ID.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentNullException))]
        public void RemovePolicyActionHandler_NullId()
        {
            SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(null);
        }

        /// <summary>
        /// Test for RemovePolicyActionHandler method with invalid handler ID.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(SubsystemInputParamException))]
        public void RemovePolicyActionHandler_InvalidId()
        {
            SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(Guid.NewGuid().ToString());
        }

        #endregion

        #region Handle action tests

        #region BlockOperationPolicyAction tests

        /// <summary>
        /// The test for block operation policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void BlockOperationPolicyActionTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(BlockOperationPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.Url));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Url);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for block operation policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void BlockOperationPolicyActionTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.BlockOperation,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region BlockUserPolicyAction tests

        /// <summary>
        /// The test for block user policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void BlockUserPolicyActionTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(BlockUserPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.JavaScript));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.JavaScript);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for block user policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void BlockUserPolicyActionTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.BlockUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region BlockAddressPolicyAction tests

        /// <summary>
        /// The test for block address policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void BlockAddressPolicyActionTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(BlockAddressPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.VbScript));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.VbScript);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for block address policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void BlockAddressPolicyActionTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.BlockAddress,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region LogPolicyAction tests

        /// <summary>
        /// The test for log policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void LogPolicyActionTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(LogPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.Css));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for log policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void LogPolicyActionTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.Log,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region RedirectOperationPolicyAction tests

        /// <summary>
        /// The test for redirect operation policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void RedirectOperationPolicyActionTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(RedirectOperationPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.Html));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Html);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for redirect operation policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void RedirectOperationPolicyActionTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.RedirectOperation,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region RedirectUserActionPolicy tests

        /// <summary>
        /// The test for redirect user policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void RedirectUserActionPolicyTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(RedirectUserActionPolicy), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.HtmlAttribute));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.HtmlAttribute);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for redirect user policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void RedirectUserActionPolicyTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.RedirectUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region LogoutUserPolicyAction tests

        /// <summary>
        /// The test for logout user policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void LogoutUserPolicyActionTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.Xml));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Xml);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for logout user policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void LogoutUserPolicyActionTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.LogoutUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region NotifyUserPolicyAction tests

        /// <summary>
        /// The test for notify user policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void NotifyUserPolicyActionTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(NotifyUserPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.XmlAttribute));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.XmlAttribute);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for notify user policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void NotifyUserPolicyActionTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.SendSecurityWarningToUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region NotifyAdminPolicyAction tests

        /// <summary>
        /// The test for notify admin policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void NotifyAdminPolicyActionTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(NotifyAdminPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.Ldap));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Ldap);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for notify admin policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void NotifyAdminPolicyActionTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.SendAdminNotification,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region ChangeSessionParameterPolicyAction tests

        /// <summary>
        /// The test for change session parameter policy action.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void ChangeSessionParameterPolicyActionTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(ChangeSessionParameterPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.Base64));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Base64);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderTestException(ExceptionId.Encoder.General);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        /// <summary>
        /// The test for change session parameter policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void ChangeSessionParameterPolicyActionTest_Negative()
        {
            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.ChangeSessionParameter,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }

        #endregion

        #region Distinguish actions tests

        /// <summary>
        /// Test whether identiacal actions are distinguished and a handler is called once only.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void DistinguishTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.LogoutUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), EncoderSubsystemName, Convert.ToString(EncoderEngineCategory.Xml));
                }));

            try
            {
                // This exception matches two policies with the same action.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Xml, SecurityEventType.AppActivityTrendEventType);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }

        /// <summary>
        /// Test whether deferent actions are not distinguished and a handler is called for several times.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void DistinguishTest_Negative()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                AllActions,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                // This exception matches two policies with the deferent actions.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.XmlAttribute, SecurityEventType.AppActivityTrendEventType);
                ex.Report();

                Assert.AreEqual(2, counter, "Two handler calls were expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }

        #endregion

        #endregion

        #region Policy rule tests

        #region EventRepeatThresholdRule tests

        /// <summary>
        /// The test for EventRepeatThresholdRule.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void EventRepeatThresholdRuleTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.SendSecurityWarningToUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(NotifyUserPolicyAction), DetectorSubsystemName, Convert.ToString(Convert.ToString(DetectorEngineCategory.Xss)));
                }));

            try
            {
                // 3rd XSS has to raise the policy action.
                Exception ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Xss);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Xss);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Xss);
                ex.Report();
                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Xss);
                ex.Report();
                Assert.AreEqual(2, counter, "Two handler calls were expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }

        #endregion

        #region EventTimespanThresholdRule tests

        /// <summary>
        /// Test for EventTimespanThresholdRule.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void EventTimespanThresholdRuleTest_Positive()
        {
            System.Threading.Thread.Sleep(310);
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.BlockOperation,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(BlockOperationPolicyAction), DetectorSubsystemName, Convert.ToString(Convert.ToString(DetectorEngineCategory.Sql)));
                }));

            try
            {
                // 5th SQL has to raise the policy action.
                Exception ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(2, counter, "Two handler calls were expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }

        #endregion

		#region EventTypeRule tests

		/// <summary>
        /// The test for EventTypeRule.
        /// </summary>
        [TestMethod()]
        [Ignore] // This test is temporarily suspended. 
        public void EventTypeRuleTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.LogoutUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), DetectorSubsystemName, Convert.ToString(Convert.ToString(DetectorEngineCategory.Sql)));
                }));

            try
            {
                // First event does not match the policy.
                Exception ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                // Second event matches the policy
                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql, SecurityEventType.AppActivityTrendEventType);
                ex.Report();
                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Third event matches the policy.
                ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql, SecurityEventType.AppActivityTrendEventType);
                ex.Report();
                Assert.AreEqual(2, counter, "Two handler calls were expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }

        /// <summary>
        /// The test for EventTypeRule when it does not match.
        /// </summary>
        [TestMethod()]
        public void EventTypeRuleTest_Negative()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.LogoutUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), DetectorSubsystemName, Convert.ToString(Convert.ToString(DetectorEngineCategory.Sql)));
                }));

            try
            {
                // First event does not match the policy.
                Exception ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }

        #endregion

        #region Custom filer tests

        /// <summary>
        /// Test for configured custom filter when an event matches it.
        /// </summary>
        [TestMethod]
        [Ignore] // This test is temporarily suspended. 
        public void CustomFilterTest_Positive()
        {
            Exception ex = new EncoderTestException(ExceptionId.Encoder.General, EncoderEngineCategory.Css);
            long expected = TestCustomFilter.MatchesCount + 1;
            ex.Report();

            long actual = TestCustomFilter.MatchesCount;
            Assert.AreEqual(expected, actual, "Unexpected number of matches. Expected {0}, found {1}", expected, actual);
        }

        /// <summary>
        /// Test for configured custom filter when an event does not match it.
        /// </summary>
        [TestMethod]
        public void CustomFilterTest_Negative()
        {
            Exception ex = new DetectorInputDataException(ExceptionId.Detector.DetectHtmlTag, DetectorEngineCategory.Xss, "Test");
            long expected = TestCustomFilter.MatchesCount;
            ex.Report();

            long actual = TestCustomFilter.MatchesCount;
            Assert.AreEqual(expected, actual, "Unexpected number of matches. Expected {0}, found {1}", expected, actual);
        }

        #endregion

		#region IPChangeRule tests

		/// <summary>
		/// Test for the IPChangeRule with different IPs.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
		public void IPChangeRuleTest_Positive()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.BlockOperation,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
				}));

			try
			{
				// First event does not match the policy.
				SecurityKernel.SecurityMonitor.Api.ReportEvent(new SecurityEvent());
				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

				// Second event does not match the policy too.
				GetExecutionContext().ClientAddress = System.Net.IPAddress.Parse("192.168.0.1");
				SecurityKernel.SecurityMonitor.Api.ReportEvent(new SecurityEvent());
				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

				// Third event matches the policy.
				GetExecutionContext().ClientAddress = System.Net.IPAddress.Parse("192.168.0.2");
				SecurityKernel.SecurityMonitor.Api.ReportEvent(new SecurityEvent());
				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
				GetExecutionContext().ClientAddress = System.Net.IPAddress.Loopback;
			}
		}

		#endregion

		#region ActionFrequencyRule tests

		/// <summary>
		/// Test for ActionFrequencyRule.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
        public void ActionFrequencyRuleTest_Positive()
		{
			System.Threading.Thread.Sleep(100);
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.SendAdminNotification,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
					CheckRespondingAction(policyAction, securityEvent, typeof(NotifyAdminPolicyAction), DetectorSubsystemName, Convert.ToString(Convert.ToString(DetectorEngineCategory.Sql)));
				}));

			try
			{
				Exception ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
				ex.Report();
				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

				ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
				ex.Report();
				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

				System.Threading.Thread.Sleep(100);

				ex = new DetectorTestException(ExceptionId.Detector.General, DetectorEngineCategory.Sql);
				ex.Report();
				Assert.AreEqual(2, counter, "Two handler calls were expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		#endregion

		#region InputDataSizeRule tests

		/// <summary>
		/// Test for InputDataSizeRule with event matching policy.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
		public void InputDataSizeRuleTest_Positive()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.LogoutUser,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportEvent(
					new SecurityEvent()
					{
						InputDataSize = 1000001
					});

				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		/// <summary>
		/// Test for InputDataSizeRule with event not matching policy.
		/// </summary>
		[TestMethod]
		public void InputDataSizeRuleTest_Negative()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.LogoutUser,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportEvent(
					new SecurityEvent()
					{
						InputDataSize = 1000000
					});

				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		#endregion

		#region EventRatioThresholdRule tests

		/// <summary>
		/// Test for EventRatioThresholdRule.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
        public void EventRatioThresholdRuleTest_Positive()
		{
			System.Threading.Thread.Sleep(100);
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.RedirectOperation,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
					CheckRespondingAction(policyAction, securityEvent, typeof(RedirectOperationPolicyAction), "Statistics", StatisticsCategory.UserLogout.ToString());
				}));

			try
			{
				// Generate 4 login events.
				SecurityKernel.SecurityMonitor.Api.ReportLogin();
				SecurityKernel.SecurityMonitor.Api.ReportLogin();
				SecurityKernel.SecurityMonitor.Api.ReportLogin();
				SecurityKernel.SecurityMonitor.Api.ReportLogin();

				// Check the policy.
				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

				SecurityKernel.SecurityMonitor.Api.ReportLogout();
				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

				SecurityKernel.SecurityMonitor.Api.ReportLogout();
				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

				SecurityKernel.SecurityMonitor.Api.ReportLogout();
				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

				SecurityKernel.SecurityMonitor.Api.ReportLogout();
				Assert.AreEqual(2, counter, "Two handler calls were expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		#endregion

		#endregion

		#region API tests

		#region ReportLogin tests

		/// <summary>
		/// Test for ReportLogin with handler for proper action type.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
        public void ReportLoginTest_Positive()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.LogoutUser,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
					CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), "Statistics", StatisticsCategory.UserLogin.ToString());
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportLogin();

				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		/// <summary>
		/// Test for ReportLogin with handler for invalid action type.
		/// </summary>
		[TestMethod]
		public void ReportLoginTest_Negative()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.RedirectOperation,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportLogin();

				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		#endregion

		#region ReportLogout tests

		/// <summary>
		/// Test for ReportLogout with handler for proper action type.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
        public void ReportLogoutTest_Positive()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.LogoutUser,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
					CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), "Statistics", StatisticsCategory.UserLogout.ToString());
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportLogout();

				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		/// <summary>
		/// Test for ReportLogout with handler for invalid action type.
		/// </summary>
		[TestMethod]
		public void ReportLogoutTest_Negative()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.RedirectUser,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportLogout();

				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		#endregion

		#region ReportFeatureUsage tests

		/// <summary>
		/// Test for ReportFeatureUsage with handler for proper action type.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
        public void ReportFeatureUsageTest_Positive()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.LogoutUser,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
					CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), "Statistics", StatisticsCategory.FeatureUsage.ToString());
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportFeatureUsage("Test");

				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		/// <summary>
		/// Test for ReportFeatureUsage with handler for invalid action type.
		/// </summary>
		[TestMethod]
		public void ReportFeatureUsageTest_Negative()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.RedirectOperation,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportFeatureUsage("Test");

				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		#endregion

		#region ReportTransactionUsage tests

		/// <summary>
		/// Test for ReportTransactionUsage with handler for proper action type.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
        public void ReportTransactionUsageTest_Positive()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.LogoutUser,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
					CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), "Statistics", StatisticsCategory.TransactionUsage.ToString());
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportTransactionUsage("Test");

				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		/// <summary>
		/// Test for ReportTransactionUsage with handler for invalid action type.
		/// </summary>
		[TestMethod]
		public void ReportTransactionUsageTest_Negative()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.RedirectOperation,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportTransactionUsage("Test");

				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		#endregion

		#region ReportIrregularUsage tests

		/// <summary>
		/// Test for ReportIrregularUsage with handler for proper action type.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
        public void ReportIrregularUsageTest_Positive()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.LogoutUser,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
					CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), "Statistics", StatisticsCategory.IrregularUsage.ToString());
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportIrregularUsage("Test");

				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		/// <summary>
		/// Test for ReportIrregularUsage with handler for invalid action type.
		/// </summary>
		[TestMethod]
		public void ReportIrregularUsageTest_Negative()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.RedirectOperation,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportIrregularUsage("Test");

				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		#endregion

		#region ReportFileUpload tests

		/// <summary>
		/// Test for ReportFileUpload with handler for proper action type.
		/// </summary>
		[TestMethod]
        [Ignore] // This test is temporarily suspended. 
        public void ReportFileUploadTest_Positive()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.LogoutUser,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
					CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), "Statistics", StatisticsCategory.FileUpload.ToString());
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportFileUpload(1);

				Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		/// <summary>
		/// Test for ReportFileUpload with handler for invalid action type.
		/// </summary>
		[TestMethod]
		public void ReportFileUploadTest_Negative()
		{
			int counter = 0;
			SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
				DefaultTestHandlerId,
				SecurityPolicyActionType.RedirectOperation,
				CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
				{
					counter++;
				}));

			try
			{
				SecurityKernel.SecurityMonitor.Api.ReportFileUpload(1);

				Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
			}
			finally
			{
				SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
			}
		}

		#endregion

		#endregion

		#region Private methods

		private ISecurityPolicyActionHandler CreateHandler(SecurityEventHandler handler)
        {
            FakeActionHandler result = new FakeActionHandler();
            result.SecurityPolicyAction += handler;

            return result;
        }

        private static void CheckRespondingAction(
            PolicyAction policyAction,
            ISecurityEvent securityEvent,
            Type expectedActionType,
            string expectedSubsystemName,
            string expectedCategoryName)
        {
            Assert.IsNotNull(policyAction, "Argument \"policyAction\". Object reference expected but null found");
            Assert.IsNotNull(securityEvent, "Argument \"securityEvent\". Object reference expected but null found");
            Assert.IsInstanceOfType(policyAction, expectedActionType, "\"{0}\" type was expected but \"{1}\" found.", expectedActionType, policyAction.GetType());
            Assert.AreEqual(expectedSubsystemName, securityEvent.SubsystemName, true, "Argument \"securityEvent\". Subsystem \"{0}\" was excepted but \"{1}\" found.", expectedSubsystemName, securityEvent.SubsystemName);
            Assert.AreEqual(expectedCategoryName, securityEvent.CategoryName, true, "Argument \"securityEvent\". Category \"{0}\" was excepted but \"{1}\" found.", expectedCategoryName, securityEvent.CategoryName);
        }

		private UnitTestExecutionContext GetExecutionContext()
		{
			Type factoryType = Type.GetType("MetraTech.SecurityFramework.Core.Common.ExecutionContextFactory, MetraTech.SecurityFramework");
			return factoryType.GetProperty("Context").GetValue(null, null) as UnitTestExecutionContext;
		}

        #endregion
    }
}
