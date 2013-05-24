using System.Collections.Generic;
using System.ServiceProcess;
using System.Text;
using MetraTech.MetraPay;
using System;

namespace MetraPay
{
  static class Program
  {
    /// <summary>
    /// The main entry point for the application.
    /// </summary>
    static void Main(string[] args)
    {
      bool bConsole = false;
      foreach (string arg in args)
      {
        if (arg == "-console")
        {
          bConsole = true;
        }
      }

      if (!bConsole)
      {
        ServiceBase[] ServicesToRun;

        // More than one user Service may run within the same process. To add
        // another service to this process, change the following line to
        // create a second service object. For example,
        //
        //   ServicesToRun = new ServiceBase[] {new Service1(), new MySecondUserService()};
        //
        ServicesToRun = new ServiceBase[] { new CMetraPayService() };

        ServiceBase.Run(ServicesToRun);
      }
      else
      {

        CMetraPayHost host = new CMetraPayHost();

        if (host.StartHost())
        {
          Console.WriteLine("MetraPay Host is running.  Press 'Q' to exit.");
          while (Console.ReadLine().ToUpper() != "Q") ;

          host.StopHost();
        }
        else
          Console.WriteLine("Host failed to start");
      }
    }
  }
}