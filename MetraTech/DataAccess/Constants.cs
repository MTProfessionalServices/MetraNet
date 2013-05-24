using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.DataAccess
{
  public static class Constants
  {
    // Number precision (total number of significant digits)
    // and scale (number of digits to right of decimal point)
    public const int METRANET_PRECISION_MAX        = 22;
    public const string METRANET_PRECISION_MAX_STR = "22";

    public const int METRANET_SCALE_MAX            = 10;
    public const string METRANET_SCALE_MAX_STR     = "10";

    public const string METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_STR =  "DECIMAL(22,10)";
    public const string METRANET_NUMERIC_PRECISION_AND_SCALE_MAX_STR =  "NUMERIC(22,10)";
    public const string METRANET_NUMBER_PRECISION_AND_SCALE_MAX_STR  =  "NUMBER(22,10)";

  }
}
