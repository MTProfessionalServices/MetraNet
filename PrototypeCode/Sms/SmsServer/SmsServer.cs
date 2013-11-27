//this is a dummy implementation of the SMSServer, something the folks in PureMatrix would do.

using System;
using System.Collections;
using CookComputing.XmlRpc;

class SMSService : XmlRpcService
{
  [XmlRpcMethod("sendSms")]
  public SMSSendResponse sendSms(SMSSend inputStruct)
  {
    string key = inputStruct.msisdns[0];
    SMSSendResponse ret = new SMSSendResponse();
    ret.errorCode = 0;
    ret.message = "SUCCESS";
 
    ret.msisdns = new XmlRpcStruct();

    SMSDnsResponse dnis = new SMSDnsResponse();

    dnis.errorCode = 0;
    dnis.message = "success";
    dnis.id = "abcdefghijabcdefghijabcdefghijabcdefghij"; //a 40 char string
    dnis.final = true;
    dnis.status = 0;
    dnis.acceptTime = System.DateTime.Now;
    dnis.connectTime = System.DateTime.Now;
    dnis.contactTime = System.DateTime.Now;
    dnis.deliveryTime = System.DateTime.Now;
    dnis.errorSummary = "No Errors";
    dnis.expireTime = System.DateTime.Now;
    dnis.holduntilTime = System.DateTime.Now;
    dnis.queueTime = System.DateTime.Now;
    dnis.readTime = System.DateTime.Now;
    dnis.sendTime = System.DateTime.Now;
    dnis.updateTime = System.DateTime.Now;
    //ret.msisdns = (XmlRpcStruct) new Hashtable();
    ret.msisdns.Add(key, dnis);
    //ret.msisdns
    return ret;
  }

  [XmlRpcMethod("checkSmsStatus")]
  public SMSStatusResponse checkSmsStatus(SMSStatus inputStruct)
  {
    string key = inputStruct.msgIds[0]; //this is a 40 character string identifying the message
    SMSStatusResponse ret = new SMSStatusResponse();
    ret.errorCode = 0;
    ret.message = "SUCCESS";
 
    ret.msgs = new XmlRpcStruct();

    SMSDnsResponse dnis = new SMSDnsResponse();

    dnis.errorCode = 0;
    dnis.message = "SUCCESS";
    dnis.id = "abcdefghijabcdefghijabcdefghijabcdefghij"; //a 40 char string
    dnis.final = true;
    dnis.status = 0;
    dnis.acceptTime = System.DateTime.Now;
    dnis.connectTime = System.DateTime.Now;
    dnis.contactTime = System.DateTime.Now;
    dnis.deliveryTime = System.DateTime.Now;
    dnis.errorSummary = "No Errors";
    dnis.expireTime = System.DateTime.Now;
    dnis.holduntilTime = System.DateTime.Now;
    dnis.queueTime = System.DateTime.Now;
    dnis.readTime = System.DateTime.Now;
    dnis.sendTime = System.DateTime.Now;
    dnis.updateTime = System.DateTime.Now;
    ret.msgs.Add(key, dnis);
    //ret.msisdns
    return ret;
  }
  public struct SMSSend 
	 { 
	   public string username; 
	   public string password; 
	   public string message; 
	   public string [] msisdns; 
     public string fromNumber;
	 }
	
	 public struct SMSSendResponse 
	 { 
	   public int errorCode; 
	   public string message; 
	   /// This is a hashtable with key=dnis digits and value and SMSDnsResponse.
	   public XmlRpcStruct msisdns; 
	   //public XmlRpcStruct msisdns = new XmlRpcStruct(); 
    /* public XmlRpcStruct msisdns;
     public SMSSendResponse()
     {
       msisdns = new XmlRpcStruct();
     } */
	 } 
	 public struct SMSStatus 
	 { 
	   public string username; 
	   public string password; 
	   public string [] msgIds; 
	 } 
	    
	 public struct SMSStatusResponse 
	 { 
	   public int errorCode; 
	   public string message; 
	   /// This is a hashtable with key=mobilesys id and value and SMSDnsResponse. 
	   public XmlRpcStruct msgs; 
	 } 
	
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