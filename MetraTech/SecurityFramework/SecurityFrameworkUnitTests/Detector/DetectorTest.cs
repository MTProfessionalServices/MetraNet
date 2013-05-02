using System;
using System.Diagnostics;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Detector;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests.Detector
{
    /// <summary>
    /// General test for XSS Detector
    /// </summary>
    [TestClass]
    public class DetectorTest
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
        //
        // Use TestInitialize to run code before running each test 
        [TestInitialize()]
        public void SecurityKernelAllTetsInitialize()
        {
            Assert.IsTrue(SecurityKernel.IsInitialized(), "SecurityKernel is not Initialized.");
        }
        //
        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void TestDetectJavaScriptCode()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", "eval('uuu');");
                Assert.Fail("JavaScript code not detected!");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }
        }

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void TestDetectDomElements()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", "document.write(document.domain);");
                Assert.Fail("DOM elements not detected!");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }
        }

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void TestDetectHtmlTags()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", "<embed>");
                Assert.Fail("HTML tags not detected!");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void TestDetectHtmlEvents()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", "<p onmousemove='doSomething();'>");
                Assert.Fail("HTML events not detected!");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void TestDetectExtension()
        {
            try
            {
                "<p onmousemove='doSomething();'/>".DetectXss();
                Assert.Fail("Extension for XSS Detector is not work!");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }
            
        }

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void VbScriptTest1()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", "Function CanDeliver(Dt) CanDeliver = (CDate(Dt) - Now()) > 2 End Function");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check short expression  '....?...:...' (if then else)
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void ObfuscationCodeTest_ShortIfThenElse_Positive()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", "((((1)+(2))>((2+4-6+10)*10))?((\"i\")+(\"f\")):(wrt))");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check short expression  '....?...:...' (if then else)
        /// </summary>
        [TestMethod]
        public void ObfuscationCodeTest_ShortIfThenElse_Negative()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", "((((1)+(2))>((2+4-6+10)*10))((\"i\")+(\"f\")):(wrt))");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check standart expression  'if then else'
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void ObfuscationCodeTest_StandartIfThenElse_Positive()
        {
            try
            {
                // 3 times
                string inputData = @"hhh;if( tt >= 2)
                                        y = 7;
 
                                        else y=10;if( tt >= 2)
                                        y = 7;
 
                                        else y=10;if( tt >= 2)
                                        y = 7;
 
                                        else y=10;";
                SecurityKernel.Detector.Api.Execute("Xss.V2", inputData);
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check standart expression  'if then else'
        /// </summary>
        [TestMethod]
        public void ObfuscationCodeTest_StandartIfThenElse_Negative()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", @"hhh if( tt >= 2)
                                        y = 7;
 
                                        else y=10;");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check standart expression  'if then' (without else)
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void ObfuscationCodeTest_StandartIfThen_Positive()
        {
            try
            {
                // 3 times
                string inputData = @"hhh;if( tt >= 2)
                                        y = 7;if( tt >= 2)
                                        y = 7;if( tt >= 2)
                                        y = 7;";

                SecurityKernel.Detector.Api.Execute("Xss.V2", inputData);
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check standart expression  'if then else'
        /// </summary>
        [TestMethod]
        public void ObfuscationCodeTest_StandartIfThen_Negative()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", @"hhh;if( tt >= 2)");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check assignment operator  'x=8;'
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void ObfuscationCodeTest_AssignmentOperator_Positive()
        {
            try
            {
                // 10 times
                SecurityKernel.Detector.Api.Execute("Xss.V2", "y -= 7;y -= 7;y -= 7;y -= 7;y -= 7;y -= 7;y -= 7;y -= 7;y -= 7;y -= 7;");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check assignment operator  'x=8;'
        /// </summary>
        [TestMethod]
        public void ObfuscationCodeTest_AssignmentOperator_Negative()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", "1y = 7;");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check function name  'function (y){t=i;}'
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void ObfuscationCodeTest_FunctionName_Positive()
        {
            try
            {
                // 10 times
                SecurityKernel.Detector.Api.Execute("Xss.V2", @"function (y){t=i;}+function (y){t=i;}+function (y){t=i;}
                                    +function (y){t=i;}+function (y){t=i;}+function (y){t=i;}
                                    +function (y){t=i;}+function (y){t=i;}+function (y){t=i;}+function (y){t=i;}");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        /// <summary>
        /// check function name  'function (y){t=i;}'
        /// </summary>
        [TestMethod]
        public void ObfuscationCodeTest_FunctionName_Negative()
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.V2", "function(t)");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }

        }

        const string EndExceptionStr = "------------------------------------";
        public static void WriteExceptionsToConsole(BadInputDataException ex)
        {
           Console.WriteLine(String.Format("1. Problem Id = '{0}'", ex.Id));
           Console.WriteLine(String.Format("2. Subsystem = '{0}'", ex.SubsystemName));
           Console.WriteLine(String.Format("3. Category= '{0}'", ex.CategoryName));
           Console.WriteLine(String.Format("4. Message (User will see this text)  = '{0}'", ex.Message));
           Console.WriteLine(String.Format("5. Input data = '{0}'", ex.InputData));
           Console.WriteLine(String.Format("6. Reason = '{0}'", ex.Reason));
           Console.WriteLine(String.Format("7. Event Type = '{0}'", ex.EventType));
           Console.WriteLine(EndExceptionStr);
        }
    }
}
