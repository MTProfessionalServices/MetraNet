using System;
using System.Reflection;
using System.Runtime.InteropServices;
using System.EnterpriseServices;

#pragma warning disable 0618    // Disable warning System.Reflection.Assembly.LoadWithPartialName(string)' is obsolete:

namespace MetraTech.Debug.DebugAsm
{
	class DebugAsm
	{
    private void WriteUsage()
    {
      Console.WriteLine("Usage:");
      Console.WriteLine("  DebugAsm load [assemblyName]             - load an assembly by name");
      Console.WriteLine("  DebugAsm loadPart [assemblyName]         - load an assembly by partial name from GAC");
      Console.WriteLine("  DebugAsm loadFrom [assemblyPath]         - load an assembly by path");
      Console.WriteLine("  DebugAsm getType [typeName,assemblyName] - find a type given its name and assembly name");
      Console.WriteLine("  DebugAsm check [assemblyPath]            - checks various rules for the given assembly");
      Console.WriteLine("\nExamples:");
      Console.WriteLine("  DebugAsm load metratech.xml");
      Console.WriteLine("  DebugAsm load metratech.xml,version=3.5");
      Console.WriteLine("  DebugAsm loadPart System");
      Console.WriteLine("  DebugAsm loadFrom o:\\debug\\bin\\metratech.xml.dll");
      Console.WriteLine("  DebugAsm getType MetraTech.Xml.MTXmlDocument,metratech.xml");
    }
   
    [STAThread]
    static int Main(string[] args)
    {
			DebugAsm exe = new DebugAsm();
			
      if (args.Length < 2)
      {
        exe.WriteUsage();
				return 1;
      }

      switch(args[0].ToLower())
      {
        case "load":
          exe.Load(args[1]);
          break;

        case "loadpart":
          exe.LoadPart(args[1]);
          break;


        case "loadfrom":
          exe.LoadFrom(args[1]);
          break;

        case "gettype":
          exe.GetType(args[1]);
          break;

        case "check":
          if (!exe.GuidelineCheck(args[1]))
						return 1;

          break;

        default: 
					exe.WriteUsage(); break;
      }

			return 0;
    }

		private void Load(string assemblyName)
    {
      Console.WriteLine("Calling Assembly.Load(\"{0}\")", assemblyName);
      
      Assembly assembly;
      assembly = Assembly.Load(assemblyName);
      Console.WriteLine("loaded {0}", assembly.FullName);
    }

    private void LoadPart(string assemblyName)
    {
      Console.WriteLine("Calling Assembly.LoadWithPartialName(\"{0}\")", assemblyName);
      
      Assembly assembly;
      assembly = Assembly.LoadWithPartialName(assemblyName);
      Console.WriteLine("loaded {0}", assembly.FullName);
    }

    private void LoadFrom(string assemblyPath)
    {
      Console.WriteLine("Calling Assembly.LoadFrom(\"{0}\")", assemblyPath);
      
      Assembly assembly;
      assembly = Assembly.LoadFrom(assemblyPath);
      Console.WriteLine("loaded {0}", assembly.FullName);
    }

    private void GetType(string typeName)
    {
      Console.WriteLine("Calling Type.GetType(\"{0}\")", typeName);

      Type objType = Type.GetType(typeName);

      if (objType == null)
        Console.WriteLine("Error: no type found.");
      else
      {
        Console.WriteLine("found type: {0}", objType);
        Console.WriteLine("Calling Activator.CreateInstance(\"{0}\")", objType);
        object obj =  Activator.CreateInstance(objType);
        if (obj == null)
          Console.WriteLine("Error: CreateInstance() failed");
        else
          Console.WriteLine("created object: {0}", obj);
      }    
    }

		private bool GuidelineCheck(string assemblyPath)
		{
      Assembly assembly;
      assembly = Assembly.LoadFrom(assemblyPath);

			bool anyFailures = false;
			bool hasComVisibleTypes = false;

			// inspects only .NET assemblies 
			if (assembly.EntryPoint == null)
			{
				foreach (Module module in assembly.GetLoadedModules())
				{
					foreach (Type type in module.GetTypes())
					{
						bool isComVisible;

						if (!CheckType(type, assemblyPath, out isComVisible))
							anyFailures = true;

						if (isComVisible)
							hasComVisibleTypes = true;
					}
				}

				if (hasComVisibleTypes)
				{
					if (!CheckAssemblyHasGuid(assembly, assemblyPath))
						anyFailures = true;
				}
			}

			return !anyFailures;
		}

		private bool CheckType(Type type, string assemblyPath, out bool isComVisible)
		{
			bool anyErrors = false;

			isComVisible = Marshal.IsTypeVisibleFromCom(type);

			if (isComVisible)
			{
				if (!CheckTypeHasGuid(type, assemblyPath))
					anyErrors = true;

				if (!CheckTransactionIsolation(type, assemblyPath))
					anyErrors = true;

				if (CheckTypeHasExplicitInterface(type, assemblyPath))
				{
					if (!CheckImplementedInterfaceHasGuid(type, assemblyPath))
						anyErrors = true;
				}
				else
					anyErrors = true;
			}
			else
			{
				if (!CheckTypeHasExtraGuid(type, assemblyPath))
					anyErrors = true;
			}

			return !anyErrors;
		}

		private bool CheckTypeHasGuid(Type type, string assemblyPath)
		{
			if (type.IsDefined(typeof(GuidAttribute), true))
				return true; 

			Console.WriteLine("CheckAsm [{0}]: Type {1} has no GUID (class ID) defined (CA1)",
												assemblyPath, type.Name);
		
			// fails for serviced components
			if(type.BaseType == typeof(ServicedComponent))
			{
				Console.WriteLine("CheckAsm [{0}]: Serviced Component {1} must have GUID attribute (CA2)",
													assemblyPath, type.Name);
			}
			
			return false;
		}

		private bool CheckTransactionIsolation(Type type, string assemblyPath)
		{
			bool failed = true;

			// fails for serviced components
			if(type.BaseType == typeof(ServicedComponent))
			{
				
				Object[] attrs = type.GetCustomAttributes(true);
				if(attrs.Length > 0)
				{
					for(int j = 0; j < attrs.Length; j++)
					{
						if (attrs[j] is TransactionAttribute)
						{
							TransactionAttribute ta = (TransactionAttribute)attrs[j];
							if(ta.Value != TransactionOption.NotSupported)
							{
								if(ta.Isolation == TransactionIsolationLevel.Any)
								{
									failed = false;
									break;
								}
							}
							//transaction not supported - we don't care about isolation level
							else
							{
								failed = false;
								break;
							}
						}
					}
				}
			}
			else
				failed = false;


			if(failed)
				Console.WriteLine("CheckAsm [{0}]: Serviced Component {1} must have transaction isolation level set to TransactionIsolationLevel.Any.",
					assemblyPath, type.Name);
								
			return !failed;
		}

		private bool CheckTypeHasExplicitInterface(Type type, string assemblyPath)
		{
			if (type.IsClass)
			{
				Type[] interfaces = type.GetInterfaces();

				int visibleCount = 0;
				foreach (Type @interface in interfaces)
				{
					if (Marshal.IsTypeVisibleFromCom(@interface))
						visibleCount++;
				}

				if (visibleCount == 0)
				{
					Console.WriteLine("CheckAsm [{0}]: Type {1} does not implement an explicit COM visible interface (CA3)",
														assemblyPath, type.Name);
					return false;
				}
			}

			return true;
		}

		private bool CheckImplementedInterfaceHasGuid(Type type, string assemblyPath)
		{
			bool anyErrors = false;
			TypeFilter filter = new TypeFilter(InterfaceFilter);
			Type[] interfaces = type.FindInterfaces(filter, "MetraTech.");
			foreach(Type @interface in interfaces)
			{
				if(Marshal.IsTypeVisibleFromCom(@interface) && 
					 !@interface.IsDefined(typeof(GuidAttribute), true))
				{
					Console.WriteLine("CheckAsm [{0}]: Interface {1} implemented by type {2} has no GUID defined (CA4)",
														assemblyPath, @interface.FullName, type.Name);
					anyErrors = true;
				}
			}
			
			return !anyErrors;
		}

		private bool CheckTypeHasExtraGuid(Type type, string assemblyPath)
		{
			if (type.IsDefined(typeof(GuidAttribute), true))
			{
				Console.WriteLine("CheckAsm [{0}]: GUID on type {1} is useless because type is not COM visible. Is this intended? (CA5)",
													assemblyPath, type.Name);
				return false;
			}
			
			return true;
		}

		private bool CheckAssemblyHasGuid(Assembly assembly, string assemblyPath)
		{
			if (assembly.IsDefined(typeof(GuidAttribute), true) == false)
			{
				Console.WriteLine("CheckAsm [{0}]: Assembly GUID not defined (CA6)", assemblyPath);
				return false;
			}

			return true;
		}

		public static bool InterfaceFilter(Type typeObj,Object criteriaObj)
		{
			if(typeObj.ToString().StartsWith(criteriaObj.ToString()) == true)
				return true;
			else
				return false;
		}

	}
	
}
