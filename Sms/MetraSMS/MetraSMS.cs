using System;
using System.Net;
using System.Web;
using CookComputing.XmlRpc;
using MetraTech.SMSWrapper;
using System.Collections;
using System.Threading;
using System.Runtime.InteropServices;
using MetraTech.Interop.COMMeter;
[assembly: GuidAttribute("a43b3ef6-f1da-4fd5-bcd2-54f09742250b")]
namespace MetraTech
{

/// <summary>
/// This is the object that does the work behind the Metratech SendSMS screen.
/// </summary>
/// 
	[Guid("ccd03b0f-5b19-4944-9d11-67e1d9550bd1")]
	public interface IMetraSMS
	{
		int SendMessage(string userName, int messageType);
		string Message
		{
			get ;
			set ;
		}
		string Id
		{
			get ;
		}
		string From
		{
			get ;
			set ;
		}
	
		string To
		{
			get ;
			set ;
		}
	
		int Status
		{
			get ;
		}
	
	
		Priority PriorityType
		{
			get ;
			set ;
		}

	}
	[Guid("08aea0a8-090d-45cd-8f38-769c3427f2e6")]
	public enum Priority : uint
	{
		Normal = 0,
		Urgent = 1,
	};
	
[Guid("1f7f7ea3-8474-4aa6-9ec5-5eca9a6aff9b")]
[ClassInterface(ClassInterfaceType.None)]
public class MetraSMS : IMetraSMS
{
	private string mMessage;
	private string mFrom;
	private string mTo;
	private string mId;
	private int mStatus;
	private Logger mLogger = new Logger ("[MetraSMS]");

	private Priority mPriority;
	
	public string Message
	{
		get { return mMessage; }
		set { mMessage = value; }
	}
  public string Id
  {
    get { return mId; }
  }
	public string From
	{
		get { return mFrom; }
		set { mFrom = value.Trim(); }
	}
	
  public string To
  {
    get { return mTo; }
    set { mTo = value.Trim(); }
  }
	
  public int Status
  {
    get { return mStatus; }
  }
	public MetraSMS()
	{
		mMessage = string.Empty;
		mFrom = string.Empty;
    mTo = string.Empty;
		mPriority = Priority.Normal;
    mStatus = -1;
    mLogger.LogDebug("Initializing MetraSMS");
	}
	
	public Priority PriorityType
	{
		get { return mPriority; }
		set { mPriority = value; }
	}
	
  public int SendMessage(string userName, int messageType)
  {
    mTo = mTo.Replace(" ", "");
    mTo = mTo.Replace("-", "");
    mFrom = mFrom.Replace(" ", "");
    mFrom = mFrom.Replace("-", "");

    mLogger.LogDebug("To: {0}", mTo);
    mLogger.LogDebug("From: {0}", mFrom);
    mLogger.LogDebug("Message: {0}", mMessage);

    if ((String.Compare(mMessage, "", true) == 0) ||
        (String.Compare(mTo, "", true) == 0))
    {
      mLogger.LogError("To or Message are empty!"); 
      mStatus = -1;
      return mStatus;
    }
    MetraTech.SMSWrapper.SMSWrapper.SMSSend inputStruct = new MetraTech.SMSWrapper.SMSWrapper.SMSSend();
    inputStruct.username = "metratech"; //hard coding username and password, read from xml file, encrypt??
    inputStruct.password = "blue2logan";
    inputStruct.message = mMessage;
    inputStruct.msisdns = new string[1];
    inputStruct.msisdns[0] = mTo;
    inputStruct.fromNumber = mFrom;
    MetraTech.SMSWrapper.SMSWrapper.sendSmsProxy proxy = new MetraTech.SMSWrapper.SMSWrapper.sendSmsProxy();
    proxy.Timeout = 60000; //60 sec or 1 mins
    MetraTech.SMSWrapper.SMSWrapper.SMSSendResponse ret = proxy.sendSms(inputStruct);

    CookComputing.XmlRpc.XmlRpcStruct outputStruct;
       
    outputStruct =(CookComputing.XmlRpc.XmlRpcStruct)ret.msisdns[mTo];
    mId = outputStruct["id"].ToString();
    if (outputStruct["message"].ToString() != "Success")
    {
       mStatus = -1;
       mLogger.LogError("Could not send SMS, status: {0}", outputStruct["message"].ToString());
       return mStatus;
    }

    //need to create a usage record for this and meter it in.
    mLogger.LogDebug("Initializing SDK");
    IMeter sdk = new Meter();
    try
    {
      sdk.Startup();
      sdk.AddServer(0, "localhost", PortNumber.DEFAULT_HTTP_PORT, 0, "", "");
      
      mLogger.LogDebug("Creating session");
      ISession session = sdk.CreateSession("metratech.com/SMSService");

      session.InitProperty("accountname", userName);
      session.InitProperty("message", mMessage);
      
      string description;
      //randomly generate a conference id
      if (messageType == 2)
      {
        System.Random rnd = new System.Random();
        int number = rnd.Next(100000, 999999);
        string sNumber = number.ToString();
        description = string.Concat("Conf# ", sNumber);
      }
      else
        description = "Text Message";
      mLogger.LogDebug(description);
      session.InitProperty("description", description);
      session.InitProperty("MobileNumber", mTo);
      if (messageType == 3)
        session.InitProperty("SMSType", "HotSpotConnect");
      else if (messageType == 2)
        session.InitProperty("SMSType", "ConfAlert");
      else
        session.InitProperty("SMSType", "Basic");

      session.InitProperty("IPAddress", "192.168.1.152"); //need to get the client ip address
      session.InitProperty("SMSId", mId);
      session.Close();
      mLogger.LogDebug("Metered session");
      sdk.Shutdown();


      //System.Threading.Thread.Sleep(60000); //sleep for 1 min 
    
      /* MetraTech.SMSWrapper.SMSWrapper.SMSStatus checkStruct = new MetraTech.SMSWrapper.SMSWrapper.SMSStatus();
      checkStruct.username = "metratech";
      checkStruct.password = "blue2logan";
      checkStruct.msgIds = new string[1];
      checkStruct.msgIds[0] = mId;
      MetraTech.SMSWrapper.SMSWrapper.checkSmsStatusProxy checkProxy = new MetraTech.SMSWrapper.SMSWrapper.checkSmsStatusProxy();
      MetraTech.SMSWrapper.SMSWrapper.SMSStatusResponse checkRet = checkProxy.checkSmsStatus(checkStruct);

      CookComputing.XmlRpc.XmlRpcStruct checkOutputStruct;
      checkOutputStruct = (CookComputing.XmlRpc.XmlRpcStruct)checkRet.msgs[mId];
      mStatus = Convert.ToInt32(checkOutputStruct["errorCode"]);
      //Console.WriteLine("checkSmsStatus Done!");
      return mStatus; */
    }
    finally
    {
      Marshal.ReleaseComObject(sdk);
    }
    return 0;
  }

}
}