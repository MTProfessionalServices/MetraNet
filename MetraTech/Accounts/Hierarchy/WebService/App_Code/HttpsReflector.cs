using System;
using System.Web.Services.Description;

namespace MetraTech.Accounts.Hierarchy.WebService
{
  public class HttpsReflector : SoapExtensionReflector
  {
    public override void ReflectMethod()
    {
      //no-op
    }

    public override void ReflectDescription()
    {
      ServiceDescription description = ReflectionContext.ServiceDescription;
      foreach (Service service in description.Services)
      {
        foreach (Port port in service.Ports)
        {
          foreach (ServiceDescriptionFormatExtension extension in port.Extensions)
          {
            SoapAddressBinding binding = extension as SoapAddressBinding;
            if (null != binding)
            {
              binding.Location = binding.Location.Replace("http://", "https://");
            }
          }
        }
      }
    }
  }
}