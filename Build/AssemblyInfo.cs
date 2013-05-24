using System.Reflection;
using System.Runtime.CompilerServices;


// The ApplicationName is the name of the COM+ application that
// any ServicedComponents will be registered under.
// We only use the one MetraNet application.
// Assemblies that do not have serviced components should not be affected.
[assembly: System.EnterpriseServices.ApplicationName("MetraNet")]

