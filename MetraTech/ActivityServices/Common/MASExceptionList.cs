using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;

namespace MetraTech.ActivityServices.Common
{
    [Flags]
  public enum ErrorGroups
  {
      COMMON = 1 << 32,
      ACCOUNTS = 1 << 33,
      ACTIVITY_SERVICES = 1 << 34,
      CORE_ACTIVITIES = 1 << 35,
      CORE_SERVICES = 1 << 36,
      AR = 1 << 37,
      AUTH = 1 << 38,
      BME = 1 << 39,
      METRAPAY = 1 << 40,
      SECURITY = 1 << 41,
      USAGE_SERVER = 1 << 42,
      METERING = 1 << 43,
      PIPELINE = 1 << 44
  }

    public enum ErrorCodes
    {
      #region activity services
      EXCEEDED_MAX_TRANSACTIONS = ErrorGroups.ACTIVITY_SERVICES + 1,
      TRANSACTION_ALREADY_FAILED = ErrorGroups.ACTIVITY_SERVICES + 2,
      TRANSACTION_ALREADY_REJECTED = ErrorGroups.ACTIVITY_SERVICES + 3,
      TRANSACTION_TIMED_OUT = ErrorGroups.ACTIVITY_SERVICES + 4,
      TRANSACTION_NOT_FAILED = ErrorGroups.ACTIVITY_SERVICES + 5,
      VOID_FAILED = ErrorGroups.ACTIVITY_SERVICES + 6,
      TRANSACTION_ALREADY_SETTLED = ErrorGroups.ACTIVITY_SERVICES + 7,
      BAD_TRANSACTION_STATE = ErrorGroups.ACTIVITY_SERVICES + 8,
      TRANSACTION_NOT_FOUND = ErrorGroups.ACTIVITY_SERVICES + 9,
      NO_OVERRIDE_CAPABILITY = ErrorGroups.ACTIVITY_SERVICES + 10,
      COULD_NOT_LOG_TRANSACTION = ErrorGroups.ACTIVITY_SERVICES + 11,
      APPROVAL_COULD_NOT_APPLY_CHANGE = ErrorGroups.ACTIVITY_SERVICES + 12,
      MTPCUSER_SUBS_EXIST_BEFORE_PO_EFF_START_DATE = ErrorGroups.ACTIVITY_SERVICES + 13,
      MTPCUSER_SUBS_EXIST_AFTER_PO_EFF_END_DATE = ErrorGroups.ACTIVITY_SERVICES + 14,
      ACCOUNT_NOT_FOUND = ErrorGroups.ACTIVITY_SERVICES + 15
      #endregion
    }

}
