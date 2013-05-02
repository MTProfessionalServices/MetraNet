using System;
using System.Collections;
using System.Collections.Generic;
using Core.FileLandingService.Interface;
using MetraTech.BusinessEntity.DataAccess;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.Core.Services.ClientProxies;
using Core.FileLandingService;
using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Core.Services.UnitTests
{
  // To Run this fixture
  // nunit-console /fixture:MetraTech.Core.Services.UnitTests.FLSManagementServiceUnitTests /assembly:O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll
  [TestClass]
  public class FLSManagementServiceUnitTests
  {
    private static Random random;
    
    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [ClassInitialize]
	public static void InitTests(TestContext testContext)
    {
      random = new Random();
      RepositoryAccess.Instance.Initialize();
    }

    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [ClassCleanup]
    public static void Dispose()
    {
    }

    [TestMethod]
    [TestCategory("GetFileErrorDetails")]
    public void GetFileErrorDetails()
    {      
      string id = random.Next().ToString();
      InvocationRecordBE job = CreateJob(id, EInvocationState.FAILED);
      job.FileBEs = new List<IFileBE>();
      
      string fileName = "test.txt" + id;
      FileBE be = new FileBE();
      be.FileBEBusinessKey._FullName = fileName;
      be.FileBEBusinessKey.EntityFullName = typeof (FileBEBusinessKey).FullName;
      be._Name = fileName;
      be._State = EFileState.ASSIGNED;
      be._ErrorMessage = "my error";
      StandardRepository.Instance.CreateInstanceFor<InvocationRecordBE, FileBE>(job.Id, ref be);
      job.FileBEs.Add(be);
      
      FLSManagementServiceClient client = new FLSManagementServiceClient("WSHttpBinding_IFLSManagementService");
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();
      string errorDetails = "";
      client.GetFileDetails(fileName, out errorDetails);
      Assert.AreEqual("my error", errorDetails);
    }

    [TestMethod]
    [TestCategory("GetFileDetailsForCompletedJob")]
    public void GetFileDetailsForCompletedJob()
    {
      string id = random.Next().ToString();
      InvocationRecordBE job = CreateJob(id, EInvocationState.COMPLETED);
      string fileName = "success.txt" + random.Next().ToString();
      FileBE be = new FileBE();
      be.FileBEBusinessKey._FullName = fileName;
      be.FileBEBusinessKey.EntityFullName = typeof(FileBEBusinessKey).FullName;
      be._Name = fileName;
      be._State = EFileState.ASSIGNED;
      StandardRepository.Instance.CreateInstanceFor<InvocationRecordBE, FileBE>(job.Id, ref be);
      job.FileBEs.Add(be);

      FLSManagementServiceClient client = new FLSManagementServiceClient("WSHttpBinding_IFLSManagementService");
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();
      string fileDetails = "";
      client.GetFileDetails(fileName, out fileDetails);
      Assert.AreEqual("The file completed processing.", fileDetails);

    }

    [TestMethod]
    [TestCategory("GetFileDetailsForPendingFiles")]
    public void GetFileDetailsForPendingFiles()
    {
      string id = random.Next().ToString();
      InvocationRecordBE job = CreateJob(id, EInvocationState.ACTIVE);
      job.FileBEs = new List<IFileBE>();

      string fileName = "test.txt" + id;
      FileBE be = new FileBE();
      be.FileBEBusinessKey._FullName = fileName;
      be.FileBEBusinessKey.EntityFullName = typeof(FileBEBusinessKey).FullName;
      be._Name = fileName;
      be._State = EFileState.ASSIGNED;
      StandardRepository.Instance.CreateInstanceFor<InvocationRecordBE, FileBE>(job.Id, ref be);
      job.FileBEs.Add(be);

      FLSManagementServiceClient client = new FLSManagementServiceClient("WSHttpBinding_IFLSManagementService");
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();
      string details = "";
      client.GetFileDetails(fileName, out details);
      Assert.AreEqual("The file is being processed.", details);
    }


    [TestMethod]
    [TestCategory("GetFailedFiles")]
    public void GetFailedFiles()
    {
      string fileName = "test_1.txt" + random.Next().ToString();
      string fileName2 = "test_2.txt" + random.Next().ToString();
      InvocationRecordBE job = new InvocationRecordBE();
      job._BatchId = "Qwenchanio";
      job._Command = "MetraFlow";
      job._ControlNumber = "1800Collect";
      job._DateTime = MetraTime.Now;
      job._TrackingId = "123";
      job._State = EInvocationState.FAILED;
      StandardRepository.Instance.SaveInstance(ref job);
      
      FileBE be = new FileBE();
      be.FileBEBusinessKey._FullName = fileName;
      be.FileBEBusinessKey.EntityFullName = typeof (FileBEBusinessKey).FullName;
      be._Name = fileName;
      be._ErrorMessage = "my error";
      be._State = EFileState.ASSIGNED;

      FileBE be1 = new FileBE();
      be1.FileBEBusinessKey._FullName = fileName2;
      be1.FileBEBusinessKey.EntityFullName = typeof (FileBEBusinessKey).FullName;
      be1._Name = fileName2;
      be1._ErrorMessage = "my error 2";
      be1._State = EFileState.ASSIGNED;

      StandardRepository.Instance.CreateInstanceFor<InvocationRecordBE, FileBE>(job.Id, ref be);
      StandardRepository.Instance.CreateInstanceFor<InvocationRecordBE, FileBE>(job.Id, ref be1);
      job.FileBEs = new List<IFileBE>();
      job.FileBEs.Add(be);
      job.FileBEs.Add(be1);
      
      FLSManagementServiceClient client = new FLSManagementServiceClient("WSHttpBinding_IFLSManagementService");
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();
      List<string> fileNames = null;
      client.GetFailedFiles(out fileNames);
      Assert.AreEqual(3, fileNames.Count);
    }





    #region private methods
    private InvocationRecordBE CreateJob(string id, EInvocationState state)
    {
      InvocationRecordBE job = new InvocationRecordBE();
      job._BatchId = "Qwenchanio";
      job._Command = "MetraFlow";
      job._ControlNumber = "1800Collect";
      job._DateTime = MetraTime.Now;
      job._TrackingId = "123";
      job._State = state;
      StandardRepository.Instance.SaveInstance<InvocationRecordBE>(ref job);
      return job;
    }

    #endregion
  }
}
