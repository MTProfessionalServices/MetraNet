using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using MetraTech.ActivityServices.Configuration;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Configuration;
using System.ServiceModel.Description;
using System.CodeDom;
using System.CodeDom.Compiler;
using System.IO;
using Microsoft.CSharp;
using MetraTech.Interop.SysContext;
using MetraTech.ActivityServices.Services.Common;
using System.Reflection;
using RCD = MetraTech.Interop.RCD;
using MetraTech.ActivityServices.Runtime;

namespace MetraTech.ActivityServices.ClientCodeGenerators
{
    using MethodDefDictionary = Dictionary<string, MASMethodInfo>;
    using MethodDefPair = KeyValuePair<string, MASMethodInfo>;
    using System.Security.Cryptography.X509Certificates;
    using MetraTech.ActivityServices.Runtime;
    using System.Data;
    using MetraTech.ActivityServices.Common;

    public class CMASClientProxyGenerator : CMASInterfaceGeneratorBase
    {
        #region Members
        private string m_ExtensionName;
        private Dictionary<string, CodeCompileUnit> m_CodeUnits = new Dictionary<string, CodeCompileUnit>();

        private bool m_BuildDebug = false;

        private static string m_NameSpaceBase = "MetraTech.";
        private static string m_BasePathFormatString;

        private static TypeExtensionsConfig m_TypeExtensions;
        #endregion

        #region Constructor
        static CMASClientProxyGenerator()
        {
            m_TypeExtensions = TypeExtensionsConfig.GetInstance();
        }

        public CMASClientProxyGenerator(string extensionName, bool buildDebug)
        {
            m_Logger = new Logger("Logging\\ActivityServices", "[MASClientProxyGenerator]");

            m_ExtensionName = extensionName;
            m_BuildDebug = buildDebug;
        }
        #endregion

        #region Properties
        public static string NameSpaceBase
        {
            get { return m_NameSpaceBase; }
            set { m_NameSpaceBase = value; }
        }

        public static string BasePathFormatString
        {
            get { return m_BasePathFormatString; }
            set { m_BasePathFormatString = value; }
        }

        private string BasePath
        {
            get { return string.Format(BasePathFormatString, m_ExtensionName); }
        }

        private string NameSpaceName
        {
            get { return string.Format("{0}{1}.ClientProxies", NameSpaceBase, m_ExtensionName); }
        }

        public string OutputAssembly
        {
            get { return Path.Combine(BasePath, string.Format("{0}.dll", NameSpaceName)); }
        }
        #endregion

        #region Public Methods
        public void AddClientProxies(CMASConfiguration configFile)
        {
            try
            {
                foreach (CMASEventService interfaceDef in configFile.EventServiceDefs.Values)
                {
                    if (interfaceDef.IsPageNav)
                    {
                        CMASEventService tmp = interfaceDef;
                        AddSetStateEventMethod(ref tmp);
                    }

                    AddMASEventProxy(interfaceDef);
                }

                foreach (CMASProceduralService interfaceDef in configFile.ProceduralServiceDefs.Values)
                {
                    AddMASProceduralProxy(interfaceDef);
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("Exception caught adding child proxies.", e);

                throw e;
            }
        }

        public bool BuildClientProxies()
        {
            bool retval = false;

            try
            {
                retval = BuildAssembly();
            }
            catch (Exception e)
            {
                m_Logger.LogException("Exception caught building child proxies.", e);

                throw e;
            }

            return retval;
        }
        #endregion

        #region Private Methods
        private bool BuildAssembly()
        {
            bool retval = true;

            m_Logger.LogDebug("Building assembly");

            CSharpCodeProvider compiler = new CSharpCodeProvider();
            CompilerParameters options = new CompilerParameters();
            CompilerResults result = null;

            string snkFileName = string.Format("ClientProxyGenKey{0}.snk", System.Diagnostics.Process.GetCurrentProcess().Id);

            if (File.Exists(snkFileName))
            {
                File.Delete(snkFileName);
            }

            FileStream wtr = File.Open(snkFileName, FileMode.Create, FileAccess.Write, FileShare.None);

            wtr.Write(KeyRes.MetraTech, 0, KeyRes.MetraTech.Length);

            wtr.Flush();
            wtr.Close();


            options.ReferencedAssemblies.Add(typeof(string).Assembly.Location);
            options.ReferencedAssemblies.Add(typeof(IDataReader).Assembly.Location);
            options.ReferencedAssemblies.Add(typeof(ServiceHost).Assembly.Location);
            options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MetraTech.Common.dll"));
            options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "SysContext.Interop.dll"));
            options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MetraTech.ActivityServices.Common.dll"));
            options.ReferencedAssemblies.Add(typeof(OperationDescription).Assembly.Location);

            List<Assembly> loadedAssemblies = new List<Assembly>(m_LoadedAssemblies.Values);

            foreach (Assembly loadedAssembly in loadedAssemblies)
            {
                if (!options.ReferencedAssemblies.Contains(loadedAssembly.FullName))
                {
                    m_Logger.LogDebug("Adding referenced assembly: {0}", loadedAssembly.Location);
                    options.ReferencedAssemblies.Add(loadedAssembly.Location);
                }

                foreach (AssemblyName assemName in loadedAssembly.GetReferencedAssemblies())
                {
                    Assembly refAssem = Assembly.Load(assemName);

                    if (!options.ReferencedAssemblies.Contains(refAssem.Location))
                    {
                        m_Logger.LogDebug("Adding referenced assembly: {0}", refAssem.Location);
                        options.ReferencedAssemblies.Add(refAssem.Location);
                    }
                }
            }

            options.CompilerOptions = string.Format("/optimize /keyfile:{0}", snkFileName);

            //      MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();


            if (!Directory.Exists(BasePath))
            {
                Directory.CreateDirectory(BasePath);
            }

            if (!m_BuildDebug)
            {
                m_Logger.LogDebug("Building in Release Mode");
                #region Compile in Release Mode
                options.TempFiles.KeepFiles = false;
                options.GenerateInMemory = false;
                options.IncludeDebugInformation = false;

                options.OutputAssembly = OutputAssembly;

                CodeCompileUnit[] codeUnits = new CodeCompileUnit[m_CodeUnits.Count];
                m_CodeUnits.Values.CopyTo(codeUnits, 0);

                result = compiler.CompileAssemblyFromDom(options, codeUnits);
                #endregion
            }
            else
            {
                m_Logger.LogDebug("Building in Debug Mode");
                #region Compile in Debug Mode
                string path = Path.Combine(BasePath, "MASClientProxyCode");

                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }

                string[] fileNames = new string[m_CodeUnits.Count];
                int i = 0;

                foreach (KeyValuePair<string, CodeCompileUnit> kvp in m_CodeUnits)
                {
                    try
                    {
                        fileNames[i] = Path.Combine(path, string.Format("{0}.cs", kvp.Key));
                        IndentedTextWriter wrtr = new IndentedTextWriter(new StreamWriter(fileNames[i++], false), "    ");
                        compiler.GenerateCodeFromCompileUnit(kvp.Value, wrtr, new CodeGeneratorOptions());
                        wrtr.Flush();
                        wrtr.Close();
                    }
                    catch (Exception e)
                    {
                        Logger log = new Logger("[MASInterfaceGenerator]");

                        log.LogException("Error dumping code", e);
                    }
                }

                options.CompilerOptions += " /debug:full";
                options.IncludeDebugInformation = true;

                options.TempFiles.KeepFiles = true;

                options.OutputAssembly = OutputAssembly;

                result = compiler.CompileAssemblyFromFile(options, fileNames);
                #endregion
            }

            // Clean up the SNK file since we don't want to be leaving it around
            if (File.Exists(snkFileName))
            {
                File.Delete(snkFileName);
            }

            if (result.Errors.HasErrors || result.Errors.HasWarnings)
            {

                foreach (CompilerError err in result.Errors)
                {
                    if (err.IsWarning)
                    {
                        m_Logger.LogWarning("Warning {0}: {1} occurred on line {2}, column {3} in file \"{4}\"", err.ErrorNumber, err.ErrorText, err.Line, err.Column, err.FileName);
                    }
                    else
                    {
                        m_Logger.LogError("Error {0}: {1} occurred on line {2}, column {3} in file \"{4}\"", err.ErrorNumber, err.ErrorText, err.Line, err.Column, err.FileName);
                    }
                }
            }

            if (result.Errors.HasErrors)
            {
                retval = false;
            }

            return retval;
        }

        private void AddMASEventProxy(CMASEventService interfaceDef)
        {
            m_Logger.LogInfo("Adding ActivityServices Interface: {0}", interfaceDef.InterfaceName);

            CodeNamespace nameSpace = new CodeNamespace(NameSpaceName);

            nameSpace.Imports.Add(new CodeNamespaceImport("System"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.Text"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.ServiceModel"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Common"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.ServiceModel.Description"));

            MethodDefDictionary methodDefs = new MethodDefDictionary();
            MASMethodInfo info;

            foreach (CMASEventMethod method in interfaceDef.EventMethods.Values)
            {
                info = new MASMethodInfo();

                info.ParameterDefs = method.ParameterDefs;
                info.FaultType = method.FaultType;
                // Current version of MS Workflow Foundation does not support flowing transactions into workflows
                // Commenting out capability until they fix the problem.
                //info.AllowTransactionFlow = method.AllowTransactionFlow;

                methodDefs.Add(method.MethodName, info);
            }

            GenerateEventInterfaceDef(ref nameSpace, interfaceDef.InterfaceName, interfaceDef);
            GenerateAsyncMethodsOnInterface(ref nameSpace, interfaceDef.InterfaceName, methodDefs, true, interfaceDef.AllowMultiple);

            GenerateChannelInterfaceDef(ref nameSpace, interfaceDef.InterfaceName);

            GenerateInterfaceProxyClass(ref nameSpace, interfaceDef.InterfaceName, methodDefs, true, interfaceDef.AllowMultiple);

            GenerateMethodProxyClasses(ref nameSpace, interfaceDef.InterfaceName, methodDefs, true, interfaceDef.AllowMultiple);

            CodeCompileUnit interfaceModule = new CodeCompileUnit();
            interfaceModule.Namespaces.Add(nameSpace);

            m_CodeUnits.Add(interfaceDef.InterfaceName, interfaceModule);
        }

        private void AddMASProceduralProxy(CMASProceduralService interfaceDef)
        {
            m_Logger.LogInfo("Adding ActivityServices Interface: {0}", interfaceDef.InterfaceName);

            CodeNamespace nameSpace = new CodeNamespace(NameSpaceName);

            nameSpace.Imports.Add(new CodeNamespaceImport("System"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.Text"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.ServiceModel"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Common"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.ServiceModel.Description"));

            MethodDefDictionary methodDefs = new MethodDefDictionary();
            MASMethodInfo info;

            foreach (CMASProceduralMethod method in interfaceDef.ProceduralMethods.Values)
            {
                info = new MASMethodInfo();

                info.ParameterDefs = method.ParameterDefs;
                info.FaultType = method.FaultType;
                // Current version of MS Workflow Foundation does not support flowing transactions into workflows
                // Commenting out capability until they fix the problem.
                //info.AllowTransactionFlow = method.AllowTransactionFlow;
                info.IsOneWay = method.IsOneWay;

                methodDefs.Add(method.MethodName, info);
            }

            GenerateProceduralInterfaceDef(ref nameSpace, interfaceDef.InterfaceName, interfaceDef);
            GenerateAsyncMethodsOnInterface(ref nameSpace, interfaceDef.InterfaceName, methodDefs, false, false);
            GenerateChannelInterfaceDef(ref nameSpace, interfaceDef.InterfaceName);

            GenerateInterfaceProxyClass(ref nameSpace, interfaceDef.InterfaceName, methodDefs, false, false);

            GenerateMethodProxyClasses(ref nameSpace, interfaceDef.InterfaceName, methodDefs, false, false);

            CodeCompileUnit interfaceModule = new CodeCompileUnit();
            interfaceModule.Namespaces.Add(nameSpace);

            m_CodeUnits.Add(interfaceDef.InterfaceName, interfaceModule);
        }

        private void GenerateAsyncMethodsOnInterface(ref CodeNamespace nameSpace, string interfaceName, MethodDefDictionary methodDefs, bool bIsEventInterface, bool bAllowMultiple)
        {
            string iName = string.Format("I{0}", interfaceName);
            CodeTypeDeclaration interfaceTypeDef = null;

            foreach (CodeTypeDeclaration decl in nameSpace.Types)
            {
                if (decl.Name == iName)
                {
                    interfaceTypeDef = decl;
                    break;
                }
            }

            if (interfaceTypeDef != null)
            {
                CodeMemberMethod[] asyncMethods;

                foreach (MethodDefPair methodDef in methodDefs)
                {
                    if (!methodDef.Value.IsOneWay)
                    {
                        asyncMethods = CreateAsyncMemberMethods(methodDef.Key, methodDef.Value.ParameterDefs, bIsEventInterface, bAllowMultiple);

                        interfaceTypeDef.Members.AddRange(asyncMethods);
                    }
                }
            }
        }

        private CodeMemberMethod[] CreateAsyncMemberMethods(string methodName, Dictionary<string, CMASParameterDef> paramDefs, bool bIsEventInterface, bool bAllowMultipleInstances)
        {
            if (!bIsEventInterface && bAllowMultipleInstances)
            {
                throw new ConfigurationErrorsException("The AllowMultipleInstances flag cannot be set to true if the EventInterface flag is not");
            }

            CodeMemberMethod[] methods = new CodeMemberMethod[2];

            methods[0] = new CodeMemberMethod();
            methods[0].Name = string.Format("Begin{0}", methodName);
            methods[0].ReturnType = new CodeTypeReference(typeof(IAsyncResult));
            methods[0].CustomAttributes.Add(new CodeAttributeDeclaration("OperationContract", new CodeAttributeArgument("AsyncPattern", new CodePrimitiveExpression(true))));


            methods[1] = new CodeMemberMethod();
            methods[1].Name = string.Format("End{0}", methodName); ;
            methods[1].ReturnType = new CodeTypeReference(typeof(void));

            CodeParameterDeclarationExpression paramDecl;

            if (bAllowMultipleInstances)
            {
                paramDecl = new CodeParameterDeclarationExpression(typeof(Guid), "processorInstanceId");
                paramDecl.Direction = FieldDirection.Ref;
                methods[0].Parameters.Add(paramDecl);

                methods[1].Parameters.Add(paramDecl);
            }

            foreach (CMASParameterDef param in paramDefs.Values)
            {
                paramDecl = new CodeParameterDeclarationExpression(GetCodeTypeReference(param.ParameterType), param.ParameterName);

                switch (param.ParamDirection)
                {
                    case CMASParameterDef.ParameterDirection.In:
                        methods[0].Parameters.Add(paramDecl);
                        break;
                    case CMASParameterDef.ParameterDirection.InOut:
                        paramDecl.Direction = FieldDirection.Ref;
                        methods[0].Parameters.Add(paramDecl);
                        methods[1].Parameters.Add(paramDecl);
                        break;
                    case CMASParameterDef.ParameterDirection.Out:
                        paramDecl.Direction = FieldDirection.Out;
                        methods[1].Parameters.Add(paramDecl);
                        break;
                };

            }

            CodeParameterDeclarationExpression interfaceParam;

            if (bIsEventInterface)
            {
                interfaceParam = new CodeParameterDeclarationExpression(typeof(Dictionary<string, object>), "stateInitData");
                interfaceParam.Direction = FieldDirection.Out;

                methods[1].Parameters.Add(interfaceParam);
            }

            paramDecl = new CodeParameterDeclarationExpression(typeof(AsyncCallback), "callback");
            methods[0].Parameters.Add(paramDecl);

            paramDecl = new CodeParameterDeclarationExpression(typeof(object), "asyncState");
            methods[0].Parameters.Add(paramDecl);

            paramDecl = new CodeParameterDeclarationExpression(typeof(IAsyncResult), "result");
            methods[1].Parameters.Add(paramDecl);

            return methods;
        }

        private void GenerateChannelInterfaceDef(ref CodeNamespace nameSpace, string interfaceName)
        {
            CodeTypeDeclaration wcfInterface = new CodeTypeDeclaration(string.Format("I{0}Channel", interfaceName));
            wcfInterface.IsClass = false;
            wcfInterface.IsInterface = true;
            wcfInterface.Attributes = MemberAttributes.Public;
            wcfInterface.BaseTypes.Add(string.Format("I{0}", interfaceName));
            wcfInterface.BaseTypes.Add(typeof(IClientChannel));

            nameSpace.Types.Add(wcfInterface);

        }

        private void GenerateInterfaceProxyClass(ref CodeNamespace nameSpace, string interfaceName, MethodDefDictionary methodDefs, bool bIsEventInterface, bool bAllowMultiple)
        {
            CodeMemberMethod methodDecl;
            CodeMemberMethod[] asyncMethodDecls;
            CodeMethodReturnStatement retStmt;
            CodeMethodInvokeExpression methodStmt;
            CodeConstructor constructor;

            CodeTypeDeclaration wcfClass = new CodeTypeDeclaration(string.Format("{0}Client", interfaceName));
            wcfClass.IsClass = true;

            CodeTypeReference baseRef = new CodeTypeReference(typeof(ClientBase<>));
            baseRef.TypeArguments.Add(string.Format("I{0}", interfaceName));
            wcfClass.BaseTypes.Add(baseRef);

            wcfClass.BaseTypes.Add(new CodeTypeReference(string.Format("I{0}", interfaceName)));

            wcfClass.Attributes = MemberAttributes.Public;
            wcfClass.IsPartial = true;
            wcfClass.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(System.Diagnostics.DebuggerStepThroughAttribute))));

            #region Add Constructors

            wcfClass.Members.Add(GenerateKnownTypesMethod(methodDefs));

            constructor = new CodeConstructor();
            constructor.Attributes = MemberAttributes.Public;
            constructor.Statements.Add(new CodeMethodInvokeExpression(new CodeThisReferenceExpression(), "AddKnownTypes"));
            wcfClass.Members.Add(constructor);

            constructor = new CodeConstructor();
            constructor.Attributes = MemberAttributes.Public;
            constructor.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "endpointConfigurationName"));
            constructor.BaseConstructorArgs.Add(new CodeVariableReferenceExpression("endpointConfigurationName"));
            constructor.Statements.Add(new CodeMethodInvokeExpression(new CodeThisReferenceExpression(), "AddKnownTypes"));
            wcfClass.Members.Add(constructor);

            constructor = new CodeConstructor();
            constructor.Attributes = MemberAttributes.Public;
            constructor.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "endpointConfigurationName"));
            constructor.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "remoteAddress"));
            constructor.BaseConstructorArgs.Add(new CodeVariableReferenceExpression("endpointConfigurationName"));
            constructor.BaseConstructorArgs.Add(new CodeVariableReferenceExpression("remoteAddress"));
            constructor.Statements.Add(new CodeMethodInvokeExpression(new CodeThisReferenceExpression(), "AddKnownTypes"));
            wcfClass.Members.Add(constructor);

            constructor = new CodeConstructor();
            constructor.Attributes = MemberAttributes.Public;
            constructor.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "endpointConfigurationName"));
            constructor.Parameters.Add(new CodeParameterDeclarationExpression(typeof(EndpointAddress), "remoteAddress"));
            constructor.BaseConstructorArgs.Add(new CodeVariableReferenceExpression("endpointConfigurationName"));
            constructor.BaseConstructorArgs.Add(new CodeVariableReferenceExpression("remoteAddress"));
            constructor.Statements.Add(new CodeMethodInvokeExpression(new CodeThisReferenceExpression(), "AddKnownTypes"));
            wcfClass.Members.Add(constructor);

            constructor = new CodeConstructor();
            constructor.Attributes = MemberAttributes.Public;
            constructor.Parameters.Add(new CodeParameterDeclarationExpression(typeof(System.ServiceModel.Channels.Binding), "binding"));
            constructor.Parameters.Add(new CodeParameterDeclarationExpression(typeof(EndpointAddress), "remoteAddress"));
            constructor.BaseConstructorArgs.Add(new CodeVariableReferenceExpression("binding"));
            constructor.BaseConstructorArgs.Add(new CodeVariableReferenceExpression("remoteAddress"));
            constructor.Statements.Add(new CodeMethodInvokeExpression(new CodeThisReferenceExpression(), "AddKnownTypes"));
            wcfClass.Members.Add(constructor);
            #endregion

            #region Add Methods
            foreach (MethodDefPair methodDef in methodDefs)
            {
                #region Add Synchronous Methods
                methodDecl = CreateMemberMethod(methodDef.Key, methodDef.Value.ParameterDefs, bIsEventInterface, bAllowMultiple);
                methodDecl.Attributes = MemberAttributes.Public;

                methodStmt = new CodeMethodInvokeExpression();
                methodStmt.Method = new CodeMethodReferenceExpression(new CodePropertyReferenceExpression(new CodeBaseReferenceExpression(), "Channel"), methodDecl.Name);

                foreach (CodeParameterDeclarationExpression paramDecl in methodDecl.Parameters)
                {
                    methodStmt.Parameters.Add(new CodeDirectionExpression(paramDecl.Direction, new CodeVariableReferenceExpression(paramDecl.Name)));
                }

                methodDecl.Statements.Add(methodStmt);

                wcfClass.Members.Add(methodDecl);
                #endregion

                if (!methodDef.Value.IsOneWay)
                {
                    #region Add Asynchronous Methods
                    asyncMethodDecls = CreateAsyncMemberMethods(methodDef.Key, methodDef.Value.ParameterDefs, bIsEventInterface, bAllowMultiple);
                    asyncMethodDecls[0].CustomAttributes.Clear();

                    asyncMethodDecls[0].Attributes = MemberAttributes.Public;

                    methodStmt = new CodeMethodInvokeExpression();
                    methodStmt.Method = new CodeMethodReferenceExpression(new CodePropertyReferenceExpression(new CodeBaseReferenceExpression(), "Channel"), asyncMethodDecls[0].Name);

                    foreach (CodeParameterDeclarationExpression paramDecl in asyncMethodDecls[0].Parameters)
                    {
                        methodStmt.Parameters.Add(new CodeDirectionExpression(paramDecl.Direction, new CodeVariableReferenceExpression(paramDecl.Name)));
                    }

                    retStmt = new CodeMethodReturnStatement(methodStmt);
                    asyncMethodDecls[0].Statements.Add(retStmt);

                    asyncMethodDecls[1].Attributes = MemberAttributes.Public;

                    methodStmt = new CodeMethodInvokeExpression();
                    methodStmt.Method = new CodeMethodReferenceExpression(new CodePropertyReferenceExpression(new CodeBaseReferenceExpression(), "Channel"), asyncMethodDecls[1].Name);

                    foreach (CodeParameterDeclarationExpression paramDecl in asyncMethodDecls[1].Parameters)
                    {
                        methodStmt.Parameters.Add(new CodeDirectionExpression(paramDecl.Direction, new CodeVariableReferenceExpression(paramDecl.Name)));
                    }

                    asyncMethodDecls[1].Statements.Add(methodStmt);


                    wcfClass.Members.AddRange(asyncMethodDecls);
                    #endregion
                }
            }
            #endregion

            nameSpace.Types.Add(wcfClass);
        }

        private CodeMemberMethod GenerateKnownTypesMethod(MethodDefDictionary methodDefs)
        {
            CodeMemberMethod method = new CodeMemberMethod();

            #region Generate collection of known types
            Dictionary<string, List<string>> methodKnownTypes = new Dictionary<string, List<string>>();
            List<string> extendedTypes = null;

            foreach (MethodDefPair mdp in methodDefs)
            {
                foreach (KeyValuePair<string, CMASParameterDef> paramDef in mdp.Value.ParameterDefs)
                {
                    List<string> customTypes = m_TypeExtensions.GetCustomizedTypes(GetType(paramDef.Value.ParameterType));

                    if (customTypes != null)
                    {
                        if (extendedTypes == null)
                        {
                            extendedTypes = new List<string>();

                            methodKnownTypes.Add(mdp.Key, extendedTypes);
                        }

                        extendedTypes.AddRange(customTypes);
                    }
                }

                extendedTypes = null;
            }
            #endregion

            #region Generate Method Definition
            method.Name = "AddKnownTypes";
            method.ReturnType = new CodeTypeReference(typeof(void));
            method.Attributes = MemberAttributes.Private;

            if (methodKnownTypes.Count > 0)
            {
                CodeVariableDeclarationStatement varStmt = new CodeVariableDeclarationStatement(
                    new CodeTypeReference(typeof(IEnumerator<OperationDescription>)),
                    "iter",
                    new CodeMethodInvokeExpression(
                    new CodePropertyReferenceExpression(
                      new CodePropertyReferenceExpression(
                        new CodePropertyReferenceExpression(new CodeBaseReferenceExpression(),
                        "Endpoint"),
                      "Contract"),
                    "Operations"),
                  "GetEnumerator")
                );
                method.Statements.Add(varStmt);

                CodeVariableDeclarationStatement boolStmt = new CodeVariableDeclarationStatement(
                  new CodeTypeReference(typeof(bool)), "iterValid", new CodePrimitiveExpression(false));
                method.Statements.Add(boolStmt);

                CodeIterationStatement iterStmt = new CodeIterationStatement();
                iterStmt.InitStatement = new CodeAssignStatement(
                  new CodeVariableReferenceExpression("iterValid"),
                  new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("iter"), "MoveNext")
                );

                iterStmt.IncrementStatement = new CodeAssignStatement(
                  new CodeVariableReferenceExpression("iterValid"),
                  new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("iter"), "MoveNext"));

                iterStmt.TestExpression = new CodeVariableReferenceExpression("iterValid");

                CodeConditionStatement parentIf = null;

                foreach (KeyValuePair<string, List<string>> kvp in methodKnownTypes)
                {
                    CodeConditionStatement innerIf = new CodeConditionStatement();
                    innerIf.Condition = new CodeMethodInvokeExpression(
                      new CodePropertyReferenceExpression(
                        new CodePropertyReferenceExpression(
                          new CodeVariableReferenceExpression("iter")
                          , "Current"),
                        "Name"),
                      "Contains",
                      new CodePrimitiveExpression(kvp.Key));

                    foreach (string knownType in kvp.Value)
                    {
                        Type customType = GetType(knownType);

                        CodeMethodInvokeExpression invokeStmt = new CodeMethodInvokeExpression(
                          new CodePropertyReferenceExpression(
                            new CodePropertyReferenceExpression(
                              new CodeVariableReferenceExpression("iter"),
                              "Current"),
                            "KnownTypes"),
                          "Add",
                          new CodeMethodInvokeExpression(
                            new CodeTypeReferenceExpression(typeof(Type)),
                            "GetType",
                            new CodePrimitiveExpression(customType.AssemblyQualifiedName),
                            new CodePrimitiveExpression(true),
                            new CodePrimitiveExpression(true)));

                        innerIf.TrueStatements.Add(invokeStmt);
                    }

                    if (parentIf != null)
                    {
                        parentIf.FalseStatements.Add(innerIf);
                    }
                    else
                    {
                        iterStmt.Statements.Add(innerIf);
                    }

                    parentIf = innerIf;

                }

                method.Statements.Add(iterStmt);
            }
            #endregion

            return method;
        }

        private void GenerateMethodProxyClasses(ref CodeNamespace nameSpace, string interfaceName, MethodDefDictionary methodDefs, bool bIsEventInterface, bool bAllowMultipleInstances)
        {
            CodeMemberMethod methodDecl;
            CodeMethodInvokeExpression methodStmt;
            CodeConstructor constructor;
            CodeMemberField fieldDecl;
            CodeMemberProperty propertyDecl;
            CodeDirectionExpression direction;
            CodeTypeDeclaration wcfClass;

            foreach (MethodDefPair methodDef in methodDefs)
            {
                #region Create Class
                wcfClass = new CodeTypeDeclaration(string.Format("{0}_{1}_Client", interfaceName, methodDef.Key));
                wcfClass.IsClass = true;

                if (bIsEventInterface)
                {
                    if (!bAllowMultipleInstances)
                    {
                        wcfClass.BaseTypes.Add(new CodeTypeReference(typeof(CMASEventClientProxyBase)));
                    }
                    else
                    {
                        wcfClass.BaseTypes.Add(new CodeTypeReference(typeof(CMASEventMIClientProxyBase)));
                    }
                }
                else
                {
                    wcfClass.BaseTypes.Add(new CodeTypeReference(typeof(CMASClientProxyBase)));
                }

                wcfClass.TypeAttributes = TypeAttributes.Sealed | TypeAttributes.Public;
                wcfClass.CustomAttributes.Add(new CodeAttributeDeclaration("Serializable"));

                fieldDecl = new CodeMemberField(typeof(string), "m_EndpointConfiguration");
                fieldDecl.Attributes = MemberAttributes.Private;
                wcfClass.Members.Add(fieldDecl);

                fieldDecl = new CodeMemberField(string.Format("{0}Client", interfaceName), "m_ClientProxy");
                fieldDecl.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(NonSerializedAttribute))));
                wcfClass.Members.Add(fieldDecl);

                #endregion

                #region Add Constructors
                constructor = new CodeConstructor();
                constructor.Attributes = MemberAttributes.Public;
                constructor.Statements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_EndpointConfiguration"), new CodePrimitiveExpression(null)));
                constructor.Statements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), new CodePrimitiveExpression(null)));
                wcfClass.Members.Add(constructor);

                constructor = new CodeConstructor();
                constructor.Attributes = MemberAttributes.Public;
                constructor.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "endpointConfigurationName"));
                constructor.Statements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_EndpointConfiguration"), new CodeVariableReferenceExpression("endpointConfigurationName")));
                constructor.Statements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), new CodePrimitiveExpression(null)));
                wcfClass.Members.Add(constructor);
                #endregion

                #region Invoke Method
                methodDecl = new CodeMemberMethod();
                methodDecl.Name = "Invoke";
                methodDecl.Attributes = MemberAttributes.Public | MemberAttributes.Override;
                methodDecl.ReturnType = new CodeTypeReference(typeof(void));

                CodeVariableDeclarationStatement varDecl = new CodeVariableDeclarationStatement(string.Format("{0}Client", interfaceName), "clientProxy", new CodePrimitiveExpression(null));
                methodDecl.Statements.Add(varDecl);

                CodeTryCatchFinallyStatement tryCatch = new CodeTryCatchFinallyStatement();
                methodDecl.Statements.Add(tryCatch);

                CodeConditionStatement condStmt = new CodeConditionStatement(new CodeBinaryOperatorExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_EndpointConfiguration"), CodeBinaryOperatorType.IdentityInequality, new CodePrimitiveExpression(null)));

                condStmt.TrueStatements.Add(new CodeAssignStatement(new CodeVariableReferenceExpression("clientProxy"), new CodeObjectCreateExpression(string.Format("{0}Client", interfaceName), new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_EndpointConfiguration"))));

                condStmt.FalseStatements.Add(new CodeAssignStatement(new CodeVariableReferenceExpression("clientProxy"), new CodeObjectCreateExpression(string.Format("{0}Client", interfaceName))));

                tryCatch.TryStatements.Add(condStmt);

                tryCatch.TryStatements.Add(new CodeAssignStatement(new CodePropertyReferenceExpression(new CodePropertyReferenceExpression(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("clientProxy"), "ClientCredentials"), "UserName"), "UserName"), new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), "UserName")));
                tryCatch.TryStatements.Add(new CodeAssignStatement(new CodePropertyReferenceExpression(new CodePropertyReferenceExpression(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("clientProxy"), "ClientCredentials"), "UserName"), "Password"), new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), "Password")));

                methodStmt = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("clientProxy"), methodDef.Key);

                if (bAllowMultipleInstances)
                {
                    direction = new CodeDirectionExpression();
                    direction.Direction = FieldDirection.Ref;
                    direction.Expression = new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ProcessorInstanceId");

                    methodStmt.Parameters.Add(direction);
                }

                foreach (CMASParameterDef paramDef in methodDef.Value.ParameterDefs.Values)
                {
                    fieldDecl = new CodeMemberField(GetCodeTypeReference(paramDef.ParameterType), string.Format("m_{0}", paramDef.ParameterName));
                    fieldDecl.Attributes = MemberAttributes.Private;
                    wcfClass.Members.Add(fieldDecl);

                    propertyDecl = new CodeMemberProperty();
                    propertyDecl.Attributes = MemberAttributes.Public | MemberAttributes.Final;
                    propertyDecl.Name = string.Format("{0}_{1}", paramDef.ParamDirection.ToString(), paramDef.ParameterName);
                    propertyDecl.Type = GetCodeTypeReference(paramDef.ParameterType);
                    propertyDecl.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), string.Format("m_{0}", paramDef.ParameterName))));
                    propertyDecl.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), string.Format("m_{0}", paramDef.ParameterName)), new CodePropertySetValueReferenceExpression()));

                    wcfClass.Members.Add(propertyDecl);

                    direction = new CodeDirectionExpression();

                    switch (paramDef.ParamDirection)
                    {
                        case CMASParameterDef.ParameterDirection.InOut:
                            direction.Direction = FieldDirection.Ref;
                            break;
                        case CMASParameterDef.ParameterDirection.Out:
                            direction.Direction = FieldDirection.Out;
                            break;
                    };

                    direction.Expression = new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), string.Format("m_{0}", paramDef.ParameterName));

                    methodStmt.Parameters.Add(direction);
                }

                if (bIsEventInterface)
                {
                    direction = new CodeDirectionExpression();
                    direction.Direction = FieldDirection.Out;
                    direction.Expression = new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_StateInitData");

                    methodStmt.Parameters.Add(direction);
                }

                tryCatch.TryStatements.Add(methodStmt);

                condStmt = new CodeConditionStatement();
                condStmt.Condition = new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("clientProxy"), CodeBinaryOperatorType.IdentityInequality, new CodePrimitiveExpression(null));

                CodeConditionStatement innerCond = new CodeConditionStatement();
                innerCond.Condition = new CodeBinaryOperatorExpression(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("clientProxy"), "State"), CodeBinaryOperatorType.IdentityEquality, new CodeSnippetExpression("CommunicationState.Opened"));

                methodStmt = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("clientProxy"), "Close");
                innerCond.TrueStatements.Add(methodStmt);

                methodStmt = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("clientProxy"), "Abort");
                innerCond.FalseStatements.Add(methodStmt);

                condStmt.TrueStatements.Add(innerCond);

                tryCatch.FinallyStatements.Add(condStmt);

                wcfClass.Members.Add(methodDecl);

                #endregion

                #region BeginInvoke Method
                methodDecl = new CodeMemberMethod();
                methodDecl.Name = "BeginInvoke";
                methodDecl.Attributes = MemberAttributes.Public | MemberAttributes.Override;
                methodDecl.ReturnType = new CodeTypeReference(typeof(IAsyncResult));

                methodDecl.Parameters.Add(new CodeParameterDeclarationExpression(typeof(AsyncCallback), "asyncCallback"));
                methodDecl.Parameters.Add(new CodeParameterDeclarationExpression(typeof(object), "stateObject"));

                varDecl = new CodeVariableDeclarationStatement(typeof(IAsyncResult), "retval");
                methodDecl.Statements.Add(varDecl);

                if (!methodDef.Value.IsOneWay)
                {
                    condStmt = new CodeConditionStatement();
                    condStmt.Condition = new CodeBinaryOperatorExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), CodeBinaryOperatorType.IdentityInequality, new CodePrimitiveExpression(null));
                    condStmt.TrueStatements.Add(new CodeThrowExceptionStatement(new CodeObjectCreateExpression(typeof(ApplicationException), new CodePrimitiveExpression("Asynchronous method already invoked"))));
                    methodDecl.Statements.Add(condStmt);

                    tryCatch = new CodeTryCatchFinallyStatement();
                    methodDecl.Statements.Add(tryCatch);

                    condStmt = new CodeConditionStatement(new CodeBinaryOperatorExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_EndpointConfiguration"), CodeBinaryOperatorType.IdentityInequality, new CodePrimitiveExpression(null)));

                    condStmt.TrueStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), new CodeObjectCreateExpression(string.Format("{0}Client", interfaceName), new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_EndpointConfiguration"))));

                    condStmt.FalseStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), new CodeObjectCreateExpression(string.Format("{0}Client", interfaceName))));

                    tryCatch.TryStatements.Add(condStmt);

                    tryCatch.TryStatements.Add(new CodeAssignStatement(new CodePropertyReferenceExpression(new CodePropertyReferenceExpression(new CodePropertyReferenceExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), "ClientCredentials"), "UserName"), "UserName"), new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), "UserName")));
                    tryCatch.TryStatements.Add(new CodeAssignStatement(new CodePropertyReferenceExpression(new CodePropertyReferenceExpression(new CodePropertyReferenceExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), "ClientCredentials"), "UserName"), "Password"), new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), "Password")));

                    methodStmt = new CodeMethodInvokeExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), string.Format("Begin{0}", methodDef.Key));

                    if (bAllowMultipleInstances)
                    {
                        direction = new CodeDirectionExpression();
                        direction.Direction = FieldDirection.Ref;
                        direction.Expression = new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ProcessorInstanceId");

                        methodStmt.Parameters.Add(direction);
                    }

                    foreach (CMASParameterDef paramDef in methodDef.Value.ParameterDefs.Values)
                    {
                        if (paramDef.ParamDirection == CMASParameterDef.ParameterDirection.In ||
                            paramDef.ParamDirection == CMASParameterDef.ParameterDirection.InOut)
                        {
                            direction = new CodeDirectionExpression();

                            switch (paramDef.ParamDirection)
                            {
                                case CMASParameterDef.ParameterDirection.InOut:
                                    direction.Direction = FieldDirection.Ref;
                                    break;
                                case CMASParameterDef.ParameterDirection.Out:
                                    direction.Direction = FieldDirection.Out;
                                    break;
                            };

                            direction.Expression = new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), string.Format("m_{0}", paramDef.ParameterName));

                            methodStmt.Parameters.Add(direction);
                        }
                    }

                    direction = new CodeDirectionExpression();
                    direction.Expression = new CodeVariableReferenceExpression("asyncCallback");
                    methodStmt.Parameters.Add(direction);

                    direction = new CodeDirectionExpression();
                    direction.Expression = new CodeVariableReferenceExpression("stateObject");
                    methodStmt.Parameters.Add(direction);

                    tryCatch.TryStatements.Add(new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), methodStmt));

                    CodeCatchClause catchClause = new CodeCatchClause("", new CodeTypeReference(typeof(Exception)));
                    methodStmt = new CodeMethodInvokeExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), "Abort");
                    catchClause.Statements.Add(methodStmt);
                    catchClause.Statements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), new CodePrimitiveExpression(null)));
                    catchClause.Statements.Add(new CodeThrowExceptionStatement());
                    tryCatch.CatchClauses.Add(catchClause);

                    methodDecl.Statements.Add(new CodeMethodReturnStatement(new CodeVariableReferenceExpression("retval")));

                }
                else
                {
                    methodDecl.Statements.Add(new CodeThrowExceptionStatement(new CodeObjectCreateExpression(typeof(NotImplementedException), new CodePrimitiveExpression("Method does not support asynchronous invocation"))));
                }
             

                wcfClass.Members.Add(methodDecl);

                #endregion

                #region EndInvoke Method
                methodDecl = new CodeMemberMethod();
                methodDecl.Name = "EndInvoke";
                methodDecl.Attributes = MemberAttributes.Public | MemberAttributes.Override;
                methodDecl.ReturnType = new CodeTypeReference(typeof(void));

                methodDecl.Parameters.Add(new CodeParameterDeclarationExpression(typeof(IAsyncResult), "asyncResult"));

                if (!methodDef.Value.IsOneWay)
                {
                    condStmt = new CodeConditionStatement();
                    condStmt.Condition = new CodeBinaryOperatorExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), CodeBinaryOperatorType.IdentityEquality, new CodePrimitiveExpression(null));
                    condStmt.TrueStatements.Add(new CodeThrowExceptionStatement(new CodeObjectCreateExpression(typeof(ApplicationException), new CodePrimitiveExpression("Asynchronous method not invoked"))));
                    methodDecl.Statements.Add(condStmt);

                    tryCatch = new CodeTryCatchFinallyStatement();
                    methodDecl.Statements.Add(tryCatch);

                    methodStmt = new CodeMethodInvokeExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), string.Format("End{0}", methodDef.Key));

                    if (bAllowMultipleInstances)
                    {
                        direction = new CodeDirectionExpression();
                        direction.Direction = FieldDirection.Ref;
                        direction.Expression = new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ProcessorInstanceId");

                        methodStmt.Parameters.Add(direction);
                    }

                    foreach (CMASParameterDef paramDef in methodDef.Value.ParameterDefs.Values)
                    {
                        if (paramDef.ParamDirection == CMASParameterDef.ParameterDirection.InOut ||
                            paramDef.ParamDirection == CMASParameterDef.ParameterDirection.Out)
                        {
                            direction = new CodeDirectionExpression();

                            switch (paramDef.ParamDirection)
                            {
                                case CMASParameterDef.ParameterDirection.InOut:
                                    direction.Direction = FieldDirection.Ref;
                                    break;
                                case CMASParameterDef.ParameterDirection.Out:
                                    direction.Direction = FieldDirection.Out;
                                    break;
                            };

                            direction.Expression = new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), string.Format("m_{0}", paramDef.ParameterName));

                            methodStmt.Parameters.Add(direction);
                        }
                    }

                    if (bIsEventInterface)
                    {
                        direction = new CodeDirectionExpression();
                        direction.Direction = FieldDirection.Out;
                        direction.Expression = new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_StateInitData");

                        methodStmt.Parameters.Add(direction);
                    }

                    direction = new CodeDirectionExpression();
                    direction.Expression = new CodeVariableReferenceExpression("asyncResult");
                    methodStmt.Parameters.Add(direction);

                    tryCatch.TryStatements.Add(methodStmt);

                    methodStmt = new CodeMethodInvokeExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), "Close");
                    tryCatch.TryStatements.Add(methodStmt);

                    CodeCatchClause catchClause = new CodeCatchClause();
                    catchClause.CatchExceptionType = new CodeTypeReference(typeof(Exception));
                    methodStmt = new CodeMethodInvokeExpression(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), "Abort");
                    catchClause.Statements.Add(methodStmt);

                    catchClause.Statements.Add(new CodeThrowExceptionStatement());
                    tryCatch.CatchClauses.Add(catchClause);

                    tryCatch.FinallyStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), "m_ClientProxy"), new CodePrimitiveExpression(null)));
                }
                else
                {
                    methodDecl.Statements.Add(new CodeThrowExceptionStatement(new CodeObjectCreateExpression(typeof(NotImplementedException), new CodePrimitiveExpression("Method does not support asynchronous invocation"))));
                }

                wcfClass.Members.Add(methodDecl);

                #endregion

                nameSpace.Types.Add(wcfClass);
            }
        }
        #endregion
    }
}
