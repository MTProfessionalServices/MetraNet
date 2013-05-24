using System;
using System.CodeDom;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.IO;
using System.Text;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using Microsoft.CSharp;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  public static class EntityInterfaceGenerator
  {
    public static string GenerateCode(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null", SystemConfig.CallerInfo);

      // CodeCompileUnit
      var codeCompileUnit = new CodeCompileUnit();

      // CodeNamespace
      var codeNamespace = new CodeNamespace(Name.GetInterfaceNamespace(entity.FullName));

      codeCompileUnit.Namespaces.Add(codeNamespace);

      codeNamespace.Imports.Add(new CodeNamespaceImport("System"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("System.Collections.ObjectModel"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.BusinessEntity.Core.Model"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.BusinessEntity.DataAccess.Metadata"));

      // EntityInterface
      var entityInterface = new CodeTypeDeclaration(Name.GetInterfaceName(entity.FullName));
      codeNamespace.Types.Add(entityInterface);

      entityInterface.IsClass = false;
      entityInterface.IsInterface = true;
      entityInterface.Attributes = MemberAttributes.Public;

      // Derive from IDataObject
      entityInterface.BaseTypes.Add(new CodeTypeReference("global::" + typeof(IDataObject).FullName));

      #region Add BusinessKey Property
      // BusinessKey property
      // GenerateBusinessKeyProperty(entityInterface, entity);
      #endregion

      #region Basic properties
      foreach (Property property in entity.Properties)
      {
        if (property.IsBusinessKey) continue;
        GenerateProperty(entityInterface, property);
      }
      #endregion

      #region Add RelationshipEntity Members
      // RelationshipEntity
      var relationshipEntity = entity as RelationshipEntity;
      if (relationshipEntity != null)
      {
        GenerateRelationshipEntityMembers(entityInterface, relationshipEntity);
      }
      #endregion

      #region Add Relationship Properties

      foreach (Relationship relationship in entity.Relationships)
      {
        if (relationship.RelationshipEntity.IsSelfRelationship && relationship.RelationshipEntity.HasSameSourceAndTarget)
        {
          Check.Require(relationship.RelationshipEntity.RelationshipType == RelationshipType.OneToMany,
                        String.Format("Can only hand one-to-many self relationships"));

          GenerateItemsForManyEnd(entityInterface, relationship, relationship.RelationshipEntity.SourcePropertyNameForTarget);
          GenerateItemsForOneEnd(entityInterface, relationship, relationship.RelationshipEntity.TargetPropertyNameForSource);
        }
        else
        {
          if (relationship.End2.Multiplicity == Multiplicity.Many)
          {
            GenerateItemsForManyEnd(entityInterface, relationship);
          }
          else if (relationship.End2.Multiplicity == Multiplicity.One)
          {
            GenerateItemsForOneEnd(entityInterface, relationship);
          }

          if (relationship.RelationshipEntity.HasJoinTable)
          {
            GenerateRelationshipEntityProperty(entityInterface, relationship);
          }
        }
      }

      #endregion

      #region Generate Save Method
      var saveMethod = new CodeMemberMethod();
      saveMethod.Name = "Save";
      entityInterface.Members.Add(saveMethod);
      #endregion

      #region Generate BusinessKey Interface
      CodeTypeDeclaration businessKeyInterface = GenerateBusinessKeyInterface(entity);
      codeNamespace.Types.Add(businessKeyInterface);
      businessKeyInterface.BaseTypes.Add(new CodeTypeReference("global::" + typeof(IBusinessKey).FullName));
      #endregion

      // Generate the file content
      return CodeGeneratorUtil.GetFileContent(codeCompileUnit);
    }

    private static void GenerateProperty(CodeTypeDeclaration entityInterface, Property property)
    {
      string typeName = property.TypeName;
      if (!property.IsRequired && property.IsValueType)
      {
        typeName = "System.Nullable<" + property.TypeName + ">";
      }

      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = property.Name;
      codeProperty.Type = new CodeTypeReference(typeName);
      codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
      codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));
      entityInterface.Members.Add(codeProperty);

   }

    private static void GenerateBusinessKeyProperty(CodeTypeDeclaration entityInterface, Entity entity)
     {
       var codeProperty = new CodeMemberProperty();
       codeProperty.Name = entity.BusinessKeyPropertyName;
       //codeProperty.Type = new CodeTypeReference("global::" + typeof(BusinessKey).FullName);
       codeProperty.Type = new CodeTypeReference(Name.GetEntityBusinessKeyInterfaceName(entity.FullName));
       codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
       codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));
       entityInterface.Members.Add(codeProperty);
     }

    private static void GenerateRelationshipEntityMembers(CodeTypeDeclaration entityInterface, 
                                                          RelationshipEntity relationshipEntity)
    {
      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = relationshipEntity.GetSourceEntityClassName();
      codeProperty.Type = new CodeTypeReference("global::" + relationshipEntity.GetSourceEntityInterfaceName());
      codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
      codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));
      entityInterface.Members.Add(codeProperty);

      codeProperty = new CodeMemberProperty();
      codeProperty.Name = relationshipEntity.GetTargetEntityClassName();
      codeProperty.Type = new CodeTypeReference("global::" + relationshipEntity.GetTargetEntityInterfaceName());
      codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
      codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));
      entityInterface.Members.Add(codeProperty);

      var method = new CodeMemberMethod();
      method.Name = "SetRelationshipItem";
      method.ReturnType = new CodeTypeReference(typeof(void));
      method.Parameters.Add(new CodeParameterDeclarationExpression(typeof(object), "item"));
      entityInterface.Members.Add(method);
    }

    private static void GenerateItemsForManyEnd(CodeTypeDeclaration entityInterface, Relationship relationship, string propertyName = null)
    {
      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = String.IsNullOrEmpty(propertyName) ? relationship.End1.PropertyName : propertyName;

      //if (relationship.RelationshipEntity.HasJoinTable)
      //{
        codeProperty.Type = new CodeTypeReference("List<global::" + relationship.End2.EntityInterfaceName + ">");
        codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
        codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));
      //}
      //else
      //{
      //  codeProperty.Type =
      //    new CodeTypeReference("ReadOnlyCollection<global::" + relationship.End2.EntityInterfaceName + ">");
      //  codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
      //}


      entityInterface.Members.Add(codeProperty);

      //#region Generate Add method

      //var method = new CodeMemberMethod();
      //if (relationship.RelationshipEntity.IsDefault && !relationship.RelationshipEntity.IsSelfRelationship)
      //{
      //  method.Name = "Add" + Name.GetEntityClassName(relationship.End2.EntityTypeName);
      //}
      //else
      //{
      //  method.Name = "Add" + Name.GetEntityClassName(relationship.End2.EntityTypeName) + "To" + codeProperty.Name;
      //}

      //method.Attributes = MemberAttributes.Public;
      //method.Parameters.Add(new CodeParameterDeclarationExpression("global::" + relationship.End2.EntityInterfaceName,
      //                                                             "item"));

      //entityInterface.Members.Add(method);

      //#endregion

      //#region Generate Remove method
      //method = new CodeMemberMethod();
      //if (relationship.RelationshipEntity.IsDefault && !relationship.RelationshipEntity.IsSelfRelationship)
      //{
      //  method.Name = "Remove" + Name.GetEntityClassName(relationship.End2.EntityTypeName);
      //}
      //else
      //{
      //  method.Name = "Remove" + Name.GetEntityClassName(relationship.End2.EntityTypeName) + "From" + codeProperty.Name;
      //}

      //method.Attributes = MemberAttributes.Public;
      //method.Parameters.Add(new CodeParameterDeclarationExpression("global::" + relationship.End2.EntityInterfaceName, "item"));

      //entityInterface.Members.Add(method);

      //#endregion

    }

    private static void GenerateItemsForOneEnd(CodeTypeDeclaration entityInterface, Relationship relationship, string propertyName = null)
    {
      string typeName = relationship.End2.EntityInterfaceName;
      string codePropertyName = String.IsNullOrEmpty(propertyName) ? relationship.End1.PropertyName : propertyName;

      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = codePropertyName;
      codeProperty.Type = new CodeTypeReference("global::" + typeName);
      codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
      codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));

      entityInterface.Members.Add(codeProperty);

      #region Generate Set method
      //var method = new CodeMemberMethod();
      //method.Name = "Set" + codeProperty.Name;
      //method.Attributes = MemberAttributes.Public;
      //method.Parameters.Add(new CodeParameterDeclarationExpression("global::" + relationship.End2.EntityInterfaceName, "item"));

      //entityInterface.Members.Add(method);

      #endregion

      #region Generate BusinessKey property

      //string businessKeyTypeName = "global::" + Name.GetEntityBusinessKeyInterfaceFullName(relationship.End2.EntityTypeName);

      //codeProperty = new CodeMemberProperty();
      //codeProperty.Name = codePropertyName + "BusinessKey";
      //codeProperty.Type = new CodeTypeReference(businessKeyTypeName);
      //codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
      //codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));

      //entityInterface.Members.Add(codeProperty);
      #endregion
    }

    private static void GenerateRelationshipEntityProperty(CodeTypeDeclaration entityInterface, Relationship relationship)
    {
      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = relationship.RelationshipEntity.PluralName;
      codeProperty.Type = new CodeTypeReference("IList<global::" + relationship.RelationshipEntity.GetInterfaceFullName() + ">");
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
      codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));

      entityInterface.Members.Add(codeProperty);
    }

    private static CodeTypeDeclaration GenerateBusinessKeyInterface(Entity entity)
    {
      var businessKeyInterface = new CodeTypeDeclaration(Name.GetEntityBusinessKeyInterfaceName(entity.FullName));

      businessKeyInterface.IsClass = false;
      businessKeyInterface.IsInterface = true;
      businessKeyInterface.Attributes = MemberAttributes.Public;

      if (entity is RelationshipEntity || entity.InternalBusinessKey)
      {
        string propertyName = "InternalKey";
        string typeName = "System.Guid";

        var codeProperty = new CodeMemberProperty();
        codeProperty.Name = propertyName;
        codeProperty.Type = new CodeTypeReference(typeName);
        codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
        codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));

        businessKeyInterface.Members.Add(codeProperty);
      }
      else
      {
        foreach (Property property in entity.Properties)
        {
          if (property.IsBusinessKey)
          {
            string propertyName = property.Name;
            string typeName = property.TypeName;

            var codeProperty = new CodeMemberProperty();
            codeProperty.Name = propertyName;
            codeProperty.Type = new CodeTypeReference(typeName);
            codeProperty.GetStatements.Add(new CodeSnippetExpression("get"));
            codeProperty.SetStatements.Add(new CodeSnippetExpression("set"));

            businessKeyInterface.Members.Add(codeProperty);
          }
        }
      }

      return businessKeyInterface;
    }

    

    #region Data
    #endregion
  }
}
