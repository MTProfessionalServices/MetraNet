// Setting ComVisible to false makes the types in this assembly not visible 
// to COM components.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: System.Runtime.InteropServices.ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: System.Runtime.InteropServices.Guid("55f9051e-6211-4380-a746-426a68ba4ad9")]
//[assembly: System.Runtime.CompilerServices.InternalsVisibleTo("UnitTests")]

namespace MetraTech.FileService
{
  using System.ServiceProcess;

  static class cLandingServiceMainProgram
  {
    /// <summary>
    /// The main entry point for the application.
    /// </summary>
    static void Main()
    {
      ServiceBase[] ServicesToRun;

      ServicesToRun = new ServiceBase[] { new FileService() };

      ServiceBase.Run(ServicesToRun);
    }
  } 
}