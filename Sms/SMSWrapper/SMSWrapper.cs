using System;
using System.Net;
using CookComputing.XmlRpc;
using System.Runtime.InteropServices;

namespace MetraTech.SMSWrapper
{
	/// <summary>
	/// Summary description for SMSWrapper.
	/// </summary>
	/// 
	[ComVisible(false)]
	public class SMSWrapper

	{
	[ComVisible(false)]
	//[XmlRpcUrl ("http://localhost/sms/MetraTech.SMSServer.rem")]
    [XmlRpcUrl ("http://boulderjaz.purematrix.com/escape/servlet/smsXmlRpc")]
		public class sendSmsProxy : XmlRpcClientProtocol
		{
			[XmlRpcMethod]
			public SMSSendResponse sendSms(SMSSend structSend)
			{
				return (SMSSendResponse)Invoke("sendSms", new Object[]{structSend});
			}
		}
		//	[XmlRpcUrl ("http://localhost/sms/MetraTech.SMSServer.rem")]	
		[ComVisible(false)]
    [XmlRpcUrl ("http://boulderjaz.purematrix.com/escape/servlet/smsXmlRpc")]
		public class checkSmsStatusProxy : XmlRpcClientProtocol
		{
			[XmlRpcMethod]
			public SMSStatusResponse checkSmsStatus(SMSStatus structCheckStatus)
			{
				return (SMSStatusResponse)Invoke("checkSmsStatus", new Object[]{structCheckStatus});
			}
		}
		[ComVisible(false)]
 		public struct SMSSend 
 		 { 
 		   public string username; 
 		   public string password; 
 		   public string message; 
 		   public string [] msisdns; 
       public string fromNumber;
 		 } 
	 [ComVisible(false)]
 		 public struct SMSSendResponse 
 		 { 
 		   public int errorCode; 
 		   public string message; 
 		   /// This is a hashtable with key=dnis digits and value and SMSDnsResponse. 
 		   public XmlRpcStruct msisdns; 
 		 } 
	[ComVisible(false)]
 		 public struct SMSStatus 
 		 { 
 		   public string username; 
 		   public string password; 
 		   public string [] msgIds; 
 		 } 
    [ComVisible(false)]
 		 public struct SMSStatusResponse 
 		 { 
 		   public int errorCode; 
 		   public string message; 
 		   /// This is a hashtable with key=mobilesys id and value and SMSDnsResponse. 
 		   public XmlRpcStruct msgs; 
 		 } 
	[ComVisible(false)]
 		 public struct SMSDnsResponse 
 		 { 
 		   public int errorCode; 
 		   public string message; 
 		   public string id; 
 		   public bool final; 
 		   public int status; 
 		   public DateTime acceptTime; 
 		   public DateTime connectTime; 
 		   public DateTime contactTime; 
 		   public DateTime deliveryTime; 
 		   public string errorSummary; 
 		   public DateTime expireTime; 
 		   public DateTime holduntilTime; 
 		   public DateTime queueTime; 
 		   public DateTime readTime; 
 		   public DateTime sendTime; 
 		   public DateTime updateTime; 
 		 } 
 
		
	}
}
