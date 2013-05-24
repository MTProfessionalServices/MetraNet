using System;
using System.CodeDom;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using Microsoft.CSharp;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  public static class EntityHistoryGenerator
  {
    public static string GenerateCode(HistoryEntity historyEntity)
    {
      Check.Require(historyEntity != null, "historyEntity cannot be null", SystemConfig.CallerInfo);

      // CodeCompileUnit
      var codeCompileUnit = new CodeCompileUnit();

      // CodeNamespace
      var codeNamespace = new CodeNamespace(historyEntity.Namespace);

      codeCompileUnit.Namespaces.Add(codeNamespace);

      codeNamespace.Imports.Add(new CodeNamespaceImport("System"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("System.Runtime.Serialization"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.Basic"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.BusinessEntity.Core"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.BusinessEntity.Core.Model"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.BusinessEntity.DataAccess.Metadata"));

      // EntityClass
      var entityClass = new CodeTypeDeclaration(historyEntity.ClassName);
      codeNamespace.Types.Add(entityClass);

      entityClass.IsClass = true;
      entityClass.IsPartial = true;
      entityClass.Attributes = MemberAttributes.Public;

      #region Add Attributes
      // Add the [DataContract] attribute
      var dataContractAttribute = new CodeAttributeDeclaration(typeof(DataContractAttribute).FullName);
      dataContractAttribute.Arguments.Add(new CodeAttributeArgument("IsReference", new CodeSnippetExpression("true")));
      entityClass.CustomAttributes.Add(dataContractAttribute);

      // Add the [Serializable] attribute
      var serializableAttribute = new CodeAttributeDeclaration(typeof(SerializableAttribute).FullName);
      entityClass.CustomAttributes.Add(serializableAttribute);

      // Add the [ConfigDriven] attribute
      var configDrivenAttribute = new CodeAttributeDeclaration(typeof(ConfigDrivenAttribute).FullName);
      entityClass.CustomAttributes.Add(configDrivenAttribute);
      #endregion

      #region Add Base Class
      entityClass.BaseTypes.Add(new CodeTypeReference(typeof(BaseHistory).FullName));
      #endregion

      #region Add BusinessKey Property
      GenerateBusinessKeyProperty(entityClass, historyEntity);
      #endregion

      #region Add constant for Id Property
      var constPublicField = new CodeMemberField(typeof(String), "Property_Id");

      // Resets the access and scope mask bit flags of the member attributes of the field
      // before setting the member attributes of the field to public and constant.
      constPublicField.Attributes = (constPublicField.Attributes & ~MemberAttributes.AccessMask & ~MemberAttributes.ScopeMask) | MemberAttributes.Public | MemberAttributes.Const;

      constPublicField.InitExpression = new CodeSnippetExpression("\"Id\"");
      entityClass.Members.Add(constPublicField);
      #endregion

      #region Add Properties
      List<Property> codeGeneratedProperties =
        historyEntity.Properties.FindAll(p => p.Name != BaseHistory.StartDatePropertyName &&
                                              p.Name != BaseHistory.EndDatePropertyName);
      codeGeneratedProperties.AddRange(historyEntity.PreDefinedProperties);

      foreach (Property property in codeGeneratedProperties)
      {
        if (property.IsBusinessKey) continue;
        GenerateProperty(entityClass, property);
      }

      #endregion

      #region Add GetDataObject Method
      GenerateGetDataObjectMethod(entityClass, historyEntity, codeGeneratedProperties);
      #endregion

      // Generate the file content
      return CodeGeneratorUtil.GetFileContent(codeCompileUnit);
    }

    private static void GenerateBusinessKeyProperty(CodeTypeDeclaration entityClass, Entity entity)
    {
      string fieldName = entity.BusinessKeyFieldName;
      string propertyName = entity.BusinessKeyPropertyName;

      string typeName = "global::" + Name.GetEntityBusinessKeyFullName(entity.FullName);
      // string typeName = "global::" + Name.GetEntityBusinessKeyInterfaceFullName(entity.FullName);

      var field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(typeName);

      entityClass.Members.Add(field);

      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = propertyName;
      codeProperty.Type = new CodeTypeReference(typeName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));

      entityClass.Members.Add(codeProperty);

      // Add the [BusinessKey] attribute
      var businessKeyAttribute = new CodeAttributeDeclaration(typeof(BusinessKeyAttribute).FullName);
      codeProperty.CustomAttributes.Add(businessKeyAttribute);

      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));
    }

    private static void GenerateProperty(CodeTypeDeclaration entityClass, Property property)
    {
      string typeName = property.TypeName;
      if (!property.IsRequired && property.IsValueType)
      {
        typeName = "System.Nullable<" + property.TypeName + ">";
      }

      var field = new CodeMemberField();
      field.Name = property.FieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(typeName);

      entityClass.Members.Add(field);

      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = property.Name;
      codeProperty.Type = new CodeTypeReference(typeName);
      if (property.IsBasePredefined())
      {
        codeProperty.Attributes = MemberAttributes.Public | MemberAttributes.Override;
      }
      else
      {
        codeProperty.Attributes = MemberAttributes.Public;
      }
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));
      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));

      entityClass.Members.Add(codeProperty);

      #region Add constant for property name
      var constPublicField = new CodeMemberField(typeof(String), "Property_" + property.Name);

      // Resets the access and scope mask bit flags of the member attributes of the field
      // before setting the member attributes of the field to public and constant.
      constPublicField.Attributes = (constPublicField.Attributes & ~MemberAttributes.AccessMask & ~MemberAttributes.ScopeMask) | MemberAttributes.Public | MemberAttributes.Const;

      constPublicField.InitExpression = new CodeSnippetExpression("\"" + property.Name + "\"");
      entityClass.Members.Add(constPublicField);
      #endregion
    }

    private static void GenerateGetDataObjectMethod(CodeTypeDeclaration entityClass, 
                                                    HistoryEntity historyEntity,
                                                    List<Property> properties)
    {
      var method = new CodeMemberMethod();
      method.Name = "GetDataObject";
      method.ReturnType = new CodeTypeReference(typeof(DataObject));
      method.Attributes = MemberAttributes.Public | MemberAttributes.Override;

      string entityClassName = Name.GetEntityClassName(historyEntity.EntityName);
      // var _site = new Site();
      string variable = "_" + entityClassName.LowerCaseFirst();
      var assignment =
        new CodeAssignStatement(new CodeSnippetExpression("var " + variable),
                                new CodeSnippetExpression("new global::" + historyEntity.EntityName + "()"));
      method.Statements.Add(assignment);

      var entityIdPropertyName = Name.GetEntityClassName(historyEntity.EntityName) + "Id";
      //site.Id = SiteId;
      assignment =
       new CodeAssignStatement(new CodeSnippetExpression(variable + ".Id"),
                               new CodeSnippetExpression(entityIdPropertyName));
      method.Statements.Add(assignment);

      //site._Version = _Version;
      assignment =
       new CodeAssignStatement(new CodeSnippetExpression(variable + "." + Property.VersionPropertyName),
                               new CodeSnippetExpression(Property.VersionPropertyName));
      method.Statements.Add(assignment);

      //site.BusinessKey = BusinessKey;
      assignment =
       new CodeAssignStatement(new CodeSnippetExpression(variable + "." + historyEntity.BusinessKeyPropertyName),
                               new CodeSnippetExpression(historyEntity.BusinessKeyPropertyName));
      method.Statements.Add(assignment);

      foreach (Property property in properties)
      {
        if (property.IsBusinessKey || property.Name == entityIdPropertyName)
        {
          continue;
        }

        assignment =
          new CodeAssignStatement(new CodeSnippetExpression(variable + "." + property.Name),
                                  new CodeSnippetExpression(property.Name));
        method.Statements.Add(assignment);

      }

      // return statement
      method.Statements.Add(new CodeMethodReturnStatement(new CodeSnippetExpression(variable)));

      entityClass.Members.Add(method);
    }

    
   
    #region Data
    #endregion
  }
}
