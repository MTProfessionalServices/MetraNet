using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using NHibernate.Util;

using MetraTech.Basic.Exception;
using MetraTech.Basic.Config;


namespace MetraTech.Basic
{
  [DataContract]
  [Serializable]
  public class QualifiedName
  {
    #region Constructors
    public QualifiedName()
    {
    }

    /// <summary>
    ///    typeName must be one of the following
    ///     (1) namespace qualified type name
    ///         e.g. MetraTech.BusinessEntity.Order
    ///     (2) assembly qualified type name
    ///         e.g. Metratech.BusinessEntity.Order, MetraTech.BusinessEntity
    ///     (3) type name without namespace as long as it is in the System namespace
    ///         e.g. String or string
    /// </summary>
    /// <param name="typeName"></param>
    /// <param name="tenant"></param>
    public QualifiedName(string typeName, string tenant)
    {
      Check.Require(tenant != null, "Argument 'tenant' cannot be null or empty", SystemConfig.CallerInfo);

      Initialize(typeName, true);
      Tenant = tenant;
    }

    /// <summary>
    ///    Constructor
    /// </summary>
    /// <param name="nameSpaceQualifiedTypeName"></param>
    /// <param name="assemblyName"></param>
    /// <param name="tenant"></param>
    public QualifiedName(string nameSpaceQualifiedTypeName, string assemblyName, string tenant)
    {
      Check.Require(assemblyName != null, "Argument 'assemblyName' cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(tenant != null, "Argument 'tenant' cannot be null or empty", SystemConfig.CallerInfo);

      Initialize(nameSpaceQualifiedTypeName, false);
      AssemblyName = assemblyName;
      Tenant = tenant;
    }
    #endregion

    #region Properties

    /// <summary>
    ///   Class name without the namespace.
    /// </summary>
    [DataMember]
    public string TypeName { get; set; }

    [DataMember]
    public string Namespace { get; set; }

    [DataMember]
    public string AssemblyName { get; set; }

    [DataMember]
    public string Tenant { get; set; }

    public string NamespaceQualifiedTypeName
    {
      get
      {
        return Namespace + "." + TypeName;
      }
    }

    public string AssemblyQualifiedTypeName
    {
      get
      {
        if (AssemblyName != null)
        {
          return NamespaceQualifiedTypeName + ", " + AssemblyName; 
        }

        return NamespaceQualifiedTypeName;
      }
    }

    
    #endregion

    #region Public Methods
    public override bool Equals(object obj)
		{
			QualifiedName other = obj as QualifiedName;

			if (other == null) return false;

      return String.Equals(AssemblyQualifiedTypeName, other.AssemblyQualifiedTypeName) && 
             String.Equals(Tenant, other.Tenant);
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int hashCode = 0;
				if (TypeName != null)
				{
					hashCode += TypeName.GetHashCode();
				}

				if (AssemblyName != null)
				{
					hashCode += AssemblyName.GetHashCode();
				}

        if (Tenant != null)
        {
          hashCode += Tenant.GetHashCode();
        }

				return hashCode;
			}
		}

		public override string ToString()
		{
			if (AssemblyName == null)
			{
				return TypeName;
			}

			return string.Concat(TypeName, ", ", AssemblyName);
		}

    public bool Validate(out List<ErrorObject> validationErrors)
    {
      validationErrors = new List<ErrorObject>();

      if (String.IsNullOrEmpty(TypeName))
      {
        var errorData = new ErrorData();
        errorData.ErrorCode = ErrorCode.QUALIFIED_NAME_VALIDATION_MISSING_TYPE_NAME;
        errorData.ErrorType = ErrorType.QualifedNameValidation;
        validationErrors.Add(new ErrorObject("QualifiedName validation failed. TypeName must be specified.", errorData));
      }

      if (AssemblyName != null)
      {
        if (String.IsNullOrEmpty(AssemblyName))
        {
          var errorData = new ErrorData();
          errorData.ErrorCode = ErrorCode.QUALIFIED_NAME_VALIDATION_MISSING_ASSEMBLY_NAME;
          errorData.ErrorType = ErrorType.QualifedNameValidation;
          validationErrors.Add(new ErrorObject("QualifiedName validation failed. AssemblyName must be specified.", errorData));
        }
      }

      if (String.IsNullOrEmpty(Tenant))
      {
        var errorData = new ErrorData();
        errorData.ErrorCode = ErrorCode.QUALIFIED_NAME_VALIDATION_MISSING_TENANT_NAME;
        errorData.ErrorType = ErrorType.QualifedNameValidation;
        validationErrors.Add(new ErrorObject("QualifiedName validation failed. Tenant must be specified.", errorData));
      }

      return validationErrors.Count > 0 ? false : true;
    }
    #endregion

    #region Private Methods
    private void Initialize(string typeName, bool setAssembly)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "Argument 'typeName' cannot be null or empty", SystemConfig.CallerInfo);

      AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(typeName);
      Check.Assert(assemblyQualifiedTypeName != null, "'assemblyQualifiedTypeName' cannot be null", SystemConfig.CallerInfo);
      Check.Assert(!String.IsNullOrEmpty(assemblyQualifiedTypeName.Type), "'assemblyQualifiedTypeName.Type' cannot be null", SystemConfig.CallerInfo);

      TypeName = StringHelper.GetClassname(assemblyQualifiedTypeName.Type);
      Check.Assert(!String.IsNullOrEmpty(TypeName), "'TypeName' cannot be null or empty", SystemConfig.CallerInfo);


      Namespace = StringHelper.Qualifier(StringHelper.GetFullClassname(assemblyQualifiedTypeName.Type));
      if (String.IsNullOrEmpty(Namespace))
      {
        if (typeAliases.ContainsKey(TypeName))
        {
          TypeName = typeAliases[TypeName];
        }

        if (Type.GetType("System." + TypeName) != null)
        {
          Namespace = "System";
        }
      }
      Check.Assert(!String.IsNullOrEmpty(Namespace), "'Namespace' cannot be null or empty", SystemConfig.CallerInfo);

      if (!String.IsNullOrEmpty(assemblyQualifiedTypeName.Assembly))
      {
        AssemblyName = assemblyQualifiedTypeName.Assembly;
      }
      else
      {
        if (setAssembly)
        {
          Type type = Type.GetType(Namespace + "." + TypeName, true);
          AssemblyName = type.Assembly.GetName().FullName;
        }
      }
    }
    #endregion

    #region Data
    private static readonly Dictionary<string, string> typeAliases = 
      new Dictionary<string, string>() {{"int", "Int32"},
                                        {"string", "String"}};

    #endregion
  }
}
