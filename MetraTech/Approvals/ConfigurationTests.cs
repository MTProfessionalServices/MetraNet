using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using System.IO;
using MetraTech.Basic.Config;

//using MetraTech.Security;
//using MetraTech.DomainModel.Common;
//using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;
using System;
//using MetraTech.DomainModel.BaseTypes;
using MetraTech.Approvals;
using MetraTech.DomainModel.BaseTypes;
using System.Xml.Serialization;
using MetraTech.Xml;
using System.Xml;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.InternalFrameworkTests /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
//
namespace MetraTech.Approvals.Test
{
  [TestClass]
  public class ConfigurationTests 
  {

    private Logger m_Logger = new Logger("[Approval Management Configuration Tests]");

    #region tests

    [TestMethod]
    [TestCategory("LoadConfigurationFromFile")]
    public void LoadConfigurationFromFile()
    {

      string filePath = Path.Combine(SystemConfig.GetExtensionsDir(), @"Core\config\Approvals\ChangeTypeConfiguration.xml");

      List<ChangeTypeConfiguration> changeTypes = new List<ChangeTypeConfiguration>();

      XmlSerializer serializer = new XmlSerializer(typeof(ChangeTypeConfiguration));

      //try
      //{

        //load config file
        MTXmlDocument doc = new MTXmlDocument();

        doc.Load(filePath);


        XmlNodeList subNodes = doc.SelectNodes("//ChangeTypeConfiguration");
        for (int i = 0; i < subNodes.Count; i++)
        {
          string xml = subNodes[i].OuterXml;

          MemoryStream stm = new MemoryStream();

          StreamWriter stw = new StreamWriter(stm);
          stw.Write(xml);
          stw.Flush();

          stm.Position = 0;

          ChangeTypeConfiguration temp = (serializer.Deserialize(stm) as ChangeTypeConfiguration);

          changeTypes.Add(temp);
        }

      //}
      //catch (Exception)
      //{
      //}

      // Create a new XmlSerializer instance with the type of the test class
      XmlSerializer SerializerObj = new XmlSerializer(typeof(List<ChangeTypeConfiguration>));

      // Create a new file stream to write the serialized object to a file
      TextWriter WriteFileStream = new StreamWriter(filePath);
      SerializerObj.Serialize(WriteFileStream, changeTypes);

      // Cleanup
      WriteFileStream.Close();

    }

    /*
    [TestMethod]
    [TestCategory("WriteConfigurationToFile")]
    public void WriteConfigurationToFile()
    {

      string filePath = Path.Combine(SystemConfig.GetExtensionsDir(), @"Core\config\Approvals\ChangeTypeConfiguration.Test2.xml");

      //List<ChangeTypeConfiguration> changeTypeConfiguration = ApprovalsConfigurationManager.LoadChangeTypesFromFile(filePath);

      ApprovalsConfiguration config = ApprovalsConfigurationManager.Load();
      ChangeTypeConfiguration itemRateUpdate = config["RateUpdate"];

      List<ChangeTypeConfiguration> changeTypes = new List<ChangeTypeConfiguration>() { config["RateUpdate"], config["AccountUpdate"], config["SampleUpdate"] };

      // Create a new XmlSerializer instance with the type of the test class
      XmlSerializer SerializerObj = new XmlSerializer(typeof(List<ChangeTypeConfiguration>));

      // Create a new file stream to write the serialized object to a file
      TextWriter WriteFileStream = new StreamWriter(filePath);
      SerializerObj.Serialize(WriteFileStream, changeTypes);

      // Cleanup
      WriteFileStream.Close();

    }
    */

    [TestMethod]
    [TestCategory("LoadConfigurationFromAllExtensions")]
    public void LoadConfigurationFromAllExtensions()
    {
      ApprovalsConfiguration config = ApprovalsConfigurationManager.LoadChangeTypesFromAllExtensions();
	    Assert.IsTrue(config.Count > 1, "Expected at least one change type to be configured");
    }

    [TestMethod]
    [TestCategory("MetraTechPathHelperTryGetExtensionFromPath")]
    public void MetraTechPathHelperTryGetExtensionFromPath()
    {
      string filePath = @"R:\extensions\Core\config\Approvals\ChangeTypeConfiguration.xml";
      string extensionName = "";
      bool success = MetraTechPathHelper.TryGetExtensionFromPath(filePath, out extensionName);

      Assert.IsTrue(success);
      Assert.AreEqual("Core", extensionName);
    }

    [TestMethod]
    [TestCategory("MetraTechPathHelperTryGetExtensionFromPathNegative")]
    public void MetraTechPathHelperTryGetExtensionFromPathNegative()
    {
      string filePath = @"R:\PathWithoutExtentions\Core\config\Approvals\ChangeTypeConfiguration.xml";
      string extensionName = "";
      bool success = MetraTechPathHelper.TryGetExtensionFromPath(filePath, out extensionName);

      Assert.IsFalse(success);
      Assert.IsNull(extensionName, "Extension should not have been found");
    }

    //[TestMethod]
    //[TestCategory("ModifyAndSaveUpdateToChangeTypeFile")]
    public void ModifyAndSaveUpdateToChangeTypeFile()
    {
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      ChangeTypeConfiguration changeType = approvalsConfig["SampleUpdate"];

      //Modify a change type
      string newDescription = "Updated by unit test on " + DateTime.Now.ToString();
      string previousDescription = changeType.Description;
      changeType.Description = newDescription;

      ApprovalsConfigurationManager.SaveChangeType(changeType);

      //Reload the file, locate our update change type and verify
      ApprovalsConfiguration approvalsConfigAfterModification = ApprovalsConfigurationManager.Load();
      ChangeTypeConfiguration changeTypeAfterUpdate = approvalsConfig["SampleUpdate"];

      Assert.AreEqual(newDescription, changeTypeAfterUpdate.Description, "Reloaded Description after Save did not match");

      //Save back the original description
      changeTypeAfterUpdate.Description = previousDescription;
      ApprovalsConfigurationManager.SaveChangeType(changeTypeAfterUpdate);

    }

    [TestMethod]
    [TestCategory("GetListOfFilesLoadedFromConfiguration")]
    public void GetListOfFilesLoadedFromConfiguration()
    {
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      //Assert.That(approvalsConfig.Count, Is.GreaterThan(0));
	  Assert.IsTrue(approvalsConfig.Count > 0);
	  Assert.IsTrue(approvalsConfig.FilesLoaded.Count>0);
    }

    [TestMethod]
    [TestCategory("ApprovalsEnabled")]
    public void ApprovalsEnabled()
    {
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();

      //Disable all the change types
      foreach (ChangeTypeConfiguration changeType in approvalsConfig.Values)
      {
        changeType.Enabled = false;
      }

      Assert.IsFalse(approvalsConfig.ApprovalsEnabled);

      //Approvals Configuration caches enabled check, need to reinitialize
      approvalsConfig = ApprovalsConfigurationManager.Load();

      //Now set one to enabled and check again
      approvalsConfig["SampleUpdate"].Enabled = true;

      Assert.IsTrue(approvalsConfig.ApprovalsEnabled);
    }

    [TestMethod]
    [TestCategory("GetFileWatcherFromConfiguration")]
    public void GetFileWatcherFromConfiguration()
    {
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();

      ApprovalsFileWatcher fileWatcher = ApprovalsConfigurationManager.GetFileWatcherFromConfiguration(approvalsConfig, OnFileChangedHandler);
    }

          private static void OnFileChangedHandler(object source, FileSystemEventArgs e)
          {
            // Specify what is done when a file is changed, created, or deleted.
            Console.WriteLine("Test Default Handler: File: " + e.FullPath + " " + e.ChangeType);
          }


  }
    #endregion
}