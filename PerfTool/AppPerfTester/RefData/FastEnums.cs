using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using log4net;

namespace AppRefData
{
  public class FastEnums
  {
    private static readonly ILog log = LogManager.GetLogger(typeof(FastEnums));

    private static FastEnums _Instance;
    public static FastEnums Instance
    {
      get
      {
        if (_Instance != null)
          return _Instance;
        _Instance = new FastEnums();
        return _Instance;
      }
    }

    public eInvoiceMethod InvoiceMethod;
    public eUsageCycleType UsageCycleType;
    public eTimeZoneId TimeZoneId;
    public eContactType ContactType;
    public eStatusReason StatusReason;

    public void init(BaselineGUI.FCEnumRepo repo)
    {
      try
      {
        InvoiceMethod = new eInvoiceMethod(repo);
        UsageCycleType = new eUsageCycleType(repo);
        TimeZoneId = new eTimeZoneId(repo);
        ContactType = new eContactType(repo);
        StatusReason = new eStatusReason(repo);
      }
      catch (Exception ex)
      {
        log.FatalFormat("Failed: {0}", ex.ToString());
      }

    }

    public class eInvoiceMethod
    {
      public Int32 Standard;

      public eInvoiceMethod(BaselineGUI.FCEnumRepo repo)
      {
        Standard = repo.getValue("metratech.com/accountcreation", "InvoiceMethod", "Standard");
      }
    }

    public class eUsageCycleType
    {
      public Int32 Monthly;

      public eUsageCycleType(BaselineGUI.FCEnumRepo repo)
      {
        Monthly = repo.getValue("metratech.com/billingcycle", "UsageCycleType", "Monthly");
      }
    }


    public class eTimeZoneId
    {
      public static Int32 EST;

      public eTimeZoneId(BaselineGUI.FCEnumRepo repo)
      {
        EST = repo.getValue("Global", "TimeZoneID", "(GMT-05:00) Eastern Time (US & Canada)");
      }

    }

    public class eContactType
    {
      public static Int32 None;
      public static Int32 Bill_To;
      public static Int32 Ship_To;

      public eContactType(BaselineGUI.FCEnumRepo repo)
      {
        None = repo.getValue("metratech.com/accountcreation", "ContactType", "None");
        Bill_To = repo.getValue("metratech.com/accountcreation", "ContactType", "Bill-To");
        Ship_To = repo.getValue("metratech.com/accountcreation", "ContactType", "Ship-To");
      }

    }

    public class eStatusReason
    {
      public Int32 None;

      public eStatusReason(BaselineGUI.FCEnumRepo repo)
      {
        None = repo.getValue("metratech.com/accountcreation", "StatusReason", "None");
      }
    }




  }
}
