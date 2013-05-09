using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Core.Services.ClientProxies;

using System.ServiceModel;
using System.ServiceModel.Channels;
using log4net;

namespace BaselineGUI
{
  public class FCSecurity : FrameworkComponentBase, IFrameworkComponent
  {
    private static readonly ILog log = LogManager.GetLogger(typeof(FCSecurity));

    public FakeSecurity.FakeSecurity security;


    public FCSecurity()
    {
      name = "Security";
      fullName = "Security";
      priority = 3;
    }

    public void Bringup()
    {
      bool success = false;

      try
      {
        security = new FakeSecurity.FakeSecurity(PrefRepo.active.Security.encryptionKey);
        success = true;
      }
      catch (Exception ex)
      {
        log.ErrorFormat("Failed: {0}", ex.ToString());
      }

      if (success)
      {
        bringupState.message = "Security Instantiated";
      }
      else
      {
        bringupState.message = "Security failed";
      }
    }


    public void Teardown()
    {
    }
  }
}
