using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.UI.Controls.MTLayout
{
  [Serializable]
  public class NestedGridParameterLayout
  {
    /// <summary>
    /// Name of the parameter to be passed to the nested grid's DataSourceURL.
    /// If the parameter is used as a filter, it ParameterName must match one of the grid's filters
    /// </summary>
    public string ParameterName;

    /// <summary>
    /// Static value for the parameter specified by Parameter Name. If ElementID is not provided, 
    /// then ParameterValue will be used.
    /// </summary>
    public string ParameterValue;

    /// <summary>
    /// Field of the outer grid whose value is to be sent to the inner grid.  If ElementID is null or empty,
    /// ParameterValue will be used
    /// </summary>
    public string ElementID;

    /// <summary>
    /// Set this property to true to pass the parameter and value as MTFilter to 
    /// the nested grid's Data Source URL.
    /// If this property is set to false, the nested grid's Data Source URL will 
    /// recieve this parameter as a form post
    /// </summary>
    public bool UseParamAsFilter;
  }
}
