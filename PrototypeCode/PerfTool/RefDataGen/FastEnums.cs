using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;

namespace AppRefData
{
    public static class FastEnums
    {
        public static class eInvoiceMethod
        {
            public static Int32 Standard;

            static eInvoiceMethod()
            {
                Standard = (int)EnumHelper.GetDbValueByEnum(InvoiceMethod.Standard);
            }
        }

        public static class eUsageCycleType
        {
            public static Int32 Monthly;

            static eUsageCycleType()
            {
                Monthly = (int)EnumHelper.GetDbValueByEnum(UsageCycleType.Monthly);
            }
        }


        public static class eTimeZoneId
        {
            public static Int32 EST;

            static eTimeZoneId()
            {
                EST = (int)EnumHelper.GetDbValueByEnum(TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_);
            }

        }

        public static class eContactType
        {
            public static Int32 None;
            public static Int32 Bill_To;
            public static Int32 Ship_To;

            static eContactType()
            {
                None = (int)EnumHelper.GetDbValueByEnum(ContactType.None);
                Bill_To = (int)EnumHelper.GetDbValueByEnum(ContactType.Bill_To);
                Ship_To = (int)EnumHelper.GetDbValueByEnum(ContactType.Ship_To);
            }

        }

        static FastEnums()
        {
        }

    }
}
