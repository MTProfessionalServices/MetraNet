using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.ServiceModel;
using MetraTech.ActivityServices.Configuration;
using MetraTech.ActivityServices.Services.Common;
using RCD = MetraTech.Interop.RCD;

namespace MetraTech.Core.Services.ClientProxyHook
{
    public class BuildConfigurationProxy : MarshalByRefObject
    {
        private Dictionary<string, List<string>> m_CodeServiceAssemblies = new Dictionary<string, List<string>>(StringComparer.InvariantCultureIgnoreCase);

        public BuildConfigurationProxy()
        {
            RCD.IMTRcd rcd = new RCD.MTRcd();
            RCD.IMTRcdFileList fileList = null;

            fileList = rcd.RunQuery(@"config\ActivityServices\*.xml", false);

            CMASConfiguration interfaceConfig;
            foreach (string fileName in fileList)
            {
                interfaceConfig = new CMASConfiguration(fileName);

                foreach (KeyValuePair<string, CMASCodeService> kvp in interfaceConfig.CodeServiceDefs)
                {
                    string serviceName = kvp.Value.ServiceType;
                    
                    int firstComma = serviceName.IndexOf(',') + 1;

                    if(firstComma == -1)
                    {
                        throw new ApplicationException(string.Format("Service type name {0} isn't assembly qualified", serviceName));
                    }

                    int secondComma = serviceName.IndexOf(',', firstComma);
                    string assemblyName;

                    if (secondComma != -1)
                    {
                      assemblyName = Path.GetFileNameWithoutExtension(serviceName.Substring(firstComma, secondComma - firstComma).Trim());
                    }
                    else
                    {
                        assemblyName = Path.GetFileNameWithoutExtension(serviceName.Substring(firstComma).Trim());
                    }

                    if(!m_CodeServiceAssemblies.ContainsKey(assemblyName))
                    {
                        m_CodeServiceAssemblies[assemblyName] = new List<string>();
                    }

                    m_CodeServiceAssemblies[assemblyName].Add(serviceName);
                }
            }
        }

        public void BuildConfiguration(string assemblyName, out Dictionary<string, List<CMASProceduralService>> svcs)
        {
            svcs = new Dictionary<string, List<CMASProceduralService>>();

            // Need to strip off the dll extension if it exists.
            string extension = Path.GetExtension(assemblyName);
            string baseAssemblyName = assemblyName;
            if(extension.ToLower().Trim() == ".dll")
                baseAssemblyName = Path.GetFileNameWithoutExtension(assemblyName);

            if (m_CodeServiceAssemblies.ContainsKey(baseAssemblyName))
            {
                AppDomain.CurrentDomain.AssemblyResolve += CurrentDomain_AssemblyResolve;

                CMASProceduralService procInterface;
                List<CMASProceduralService> interfaces;

                foreach (string serviceType in m_CodeServiceAssemblies[baseAssemblyName])
                {
                    Type type = Type.GetType(serviceType, true, true);

                    interfaces = new List<CMASProceduralService>();

                    if (type.IsClass && type.IsSubclassOf(typeof(CMASServiceBase)))
                    {
                        foreach (Type iFace in type.GetInterfaces())
                        {
                            if (iFace.GetCustomAttributes(typeof(ServiceContractAttribute), true).Length != 0)
                            {
                                procInterface = ProcessInterface(iFace);
                                interfaces.Add(procInterface);
                            }
                        }

                        if (interfaces.Count > 0)
                        {
                            svcs.Add(type.FullName, interfaces);
                        }
                    }
                }
            }
        }

        private static CMASProceduralService ProcessInterface(Type type)
        {
            CMASProceduralService svc;
            CMASProceduralMethod svcMethod;
            CMASParameterDef paramDef;

            svc = new CMASProceduralService();
            svc.InterfaceName = type.Name.Substring(1);

            object[] svcContractAttribs = type.GetCustomAttributes(typeof(ServiceContractAttribute), false);

            MethodInfo[] methods = type.GetMethods(BindingFlags.FlattenHierarchy | BindingFlags.Instance | BindingFlags.Public);

            foreach (MethodInfo method in methods)
            {
                if (method.ReturnType != typeof(void))
                {
                    throw new ApplicationException(string.Format("Return type of MAS service methods must be Void.  This is not the case for the method: {0}.", method.Name));
                }

                object[] opContractAttribs = method.GetCustomAttributes(typeof(OperationContractAttribute), true);
                if (opContractAttribs != null)
                {
                    OperationContractAttribute opContractAttrib = opContractAttribs[0] as OperationContractAttribute;

                    svcMethod = new CMASProceduralMethod();
                    svcMethod.MethodName = method.Name;

                    svcMethod.IsOneWay = opContractAttrib.IsOneWay;

                    ParameterInfo[] parameters = method.GetParameters();

                    foreach (ParameterInfo parameter in parameters)
                    {
                        paramDef = new CMASParameterDef();
                        paramDef.ParameterName = parameter.Name;

                        if (parameter.ParameterType.IsByRef && parameter.IsOut)
                        {
                            paramDef.ParamDirection = CMASParameterDef.ParameterDirection.Out;
                            paramDef.ParameterType = parameter.ParameterType.GetElementType().AssemblyQualifiedName;
                        }
                        else if (parameter.ParameterType.IsByRef)
                        {
                            paramDef.ParamDirection = CMASParameterDef.ParameterDirection.InOut;
                            paramDef.ParameterType = parameter.ParameterType.GetElementType().AssemblyQualifiedName;
                        }
                        else
                        {
                            paramDef.ParamDirection = CMASParameterDef.ParameterDirection.In;
                            paramDef.ParameterType = parameter.ParameterType.AssemblyQualifiedName;
                        }

                        svcMethod.ParameterDefs.Add(paramDef.ParameterName, paramDef);
                    }

                    object[] faultContracts = method.GetCustomAttributes(typeof(FaultContractAttribute), false);
                    string faultTypes = "";

                    foreach (FaultContractAttribute attrib in faultContracts)
                    {
                        faultTypes += attrib.DetailType.AssemblyQualifiedName + ";";
                    }

                    svcMethod.FaultType = faultTypes;

                    if (svc.ProceduralMethods.ContainsKey(svcMethod.MethodName))
                    {
                        throw new Exception(string.Format(
                          "Type {0} has more then one method with the name {1}. Change your code to have unique names to fix this error",
                          type.FullName, svcMethod.MethodName));
                    }
                    else
                        svc.ProceduralMethods.Add(svcMethod.MethodName, svcMethod);
                }
            }

            return svc;
        }

        private static ICollection<MethodInfo> GetMethods(Type type, BindingFlags flags)
        {
            HashSet<MethodInfo> methods = new HashSet<MethodInfo>();
            GetMethodsRecursively(type, flags, methods);
            return methods;
        }



        private static void GetMethodsRecursively(Type type, BindingFlags flags, HashSet<MethodInfo> methods)
        {
            MethodInfo[] childMethods = type.GetMethods(flags);
            methods.UnionWith(childMethods);

            foreach (Type interfaceType in type.GetInterfaces())
            {
                GetMethodsRecursively(interfaceType, flags, methods);
            }
        } 
        private static Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args)
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
                    retval = Assembly.LoadFile(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, searchName));
                }
                catch (Exception)
                {
                    RCD.IMTRcd rcd = new RCD.MTRcd();
                    RCD.IMTRcdFileList fileList = rcd.RunQuery(string.Format("Bin\\{0}", searchName), false);

                    if (fileList.Count > 0)
                    {
                        AssemblyName nm2 = AssemblyName.GetAssemblyName(((string)fileList[0]));
                        retval = Assembly.Load(nm2);
                    }
                }
            }

            return retval;
        }

    }
}
