
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Reflection.Emit;
using System.Resources;
using MetraTech.Basic.Config;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class ResourceGenerator : BaseCodeGenerator
  {
    #region Public Methods
    /// <summary>
    ///    (1) Generate one resource assembly and one .resx file for each language specified in config.
    ///    (2) .resx and .resources generated simultaneously
    ///    (3) .resources compiled into assembly using al.exe 
    /// </summary>
    /// <returns></returns>
    public static bool GenerateResources()
    {
      try
      {
        if (EnumGenerator.AssemblyGenerated == false && AccountGenerator.AssemblyGenerated == false)
        {
          logger.LogDebug("No resource assemblies were generated because no input files have changed");
          return true;
        }

        logger.LogDebug("Generating resource assemblies.");

        // Initialize enum resource data
        if (EnumGenerator.ResourceData == null)
        {
          EnumGenerator.InitResourceData();
        } 

        // Initialize account resource data
        if (AccountGenerator.ResourceData == null)
        {
          AccountGenerator.InitResourceData();
        }

        // Initialize product offering resource data
        if (ProductOfferingGenerator.ResourceData == null)
        {
            ProductOfferingGenerator.InitResourceData();
        }

        // Initialize product view resource data
        if (ProductViewGenerator.ResourceData == null)
        {
            ProductViewGenerator.InitResourceData();
        }

        ResourceData resBaseTypes = new ResourceData();
        standardResources.Add(resBaseTypes);
        AddResourceData("MetraTech.DomainModel.BaseTypes.dll", resBaseTypes);

        foreach (string language in BaseCodeGenerator.LanguageMappings.Keys)
        {
          GenerateResourceAssembly(language);
        }

        logger.LogDebug("Finished generating resource assemblies.");
      }
      catch (Exception e)
      {
        logger.LogException("Error occurred while generating resource assembly", e);
        throw;
      }
      
      return true;
    }

    public static void GenerateResourceAssembly(string language)
    {
      string standardLanguage = BaseCodeGenerator.LanguageMappings[language];

      Dictionary<string, string> allResources = new Dictionary<string, string>();

      // Get the enum resources for the given language
      EnumGenerator.ResourceData.GetResources(language, ref allResources);

      // Get the account/view resources for the given language
      AccountGenerator.ResourceData.GetResources(language, ref allResources);

      // Get the ProductOffering resources for the given language
      ProductOfferingGenerator.ResourceData.GetResources(language, ref allResources);

      // Get the ProductView resources for the given language
      ProductViewGenerator.ResourceData.GetResources(language, ref allResources);

      // Get the standard (non-generated) resources
      foreach (ResourceData resourceData in standardResources)
      {
          resourceData.GetResources(language, ref allResources);
      }

      // Create the output dir, if necessary
      string outDir = Path.Combine(SystemConfig.GetBinDir(), standardLanguage);
      if (!Directory.Exists(outDir))
      {
        Directory.CreateDirectory(outDir);
      }

      // Create the assembly
      string output = Path.Combine(outDir, resourceAssemblyName);
      AssemblyName assemblyName = new AssemblyName();
      assemblyName.Name = resourceAssemblyNameWithoutExtension;
      assemblyName.CodeBase = outDir;
      assemblyName.CultureInfo = new CultureInfo(standardLanguage);
      assemblyName.SetPublicKeyToken(AssemblyPublicKeyToken);
      assemblyName.SetPublicKey(AssemblyPublicKey);
      assemblyName.Version = AssemblyVersion;
      assemblyName.KeyPair = new StrongNameKeyPair(KeyFileBytes);


      AssemblyBuilder assemblyBuilder =
        AppDomain.CurrentDomain.DefineDynamicAssembly(assemblyName, AssemblyBuilderAccess.RunAndSave, outDir);
      ModuleBuilder moduleBuilder = assemblyBuilder.DefineDynamicModule(resourceAssemblyName, resourceAssemblyName);

      string resourceName = "MetraTech.DomainModel." + standardLanguage + ".Resources";
      // Create the .resources and .resx files
      string resxFile = Path.Combine(outDir, resourceName.Replace(".Resources", ".resx"));
    
      using (IResourceWriter resourceWriter = 
              moduleBuilder.DefineResource(resourceName, "Generated resources", ResourceAttributes.Public))
      {
        using (ResXResourceWriter resxWriter = new ResXResourceWriter(resxFile))
        {
            foreach (string key in allResources.Keys)
          {
              resourceWriter.AddResource(key, allResources[key]);
              resxWriter.AddResource(key, allResources[key]);
          }

          assemblyBuilder.Save(resourceAssemblyName);

          resourceWriter.Close();
          resxWriter.Close();
        }
      }
    }

    #endregion

    #region Data

    public const string resourceAssemblyName = "MetraTech.DomainModel.BaseTypes.resources.dll";
    public const string resourceAssemblyNameWithoutExtension = "MetraTech.DomainModel.BaseTypes.resources";

    static List<ResourceData> standardResources = new List<ResourceData>();

    #endregion
  }
}
