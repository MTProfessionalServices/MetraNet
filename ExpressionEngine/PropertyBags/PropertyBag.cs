using System;
using System.Text.RegularExpressions;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using System.IO;
using MetraTech.ExpressionEngine.Validations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    /// <summary>
    /// Implements a ComplexType, esentially something that PropertyCollection which may include properties and
    /// other complex types. Note that DataTypeInfo.IsEntity determines if it's deemed an PropertyBag (an important destinction for Metanga)
    /// </summary>
    [DataContract(Namespace = "MetraTech")]
    [KnownType(typeof(AccountViewEntity))]
    [KnownType(typeof(BusinessModelingEntity))]
    [KnownType(typeof(ParameterTableEntity))]
    [KnownType(typeof(ProductViewEntity))]
    [KnownType(typeof(ServiceDefinitionEntity))]
    public class PropertyBag : Property, IExpressionEngineTreeNode
    {
        #region Properties

        /// <summary>
        /// The name prefixed with the namespace, if any
        /// </summary>
        public override string FullName
        {
            get { return Namespace + "." + Name; }
        }

        /// <summary>
        /// The entity's namespace. Primarly used to prevent name collisions for MetraNet
        /// </summary>
        [DataMember]
        public string Namespace { get; set; }

        /// <summary>
        /// The properties contained in the property bag which may include other property bags
        /// </summary>
        [DataMember]
        public PropertyCollection Properties { get; private set; }

        public override string CompatibleKey
        {
            get { return string.Format(CultureInfo.InvariantCulture, "{0}|{1}", Name, Type.CompatibleKey); }
        }

        public virtual string XqgPrefix { get { return null; } }

        #endregion

        #region GUI Helper Properties (move in future)
        public override string ToolTip
        {
            get
            {
                var tip = ((PropertyBagType)Type).Name;
                if (!string.IsNullOrEmpty(Description))
                    tip += Environment.NewLine + Description;
                if (UserContext.Settings.ShowActualMappings)
                    tip += string.Format(CultureInfo.InvariantCulture, "\r\n[TableName: {0}]", DatabaseName);
                return tip;
            }
        }

        public override string Image {get { return ((PropertyBagType) Type).PropertyBagMode.ToString() + ".png"; }}

        public override string ImageDirection
        {
            get
            {
                switch (Direction)
                {
                    case Direction.InputOutput:
                        return "EntityInOut.png";
                    case Direction.Input:
                        return "EntityInput.png";
                    case Direction.Output:
                        return "EntityOutput.png";
                    default:
                        return null;
                }
            }
        }
        #endregion

        #region Constructor

        public PropertyBag(string _namespace, string name, string propertyBagTypeName, PropertyBagMode propertyBagMode, string description)
            : base(name, TypeFactory.CreatePropertyBag(propertyBagTypeName, propertyBagMode), true, description)
        {
            Namespace = _namespace;
            Name = name;
            Type = TypeFactory.CreatePropertyBag(propertyBagTypeName, propertyBagMode);
            Description = description;
            Properties = new PropertyCollection(this);
        }
        #endregion

        #region Methods

        /// <summary>
        /// Determines if the Properties collection exactly matches the nameFilter or the typeFilter. Useful
        /// for filtering in the GUI.
        /// TODO: Add recursive option to look sub entities
        /// </summary>
        public bool HasPropertyMatch(Regex nameFilter, Type typeFilter)
        {
            foreach (var property in Properties)
            {
                if (nameFilter != null && !nameFilter.IsMatch(property.Name))
                    continue;
                if (typeFilter != null && !property.Type.IsBaseTypeFilterMatch(typeFilter))
                    continue;
                return true;
            }
            return false;
        }

        public override string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", XqgPrefix, Name);
            }
        }

        public override object Clone()
        {
            throw new NotImplementedException();
            //var newEntity = new ComplexType(Name, Type.ComplexType, Description);
            //newEntity.Properties = Properties.Clone();
            //return newEntity;
        }

        public override ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages, Context context)
        {
            var prefix = string.Format(CultureInfo.CurrentCulture, "PropertyBag '{0}':", FullName);
            if (!BasicHelper.FullNameIsValid(FullName))
                messages.Error(prefix + "Invalid name.");
            if (string.IsNullOrWhiteSpace(Description))
                messages.Info(prefix + "Invalid name.");

            prefix = string.Format(CultureInfo.CurrentCulture, prefix + Localization.PropertyMessagePrefix, Name);

            //Valiate all of the properties
            foreach (var property in Properties)
            {
                property.Validate(prefixMsg, messages, context);
            }

            return messages;
        }
        #endregion

        #region IO Methods

        public void Save(string file)
        {
            IOHelper.Save(file, this);
        }

        public static T CreateFromFile<T>(string file)
        {
            var xmlContent = File.ReadAllText(file);
            return CreateFromString<T>(xmlContent);
        }

        public static T CreateFromString<T>(string xmlContent)
        {
            var propertyBag = IOHelper.CreateFromString<T>(xmlContent);
            var pb = (PropertyBag)(object)propertyBag;
            pb.Properties.Parent = propertyBag;
            pb.Properties.SetPropertyParentReferences();
            return propertyBag;
        }
        
        #endregion
    }
}
