using System;
using System.CodeDom;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using MetraTech.ActivityServices.Configuration;
using System.Reflection;

namespace MetraTech.ActivityServices.Runtime
{
  using MethodDefDictionary = Dictionary<string, MASMethodInfo>;
  using MethodDefPair = KeyValuePair<string, MASMethodInfo>;
  using System.ServiceModel;
    using System.IO;

  public struct MASMethodInfo
  {
    // Current version of MS Workflow Foundation does not support flowing transactions into workflows
    // Commenting out capability until they fix the problem.
    //public bool AllowTransactionFlow;
    public string FaultType;
    public Dictionary<string, CMASParameterDef> ParameterDefs;

    public bool IsOneWay;
  }

  public abstract class CMASInterfaceGeneratorBase : IDisposable
  {
    #region Protected Members
    protected Logger m_Logger;

    protected static ResolveEventHandler m_ResolveEventHandler;
    protected static Dictionary<string, Assembly> m_LoadedAssemblies = new Dictionary<string, Assembly>();
    #endregion

    static CMASInterfaceGeneratorBase()
    {
      m_ResolveEventHandler = new ResolveEventHandler(CurrentDomain_AssemblyResolve);
    }

    public CMASInterfaceGeneratorBase()
    {
      // Add an AssemblyResolve handler so that we can handle looking up assemblies in the
      // Extensions folder tree
      
      AppDomain.CurrentDomain.AssemblyResolve += m_ResolveEventHandler;
    }

    ~CMASInterfaceGeneratorBase()
    {
      Dispose();
    }

    #region Protected Methods
    protected CodeMemberMethod CreateMemberMethod(string methodName, Dictionary<string, CMASParameterDef> paramDefs, bool bIsEventInterface, bool bAllowMultipleInstances)
    {
      if (!bIsEventInterface && bAllowMultipleInstances)
      {
        throw new ConfigurationErrorsException("The AllowMultipleInstances flag cannot be set to true if the EventInterface flag is not");
      }

      CodeMemberMethod methodDecl = new CodeMemberMethod();
      methodDecl.Name = methodName;

      methodDecl.ReturnType = new CodeTypeReference(typeof(void));

      CodeParameterDeclarationExpression paramDecl;

      if (bAllowMultipleInstances)
      {
        paramDecl = new CodeParameterDeclarationExpression(typeof(Guid), "processorInstanceId");
        paramDecl.Direction = FieldDirection.Ref;
        methodDecl.Parameters.Add(paramDecl);
      }

      foreach (CMASParameterDef param in paramDefs.Values)
      {
          CodeTypeReference cRef = GetCodeTypeReference(param.ParameterType);

          paramDecl = new CodeParameterDeclarationExpression(cRef, param.ParameterName);

        switch (param.ParamDirection)
        {
          case CMASParameterDef.ParameterDirection.InOut:
            paramDecl.Direction = FieldDirection.Ref;
            break;
          case CMASParameterDef.ParameterDirection.Out:
            paramDecl.Direction = FieldDirection.Out;
            break;
        };

        methodDecl.Parameters.Add(paramDecl);
      }

      CodeParameterDeclarationExpression interfaceParam;

      if (bIsEventInterface)
      {
        interfaceParam = new CodeParameterDeclarationExpression(typeof(Dictionary<string, object>), "stateInitData");
        interfaceParam.Direction = FieldDirection.Out;

        methodDecl.Parameters.Add(interfaceParam);
      }

      return methodDecl;
    }

    protected CodeTypeReference GetCodeTypeReference(string paramTypeString)
    {
        Type paramType = GetType(paramTypeString);

        CodeTypeReference cRef = null;
        if (!paramType.IsGenericType)
        {
            cRef = new CodeTypeReference(paramType, CodeTypeReferenceOptions.GlobalReference);
        }
        else
        {
            cRef = new CodeTypeReference();
            cRef.BaseType = string.Format("global::{0}.{1}", paramType.Namespace, paramType.Name);

            Type[] genTypes = paramType.GetGenericArguments();

            foreach (Type genType in genTypes)
            {
                Type tmp = Type.GetType(genType.AssemblyQualifiedName);
                cRef.TypeArguments.Add(new CodeTypeReference(tmp, CodeTypeReferenceOptions.GlobalReference));
            }
        }

        return cRef;
    }

    protected void GenerateEventInterfaceDef(ref CodeNamespace nameSpace, string interfaceName, CMASEventService interfaceDef)
    {

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

      GenerateInterfaceDef(ref nameSpace, interfaceName, methodDefs, interfaceDef.SupportedChildTypes, true, interfaceDef.AllowMultiple);
    }

    protected void GenerateProceduralInterfaceDef(ref CodeNamespace nameSpace, string interfaceName, CMASProceduralService interfaceDef)
    {
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

      GenerateInterfaceDef(ref nameSpace, interfaceName, methodDefs, interfaceDef.SupportedChildTypes, false, false);
    }

    protected void GenerateInterfaceDef(ref CodeNamespace nameSpace, string interfaceName, MethodDefDictionary methodDefs, List<string> serviceKnownTypes, bool bIsEventInterface, bool bAllowMultipleInstances)
    {
      m_Logger.LogDebug("Generating Interface Definition: {0}", interfaceName);

      if (!bIsEventInterface && bAllowMultipleInstances)
      {
        throw new ConfigurationErrorsException("The AllowMultipleInstances flag cannot be set to true if the EventInterface flag is not");
      }

      CodeMemberMethod method1;
      CodeTypeDeclaration wcfInterface = new CodeTypeDeclaration("I" + interfaceName);
      wcfInterface.IsClass = false;
      wcfInterface.IsInterface = true;
      wcfInterface.CustomAttributes.Add(new CodeAttributeDeclaration("ServiceContract", new CodeAttributeArgument("ConfigurationName", new CodePrimitiveExpression(string.Format("I{0}", interfaceName)))));
      wcfInterface.Attributes = MemberAttributes.Public;

      foreach (string knownType in serviceKnownTypes)
      {
        wcfInterface.CustomAttributes.Add(new CodeAttributeDeclaration("ServiceKnownType", new CodeAttributeArgument(new CodeTypeOfExpression(GetType(knownType)))));
      }

      foreach (MethodDefPair method in methodDefs)
      {
        m_Logger.LogDebug("Generating Interface Method Definition: {0}", method.Key);

        MASMethodInfo info = method.Value;

        method1 = CreateMemberMethod(method.Key, info.ParameterDefs, bIsEventInterface, bAllowMultipleInstances);

        CodeAttributeDeclaration codeAttrib = new CodeAttributeDeclaration("OperationContract");

        if (method.Value.IsOneWay)
        {
            codeAttrib.Arguments.Add(new CodeAttributeArgument("IsOneWay", new CodePrimitiveExpression(method.Value.IsOneWay)));
        }

        method1.CustomAttributes.Add(codeAttrib);

        if (!method.Value.IsOneWay)
        {
        method1.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(FaultContractAttribute)), new CodeAttributeArgument(new CodeTypeOfExpression("MASBasicFaultDetail"))));

        string[] faultTypes = info.FaultType.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);

        foreach (string faultType in faultTypes)
        {
          if (!faultType.Contains("MASBasicFaultDetail"))
          {
            method1.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(FaultContractAttribute)), new CodeAttributeArgument(new CodeTypeOfExpression(faultType))));
          }
        }
        }
        // Current version of MS Workflow Foundation does not support flowing transactions into workflows
        // Commenting out capability until they fix the problem.
        //if (info.AllowTransactionFlow)
        //{
        //  method1.CustomAttributes.Add(new CodeAttributeDeclaration(new CodeTypeReference(typeof(System.ServiceModel.TransactionFlowAttribute)), new CodeAttributeArgument(new CodePropertyReferenceExpression(new CodeTypeReferenceExpression(typeof(System.ServiceModel.TransactionFlowOption)), "Allowed"))));
        //}

        wcfInterface.Members.Add(method1);
      }
      nameSpace.Types.Add(wcfInterface);
    }

    protected void AddSetStateEventMethod(ref CMASEventService interfaceDef)
    {
      CMASEventMethod method = new CMASEventMethod();
      method.MethodName = "SetState";
      method.EventName = "SetStateEvent";

      CMASParameterDef paramDef = new CMASParameterDef();
      paramDef.ParameterName = "AccountId";
      paramDef.ParameterType = "MetraTech.ActivityServices.Common.AccountIdentifier, MetraTech.ActivityServices.Common";
      paramDef.InternalName = "AccountId";
      paramDef.IsInstanceIdentifier = true;
      method.ParameterDefs.Add(paramDef.ParameterName, paramDef);

      paramDef = new CMASParameterDef();
      paramDef.ParameterName = "PageState";
      paramDef.ParameterType = "System.Guid";
      paramDef.InternalName = "PageStateGuid";
      method.ParameterDefs.Add(paramDef.ParameterName, paramDef);

      interfaceDef.EventMethods.Add(method.MethodName, method);
    }

    protected Type GetType(string typeName)
    {
        Type retval = Type.GetType(typeName, true, true);

        if (!m_LoadedAssemblies.ContainsKey(Path.GetFileName(retval.Assembly.Location)))
        {
            m_LoadedAssemblies.Add(Path.GetFileName(retval.Assembly.Location), retval.Assembly);
        }

        if (retval.IsGenericType)
        {
            foreach (Type t in retval.GetGenericArguments())
            {
                if (!m_LoadedAssemblies.ContainsKey(Path.GetFileName(t.Assembly.Location)))
                {
                    m_LoadedAssemblies.Add(Path.GetFileName(t.Assembly.Location), t.Assembly);
                }
            }
        }

        return retval;
    }

    private static Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args)
    {
      Assembly loaded = null;

      string searchName = args.Name.Substring(0, (args.Name.IndexOf(',') == -1 ? args.Name.Length : args.Name.IndexOf(','))).ToUpper();

      if (!searchName.Contains(".DLL"))
      {
        searchName += ".DLL";
      }

      if (m_LoadedAssemblies.ContainsKey(searchName))
      {
        loaded = m_LoadedAssemblies[searchName];
      }
      else
      {
        loaded = CMASHost.LoadAssembly(searchName);

        if (loaded != null)
        {
          m_LoadedAssemblies.Add(searchName, loaded);
        }
      }

      return loaded;
    }
    #endregion

    #region IDisposable Members

    public void Dispose()
    {
      // Remove the AssemblyResolve handler 
      AppDomain.CurrentDomain.AssemblyResolve -= m_ResolveEventHandler;

      GC.SuppressFinalize(this);
    }

    #endregion
  }
}
