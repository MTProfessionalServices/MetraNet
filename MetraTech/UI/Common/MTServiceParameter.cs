using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.UI.Common
{
  public class MTServiceParameter
  {
    private string dataType;

    public string DataType
    {
      get { return dataType; }
      set { dataType = value; }
    }

    private string paramName;

    public string ParamName
    {
      get { return paramName; }
      set { paramName = value; }
    }

    private string paramValue;

    public string ParamValue
    {
      get { return paramValue; }
      set { paramValue = value; }
    }
  }
}
