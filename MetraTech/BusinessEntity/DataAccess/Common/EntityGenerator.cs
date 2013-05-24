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
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using Microsoft.CSharp;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  public static class EntityGenerator
  {
    public static string GenerateCode(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null", SystemConfig.CallerInfo);

      // CodeCompileUnit
      var codeCompileUnit = new CodeCompileUnit();

      // CodeNamespace
      var codeNamespace = new CodeNamespace(entity.Namespace);

      codeCompileUnit.Namespaces.Add(codeNamespace);

      #region Add imports
      codeNamespace.Imports.Add(new CodeNamespaceImport("System"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("System.Collections.Generic"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("System.Collections.ObjectModel"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("System.Runtime.Serialization"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("System.Linq"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.Basic"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.BusinessEntity.Core"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.BusinessEntity.Core.Model"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.BusinessEntity.DataAccess.Metadata"));
      codeNamespace.Imports.Add(new CodeNamespaceImport("MetraTech.BusinessEntity.DataAccess.Persistence"));

      #endregion

      // EntityClass
      var entityClass = new CodeTypeDeclaration(entity.ClassName);
      codeNamespace.Types.Add(entityClass);

      entityClass.IsClass = true;
      entityClass.IsPartial = true;
      entityClass.Attributes = MemberAttributes.Public;

      #region Add constant for FullName
      var constPublicField = new CodeMemberField(typeof(String), "FullName");

      // Resets the access and scope mask bit flags of the member attributes of the field
      // before setting the member attributes of the field to public and constant.
      constPublicField.Attributes = (constPublicField.Attributes & ~MemberAttributes.AccessMask & ~MemberAttributes.ScopeMask) | MemberAttributes.Public | MemberAttributes.Const;

      constPublicField.InitExpression = new CodeSnippetExpression("\"" + entity.FullName + "\"");
      entityClass.Members.Add(constPublicField);
      #endregion

      #region Add Attributes
      // Add the [DataContract] attribute
      var dataContractAttribute = new CodeAttributeDeclaration(typeof(DataContractAttribute).FullName);
      dataContractAttribute.Arguments.Add(new CodeAttributeArgument("IsReference", new CodeSnippetExpression("true")));
      entityClass.CustomAttributes.Add(dataContractAttribute);

      // Add the [Serializable] attribute
      var serializableAttribute = new CodeAttributeDeclaration(typeof(SerializableAttribute).FullName);
      entityClass.CustomAttributes.Add(serializableAttribute);

      // Add the [KnownType("GetKnownTypes")] attribute
      var attributeItems = new CodeAttributeArgument[1];
      attributeItems[0] =
        (new CodeAttributeArgument(new CodePrimitiveExpression("GetKnownTypes")));
      var knownTypeAttribute =
        new CodeAttributeDeclaration(typeof(KnownTypeAttribute).FullName, attributeItems);
      entityClass.CustomAttributes.Add(knownTypeAttribute);

      // Add the [ConfigDriven] attribute
      var configDrivenAttribute = new CodeAttributeDeclaration(typeof(ConfigDrivenAttribute).FullName);
      entityClass.CustomAttributes.Add(configDrivenAttribute);
      #endregion

      #region Add Base Class and Interface
      if (entity.EntityType == EntityType.Derived)
      {
        Check.Require(!String.IsNullOrEmpty(entity.ParentEntityName), 
                      String.Format("Missing parent entity name for derived entity '{0}'", entity));
        entityClass.BaseTypes.Add(new CodeTypeReference("global::" + entity.ParentEntityName));
      }
      else if (!String.IsNullOrEmpty(entity.CustomBaseClassName))
      {
        entityClass.BaseTypes.Add(new CodeTypeReference("global::" + entity.CustomBaseClassName));
      }
      else
      {
        entityClass.BaseTypes.Add(new CodeTypeReference(typeof(DataObject).FullName));
      }

      if (entity.EntityType != EntityType.SelfRelationship)
      {
        entityClass.BaseTypes.Add(new CodeTypeReference("global::" + Name.GetInterfaceFullName(entity.FullName)));
      }
      if (entity.RecordHistory)
      {
        entityClass.BaseTypes.Add(new CodeTypeReference(typeof(IRecordHistory)));
      }
      if (entity.EntityType == EntityType.Compound)
      {
        entityClass.BaseTypes.Add(new CodeTypeReference(typeof(ICompound)));
      }
      #endregion

      #region Add Pre-defined properties

      if (entity.EntityType != EntityType.Derived)
      {
        foreach (Property property in entity.PreDefinedProperties)
        {
          GenerateProperty(entityClass, property);
        }
      }

      #endregion

      #region Add constant for Id Property
      constPublicField = new CodeMemberField(typeof(String), "Property_Id");

      // Resets the access and scope mask bit flags of the member attributes of the field
      // before setting the member attributes of the field to public and constant.
      constPublicField.Attributes = (constPublicField.Attributes & ~MemberAttributes.AccessMask & ~MemberAttributes.ScopeMask) | MemberAttributes.Public | MemberAttributes.Const;

      constPublicField.InitExpression = new CodeSnippetExpression("\"Id\"");
      entityClass.Members.Add(constPublicField);
      #endregion

      #region Add BusinessKey Property
      GenerateBusinessKeyProperty(entityClass, entity);
      #endregion

      #region Add Basic properties
      foreach (Property property in entity.Properties)
      {
        if (property.IsBusinessKey) continue;
        GenerateProperty(entityClass, property);
      }
      #endregion

      #region Add Parent/Children Properties for entities with self-relationship
      //if (entity.HasSelfRelationship)
      //{
      //  GenerateSelfRelationshipItems(entityClass, entity);
      //}
      #endregion

      #region Add IRecordHistory Members
      if (entity.RecordHistory)
      {
        GenerateIRecordHistoryMembers(entityClass, entity);
      }
      #endregion

      #region Add Entity Specific Members
      
      if (entity.EntityType == EntityType.SelfRelationship)
      {
        var selfRelationshipEntity = entity as SelfRelationshipEntity;
        Check.Require(selfRelationshipEntity != null, String.Format("Cannot convert entity '{0}' to SelfRelationshipEntity", entity));
        GenerateSelfRelationshipEntityMembers(entityClass, selfRelationshipEntity);
      }
      else if (entity.EntityType == EntityType.Relationship)
      {
        var relationshipEntity = entity as RelationshipEntity;
        Check.Require(relationshipEntity != null, String.Format("Cannot convert entity '{0}' to RelationshipEntity", entity));
        GenerateRelationshipEntityMembers(entityClass, relationshipEntity);
      }
    
      #endregion

      #region Add RelationshipEntity Members
     
      #endregion

      #region Add Relationship Properties

      var relationshipPropertiesToNull = new Dictionary<string, string>();
      var relationshipPropertiesToNewList = new Dictionary<string, CodeExpression>();
      var businessKeyPropertiesToSet = new Dictionary<string, string>();
      var relationshipNames = new List<string>();
      var businesKeyPropertyForSingleEndedAssociations = new List<string>();
      var idPropertyForSingleEndedAssociations = new List<string>();

      foreach (Relationship relationship in entity.Relationships)
      {
        relationshipNames.Add(relationship.RelationshipEntity.RelationshipName);
       
        if (relationship.RelationshipEntity.IsSelfRelationship && relationship.RelationshipEntity.HasSameSourceAndTarget)
        {
          Check.Require(relationship.RelationshipEntity.RelationshipType == RelationshipType.OneToMany,
                        String.Format("Can only hand one-to-many self relationships"));

          GenerateItemsForManyEnd(entityClass, 
                                  relationship,
                                  ref relationshipPropertiesToNewList,
                                  relationship.RelationshipEntity.SourceFieldNameForTarget, 
                                  relationship.RelationshipEntity.SourcePropertyNameForTarget);
          
          GenerateItemsForOneEnd(entityClass, relationship,
                                 ref relationshipPropertiesToNull,
                                 ref businessKeyPropertiesToSet,
                                 relationship.RelationshipEntity.TargetFieldNameForSource, 
                                 relationship.RelationshipEntity.TargetPropertyNameForSource);

         
        }
        else
        {
          if (relationship.End2.Multiplicity == Multiplicity.Many)
          {
            GenerateItemsForManyEnd(entityClass, relationship, ref relationshipPropertiesToNewList);
          }
          else if (relationship.End2.Multiplicity == Multiplicity.One)
          {
            GenerateItemsForOneEnd(entityClass, relationship, ref relationshipPropertiesToNull, ref businessKeyPropertiesToSet);
          }

          if (relationship.RelationshipEntity.HasJoinTable)
          {
            GenerateRelationshipEntityProperty(entityClass, relationship);
          }
        }
      }

      #region Add SetupRelationships 
      var setupRelationshipsMethod = new CodeMemberMethod();
      setupRelationshipsMethod.Name = "SetupRelationships";
      setupRelationshipsMethod.Attributes = MemberAttributes.Public | MemberAttributes.Override;
      entityClass.Members.Add(setupRelationshipsMethod);

      foreach (KeyValuePair<string, string> kvp in relationshipPropertiesToNull)
      {
        // if (ARAccount != null)
        // {
        //   ARAccountBusinessKey = ((DataObject)ARAccount).GetBusinessKey();  
        //   ARAccountId = ARAccount.Id;
        //   _aRAccount = null;
        // }
        string businessKeyPropertyNameOnThis = kvp.Key + "BusinessKey";
        string businessKeyPropertyNameOnOther;
        businessKeyPropertiesToSet.TryGetValue(businessKeyPropertyNameOnThis, out businessKeyPropertyNameOnOther);
        Check.Require(!String.IsNullOrEmpty(businessKeyPropertyNameOnOther));

        var ifCondition =
          new CodeConditionStatement
            (new CodeSnippetExpression(kvp.Key + " != null"),
               new CodeStatement[] 
               {
                 new CodeSnippetStatement(businessKeyPropertyNameOnThis + " = ((global::" + typeof(DataObject).FullName + ")" + kvp.Key + ").GetBusinessKey();"),
                 new CodeSnippetStatement(kvp.Key + "Id = " + kvp.Key + ".Id;"),
                 new CodeSnippetStatement("_" + kvp.Key.LowerCaseFirst() + " = null;")
               });

        setupRelationshipsMethod.Statements.Add(ifCondition);

        businesKeyPropertyForSingleEndedAssociations.Add(businessKeyPropertyNameOnThis);
        idPropertyForSingleEndedAssociations.Add(kvp.Key + "Id");
      }

      foreach (KeyValuePair<string, CodeExpression> kvp in relationshipPropertiesToNewList)
      {
        var assignment = new CodeAssignStatement(new CodeSnippetExpression(kvp.Key), kvp.Value);
        setupRelationshipsMethod.Statements.Add(assignment);
      }
      #endregion

      #region Add constants for relationship names
      foreach (string relationshipName in relationshipNames)
      {
        if (String.IsNullOrEmpty(relationshipName)) continue;

        constPublicField = new CodeMemberField(typeof(String), "Relationship_" + relationshipName);

        // Resets the access and scope mask bit flags of the member attributes of the field
        // before setting the member attributes of the field to public and constant.
        constPublicField.Attributes = (constPublicField.Attributes & ~MemberAttributes.AccessMask & ~MemberAttributes.ScopeMask) | MemberAttributes.Public | MemberAttributes.Const;

        constPublicField.InitExpression = new CodeSnippetExpression("\"" + relationshipName + "\"");
        entityClass.Members.Add(constPublicField);
      }
      #endregion

      #endregion

      #region Generate Clone Method
      GenerateCloneMethod(entityClass, entity, businesKeyPropertyForSingleEndedAssociations, idPropertyForSingleEndedAssociations);
      #endregion

      #region Generate Save Method
      var saveMethod = new CodeMemberMethod();
      saveMethod.Name = "Save";
      saveMethod.Attributes = MemberAttributes.Public;
      entityClass.Members.Add(saveMethod);

      // var item = this;
      // StandardRepository.Instance.SaveInstance(ref item);
      saveMethod.Statements.Add(new CodeAssignStatement(new CodeSnippetExpression("var item"),
                                                        new CodeSnippetExpression("this")));
      saveMethod.Statements.Add
        (new CodeSnippetExpression("global::" + typeof(StandardRepository).FullName + ".Instance.SaveInstance(ref item)"));
      #endregion

      #region Generate UpdateRelationships
      GenerateCopyPropertiesFrom(entityClass, entity);
      #endregion

      #region Add GetKnownTypes
      GenerateGetKnownTypes(entityClass, entity);
      #endregion

      #region Add ICompound Members for Compound Entity
      if (entity.EntityType == EntityType.Compound)
      {
        GenerateICompoundMembers(entityClass, entity);
      }
      #endregion

      #region Generate BusinessKey Class
      CodeTypeDeclaration businessKeyClass = GenerateBusinessKeyClass(entityClass, entity);
      codeNamespace.Types.Add(businessKeyClass);
      #endregion

      #region Generate Legacy Class for Compound Entity
      if (entity.EntityType == EntityType.Compound)
      {
        CodeTypeDeclaration legacyClass = GenerateLegacyClass(entity);
        codeNamespace.Types.Add(legacyClass);
      }
      #endregion

      // Generate the file content
      return CodeGeneratorUtil.GetFileContent(codeCompileUnit);
    }

    #region Private Methods
    private static void GenerateCopyPropertiesFrom(CodeTypeDeclaration entityClass, Entity entity)
    {
      var copyPropertiesFromMethod = new CodeMemberMethod();
      copyPropertiesFromMethod.Name = "CopyPropertiesFrom";
      copyPropertiesFromMethod.Attributes = MemberAttributes.Public | MemberAttributes.Override;
      string dataObjectParameter = "dataObject";
      copyPropertiesFromMethod.Parameters.Add(new CodeParameterDeclarationExpression("global::" + typeof(DataObject).FullName, dataObjectParameter));
      entityClass.Members.Add(copyPropertiesFromMethod);

      copyPropertiesFromMethod.Statements.Add
        (new CodeAssignStatement
          (new CodeSnippetExpression("var item"),
           new CodeSnippetExpression("dataObject as global::" + entity.FullName)));

      List<Property> foreignKeyProperties = entity.GetForeignKeyProperties();
      foreach(Property property in foreignKeyProperties)
      {
        // if (item.ARAccount != null)
        // {
        //   ARAccount = item.ARAccount;
        // }
        // else 
        // {
        //   if (item.ARAccount == null && item.ARAccountId == null)
        //   {
        //     ARAccount = null;
        //   }
        // }
        var outerIfCondition =
          new CodeConditionStatement
            (new CodeSnippetExpression("item." + property.Name + " != null"),
             new CodeStatement[]
               {
                 new CodeAssignStatement(new CodeSnippetExpression(property.Name), new CodeSnippetExpression("item." + property.Name))
               });

        var innerIfCondition =
          new CodeConditionStatement
            (new CodeSnippetExpression("item." + property.Name + " == null && " + "item." + property.Name + "Id == null"),
             new CodeStatement[]
               {
                 new CodeAssignStatement(new CodeSnippetExpression(property.Name), new CodeSnippetExpression("null"))
               });

        outerIfCondition.FalseStatements.Add(innerIfCondition);
        copyPropertiesFromMethod.Statements.Add(outerIfCondition);
      }

      // Basic properties
      foreach(Property property in entity.Properties)
      {
        if (property.IsBusinessKey) continue;
        copyPropertiesFromMethod.Statements.Add
          (new CodeAssignStatement
              (new CodeSnippetExpression(property.Name), 
               new CodeSnippetExpression("item." + property.Name)));
      }

      // BusinessKey
      copyPropertiesFromMethod.Statements.Add
          (new CodeAssignStatement
            (new CodeSnippetExpression(Name.GetBusinessKeyPropertyName(entity.FullName)),
             new CodeSnippetExpression("item." + Name.GetBusinessKeyPropertyName(entity.FullName))));
    }

    private static void GenerateCloneMethod(CodeTypeDeclaration entityClass, 
                                            Entity entity,
                                            List<string> businessKeyPropertyForSingleEndedAssociations,
                                            List<string> idPropertyForSingleEndedAssociations)
    {
      // object Clone()

      var cloneMethod = new CodeMemberMethod();
      cloneMethod.Name = "Clone";
      cloneMethod.ReturnType = new CodeTypeReference(typeof(object));
      cloneMethod.Attributes = MemberAttributes.Public;

      // var _entityName = new EntityName();
      string cloneVariable = "_" + entity.ClassName.LowerCaseFirst();
      var assignment =
        new CodeAssignStatement(new CodeSnippetExpression("var " + cloneVariable),
                                new CodeSnippetExpression("new global::" + entity.FullName + "()"));
      cloneMethod.Statements.Add(assignment);

      // business key
      string businessKeyClassName = Name.GetEntityBusinessKeyClassName(entity.FullName);
      string businessKeyFullName = Name.GetEntityBusinessKeyFullName(entity.FullName);

      assignment =
        new CodeAssignStatement(new CodeSnippetExpression(cloneVariable + "." + businessKeyClassName),
                                new CodeSnippetExpression("(global::" + businessKeyFullName + ")" + businessKeyClassName + ".Clone()"));
                                
      cloneMethod.Statements.Add(assignment);

      // properties
      foreach(Property property in entity.Properties)
      {
        if (property.IsBusinessKey) continue;
        assignment = new CodeAssignStatement(new CodeSnippetExpression(cloneVariable + "." + property.Name),
                                             new CodeSnippetExpression(property.Name));
        cloneMethod.Statements.Add(assignment);
      }

      foreach (string businessKeyProperty in businessKeyPropertyForSingleEndedAssociations)
      {
        var ifCondition =
          new CodeConditionStatement
            (new CodeSnippetExpression(businessKeyProperty + " != null"),
               new CodeStatement[] 
               {
                 new CodeAssignStatement(new CodeSnippetExpression(cloneVariable + "." + businessKeyProperty),
                                         new CodeSnippetExpression("(" + typeof(BusinessKey).FullName + ")" + businessKeyProperty + ".Clone()"))
               });

        cloneMethod.Statements.Add(ifCondition);
      }

      foreach (string idProperty in idPropertyForSingleEndedAssociations)
      {
        assignment = new CodeAssignStatement(new CodeSnippetExpression(cloneVariable + "." + idProperty),
                                             new CodeSnippetExpression(idProperty));

        cloneMethod.Statements.Add(assignment);
      }

      // return
      cloneMethod.Statements.Add(new CodeMethodReturnStatement(new CodeSnippetExpression(cloneVariable)));

      entityClass.Members.Add(cloneMethod);
    }

    private static void GenerateICompoundMembers(CodeTypeDeclaration entityClass, Entity entity)
    {
      #region Legacy Property
      string fieldName = "_legacyObject";
      string propertyName = "LegacyObject";
      string typeName = "global::" + Name.GetLegacyFullName(entity.FullName);

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
      #endregion

      #region Generate TransferDataFromLegacy method
      var method = new CodeMemberMethod();
      entityClass.Members.Add(method);
      method.Name = "TransferDataFromLegacy";
      method.Attributes = MemberAttributes.Public;

      var ifCondition = 
        new CodeConditionStatement(new CodeSnippetExpression("LegacyObject == null"), 
                                   new CodeSnippetStatement("return;"));
      method.Statements.Add(ifCondition);

      List<Property> compoundProperties = entity.Properties.FindAll(p => p.IsCompound);
      
      CodeAssignStatement assignment;

      foreach(Property property in compoundProperties)
      {
        var lhs = property.IsBusinessKey ?
                    new CodeSnippetExpression("BusinessKey." + property.Name) :
                    new CodeSnippetExpression(property.Name);

        if (property.IsEnum)
        {
          assignment =
            new CodeAssignStatement(lhs,
                                    new CodeSnippetExpression("(" + property.TypeName + ")ConvertDbValueToCSharpEnum(LegacyObject." + property.Name + ", \"" + property.Name + "\")"));
        }
        else
        {
          assignment =
            new CodeAssignStatement(lhs,
                                    new CodeSnippetExpression("LegacyObject." + property.Name));
        }
        

        method.Statements.Add(assignment);
      }
      #endregion

      #region Generate TransferDataToLegacy method
      method = new CodeMemberMethod();
      entityClass.Members.Add(method);
      method.Name = "TransferDataToLegacy";
      method.Attributes = MemberAttributes.Public;

      compoundProperties = entity.Properties.FindAll(p => p.IsCompound);

      assignment =
        new CodeAssignStatement(new CodeSnippetExpression("LegacyObject"),
                                new CodeSnippetExpression("new global::" + Name.GetLegacyFullName(entity.FullName) + "()"));
      method.Statements.Add(assignment);

      foreach (Property property in compoundProperties)
      {
        var rhs = property.IsBusinessKey ?
                   new CodeSnippetExpression("BusinessKey." + property.Name) :
                   new CodeSnippetExpression(property.Name);

        if (property.IsEnum)
        {
          string prefix = property.IsRequired ? "(int)" : String.Empty;
          assignment =
            new CodeAssignStatement(new CodeSnippetExpression("LegacyObject." + property.Name),
                                    new CodeSnippetExpression(prefix + "ConvertCSharpEnumToDbValue(" + rhs.Value + ", \"" + property.Name + "\")"));
        }
        else
        {
          assignment =
            new CodeAssignStatement(new CodeSnippetExpression("LegacyObject." + property.Name), rhs);
        }
       

        method.Statements.Add(assignment);
      }
      #endregion
    }

    private static void GenerateIRecordHistoryMembers(CodeTypeDeclaration entityClass, Entity entity)
    {
      var method = new CodeMemberMethod();
      method.Name = "GetHistoryObject";
      method.ReturnType = new CodeTypeReference(typeof(BaseHistory));
      method.Attributes = MemberAttributes.Public;

      //var siteHistory = new SiteHistory();
      string variable = "_" + Name.GetEntityHistoryClassName(entity.FullName).LowerCaseFirst();
      var assignment =
        new CodeAssignStatement(new CodeSnippetExpression("var " + variable),
                                new CodeSnippetExpression("new " + "global::" + Name.GetEntityHistoryTypeName(entity.FullName) + "()"));
      method.Statements.Add(assignment);

      //siteHistory.Id = Id;
      assignment =
       new CodeAssignStatement(new CodeSnippetExpression(variable + ".Id"),
                               new CodeSnippetExpression("Id"));
      method.Statements.Add(assignment);

      //siteHistory.DataObjectVersion = _Version;
      assignment =
       new CodeAssignStatement(new CodeSnippetExpression(variable + "." + Property.VersionPropertyName),
                               new CodeSnippetExpression(Property.VersionPropertyName));
      method.Statements.Add(assignment);

      //siteHistory.BusinessKey = BusinessKey;
      assignment =
       new CodeAssignStatement(new CodeSnippetExpression(variable + "." + entity.BusinessKeyPropertyName),
                               new CodeSnippetExpression(entity.BusinessKeyPropertyName));
      method.Statements.Add(assignment);

      foreach (Property property in entity.Properties)
      {
        if (property.IsBusinessKey)
        {
          // The BusinessKey property is assigned already
          continue;
        }
        
        if (property.RecordHistory)
        {
          assignment =
            new CodeAssignStatement(new CodeSnippetExpression(variable + "." + property.Name),
                                    new CodeSnippetExpression(property.Name));
          method.Statements.Add(assignment);
        }
      }

      // return statement
      method.Statements.Add(new CodeMethodReturnStatement(new CodeSnippetExpression(variable)));

      entityClass.Members.Add(method);
    }

    private static void GenerateBusinessKeyProperty(CodeTypeDeclaration entityClass, Entity entity)
    {
      string fieldName = entity.BusinessKeyFieldName;
      string propertyName = entity.BusinessKeyPropertyName;
      string typeName = "global::" + Name.GetEntityBusinessKeyFullName(entity.FullName);
        //entity.EntityType == EntityType.SelfRelationship
        //  ? "global::" + Name.GetEntityBusinessKeyFullName(entity.FullName)
        //  : "global::" + Name.GetEntityBusinessKeyInterfaceFullName(entity.FullName);

      var field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(typeName);

      field.InitExpression =
        new CodeSnippetExpression("new " + Name.GetEntityBusinessKeyClassName(entity.FullName) + "()");
      

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

      if (!String.IsNullOrEmpty(property.DefaultValue))
      {
        field.InitExpression = new CodeSnippetExpression(property.GetCodeSnippetForInitializingFieldWithDefaultValueInT4Template());
      }

      entityClass.Members.Add(field);

      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = property.Name;
      codeProperty.Type = new CodeTypeReference(typeName);
      if (InheritanceGraph.IsPropertyOverridable(property.Name, property.Entity.FullName) || 
          property.IsBasePredefined() ||
          property.IsCustomBaseClassProperty)
      {
        // this makes it public override
        codeProperty.Attributes = MemberAttributes.Public | MemberAttributes.Override;
      }
      else
      {
        // this makes it public virtual 
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

    private static void GenerateSelfRelationshipEntityMembers(CodeTypeDeclaration entityClass, 
                                                              SelfRelationshipEntity selfRelationshipEntity)
    {
      // Parent Field
      string fieldName = "_parent";
      var field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference("global::" + selfRelationshipEntity.EntityName);

      entityClass.Members.Add(field);

      // Parent Property
      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = "Parent";
      codeProperty.Type = new CodeTypeReference("global::" + selfRelationshipEntity.EntityName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));
      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));

      entityClass.Members.Add(codeProperty);

      // Child Field
      fieldName = "_child";
      field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference("global::" + selfRelationshipEntity.EntityName);

      entityClass.Members.Add(field);

      // Parent Property
      codeProperty = new CodeMemberProperty();
      codeProperty.Name = "Child";
      codeProperty.Type = new CodeTypeReference("global::" + selfRelationshipEntity.EntityName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));
      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));

      entityClass.Members.Add(codeProperty);
    }

    private static void GenerateRelationshipEntityMembers(CodeTypeDeclaration entityClass, RelationshipEntity relationshipEntity)
    {
      
      // Source Field
      string fieldName = relationshipEntity.GetSourceEntityFieldName();
      var field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference("global::" + relationshipEntity.GetSourceEntityInterfaceName());

      entityClass.Members.Add(field);

      // Source Property
      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = relationshipEntity.GetSourceEntityClassName();
      codeProperty.Type = new CodeTypeReference("global::" + relationshipEntity.GetSourceEntityInterfaceName());
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));
      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));

      entityClass.Members.Add(codeProperty);
    
      // Target Field
      fieldName = relationshipEntity.GetTargetEntityFieldName();
      field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference("global::" + relationshipEntity.GetTargetEntityInterfaceName());

      entityClass.Members.Add(field);

      // Target Property
      codeProperty = new CodeMemberProperty();
      codeProperty.Name = relationshipEntity.GetTargetEntityClassName();
      codeProperty.Type = new CodeTypeReference("global::" + relationshipEntity.GetTargetEntityInterfaceName());
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));
      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));
      entityClass.Members.Add(codeProperty);

      #region SetRelationshipItem method
      var method = new CodeMemberMethod();
      method.Name = "SetRelationshipItem";
      method.ReturnType = new CodeTypeReference(typeof(void));
      method.Attributes = MemberAttributes.Public;
      method.Parameters.Add(new CodeParameterDeclarationExpression(typeof(object), "item"));

      var parentIf = new CodeConditionStatement();
      parentIf.Condition = new CodeSnippetExpression("item is global::" + relationshipEntity.GetSourceEntityInterfaceName());

      var assignment = 
        new CodeAssignStatement(new CodeSnippetExpression(Name.GetEntityClassName(relationshipEntity.SourceEntityName)),
                                new CodeSnippetExpression("item as global::" + relationshipEntity.GetSourceEntityInterfaceName()));
    
      parentIf.TrueStatements.Add(assignment);

      var innerIf = new CodeConditionStatement();
      innerIf.Condition = new CodeSnippetExpression("item is global::" + relationshipEntity.GetTargetEntityInterfaceName());

      assignment =
        new CodeAssignStatement(new CodeSnippetExpression(Name.GetEntityClassName(relationshipEntity.TargetEntityName)),
                                new CodeSnippetExpression("item as global::" + relationshipEntity.GetTargetEntityInterfaceName()));
    
      innerIf.TrueStatements.Add(assignment);
      innerIf.FalseStatements.Add(
        new CodeThrowExceptionStatement(
          new CodeSnippetExpression("new ApplicationException(\"Invalid argument\")")));

      parentIf.FalseStatements.Add(innerIf);

      method.Statements.Add(parentIf);
      entityClass.Members.Add(method);
      #endregion
    }

    /// <summary>
    ///   Generate the items that are required for a self relationship.
    ///   - Parent property
    ///   - Children property
    ///   - EntitySelfRelationshipList
    /// </summary>
    /// <param name="entityClass"></param>
    /// <param name="entity"></param>
    private static void GenerateSelfRelationshipItems(CodeTypeDeclaration entityClass, Entity entity)
    {
      string parentTypeName = "global::" + entity.FullName;
      string childTypeName = "IList<global::" + entity.FullName + ">";

      // Generate Parent
      var fieldName = "_parent";

      var field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(parentTypeName);

      entityClass.Members.Add(field);

      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = "Parent";
      codeProperty.Type = new CodeTypeReference(parentTypeName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));
      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));
      entityClass.Members.Add(codeProperty);
      
      // Generate Children
      fieldName = "_children";

      field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(childTypeName);
      field.InitExpression = new CodeSnippetExpression("new List<global::" + entity.FullName + ">()");

      entityClass.Members.Add(field);

      codeProperty = new CodeMemberProperty();
      codeProperty.Name = "Children";
      codeProperty.Type = new CodeTypeReference(childTypeName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));
      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));
      entityClass.Members.Add(codeProperty);

      // Generate self relationship list for parent
      Check.Require(entity.SelfRelationshipEntity != null,
                    String.Format("Cannot find SelfRelationshipEntity on entity '{0}'", entity));

      var typeName = "IList<global::" + entity.SelfRelationshipEntity.FullName + ">";

      field = new CodeMemberField();
      field.Name = entity.SelfRelationshipEntity.GetParentFieldName();
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(typeName);
      field.InitExpression = new CodeSnippetExpression("new List<global::" + entity.SelfRelationshipEntity.FullName + ">()");
      entityClass.Members.Add(field);

      codeProperty = new CodeMemberProperty();
      codeProperty.Name = entity.SelfRelationshipEntity.GetParentPluralName();
      codeProperty.Type = new CodeTypeReference(typeName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(
        new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(
        new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name),
                                new CodePropertySetValueReferenceExpression()));

      entityClass.Members.Add(codeProperty);

      // Generate self relationship list for child
      field = new CodeMemberField();
      field.Name = entity.SelfRelationshipEntity.GetChildFieldName();
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(typeName);
      field.InitExpression = new CodeSnippetExpression("new List<global::" + entity.SelfRelationshipEntity.FullName + ">()");
      entityClass.Members.Add(field);

      codeProperty = new CodeMemberProperty();
      codeProperty.Name = entity.SelfRelationshipEntity.GetChildPluralName();
      codeProperty.Type = new CodeTypeReference(typeName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(
        new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(
        new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name),
                                new CodePropertySetValueReferenceExpression()));

      entityClass.Members.Add(codeProperty);

   
      #region Generate AddChild method

      var method = new CodeMemberMethod();
      method.Name = "AddChild";
      method.ReturnType = new CodeTypeReference(typeof(DataObject).FullName);
      method.Attributes = MemberAttributes.Public;
      method.Parameters.Add(new CodeParameterDeclarationExpression("global::" + entity.FullName, "child"));

      var assignment =
        new CodeAssignStatement(new CodeSnippetExpression("var type"),
                                new CodeSnippetExpression("System.Type.GetType(\"" + Name.GetEntityAssemblyQualifiedName(entity.SelfRelationshipEntity.FullName) + "\", true)"));
      method.Statements.Add(assignment);

      assignment =
        new CodeAssignStatement(new CodeSnippetExpression("global::" + entity.SelfRelationshipEntity.FullName + " selfRelationshipDataObject"),
                                new CodeSnippetExpression("Activator.CreateInstance(type, false) as global::" + entity.SelfRelationshipEntity.FullName));
      method.Statements.Add(assignment);

      assignment =
        new CodeAssignStatement(new CodeSnippetExpression("selfRelationshipDataObject.Parent"),
                                new CodeSnippetExpression("this"));
      method.Statements.Add(assignment);

      assignment =
        new CodeAssignStatement(new CodeSnippetExpression("selfRelationshipDataObject.Child"),
                                new CodeSnippetExpression("child"));
      method.Statements.Add(assignment);

      var invokeExpression =
        new CodeMethodInvokeExpression(new CodeSnippetExpression(entity.SelfRelationshipEntity.GetChildPluralName()),
                                                                 "Add",
                                                                 new[] { new CodeSnippetExpression("selfRelationshipDataObject") });
      method.Statements.Add(invokeExpression);

      invokeExpression =
        new CodeMethodInvokeExpression(new CodeSnippetExpression("Children"),
                                                                 "Add",
                                                                 new[] { new CodeSnippetExpression("child") });
      method.Statements.Add(invokeExpression);

      method.Statements.Add(new CodeMethodReturnStatement(new CodeVariableReferenceExpression("(" + typeof(DataObject).FullName + ")selfRelationshipDataObject")));

      entityClass.Members.Add(method);

      #endregion
    }

    private static void GenerateItemsForManyEnd(CodeTypeDeclaration entityClass,
                                                Relationship relationship,
                                                ref Dictionary<string, CodeExpression> relationshipPropertyToNewList,
                                                string inputFieldName = null,
                                                string inputPropertyName = null)
    {
      string fieldName = String.IsNullOrEmpty(inputFieldName) ? relationship.End1.PropertyFieldName : inputFieldName;
      string fieldTypeName = "IList<global::" + relationship.End2.EntityInterfaceName + ">";
      string propertyTypeName = "List<global::" + relationship.End2.EntityInterfaceName + ">";
          
      var field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(fieldTypeName);
      field.InitExpression = new CodeSnippetExpression("new List<global::" + relationship.End2.EntityInterfaceName + ">()");

      entityClass.Members.Add(field);

      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = String.IsNullOrEmpty(inputPropertyName) ? relationship.End1.PropertyName : inputPropertyName;
      if (!relationship.RelationshipEntity.HasJoinTable)
      {
        relationshipPropertyToNewList.Add(codeProperty.Name, field.InitExpression);
      }
      codeProperty.Attributes = MemberAttributes.Public;

      //if (relationship.RelationshipEntity.HasJoinTable)
      //{
      codeProperty.Type = new CodeTypeReference(propertyTypeName);

      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeSnippetExpression(field.Name + " as " + propertyTypeName)));
          // new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(
        new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name),
                                new CodePropertySetValueReferenceExpression()));

      // Add the [DataMember] attribute
      // codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));

      //}
      //else
      //{
      //  codeProperty.Type =
      //    new CodeTypeReference("ReadOnlyCollection<global::" + relationship.End2.EntityInterfaceName + ">");

      //  // get { return new ReadOnlyCollection<OrderLine>(_orderLines); }
      //  codeProperty.GetStatements.Add(
      //    new CodeMethodReturnStatement(new CodeSnippetExpression("new System.Collections.ObjectModel.ReadOnlyCollection<global::" + relationship.End2.EntityInterfaceName + ">(" + fieldName + ")")));
      //  // Add DataMember to field
      //  field.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName,
      //                                                          new [] { new CodeAttributeArgument("Name", new CodeSnippetExpression("\"" + codeProperty.Name + "\"")) }));
      //}
      
      entityClass.Members.Add(codeProperty);
      
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
      //method.Parameters.Add(new CodeParameterDeclarationExpression(
      //                        "global::" + relationship.End2.EntityInterfaceName, "item"));
      
      //var ifStatement = new CodeConditionStatement();
      //ifStatement.Condition = new CodeSnippetExpression("!" + fieldName + ".Contains(item)");

      //var invokeExpression =
      //  new CodeMethodInvokeExpression(new CodeSnippetExpression(fieldName),
      //                                  "Add",
      //                                  new[] { new CodeSnippetExpression("item") });
      //ifStatement.TrueStatements.Add(invokeExpression);

      //var assignment =
      //  new CodeAssignStatement(new CodeSnippetExpression("item." + relationship.RelationshipEntity.TargetPropertyNameForSource),
      //                          new CodeSnippetExpression("this"));

      //ifStatement.TrueStatements.Add(assignment);

      //method.Statements.Add(ifStatement);
      
      
      //entityClass.Members.Add(method);
    
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
      //method.Parameters.Add(new CodeParameterDeclarationExpression(
      //                      "global::" + relationship.End2.EntityInterfaceName, "item"));
      
      //ifStatement = new CodeConditionStatement();
      //ifStatement.Condition = new CodeSnippetExpression(fieldName + ".Contains(item)");

      //invokeExpression =
      //  new CodeMethodInvokeExpression(new CodeSnippetExpression(fieldName),
      //                                  "Remove",
      //                                  new[] { new CodeSnippetExpression("item") });
      //ifStatement.TrueStatements.Add(invokeExpression);

      //var removeAssignment =
      //  new CodeAssignStatement(new CodeSnippetExpression("item." + relationship.RelationshipEntity.TargetPropertyNameForSource),
      //                          new CodeSnippetExpression("null"));

      //ifStatement.TrueStatements.Add(removeAssignment);

      //method.Statements.Add(ifStatement);
     

      //entityClass.Members.Add(method);

      //#endregion
    }

    private static void GenerateItemsForOneEnd(CodeTypeDeclaration entityClass,
                                               Relationship relationship,
                                               ref  Dictionary<string, string> relationshipPropertiesToClear,
                                               ref Dictionary<string, string> businessKeyPropertiesToSet,
                                               string inputFieldName = null,
                                               string inputPropertyName = null)
    {
      string fieldName = String.IsNullOrEmpty(inputFieldName) ? relationship.End1.PropertyFieldName : inputFieldName;
      string propertyName = String.IsNullOrEmpty(inputPropertyName) ? relationship.End1.PropertyName : inputPropertyName;
      string typeName = "global::" + relationship.End2.EntityInterfaceName;

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

      // Add the [DataMember] attribute
      // codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));
      entityClass.Members.Add(codeProperty);

      if (relationship.RelationshipEntity.HasJoinTable)
      {
        return;
      }

      relationshipPropertiesToClear.Add(codeProperty.Name, "global::" + relationship.End2.EntityTypeName);
      
      #region Generate BusinessKey property

      string businessKeyFieldName = fieldName + "BusinessKey";
      string businessKeyPropertyName = propertyName + "BusinessKey";
      string businessKeyTypeName = "global::" + typeof(BusinessKey).FullName;

      field = new CodeMemberField();
      field.Name = businessKeyFieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(businessKeyTypeName);

      entityClass.Members.Add(field);

      codeProperty = new CodeMemberProperty();
      codeProperty.Name = businessKeyPropertyName;
      codeProperty.Type = new CodeTypeReference(businessKeyTypeName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));
      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));
      entityClass.Members.Add(codeProperty);

      businessKeyPropertiesToSet.Add(codeProperty.Name, Name.GetEntityBusinessKeyClassName(relationship.End2.EntityTypeName));
      #endregion

      #region Generate Id Property

      string idFieldName = fieldName + "Id";
      string idPropertyName = propertyName + "Id";
      string idTypeName = "System.Nullable<System.Guid>";

      field = new CodeMemberField();
      field.Name = idFieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(idTypeName);

      entityClass.Members.Add(field);

      codeProperty = new CodeMemberProperty();
      codeProperty.Name = idPropertyName;
      codeProperty.Type = new CodeTypeReference(idTypeName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name), new CodePropertySetValueReferenceExpression()));
      // Add the [DataMember] attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));
      entityClass.Members.Add(codeProperty);

      #endregion

      #region Generate Clear method
      var clearMethod = new CodeMemberMethod();
      clearMethod.Name = "Clear" + propertyName;
      clearMethod.Attributes = MemberAttributes.Public;
      entityClass.Members.Add(clearMethod);

      var assignment = new CodeAssignStatement(new CodeSnippetExpression(fieldName), new CodeSnippetExpression("null"));
      clearMethod.Statements.Add(assignment);
      assignment = new CodeAssignStatement(new CodeSnippetExpression(businessKeyFieldName), new CodeSnippetExpression("null"));
      clearMethod.Statements.Add(assignment);
      assignment = new CodeAssignStatement(new CodeSnippetExpression(idFieldName), new CodeSnippetExpression("null"));
      clearMethod.Statements.Add(assignment);
      #endregion

      #region Generate Load method
      var loadMethod = new CodeMemberMethod();
      // Generate the following for the ARAccount property on AccountNote - 'LoadARAccount'
      loadMethod.Name = "Load" + propertyName;
      var returnType = "global::" + Name.GetInterfaceFullName(relationship.End2.EntityTypeName);
      loadMethod.ReturnType = new CodeTypeReference(returnType);
      loadMethod.Attributes = MemberAttributes.Public;
      entityClass.Members.Add(loadMethod);

      string loadInstanceForCodeSnippet;
      if (relationship.RelationshipEntity.HasSameSourceAndTarget)
      {
        // Generate the following for the ManagedBy property on ARAccount 
        // StandardRepository.Instance.LoadParent<ARAccount>(Id, "relationshipName");
        loadInstanceForCodeSnippet =
          "global::" + typeof(StandardRepository).FullName
           + ".Instance.LoadParent<global::" + relationship.End1.EntityTypeName + ">(Id, \"" +
                                               relationship.RelationshipEntity.RelationshipName + "\")";
      }
      else
      {
        // Generate the following for the ARAccount property on AccountNote 
        // StandardRepository.Instance.LoadInstanceFor("AccountNote", "ARAccount", Id, "relationshipName");
        loadInstanceForCodeSnippet =
          "global::" + typeof(StandardRepository).FullName
           + ".Instance.LoadInstanceFor(\"" + relationship.End2.EntityTypeName + "\", \"" +
                                              relationship.End1.EntityTypeName +
                                              "\", Id, \"" +
                                              relationship.RelationshipEntity.RelationshipName + "\")";
      }
      
      assignment = new CodeAssignStatement(new CodeSnippetExpression("object item"), new CodeSnippetExpression(loadInstanceForCodeSnippet));
      loadMethod.Statements.Add(assignment);

      loadMethod.Statements.Add
        (new CodeMethodReturnStatement
            (new CodeSnippetExpression("item == null ? null : (" + returnType + ")item")));

      #endregion
    }

    private static void GenerateRelationshipEntityProperty(CodeTypeDeclaration entityClass, Relationship relationship)
    {
      string fieldName = relationship.RelationshipEntity.GetFieldName();
      string typeName = "IList<global::" + relationship.RelationshipEntity.GetInterfaceFullName() + ">";

      var field = new CodeMemberField();
      field.Name = fieldName;
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(typeName);
      field.InitExpression = new CodeSnippetExpression("new List<global::" + relationship.RelationshipEntity.GetInterfaceFullName() + ">()");
      entityClass.Members.Add(field);

      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = relationship.RelationshipEntity.PluralName;
      codeProperty.Type = new CodeTypeReference(typeName);
      codeProperty.Attributes = MemberAttributes.Public;
      codeProperty.GetStatements.Add(
        new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(
        new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name),
                                new CodePropertySetValueReferenceExpression()));
    
      entityClass.Members.Add(codeProperty);

    }

    private static void GenerateGetKnownTypes(CodeTypeDeclaration entityClass, Entity entity)
    {
      var method = new CodeMemberMethod();
      method.Name = "GetKnownTypes";
      method.ReturnType = new CodeTypeReference("new System.Type[]");
      method.Attributes = MemberAttributes.Public | MemberAttributes.Static;

      var assignment = new CodeAssignStatement(new CodeSnippetExpression("var knownTypes"),
                                               new CodeSnippetExpression("new List<System.Type>()"));
      method.Statements.Add(assignment);

      CodeMethodInvokeExpression invokeExpression;
      foreach(Property property in entity.Properties)
      {
        if (property.IsEnum)
        {
          invokeExpression = 
            new CodeMethodInvokeExpression(new CodeSnippetExpression("knownTypes"),
                                           "Add",
                                           new[] { new CodeSnippetExpression("typeof(" + property.TypeName + ")") });
          method.Statements.Add(invokeExpression);

        }
      }

      // Add BusinessKey type
      invokeExpression =
        new CodeMethodInvokeExpression(new CodeSnippetExpression("knownTypes"),
                                       "Add",
                                       new[] { new CodeSnippetExpression("typeof(global::" + Name.GetEntityBusinessKeyFullName(entity.FullName) + ")") });
      method.Statements.Add(invokeExpression);

      method.Statements.Add(new CodeMethodReturnStatement(new CodeVariableReferenceExpression("knownTypes.ToArray()")));

      entityClass.Members.Add(method);
    }

    private static CodeTypeDeclaration GenerateBusinessKeyClass(CodeTypeDeclaration entityClass, Entity entity)
    {
      var businessKeyClass = new CodeTypeDeclaration(Name.GetEntityBusinessKeyClassName(entity.FullName));

      businessKeyClass.IsClass = true;
      businessKeyClass.IsPartial = true;
      businessKeyClass.Attributes = MemberAttributes.Public;

      // Add the [DataContract] attribute
      var dataContractAttribute = new CodeAttributeDeclaration(typeof(DataContractAttribute).FullName);
      dataContractAttribute.Arguments.Add(new CodeAttributeArgument("IsReference", new CodeSnippetExpression("true")));
      businessKeyClass.CustomAttributes.Add(dataContractAttribute);

      // Add the [Serializable] attribute
      var serializableAttribute = new CodeAttributeDeclaration(typeof(SerializableAttribute).FullName);
      businessKeyClass.CustomAttributes.Add(serializableAttribute);

      // Add base class
      businessKeyClass.BaseTypes.Add(typeof(BusinessKey));

      // Add interface
      if (entity.EntityType != EntityType.SelfRelationship)
      {
        businessKeyClass.BaseTypes.Add("global::" + Name.GetEntityBusinessKeyInterfaceFullName(entity.FullName));
      }

      #region Add the EntityFullName property
      var field = new CodeMemberField();
      field.Name = "_entityFullName";
      field.Attributes = MemberAttributes.Private;
      field.Type = new CodeTypeReference(typeof(String));
      field.InitExpression = new CodeSnippetExpression("\"" + entity.FullName + "\"");

      businessKeyClass.Members.Add(field);

      var codeProperty = new CodeMemberProperty();
      codeProperty.Name = "EntityFullName";
      codeProperty.Type = new CodeTypeReference(typeof(String));
      codeProperty.Attributes = MemberAttributes.Public | MemberAttributes.Override;
      codeProperty.GetStatements.Add(new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
      codeProperty.SetStatements.Add(
        new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name),
                                new CodeSnippetExpression("\"" + entity.FullName + "\"")));

      // Add the DataMember attribute
      codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));

      businessKeyClass.Members.Add(codeProperty);

      #endregion

      #region Generate Clone Method
      var cloneMethod = new CodeMemberMethod();
      cloneMethod.Name = "Clone";
      // var typeParameter = new CodeTypeParameter("T");
      // typeParameter.Constraints.Add(new CodeTypeReference(typeof(BusinessKey)));

      // cloneMethod.TypeParameters.Add(typeParameter);
      cloneMethod.ReturnType = new CodeTypeReference(typeof(object));
      cloneMethod.Attributes = MemberAttributes.Public | MemberAttributes.Override;
      
      //var businessKey = new ABusinessKey();
      string cloneVariable = "_businessKey";
      var assignment =
        new CodeAssignStatement(new CodeSnippetExpression("var " + cloneVariable),
                                new CodeSnippetExpression("new " + businessKeyClass.Name + "()"));
      cloneMethod.Statements.Add(assignment);

      // Initialize property values in the code below
      #endregion

      if (entity is RelationshipEntity || entity.InternalBusinessKey)
      {
        string fieldName = "_internalKey";
        string propertyName = "InternalKey";
        string typeName = "System.Guid";

        field = new CodeMemberField();
        field.Name = fieldName;
        field.Attributes = MemberAttributes.Private;
        field.Type = new CodeTypeReference(typeName);
        businessKeyClass.Members.Add(field);

        codeProperty = new CodeMemberProperty();
        codeProperty.Name = propertyName;
        codeProperty.Type = new CodeTypeReference(typeName);
        codeProperty.Attributes = MemberAttributes.Public;
        codeProperty.GetStatements.Add(
          new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
        codeProperty.SetStatements.Add(
          new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name),
                                  new CodePropertySetValueReferenceExpression()));
        // Add the [DataMember] attribute
        codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));

        businessKeyClass.Members.Add(codeProperty);

        // Add to Clone
        assignment = new CodeAssignStatement(new CodeSnippetExpression(cloneVariable + "." + propertyName),
                                             new CodeSnippetExpression(propertyName));
        cloneMethod.Statements.Add(assignment);

        #region Add constant for property name
        var constPublicField = new CodeMemberField(typeof(String), "Property_" + propertyName);

        // Resets the access and scope mask bit flags of the member attributes of the field
        // before setting the member attributes of the field to public and constant.
        constPublicField.Attributes = (constPublicField.Attributes & ~MemberAttributes.AccessMask & ~MemberAttributes.ScopeMask) | MemberAttributes.Public | MemberAttributes.Const;

        constPublicField.InitExpression = new CodeSnippetExpression("\"" + propertyName + "\"");
        entityClass.Members.Add(constPublicField);
        #endregion
      }
      else
      {
        foreach (Property property in entity.Properties)
        {
          if (property.IsBusinessKey)
          {
            string fieldName = property.FieldName;
            string propertyName = property.Name;
            string typeName = property.TypeName;

            field = new CodeMemberField();
            field.Name = fieldName;
            field.Attributes = MemberAttributes.Private;
            field.Type = new CodeTypeReference(typeName);
            businessKeyClass.Members.Add(field);

            codeProperty = new CodeMemberProperty();
            codeProperty.Name = propertyName;
            codeProperty.Type = new CodeTypeReference(typeName);
            codeProperty.Attributes = MemberAttributes.Public;
            codeProperty.GetStatements.Add(
              new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
            codeProperty.SetStatements.Add(
              new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name),
                                      new CodePropertySetValueReferenceExpression()));
            // Add the [DataMember] attribute
            codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));

            businessKeyClass.Members.Add(codeProperty);

            // Add to Clone
            assignment = new CodeAssignStatement(new CodeSnippetExpression(cloneVariable + "." + propertyName),
                                                 new CodeSnippetExpression(propertyName));
            cloneMethod.Statements.Add(assignment);

            #region Add constant for property name
            var constPublicField = new CodeMemberField(typeof(String), "Property_" + propertyName);

            // Resets the access and scope mask bit flags of the member attributes of the field
            // before setting the member attributes of the field to public and constant.
            constPublicField.Attributes = (constPublicField.Attributes & ~MemberAttributes.AccessMask & ~MemberAttributes.ScopeMask) | MemberAttributes.Public | MemberAttributes.Const;

            constPublicField.InitExpression = new CodeSnippetExpression("\"" + propertyName + "\"");
            entityClass.Members.Add(constPublicField);
            #endregion
          }
        }
      }

      // Add return statement to Clone
      cloneMethod.Statements.Add(new CodeMethodReturnStatement(new CodeSnippetExpression(cloneVariable)));
      businessKeyClass.Members.Add(cloneMethod);

      return businessKeyClass;
    }

    private static CodeTypeDeclaration GenerateLegacyClass(Entity entity)
    {
      Check.Require(entity.EntityType == EntityType.Compound, 
                    String.Format("Cannot generate legacy class for non-compound entity '{0}'", entity.FullName));

      var legacyClass = new CodeTypeDeclaration(Name.GetLegacyClassName(entity.FullName));

      legacyClass.IsClass = true;
      legacyClass.IsPartial = true;
      legacyClass.Attributes = MemberAttributes.Public;

      // Add the [Serializable] attribute
      var serializableAttribute = new CodeAttributeDeclaration(typeof(SerializableAttribute).FullName);
      legacyClass.CustomAttributes.Add(serializableAttribute);

      // Add base class
      legacyClass.BaseTypes.Add(typeof(LegacyObject));

      #region Generate Properties
      // Add the compound properties
      List<Property> compoundProperties = entity.Properties.FindAll(p => p.IsCompound);

      foreach (Property property in compoundProperties)
      {
        string fieldName = property.FieldName;
        string propertyName = property.Name;
        string typeName = property.IsEnum ? "System.Int32" : property.TypeName;
        if (!property.IsRequired && property.IsValueType)
        {
          typeName = "System.Nullable<" + typeName + ">";
        }

        var field = new CodeMemberField();
        field.Name = fieldName;
        field.Attributes = MemberAttributes.Private;
        field.Type = new CodeTypeReference(typeName);
        legacyClass.Members.Add(field);

        var codeProperty = new CodeMemberProperty();
        codeProperty.Name = propertyName;
        codeProperty.Type = new CodeTypeReference(typeName);
        codeProperty.Attributes = MemberAttributes.Public; 
        codeProperty.GetStatements.Add(
          new CodeMethodReturnStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name)));
        codeProperty.SetStatements.Add(
          new CodeAssignStatement(new CodeFieldReferenceExpression(new CodeThisReferenceExpression(), field.Name),
                                  new CodePropertySetValueReferenceExpression()));
        // Add the [DataMember] attribute
        codeProperty.CustomAttributes.Add(new CodeAttributeDeclaration(typeof(DataMemberAttribute).FullName));

        legacyClass.Members.Add(codeProperty);
      }
      #endregion

      #region Equals
      var method = new CodeMemberMethod();
      legacyClass.Members.Add(method);
      method.Name = "Equals";
      method.Attributes = MemberAttributes.Public | MemberAttributes.Override;
      method.ReturnType = new CodeTypeReference(typeof(Boolean));
      var param = new CodeParameterDeclarationExpression(typeof(Object), "obj");
      method.Parameters.Add(param);
      method.Statements.Add(new CodeSnippetStatement("return base.Equals(obj);"));
      #endregion

      #region GetHashCode
      method = new CodeMemberMethod();
      legacyClass.Members.Add(method);
      method.Name = "GetHashCode";
      method.Attributes = MemberAttributes.Public | MemberAttributes.Override;
      method.ReturnType = new CodeTypeReference(typeof(int));
      method.Statements.Add(new CodeSnippetStatement("return base.GetHashCode();"));
      #endregion


      return legacyClass;
    }
    #endregion
    
    #region Internal Properties
    internal static InheritanceGraph InheritanceGraph { get; set; }
    internal static BuildGraph BuildGraph { get; set; }
    #endregion
  }
}
