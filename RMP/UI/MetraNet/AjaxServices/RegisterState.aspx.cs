using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.IO;
using System.Reflection;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;

public partial class RegisterState : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    string state = Request["State"];
    string processorId = Request["ProcessorID"];
    string interfaceName = Request["InterfaceName"];
    AccountIdentifier accountId = new AccountIdentifier(UI.User.AccountId);

    // Set server side state
    try
    {
      // TODO: actually move backend workflow  
      Logger.LogDebug(String.Format("Setting Server Side State: {0}, ProcessorID: {1}, InterfaceName: {2}, AccountID: {3}", state.ToString(), processorId.ToString(), interfaceName.ToString(), accountId.ToString()));

      string typeName = string.Format("{0}_SetState_Client", interfaceName);


      CMASEventClientProxyBase client = FindClientProxy(typeName);

      if (client != null)
      {
        Type clientType = client.GetType();

        PropertyInfo propInfo = clientType.GetProperty("In_AccountId");

        if (propInfo != null)
        {
          propInfo.SetValue(client, accountId, null);
        }

        propInfo = clientType.GetProperty("In_PageState");

        if (propInfo != null)
        {
          propInfo.SetValue(client, new Guid(state), null);
        }

        propInfo = clientType.GetProperty("InOut_ProcessorInstanceId");

        if (propInfo != null)
        {
          propInfo.SetValue(client, new Guid(processorId), null);
        }

        client.UserName = this.UI.User.UserName;
        client.Password = this.UI.User.SessionPassword;

        client.Invoke();
      }

      Response.Write("OK");
    }
    catch (Exception exp)
    {
      Logger.LogException("Failed to register state: " + state, exp);
      Response.Write("FAILED");
    }
    Response.End();
  }

  protected CMASEventClientProxyBase FindClientProxy(string typeName)
  {
    CMASEventClientProxyBase retval = null;

    string [] files = Directory.GetFiles(HttpRuntime.BinDirectory, "*.ClientProxies.dll");
    Assembly assem;

    for(int i = 0; i < files.Length && retval == null; i++)
    {
      try
      {
        assem = Assembly.LoadFile(files[i]);

        Type[] types = assem.GetTypes();

        foreach (Type type in types)
        {
          if (type.Name == typeName)
          {
            retval = Activator.CreateInstance(type) as CMASEventClientProxyBase;
            break;
          }
        }
      }
      catch(Exception)
      {
      }
    }

    return retval;
  }
}
