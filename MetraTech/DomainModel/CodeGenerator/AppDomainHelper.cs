using System;
using System.IO;
using System.Reflection;
using MetraTech.Basic.Config;
using RCD = MetraTech.Interop.RCD;

namespace MetraTech.DomainModel.CodeGenerator
{
  /// <summary>
  /// </summary>
  [Serializable]
  public static class AppDomainHelper
  {
      static AppDomainHelper()
      {
          AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(appDomain_AssemblyResolve);
      }

      #region Public Methods

    public static void CleanDirectories()
    {
      AppDomain appDomain = null;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain();

        string location = Assembly.GetExecutingAssembly().Location;

        CodeGeneratorProxy typeLoader =
          (CodeGeneratorProxy)appDomain.CreateInstanceFromAndUnwrap(location, typeof(CodeGeneratorProxy).FullName);

        typeLoader.CleanDirectories();
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }
    }

    public static bool GenerateEnums(bool debugOnly)
    {
      AppDomain appDomain = null;
      bool status = false;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain();

        string location = Assembly.GetExecutingAssembly().Location;

        CodeGeneratorProxy typeLoader =
          (CodeGeneratorProxy)appDomain.CreateInstanceFromAndUnwrap(location, typeof(CodeGeneratorProxy).FullName);

        status = typeLoader.GenerateEnums(debugOnly);
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }

      return status;
    }

    public static bool GenerateAccounts(bool debugOnly)
    {
      AppDomain appDomain = null;
      bool status = false;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain();

        string location = Assembly.GetExecutingAssembly().Location;

        CodeGeneratorProxy typeLoader =
          (CodeGeneratorProxy)appDomain.CreateInstanceFromAndUnwrap(location, typeof(CodeGeneratorProxy).FullName);

        status = typeLoader.GenerateAccounts(debugOnly);
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }

      return status;
    }

    public static bool GenerateProductOfferings(bool debugOnly)
    {
      AppDomain appDomain = null;
      bool status = false;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain();

        string location = Assembly.GetExecutingAssembly().Location;

        CodeGeneratorProxy typeLoader =
          (CodeGeneratorProxy)appDomain.CreateInstanceFromAndUnwrap(location, typeof(CodeGeneratorProxy).FullName);

        status = typeLoader.GenerateProductOfferings(debugOnly);
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }

      return status;
    }

    public static bool GenerateProductViews(bool debugOnly)
    {
        AppDomain appDomain = null;
        bool status = false;

        try
        {
            // Create AppDomain
            appDomain = CreateAppDomain();

            string location = Assembly.GetExecutingAssembly().Location;

            CodeGeneratorProxy typeLoader =
              (CodeGeneratorProxy)appDomain.CreateInstanceFromAndUnwrap(location, typeof(CodeGeneratorProxy).FullName);

            status = typeLoader.GenerateProductViews(debugOnly);
        }
        finally
        {
            // Unload the AppDomain
            if (appDomain != null)
            {
                AppDomain.Unload(appDomain);
            }
        }

        return status;
    }

    public static bool GenerateServiceDefinitions(bool debugOnly)
    {
        AppDomain appDomain = null;
        bool status = false;

        try
        {
            // Create AppDomain
            appDomain = CreateAppDomain();

            string location = Assembly.GetExecutingAssembly().Location;

            CodeGeneratorProxy typeLoader =
              (CodeGeneratorProxy)appDomain.CreateInstanceFromAndUnwrap(location, typeof(CodeGeneratorProxy).FullName);

            status = typeLoader.GenerateServiceDefs(debugOnly);
        }
        finally
        {
            // Unload the AppDomain
            if (appDomain != null)
            {
                AppDomain.Unload(appDomain);
            }
        }

        return status;
    }

    public static bool GenerateResources()
    {
      AppDomain appDomain = null;
      bool status = false;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain();

        string location = Assembly.GetExecutingAssembly().Location;

        CodeGeneratorProxy typeLoader =
          (CodeGeneratorProxy)appDomain.CreateInstanceFromAndUnwrap(location, typeof(CodeGeneratorProxy).FullName);

        status = typeLoader.GenerateResources();
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }

      return status;
    }
    #endregion

    #region Private Methods
    private static AppDomain CreateAppDomain()
    {
      AppDomain appDomain = null;

      // Setup AppDomain
      var domainSetup = new AppDomainSetup();

      domainSetup.ApplicationName = AppDomainNamePrefix + Guid.NewGuid().ToString().GetHashCode().ToString("x");

      // Set the base directory. 
      domainSetup.ApplicationBase = SystemConfig.GetBinDir();
      domainSetup.ShadowCopyFiles = "true";
      // domainSetup.ShadowCopyDirectories = SystemConfig.GetBinDir();
      domainSetup.CachePath = BaseCodeGenerator.ShadowCopyDir;

      // Create AppDomain
      appDomain = AppDomain.CreateDomain(domainSetup.ApplicationName, null, domainSetup);

      return appDomain;
    }

    static Assembly appDomain_AssemblyResolve(object sender, ResolveEventArgs args)
    {
      Assembly retval = null;
      string searchName = args.Name.Substring(0, (args.Name.IndexOf(',') == -1 ? args.Name.Length : args.Name.IndexOf(','))).ToUpper();

      if (!searchName.Contains(".DLL"))
      {
        searchName += ".DLL";
      }

      try
      {
        AssemblyName nm = AssemblyName.GetAssemblyName(searchName);
        retval = Assembly.Load(nm);
      }
      catch (Exception)
      {
        try
        {
          retval = Assembly.LoadFrom(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), searchName));
        }
        catch (Exception)
        {
          RCD.IMTRcd rcd = new RCD.MTRcd();
          RCD.IMTRcdFileList fileList = rcd.RunQuery(string.Format("Bin\\{0}", searchName), false);

          if (fileList.Count > 0)
          {
            retval = Assembly.LoadFrom(fileList[0] as string);
          }
        }
      }

      return retval;
    }
    #endregion

    #region Properties
    public static string AppDomainNamePrefix
    {
      get
      {
        return "DomainModelAppDomain-";
      }
    }
    #endregion

    #region Data
    static Logger logger =
      new Logger("Logging\\DomainModel\\CodeGenerator", "[AppDomainHelper]");
    #endregion
  }

  
}
