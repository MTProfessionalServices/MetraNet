using System.IO;
using System.Collections.Generic;
using NUnit.Framework;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using Core.FileLandingService;
using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
using MetraTech.ActivityServices.Common; // For access to MTList

// Setting ComVisible to false makes the types in this assembly not visible 
// to COM componenets.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: System.Runtime.InteropServices.ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: System.Runtime.InteropServices.Guid("6aac7b29-e10d-4853-8cf3-e02d65ab960e")]


namespace MetraTech.FileService.Test
{
  /// <summary>
  ///   Unit Tests for MenuManager.
  ///   
  ///   To run the this test fixture:
  ///    nunit-console.exe /fixture:MetraTech.FileService.Test.PopulateTestData /assembly:MetraTech.FileLandingService.Test.dll
  /// </summary>
  [TestFixture]
  public class PopulateTestData
  {
    private IStandardRepository m_Repository = null;

    public IStandardRepository REPOSITORY { get { return m_Repository; } }

    #region Test Initialization
    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [TestFixtureSetUp]
    public void Init()
    {
      MetadataRepository.Instance.InitializeFromFileSystem();
      MetadataRepository.Instance.InitLocalizationData();
      RepositoryAccess.Instance.Initialize();
      m_Repository = RepositoryAccess.Instance.GetRepository();
    } 
    #endregion

    #region Default configure Data
    [Test]
    [Category("SetBasicConfiguration")]
    public void SetBasicConfiguration()
    {
      ConfigurationBE cfg = new ConfigurationBE();
      /////////////////////////////////////////////////
      // Default basic configuration
      /////////////////////////////////////////////////
      cfg._ConfRefreshIntervalInMS  = 10000; // 10 seconds
      cfg._MaximumActiveTargets     = 5;   // Can the machine handle this much ;-) What about more?
      cfg._UseDescriptorFile    = false; // not yet supported
      cfg._UseMD5               = false; // not yet supported
      cfg._UseSHA1              = false; // not yet supported
      cfg._UseToken             = false; // not yet supported
      cfg._FailedDirectory = "c:\\fls\\failed\\";
      cfg._CompletedDirectory = "c:\\fls\\completed\\";
      cfg._ActiveDirectory = "c:\\fls\\active\\";
      cfg._IncomingDirectory = "c:\\fls\\incoming\\";
      // Save the config
      REPOSITORY.SaveInstance(cfg);
    }
    #endregion

    #region SinglePoint Target Configuration
    [Test]
    [Category("SetSinglePointExecutableTarget")]
    public void SetSinglePointExecutableTarget()

    {
      TargetBE target = new TargetBE();
      target._Type = ETargetType.EXECUTABLE;
      target._Name = "rate";
      target._Description = "Runs test rating.";
      target._Executable = "o:\\debug\\bin\\MetraFlowShell.exe";
      target._RedirectFileToStdin = false;
      // Set up the critical trigger which we use to activate this target
      // Notice we place TestService and Start in the RegularExpression
      // This is for the TestService Service Definition
      // For another Service, we may want to allow .start, but want to route that
      // service to another target.
      target._Regex = "rate"; 
      REPOSITORY.SaveInstance(target); 

      ArgumentBE file1 = new ArgumentBE();
      file1._Order = 1; // This is the first file argument
      file1._Format = "--arg USAGERECORDFILE=\"$(FILE)\"";
      file1._Regex = "flat";
      file1._ConditionalFlag = EConditionalType.ALWAYS;
      // Store to the target
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, file1);

      ArgumentBE batchid = new ArgumentBE();
      batchid._Order = 2;
      batchid._Format = "--arg batchID=\"$(BATCHID)\"";
      batchid._Regex = ""; // Not valid
      batchid._ConditionalFlag = EConditionalType.ON_NEW;
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, batchid);

      ArgumentBE retryCond = new ArgumentBE();
      retryCond._Order = 4;
      retryCond._Format = "--trackingRetry $(TRACKINGID)";
      retryCond._Regex = "";
      retryCond._ConditionalFlag = EConditionalType.ON_RETRY;
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, retryCond);

      ArgumentBE fixedCond = new ArgumentBE();
      fixedCond._Order = 3;
      fixedCond._Format = "--trackingNew $(TRACKINGID)";
      fixedCond._Regex = "";
      fixedCond._ConditionalFlag = EConditionalType.ON_NEW;
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, fixedCond);

      ArgumentBE script = new ArgumentBE();
      script._Format = "R:\\extensions\\Core\\config\\MetraFlow\\Scripts\\RateTestService.mfs";
      script._Order = 5; // Forces to the last argument
      script._Regex = ""; // Not needed for a FIXED type
      script._ConditionalFlag = EConditionalType.ALWAYS;
      // Store to the target
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, script);

    }
    #endregion

    #region MultiPoint Target Configuration
    [Test]
    [Category("SetMultiPointExecutableTarget")]
    public void SetPrimaryExecutableTarget()

    {
      TargetBE target = new TargetBE();
      target._Type = ETargetType.EXECUTABLE;
      target._Name = "rateAudio";
      target._Description = "Runs test audio rating.";
      target._Executable = "o:\\debug\\bin\\MetraFlowShell.exe";
      target._RedirectFileToStdin = false;
      // Set up the critical trigger which we use to activate this target
      // Notice we place TestService and Start in the RegularExpression
      // This is for the TestService Service Definition
      // For another Service, we may want to allow .start, but want to route that
      // service to another target.
      target._Regex = "rateAudio";
      REPOSITORY.SaveInstance(target); 

      ArgumentBE file1 = new ArgumentBE();
      file1._Order = 1; // This is the first file argument
      file1._Format = "--arg AUDIOCONF=\"$(FILE)\"";
      file1._Regex = "audioConf";
      file1._ConditionalFlag = EConditionalType.ALWAYS;
      // Store to the target
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, file1);

      ArgumentBE file2 = new ArgumentBE();
      file2._Order = 2; // This is the first file argument
      file2._Format = "--arg AUDIOLEG=\"$(FILE)\"";
      file2._Regex = "audioLeg";
      file2._ConditionalFlag = EConditionalType.ALWAYS;
      // Store to the target
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, file2);

      ArgumentBE batchid = new ArgumentBE();
      batchid._Order = 3;
      batchid._Format = "--arg batchID=\"$(BATCHID)\"";
      batchid._Regex = ""; // Not valid
      batchid._ConditionalFlag = EConditionalType.ON_NEW;
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, batchid);

      ArgumentBE retryCond = new ArgumentBE();
      retryCond._Order = 5;
      retryCond._Format = "--trackingRetry $(TRACKINGID)";
      retryCond._Regex = "";
      retryCond._ConditionalFlag = EConditionalType.ON_RETRY;
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, retryCond);

      ArgumentBE fixedCond = new ArgumentBE();
      fixedCond._Order = 4;
      fixedCond._Format = "--trackingNew $(TRACKINGID)";
      fixedCond._Regex = "";
      fixedCond._ConditionalFlag = EConditionalType.ON_NEW;
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, fixedCond);

      ArgumentBE script = new ArgumentBE();
      script._Format = "R:\\extensions\\Core\\config\\MetraFlow\\Scripts\\RateAudioTestService.mfs";
      script._Order = 6; // Forces to the last argument
      script._Regex = ""; // Not needed for a FIXED type
      script._ConditionalFlag = EConditionalType.ALWAYS;
      // Store to the target
      REPOSITORY.CreateInstanceFor(typeof(TargetBE).FullName, target.Id, script);
    }
    #endregion

    #region Resubmit Target Configuration
    [Test]
    [Category("SetRerunExecutableTarget")]
    public void SetRerunExecutableTarget()
    {
    }
    #endregion
  }
}
