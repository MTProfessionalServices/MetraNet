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
  public class AssemblyQualifiedName
  {
    #region Constructors
    public AssemblyQualifiedName()
    {
    }

    /// <summary>
    ///    Constructor
    /// </summary>
    /// <param name="nameSpaceQualifiedTypeName"></param>
    /// <param name="assemblyName"></param>
    public AssemblyQualifiedName(string nameSpaceQualifiedTypeName, string assemblyName)
    {
      Check.Require(assemblyName != null, "Argument 'assemblyName' cannot be null or empty", SystemConfig.CallerInfo);
      Initialize(nameSpaceQualifiedTypeName);
      AssemblyName = assemblyName;
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
      AssemblyQualifiedName other = obj as AssemblyQualifiedName;

			if (other == null) return false;

      return String.Equals(AssemblyQualifiedTypeName, other.AssemblyQualifiedTypeName);
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

				return hashCode;
			}
		}

		public override string ToString()
		{
			return string.Concat(TypeName, ", ", AssemblyName);
		}

    public bool Validate(out List<ErrorObject> validationErrors)
    {
      validationErrors = new List<ErrorObject>();

      if (String.IsNullOrEmpty(TypeName))
      {
        validationErrors.Add(new ErrorObject("QualifiedName validation failed. TypeName must be specified."));
      }

      if (String.IsNullOrEmpty(AssemblyName))
      {
        validationErrors.Add(new ErrorObject("QualifiedName validation failed. AssemblyName object does not have a Name."));
      }
      
      return validationErrors.Count > 0 ? false : true;
    }
    #endregion

    #region Private Methods
    private void Initialize(string typeName)
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
    }
    #endregion

    #region Data
    private static readonly Dictionary<string, string> typeAliases = 
      new Dictionary<string, string>() {{"int", "Int32"},
                                        {"string", "String"}};

    #endregion
  }
}
