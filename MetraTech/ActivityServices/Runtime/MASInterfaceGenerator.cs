using System;
using System.Collections.Generic;
using System.Text;
using System.CodeDom;
using System.CodeDom.Compiler;
using Microsoft.CSharp;
using System.IO;
using System.Reflection;
using System.ServiceModel;
using System.Configuration;
using MetraTech.ActivityServices.Configuration;
using MetraTech.ActivityServices.Activities;

namespace MetraTech.ActivityServices.Runtime
{
    using MethodDefDictionary = Dictionary<string, Dictionary<string, CMASParameterDef>>;
    using MethodDefPair = KeyValuePair<string, Dictionary<string, CMASParameterDef>>;
    using MetraTech.ActivityServices.Services.Common;
    using System.Data;
    using System.Xml;
    using System.Transactions;
    using MetraTech.ActivityServices.Common;
    using MetraTech.DomainModel.BaseTypes;
    using MetraTech.BusinessEntity.DataAccess.Metadata;

    internal sealed class CMASInterfaceGenerator : CMASInterfaceGeneratorBase
    {
        #region Members
        private string m_NamespaceName;
        private Dictionary<string, CodeCompileUnit> m_CodeUnits = new Dictionary<string, CodeCompileUnit>();
        #endregion

        #region Constructor
        public CMASInterfaceGenerator(string namespaceName)
        {
            m_NamespaceName = namespaceName;

            m_Logger = new Logger("Logging\\ActivityServices", "[MASInterfaceGenerator]");
        }
        #endregion

        #region Public Methods
        public void AddMASEventInterface(string interfaceName, CMASEventService interfaceDef)
        {
            m_Logger.LogInfo("Adding ActivityServices Interface: {0}", interfaceName);

            CodeNamespace nameSpace = new CodeNamespace(m_NamespaceName);

            nameSpace.Imports.Add(new CodeNamespaceImport("System"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.Text"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.ServiceModel"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.Reflection"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Runtime"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Common"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Services.Common"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.Transactions"));

            if (interfaceDef.IsPageNav)
            {
                AddSetStateEventMethod(ref interfaceDef);
            }

            GenerateEventInterfaceDef(ref nameSpace, interfaceName, interfaceDef);
            GenerateEventInterfaceClass(ref nameSpace, interfaceName, interfaceDef);

            CodeCompileUnit interfaceModule = new CodeCompileUnit();
            interfaceModule.Namespaces.Add(nameSpace);

            m_CodeUnits.Add(interfaceDef.InterfaceName, interfaceModule);
        }

        public void AddMASProceduralInterface(string interfaceName, CMASProceduralService interfaceDef)
        {
            m_Logger.LogInfo("Adding ActivityServices Interface: {0}", interfaceName);

            CodeNamespace nameSpace = new CodeNamespace(m_NamespaceName);

            nameSpace.Imports.Add(new CodeNamespaceImport("System"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.Text"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.ServiceModel"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.Reflection"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Runtime"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Common"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Services.Common"));
            nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech"));
            nameSpace.Imports.Add(new CodeNamespaceImport("System.Transactions"));

            GenerateProceduralInterfaceDef(ref nameSpace, interfaceName, interfaceDef);
            GenerateProceduralInterfaceClass(ref nameSpace, interfaceName, interfaceDef);

            CodeCompileUnit interfaceModule = new CodeCompileUnit();
            interfaceModule.Namespaces.Add(nameSpace);

            m_CodeUnits.Add(interfaceDef.InterfaceName, interfaceModule);
        }

        public Assembly BuildAssembly(string assemblyName, bool bInMemoryOnly)
        {
            m_Logger.LogDebug("Building assembly");

            CSharpCodeProvider compiler = new CSharpCodeProvider();
            CompilerParameters options = new CompilerParameters();
            CompilerResults result = null;

            string snkFileName = string.Format("MASKey{0}.snk", System.Diagnostics.Process.GetCurrentProcess().Id);

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
            options.ReferencedAssemblies.Add(this.GetType().Assembly.Location);
            options.ReferencedAssemblies.Add(typeof(XmlReader).Assembly.Location);
            options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MetraTech.Common.dll"));
            options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "SysContext.Interop.dll"));
            options.ReferencedAssemblies.Add(typeof(Transaction).Assembly.Location);
            options.ReferencedAssemblies.Add(typeof(MASBaseException).Assembly.Location);
            options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MetraTech.ActivityServices.Services.Common.dll"));

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


            if (!CMASHost.HostConfig.PreserveCode || bInMemoryOnly)
            {
                m_Logger.LogDebug("Building in Release Mode");
                #region Compile in Release Mode
                options.GenerateInMemory = true;
                options.TempFiles.KeepFiles = false;
                options.IncludeDebugInformation = false;

                options.OutputAssembly = assemblyName + ".dll";

                CodeCompileUnit[] codeUnits = new CodeCompileUnit[m_CodeUnits.Count];
                m_CodeUnits.Values.CopyTo(codeUnits, 0);

                result = compiler.CompileAssemblyFromDom(options, codeUnits);
                #endregion
            }
            else
            {
                m_Logger.LogDebug("Building in Debug Mode");
                #region Compile in Debug Mode
                string path = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MASCodeGen");
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

                options.OutputAssembly = assemblyName + ".dll";

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

            if (!result.Errors.HasErrors)
            {
                return result.CompiledAssembly;
            }
            else
            {
                m_Logger.LogError("Compilation of ActivityServices interface assembly has failed");

                throw new ApplicationException("Failed to build ActivityServices interface assembly");
            }
        }

        #endregion

        #region Private Methods
        private string GenerateEventDataClass(ref CodeNamespace nameSpace, string interfaceName, string dataTypeName, CMASEventMethod methodDef)
        {
            m_Logger.LogDebug("Generating Event Data Class for method \"{0}\" in interface: \"{1}\"", methodDef.MethodName, interfaceName);

            string eventDataClassName = string.Format("{0}_{1}_EventData", interfaceName, methodDef.MethodName);
            CodeTypeDeclaration wcfEventDataClass = new CodeTypeDeclaration(eventDataClassName);
            wcfEventDataClass.IsClass = true;
            wcfEventDataClass.BaseTypes.Add(new CodeTypeReference(typeof(CMASEventData)));
            wcfEventDataClass.TypeAttributes = TypeAttributes.NestedAssembly;
            wcfEventDataClass.CustomAttributes.Add(new CodeAttributeDeclaration("Serializable"));

            wcfEventDataClass.Members.Add(AddGetQueryPredicateMethod(dataTypeName, methodDef));
            wcfEventDataClass.Members.Add(AddGetTableNameMethod(dataTypeName, methodDef));
            wcfEventDataClass.Members.Add(AddGetIDColumnNameMethod(dataTypeName, methodDef));

            nameSpace.Types.Add(wcfEventDataClass);

            return eventDataClassName;
        }

        private CodeMemberMethod AddGetQueryPredicateMethod(string dataTypeName, CMASEventMethod methodDef)
        {
            m_Logger.LogDebug("Generating GetQueryPredicate method for Event Data class");

            #region Find instance identifier parameter
            Type instanceIdentifierType = null;
            string internalName = "";
            foreach (CMASParameterDef paramDef in methodDef.ParameterDefs.Values)
            {
                if (paramDef.IsInstanceIdentifier)
                {
                    if (instanceIdentifierType == null)
                    {
                        instanceIdentifierType = GetType(paramDef.ParameterType);
                        internalName = paramDef.InternalName;
                    }
                    else
                    {
                        throw new ConfigurationErrorsException(string.Format("Cannot specify more than one instance identifier parameter on method {0}", methodDef.MethodName));
                    }
                }
            }

            if (instanceIdentifierType == null)
            {
                throw new ConfigurationErrorsException(string.Format("Must mark one parameter as the instnace identifier on method {0}", methodDef.MethodName));
            }
            #endregion

            CodeMemberMethod method = new CodeMemberMethod();
            method.Attributes = MemberAttributes.Public | MemberAttributes.Override;
            method.Name = "GetQueryPredicate";
            method.ReturnType = new CodeTypeReference(typeof(string));

            method.Parameters.Add(new CodeParameterDeclarationExpression(typeof(bool), "isOracle"));

            CodeVariableDeclarationStatement varDecl = new CodeVariableDeclarationStatement(typeof(string), "retval", new CodePrimitiveExpression(""));
            method.Statements.Add(varDecl);

            CodeAssignStatement assignStmt;

            if (string.Compare(dataTypeName, "Account", true) == 0)
            {
                if (instanceIdentifierType == typeof(AccountIdentifier))
                {
                    #region Add Code for AccountIdentifier
                    varDecl = new CodeVariableDeclarationStatement(
                        typeof(AccountIdentifier),
                        "id",
                        new CodeCastExpression(typeof(AccountIdentifier),
                            new CodeMethodInvokeExpression(
                                new CodeThisReferenceExpression(),
                                "GetInputItem",
                                new CodePrimitiveExpression(internalName))));
                    method.Statements.Add(varDecl);

                    CodeConditionStatement condStmt = new CodeConditionStatement();
                    condStmt.Condition = new CodeBinaryOperatorExpression(
                        new CodePropertyReferenceExpression(
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"), "AccountID"),
                                "HasValue"),
                        CodeBinaryOperatorType.BooleanAnd,
                        new CodeBinaryOperatorExpression(
                            new CodeBinaryOperatorExpression(
                                new CodeMethodInvokeExpression(
                                    new CodeTypeReferenceExpression(typeof(string)),
                                    "IsNullOrEmpty",
                                    new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("id"), "Username")),
                                CodeBinaryOperatorType.IdentityInequality,
                                new CodePrimitiveExpression(true)),
                            CodeBinaryOperatorType.BooleanAnd,
                            new CodeBinaryOperatorExpression(
                                new CodeMethodInvokeExpression(
                                    new CodeTypeReferenceExpression(typeof(string)),
                                    "IsNullOrEmpty",
                                    new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("id"), "Namespace")),
                                CodeBinaryOperatorType.IdentityInequality,
                                new CodePrimitiveExpression(true))));

                    assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodePrimitiveExpression("id_acc = "));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodePropertyReferenceExpression(
                                    new CodeVariableReferenceExpression("id"),
                                    "AccountID"),
                                    "Value")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression(" AND nm_login = '")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"),
                                "Username")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("' AND nm_space = '")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"),
                                "Namespace")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("'")));
                    condStmt.TrueStatements.Add(assignStmt);

                    CodeConditionStatement innerCond = new CodeConditionStatement();
                    innerCond.Condition = new CodeBinaryOperatorExpression(
                        new CodePropertyReferenceExpression(
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"), "AccountID"),
                                "HasValue"),
                        CodeBinaryOperatorType.IdentityEquality,
                        new CodePrimitiveExpression(true));

                    assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodePrimitiveExpression("id_acc = "));
                    innerCond.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodePropertyReferenceExpression(
                                    new CodeVariableReferenceExpression("id"),
                                    "AccountID"),
                                    "Value")));
                    innerCond.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("nm_login = '")));
                    innerCond.FalseStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"),
                                "Username")));
                    innerCond.FalseStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("' AND nm_space = '")));
                    innerCond.FalseStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"),
                                "Namespace")));
                    innerCond.FalseStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("'")));
                    innerCond.FalseStatements.Add(assignStmt);

                    condStmt.FalseStatements.Add(innerCond);

                    method.Statements.Add(condStmt);
                    #endregion
                }
                else if (instanceIdentifierType.IsSubclassOf(typeof(Account)))
                {
                    #region Add code for Account
                    varDecl = new CodeVariableDeclarationStatement(
                      typeof(Account),
                      "id",
                      new CodeCastExpression(typeof(Account),
                          new CodeMethodInvokeExpression(
                              new CodeThisReferenceExpression(),
                              "GetInputItem",
                              new CodePrimitiveExpression(internalName))));
                    method.Statements.Add(varDecl);

                    CodeConditionStatement condStmt = new CodeConditionStatement();
                    condStmt.Condition = new CodeBinaryOperatorExpression(
                        new CodePropertyReferenceExpression(
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"), "_AccountID"),
                                "HasValue"),
                        CodeBinaryOperatorType.BooleanAnd,
                        new CodeBinaryOperatorExpression(
                            new CodeBinaryOperatorExpression(
                                new CodeMethodInvokeExpression(
                                    new CodeTypeReferenceExpression(typeof(string)),
                                    "IsNullOrEmpty",
                                    new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("id"), "UserName")),
                                CodeBinaryOperatorType.IdentityInequality,
                                new CodePrimitiveExpression(true)),
                            CodeBinaryOperatorType.BooleanAnd,
                            new CodeBinaryOperatorExpression(
                                new CodeMethodInvokeExpression(
                                    new CodeTypeReferenceExpression(typeof(string)),
                                    "IsNullOrEmpty",
                                    new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("id"), "Name_Space")),
                                CodeBinaryOperatorType.IdentityInequality,
                                new CodePrimitiveExpression(true))));

                    assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodePrimitiveExpression("id_acc = "));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodePropertyReferenceExpression(
                                    new CodeVariableReferenceExpression("id"),
                                    "_AccountID"),
                                    "Value")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression(" AND nm_login = '")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"),
                                "UserName")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("' AND nm_space = '")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"),
                                "Name_Space")));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("'")));
                    condStmt.TrueStatements.Add(assignStmt);

                    CodeConditionStatement innerCond = new CodeConditionStatement();
                    innerCond.Condition = new CodeBinaryOperatorExpression(
                        new CodePropertyReferenceExpression(
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"), "_AccountID"),
                                "HasValue"),
                        CodeBinaryOperatorType.IdentityEquality,
                        new CodePrimitiveExpression(true));

                    assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodePrimitiveExpression("id_acc = "));
                    innerCond.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodePropertyReferenceExpression(
                                    new CodeVariableReferenceExpression("id"),
                                    "_AccountID"),
                                    "Value")));
                    innerCond.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("nm_login = '")));
                    innerCond.FalseStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"),
                                "UserName")));
                    innerCond.FalseStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("' AND nm_space = '")));
                    innerCond.FalseStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePropertyReferenceExpression(
                                new CodeVariableReferenceExpression("id"),
                                "Name_Space")));
                    innerCond.FalseStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("retval"),
                        new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodePrimitiveExpression("'")));
                    innerCond.FalseStatements.Add(assignStmt);

                    condStmt.FalseStatements.Add(innerCond);

                    method.Statements.Add(condStmt);
                    #endregion
                }
                else
                {
                    throw new ConfigurationErrorsException(string.Format("Instance identifier parameter for data type 'Account' must of type AccountIdentifier or derived from Account for method {0}", methodDef.MethodName));
                }
            }
            else
            {
                if(instanceIdentifierType.IsSubclassOf(typeof(DataObject)))
                {
                    #region Add BusinessEntity predicate generation
                    varDecl = new CodeVariableDeclarationStatement();
                    varDecl.Type = new CodeTypeReference(instanceIdentifierType, CodeTypeReferenceOptions.GlobalReference);
                    varDecl.Name = "entity";
                    varDecl.InitExpression = new CodeCastExpression(new CodeTypeReference(instanceIdentifierType, CodeTypeReferenceOptions.GlobalReference),
                        new CodeMethodInvokeExpression(
                            new CodeThisReferenceExpression(),
                            "GetInputItem",
                            new CodePrimitiveExpression(internalName)));
                    method.Statements.Add(varDecl);

                    Type businessKeyType = instanceIdentifierType.GetProperty("BusinessKey").PropertyType;
                    PropertyInfo[] props = businessKeyType.GetProperties();
                    PropertyInfo propInfo;

                    varDecl = new CodeVariableDeclarationStatement(
                        new CodeTypeReference(
                            businessKeyType, 
                            CodeTypeReferenceOptions.GlobalReference), 
                        "key", 
                        new CodePrimitiveExpression(null));
                    method.Statements.Add(varDecl);

                    CodeConditionStatement condStmt = new CodeConditionStatement();
                    condStmt.Condition = new CodeBinaryOperatorExpression(
                        new CodePropertyReferenceExpression(
                            new CodeVariableReferenceExpression("entity"),
                            "BusinessKey"),
                            CodeBinaryOperatorType.IdentityInequality,
                            new CodePrimitiveExpression(null));

                    assignStmt = new CodeAssignStatement(
                        new CodeVariableReferenceExpression("key"),
                        new CodePropertyReferenceExpression(
                            new CodeVariableReferenceExpression("entity"),
                            "BusinessKey"));
                    condStmt.TrueStatements.Add(assignStmt);
                    method.Statements.Add(condStmt);

                    condStmt = new CodeConditionStatement();
                    condStmt.Condition =
                        new CodeBinaryOperatorExpression(
                            new CodeBinaryOperatorExpression(
                                new CodeMethodInvokeExpression(
                                        new CodeTypeReferenceExpression(typeof(Guid)),
                                        "Equals",
                                        new CodePropertyReferenceExpression(
                                            new CodeVariableReferenceExpression("entity"),
                                            "Id"),
                                        new CodePropertyReferenceExpression(
                                            new CodeTypeReferenceExpression(typeof(Guid)),
                                            "Empty")),
                                CodeBinaryOperatorType.IdentityEquality,
                                new CodePrimitiveExpression(false)),
                            CodeBinaryOperatorType.BooleanAnd,
                            new CodeBinaryOperatorExpression(
                        new CodePropertyReferenceExpression(
                            new CodeVariableReferenceExpression("entity"),
                            "BusinessKey"),
                            CodeBinaryOperatorType.IdentityInequality,
                            new CodePrimitiveExpression(null)));

                    CodeConditionStatement innerCond = new CodeConditionStatement();
                    innerCond.Condition = new CodeBinaryOperatorExpression(
                                new CodeMethodInvokeExpression(
                                        new CodeTypeReferenceExpression(typeof(Guid)),
                                        "Equals",
                                        new CodePropertyReferenceExpression(
                                            new CodeVariableReferenceExpression("entity"),
                                            "Id"),
                                        new CodePropertyReferenceExpression(
                                            new CodeTypeReferenceExpression(typeof(Guid)),
                                            "Empty")),
                                CodeBinaryOperatorType.IdentityEquality,
                                new CodePrimitiveExpression(false));
                    condStmt.FalseStatements.Add(innerCond);

                    assignStmt = new CodeAssignStatement();
                    assignStmt.Left = new CodeVariableReferenceExpression("retval");
                    assignStmt.Right = new CodeBinaryOperatorExpression(
                        new CodeVariableReferenceExpression("retval"),
                        CodeBinaryOperatorType.Add,
                        new CodeSnippetExpression(
                            string.Format(
                                "\"{0} = \" + EncodeGuid(entity.Id, isOracle) + \" AND \"",
                                Entity.GetIdColumnName(instanceIdentifierType.FullName))));
                    condStmt.TrueStatements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement();
                    assignStmt.Left = new CodeVariableReferenceExpression("retval");
                    assignStmt.Right = new CodeBinaryOperatorExpression(
                        new CodeVariableReferenceExpression("retval"),
                        CodeBinaryOperatorType.Add,
                        new CodeSnippetExpression(
                            string.Format(
                                "\"{0} = \" + EncodeGuid(entity.Id, isOracle)",
                                Entity.GetIdColumnName(instanceIdentifierType.FullName))));
                    innerCond.TrueStatements.Add(assignStmt);

                    for (int i = 0; i < props.Length - 1; i++)
                    {
                        propInfo = props[i];

                        // Special case this prop as it is not really a key prop
                        if (propInfo.Name != "EntityFullName")
                        {
                            assignStmt = new CodeAssignStatement();
                            assignStmt.Left = new CodeVariableReferenceExpression("retval");
                            assignStmt.Right = new CodeBinaryOperatorExpression(
                                new CodeVariableReferenceExpression("retval"),
                                CodeBinaryOperatorType.Add,
                                new CodeSnippetExpression(
                                    string.Format(
                                        "\"{0} = {1}\" + {2} + \"{1} AND \"",
                                        Property.GetColumnName(propInfo.Name),
                                        (IncludeQuote(propInfo.PropertyType.FullName) ? "'" : ""),
                                        (propInfo.PropertyType != typeof(Guid) ?
                                            string.Format("key.{0}", propInfo.Name) :
                                            string.Format("EncodeGuid(key.{0}, isOracle)", propInfo.Name)))));
                            condStmt.TrueStatements.Add(assignStmt);
                            innerCond.FalseStatements.Add(assignStmt);
                        }
                    }

                    propInfo = props[props.Length - 1];

                    // Special case this prop as it is not really a key prop
                    if (propInfo.Name != "EntityFullName")
                    {
                        assignStmt = new CodeAssignStatement();
                        assignStmt.Left = new CodeVariableReferenceExpression("retval");
                        assignStmt.Right = new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodeSnippetExpression(
                                string.Format(
                                    "\"{0} = {1}\" + key.{2} + \"{1}\"",
                                    Property.GetColumnName(propInfo.Name),
                                    (IncludeQuote(propInfo.PropertyType.FullName) ? "'" : ""),
                                    propInfo.Name)));
                        condStmt.TrueStatements.Add(assignStmt);
                        innerCond.FalseStatements.Add(assignStmt);
                    }

                    method.Statements.Add(condStmt);
                    #endregion
                }
                else if (instanceIdentifierType.IsSubclassOf(typeof(BusinessKey)))
                {
                    #region Add BusinessKey predicate generation
                    varDecl = new CodeVariableDeclarationStatement(
                        new CodeTypeReference(instanceIdentifierType, CodeTypeReferenceOptions.GlobalReference),
                        "key",
                        new CodeCastExpression(new CodeTypeReference(instanceIdentifierType, CodeTypeReferenceOptions.GlobalReference),
                            new CodeMethodInvokeExpression(
                                new CodeThisReferenceExpression(),
                                "GetInputItem",
                                new CodePrimitiveExpression(internalName))));
                    method.Statements.Add(varDecl);

                    PropertyInfo[] props = instanceIdentifierType.GetProperties();

                    PropertyInfo propInfo;

                    for (int i = 0; i < props.Length - 1; i++)
                    {
                        propInfo = props[i];

                        // Special case this prop as it is not really a key prop
                        if (propInfo.Name != "EntityFullName")
                        {
                            assignStmt = new CodeAssignStatement();
                            assignStmt.Left = new CodeVariableReferenceExpression("retval");
                            assignStmt.Right = new CodeBinaryOperatorExpression(
                                new CodeVariableReferenceExpression("retval"),
                                CodeBinaryOperatorType.Add,
                                new CodeSnippetExpression(
                                    string.Format(
                                        "\"{0} = {1}\" + key.{2} + \"{1} AND \"",
                                        Property.GetColumnName(propInfo.Name),
                                        (IncludeQuote(propInfo.PropertyType.FullName) ? "'" : ""),
                                        propInfo.Name)));
                            method.Statements.Add(assignStmt);
                        }
                    }

                    propInfo = props[props.Length - 1];

                    // Special case this prop as it is not really a key prop
                    if (propInfo.Name != "EntityFullName")
                    {
                        assignStmt = new CodeAssignStatement();
                        assignStmt.Left = new CodeVariableReferenceExpression("retval");
                        assignStmt.Right = new CodeBinaryOperatorExpression(
                            new CodeVariableReferenceExpression("retval"),
                            CodeBinaryOperatorType.Add,
                            new CodeSnippetExpression(
                                string.Format(
                                    "\"{0} = {1}\" + key.{2} + \"{1}\"",
                                    Property.GetColumnName(propInfo.Name),
                                    (IncludeQuote(propInfo.PropertyType.FullName) ? "'" : ""),
                                    propInfo.Name)));
                        method.Statements.Add(assignStmt);
                    }
                    #endregion
                }
                else
                {
                    throw new ConfigurationErrorsException(string.Format("Instance identifier parameter for BusinessEntity data type must be of BusinessEntity or BusinessKey data type for method {0}", methodDef.MethodName));
                }

                //foreach(KeyValuePair<string, string> kvp in businessKeys)
                //{
                //    assignStmt = new CodeAssignStatement();
                //    assignStmt.Left = new CodeVariableReferenceExpression("retval");

                //    CodeBinaryOperatorExpression binaryOp = new CodeBinaryOperatorExpression();
                //    binaryOp.Left = new CodeVariableReferenceExpression("retval");
                //    binaryOp.Operator = CodeBinaryOperatorType.Add;

                //    CodeBinaryOperatorExpression innerOp = new CodeBinaryOperatorExpression();
                //    innerOp.Left = new CodePrimitiveExpression(string.Format("{0} = {1}id.{2}{1}", kvp.Key, IncludeQuote(
                //}
            }

            //bool firstElementAdded = false;
            //foreach (CMASParameterDef paramDef in methodDef.ParameterDefs.Values)
            //{
            //    if (paramDef.UniqueKeyFieldName != null && paramDef.UniqueKeyFieldName.Length > 0)
            //    {
            //        if (firstElementAdded)
            //        {
            //            assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("retval"), CodeBinaryOperatorType.Add, new CodePrimitiveExpression(" AND ")));
            //            method.Statements.Add(assignStmt);
            //        }

            //        assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("retval"), CodeBinaryOperatorType.Add, new CodePrimitiveExpression(paramDef.UniqueKeyFieldName)));
            //        method.Statements.Add(assignStmt);

            //        assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("retval"), CodeBinaryOperatorType.Add, new CodePrimitiveExpression("=")));
            //        method.Statements.Add(assignStmt);

            //        if (IncludeQuote(paramDef.ParameterType))
            //        {
            //            assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("retval"), CodeBinaryOperatorType.Add, new CodePrimitiveExpression("'")));
            //            method.Statements.Add(assignStmt);
            //        }

            //        assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("retval"), CodeBinaryOperatorType.Add, new CodeMethodInvokeExpression(new CodeThisReferenceExpression(), "GetInputItem", new CodePrimitiveExpression(paramDef.InternalName))));
            //        method.Statements.Add(assignStmt);

            //        if (IncludeQuote(paramDef.ParameterType))
            //        {
            //            assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("retval"), CodeBinaryOperatorType.Add, new CodePrimitiveExpression("'")));
            //            method.Statements.Add(assignStmt);
            //        }

            //        firstElementAdded = true;
            //    }
            //}

            CodeMethodReturnStatement retStmt = new CodeMethodReturnStatement(new CodeVariableReferenceExpression("retval"));
            method.Statements.Add(retStmt);

            return method;
        }

        private CodeMemberMethod AddGetTableNameMethod(string dataTypeName, CMASEventMethod methodDef)
        {
            m_Logger.LogDebug("Generating GetTableName method for Event Data class");

            Type instanceIdentifierType = null;
            #region Find instance identifier parameter
            foreach (CMASParameterDef paramDef in methodDef.ParameterDefs.Values)
            {
                if (paramDef.IsInstanceIdentifier)
                {
                    if (instanceIdentifierType == null)
                    {
                        instanceIdentifierType = GetType(paramDef.ParameterType);
                    }
                    else
                    {
                        throw new ConfigurationErrorsException(string.Format("Cannot specify more than one instance identifier parameter on method {0}", methodDef.MethodName));
                    }
                }
            }

            if (instanceIdentifierType == null)
            {
                throw new ConfigurationErrorsException(string.Format("Must mark one parameter as the instnace identifier on method {0}", methodDef.MethodName));
            }
            #endregion

            string tableName = "";
            if (string.Compare(dataTypeName, "Account", true) == 0)
            {
                if (instanceIdentifierType != typeof(AccountIdentifier) &&
                    !instanceIdentifierType.IsSubclassOf(typeof(Account)))
                {
                    throw new ConfigurationErrorsException(string.Format("Instance identifier parameter for data type 'Account' must of type AccountIdentifier or derived from Account for method {0}", methodDef.MethodName));
                }

                tableName = "t_account_mapper";
            }
            else
            {
                Type dataType = GetType(dataTypeName);
                tableName = Entity.GetTableName(dataType.FullName);
            }

            CodeMemberMethod method = new CodeMemberMethod();
            method.Attributes = MemberAttributes.Public | MemberAttributes.Override;
            method.Name = "GetTableName";
            method.ReturnType = new CodeTypeReference(typeof(string));

            CodeVariableDeclarationStatement varDecl = new CodeVariableDeclarationStatement(typeof(string), "retval", new CodePrimitiveExpression(""));
            method.Statements.Add(varDecl);

            CodeAssignStatement assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodePrimitiveExpression(tableName));
            method.Statements.Add(assignStmt);

            CodeMethodReturnStatement retStmt = new CodeMethodReturnStatement(new CodeVariableReferenceExpression("retval"));
            method.Statements.Add(retStmt);

            return method;

        }

        private CodeMemberMethod AddGetIDColumnNameMethod(string dataTypeName, CMASEventMethod methodDef)
        {
            m_Logger.LogDebug("Generating GetIDColumnName method for Event Data class");

            Type instanceIdentifierType = null;
            #region Find instance identifier parameter
            foreach (CMASParameterDef paramDef in methodDef.ParameterDefs.Values)
            {
                if (paramDef.IsInstanceIdentifier)
                {
                    if (instanceIdentifierType == null)
                    {
                        instanceIdentifierType = GetType(paramDef.ParameterType);
                    }
                    else
                    {
                        throw new ConfigurationErrorsException(string.Format("Cannot specify more than one instance identifier parameter on method {0}", methodDef.MethodName));
                    }
                }
            }

            if (instanceIdentifierType == null)
            {
                throw new ConfigurationErrorsException(string.Format("Must mark one parameter as the instance identifier on method {0}", methodDef.MethodName));
            }
            #endregion

            string columnName = "";
            if (string.Compare(dataTypeName, "Account", true) == 0)
            {
                if (instanceIdentifierType != typeof(AccountIdentifier) &&
                    !instanceIdentifierType.IsSubclassOf(typeof(Account)))
                {
                    throw new ConfigurationErrorsException(string.Format("Instance identifier parameter for data type 'Account' must of type AccountIdentifier or derived from Account for method {0}", methodDef.MethodName));
                }

                columnName = "id_acc";
            }
            else
            {
                Type dataType = GetType(dataTypeName);
                columnName = Entity.GetIdColumnName(dataType.FullName);
            }

            CodeMemberMethod method = new CodeMemberMethod();
            method.Attributes = MemberAttributes.Public | MemberAttributes.Override;
            method.Name = "GetIDColumnName";
            method.ReturnType = new CodeTypeReference(typeof(string));

            CodeVariableDeclarationStatement varDecl = new CodeVariableDeclarationStatement(typeof(string), "retval", new CodePrimitiveExpression(""));
            method.Statements.Add(varDecl);

            CodeAssignStatement assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("retval"), new CodePrimitiveExpression(columnName));
            method.Statements.Add(assignStmt);

            CodeMethodReturnStatement retStmt = new CodeMethodReturnStatement(new CodeVariableReferenceExpression("retval"));
            method.Statements.Add(retStmt);

            return method;
        }

        private bool IncludeQuote(string parameterType)
        {
            bool retval = false;

            switch (parameterType)
            {
                case "System.String":
                case "System.DateTime":
                case "System.Time":
                case "System.boolean":
                    retval = true;
                    break;
            }

            return retval;
        }

        private CodeExpression GetDefaultValueStatement(string parameterType)
        {
            CodeExpression retval = null;

            switch (parameterType)
            {
                //case "System.String":
                //  retval = new CodePrimitiveExpression("");
                //  break;

                case "System.DateTime":
                    retval = new CodePropertyReferenceExpression(new CodeTypeReferenceExpression(typeof(DateTime)), "MinValue");
                    break;

                case "System.Int32":
                case "System.Int64":
                case "System.Int16":
                case "System.Decimal":
                case "System.Double":
                case "System.Byte":
                    retval = new CodePrimitiveExpression(0);
                    break;

                case "System.Boolean":
                    retval = new CodePrimitiveExpression(false);
                    break;

                //case "System.Char":
                //  retval = new CodePrimitiveExpression(Char.MinValue);
                //  break;

                //case System.


                default:
                    retval = new CodePrimitiveExpression(null);
                    break;
            };

            return retval;
        }

        private void GenerateEventInterfaceClass(ref CodeNamespace nameSpace, string interfaceName, CMASEventService interfaceDef)
        {
            m_Logger.LogDebug("Generating Event Interface Class: {0}", interfaceName);

            CodeMemberMethod method1;
            CodeVariableDeclarationStatement varDecl;
            CodeAssignStatement assignStmt;
            CodeMethodInvokeExpression methodStmt;
            string eventDataClassName;

            CodeTypeDeclaration wcfClass = new CodeTypeDeclaration(interfaceName);
            wcfClass.IsClass = true;
            wcfClass.BaseTypes.Add(new CodeTypeReference(typeof(CMASServiceBase)));
            wcfClass.BaseTypes.Add(new CodeTypeReference("I" + interfaceName, 0));
            wcfClass.Attributes = MemberAttributes.Public;

            foreach (CMASEventMethod method in interfaceDef.EventMethods.Values)
            {
                m_Logger.LogDebug("Generating Event Interface Class Method Definition: {0}", method.MethodName);

                eventDataClassName = GenerateEventDataClass(ref nameSpace, interfaceName, interfaceDef.DataTypeName, method);

                method1 = CreateMemberMethod(method.MethodName, method.ParameterDefs, true, interfaceDef.AllowMultiple);
                method1.Attributes = MemberAttributes.Public;
                //method1.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(OperationBehaviorAttribute)), new CodeAttributeArgument("TransactionScopeRequired", new CodePrimitiveExpression(true))));

                foreach (string reqCap in method.RequiredCapabilities)
                {
                    method1.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(OperationCapabilityAttribute)), new CodeAttributeArgument(new CodePrimitiveExpression(reqCap))));
                }

                varDecl = new CodeVariableDeclarationStatement(new CodeTypeReference(typeof(Logger)), "logger", new CodeObjectCreateExpression(new CodeTypeReference(typeof(Logger)), new CodeExpression[] { new CodePrimitiveExpression("[ActivityServices WCF Interface]") }));
                method1.Statements.Add(varDecl);

                CodeMethodInvokeExpression invoke = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("logger"), "LogInfo", new CodeExpression[] { new CodePrimitiveExpression("Event received on {0} method of {1} interface"), new CodePrimitiveExpression(method.MethodName), new CodePrimitiveExpression(interfaceDef.InterfaceName) });
                method1.Statements.Add(invoke);

                #region Initialize Out parameters
                foreach (CMASParameterDef param in method.ParameterDefs.Values)
                {
                    if (param.ParamDirection == CMASParameterDef.ParameterDirection.Out)
                    {
                        assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression(param.ParameterName), GetDefaultValueStatement(param.ParameterType));
                        method1.Statements.Add(assignStmt);
                    }
                }

                assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("stateInitData"), new CodePrimitiveExpression(null));
                method1.Statements.Add(assignStmt);
                #endregion

                varDecl = new CodeVariableDeclarationStatement(new CodeTypeReference(typeof(CMASEventData)), "eventData", new CodeObjectCreateExpression(new CodeTypeReference(eventDataClassName), new CodeExpression[] { }));
                method1.Statements.Add(varDecl);

                assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "DataTypeName"), new CodePrimitiveExpression(interfaceDef.DataTypeName));
                method1.Statements.Add(assignStmt);

                assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "EventName"), new CodePrimitiveExpression(method.EventName));
                method1.Statements.Add(assignStmt);

                assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "WorkflowTypeName"), new CodePrimitiveExpression(interfaceDef.WorkflowType.FullTypeName));
                method1.Statements.Add(assignStmt);

                assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "WorkflowAssembly"), new CodePrimitiveExpression(interfaceDef.WorkflowType.AssemblyName));
                method1.Statements.Add(assignStmt);

                assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "XomlFile"), new CodePrimitiveExpression(interfaceDef.WorkflowType.XOMLFile));
                method1.Statements.Add(assignStmt);

                if (interfaceDef.AllowMultiple)
                {
                    assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "AllowMultipleInstances"), new CodePrimitiveExpression(true));
                    method1.Statements.Add(assignStmt);

                    assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "ProcessorInstanceId"), new CodeVariableReferenceExpression("processorInstanceId"));
                    method1.Statements.Add(assignStmt);
                }

                foreach (CMASParameterDef param in method.ParameterDefs.Values)
                {
                    if (param.ParamDirection == CMASParameterDef.ParameterDirection.In || param.ParamDirection == CMASParameterDef.ParameterDirection.InOut)
                    {
                        methodStmt = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("eventData"), "SetInputItem", new CodeExpression[] { new CodePrimitiveExpression(param.InternalName), new CodeVariableReferenceExpression(param.ParameterName) });
                        method1.Statements.Add(methodStmt);
                    }
                }

                varDecl = new CodeVariableDeclarationStatement(typeof(CMASEventProcessor), "processor", new CodeObjectCreateExpression(typeof(CMASEventProcessor), new CodeExpression[] { }));
                method1.Statements.Add(varDecl);

                method1.Statements.Add(new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("processor"), "Process", new CodeExpression[] { new CodeDirectionExpression(FieldDirection.Ref, new CodeVariableReferenceExpression("eventData")), new CodeDirectionExpression(FieldDirection.Out, new CodeVariableReferenceExpression("stateInitData")) }));

                if (interfaceDef.AllowMultiple)
                {
                    assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("processorInstanceId"), new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "ProcessorInstanceId"));
                    method1.Statements.Add(assignStmt);
                }

                foreach (CMASParameterDef param in method.ParameterDefs.Values)
                {
                    if (param.ParamDirection == CMASParameterDef.ParameterDirection.InOut || param.ParamDirection == CMASParameterDef.ParameterDirection.Out)
                    {
                        assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression(param.ParameterName), new CodeCastExpression(new CodeTypeReference(GetType(param.ParameterType), CodeTypeReferenceOptions.GlobalReference), new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("eventData"), "GetOutputItem", new CodeExpression[] { new CodePrimitiveExpression(param.InternalName) })));
                        method1.Statements.Add(assignStmt);
                    }
                }

                CodeConditionStatement condStmt = new CodeConditionStatement();
                condStmt.Condition = new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("stateInitData"), CodeBinaryOperatorType.IdentityEquality, new CodePrimitiveExpression(null));
                assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression("stateInitData"), new CodeObjectCreateExpression(typeof(Dictionary<string, object>)));
                condStmt.TrueStatements.Add(assignStmt);
                method1.Statements.Add(condStmt);

                methodStmt = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("stateInitData"), "Add", new CodePrimitiveExpression("InterfaceName"), new CodePrimitiveExpression(interfaceDef.InterfaceName));
                method1.Statements.Add(methodStmt);

                wcfClass.Members.Add(method1);
            }

            nameSpace.Types.Add(wcfClass);
        }

        private void GenerateProceduralInterfaceClass(ref CodeNamespace nameSpace, string interfaceName, CMASProceduralService interfaceDef)
        {
            m_Logger.LogDebug("Generating Procedural Interface Class: {0}", interfaceName);

            CodeMemberMethod method1;
            CodeVariableDeclarationStatement varDecl;
            CodeAssignStatement assignStmt;
            CodeMethodInvokeExpression methodStmt;

            CodeTypeDeclaration wcfClass = new CodeTypeDeclaration(interfaceName);
            wcfClass.IsClass = true;
            wcfClass.BaseTypes.Add(new CodeTypeReference(typeof(CMASServiceBase)));
            wcfClass.BaseTypes.Add(new CodeTypeReference("I" + interfaceName, 0));
            wcfClass.Attributes = MemberAttributes.Public;
            wcfClass.CustomAttributes.Add(
              new CodeAttributeDeclaration("ServiceBehavior",
                new CodeAttributeArgument("IncludeExceptionDetailInFaults", new CodeSnippetExpression("true")),
                new CodeAttributeArgument("ConcurrencyMode", new CodeSnippetExpression("ConcurrencyMode.Multiple")),
                new CodeAttributeArgument("InstanceContextMode", new CodeSnippetExpression("InstanceContextMode.Single"))));

            foreach (CMASProceduralMethod method in interfaceDef.ProceduralMethods.Values)
            {
                m_Logger.LogDebug("Generating Procedural Interface Class Method Definition: {0}", method.MethodName);

                method1 = CreateMemberMethod(method.MethodName, method.ParameterDefs, false, false);
                method1.Attributes = MemberAttributes.Public;
                //method1.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(OperationBehaviorAttribute)), new CodeAttributeArgument("TransactionScopeRequired", new CodePrimitiveExpression(true))));

                foreach (string reqCap in method.RequiredCapabilities)
                {
                    method1.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(OperationCapabilityAttribute)), new CodeAttributeArgument(new CodePrimitiveExpression(reqCap))));
                }

                varDecl = new CodeVariableDeclarationStatement(new CodeTypeReference(typeof(Logger)), "logger", new CodeObjectCreateExpression(new CodeTypeReference(typeof(Logger)), new CodeExpression[] { new CodePrimitiveExpression("[ActivityServices WCF Interface]") }));
                method1.Statements.Add(varDecl);

                CodeMethodInvokeExpression invoke = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("logger"), "LogInfo", new CodeExpression[] { new CodePrimitiveExpression("Request received on {0} method of {1} interface"), new CodePrimitiveExpression(method.MethodName), new CodePrimitiveExpression(interfaceDef.InterfaceName) });
                method1.Statements.Add(invoke);

                #region Initialize Out parameters
                foreach (CMASParameterDef param in method.ParameterDefs.Values)
                {
                    if (param.ParamDirection == CMASParameterDef.ParameterDirection.Out)
                    {
                        assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression(param.ParameterName), GetDefaultValueStatement(param.ParameterType));
                        method1.Statements.Add(assignStmt);
                    }
                }
                #endregion

                varDecl = new CodeVariableDeclarationStatement(new CodeTypeReference(typeof(CMASRequestData)), "eventData", new CodeObjectCreateExpression(new CodeTypeReference(typeof(CMASRequestData)), new CodeExpression[] { }));
                method1.Statements.Add(varDecl);

                assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "WorkflowTypeName"), new CodePrimitiveExpression(method.WorkflowType.FullTypeName));
                method1.Statements.Add(assignStmt);

                assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "WorkflowAssembly"), new CodePrimitiveExpression(method.WorkflowType.AssemblyName));
                method1.Statements.Add(assignStmt);

                assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeVariableReferenceExpression("eventData"), "XomlFile"), new CodePrimitiveExpression(method.WorkflowType.XOMLFile));
                method1.Statements.Add(assignStmt);

                foreach (CMASParameterDef param in method.ParameterDefs.Values)
                {
                    if (param.ParamDirection == CMASParameterDef.ParameterDirection.In || param.ParamDirection == CMASParameterDef.ParameterDirection.InOut)
                    {
                        methodStmt = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("eventData"), "SetInputItem", new CodeExpression[] { new CodePrimitiveExpression(param.InternalName), new CodeVariableReferenceExpression(param.ParameterName) });
                        method1.Statements.Add(methodStmt);
                    }
                }

                varDecl = new CodeVariableDeclarationStatement(typeof(CMASProceduralProcessor), "processor", new CodeObjectCreateExpression(typeof(CMASProceduralProcessor), new CodeExpression[] { }));
                method1.Statements.Add(varDecl);

                method1.Statements.Add(new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("processor"), "Process", new CodeExpression[] { new CodeDirectionExpression(FieldDirection.Ref, new CodeVariableReferenceExpression("eventData")) }));

                foreach (CMASParameterDef param in method.ParameterDefs.Values)
                {
                    if (param.ParamDirection == CMASParameterDef.ParameterDirection.InOut || param.ParamDirection == CMASParameterDef.ParameterDirection.Out)
                    {
                        assignStmt = new CodeAssignStatement(new CodeVariableReferenceExpression(param.ParameterName), new CodeCastExpression(new CodeTypeReference(GetType(param.ParameterType), CodeTypeReferenceOptions.GlobalReference), new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("eventData"), "GetOutputItem", new CodeExpression[] { new CodePrimitiveExpression(param.InternalName) })));
                        method1.Statements.Add(assignStmt);
                    }
                }

                wcfClass.Members.Add(method1);
            }

            nameSpace.Types.Add(wcfClass);
        }
        #endregion
    }
}
