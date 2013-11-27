using System;
using System.Reflection;
using System.IO;
using System.CodeDom;
using System.CodeDom.Compiler;
using Microsoft.CSharp;
using System.Collections;
using System.Collections.Generic;
using System.Data;

namespace Linqify
{
    public class FieldDesc
    {
        public string name;
        public int ordinal;
        public bool isNullable;
    }

    public static class NetMeterCodeDom
    {
        public static CodeCompileUnit targetUnit;
        public static CodeNamespace targetNamespace;
        public static CodeTypeDeclaration targetClass;
        public static CodeMemberMethod targetMethod;

        public const string outputFileName = "SampleCode.cs";

        static NetMeterCodeDom()
        {
            targetUnit = new CodeCompileUnit();
            targetNamespace = new CodeNamespace("NetMeterObj");
            targetUnit.Namespaces.Add(targetNamespace);

            addUsings();
        }

        public static void buildIt()
        {
            string outputFileName = "foo.cs";

            addUsings();
            GenerateCSharpCode(outputFileName);
            // compile();
        }


        public static void addUsings()
        {
            foreach (string s in Config.getUsings())
            {
                targetNamespace.Imports.Add(new CodeNamespaceImport(s));
            }
        }


        public static void workOnClass(string className)
        {
            targetClass = new CodeTypeDeclaration(className);
            targetClass.IsClass = true;
            targetClass.TypeAttributes = TypeAttributes.Public;
            targetClass.IsPartial = true;
            targetNamespace.Types.Add(targetClass);
        }

        public static void workOnTableClass(string className)
        {
            workOnClass(className);
            targetClass.CustomAttributes.Add(new CodeAttributeDeclaration("DataContract"));
            targetClass.BaseTypes.Add("IDbObj");
        }


        public static void workOnMethod(string name)
        {
            targetMethod = new CodeMemberMethod();
            targetMethod.Name = name;
            targetMethod.Attributes = MemberAttributes.Public | MemberAttributes.Final;
            targetClass.Members.Add(targetMethod);
        }

        public static void addParameter(string typeName, string name)
        {
            targetMethod.Parameters.Add(new CodeParameterDeclarationExpression(typeName, name));
        }


        public static void addDataMember(string name, Type theType, bool nullable)
        {
            CodeMemberField prop = new CodeMemberField();
            prop.Attributes = MemberAttributes.Public;
            prop.Name = name;

            // TODO This is't quite right as we'd like them autoimplemented
            // Rather than generate yet more code, we use a hack
            //prop.HasGet = true;
            //prop.HasSet = true;
            // HACK
            // The comment mark is needed to eat the generated semicolon
            prop.Name += " {set; get;} //";

            CodeTypeReference ctr = new CodeTypeReference(theType);
            // field.Type = new CodeTypeReference(theType);
            if (nullable)
            {
                CodeTypeReference[] ctra = new CodeTypeReference[1];
                ctra[0] = ctr;
                ctr = new CodeTypeReference("System.Nullable", ctra);
            }
            prop.Type = ctr;
            prop.CustomAttributes.Add(new CodeAttributeDeclaration("DataMember"));

            targetClass.Members.Add(prop);
        }


        public static void addInMemoryList(string className)
        {
            CodeMemberField prop = new CodeMemberField();
            prop.Attributes = MemberAttributes.Public | MemberAttributes.Static;
            prop.Name = className + "List";

            CodeTypeReference eltType = new CodeTypeReference(className);

            prop.Type = new CodeTypeReference("List", eltType);
            targetClass.Members.Add(prop);
        }


        public static void addMethod_TableName(string name)
        {
            workOnMethod(name);
            targetMethod.ReturnType = new CodeTypeReference("System.String");
            //method1.Parameters.Add(new CodeParameterDeclarationExpression("System.String", "text"));
            targetMethod.Statements.Add(new CodeMethodReturnStatement(new CodePrimitiveExpression(name)));
        }


        public static void addField_AdapterWidget()
        {

            CodeMemberField widthValueField = new CodeMemberField();
            widthValueField.Attributes = MemberAttributes.Public | MemberAttributes.Static;
            widthValueField.Name = "adapterWidget";
            widthValueField.Type = new CodeTypeReference("AdapterWidget");
            targetClass.Members.Add(widthValueField);
        }

        public static void addMethod_ToRow(List<FieldDesc> fieldDescs)
        {
            CodeMemberMethod method1 = new CodeMemberMethod();
            method1.Name = "ToRow";
            method1.Attributes = MemberAttributes.Public | MemberAttributes.Final;
            //method1.ReturnType = new CodeTypeReference("void");
            method1.Parameters.Add(new CodeParameterDeclarationExpression("DataRow", "row"));
            // method1.Statements.Add(new CodeMethodReturnStatement(new CodePrimitiveExpression(name)));
            foreach (FieldDesc fd in fieldDescs)
            {
                CodeAssignStatement stmt = new CodeAssignStatement();
                CodeFieldReferenceExpression fieldRef1 = new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), fd.name);
                stmt.Right = fieldRef1;
                stmt.Left = new System.CodeDom.CodeIndexerExpression(new CodeVariableReferenceExpression("row"), new CodePrimitiveExpression(fd.ordinal));
                method1.Statements.Add(stmt);
            }
            targetClass.Members.Add(method1);
        }



        //sb.AppendLine("      public void insert()");
        //sb.AppendLine("      {");
        //sb.AppendLine("        DataRow row = adapterWidget.createRow();");
        //sb.AppendLine("        ToRow( row);");
        //sb.AppendLine("        adapterWidget.insertRow( row);");
        //sb.AppendLine("      }");

        public static void addMethod_Insert()
        {
            // Defines a method that returns a string passed to it.
            CodeMemberMethod method1 = new CodeMemberMethod();
            method1.Name = "insert";
            method1.Attributes = MemberAttributes.Public | MemberAttributes.Final;

            CodeVariableReferenceExpression aw = new CodeVariableReferenceExpression("adapterWidget");
            CodeVariableReferenceExpression row = new CodeVariableReferenceExpression("row");

            {

                CodeMethodReferenceExpression m = new CodeMethodReferenceExpression(aw, "createRow");
                CodeMethodInvokeExpression mi = new CodeMethodInvokeExpression(m);
                CodeVariableDeclarationStatement vd;
                vd = new CodeVariableDeclarationStatement(typeof(DataRow), "row", mi);
                method1.Statements.Add(vd);
            }

            {
                CodeMethodReferenceExpression m = new CodeMethodReferenceExpression(new CodeThisReferenceExpression(), "ToRow");
                CodeMethodInvokeExpression mi = new CodeMethodInvokeExpression(m, row);
                CodeExpressionStatement stmt = new CodeExpressionStatement(mi);
                method1.Statements.Add(stmt);
            }

            {
                CodeMethodReferenceExpression m = new CodeMethodReferenceExpression(aw, "insertRow");
                CodeMethodInvokeExpression mi = new CodeMethodInvokeExpression(m, row);
                CodeExpressionStatement stmt = new CodeExpressionStatement(mi);
                method1.Statements.Add(stmt);
            }

            //method1.ReturnType = new CodeTypeReference("System.String");
            //method1.Parameters.Add(new CodeParameterDeclarationExpression("System.String", "text"));
            //method1.Statements.Add(new CodeMethodReturnStatement(new CodePrimitiveExpression(name)));
            targetClass.Members.Add(method1);
        }

        public static void addListLoad(string className, string tableName)
        {
            string listVar = className + "List";
            CodeVariableReferenceExpression lhs = new CodeVariableReferenceExpression(listVar);

            CodeTypeReference typeRef = new CodeTypeReference(className);
            CodeMethodReferenceExpression methodExpr = new CodeMethodReferenceExpression(null, "load", typeRef);

            CodeMethodInvokeExpression rhs = new CodeMethodInvokeExpression(methodExpr);
            CodeAssignStatement stmt = new CodeAssignStatement(lhs, rhs);
            targetMethod.Statements.Add(stmt);
        }

        //sb.AppendFormat("     {0}.adapterWidget = AdapterWidgetFactory.create(\"{1}\");", className, tableName);
        public static void addCreateAdapterWidget(string className, string tableName)
        {

            CodeFieldReferenceExpression lhs = new CodeFieldReferenceExpression(new CodeVariableReferenceExpression(className), "adapterWidget");

            CodeTypeReference typeRef = new CodeTypeReference(className);
            CodeMethodReferenceExpression methodExpr = new CodeMethodReferenceExpression(null, "load", typeRef);

            CodeObjectCreateExpression rhs = new CodeObjectCreateExpression("AdapterWidget", new CodePrimitiveExpression( tableName));

            CodeAssignStatement stmt = new CodeAssignStatement(lhs, rhs);
            targetMethod.Statements.Add(stmt);
        }

        public static void addField_index(ObjectIndex idx)
        {
            CodeMemberField field = new CodeMemberField();
            field.Attributes = MemberAttributes.Public | MemberAttributes.Static;
            field.Name = idx.instanceName;
            field.Type = new CodeTypeReference(idx.fullClassName);
 
            targetClass.Members.Add(field);
        }


        public static void AddFields()
        {
            // Declare the widthValue field.
            CodeMemberField widthValueField = new CodeMemberField();
            widthValueField.Attributes = MemberAttributes.Public;
            widthValueField.Name = "widthValue";
            widthValueField.Type = new CodeTypeReference(typeof(System.Double));
            widthValueField.Comments.Add(new CodeCommentStatement(
                "The width of the object."));
            targetClass.Members.Add(widthValueField);

            // Declare the heightValue field
            CodeMemberField heightValueField = new CodeMemberField();
            heightValueField.Attributes = MemberAttributes.Private;
            heightValueField.Name = "heightValue";
            heightValueField.Type =
                new CodeTypeReference(typeof(System.Double));
            heightValueField.Comments.Add(new CodeCommentStatement(
                "The height of the object."));
            targetClass.Members.Add(heightValueField);
        }


        public static void AddProperties()
        {
            // Declare the read-only Width property.
            CodeMemberProperty widthProperty = new CodeMemberProperty();
            widthProperty.Attributes =
                MemberAttributes.Public | MemberAttributes.Final;
            widthProperty.Name = "Width";
            widthProperty.HasGet = true;
            widthProperty.Type = new CodeTypeReference(typeof(System.Double));
            widthProperty.Comments.Add(new CodeCommentStatement(
                "The Width property for the object."));
            widthProperty.GetStatements.Add(new CodeMethodReturnStatement(
                new CodeFieldReferenceExpression(
                new CodeThisReferenceExpression(), "widthValue")));
            targetClass.Members.Add(widthProperty);

            // Declare the read-only Height property.
            CodeMemberProperty heightProperty = new CodeMemberProperty();
            heightProperty.Attributes =
                MemberAttributes.Public | MemberAttributes.Final;
            heightProperty.Name = "Height";
            heightProperty.HasGet = true;
            heightProperty.Type = new CodeTypeReference(typeof(System.Double));
            heightProperty.Comments.Add(new CodeCommentStatement(
                "The Height property for the object."));
            heightProperty.GetStatements.Add(new CodeMethodReturnStatement(
                new CodeFieldReferenceExpression(
                new CodeThisReferenceExpression(), "heightValue")));
            targetClass.Members.Add(heightProperty);

            // Declare the read only Area property.
            CodeMemberProperty areaProperty = new CodeMemberProperty();
            areaProperty.Attributes =
                MemberAttributes.Public | MemberAttributes.Final;
            areaProperty.Name = "Area";
            areaProperty.HasGet = true;
            areaProperty.Type = new CodeTypeReference(typeof(System.Double));
            areaProperty.Comments.Add(new CodeCommentStatement(
                "The Area property for the object."));

            // Create an expression to calculate the area for the get accessor  
            // of the Area property.
            CodeBinaryOperatorExpression areaExpression =
                new CodeBinaryOperatorExpression(
                new CodeFieldReferenceExpression(
                new CodeThisReferenceExpression(), "widthValue"),
                CodeBinaryOperatorType.Multiply,
                new CodeFieldReferenceExpression(
                new CodeThisReferenceExpression(), "heightValue"));
            areaProperty.GetStatements.Add(
                new CodeMethodReturnStatement(areaExpression));
            targetClass.Members.Add(areaProperty);
        }

        public static void GenerateCSharpCode(string fileName)
        {
            CodeDomProvider provider = CodeDomProvider.CreateProvider("CSharp");
            CodeGeneratorOptions options = new CodeGeneratorOptions();
            options.BracingStyle = "C";
            using (StreamWriter sourceWriter = new StreamWriter(fileName))
            {
                provider.GenerateCodeFromCompileUnit(
                    targetUnit, sourceWriter, options);
            }
        }


        public static bool compile()
        {
            CodeDomProvider provider = CodeDomProvider.CreateProvider("CSharp");
            CodeGeneratorOptions options = new CodeGeneratorOptions();
            // Build the parameters for source compilation.
            CompilerParameters cp = new CompilerParameters();

            // Add an assembly reference.
            cp.ReferencedAssemblies.Add("System.dll");

            // Generate an executable instead of 
            // a class library.
            cp.GenerateExecutable = false;

            // Set the assembly file name to generate.
            cp.OutputAssembly = "foo.dll";

            // Save the assembly as a physical file.
            cp.GenerateInMemory = false;

            // Invoke compilation.
            CompilerResults cr = provider.CompileAssemblyFromDom(cp, targetUnit);

            if (cr.Errors.Count > 0)
            {
                // Display compilation errors.
                Console.WriteLine("Errors building {0} into {1}",
                    "foo.cs", cr.PathToAssembly);
                foreach (CompilerError ce in cr.Errors)
                {
                    Console.WriteLine("  {0}", ce.ToString());
                    Console.WriteLine();
                }
            }
            else
            {
                Console.WriteLine("Source {0} built into {1} successfully.",
                    "foo.cs", cr.PathToAssembly);
            }

            // Return the results of compilation. 
            if (cr.Errors.Count > 0)
            {
                return false;
            }
            else
            {
                return true;
            }


        }


    }

}