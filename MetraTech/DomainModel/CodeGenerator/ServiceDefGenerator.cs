using System;
using System.Collections.Generic;
using System.IO;
using System.CodeDom;
using System.Web.Script.Serialization;
using System.Xml;
using System.Runtime.Serialization;

using MetraTech.DomainModel.CodeGenerator;

namespace MetraTech.DomainModel.CodeGenerator
{
  /// <summary>
  /// Holds the details of a service definition file.
  /// Also provides static methods for return lists of service
  /// definition files and localization files.
  /// </summary>
  public class ServiceDefFileData : ViewFileData
  {
    #region Public Methods

    /// <summary>
    /// Constructor
    /// </summary>
    /// <param name="viewType">the name of the service definition. Example: metratech.com/meeting
    /// </param>
    public ServiceDefFileData ( string serviceDefnName )
          : base(serviceDefnName)
    {
    }

    /// <summary>
    /// Return a list of service definition file objects and localization file
    /// objects for all the extensions in RMP\Extensions. The Account extension is skipped.
    /// </summary>
    /// <param name="serviceDefFiles">the list of service def files to populate</param>
    /// <param name="localizationFiles">the list of localization files to populate</param>
    public static void GetList ( ref List<FileData> serviceDefFiles, 
                                 ref List<LocalizationFileData> localizationFiles )
    {
      // Go through all the extensions.
      foreach ( string extension in BaseCodeGenerator.RCD.ExtensionList )
      {
        if ( extension == "Account" )
        {
            continue;
        }

        // Get all the service definitions in the extension.
        List<string> files = BaseCodeGenerator.GetFiles ( extension, "service", "msixdef" );

        ServiceDefFileData serviceDefFileData = null;

        // For each service definition, we are going to create a ServiceDefFileData object.
        // We will log an error, but otherwise ignore incorrect service definitions.
        foreach ( string file in files )
        {
            // Get the name of the service definition.
            XmlDocument xmlDocument = new XmlDocument ();
            xmlDocument.Load ( file );
            XmlNode name = xmlDocument.SelectSingleNode ( @"//name" );

            if ( name == null )
            {
                logger.LogError ( "ServiceDefGenerator : Extension file {0} is missing a <name> node", file );
                continue;
            }

            string localeSpace = name.InnerText.Trim ().ToLower ();

            if ( String.IsNullOrEmpty ( localeSpace ) )
            {
                logger.LogError ( "ServiceDefGenerator : Extension file {0} : <name> node is empty", file );
                continue;
            }

            // Create an object representing the service definition file.
            serviceDefFileData = new ServiceDefFileData ( localeSpace );

            serviceDefFileData.ExtensionName = BaseCodeGenerator.RCD.GetExtensionFromPath ( file );
            serviceDefFileData.FileName = Path.GetFileName ( file );
            serviceDefFileData.FullPath = file;

            // Add this to the list of service definitions we are building.
            serviceDefFiles.Add ( serviceDefFileData );

            // Get all the localization files for the extension.
            List<LocalizationFileData> locFileData = LocalizationFileData.GetLocalizationFileData ( extension, localeSpace );

            // Add the localization files to the list we are building.
            if ( locFileData != null && locFileData.Count > 0 )
            {
                localizationFiles.AddRange ( locFileData );
            }
        }
      }

      // Add ancillary ProductView locales 
      localizationFiles.AddRange ( LocalizationFileData.GetLocalizationFileData ( "Core", "metratech.com/defaultadjustmentdetail" ) );
    }

    #endregion

    // Logger
    private static new Logger logger = new Logger("[ServiceDefGenerator]");
  }

  /// <summary>
  /// Generates the code to represent the domain
  /// models for the all the service definitions.
  /// </summary>
  public class ServiceDefGenerator : BaseCodeGenerator
  {
    #region Public Methods

    /// <summary>
    /// Returns the singleton ServiceDefGenerator.
    /// </summary>
    /// <returns></returns>
    public static ServiceDefGenerator GetInstance ()
    {
      return instance;
    }

    /// <summary>
    /// Initialize resource data for this generator.
    /// </summary>
    public static void InitResourceData ()
    {
      if ( resourceData == null )
      {
        resourceData = CreateResourceData ( serviceDefAssemblyName );
      }
    }

    /// <summary>
    /// Generate the service definition domain model code.
    /// </summary>
    /// <param name="debugMode">whether it is debug mode or not</param>
    /// <returns>true on success</returns>
    public bool GenerateCode ( bool debugMode )
    {
      try
      {
        // Create a list of service definition files and localization files.
        List<FileData> serviceDefFiles = new List<FileData> ();
        List<LocalizationFileData> localizationFiles = new List<LocalizationFileData> ();
        ServiceDefFileData.GetList ( ref serviceDefFiles, ref localizationFiles );

        // Create a combined list of service definition files, localization files,
        // and priceable item files.
        // We use this combined list to decided if any of the files has
        // changed since last generation of the code.
        // (A change to a priceable item file might affect the parent-child
        // relationship among service definitions.)
        List<FileData> allFiles = new List<FileData>();
        if ( serviceDefFiles.Count != 0 )
        {
          allFiles.AddRange ( serviceDefFiles );
        }

        foreach ( FileData file in localizationFiles )
        {
          allFiles.Add ( file );
        }

        if (PriceableItemData.ExtensionFiles.Count != 0)
        {
          allFiles.AddRange(PriceableItemData.ExtensionFiles);
        }

        // No need to generate the dll if the input files haven't changed
        if ( !MustGenerateCode ( checksums, allFiles ) )
        {
          logger.LogDebug ( "Assembly '{0}' was not generated because its input files haven't changed", serviceDefAssemblyName );
          return true;
        }

        // Create a dictionary that will hold our generated code.
        Dictionary<string, CodeCompileUnit> codeUnits = new Dictionary<string, CodeCompileUnit> ();

        // Generate the code for all the service definitions.
        if ( !ServiceDefGenerator.GetInstance ().GenerateCode ( serviceDefNamespace, serviceDefFiles, codeUnits ) )
        {
          logger.LogError ( "Assembly '{0}' was not generated.  Service Def generation failed.", serviceDefAssemblyName );
          return false;
        }

        // Generate the checksum.resources file.
        // This is used to determined is anything has changed next time we generate.
        string checksumResourceFile;
        BuildChecksumResource ( allFiles, out checksumResourceFile );
        List<string> resourceFiles = new List<string> ();
        resourceFiles.Add ( checksumResourceFile );

        // Create a list of referenced assemblies the code needs.
        List<string> referencedSystemAssemblies = new List<string> ();
        referencedSystemAssemblies.Add ( "System.dll" );
        referencedSystemAssemblies.Add ( typeof ( ScriptIgnoreAttribute ).Assembly.Location );
        referencedSystemAssemblies.Add ( typeof ( DataContractAttribute ).Assembly.Location );

        // Create a list of local assemblies the code needs.
        List<string> referencedLocalAssemblies = new List<string> ();
        referencedLocalAssemblies.Add ( "MetraTech.DomainModel.Common.dll" );
        referencedLocalAssemblies.Add ( "MetraTech.DomainModel.Enums.Generated.dll" );
        referencedLocalAssemblies.Add ( "MetraTech.DomainModel.BaseTypes.dll" );
        referencedLocalAssemblies.Add ( "MetraTech.ActivityServices.Common.dll" );

        // We are finally ready to build the assembly.
        if (!BuildAssembly(serviceDefAssemblyName,
                           codeUnits,
                           referencedSystemAssemblies,
                           referencedLocalAssemblies,
                           resourceFiles,
                           debugMode,
                           @"ServiceDefs" ))
        {
          return false;
        }

        // Generate resources for assembly.
        if (ResourceData == null)
        {
          InitResourceData ();
        }
        ResourceData resBaseTypes = new ResourceData ();

        AddResourceData ( "MetraTech.DomainMode.BaseTypes.dll", resBaseTypes );

        foreach ( string language in LanguageMappings.Keys )
        {
          Dictionary<string, string> allResources = new Dictionary<string, string> ();
          string standardLanguage = LanguageMappings [ language ];

          ResourceData.GetResources ( language, ref allResources );

          resBaseTypes.GetResources ( language, ref allResources );

          string outDir = Path.Combine ( MetraTech.Basic.Config.SystemConfig.GetBinDir (), standardLanguage );
          if ( !Directory.Exists ( outDir ) )
          {
            Directory.CreateDirectory ( outDir );
          }

          string output = Path.Combine ( outDir, resourceAssemblyName );
          System.Reflection.AssemblyName assemblyName = new System.Reflection.AssemblyName ();
          assemblyName.Name = resourceAssemblyNameWithoutExtension;
          assemblyName.CodeBase = outDir;
          assemblyName.CultureInfo = new System.Globalization.CultureInfo ( standardLanguage );
          assemblyName.SetPublicKeyToken ( AssemblyPublicKeyToken );
          assemblyName.SetPublicKey ( AssemblyPublicKey );
          assemblyName.Version = GetAssembly ( "MetraTech.DomainModel.BaseTypes.dll" ).GetName ().Version;
          assemblyName.KeyPair = new System.Reflection.StrongNameKeyPair ( KeyFileBytes );

          System.Reflection.Emit.AssemblyBuilder assemblyBuilder = AppDomain.CurrentDomain.DefineDynamicAssembly ( assemblyName, System.Reflection.Emit.AssemblyBuilderAccess.RunAndSave, outDir );
          System.Reflection.Emit.ModuleBuilder moduleBuilder = assemblyBuilder.DefineDynamicModule ( resourceAssemblyName, resourceAssemblyName );

          string resourceName = "MetraTech.DomainModel." + standardLanguage + ".Resources";

          string resxFile = Path.Combine ( outDir, resourceName.Replace ( ".Resources", ".resx" ) );

          using ( System.Resources.IResourceWriter resourceWriter = moduleBuilder.DefineResource ( resourceName, "Generated resources", System.Reflection.ResourceAttributes.Public ) )
          {
            using ( System.Resources.ResXResourceWriter resxWriter = new System.Resources.ResXResourceWriter ( resxFile ) )
            {
              foreach ( string key in allResources.Keys )
              {
                resourceWriter.AddResource ( key, allResources [ key ] );
                resxWriter.AddResource ( key, allResources [ key ] );
              }

              assemblyBuilder.Save ( resourceAssemblyName );

              resourceWriter.Close ();
              resxWriter.Close ();
            }
          }
        }

      }
      catch ( Exception e )
      {
        logger.LogError ( "Code generation for Service Defs failed: " + e.Message + " " + e.StackTrace );
        throw e;
      }

      return true;
    }

    /// <summary>
    /// The resource data.
    /// </summary>
    public new static ResourceData ResourceData
    {
      get
      {
        if ( resourceData == null )
        {
          InitResourceData ();
        }

        return resourceData;
      }
      set
      {
        resourceData = value;
      }
    }

    /// <summary>
    /// Build a dictionary of service definition name to children service definition names.
    /// For example, dictionary entry meeting might have children meetingParticipant, meetingLanguage.
    /// The relationship between service definitions is based on the parent information 
    /// provided in the priceable item definitions.   A priceable item definition contains
    /// its corresponding service definition name and can identify its parent.
    /// If there is an error in an examinded priceable item definition, then an error
    /// is logged and that priceable item definition is ignored.
    /// </summary>
    /// <param name="parentToChildren"></param>
    /// <returns></returns>
    public static void GetAncestry(Dictionary<string, List<string>> parentToChildren,
                                   Dictionary<string, string> childToParent)
    {
      if (PriceableItemData.ExtensionFiles.Count == 0)
      {
        logger.LogDebug("No priceable item extensions found.");
        return;
      }

      // Create a dictionary of priceable item name to service definition.
      // We will later need this dictionary to take a priceable item name
      // and get the corresponding service definition name.
      Dictionary<string, string> priceableItemToServDef = new Dictionary<string, string> ();

      // Go through all the extensions.
      foreach (FileData fileData in PriceableItemData.ExtensionFiles)
      {
          XmlDocument doc = new XmlDocument();
          doc.Load(fileData.FullPath);

          // Get the priceable item name
          XmlNode piNameNode = doc.SelectSingleNode("//name");
          if (piNameNode == null)
          {
              logger.LogError("Ignoring improperly defined priceable item (<name/> element missing): " + fileData.FullPath);
              continue;
          }

          string piName = piNameNode.InnerText.Trim();
          if (String.IsNullOrEmpty(piName))
          {
              logger.LogError("Ignoring improperly defined priceable item (no name provided): " + fileData.FullPath);
              continue;
          }

          // Get the service definition name
          XmlNode servDefNode = doc.SelectSingleNode("//pipeline/service_definition");
          if (servDefNode == null)
          {
              logger.LogError("Ignoring improperly defined priceable item (<service_definition/> element is missing): " + fileData.FullPath);
              continue;
          }

          string servDefName = servDefNode.InnerText.Trim();
          if (String.IsNullOrEmpty(servDefName))
          {
              logger.LogError("Ignoring improperly defined priceable item (no service definition provided): " + fileData.FullPath);
              continue;
          }

          // Store the priceable item to service definition name in the dictionary.
          priceableItemToServDef.Add(piName, servDefName);
      }

      // Now that we have the mapping between priceable item name and service definition name,
      // we make another pass examining the parents identified in the priceable item.
      // For each found parent, we will look up the parent's service definition name.
      // Finally, we store the relationship between the parent service definition and the child
      // service definition.

      foreach (FileData fileData in PriceableItemData.ExtensionFiles)
      {
          logger.LogDebug(String.Format("Creating service def ancestry item from '{0}'.", fileData.FullPath));

          // Store any found relationship in the priceable item definition.
          ExtractRelationship(fileData, priceableItemToServDef, parentToChildren, childToParent);
      }
    }

    #endregion

    #region Private Methods

    /// <summary>
    /// Given a list of service definition data files, generate the corresponding
    /// code for the domain models.
    /// </summary>
    /// <param name="nameSpace">Service definition name space. Example: MetraTech.DomainModel.ServiceDef</param>
    /// <param name="fileDataList">list of service definition files</param>
    /// <param name="codeUnits">Generated code.</param>
    /// <returns>true on success.</returns>
    private bool GenerateCode ( string nameSpace, List<FileData> fileDataList, Dictionary<string, CodeCompileUnit> codeUnits )
    {
      if ( fileDataList.Count == 0 )
      {
        logger.LogDebug ( "No service definition files found" );
        return true;
      }

      // Before generating the code, we are going to construct a dictionary mapping
      // service definition name to children service definition names.  We need
      // this to build the domain model for the service definition.  A parent service
      // definition will have subfields for the children service definitions.
      Dictionary<string, List<string>> parentToChildren = new Dictionary<string, List<string>>();
      Dictionary<string, string> childToParent = new Dictionary<string, string>();
      GetAncestry(parentToChildren, childToParent);

      CodeNamespace codeNamespace = new CodeNamespace ( nameSpace );

      // Generate the code for each service definition.
      foreach ( FileData fileData in fileDataList )
      {
        logger.LogDebug ( "Creating service def from: '{0}'.", fileData.FullPath );

        CodeTypeDeclaration serviceDefType = null;
        string typeName;
        string namespaceName;
        string keyName;

        // Look at the service definition file and determine the information needed to produce the code.
        if ( !CreateServiceDef ( fileData, nameSpace, parentToChildren, childToParent,
                                 out serviceDefType, out typeName, out namespaceName, out keyName ) )
        {
          logger.LogDebug ( "Unable to create service def from '{0}'.", fileData.FullPath );
          return false;
        }

        // Add the [DataContract] attribute
        CodeAttributeDeclaration attribute = new CodeAttributeDeclaration ( "System.Runtime.Serialization.DataContractAttribute" );
        attribute.Arguments.Add ( new CodeAttributeArgument ( "Name", new CodePrimitiveExpression ( typeName ) ) );
        attribute.Arguments.Add ( new CodeAttributeArgument ( "Namespace", new CodePrimitiveExpression ( namespaceName ) ) );
        serviceDefType.CustomAttributes.Add ( attribute );

        // Add the [Serializable] attribute
        attribute = new CodeAttributeDeclaration ( "System.SerializableAttribute" );
        serviceDefType.CustomAttributes.Add ( attribute );

        // Add the [ServiceDefinition] attribute
        attribute = new CodeAttributeDeclaration ( "MetraTech.DomainModel.BaseTypes.ServiceDefinitionAttribute" );
        attribute.Arguments.Add ( new CodeAttributeArgument ( "Namespace", new CodePrimitiveExpression ( namespaceName ) ) );
        attribute.Arguments.Add ( new CodeAttributeArgument ( "Name", new CodePrimitiveExpression ( typeName ) ) );
        if ( !string.IsNullOrEmpty ( keyName ) )
        {
          attribute.Arguments.Add ( new CodeAttributeArgument ( "Key", new CodePrimitiveExpression ( keyName ) ) );
        }
        serviceDefType.CustomAttributes.Add ( attribute );

        codeNamespace.Types.Add ( serviceDefType );
      }

      CodeCompileUnit codeUnit = new CodeCompileUnit ();
      codeUnit.Namespaces.Add ( codeNamespace );
      codeUnits.Add ( "ServiceDef.cs", codeUnit );

      return true;
    }

    /// <summary>
    /// Given a service definition file, and a dictionary defining parent service definition children, 
    /// generate various information needed to genearate the code.
    /// </summary>
    /// <param name="fileData">service definition file</param>
    /// <param name="nameSpace">service definition name space. Example: MetraTech.DomainModel.ServiceDef</param>
    /// <param name="serviceDefType">if the service definition doesn't have a parent, then the type
    ///                              will be MetraTech.DomainModel.BaseTypes.RootServiceDef, otherwise
    ///                              MetraTech.DomainModel.BaseTypes.BaseServiceDef</param>
    /// <param name="parentToChildren">relationship between parent and children service definitions</param>
    /// <param name="typeName">Name to use for service definition type. Example: Meeting</param>
    /// <param name="namespaceName">Name space for service definition. Example: metratech.com</param>
    /// <param name="keyName"></param>
    /// <returns>true on success</returns>
    private bool CreateServiceDef ( FileData fileData, string nameSpace, 
                                    Dictionary<string, List<string>> parentToChildren, 
                                    Dictionary<string, string> childToParent,
                                    out CodeTypeDeclaration serviceDefType, 
                                    out string typeName, 
                                    out string namespaceName, 
                                    out string keyName )
    {
      serviceDefType = null;
      typeName = null;
      namespaceName = null;
      keyName = null;

      XmlDocument doc = new XmlDocument ();
      doc.Load ( fileData.FullPath );

      // Get the name of the service definition.
      XmlNode nameNode = doc.SelectSingleNode ( "//name" );
      if ( nameNode == null )
      {
        logger.LogError("Service def generator failed (<name/>is missing): " + fileData.FullPath);
        return false;
      }

      string serviceDefName = nameNode.InnerText.Trim ();

      if ( String.IsNullOrEmpty ( serviceDefName ) )
      {
          logger.LogError("Service def generator failed (name not provided): " + fileData.FullPath);
        return false;
      }

      // Separate the service definition name (example: meeting) from the namespace (example: metratech.com)
      string [] names = serviceDefName.Split ( new char [] { '/' }, StringSplitOptions.RemoveEmptyEntries );

      typeName = names [ names.Length - 1 ];
      namespaceName = names [ 0 ];

      // Convert any funny characters
      string serviceDefPrefix = MakeAlphaNumeric ( serviceDefName );

      // Create the service definition type
      serviceDefType = new CodeTypeDeclaration ();
      serviceDefType.Name = serviceDefPrefix;

      // The type of the service definition depends on whether the
      // service definition is a child or not.
      if ( !childToParent.ContainsKey ( serviceDefName ) )
      {
        serviceDefType.BaseTypes.Add ( "MetraTech.DomainModel.BaseTypes.RootServiceDef" );
      }
      else
      {
        serviceDefType.BaseTypes.Add ( "MetraTech.DomainModel.BaseTypes.BaseServiceDef" );
      }

      // Add properties to the service definition
      XmlNodeList ptypeNodes = doc.SelectNodes ( "//ptype" );

      if ( !CreateServiceDefProperties ( fileData, nameSpace, serviceDefName, ptypeNodes, typeName, ref serviceDefType, out keyName ) )
      {
        return false;
      }

      // If the service definition has children service definitions, then these
      // children properties will become properties of the parent.
      if ( parentToChildren.ContainsKey ( serviceDefName ) )
      {
        foreach ( string child in parentToChildren [ serviceDefName ] )
        {
          string [] childNames = child.Split ( new char [] { '/' }, StringSplitOptions.RemoveEmptyEntries );

          CodeMemberProperty property =
            CreateBaselinePropertyData ( childNames [ childNames.Length - 1 ] + "Children",
                               serviceDefNamespace + "." + serviceDefType.Name + "." + childNames [ 1 ] + "Children",
                               serviceDefName + "/" + childNames [ 1 ] + "Children",
                               MakeAlphaNumeric ( child ),
                               null,
                               true,
                               false,
                               false,
                               ref serviceDefType,
                               resourceData,
                               fileData );
        }
      }
      return true;
    }

    /// <summary>
    /// Given a service definition file, create properties.
    /// </summary>
    /// <param name="fileData">service definition file</param>
    /// <param name="nameSpace">service definition name space. Example: MetraTech.DomainModel.ServiceDef</param>
    /// <param name="serviceDefType">if the service definition doesn't have children, then the type
    ///                              will be MetraTech.DomainModel.BaseTypes.RootServiceDef otherwise,
    ///                              MetraTech.DomainModel.BaseTypes.BaseServiceDef</param>
    /// <param name="ptypeNodes">The ptype nodes from the service definition. These are the service definition fields.</param>
    /// <param name="typeName">Name to use for service definition type. Example: Meeting</param>
    /// <param name="serviceDefName">name of the service definition. Example: metratech.com/Meeting</param>
    /// <param name="keyName">If there is a ptype in the service definition named "id", then "id"
    ///                       will be returned as keyName.  This is arbitrary, but currently there is
    ///                       nothing in the xml that identifies a ptype as being the keyName.</param>
    /// <returns>true on success</returns>
    private bool CreateServiceDefProperties ( FileData fileData, string nameSpace, string serviceDefName, XmlNodeList ptypeNodes, string typeName, ref CodeTypeDeclaration serviceDefType, out string keyName )
    {
      keyName = null;
      foreach ( XmlNode ptypeNode in ptypeNodes )
      {
        ConfigPropertyData configPropertyData = null;

        if ( !GetPropertyData ( ptypeNode, true, out configPropertyData ) )
        {
          logger.LogError ( "Failed to get config property data for {0} ", serviceDefType.Name );
          return false;
        }

        // If the ptype is named "id" we assume this is the key field.
        if ( configPropertyData.Name.Equals ( typeName + "id", StringComparison.OrdinalIgnoreCase ) )
        {
          keyName = configPropertyData.Name;
        }

        CodeMemberProperty property =
            CreateBaselinePropertyData (configPropertyData.Name,
                             serviceDefNamespace + "." + serviceDefType.Name + "." + configPropertyData.Name,
                             serviceDefName + "/" + configPropertyData.Name,
                             configPropertyData.PropertyType.ToString (),
                             configPropertyData.DefaultValue,
                             false,
                             configPropertyData.IsEnum,
                             configPropertyData.IsRequired,
                             ref serviceDefType,
                             resourceData,
                             fileData );

        CreateMTDataMemberAttribute ( ref property, configPropertyData );
      }

      return true;
    }

    /// <summary>
    /// Create baseline property data.
    /// </summary>
    /// <param name="name">name of the property</param>
    /// <param name="fqn">property fqn</param>
    /// <param name="mtlocalizationKey">localization key</param>
    /// <param name="type">data type</param>
    /// <param name="defaultValue">default value or null for no default</param>
    /// <param name="isArray">whether it is an array</param>
    /// <param name="isEnum">whether it is an enum</param>
    /// <param name="isRequired">whether it is required</param>
    /// <param name="codeType">the code type object to populate</param>
    /// <param name="resourceData">resource data</param>
    /// <param name="fileData">file data</param>
    /// <returns>the code member for this property</returns>
    public static CodeMemberProperty CreateBaselinePropertyData ( string name,
                                                    string fqn,
                                                    string mtlocalizationKey,
                                                    string type,
                                                    object defaultValue,
                                                    bool isArray,
                                                    bool isEnum,
                                                    bool isRequired,
                                                    ref CodeTypeDeclaration codeType,
                                                    ResourceData resourceData,
                                                    FileData fileData )
    {
      CodeMemberProperty property = null;

      #region Create regular field and property
      // Create the regular field
      CodeMemberField field = new CodeMemberField ();
      field.Name = LowerCaseFirst ( name );
      if ( field.Name.StartsWith ( "_" ) )
      {
        field.Name = "m" + field.Name;
      }
      CodeTypeReference fieldDataType = new CodeTypeReference ();

      if ( isEnum )
      {
        fieldDataType.BaseType = "System.Nullable<" + type + ">";
      }
      else
      {
        fieldDataType.BaseType = type;
      }

      field.Type = fieldDataType;
      if ( isArray )
      {
        fieldDataType.ArrayRank = 1;
        CodePrimitiveExpression fieldInit = new CodePrimitiveExpression ( null );
        field.InitExpression = fieldInit;
      }
      else if ( defaultValue != null )
      {
        if ( isEnum && defaultValue is Enum )
        {
          CodeTypeReferenceExpression codeTypeReference =
            new CodeTypeReferenceExpression ( defaultValue.GetType () );

          field.InitExpression =
            new CodeFieldReferenceExpression ( codeTypeReference,
               Enum.GetName ( defaultValue.GetType (), ( int ) defaultValue ) );
        }
        else if ( defaultValue is DateTime )
        {
          field.InitExpression = CodeCreateUTCDateTimeValue ( ( DateTime ) defaultValue );
        }
        else
        {
          field.InitExpression = new CodePrimitiveExpression ( defaultValue );
        }

        if ( defaultValue is string && String.IsNullOrEmpty ( defaultValue as string ) )
        {
          field.InitExpression = null;
        }
      }

      codeType.Members.Add ( field );

      // Create the regular property
      property = new CodeMemberProperty ();
      property.Name = UpperCaseFirst ( name );
      property.Type = fieldDataType;
      property.Attributes = MemberAttributes.Public | MemberAttributes.Final;
      property.HasGet = true;
      property.HasSet = true;
      codeType.Members.Add ( property );

      // Create the getter
      CodeFieldReferenceExpression fieldRef =
        new CodeFieldReferenceExpression ( new CodeThisReferenceExpression (), field.Name );

      CodeMethodReturnStatement returnStatement1 = new CodeMethodReturnStatement ( fieldRef );
      property.GetStatements.Add ( returnStatement1 );

      // Create the setter
      property.SetStatements.Add
        ( new CodeAssignStatement ( fieldRef, new CodeArgumentReferenceExpression ( "value" ) ) );

      #endregion

      if ( !string.IsNullOrEmpty ( fqn ) )
      {
        #region Create DisplayName property
        CodeMemberProperty displayNameProperty = new CodeMemberProperty ();
        displayNameProperty.Name = property.Name + "DisplayName";
        displayNameProperty.Type = new CodeTypeReference ( "System.String" );
        displayNameProperty.Attributes = MemberAttributes.Public | MemberAttributes.Final | MemberAttributes.Static;
        displayNameProperty.HasGet = true;
        displayNameProperty.HasSet = false;
        codeType.Members.Add ( displayNameProperty );

        displayNameProperty.GetStatements.Add ( new CodeMethodReturnStatement ( new CodeSnippetExpression ( "ResourceManager.GetString(\"" + fqn.ToLower () + "\")" ) ) );

        List<CodeAttributeArgument> localizationAttributes = new List<CodeAttributeArgument> ();
        localizationAttributes.Add ( new CodeAttributeArgument ( "ResourceId", new CodePrimitiveExpression ( fqn.ToLower () ) ) );
        localizationAttributes.Add ( new CodeAttributeArgument ( "DefaultValue", new CodePrimitiveExpression ( property.Name ) ) );

        string localeSpace = null;
        if ( fileData != null && fileData is ViewFileData )
        {
          localizationAttributes.Add ( new CodeAttributeArgument ( "MTLocalizationId", new CodePrimitiveExpression ( mtlocalizationKey ) ) );
          localizationAttributes.Add ( new CodeAttributeArgument ( "Extension", new CodePrimitiveExpression ( fileData.ExtensionName ) ) );
          localeSpace = ( ( ViewFileData ) fileData ).ViewType;
          localizationAttributes.Add ( new CodeAttributeArgument ( "LocaleSpace", new CodePrimitiveExpression ( localeSpace ) ) );

          if ( fileData.LocalizationFiles.Count > 0 )
          {
            string [] localizationFileNames = fileData.LocalizationFileNames;
            CodePrimitiveExpression [] localizationFiles = new CodePrimitiveExpression [ localizationFileNames.Length ];
            for ( int j = 0; j < localizationFileNames.Length; j++ )
            {
              localizationFiles [ j ] = new CodePrimitiveExpression ( localizationFileNames [ j ] );
            }
            CodeArrayCreateExpression localizationFileArray = new CodeArrayCreateExpression ( new CodeTypeReference ( "System.String" ), localizationFiles );
            localizationAttributes.Add ( new CodeAttributeArgument ( "LocalizationFiles", localizationFileArray ) );
          }
        }

        CodeAttributeDeclaration mtLocalizationAttribute = new CodeAttributeDeclaration ( MetraTech.DomainModel.Common.MTPropertyLocalizationAttribute.QualifiedName, localizationAttributes.ToArray () );
        displayNameProperty.CustomAttributes.Add ( mtLocalizationAttribute );

        CodeAttributeDeclaration scriptIgnore = new CodeAttributeDeclaration ( typeof ( System.Web.Script.Serialization.ScriptIgnoreAttribute ).FullName );
        displayNameProperty.CustomAttributes.Add ( scriptIgnore );
        //        CodeAttributeDeclaration nonSerializable = new CodeAttributeDeclaration ( typeof ( System.NonSerializedAttribute ).FullName );
        //        displayNameProperty.CustomAttributes.Add ( nonSerializable );


        if ( resourceData != null )
        {
          resourceData.AddResource ( mtlocalizationKey, fqn.ToLower (), property.Name, fileData.ExtensionName, localeSpace );
        }
        #endregion
      }

      #region Create the DataMember attribute
      CodeAttributeArgument [] attributeItems = new CodeAttributeArgument [ 1 ];
      // Until we solve ContactType - which is required and doesn't have a default value.
      attributeItems [ 0 ] =
        ( new CodeAttributeArgument ( "IsRequired", new CodePrimitiveExpression ( isRequired ) ) );

      CodeAttributeDeclaration dataMemberAttribute =
        new CodeAttributeDeclaration ( "System.Runtime.Serialization.DataMemberAttribute", attributeItems );

      property.CustomAttributes.Add ( dataMemberAttribute );

      #endregion

      return property;
    }

    /// <summary>
    /// Given a priceable item data file, check if a parent relationship has
    /// been defined.   If so, store the relationship in the given output
    /// dictionary.  If an error is encountered in examining the priceable
    /// item file, then the error is logged and no relationship is stored.
    /// </summary>
    /// <param name="priceableItemDataFile">the priceable item data file to examine.</param>
    /// <param name="priceableItemToServDef">a dictionary for translating a priceable item name to a service definition name.</param>
    /// <param name="parentToChildren">an output dictionary of parent service definition to children service definitions.</param>
    /// <returns></returns>
    private static void ExtractRelationship(FileData priceableItemDataFile, 
                                            Dictionary<string, string> priceableItemToServDef,
                                            Dictionary<string, List<string>> parentToChildren,
                                            Dictionary<string, string> childToParent)
    {
      XmlDocument doc = new XmlDocument();
      doc.Load(priceableItemDataFile.FullPath);

      // Determine the name of the service definition.
      XmlNode servDefNode = doc.SelectSingleNode("//pipeline/service_definition");
      if (servDefNode == null)
      {
        logger.LogError("Ignoring improperly defined priceable item (<service_definition/> element is missing): " + priceableItemDataFile.FullPath);
        return;
      }

      string servDefName = servDefNode.InnerText.Trim();
      if (String.IsNullOrEmpty(servDefName))
      {
        logger.LogError("Ignoring improperly defined priceable item (service definition is not provided): " + priceableItemDataFile.FullPath);
        return;
      }

      // See if a parent priceable item was given
      XmlNode parentPiNode = doc.SelectSingleNode("//relationships/parent");
      if (parentPiNode == null)
      {
        return;
      }

      string parentPiName = parentPiNode.InnerText.Trim();
      if (String.IsNullOrEmpty(parentPiName))
      {
          return;
      }

      // Translate the parent priceable item name to the corresponding
      // service definition name.
      string parentServDefName;
      if (!priceableItemToServDef.TryGetValue(parentPiName, out parentServDefName))
      {
          logger.LogError("The priceable item refers to a parent that is missing a service definition " +
                          "in the parent's priceable item xml file.  The priceable item containing the " +
                          "reference to the parent is: " + priceableItemDataFile.FullPath);
          return;
      }

      // Ignore if the parent is the same as the child
      if (parentServDefName.Equals(servDefName))
      {
          return;
      }

      // Add the relationship to our dictionary of parents.
      if (!parentToChildren.ContainsKey(parentServDefName))
      {
          parentToChildren[parentServDefName] = new List<string>();
      }
     
      // (ESR-6175) Must avoid adding the same child twice in the scenario in which a service definition
      // is used in two different parent PIs, and the child PI of the first parent uses the same service definition
      // as the child PI of the second parent does.
      if (!parentToChildren[parentServDefName].Contains(servDefName))
      {
          parentToChildren[parentServDefName].Add(servDefName);
      }

      // Add the relationship to our dictionary of children.
      if (!childToParent.ContainsKey(servDefName))
      {
        childToParent[servDefName] = parentServDefName;
      }
    }

    #endregion

    #region Data

    private new static Logger logger = new Logger("[ServiceDefGenerator]");

    /// <summary>
    /// Service Definition objects namespace
    /// </summary>
    public const string serviceDefNamespace = "MetraTech.DomainModel.ServiceDef";

    /// <summary>
    /// Service definition objects assembly name
    /// </summary>
    public const string serviceDefAssemblyName = "MetraTech.DomainModel.ServiceDefinitions.Generated.dll";
   
    /// <summary>
    /// Resources dll name
    /// </summary>
    public const string resourceAssemblyNameWithoutExtension = "MetraTech.DomainModel.BaseTypes.Resources";

    /// <summary>
    /// Resources dll name with extension
    /// </summary>
    public const string resourceAssemblyName = resourceAssemblyNameWithoutExtension + ".dll";

    /// <summary>
    /// Checksum resources
    /// </summary>
    public const string checksumResourceFileName = "checksum.resources";

    // .NET guarantees thread safety for static initialization 
    private static readonly ServiceDefGenerator instance = new ServiceDefGenerator();

    // initialized in the constructor
    private static readonly Dictionary<string, string> checksums = GetChecksums ( serviceDefAssemblyName, checksumResourceFileName );

    private static ResourceData resourceData = null;

    #endregion
  }
}
