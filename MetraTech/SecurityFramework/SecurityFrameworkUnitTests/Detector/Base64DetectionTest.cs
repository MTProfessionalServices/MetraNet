using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Detector;
using MetraTech.SecurityFramework.Core.Detector.Engine;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests.Detector
{
    [TestClass]
    public class Base64DetectionTest
    {
        private static Base64Detector _base64detector = null;
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

        #region Base64 detector engines
        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        // Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void SecurityKernelInitialize(TestContext testContext)
        {
            UnitTestUtility.InitFrameworkConfiguration(testContext);
            _base64detector = new Base64Detector();
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

        #region Base64 standart encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectBase64StandartEncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29yZCEgSXQncyBCQVNFNjQu");
        }

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectBase64StandartEncodingTest2()
        {
            DetectBase64GeneralTest("SGVsbG8gd29yZCEgSXQncyBCQVNFNjQhIQ==");
        }

        [TestMethod]
        //[ExpectedException(typeof(DetectorInputDataException))]
        public void DetectBase64StandartEncodingTest_Negative()
        {
            DetectBase64GeneralTest_Negative("LLrHB0eJzyhP+_fSStdW8okeEnv47jxe7SJ_iN72ohNcUk2jHEUSoH1nvNSIWL9M8tEjmF_zxB-bATMtPjCUWbz8Lr9wloXIkjHUlBLpvXR0UrUzYbkNpk0agV2IzUpkJ6UiRRGcDSvzrsoK+oNvqu6z7Xs5Xfz5rDqUcMlK1Z6720dcBWGGsDLpTpSCnpotdXd_H5LMDWnonNvPCwQUHtDD");
        }


        #endregion Base64 standart encoding

        #region IRCu encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectIRCuEncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29yZCEgSXQncyBCQVNFNjQhIQ00");
        }

        #endregion IRCu encoding

        #region MIME Base64 encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectMIMEBase64EncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29y+CEgSXQ/cyBCQVNFNjQu");
        }
        
        #endregion  MIME Base64  encoding

        #region Modified Base64 for URL applications encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectModifiedBase64ForURLApplicationsEncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29y-CEgSXQ_cyBCQVNFNjQu");
        }

        #endregion  Modified Base64 for URL applications  encoding

        #region Modified Base64 for filenames encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectModifiedBase64ForFilenamesEncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29y+CEgSXQ-cyBCQVNFNjQu");
        }

        #endregion  Modified Base64 for filenames encoding

        #region Modified Base64 for XML name tokens  encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectModifiedBase64ForXMLNameEncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29y.CEgSXQ-cyBCQVNFNjQu");
        }

        #endregion  Modified Base64 for XML name tokens   encoding

        #region Modified Base64 for XML identifiers encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectModifiedBase64ForXMLIdentifiersEncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29y_CEgSXQ:cyBCQVNFNjQu");
        }

        #endregion  Modified Base64 for XML identifiers encoding

        #region Modified Base64 for Program identifiers encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectModifiedBase64ForProgramIdentifiersVer1EncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29y_CEgSXQ-cyBCQVNFNjQu");
        }

        #endregion  Modified Base64 for Program identifiers  encoding

        #region Modified Base64 for Program identifiers encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectModifiedBase64ForProgramIdentifiersVar2EncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29y.CEgSXQ_cyBCQVNFNjQu");
        }

        #endregion  Modified Base64 for Program identifiers  encoding


        #region Modified Base64 for Regular expressions encoding

        [TestMethod]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectModifiedBase64ForRegexEncodingTest1()
        {
            DetectBase64GeneralTest("SGVsbG8gd29y!CEgSXQ-cyBCQVNFNjQu");
        }

        #endregion  Modified Base64 for Regular expressions  encoding

        #region Negatives tests
        [TestMethod]
        public void DetectBase64Tets_Negative1()
        {
            DetectBase64GeneralTest_Negative("aGVsbG8gd29y+ZA=");
        }

        [TestMethod]
        public void DetectBase64Tets_Negative3()
        {
            DetectBase64GeneralTest_Negative("aGVsbG8gd29y-ZA=");
        }

        [TestMethod]
        public void DetectBase64Tets_Negative4()
        {
            DetectBase64GeneralTest_Negative("aGVsbGqwdfdfsagfdgf8gd29y ZA!");
        }

        [TestMethod]
        public void DetectBase64Tets_Negative5()
        {
            DetectBase64GeneralTest_Negative("aGVsbG8gdgfdsgdfsgfdgdhgfhfgdhgdsd29yZA !");
        }

        [TestMethod]
        public void DetectBase64Tets_Negative6()
        {
            DetectBase64GeneralTest_Negative("aGVsbG8gd2hsdndghghgfdh+9y=ZA!");
        }
        #endregion Negatives tests

        private void DetectBase64GeneralTest(string inputStr)
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.DetectBase64", inputStr);
                Assert.Fail("Detector is NOT detection a Base64 encoding!");
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                DetectorTest.WriteExceptionsToConsole(detectorInputDataException);
                throw;
            }
        }

        private void DetectBase64GeneralTest_Negative(string inputStr)
        {
            try
            {
                SecurityKernel.Detector.Api.Execute("Xss.DetectBase64", inputStr);
                
            }
            catch (DetectorInputDataException detectorInputDataException)
            {
                DetectorTest.WriteExceptionsToConsole(detectorInputDataException);
                Assert.Fail("Detector for Base64 was not detected base64 sequence. This is a negative test.");
            }
        }
        #endregion Base64 detector engines

      

    }
}
