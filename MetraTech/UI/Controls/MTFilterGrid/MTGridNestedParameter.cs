using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.UI.Controls
{
  /// <summary>
  /// This class represents parameters that the main grid passes to the nested grid
  /// </summary>
  public class MTGridNestedParameter
  {
    private string paramName;

    /// <summary>
    /// Name of the parameter
    /// </summary>
    public string ParamName
    {
      get { return paramName; }
      set { paramName = value; }
    }

    private string elementID;
    /// <summary>
    /// ID of the element in the main grid, whose value will be sent as a parameter to the inner grid
    /// </summary>
    public string ElementID
    {
      get { return elementID; }
      set { elementID = value; }
    }

    private string paramValue;

    /// <summary>
    /// Field of the outer grid whose value is to be sent to the inner grid.  If ElementID is null or empty,
    /// ParameterValue will be used
    /// </summary>
    public string ParamValue
    {
      get { return paramValue; }
      set { paramValue = value; }
    }

    private bool useParamAsFilter;
    /// <summary>
    /// Set this property to true to pass the parameter and value as MTFilter to 
    /// the nested grid's Data Source URL.
    /// If this property is set to false, the nested grid's Data Source URL will 
    /// recieve this parameter as a form post
    /// </summary>
    public bool UseParamAsFilter
    {
      get { return useParamAsFilter; }
      set { useParamAsFilter = value; }
    }

    
  }
}
