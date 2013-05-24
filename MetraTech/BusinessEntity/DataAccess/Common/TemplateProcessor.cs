using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml;
using System.CodeDom;
using System.CodeDom.Compiler;
using System.Globalization;
using Microsoft.VisualStudio.TextTemplating;

using MetraTech.Basic;
using MetraTech.Basic.Exception;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;


namespace MetraTech.BusinessEntity.DataAccess.Common
{
  public enum TypeCategory
  {
    Interface,
    Class
  }
  
  public class TemplateProcessor
  {
    #region Public Properties
    public static TemplateProcessor Instance
    {
      get
      {
        if (instance == null)
        {
          lock (syncRoot)
          {
            if (instance == null)
            {
              instance = new TemplateProcessor();
            }
          }
        }

        return instance;
      }
    }
    #endregion

    #region Public Methods
    public void ProcessEntity(Entity entity, string outputFile)
    {
      List<ErrorObject> errors = new List<ErrorObject>();

      try
      {
        entityTemplateHost.Entity = entity;
        entityTemplateHost.InitializeStandardImportsAndAssemblies(entity, TypeCategory.Class);

        string output = engine.ProcessTemplate(entityTemplateContent, entityTemplateHost);
        if (entityTemplateHost.Errors.HasErrors)
        {
          logger.Error(String.Format("Failed to process template '{0}'", entityTemplateFile));
          foreach (CompilerError error in entityTemplateHost.Errors)
          {
            logger.Error(error.ErrorText);
            errors.Add(new ErrorObject(error.ErrorText));
          }
        }

        File.WriteAllText(outputFile, output, entityTemplateHost.FileEncoding);
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to process template '{0}'", entityTemplateFile);
        throw new MetadataException(message, e, SystemConfig.CallerInfo);
      }

      if (errors.Count > 0)
      {
        string message = String.Format("Failed to process template '{0}'", entityTemplateFile);
        throw new MetadataException(message, errors, SystemConfig.CallerInfo);
      }
    }

    public void ProcessEntityInterface(Entity entity, string outputFile)
    {
      List<ErrorObject> errors = new List<ErrorObject>();

      try
      {
        entityInterfaceTemplateHost.Entity = entity;
        entityInterfaceTemplateHost.InitializeStandardImportsAndAssemblies(entity, TypeCategory.Interface);

        string output = engine.ProcessTemplate(entityInterfaceTemplateContent, entityInterfaceTemplateHost);
        if (entityInterfaceTemplateHost.Errors.HasErrors)
        {
          logger.Error(String.Format("Failed to process template '{0}'", entityInterfaceTemplateFile));
          foreach (CompilerError error in entityInterfaceTemplateHost.Errors)
          {
            logger.Error(error.ErrorText);
            errors.Add(new ErrorObject(error.ErrorText));
          }
        }

        File.WriteAllText(outputFile, output, entityInterfaceTemplateHost.FileEncoding);
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to process template '{0}'", entityInterfaceTemplateFile);
        throw new MetadataException(message, e, SystemConfig.CallerInfo);
      }

      if (errors.Count > 0)
      {
        string message = String.Format("Failed to process template '{0}'", entityInterfaceTemplateFile);
        throw new MetadataException(message, errors, SystemConfig.CallerInfo);
      }
    }
    #endregion

    #region Private Methods

    private TemplateProcessor()
    {
      entityTemplateFile = SystemConfig.GetEntityTemplate();
      entityInterfaceTemplateFile = SystemConfig.GetEntityInterfaceTemplate();

      entityTemplateHost = CreateTemplateHost(entityTemplateFile);
      entityInterfaceTemplateHost = CreateTemplateHost(entityInterfaceTemplateFile);
      engine = new Engine();
      entityTemplateContent = File.ReadAllText(entityTemplateFile);
      entityInterfaceTemplateContent = File.ReadAllText(entityInterfaceTemplateFile);
    }

    private static TemplateHost CreateTemplateHost(string templateFile)
    {
      var host = new TemplateHost();
      host.FileExtension = ".cs";
      host.FileEncoding = Encoding.UTF8;
      host.TemplateFile = templateFile;
 
      return host;
    }

    #endregion

    #region Data

    private TemplateHost entityTemplateHost;
    private TemplateHost entityInterfaceTemplateHost;
    private Engine engine;
    private string entityTemplateContent;
    private string entityTemplateFile;
    private string entityInterfaceTemplateContent;
    private string entityInterfaceTemplateFile;
    private static readonly ILog logger = LogManager.GetLogger("TemplateProcessor");
    private static TemplateProcessor instance;
    private static readonly object syncRoot = new Object();

    #endregion
  }

  #region TemplateHost
  [Serializable]
  public class TemplateHost : ITextTemplatingEngineHost
  {
    public string TemplateFile { get; set; }
    public string FileExtension { get; set; }
    public Encoding FileEncoding { get; set; }
    public CompilerErrorCollection Errors { get; set; }

    private IList<string> standardAssemblyReferences = new List<string>();
    public IList<string> StandardAssemblyReferences
    {
      get { return standardAssemblyReferences; }
      set { standardAssemblyReferences = value;}
    }
    private IList<string> standardImports = new List<string>();
    public IList<string> StandardImports
    {
      get { return standardImports; }
      set { standardImports = value; }
    }

    public Entity Entity { get; set; }

    public bool LoadIncludeText(string requestFileName, out string content, out string location)
    {
      content = string.Empty;
      location = string.Empty;

      if (!File.Exists(requestFileName))
      {
        return false;
      }

      content = File.ReadAllText(requestFileName);
      return true;
    }

    public object GetHostOption(string optionName)
    {
      switch (optionName)
      {
        case "CacheAssemblies":
          return true;
        default:
          return false;
      }
    }

    public string ResolveAssemblyReference(string assemblyReference)
    {
      if (File.Exists(assemblyReference))
      {
        return assemblyReference;
      }

      string candidate = Path.Combine(SystemConfig.GetBinDir(), assemblyReference);
      if (File.Exists(candidate))
      {
        return candidate;
      }

      return string.Empty;
    }

    public List<string> CommandLineArguments { get; set; }

    public Type ResolveDirectiveProcessor(string processorName)
    {
      if (string.Equals(processorName, "CodeGen", StringComparison.InvariantCultureIgnoreCase))
      {
        CustomDirectiveProcessor.CommandLineArguments = CommandLineArguments;
        return typeof(CustomDirectiveProcessor);
      }
      throw new MetadataException("Directive processor for " + processorName + " not found", SystemConfig.CallerInfo);
    }

    public string ResolvePath(string path)
    {
      if (string.IsNullOrEmpty(path))
      {
        throw new MetadataException(new ArgumentException("path", "Path cannot be null"), SystemConfig.CallerInfo);
      }

      if (File.Exists(path))
      {
        return path;
      }

      var candidate = Path.Combine(Path.GetDirectoryName(this.TemplateFile), path);
      if (File.Exists(candidate))
      {
        return candidate;
      }

      return path;
    }

    public string ResolveParameterValue(string directiveId, string processorName, string parameterName)
    {
      if (string.IsNullOrEmpty(directiveId))
      {
        throw new MetadataException(new ArgumentNullException("directiveId", "Directive cannot be null"), SystemConfig.CallerInfo);
      }
      if (string.IsNullOrEmpty(processorName))
      {
        throw new MetadataException(new ArgumentNullException("processorName", "Processor cannot be null"), SystemConfig.CallerInfo); 
      }
      if (string.IsNullOrEmpty(parameterName))
      {
        throw new MetadataException(new ArgumentNullException("parameterName", "Parameter cannot be null"), SystemConfig.CallerInfo); 
      }

      return string.Empty;
    }

    public void SetFileExtension(string extension)
    {
      FileExtension = extension;
    }

    public void LogErrors(CompilerErrorCollection errors)
    {
      Errors = errors;
    }

    public AppDomain ProvideTemplatingAppDomain(string content)
    {
      return AppDomainHelper.CreateAppDomain(null, null);
    }

    public void SetOutputEncoding(Encoding encoding, bool fromOutputDirective)
    {
      FileEncoding = encoding;
    }

    public void InitializeStandardImportsAndAssemblies(Entity entity, TypeCategory typeCategory)
    {
      StandardImports.Clear();
      StandardAssemblyReferences.Clear();

      #region Standard Imports
      StandardImports.Add("System");
      StandardImports.Add("System.CodeDom");
      StandardImports.Add("System.CodeDom.Compiler");
      StandardImports.Add("MetraTech.BusinessEntity.DataAccess.Common");
      StandardImports.Add("MetraTech.BusinessEntity.DataAccess.Metadata");
      StandardImports.Add("MetraTech.BusinessEntity.Core.Model");
      StandardImports.Add("MetraTech.BusinessEntity.Core");
      StandardImports.Add("MetraTech.Basic");
      #endregion

      #region Standard Assembly References
      string binDir = SystemConfig.GetBinDir();

      string assemblyPath = Path.Combine(binDir, "log4net.dll");
      Check.Assert(File.Exists(assemblyPath), String.Format("Cannot find file '{0}'", assemblyPath));
      StandardAssemblyReferences.Add(assemblyPath);

      assemblyPath = Path.Combine(binDir, "NHibernate.dll");
      Check.Assert(File.Exists(assemblyPath), String.Format("Cannot find file '{0}'", assemblyPath));
      StandardAssemblyReferences.Add(assemblyPath);

      assemblyPath = Path.Combine(binDir, "MetraTech.Basic.dll");
      Check.Assert(File.Exists(assemblyPath), String.Format("Cannot find file '{0}'", assemblyPath));
      StandardAssemblyReferences.Add(assemblyPath);

      assemblyPath = Path.Combine(binDir, "MetraTech.BusinessEntity.Core.dll");
      Check.Assert(File.Exists(assemblyPath), String.Format("Cannot find file '{0}'", assemblyPath));
      StandardAssemblyReferences.Add(assemblyPath);

      assemblyPath = Path.Combine(binDir, "MetraTech.BusinessEntity.DataAccess.dll");
      Check.Assert(File.Exists(assemblyPath), String.Format("Cannot find file '{0}'", assemblyPath));
      StandardAssemblyReferences.Add(assemblyPath);

      assemblyPath = Path.Combine(binDir, "MetraTech.DomainModel.Enums.Generated.dll");
      Check.Assert(File.Exists(assemblyPath), String.Format("Cannot find file '{0}'", assemblyPath));
      StandardAssemblyReferences.Add(assemblyPath);

      StandardAssemblyReferences.Add(typeof(XmlDocument).Assembly.Location);
      StandardAssemblyReferences.Add(typeof(CodeCompileUnit).Assembly.Location);
      #endregion

      ICollection<string> interfaceNamespaces = null;
      if (typeCategory == TypeCategory.Class)
      {
        interfaceNamespaces = entity.GetInterfaceNamespaces(true);
      }
      else
      {
        interfaceNamespaces = entity.GetInterfaceNamespaces(false);
      }
      foreach (string interfaceNamespace in interfaceNamespaces)
      {
        if (!StandardImports.Contains(interfaceNamespace))
        {
          StandardImports.Add(interfaceNamespace);
        }
      }

      ICollection<string> interfaceAssemblyNames = null;
      if (typeCategory == TypeCategory.Class)
      {
        interfaceAssemblyNames = entity.GetInterfaceAssemblyNames(true, false);
      }
      else
      {
        interfaceAssemblyNames = entity.GetInterfaceAssemblyNames(false, false);
      }

      foreach (string interfaceAssemblyName in interfaceAssemblyNames)
      {
        assemblyPath = Path.Combine(binDir, interfaceAssemblyName + ".dll");
        Check.Assert(File.Exists(assemblyPath), String.Format("Cannot find file '{0}'", assemblyPath));

        if (!StandardAssemblyReferences.Contains(assemblyPath))
        {
          StandardAssemblyReferences.Add(assemblyPath);
        }
      }
    }
  }
  #endregion

  #region CustomDirectiveProcessor
  public class CustomDirectiveProcessor : DirectiveProcessor
  {
    private const string includeArgumentsKeyword = "includeArguments";
    public override bool IsDirectiveSupported(string directiveName)
    {
      if (string.Equals(directiveName, includeArgumentsKeyword, StringComparison.InvariantCultureIgnoreCase))
      {
        return true;
      }

      return false;
    }

    public CodeDomProvider Provider { get; set; }
    public string TemplateContents { get; set; }
    public new CompilerErrorCollection Errors { get; set; }
    private StringBuilder codeBuffer;

    public override void StartProcessingRun(CodeDomProvider languageProvider, string templateContents, CompilerErrorCollection errors)
    {
      Provider = languageProvider;
      TemplateContents = templateContents;
      Errors = errors;
      codeBuffer = new StringBuilder();
    }

    public static List<string> CommandLineArguments = new List<string>();

    public override void ProcessDirective(string directiveName, IDictionary<string, string> arguments)
    {
      var options = new CodeGeneratorOptions()
      {
        BlankLinesBetweenMembers = true,
        IndentString = "    ",
        VerbatimOrder = true
      };

      if (string.Equals(directiveName, includeArgumentsKeyword, StringComparison.InvariantCultureIgnoreCase))
      {
        GenerateCommandLineArgumentProperties(options);
      }

    }

    private void GenerateCommandLineArgumentProperties(CodeGeneratorOptions options)
    {
      for (int argumentIndex = 0; argumentIndex < CommandLineArguments.Count; argumentIndex++)
      {
        var property = new CodeMemberProperty()
        {
          Name = "Argument" + argumentIndex,
          Type = new CodeTypeReference(typeof(string)),
          Attributes = MemberAttributes.Public,
          HasGet = true,
          HasSet = false
        };

        property.GetStatements.Add(new CodeMethodReturnStatement(new CodePrimitiveExpression(CommandLineArguments[argumentIndex])));

        using (StringWriter writer = new StringWriter(codeBuffer, CultureInfo.InvariantCulture))
        {
          Provider.GenerateCodeFromMember(property, writer, options);
        }
      }
    }

    public override void FinishProcessingRun()
    {
      Provider = null;
    }

    public override string GetClassCodeForProcessingRun()
    {
      return codeBuffer.ToString();
    }

    public override string[] GetImportsForProcessingRun()
    {
      var thisNamespaceElements = this.GetType().ToString().Split('.');
      var thisNamespace = string.Join(".", thisNamespaceElements.Take(thisNamespaceElements.Count() - 1).ToArray());
      return new string[]
           {
              thisNamespace
           };
    }

    public override string GetPreInitializationCodeForProcessingRun()
    {
      return string.Empty;
    }

    public override string GetPostInitializationCodeForProcessingRun()
    {
      return string.Empty;
    }

    public override string[] GetReferencesForProcessingRun()
    {
      return new string[]
           {
               this.GetType().Assembly.Location
           };
    }
  }
  #endregion
}
