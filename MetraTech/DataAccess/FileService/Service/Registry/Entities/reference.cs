namespace MetraTech.FileService
{
  using System;
  using System.Reflection;
  using System.Transactions;

  using Core.FileLandingService;
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  using MetraTech.ActivityServices.Common; // For access to MTList
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
  
  /// <summary>
  /// An assembly referenced by a snippet of runtime-compiled code.
  /// </summary>
  public class AssemblyDependency : BasicEntity
  {
    public AssemblyDependency(IStandardRepository db, AssemblyReferenceBE a)
      : base (db, a)
    {
    }

    /// <summary>
    /// The file name (i.e. ChangeListenerFoo.dll) of the assembly being referenced.
    /// </summary>
    public string Name
    {
      get
      {
        return (Instance as AssemblyReferenceBE)._Name;
      }
    }
    /// <summary>
    /// Validates an assembly generated from runtime-compiled code; makes sure that there is
    /// one and only one class that implements the IFileLandingEventHandler interface.
    /// </summary>
    /// <param name="assembly">
    /// Assembly object that we are to check.
    /// </param>
    protected static void ValidateAssembly(Assembly assembly)
    {
      FindEventHandlerType(assembly);
    }

    /// <summary>
    /// Creates an instance of the event handler class (class that implements the 
    /// IFileLandingEventHandler interface) that's defined in a snippet of runtime-compiled 
    /// code.
    /// </summary>
    /// <param name="assembly">
    /// Assembly containing a handler class.
    /// </param>
    /// <returns>
    /// An instance of the event handler class.
    /// </returns>
    protected static IFileLandingEventHandler CreateEventHandlerInstance(Assembly assembly)
    {
      Type eventHandlerType = FindEventHandlerType(assembly);
      return (IFileLandingEventHandler)Activator.CreateInstance(eventHandlerType);
    }

    /// <summary>
    /// Searches an assembly for a type that implements the IFileLandingEventHandler interface 
    /// and throws exceptions if more or less than one are found.
    /// </summary>
    /// <param name="assembly">
    /// Assembly object that we are to search.
    /// </param>
    /// <returns>
    /// The Type object for the class that implements IFileLandingEventHandler.
    /// </returns>
    protected static Type FindEventHandlerType(Assembly assembly)
    {
      Type eventHandlerType = null;

      foreach (Type t in assembly.GetTypes())
      {
        if (null != t.GetInterface("IFileLandingEventHandler"))
        {
          // If we've already found a qualifying type, then throw an exception
          if (null != eventHandlerType)
            throw new ArgumentException(String.Format("Multiple classes implementing IFileLandingEventHandler were found in {0}.", assembly.FullName));

          eventHandlerType = t;
        }
      }

      // If no qualifying types were found, then throw an exception
      if (null == eventHandlerType)
        throw new ArgumentException(String.Format("No classes implementing IFileLandingEventHandler were found in {0}.", assembly.FullName));

      return eventHandlerType;
    }
  }
}
