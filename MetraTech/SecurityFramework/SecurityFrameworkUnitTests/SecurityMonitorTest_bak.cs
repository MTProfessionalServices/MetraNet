using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Detector;
using MetraTech.SecurityFramework.Core.Encoder;
using MetraTech.SecurityFramework.Core.SecurityMonitor;
using MetraTech.SecurityFramework.Core.SecurityMonitor.Policy;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    /// Summary description for SecurityMonitorTest
    /// </summary>
    [TestClass]
    public class SecurityMonitorTest
    {
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

        public static void policyActionTest_Positive(SecurityPolicyActionType policyActionType, Type expectedActionType, EncoderEngineCategory categoryForMatch, EncoderEngineCategory categoryForDontMatch)
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                policyActionType,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, expectedActionType, EncoderSubsystemName, Convert.ToString(categoryForMatch));
                }));

            try
            {
                // Match the policy.
                Exception ex = new EncoderInputDataException(ExceptionId.Encoder.NotSetId, categoryForMatch, "Match the policy");
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Don't match the policy.
                ex = new EncoderInputDataException(ExceptionId.Encoder.NotSetId, categoryForDontMatch, "Don't match the policy");
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
        }

        private static void policyActionTest_Negative(SecurityPolicyActionType policyActionType, EncoderEngineCategory category)
        {

            int counter = 0;

            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                policyActionType,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                Exception ex = new EncoderInputDataException(ExceptionId.Encoder.NotSetId, category, "test");
                ex.Report();
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }

            Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);
        }
        //  policyActionTest_Positive(AllActions, typeof(BlockUserPolicyAction), EncoderEngineCategory.JavaScript, EncoderEngineCategory.Css);
        //  policyActionTest_Negative(AllActions, EncoderEngineCategory.Css);

        #region BlockOperationPolicyAction tests

        /// <summary>
        /// The test for block operation policy action.
        /// </summary>
        [TestMethod()]
        public void BlockOperationPolicyActionTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(BlockOperationPolicyAction)
                                            , EncoderEngineCategory.Url, EncoderEngineCategory.Css);
        }

        /// <summary>
        /// The test for block operation policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void BlockOperationPolicyActionTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.BlockOperation, EncoderEngineCategory.Css);
        }

        #endregion

        #region BlockUserPolicyAction tests

        /// <summary>
        /// The test for block user policy action.
        /// </summary>
        [TestMethod()]
        public void BlockUserPolicyActionTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(BlockUserPolicyAction), EncoderEngineCategory.JavaScript, EncoderEngineCategory.Css);
        }

        /// <summary>
        /// The test for block user policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void BlockUserPolicyActionTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.BlockUser, EncoderEngineCategory.Css);
        }

        #endregion

        #region BlockAddressPolicyAction tests

        /// <summary>
        /// The test for block address policy action.
        /// </summary>
        [TestMethod()]
        public void BlockAddressPolicyActionTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(BlockAddressPolicyAction), EncoderEngineCategory.VbScript, EncoderEngineCategory.Css);
        }

        /// <summary>
        /// The test for block address policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void BlockAddressPolicyActionTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.BlockAddress, EncoderEngineCategory.Css);
        }

        #endregion

        #region LogPolicyAction tests

        /// <summary>
        /// The test for log policy action.
        /// </summary>
        [TestMethod()]
        public void LogPolicyActionTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(LogPolicyAction), EncoderEngineCategory.Css, EncoderEngineCategory.XmlAttribute);
        }

        /// <summary>
        /// The test for log policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void LogPolicyActionTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.Log, EncoderEngineCategory.Css);
        }

        #endregion

        #region RedirectOperationPolicyAction tests

        /// <summary>
        /// The test for redirect operation policy action.
        /// </summary>
        [TestMethod()]
        public void RedirectOperationPolicyActionTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(RedirectOperationPolicyAction), EncoderEngineCategory.Html, EncoderEngineCategory.Css);
        }

        /// <summary>
        /// The test for redirect operation policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void RedirectOperationPolicyActionTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.RedirectOperation, EncoderEngineCategory.Css);
        }

        #endregion

        #region RedirectUserActionPolicy tests

        /// <summary>
        /// The test for redirect user policy action.
        /// </summary>
        [TestMethod()]
        public void RedirectUserActionPolicyTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(RedirectUserActionPolicy), EncoderEngineCategory.HtmlAttribute, EncoderEngineCategory.Css);
        }

        /// <summary>
        /// The test for redirect user policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void RedirectUserActionPolicyTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.RedirectUser, EncoderEngineCategory.Css);
        }

        #endregion

        #region LogoutUserPolicyAction tests

        /// <summary>
        /// The test for logout user policy action.
        /// </summary>
        [TestMethod()]
        public void LogoutUserPolicyActionTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(LogoutUserPolicyAction), EncoderEngineCategory.Xml, EncoderEngineCategory.Css);
        }

        /// <summary>
        /// The test for logout user policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void LogoutUserPolicyActionTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.LogoutUser, EncoderEngineCategory.Css);
        }

        #endregion

        #region NotifyUserPolicyAction tests

        /// <summary>
        /// The test for notify user policy action.
        /// </summary>
        [TestMethod()]
        public void NotifyUserPolicyActionTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(NotifyUserPolicyAction), EncoderEngineCategory.XmlAttribute, EncoderEngineCategory.Css);
        }

        /// <summary>
        /// The test for notify user policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void NotifyUserPolicyActionTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.SendSecurityWarningToUser, EncoderEngineCategory.Css);
        }

        #endregion

        #region NotifyAdminPolicyAction tests

        /// <summary>
        /// The test for notify admin policy action.
        /// </summary>
        [TestMethod()]
        public void NotifyAdminPolicyActionTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(NotifyAdminPolicyAction), EncoderEngineCategory.Ldap, EncoderEngineCategory.Css);
        }

        /// <summary>
        /// The test for notify admin policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void NotifyAdminPolicyActionTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.SendAdminNotification, EncoderEngineCategory.Css);
        }

        #endregion

        #region ChangeSessionParameterPolicyAction tests

        /// <summary>
        /// The test for change session parameter policy action.
        /// </summary>
        [TestMethod()]
        public void ChangeSessionParameterPolicyActionTest_Positive()
        {
            policyActionTest_Positive(AllActions, typeof(ChangeSessionParameterPolicyAction), EncoderEngineCategory.Base64, EncoderEngineCategory.Css);
        }

        /// <summary>
        /// The test for change session parameter policy action when it's not called.
        /// </summary>
        [TestMethod()]
        public void ChangeSessionParameterPolicyActionTest_Negative()
        {
            policyActionTest_Negative(SecurityPolicyActionType.ChangeSessionParameter, EncoderEngineCategory.Css);
        }

        #endregion

        #region Distinguish actions tests

        private void DistinguishActionTest_Positive(SecurityPolicyActionType policyActionType, Type expectedActionType, EncoderEngineCategory categoryEngine, SecurityEventType securityEventType)
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                policyActionType,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, expectedActionType, EncoderSubsystemName, Convert.ToString(categoryEngine));
                }));

            try
            {
                // This exception matches two policies with the same action.
                Exception ex = new EncoderTestException(ExceptionId.Encoder.NotSetId, categoryEngine, securityEventType);
                ex.Report();

                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }

        private void DistinguishActionTest_Negative(SecurityPolicyActionType policyActionType, EncoderEngineCategory categoryEngine, SecurityEventType securityEventType)
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                policyActionType,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                }));

            try
            {
                // This exception matches two policies with the deferent actions.
                Exception ex =  new EncoderTestException(ExceptionId.Encoder.NotSetId, categoryEngine, securityEventType);
                ex.Report();

                Assert.AreEqual(2, counter, "Two handler calls were expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }
        // DistinguishActionTest_Positive(SecurityPolicyActionType.LogoutUser, typeof(LogoutUserPolicyAction), EncoderEngineCategory.Xml, SecurityEventType.AppActivityTrendEventType);
        // DistinguishActionTest_Negative(SecurityPolicyActionType.LogoutUser, EncoderEngineCategory.Xml, SecurityEventType.AppActivityTrendEventType);


        /// <summary>
        /// Test whether identiacal actions are distinguished and a handler is called once only.
        /// </summary>
        [TestMethod()]
        public void DistinguishTest_Positive()
        {
            DistinguishActionTest_Positive(SecurityPolicyActionType.LogoutUser, typeof(LogoutUserPolicyAction)
                                            , EncoderEngineCategory.Xml, SecurityEventType.AppActivityTrendEventType);
        }

        /// <summary>
        /// Test whether deferent actions are not distinguished and a handler is called for several times.
        /// </summary>
        [TestMethod()]
        public void DistinguishTest_Negative()
        {
            DistinguishActionTest_Negative(AllActions, EncoderEngineCategory.XmlAttribute, SecurityEventType.AppActivityTrendEventType);
        }

        #endregion

        #endregion

        #region Policy rule tests

        #region EventRepeatThresholdRule tests

        //The test for EventRepeatThresholdRule.
        [TestMethod()]
        public void EventRepeatThresholdRuleTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.SendSecurityWarningToUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(NotifyUserPolicyAction), DetectorSubsystemName, Convert.ToString(DetectorEngineCategory.Xss));
                }));

            try
            {
                // 3rd XSS has to raise the policy action.
                Exception ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Xss);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Xss);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Xss);
                ex.Report();
                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Xss);
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
        /// The test for EventTimespanThresholdRule.
        /// </summary>
        [TestMethod()]
        public void EventTimespanThresholdRuleTest_Positive()
        {
            System.Threading.Thread.Sleep(1000);
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.BlockOperation,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(BlockOperationPolicyAction), DetectorSubsystemName, Convert.ToString(DetectorEngineCategory.Sql));
                }));

            try
            {
                // 5th SQL has to raise the policy action.
                Exception ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(2, counter, "Two handler calls were expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }

        #endregion

        #region EventCategoryRule tests

        /// <summary>
        /// The test for EventCategoryRule.
        /// </summary>
        [TestMethod()]
        public void EventCategoryRuleTest_Positive()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.LogoutUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), DetectorSubsystemName, Convert.ToString(DetectorEngineCategory.Sql));
                }));

            try
            {
                // First event does not match the policy.
                Exception ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql);
                ex.Report();
                Assert.AreEqual(0, counter, "No handler call was expected but {0} found.", counter);

                // Second event matches the policy
                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql, SecurityEventType.AppActivityTrendEventType);
                ex.Report();
                Assert.AreEqual(1, counter, "One handler call was expected but {0} found.", counter);

                // Third event matches the policy.
                ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql, SecurityEventType.AppActivityTrendEventType);
                ex.Report();
                Assert.AreEqual(2, counter, "Two handler calls were expected but {0} found.", counter);
            }
            finally
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler(DefaultTestHandlerId);
            }
        }

        /// <summary>
        /// The test for EventCategoryRule when it does not match.
        /// </summary>
        [TestMethod()]
        public void EventCategoryRuleTest_Negative()
        {
            int counter = 0;
            SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                DefaultTestHandlerId,
                SecurityPolicyActionType.LogoutUser,
                CreateHandler(delegate(PolicyAction policyAction, ISecurityEvent securityEvent)
                {
                    counter++;
                    CheckRespondingAction(policyAction, securityEvent, typeof(LogoutUserPolicyAction), DetectorSubsystemName, Convert.ToString(DetectorEngineCategory.Sql));
                }));

            try
            {
                // First event does not match the policy.
                Exception ex = new DetectorTestException(ExceptionId.Detector.NotSetId, DetectorEngineCategory.Sql);
                ex.Report();
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

        private class EncoderTestException : BadInputDataException
        {
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
                : base(id.ToInt(), "Encoder", Convert.ToString(category), "Test monitor", SecurityEventType.Unknown)
            { }

            public DetectorTestException(ExceptionId.Detector id, DetectorEngineCategory category, SecurityEventType eventType)
                : base(id.ToInt(), "Encoder", Convert.ToString(category), "Test monitor", eventType)
            { }
        }

        private static ISecurityPolicyActionHandler CreateHandler(SecurityEventHandler handler)
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

        #endregion
    }
}
