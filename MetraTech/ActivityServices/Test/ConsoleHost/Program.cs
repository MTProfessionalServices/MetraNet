using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.ActivityServices.Runtime;
using System.Reflection;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Description;
using System.Configuration;

namespace ConfigTest
{
  class Program
  {
    static void Main(string[] args)
    {
      CMASHost dbmfHost = new CMASHost();

      Configuration config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

      if (dbmfHost.StartMASHost())
      {
        Console.WriteLine("ActivityServices Host is running.  Press 'Q' to exit.");
        while (Console.ReadLine().ToUpper() != "Q") ;

        dbmfHost.StopMASHost();
      }

    }

    
  }
}
