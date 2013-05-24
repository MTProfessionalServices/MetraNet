using System;
using MetraTech.Pipeline;
using MetraTech.Adjustments;
using MetraTech.MTSQL;
using System.Reflection;
using System.Reflection.Emit;

namespace MetraTech.Adjustments.MTSQLCompiler
{
	/// <summary>
	/// Summary description for ExecutionParameters.
	/// </summary>
	public class ExecutionParameterFactory
	{
  	public static object CreateExecutionParameters(ICalculationFormula aFormula, IProductViewDefinition aPV)
		{
      //dynamically create properties. This class is used as a feed for
      //PropertyGrid
      AppDomain currentDomain = AppDomain.CurrentDomain;
      AssemblyName an = new AssemblyName();
      an.Name = "dsss";
      AssemblyBuilder ab = currentDomain.DefineDynamicAssembly(an, AssemblyBuilderAccess.Run);
      ModuleBuilder mb = ab.DefineDynamicModule("mymodule");
      TypeBuilder tb = mb.DefineType("ExecutionParameters");
      PropertyBuilder pb = tb.DefineProperty("Prop1", PropertyAttributes.None, typeof(string), null);
      EnumBuilder eb = mb.DefineEnum("ServiceLevel", TypeAttributes.Public, typeof(string));
      PropertyBuilder pb1 = tb.DefineProperty("Prop2", PropertyAttributes.None, eb.GetType(), null);
      PropertyBuilder pb2 = tb.DefineProperty("Prop3", PropertyAttributes.None, typeof(int), null);

      return System.Activator.CreateInstance(tb.CreateType());
      
      
		}

	}

}
