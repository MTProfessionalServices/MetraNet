using System;
using System.Collections.Generic;
using System.Text;
using System.CodeDom;
using System.CodeDom.Compiler;
using Microsoft.CSharp;
using System.IO;
using System.Reflection;
using System.ServiceModel;

namespace WCFCodeGenPrototype
{
  class WCFClassGeneratorTest
  {
    private string m_BaseMsg;

    public WCFClassGeneratorTest(string baseMsg)
    {
      m_BaseMsg = baseMsg;
    }

    public Assembly GenerateWCFClass(string className)
    {
      CodeCompileUnit compileUnit = new CodeCompileUnit();

      CodeNamespace nameSpace = new CodeNamespace("Metratech.CodeGenWCF");

      nameSpace.Imports.Add(new CodeNamespaceImport("System"));
      nameSpace.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
      nameSpace.Imports.Add(new CodeNamespaceImport("System.Text"));
      nameSpace.Imports.Add(new CodeNamespaceImport("System.ServiceModel"));

      compileUnit.Namespaces.Add(nameSpace);

      CodeTypeDeclaration wcfInterface = GenerateInterfaceDef(className);
      CodeTypeDeclaration wcfClass = GenerateInterfaceClass(className);

      nameSpace.Types.Add(wcfInterface);
      nameSpace.Types.Add(wcfClass);

      return CompileCodeDomGraph(className, compileUnit);
    }

    private CodeTypeDeclaration GenerateInterfaceDef(string className)
    {
      CodeTypeDeclaration wcfInterface = new CodeTypeDeclaration("I" + className);
      wcfInterface.IsClass = false;
      wcfInterface.IsInterface = true;
      wcfInterface.CustomAttributes.Add(new CodeAttributeDeclaration("ServiceContract"));
      wcfInterface.Attributes = MemberAttributes.Public;

      CodeMemberMethod method1 = new CodeMemberMethod();
      method1.Name = "TestMethod1";
      method1.CustomAttributes.Add(new CodeAttributeDeclaration("OperationContract"));

      //method1.ReturnType = new CodeTypeReference(new CodeTypeParameter("void"));
      method1.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "msg"));

      wcfInterface.Members.Add(method1);

      return wcfInterface;
    }

    private CodeTypeDeclaration GenerateInterfaceClass(string className)
    {
      CodeTypeDeclaration wcfClass = new CodeTypeDeclaration(className);
      wcfClass.IsClass = true;
      wcfClass.BaseTypes.Add(new CodeTypeReference("I" + className, 0));
      wcfClass.Attributes = MemberAttributes.Public;
      wcfClass.CustomAttributes.Add(new CodeAttributeDeclaration("ServiceBehavior", new CodeAttributeArgument("IncludeExceptionDetailInFaults", new CodeSnippetExpression("true"))));

      CodeMemberMethod method1 = new CodeMemberMethod();
      method1.Name = "TestMethod1";
      method1.Attributes = MemberAttributes.Public;
      //method1.ReturnType = new CodeTypeReference(new CodeTypeParameter("void"));
      method1.Parameters.Add(new CodeParameterDeclarationExpression(typeof(string), "msg"));

      method1.Statements.Add(new CodeSnippetStatement("Console.WriteLine(\"In " + className + ": {0}\", msg);"));

      wcfClass.Members.Add(method1);

      return wcfClass;
    }

    private Assembly CompileCodeDomGraph(string className, CodeCompileUnit codeGraph)
    {
      CSharpCodeProvider compiler = new CSharpCodeProvider();
      
      IndentedTextWriter wrtr = new IndentedTextWriter(new StreamWriter("CodeDomWCF1.cs", false), "    ");
      compiler.GenerateCodeFromCompileUnit(codeGraph, wrtr, new CodeGeneratorOptions());
      wrtr.Flush();
      wrtr.Close();

      CompilerParameters options = new CompilerParameters();
      options.GenerateInMemory = true;
      options.ReferencedAssemblies.Add("System.dll");
      options.ReferencedAssemblies.Add("System.Data.dll");
      options.ReferencedAssemblies.Add(typeof(ServiceHost).Assembly.Location);
      options.ReferencedAssemblies.Add("System.Xml.dll");
      options.OutputAssembly = className + ".dll";
      options.CompilerOptions = "/optimize";

      CompilerResults result = compiler.CompileAssemblyFromDom(options, codeGraph);

      return result.CompiledAssembly;

    }
  }
}
