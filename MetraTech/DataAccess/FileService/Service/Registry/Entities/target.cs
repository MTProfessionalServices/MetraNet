namespace MetraTech.FileService
{
  using System;
  using System.IO;
  using System.Diagnostics;
  using System.Collections.Generic;
  using System.Text;
  using System.Transactions;
  using System.Configuration;
  using System.Configuration.Internal;
  using System.Xml;
  using System.Xml.Serialization;
  using System.Reflection;
  using System.CodeDom;
  using System.CodeDom.Compiler;
  using Microsoft.CSharp;
  using Microsoft.VisualBasic;

  using Core.FileLandingService;
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  using MetraTech.ActivityServices.Common; // For access to MTList
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;


  /// <summary>
  /// Represents a program target to execute for specific file system events
  /// </summary>
  public class Target : BasicEntity
  {
    #region Data Members

    #region Public Data
    public static TLog m_log = new TLog("MetraTech.FileService.Target");

    /// <summary>
    /// Full Name for the executable
    /// </summary>
    public enum TState
    {
      NEW,
      CHANGED,
      CURRENT,
      GARBAGE
    }

    public TState State { get; set; }
    /// <summary>
    /// Full Name of executable
    /// </summary>
    
    public string ExecutableName { get; set; }

    /// <summary>
    /// Return true if this a properly constructed Target
    /// </summary>
    public bool IsHealthy
    {
      get
      {
        return m_isHealthy;
      }
    }
    #endregion

    #region Private Data

    /// <summary>
    /// These are the filter, and or filters that each cEventFilter may apply.
    /// </summary>
    NameFilter m_filter = null;

    /// <summary>
    /// This is the list of arguments which instruct us how to execute the target executable
    /// These are not valid for generated programs which implement the IFileLandingEventHandler
    /// interface.
    /// </summary>
    private List<Argument> m_arguments = new List<Argument>();

    /// <summary>
    /// Interface to the runtime-compiled class that we are to invoke to handle the event.
    /// </summary>
    public IFileLandingEventHandler m_eventHandler = null;

    /// <summary>
    /// True if a properly constructed target.
    /// </summary>
    private bool m_isHealthy = false;

    #endregion Private Data

    #endregion

    #region Constructor
    /// <summary>
    /// Creates a new instance of a target, and performs any validation and creation of internal data. 
    /// </summary>
    /// <param name="db">Database access reference</param>
    /// <param name="t">Execution DataObject reference</param>
    public Target(IStandardRepository db, TargetBE t)
      : base(db, t)
    {
      m_isHealthy = false;
      ExecutableName = t._Executable;
      if (null == db.LoadInstance(typeof(TargetBE).FullName, t.Id))
      {
        m_log.Error(String.Format("Target {0} does not exist in the database", ExecutableName));
        return;
      }

      try
      {
        m_filter = new NameFilter(t._Regex);
      }
      catch (System.ArgumentOutOfRangeException ex)
      {
        m_log.Error(ex.Message + " Target options contains an invalid flag (" + t._Name + ":" + t._Regex + ")");
        return;
      }
      catch (System.ArgumentNullException ex)
      {
        m_log.Error(ex.Message + " Target pattern is null (" + t._Name + ":" + t._Regex + ")");
        return;
      }
      catch (System.ArgumentException ex)
      {
        m_log.Error(ex.Message + " Target pattern parsing error, pattern invalid (" + t._Name + ":" + t._Regex + ")");
        return;
      }

      try
      {
        EnumerateArguments();
      }
      catch
      {
        m_log.Error("Problem enumerating Arguments for Target(" + t._Name + ")");
        return;
      }

      m_isHealthy = true;
    }

    // Copy constructor.
    public Target(Target previousTarget)
      : base(previousTarget)
    {
      ExecutableName = previousTarget.ExecutableName;

      m_isHealthy = false;

      try
      {
        m_filter = new NameFilter((previousTarget.Instance as TargetBE)._Regex);
      }
      catch (System.ArgumentOutOfRangeException ex)
      {
        m_log.Error(ex.Message + " Target options contains an invalid flag (" + (previousTarget.Instance as TargetBE)._Name + ":" + (previousTarget.Instance as TargetBE)._Regex + ")");
        return;
      }
      catch (System.ArgumentNullException ex)
      {
        m_log.Error(ex.Message + " Target pattern is null (" + (previousTarget.Instance as TargetBE)._Name + ":" + (previousTarget.Instance as TargetBE)._Regex + ")");
        return;
      }
      catch (System.ArgumentException ex)
      {
        m_log.Error(ex.Message + " Target pattern parsing error, pattern invalid (" + (previousTarget.Instance as TargetBE)._Name + ":" + (previousTarget.Instance as TargetBE)._Regex + ")");
        return;
      }

      try
      {
        EnumerateArguments();
      }
      catch
      {
        m_log.Error("Problem enumerating Arguments for Target(" + (previousTarget.Instance as TargetBE)._Name + ")");
        return;
      }

      m_isHealthy = true;
    }

    #endregion Constructor

    #region Accessors
    /// <summary>
    /// 
    /// </summary>
    public ETargetType Type
    {
      get
      {
        return (Instance as TargetBE)._Type;
      }
    }
    /// <summary>
    /// Name of the target
    /// </summary>
    public string Name
    {
      get
      {
        return (Instance as TargetBE)._Name;
      }
    }
    /// <summary>
    /// Description of the target
    /// </summary>
    public string Description
    {
      get
      {
        return (Instance as TargetBE)._Description;
      }
    }
    /// <summary>
    /// Name of the executable
    /// </summary>
    public string Executable
    {
      get
      {
        return (Instance as TargetBE)._Executable;
      }
    }    
    /// <summary>
    /// Flag indicates whether to redirect process' standard input stream.
    /// </summary>
    public bool RedirectFileToStdin
    {
      get
      {
        return (Instance as TargetBE)._RedirectFileToStdin;
      }
    }
    /// <summary>
    /// Filter collection
    /// </summary>
    public NameFilter Filter
    {
      get
      {
        return m_filter;
      }
    }
    public List<Argument> Arguments
    {
      get
      {
        return m_arguments;
      }
    }
    public List<Argument> FileArguments
    {
      get
      {
        List<Argument> list = new List<Argument>();
        foreach (Argument a in m_arguments)
          if (a.Type == ArgType.FILE)
            list.Add(a);
        return list;
      }
    }
    public List<Argument> FixedArguments
    {
      get
      {
        List<Argument> list = new List<Argument>();
        foreach (Argument a in m_arguments)
          if (a.Type == ArgType.FIXED)
            list.Add(a);
        return list;
      }
    }
    public List<Argument> TrackingIdArguments
    {
      get
      {
        List<Argument> list = new List<Argument>();
        foreach (Argument a in m_arguments)
          if (a.Type == ArgType.TRACKINGID)
            list.Add(a);
        return list;
      }
    }
    public List<Argument> BatchIdArguments
    {
      get
      {
        List<Argument> list = new List<Argument>();
        foreach (Argument a in m_arguments)
          if (a.Type == ArgType.BATCHID)
            list.Add(a);
        return list;
      }
    }
    #endregion


    #region Argument Enumeration
    /// <summary>
    /// Comparison helper routine for Arguments based on order
    /// causes sort assending
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    private static int SortArgsAssending(Argument fx, Argument fy)
    {
      if (fx == null)
      {
        // both null, then equal
        if (fy == null) return 0;
      }
      else
      {
        // greater than
        if (fy == null) return 1;
        // equal, even for (-1)
        if (fx.Order == fy.Order) return 0;

        // Deal with the none infinate priority
        if (fx.Order != -1 && fx.Order < fy.Order) return -1;
        if (fy.Order != -1 && fx.Order < fy.Order) return -1;
        if (fx.Order != -1 && fx.Order > fy.Order) return 1;
        if (fy.Order != -1 && fx.Order > fy.Order) return 1;
        if (fx.Order == -1) return 1; // fx has infinite priority
      }
      // otherwise y has priority (maybe infinate) so return less than
      return -1;
    }
    /// <summary>
    /// This routine will enumerate arguments that are part of the target
    /// </summary>
    private void EnumerateArguments()
    {
      MTList<DataObject> argument = DB.LoadInstancesFor(typeof(ArgumentBE).FullName,
                                                        typeof(TargetBE).FullName,
                                                        Instance.Id, new MTList<DataObject>());
      foreach (ArgumentBE a in argument.Items)
      {
        try
        {
          m_arguments.Add(new Argument(DB, a));
        }
        catch (Exception e)
        {
          m_log.Error(e.Message);
          throw;
        }
      }
      m_arguments.Sort(SortArgsAssending);
    }
    #endregion

    /// <summary>
    /// This routine determines if the target instance saved in
    /// cache is the same as the target in the database.
    /// It is also responsible for drilling down into sub-elements
    /// to ensure they too are current. If not, then this instance
    /// is not current.
    /// </summary>
    /// <returns>true if current, false if not</returns>
    public override bool IsUpToDate()
    {
      TargetBE me = Instance as TargetBE;
      if (null == me || me.Id == Guid.Empty)
        return false;

      TargetBE instance = DB.LoadInstance(typeof(TargetBE).FullName, Instance.Id) as TargetBE;
      if (null != instance)
      {
        if (me._Version < instance._Version)
        {
          return false;
        }
        // Before declaring that the target is current,
        // 1) Determine if there are any updated arguments
        foreach(Argument a in m_arguments)
        {
          if(!a.IsUpToDate())
          {
            m_log.Info("Target change caught, argument has been changed");
            return false;
          }
        }
        // 2) Get the arguments for the target instance
        MTList<DataObject> args = DB.LoadInstancesFor(typeof(ArgumentBE).FullName,
                                                      typeof(TargetBE).FullName,
                                                      Instance.Id, new MTList<DataObject>());
        // 3) Determine if there are any new 
        foreach (ArgumentBE a in args.Items)
        {
          if(null == m_arguments.Find(delegate(Argument at){return at.Instance.Id == a.Id;}))
          {
            m_log.Info("Target change caught, argument has been added");
            return false;
          }
        }
        // 4) removed arguments
        foreach(Argument a in m_arguments)
        {
          if (null == args.Items.Find(delegate(DataObject dat)
          {
            ArgumentBE at = dat as ArgumentBE;
            if (null == at) return false;
            return at.Id == a.Instance.Id;
          }
            ))
          {
            m_log.Info("Target change caught, argument has been removed");
            return false;
          }
        }
        return true;
      }
      return false;
    }
    
    public virtual void Compile()
    {
      //TODO: Implement for dyn generated target support
    }
  }
  /// <summary>
  /// A snippet of runtime-compiled code that we are to run in response to a filesystem event.
  /// </summary>
  public class ProgramCode
  {
    private ELanguageType m_lang = ELanguageType.CSHARP;
    /// <summary>
    /// The text of the actual code that we are to compile.
    /// </summary>
    private string text = null;

    /// <summary>
    /// Assembly that results when we compile the code.
    /// </summary>
    private Assembly assembly = null;

    private List<AssemblyDependency> m_RefAssmColl = null;

    /// <summary>
    /// The language for this code snippet.
    /// </summary>
    public ELanguageType Language
    {
      get
      {
        return m_lang;
      }
    }

    /// <summary>
    /// Text representing the actual code.
    /// </summary>
    public string Text
    {
      get
      {
        return text;
      }
    }

    public List<AssemblyDependency> ReferencedAssemblies
    {
      get
      {
        return m_RefAssmColl;
      }
    }

    /// <summary>
    /// Assembly representing the compiled results of the code.
    /// </summary>
    public Assembly Assembly
    {
      get
      {
        // If the code has not already been compiled, do so now
        if (assembly == null)
        {
          CodeDomProvider codeProvider = null;

          // Get the proper code provider based on the code's language
          if (Language == ELanguageType.CSHARP)
            codeProvider = new CSharpCodeProvider();

          else if (Language == ELanguageType.VBASIC)
            codeProvider = new VBCodeProvider();

          CompilerParameters compilerParameters = new CompilerParameters();

          // Set the compiler options so that we don't generate an assembly on disk and
          // we create a library assembly that does not contain debug information
          compilerParameters.GenerateExecutable = false;
          compilerParameters.GenerateInMemory = true;
          compilerParameters.IncludeDebugInformation = false;
          compilerParameters.CompilerOptions = "/target:library /optimize";
          compilerParameters.ReferencedAssemblies.Add("System.dll");
          //TODO: Add list of common assemblys for default access
          compilerParameters.ReferencedAssemblies.Add(AppDomain.CurrentDomain.BaseDirectory + "\\MetraTech.Basic.dll");
          compilerParameters.ReferencedAssemblies.Add(AppDomain.CurrentDomain.BaseDirectory + "\\MetraTech.Basic.Common.dll");

          // Add any assembly references (besides System.dll and DirectoryWatcher.exe, 
          // which everyone gets) specified for this code
          foreach (AssemblyDependency referencedAssembly in ReferencedAssemblies)
            compilerParameters.ReferencedAssemblies.Add(referencedAssembly.Name);

          // Generate the assembly
          CompilerResults results = codeProvider.CompileAssemblyFromSource(compilerParameters, text);

          // Check the return code and throw an exception if the compilation failed
          if (results.NativeCompilerReturnValue != 0)
            throw new CompilationException(results.Errors);

          assembly = results.CompiledAssembly;
        }

        return assembly;
      }
    }
  }
}
