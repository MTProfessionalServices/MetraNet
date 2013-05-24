using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel;
using System.Web.UI;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls
{

  public class MTGridDataBinding
  {

    private List<MTServiceParameter> serviceMethodParameters;

    /// <summary>
    /// Collection of parameters to be sent to the service specified in ServiceMethodName property
    /// </summary>
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
    [PersistenceMode(PersistenceMode.InnerProperty)]
    [NotifyParentProperty(true)]
    public List<MTServiceParameter> ServiceMethodParameters
    {
      get
      {
        if (serviceMethodParameters == null)
        {
          serviceMethodParameters = new List<MTServiceParameter>();
        }
        return serviceMethodParameters;
      }
      set { serviceMethodParameters = value; }
    }


    private string serviceMethodName;

    /// <summary>
    /// Specifies the name of the WCF service to be executed.
    /// If parameters need to be passed to the service, use the ServiceMethodParameters collection
    /// </summary>
    public string ServiceMethodName
    {
      get { return serviceMethodName; }
      set { serviceMethodName = value; }
    }


    private MTGridDataBindingArgumentCollection arguments;

    [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
    [PersistenceMode(PersistenceMode.InnerProperty)]
    [NotifyParentProperty(true)]
    public MTGridDataBindingArgumentCollection Arguments
    {
      get
      {
        if (arguments == null)
        {
          arguments = new MTGridDataBindingArgumentCollection();
        }
        return arguments;

      }
      set { arguments = value; }
    }

    private string outPropertyName;

    public string OutPropertyName
    {
      get { return outPropertyName; }
      set { outPropertyName = value; }
    }
    private string servicePath;

    public string ServicePath
    {
      get { return servicePath; }
      set { servicePath = value; }
    }

    private string operation;

    /// <summary>
    /// Name of the class in client proxy to use
    /// </summary>
    public string Operation
    {
      get { return operation; }
      set { operation = value; }
    }

    private string binding;

    public string Binding
    {
      get { return binding; }
      set { binding = value; }
    }


    private string processorID;

    public string ProcessorID
    {
      get { return processorID; }
      set { processorID = value; }
    }


    private string accountID;

    public string AccountID
    {
      get { return accountID; }
      set { accountID = value; }
    }




  }
}
