using System;
using System.Net;
using System.Web;
using CookComputing.XmlRpc;
using MetraTech.SMSWrapper;
using System.Collections;
using System.Threading;

//travis 17813677088
//anagha 17817385845
//scott 16173357657
namespace MetraTech.SMSWrapper.Test
{

  public class smsTest
  {
 
    static void Main()
    {
      string numberToCall;
      string callId;

      numberToCall = "17817385845";

      MetraTech.SMSWrapper.SMSWrapper.SMSSend inputStruct = new MetraTech.SMSWrapper.SMSWrapper.SMSSend();
      inputStruct.username = "metratech";
      inputStruct.password = "blue2logan";
      inputStruct.message = "Hi Scott, Can you hear me now, testing the from 17817385845 ?";
      inputStruct.msisdns = new string[1];
      inputStruct.msisdns[0] = numberToCall;
      inputStruct.fromNumber = "17818388438 12345"; //sending extra numbers
      MetraTech.SMSWrapper.SMSWrapper.sendSmsProxy proxy = new MetraTech.SMSWrapper.SMSWrapper.sendSmsProxy();
      proxy.Timeout = 60000; //60 sec or 1 mins
      MetraTech.SMSWrapper.SMSWrapper.SMSSendResponse ret = proxy.sendSms(inputStruct);
      CookComputing.XmlRpc.XmlRpcStruct o;
      
      o =(CookComputing.XmlRpc.XmlRpcStruct)ret.msisdns[numberToCall];
      Console.WriteLine(o["id"]);
      callId = o["id"].ToString();
      Console.WriteLine("sendSms done!");

      Console.WriteLine(callId);
      System.Threading.Thread.Sleep(60000); //sleep for 1 min      

      MetraTech.SMSWrapper.SMSWrapper.SMSStatus checkStruct = new MetraTech.SMSWrapper.SMSWrapper.SMSStatus();
      checkStruct.username = "metratech";
      checkStruct.password = "blue2logan";
      checkStruct.msgIds = new string[1];
      checkStruct.msgIds[0] = callId;
      MetraTech.SMSWrapper.SMSWrapper.checkSmsStatusProxy checkProxy = new MetraTech.SMSWrapper.SMSWrapper.checkSmsStatusProxy();
      MetraTech.SMSWrapper.SMSWrapper.SMSStatusResponse checkRet = checkProxy.checkSmsStatus(checkStruct);
      Console.WriteLine("checkSmsStatus Done!");
    }
  }
}