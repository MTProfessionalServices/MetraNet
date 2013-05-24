using System;
using System.Collections;
using System.IO;
using System.Reflection;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using System.Collections.Generic;
using System.ServiceModel;

//Temporary
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DataAccess;
using MetraTech.Interop.QueryAdapter;
using MetraTech.ActivityServices.Services.Common;
using System.Transactions;

namespace MetraTech.Approvals
{
  public class Reflection
  {
    //      S:\MetraTech\Core\Client\CoreClientConnector.cs
    //S:\MetraTech\ActivityServices\Common\MASClientClassFactory.cs
    //S:\MetraTech\ActivityServices\Runtime\MASInternalMASCallService.cs


    //string configFilePath = m_ConfigSection.WCFConfigFile;

    //if (!Path.IsPathRooted(configFilePath))
    //{
    //    IMTRcd rcd = new MTRcdClass();
    //    configFilePath = Path.Combine(rcd.ExtensionDir, configFilePath);
    //}


    //      RecurringPaymentsServiceClient client = MASClientClassFactory.CreateClient<RecurringPaymentsServiceClient>(configFilePath, m_ConfigSection.EPSEndpoint);      
    //client.ClientCredentials.UserName.UserName = superUser.UserName;
    //client.ClientCredentials.UserName.Password = superUser.Password;


    public static T GetInterface<T>(string assemblyName, string className)
    {
      string assemblyPath;
      if (Path.IsPathRooted(assemblyName))
        assemblyPath = assemblyName;
      else
        assemblyPath = Path.Combine(SystemConfig.GetBinDir(), assemblyName);

      //Assembly assembly = Assembly.LoadFile(assemblyPath);
      Assembly assembly = Assembly.GetExecutingAssembly();

      Type type = assembly.GetType(className);
      if (type==null)
      {
        Logger logger = new Logger("[ApprovalImplementation]");
        logger.LogError(
          "The assembly {0} was loaded but GetType('{1}') on the assembly failed. Check that the className is {1} is correct", assemblyPath, className);
      }
      
      if (type==null)
      {
        Logger logger = new Logger("[ApprovalImplementation]");
        logger.LogError(
          "The assembly {0} was loaded but GetType('{1}') on the assembly failed. Check that the className is {1} is correct", assemblyPath, className);
      }
      
      T runnable;
      try
      {
        object debug = Activator.CreateInstance(type);
        //Type[] interfaces = debug.GetType().GetInterfaces();

        ////MetraTech.Approvals.ChangeTypes.SampleUpdateChangeType changeType =
        ////  (MetraTech.Approvals.ChangeTypes.SampleUpdateChangeType) debug;

        //MetraTech.Approvals.IApprovalFrameworkApplyChange applyInterface =
        //  (MetraTech.Approvals.IApprovalFrameworkApplyChange) debug;

        runnable = (T) debug;
      }
      catch (Exception /*ex*/)
      {
        //string msg = ex.Message;
        runnable = default(T); //null;
      }

      return runnable;
    }

    public static object CallWebServiceClientMethodDynamically(MethodConfiguration methodConfig,
                                                               Dictionary<string, object> possibleMethodArguments,
                                                               int userIdToImpersonate)
                                        
    {
      //<ConfigFile>PaymentSvrClient\config\UsageServer\PayAuthAdapter_US.xml</ConfigFile>
      //<EndPoint>WSHttpBinding_IElectronicPaymentServices</EndPoint>

      Type clientType;
      try
      {
        clientType = Type.GetType(methodConfig.ClientProxyType, true, true);
      }
      //Catch and throw MASBasicException so that we don't go down to Exception
      catch (MASBasicException)
      {
        throw;
      }
      catch (Exception ex)
      {
        throw new MASBasicException(
          string.Format("Unable to load or GetType for {0}. Check the configuration and assembly loading: {1}",
                        methodConfig.ClientProxyType, ex.Message));
      }

      object client;
      try
      {
        string configFileLocation = methodConfig.ConfigFileLocation;
        if (!string.IsNullOrWhiteSpace(configFileLocation))
        {
          configFileLocation = MethodConfigurationManager.GetFullPathToWebServiceConfigFile(configFileLocation);
          if (!File.Exists(configFileLocation))
            throw new Exception("WebService configuration file does not exist at " + configFileLocation);
        }

        client = MASClientClassFactory.CreateClient(methodConfig.ClientProxyType, methodConfig.EndPointName, configFileLocation);

        //MetraTech.Account.ClientProxies.AccountCreationClient accCreationtClient = null;
        //accCreationtClient = new MetraTech.Account.ClientProxies.AccountCreationClient("WSHttpBinding_IAccountCreation");
        //client = accCreationtClient;
      }
      catch (Exception ex)
      {
        throw new MASBasicException(
          string.Format(
            "Unable to create an instance of the configured web service client {0}. Check the configuration and assembly loading: {1}",
            methodConfig.ClientProxyType, ex.Message));
      }

      //Create ticket / login to service
      //Need to change ticket generation to use service and su context
      string ticket = GetTicketToUseToCallWebservice(userIdToImpersonate);

      //Call method dynamically to set UserName property to ticket value
      try
      {
        object oClientCredentials = client.GetType().GetProperty("ClientCredentials").GetValue(client, null);
        object oUserName = oClientCredentials.GetType().GetProperty("UserName").GetValue(oClientCredentials, null);
        oUserName.GetType().GetProperty("UserName").SetValue(oUserName, ticket, null);
      }
      catch (Exception ex)
      {
        throw new MASBasicException(
          string.Format(
            "Unable to set the ClientCredentials on the configured webservice client {0}. Check the configuration and that this client supports setting ClientCredentials: {1}",
            methodConfig.ClientProxyType, ex.Message));
      }

      MethodInfo methodInfo;
      try
      {
        methodInfo = clientType.GetMethod(methodConfig.Name);
      }
      catch (Exception ex)
      {
        throw new MASBasicException(
          string.Format(
            "Unable to get method info for method {2} on the web service client {0}. Check the method configuration: {1}",
            methodConfig.ClientProxyType, ex.Message, methodConfig.Name));
      }

      if ((methodInfo == null) || (client == null) || (clientType == null))
        throw new MASBasicException(
          string.Format(
            "Unable to get method info for method {1} on the web service client {0}. Check the method configuration and assembly loading.",
            methodConfig.ClientProxyType, methodConfig.Name));


      //Populate Parameters Dynamically and Invoke Method
      object result = null;
      try
      {
        ParameterInfo[] parametersDefinition = methodInfo.GetParameters();
        if (parametersDefinition.Length == 0)
        {
          result = methodInfo.Invoke(client, null);
        }
        else
        {
          object[] parametersArray = new object[parametersDefinition.Length];
          int paramCounter = 0;

          foreach (ParameterInfo paramInfo in parametersDefinition)
          {
            if (possibleMethodArguments.ContainsKey(paramInfo.Name))
            {
              parametersArray[paramCounter++] = possibleMethodArguments[paramInfo.Name];
            }
            else
            {
              throw new Exception(
                string.Format("The configured method {0} requires the argument {1} which was not passed.",
                              methodConfig.Name, paramInfo.Name));
            }
          }

          result = methodInfo.Invoke(client, parametersArray);
        }
      }
      catch (Exception ex)
      {
        string innerExceptionMessage = "";
        Exception exInner = ex.InnerException;
        if (exInner is FaultException<MASBasicFaultDetail>)
        {
          var tempEx = exInner as FaultException<MASBasicFaultDetail>;
          throw new MASBasicException(tempEx.Detail);
        }

        while (exInner != null)
        {
          innerExceptionMessage = string.Format(": {0}", exInner.Message);
          exInner = exInner.InnerException;
        }

        throw new MASBasicException(string.Format("Unable to invoke for method {2} on the web service client {0}{3}: {1}",
                                                  methodConfig.ClientProxyType, ex.Message, methodConfig.Name, innerExceptionMessage));
      }

      return result;
    }

    public static string GetTicketToUseToCallWebservice(int userIdToImpersonate)
    {
      //Create ticket / login to service
      string userName;
      string nameSpace;
      GetUserNameAndNameSpaceFromUserId(userIdToImpersonate, out userName, out nameSpace);

      return GetTicketToUseToCallWebservice(userIdToImpersonate, userName, nameSpace);
    }

    public static string GetTicketToUseToCallWebservice(int userIdToImpersonate, string userName, string nameSpace)
    {
      //Create ticket / login to service

      //Need to change ticket generation to use service and su context
      int ticketTimeOutInMinutes = 1; //Make configurable?
      string ticket;
      //string sessionContext;
      //ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
      //sa.Initialize();
      //ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");

      //MetraTech.Core.Services.AuthService authService = new MetraTech.Core.Services.AuthService();
      //authService.InitializeSecurity("su","system_user", "su123");
      ////Eventually save this so we can reuse it
      //authService.TicketToAccount("system_user", "admin", 1, out ticket, out sessionContext);
      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress))
      {
        ticket = TicketManager.CreateTicket(userIdToImpersonate, nameSpace, userName, ticketTimeOutInMinutes);
        scope.Complete();
      }

      return ticket;
    }

    public static void GetUserNameAndNameSpaceFromUserId(int userId, out string userName, out string nameSpace)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\AccHierarchies"))
      {
        MTQueryAdapter queryAdapter = new MTQueryAdapter();
        queryAdapter.Init("Queries\\AccHierarchies");
        queryAdapter.SetQueryTag("__RESOLVE_USERNAME_NAMESPACE_FROM_USERID__");

        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.GetQuery()))
        {
          stmt.AddParam(MTParameterType.Integer, userId);

          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            if (reader.Read())
            {
              nameSpace = reader.GetString("nm_space");
              userName = reader.GetString("nm_login");
            }
            else
            {
              throw new MASBasicException("Invalid user id:" + userId);
            }

          }
        }
      }
    }
  
  }

  //public class DynaInvoke
  //{
  //  // this way of invoking a function

  //  // is slower when making multiple calls

  //  // because the assembly is being instantiated each time.

  //  // But this code is clearer as to what is going on

  //  public static Object InvokeMethodSlow(string AssemblyName,
  //         string ClassName, string MethodName, Object[] args)
  //  {
  //    // load the assemly

  //    Assembly assembly = Assembly.LoadFrom(AssemblyName);

  //    // Walk through each type in the assembly looking for our class

  //    foreach (Type type in assembly.GetTypes())
  //    {
  //      if (type.IsClass == true)
  //      {
  //        if (type.FullName.EndsWith("." + ClassName))
  //        {
  //          // create an instance of the object

  //          object ClassObj = Activator.CreateInstance(type);

  //          // Dynamically Invoke the method

  //          object Result = type.InvokeMember(MethodName,
  //            BindingFlags.Default | BindingFlags.InvokeMethod,
  //                 null,
  //                 ClassObj,
  //                 args);
  //          return (Result);
  //        }
  //      }
  //    }
  //    throw (new System.Exception("could not invoke method"));
  //  }

  //  // ---------------------------------------------

  //  // now do it the efficient way

  //  // by holding references to the assembly

  //  // and class


  //  // this is an inner class which holds the class instance info

  //  public class DynaClassInfo
  //  {
  //    public Type type;
  //    public Object ClassObject;

  //    public DynaClassInfo()
  //    {
  //    }

  //    public DynaClassInfo(Type t, Object c)
  //    {
  //      type = t;
  //      ClassObject = c;
  //    }
  //  }


  //  public static Hashtable AssemblyReferences = new Hashtable();
  //  public static Hashtable ClassReferences = new Hashtable();

  //  public static DynaClassInfo
  //         GetClassReference(string AssemblyName, string ClassName)
  //  {
  //    if (ClassReferences.ContainsKey(AssemblyName) == false)
  //    {
  //      Assembly assembly;
  //      if (AssemblyReferences.ContainsKey(AssemblyName) == false)
  //      {
  //        AssemblyReferences.Add(AssemblyName,
  //              assembly = Assembly.LoadFrom(AssemblyName));
  //      }
  //      else
  //        assembly = (Assembly)AssemblyReferences[AssemblyName];

  //      // Walk through each type in the assembly

  //      foreach (Type type in assembly.GetTypes())
  //      {
  //        if (type.IsClass == true)
  //        {
  //          // doing it this way means that you don't have

  //          // to specify the full namespace and class (just the class)

  //          if (type.FullName.EndsWith("." + ClassName))
  //          {
  //            DynaClassInfo ci = new DynaClassInfo(type,
  //                               Activator.CreateInstance(type));
  //            ClassReferences.Add(AssemblyName, ci);
  //            return (ci);
  //          }
  //        }
  //      }
  //      throw (new System.Exception("could not instantiate class"));
  //    }
  //    return ((DynaClassInfo)ClassReferences[AssemblyName]);
  //  }

  //  public static Object InvokeMethod(DynaClassInfo ci,
  //                       string MethodName, Object[] args)
  //  {
  //    // Dynamically Invoke the method

  //    Object Result = ci.type.InvokeMember(MethodName,
  //      BindingFlags.Default | BindingFlags.InvokeMethod,
  //           null,
  //           ci.ClassObject,
  //           args);
  //    return (Result);
  //  }

  //  // --- this is the method that you invoke ------------

  //  public static Object InvokeMethod(string AssemblyName,
  //         string ClassName, string MethodName, Object[] args)
  //  {
  //    DynaClassInfo ci = GetClassReference(AssemblyName, ClassName);
  //    return (InvokeMethod(ci, MethodName, args));
  //  }
  //}
}
