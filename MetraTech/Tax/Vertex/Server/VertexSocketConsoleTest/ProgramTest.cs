//using VertexSocketService;
//using Microsoft.VisualStudio.TestTools.UnitTesting;
//using System;
//using System.Net;

//namespace VertexSocketConsoleTest
//{
    
    
//    /// <summary>
//    ///This is a test class for ProgramTest and is intended
//    ///to contain all ProgramTest Unit Tests
//    ///</summary>
//  [TestClass()]
//  public class ProgramTest
//  {


//    private TestContext testContextInstance;

//    /// <summary>
//    ///Gets or sets the test context which provides
//    ///information about and functionality for the current test run.
//    ///</summary>
//    public TestContext TestContext
//    {
//      get
//      {
//        return testContextInstance;
//      }
//      set
//      {
//        testContextInstance = value;
//      }
//    }

//    #region Additional test attributes
//    // 
//    //You can use the following additional attributes as you write your tests:
//    //
//    //Use ClassInitialize to run code before running the first test in the class
//    //[ClassInitialize()]
//    //public static void MyClassInitialize(TestContext testContext)
//    //{
//    //}
//    //
//    //Use ClassCleanup to run code after all tests in a class have run
//    //[ClassCleanup()]
//    //public static void MyClassCleanup()
//    //{
//    //}
//    //
//    //Use TestInitialize to run code before running each test
//    //[TestInitialize()]
//    //public void MyTestInitialize()
//    //{
//    //}
//    //
//    //Use TestCleanup to run code after each test has run
//    //[TestCleanup()]
//    //public void MyTestCleanup()
//    //{
//    //}
//    //
//    #endregion

    
//    /// <summary>
//    ///A test for Program Constructor
//    ///</summary>
//    [TestMethod()]
//    public void ProgramConstructorTest()
//    {
//      Program target = new Program();
//      Assert.IsNotNull(target);
//    }

//    /// <summary>
//    ///A test for BuildStringsForServerConsole
//    ///</summary>
//    [TestMethod()]
//    [DeploymentItem("VertexSocketService.exe")]
//    public void BuildStringsForServerConsoleTest()
//    {
//      Program_Accessor.BuildStringsForServerConsole();
//    }

//    /// <summary>
//    ///A test for Main
//    ///</summary>
//    [TestMethod()]
//    [DeploymentItem("VertexSocketService.exe")]
//    public void MainTest()
//    {
//      string[] args = null; 
//      Program_Accessor.Main(args);
//    }

//    /// <summary>
//    ///A test for ManageClosing
//    ///</summary>
//    [TestMethod()]
//    [DeploymentItem("VertexSocketService.exe")]
//    public void ManageClosingTest()
//    {
//      SocketListener_Accessor socketListener = null; 
//      Program_Accessor.ManageClosing(socketListener);
//    }

//    /// <summary>
//    ///A test for ReadAndLoadAllValuesFromConfig
//    ///</summary>
//    [TestMethod()]
//    [DeploymentItem("VertexSocketService.exe")]
//    public void ReadAndLoadAllValuesFromConfigTest()
//    {
//      Program_Accessor.ReadAndLoadAllValuesFromConfig();
//      Assert.IsTrue(Program_Accessor.backlog == 100);
//      Assert.IsTrue(Program_Accessor.bufferSize == 25000);
//    }

//    /// <summary>
//    ///A test for WriteInfoToConsole
//    ///</summary>
//    [TestMethod()]
//    public void WriteInfoToConsoleTest()
//    {
//      IPEndPoint localEndPoint = new IPEndPoint(IPAddress.Any, Program.port);
//      Program.WriteInfoToConsole(localEndPoint);
//    }
//  }
//}
