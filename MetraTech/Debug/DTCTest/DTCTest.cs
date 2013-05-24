using System;

namespace MetraTech.Debug.DTCTest
{

	/// <summary>
	/// Utility to verify DTC is configured correctly
	/// </summary>
  class DTCTestExecutable
  {
    [STAThread]
    static int Main(string[] args)
    {
      if (args.Length != 3)
      {
        Console.WriteLine("DTCTest usage:");
        Console.WriteLine("  dtctest.exe dbserver dbusername dbpassword");
        Console.WriteLine("Example:");
        Console.WriteLine("  dtctest.exe FLUX sa MetraTech1");
        return 1;
      }

      try
      {
        DTCTestLib dtc = new DTCTestLib();
				dtc.Server = args[0];
				dtc.UserName = args[1];
				dtc.Password = args[2];

				dtc.Test();

				Console.WriteLine();
				Console.WriteLine("DTC test succeeded!");
 
        return 0;
      }
      catch (Exception e)
      {
        Console.WriteLine("Exception caught:\n{0}", e);
				Console.WriteLine();
				Console.WriteLine("DTC test failed!");

        return 1;
      }
    }
  }
}
