using MetraTech.Core.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;

//using MetraTech.Security;
//using MetraTech.DomainModel.Common;
//using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;
using System;
//using MetraTech.DomainModel.BaseTypes;
using MetraTech.Approvals;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using System.Reflection;
using System.IO;
using MetraTech.Basic.Config;


//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.ReflectionTest /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
//
namespace MetraTech.Approvals.Test
{
  [TestClass]
  public class ReflectionTest
  {

    private Logger m_Logger = new Logger("[ApprovalManagementTest]");

    #region tests

    [TestMethod]
    [TestCategory("FindMethod")]
    [Ignore] //("Reflection test relies on this being developer VM or that product binaries can be explicity located using system config")]
    public void FindMethod()
    {
      IApprovalFrameworkApplyChange changeType;

      changeType = Reflection.GetInterface<IApprovalFrameworkApplyChange>(@"o:\debug\bin\MetraTech.Approvals.dll", "MetraTech.Approvals.ChangeTypes.SampleUpdateChangeType");

      Assert.IsNotNull(changeType, "Unable to retrieve IApprovalFrameworkApplyChange from SampleUpdateChangeType");

      //MetraTech.Approvals.ChangeTypes.RateUpdateChangeType

      changeType = Reflection.GetInterface<IApprovalFrameworkApplyChange>(@"o:\debug\bin\MetraTech.Approvals.dll", "MetraTech.Approvals.ChangeTypes.RateUpdateChangeType");
      Assert.IsNotNull(changeType, "Unable to retrieve IApprovalFrameworkApplyChange from RateUpdateChangeType");

    }

    [TestMethod]
    [TestCategory("CallWebService")]
    [Ignore] //("Reflection test relies on this being developer VM or that product binaries can be explicity located using system config")]
    public void CallWebService()
    {
        //<ConfigFile>PaymentSvrClient\config\UsageServer\PayAuthAdapter_US.xml</ConfigFile>
        //<EndPoint>WSHttpBinding_IElectronicPaymentServices</EndPoint>
            //Create the change
      int accountIdToUpdate = 123;

      //MetraTech.DomainModel.BaseTypes.Account account = new MetraTech.DomainModel.BaseTypes.Account();
      MetraTech.DomainModel.AccountTypes.IndependentAccount account = new IndependentAccount();

      account._AccountID = accountIdToUpdate;

      //Change something on the account
      ContactView shipToContactView;
      shipToContactView = (ContactView) MetraTech.DomainModel.BaseTypes.View.CreateView(@"metratech.com/contact");
      shipToContactView.ContactType = ContactType.Ship_To;
      shipToContactView.FirstName = "Ted";
      shipToContactView.Address1 = MetraTime.Now.ToString();

      account.AddView(shipToContactView, "LDAP");


      ApprovalsConfiguration config = ApprovalsConfigurationManager.Load();
      MethodConfiguration methodConfig = config["AccountUpdate"].MethodForApply;

      methodConfig.EndPointName = "WSHttpBinding_IAccountCreation";
      //methodConfig.ConfigFileLocation = @"\RMP\extensions\Account\bin\MetraTech.Account.config"; //C:\dev\6.7.0-Development\RMP\extensions\Account\bin\MetraTech.Account.config
      methodConfig.ConfigFileLocation = @"extensions\Account\bin\MetraTech.Account.config";
      methodConfig.ClientProxyType = "MetraTech.Account.ClientProxies.AccountCreationClient, MetraTech.Account.ClientProxies";
      methodConfig.Name = "UpdateAccountView";
      methodConfig.Assembly = @"r:\Extensions\Account\bin\MetraTech.Account.ClientProxies.dll";

      
      Type clientType = Type.GetType(methodConfig.ClientProxyType, true, true);

      string configFileFullPath = methodConfig.ConfigFileLocation;
      if (!Path.IsPathRooted(configFileFullPath))
        configFileFullPath = Path.Combine(SystemConfig.GetRmpDir(), configFileFullPath);
      
      if (!File.Exists(configFileFullPath))
          throw new MASBasicException("Unable to load config file for webservice client. File does not exist at " + configFileFullPath);

      //var client = MASClientClassFactory.CreateClient(methodConfig.ClientProxyType,methodConfig.ConfigFileLocation, methodConfig.EndPointName);
      var client = MASClientClassFactory.CreateClient(methodConfig.ClientProxyType,methodConfig.ConfigFileLocation, methodConfig.EndPointName);

      MetraTech.Account.ClientProxies.AccountCreationClient accCreationtClient = null;
      accCreationtClient = new MetraTech.Account.ClientProxies.AccountCreationClient("WSHttpBinding_IAccountCreation");

      ////Now call methods on client dynamically
      //var client = accCreationtClient;

      accCreationtClient.ClientCredentials.UserName.UserName = "su";
      accCreationtClient.ClientCredentials.UserName.Password = "su123";

      string ticket;
      //string sessionContext;

      //MetraTech.Core.Services.AuthService authService = new MetraTech.Core.Services.AuthService();
      //authService.InitializeSecurity("su","system_user", "su123");
      ////Eventually save this so we can reuse it
      //authService.TicketToAccount("system_user", "admin", 1, out ticket, out sessionContext);

      ticket = "blah";

      //Call method dynamically to set UserName property to ticket value

      //Type type = client.GetType();

      object oClientCredentials = client.GetType().GetProperty("ClientCredentials").GetValue(client, null);
      object oUserName = oClientCredentials.GetType().GetProperty("UserName").GetValue(oClientCredentials, null);
      //object oUserNameUserName = oUserName.GetType().GetProperty("UserName").GetValue(oUserName, null);
      oUserName.GetType().GetProperty("UserName").SetValue(oUserName, ticket, null);

      ////object userName = type.GetProperty("ClientCredentials").PropertyType.GetProperty("UserName").GetValue(client, null);
      //PropertyInfo propUserName = type.GetProperty("ClientCredentials").PropertyType.GetProperty("UserName").PropertyType.GetProperty("UserName");
      //propUserName.SetValue(userName, ticket, null);


      //accCreationtClient.ClientCredentials.UserName.UserName = ticket;
      //client.ClientCredentials.UserName.Password = "su123";

      //accCreationtClient.UpdateAccountView(account);

      MethodInfo methodInfo = clientType.GetMethod(methodConfig.Name);
      if (methodInfo != null)
      {
        object result = null;
        ParameterInfo[] parameters = methodInfo.GetParameters();
        //object classInstance = Activator.CreateInstance(clientType, null);
        if (parameters.Length == 0)
        {
          //This works fine
          result = methodInfo.Invoke(client, null);
        }
        else
        {
          object[] parametersArray = new object[] {account};

          result = methodInfo.Invoke(client, parametersArray);
        }
      }

    }
  }

    #endregion
}