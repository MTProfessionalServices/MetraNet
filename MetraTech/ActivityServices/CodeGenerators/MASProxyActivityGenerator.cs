using Microsoft.CSharp;
using System;
using System.CodeDom;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;
using System.Workflow.ComponentModel;

using MetraTech.ActivityServices.Configuration;
using MetraTech.ActivityServices.Services.Common;

namespace MetraTech.ActivityServices.ClientCodeGenerators
{
  using MethodDefDictionary = Dictionary<string, Dictionary<string, CMASParameterDef>>;
  using MethodDefPair = KeyValuePair<string, Dictionary<string, CMASParameterDef>>;
  using MetraTech.ActivityServices.Runtime;
  using System.Data;
  using MetraTech.ActivityServices.Activities;

  public class CMASProxyActivityGenerator : CMASInterfaceGeneratorBase
  {
    #region Members
    private string m_ExtensionName;
    private string m_ServiceAssembly;
    private Dictionary<string, CodeCompileUnit> m_CodeUnits = new Dictionary<string, CodeCompileUnit>();
    
    private bool m_BuildDebug = false;

    private static string m_NameSpaceBase = "MetraTech.";
    private static string m_BasePathFormatString;
    #endregion

    #region Constructor
    public CMASProxyActivityGenerator(string extensionName, string serviceAssembly, bool buildDebug)
    {
      try
      {
        m_Logger = new Logger("Logging\\ActivityServices", "[MASProxyActivityGenerator]");

        m_ExtensionName = extensionName;
        m_ServiceAssembly = serviceAssembly;
        m_BuildDebug = buildDebug;
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception constructing proxy activity generator", e);

        throw e;
      }
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
      get { return string.Format("{0}{1}.ProxyActivities", NameSpaceBase, m_ExtensionName); }
    }

    public string OutputAssembly
    {
        get { return Path.Combine(BasePath, string.Format("{0}.dll", NameSpaceName)); }
    }
    #endregion

    #region Public Methods
    public void AddProxyActivities(CMASConfiguration configFile)
    {
      try
      {
        foreach (CMASEventService interfaceDef in configFile.EventServiceDefs.Values)
        {
          AddMASEventProxyActivity(interfaceDef);
        }

        foreach (CMASProceduralService interfaceDef in configFile.ProceduralServiceDefs.Values)
        {
          AddMASProceduralProxyActivity(interfaceDef);
        }
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception caught adding proxy activities.", e);

        throw e;
      }
    }

    public bool BuildProxyActivities()
    {
      bool retval = false; 

      try
      {
        retval = BuildAssembly();
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception caught building proxy activities.", e);

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

      string snkFileName = string.Format("ProxyActGenKey{0}.snk", System.Diagnostics.Process.GetCurrentProcess().Id);

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
      options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MetraTech.Common.dll"));
      options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "SysContext.Interop.dll"));
      options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MetraTech.ActivityServices.Common.dll"));
      options.ReferencedAssemblies.Add(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "MetraTech.ActivityServices.Activities.dll"));
      options.ReferencedAssemblies.Add(typeof(Activity).Assembly.Location); ;

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

      MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();

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
        string path = Path.Combine(BasePath, "MASProxyActivityCode");

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

    private void AddMASProceduralProxyActivity(CMASProceduralService interfaceDef)
    {
      m_Logger.LogInfo("Adding ActivityServices Proxy Activity for Interface: {0}", interfaceDef.InterfaceName);

      string interfaceName = interfaceDef.InterfaceName;
      string namespaceName = "";

      string[] parts = interfaceDef.InterfaceName.Split('.');

      if (parts.Length > 1)
      {
        interfaceName = parts[parts.Length - 1];
        namespaceName = interfaceDef.InterfaceName.Substring(0, interfaceDef.InterfaceName.LastIndexOf('.'));
      }

      CodeNamespace nameSpace = new CodeNamespace(NameSpaceName);

      nameSpace.Imports.Add(new CodeNamespaceImport("System"));
      nameSpace.Imports.Add(new CodeNamespaceImport("System.Text"));
      nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Common"));
      nameSpace.Imports.Add(new CodeNamespaceImport("System.Workflow.ComponentModel"));

      MethodDefDictionary methodDefs = new MethodDefDictionary();

      foreach (CMASProceduralMethod method in interfaceDef.ProceduralMethods.Values)
      {
        methodDefs.Add(method.MethodName, method.ParameterDefs);
      }

      m_Logger.LogInfo("Adding ActivityServices Procedural Proxy ActivityProxy Activity for NameSpace: {0} and Interface: {1}", namespaceName, interfaceName);
      AddMASProxyActivity(ref nameSpace, namespaceName, interfaceName, methodDefs, false, false);

      CodeCompileUnit interfaceModule = new CodeCompileUnit();
      interfaceModule.Namespaces.Add(nameSpace);

      m_CodeUnits.Add(interfaceDef.InterfaceName, interfaceModule);
    }

    private void AddMASEventProxyActivity(CMASEventService interfaceDef)
    {
      m_Logger.LogInfo("Adding ActivityServices Proxy Activity for Interface: {0}", interfaceDef.InterfaceName);

      string interfaceName = interfaceDef.InterfaceName;
      string namespaceName = "";

      string[] parts = interfaceDef.InterfaceName.Split('.');

      if (parts.Length > 1)
      {
        interfaceName = parts[parts.Length - 1];
        namespaceName = interfaceDef.InterfaceName.Substring(0, interfaceDef.InterfaceName.LastIndexOf('.'));
      }

      CodeNamespace nameSpace = new CodeNamespace(NameSpaceName);

      nameSpace.Imports.Add(new CodeNamespaceImport("System"));
      nameSpace.Imports.Add(new CodeNamespaceImport("System.Text"));
      nameSpace.Imports.Add(new CodeNamespaceImport("MetraTech.ActivityServices.Common"));
      nameSpace.Imports.Add(new CodeNamespaceImport("System.Workflow.ComponentModel"));

      MethodDefDictionary methodDefs = new MethodDefDictionary();

      foreach (CMASEventMethod method in interfaceDef.EventMethods.Values)
      {
        methodDefs.Add(method.MethodName, method.ParameterDefs);
      }

      AddMASProxyActivity(ref nameSpace, namespaceName, interfaceName, methodDefs, true, interfaceDef.AllowMultiple);

      CodeCompileUnit interfaceModule = new CodeCompileUnit();
      interfaceModule.Namespaces.Add(nameSpace);

      m_CodeUnits.Add(interfaceDef.InterfaceName, interfaceModule);
    }

    private void AddMASProxyActivity(ref CodeNamespace nameSpace, string namespaceName, string interfaceName, MethodDefDictionary methodDefs, bool bIsEventInterface, bool bAllowMultiple)
    {
      CodeMemberMethod methodDecl;
      CodeAssignStatement assignStmt;
      CodeMethodInvokeExpression methodStmt;
      CodeConstructor constructor;
      CodeMemberField fieldDecl;
      CodeMemberProperty propertyDecl;
      CodeTypeDeclaration activityClass;
      CodeVariableDeclarationStatement varDecl;
      string propertyName;
      Type propertyType;
      List<CodeAssignStatement> outputStmts = new List<CodeAssignStatement>();

      foreach (MethodDefPair methodDef in methodDefs)
      {
        #region Create Class
        activityClass = new CodeTypeDeclaration(string.Format("{0}_{1}_ClientActivity", interfaceName, methodDef.Key));
        activityClass.IsClass = true;

        if (bIsEventInterface)
        {
          if (!bAllowMultiple)
          {
            activityClass.BaseTypes.Add(new CodeTypeReference(typeof(CMASEventClientActivityBase)));
          }
          else
          {
            activityClass.BaseTypes.Add(new CodeTypeReference(typeof(CMASEventMIClientActivityBase)));
          }
        }
        else
        {
          activityClass.BaseTypes.Add(new CodeTypeReference(typeof(CMASClientActivityBase)));
        }

        activityClass.TypeAttributes = TypeAttributes.Sealed | TypeAttributes.Public;
        #endregion

        #region Add Constructor
        constructor = new CodeConstructor();
        constructor.Attributes = MemberAttributes.Public;
        activityClass.Members.Add(constructor);
        #endregion

        #region Add Execute Method
        methodDecl = new CodeMemberMethod();
        methodDecl.Name = "Execute";
        methodDecl.Attributes = MemberAttributes.Override | MemberAttributes.Family;
        methodDecl.ReturnType = new CodeTypeReference(typeof(ActivityExecutionStatus));
        methodDecl.Parameters.Add(new CodeParameterDeclarationExpression(typeof(ActivityExecutionContext), "executionContext"));

        CodeMethodReferenceExpression methodRef = new CodeMethodReferenceExpression(new CodeVariableReferenceExpression("executionContext"), "GetService");
        methodRef.TypeArguments.Add(new CodeTypeReference(typeof(IMTMASCallService)));

        #region Declare Variables
        varDecl = new CodeVariableDeclarationStatement(typeof(IMTMASCallService), "callSvc", new CodeMethodInvokeExpression(methodRef));
        methodDecl.Statements.Add(varDecl);

        varDecl = new CodeVariableDeclarationStatement(typeof(Dictionary<string, object>), "methodArgs", new CodeObjectCreateExpression(typeof(Dictionary<string, object>)));
        methodDecl.Statements.Add(varDecl);
        #endregion

        #region Add parameters to method args dictionary
        foreach (CMASParameterDef paramDef in methodDef.Value.Values)
        {
          propertyName = string.Format("{0}_{1}", paramDef.ParamDirection.ToString(), paramDef.ParameterName);
          propertyType = GetType(paramDef.ParameterType);

          #region Add DependencyProperty
          fieldDecl = new CodeMemberField(typeof(DependencyProperty), string.Format("{0}Property", propertyName));
          fieldDecl.Attributes = MemberAttributes.Public | MemberAttributes.Static;
          fieldDecl.InitExpression = new CodeMethodInvokeExpression(new CodeTypeReferenceExpression(typeof(DependencyProperty)), "Register", new CodePrimitiveExpression(propertyName), new CodeTypeOfExpression(GetCodeTypeReference(propertyType.AssemblyQualifiedName)), new CodeTypeOfExpression(activityClass.Name));
          activityClass.Members.Add(fieldDecl);

          propertyDecl = new CodeMemberProperty();
          propertyDecl.Attributes = MemberAttributes.Public | MemberAttributes.Final;
          propertyDecl.Name = propertyName;
          propertyDecl.Type = base.GetCodeTypeReference(propertyType.AssemblyQualifiedName);
          propertyDecl.GetStatements.Add(new CodeMethodReturnStatement(new CodeCastExpression(GetCodeTypeReference(propertyType.AssemblyQualifiedName), new CodeMethodInvokeExpression(new CodeThisReferenceExpression(), "GetValue", new CodeFieldReferenceExpression(new CodeTypeReferenceExpression(activityClass.Name), string.Format("{0}Property", propertyName))))));
          propertyDecl.SetStatements.Add(new CodeMethodInvokeExpression(new CodeThisReferenceExpression(), "SetValue", new CodeFieldReferenceExpression(new CodeTypeReferenceExpression(activityClass.Name), string.Format("{0}Property", propertyName)), new CodeVariableReferenceExpression("value")));

          activityClass.Members.Add(propertyDecl);
          #endregion

          methodStmt = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("methodArgs"), "Add", new CodePrimitiveExpression(paramDef.ParameterName), new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), propertyName));
          methodDecl.Statements.Add(methodStmt);

          if (paramDef.ParamDirection != CMASParameterDef.ParameterDirection.In)
          {
            assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), propertyName), new CodeCastExpression(GetCodeTypeReference(propertyType.AssemblyQualifiedName), new CodeIndexerExpression(new CodeVariableReferenceExpression("methodArgs"), new CodePrimitiveExpression(paramDef.ParameterName))));
            outputStmts.Add(assignStmt);
          }
        }

        if (bIsEventInterface)
        {
          methodStmt = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("methodArgs"), "Add", new CodePrimitiveExpression("stateInitData"), new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), "StateInitOutputs"));
          methodDecl.Statements.Add(methodStmt);

          assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), "StateInitOutputs"), new CodeCastExpression(typeof(Dictionary<string,object>), new CodeIndexerExpression(new CodeVariableReferenceExpression("methodArgs"), new CodePrimitiveExpression("stateInitData"))));
          outputStmts.Add(assignStmt);

          if (bAllowMultiple)
          {
            methodStmt = new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("methodArgs"), "Add", new CodePrimitiveExpression("processorInstanceId"), new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), "ProcessorInstanceId"));
            methodDecl.Statements.Add(methodStmt);

            assignStmt = new CodeAssignStatement(new CodePropertyReferenceExpression(new CodeThisReferenceExpression(), "ProcessorInstanceId"), new CodeCastExpression(typeof(Guid), new CodeIndexerExpression(new CodeVariableReferenceExpression("methodArgs"), new CodePrimitiveExpression("processorInstanceId"))));
            outputStmts.Add(assignStmt);
          }
        }
        #endregion

        CodeConditionStatement ifStmt = new CodeConditionStatement();
        ifStmt.Condition = new CodeBinaryOperatorExpression(new CodeVariableReferenceExpression("callSvc"), CodeBinaryOperatorType.IdentityInequality, new CodePrimitiveExpression(null));

        string typeName;
        if (!String.IsNullOrEmpty(namespaceName))
        {
          typeName = string.Format("{0}.{1},{2}.dll", namespaceName, interfaceName, m_ServiceAssembly);
        }
        else
        {
          typeName = string.Format("{0}.{1},{0}.dll", m_ServiceAssembly, interfaceName);
        }
        ifStmt.TrueStatements.Add(new CodeMethodInvokeExpression(new CodeVariableReferenceExpression("callSvc"), "InvokeMASMethod", new CodePrimitiveExpression(typeName), new CodePrimitiveExpression(methodDef.Key), new CodeDirectionExpression(FieldDirection.Ref, new CodeVariableReferenceExpression("methodArgs")))); 

        foreach (CodeAssignStatement stmt in outputStmts)
        {
          ifStmt.TrueStatements.Add(stmt);
        }

        outputStmts.Clear();

        methodDecl.Statements.Add(ifStmt);

        methodDecl.Statements.Add(new CodeMethodReturnStatement(new CodePropertyReferenceExpression(new CodeTypeReferenceExpression(typeof(ActivityExecutionStatus)), "Closed")));
        
        activityClass.Members.Add(methodDecl);
        #endregion

        nameSpace.Types.Add(activityClass);
      }
    }
    #endregion
  }
}
