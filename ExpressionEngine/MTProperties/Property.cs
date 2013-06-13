using System;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.Mvm;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Validations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.MTProperties
{
    /// <summary>
    /// General abstraction for properties spanning MetraNet(ProductViews, BMEs, etc.) and Metanga. There will be subclasses to
    /// implement variants. For example, ProductView properties have many other attributes such as access levels.
    /// 
    /// TO DO:
    /// *Fix NameRegex
    /// *Unit tests
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    [KnownType(typeof(AccountViewProperty))]
    [KnownType(typeof(BusinessModelingEntityProperty))]
    [KnownType(typeof(ParameterTableProperty))]
    [KnownType(typeof(ProductViewProperty))]
    [KnownType(typeof(ServiceDefinitionProperty))]
    public class Property : IComponent, IExpressionEngineTreeNode
    {
        #region Static Properties
        public ComponentType ComponentType { get; protected set; } 
        #endregion

        #region Properties

        /// <summary>
        /// The collection to which the property belongs (may be null)
        /// </summary>
        public PropertyCollection PropertyCollection { get; set; }


        /// <summary>
        /// Safe cast PropertyDriven Collection
        /// </summary>
        public PropertyBag PropertyBag
        {
            get
            {
                if (PropertyCollection == null || PropertyCollection.PropertyBag == null)
                    return null;
                return PropertyCollection.PropertyBag;
            }
        }

        /// <summary>
        /// The name of the property
        /// </summary>
        [DataMember]
        public string Name { get; set; }
        public string NameWithListSuffix { get { return Name + Type.ListSuffix; } }

        /// <summary>
        /// Properties don't have a Namespace, so the full name is the same as the name
        /// </summary>
        public virtual string FullName { get
        {
            var pb = PropertyBag;
            if (pb == null)
                return Name;
            return pb.FullName + "." + Name;
        } }
        public string FullNameWithListSuffix { get { return FullName + Type.ListSuffix; } }
     
        /// <summary>
        /// Rich data type class
        /// </summary>
        [DataMember]
        public Type Type { get; set; }

        /// <summary>
        /// A description that's used in tooltips, auto doc, etc.
        /// </summary>
        [DataMember]
        public string Description { get; set; }

        /// <summary>
        /// Indicates if a value is required
        /// </summary>
        [DataMember]
        public bool Required { get; set; }

        /// <summary>
        /// Indicates if the value is calculated via the CalculationExpression. When this is true, the user
        /// should be prevented from ever setting the value via a direct mechanism.
        /// </summary>
        [DataMember]
        public bool IsCalculated { get; set; }

        /// <summary>
        /// The expression used to calcuate the value. Only used when the value IsCalcualted is set to true.
        /// </summary>
        [DataMember]
        public string CalculationExpression { get; set; }

        public string CalculationExpressionWithAssignment { get { return MvmHelper.GetAssigment(this); } }

        /// <summary>
        /// The defult value for the property
        /// </summary>
        [DataMember]
        public string DefaultValue { get; set; }

        /// <summary>
        /// Indicates if the property is something that is common within the context of the Parent property.
        /// For example, all usage events have a Timestamp property, therefore it's considered common. These by
        /// definition aren't editable.
        /// </summary>
        [DataMember]
        public bool IsCore { get; set; }

        /// <summary>
        /// The availability of the property in whatever context is being modeled. Properties that are IsCore=true
        /// are always available. See the enum for further information.
        /// </summary>
        [DataMember]
        public Availability Availability { get; set; }

        /// <summary>
        /// The assoicated name, if any, in the database. In the case of property it's a column name, in the case of a PropertyBag, 
        /// it's a table name. Note that not all PropertyBag types are backed by database table.
        /// </summary>
        public virtual string DatabaseName { get { return Name; } }

        /// <summary>
        /// Indicates the how the PropertyDriven is interacted with (e.g., Input, Output or InputOutput)
        /// </summary>
        [DataMember]
        public Direction Direction { get; set; }

        //
        //Determines if the Direction is Input or InputOutput
        //
        public bool IsInputOrInOut
        {
            get { return Direction == Direction.Input || Direction == Direction.InputOutput; }
        }

        //
        //Determines if the Direction is Ouput or InputOutput
        //
        public bool IsOutputOrInOut
        {
            get { return Direction == Direction.Output || Direction == Direction.InputOutput; }
        }

        public virtual string CompatibleKey { get { return Type.CompatibleKey; } }

        /// <summary>
        /// Used for end-user-drive testing etc. 
        /// </summary>
        public string Value { get; set; }

        #endregion Properties

        #region GUI Helper Properties (should be moved)
        /// <summary>
        /// Combines the data type and description
        /// </summary>
        public  virtual string ToolTip
        {
            get
            {
                {
                    var tooltipStr = Type.ToString(true);
                    if (!string.IsNullOrEmpty(Description))
                        tooltipStr += Environment.NewLine + Description;
                    if (UserContext.Settings.ShowActualMappings)
                        tooltipStr += string.Format(CultureInfo.InvariantCulture, "\r\n[ColumnName: {0}]", DatabaseName);
                    return tooltipStr;
                }
            }
        }

        public virtual string ImageDirection
        {
            get
            {
                switch (Direction)
                {
                    case Direction.InputOutput:
                        return "PropertyInOut.png";
                    case Direction.Input:
                        return "PropertyInput.png";
                    case Direction.Output:
                        return "PropertyOutput.png";
                    default:
                        return null;
                }
            }
        }

        public virtual string Image
        {
            get
            {
                var baseName = Type.BaseType.ToString();
                if (IsCore)
                    baseName += "IsCoreOverlay";
                return baseName + ".png";
            }
        }
        #endregion

        #region Constructors

        public Property(string name, Type type, bool isRequired, string description = null)
        {
            ComponentType = ComponentType.PropertyBagProperty;
            Name = name;
            Type = type;
            Required = isRequired;
            Description = description;

            DefaultValue = null;
            IsCore = false;
        }

        #endregion Constructors

        #region Static Create Methods
        public static Property CreateUnknown(string name, bool isRequired, string description)
        {
            return new Property(name, TypeFactory.CreateUnknown(), isRequired, description);
        }
        public static Property CreateInteger32(string name, bool isRequired, string description)
        {
            return new Property(name, TypeFactory.CreateInteger32(UnitOfMeasureMode.None, null), isRequired, description);
        }
        public static Property CreateString(string name, bool isRequired, string description, int length)
        {
            var property = new Property(name, TypeFactory.CreateString(length), isRequired, description);
            return property;
        }

        public static Property CreateBoolean(string name, bool isRequired, string description)
        {
            var property = new Property(name, TypeFactory.CreateBoolean(), isRequired, description);
            return property;
        }

        public static Property CreateEnum(string name, bool isRequired, string description, string category)
        {
            var property = new Property(name, TypeFactory.CreateEnumeration(category), isRequired, description);
            return property;
        }
        #endregion

        #region Methods

        public virtual object Clone()
        {
            throw new NotImplementedException();
        }
        public virtual object Copy()
        {
            var property = new Property(Name, Type.Copy(), Required, Description);
            property.IsCore = IsCore;
            return property;
        }

        /// <summary>
        /// Useful for debugging.
        /// </summary>
        public override string ToString()
        {
            return string.Format(CultureInfo.InvariantCulture, "{0} ({1})", Name, Type.ToString(true));
        }

        public virtual string ToExpressionSnippet
        {
            get
            {
                var entity = PropertyBag;
                if (entity == null)
                    return null;

                string snippet;
                if (UserContext.Settings.NewSyntax)
                    snippet = string.Format(CultureInfo.InvariantCulture, "{0}.{1}", entity.XqgPrefix, Name);
                else
                    snippet = string.Format(CultureInfo.InvariantCulture, "{0}.c_{1}", entity.XqgPrefix, Name);

                return snippet + Type.ListSuffix;
            }
        }

        public string QualifiedName
        {
            get
            {
                var entity = PropertyBag;
                if (entity == null)
                    return Name;
                return entity.Name + "." + Name;
            }
        }

        /// <summary>
        /// Used when searching for properties across entities. The underlying datatype might not be the same. Perhaps
        /// the DataType level formatting should be moved to DataTypeInfo class
        /// NOTE THAT WE'RE NOT DEALING WITH UOMs
        /// </summary>
        //public string CompatibleKey
        //{
        //{get{return null;}}
        //    //string.Format(CultureInfo.InvariantCulture, "{0}|{1}", Name, Type.CompatibleKey);}}

        public string GetFullyQualifiedName(bool prefix)
        {
            var propertyBag = PropertyBag;
            if (PropertyBag == null)
                return Name;

            var name = string.Format(CultureInfo.InvariantCulture, "{0}.{1}", propertyBag.Name, Name);
            if (prefix)
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", propertyBag.XqgPrefix, name);
            return name;
        }

        #endregion

        #region Validation Methods

        //Not sure that I need prefixMsg here
        public virtual ValidationMessageCollection Validate(ValidationMessageCollection messages, Context context)
        {
            if (messages == null)
                throw new ArgumentException("messages is null");
            if (context == null)
                throw new ArgumentException("context is null");

            //Validate the name
            if (string.IsNullOrWhiteSpace(Name))
                messages.Error(this, Localization.NameNotSpecified);
            else
            {
                if (!NameIsValid(Name))
                    messages.Error(Localization.InvalidName);
                //FUTURE FEATURE
                //else
                //    SpellingEngine.CheckWord(Name, null, messages);
            }

            //Validate the type
            Type.Validate(this, messages, context, PropertyCollection);

            //Validate the default value, if any
            if (!TypeHelper.ValueIsValid(Type, DefaultValue, true, context.EnumManager))
                messages.Error(this, Localization.InvalidDefaultValue);

            //Validate the description
            if (string.IsNullOrEmpty(Description))
                messages.Info(this, Localization.NoDescription);
            //FUTURE FEATURE
            //SpellingEngine.CheckString(Description, null, messages);

            return messages;
        }

        public static bool NameIsValid(string name)
        {
            return BasicHelper.NameIsValid(name);
        }
        #endregion  

        System.Collections.Generic.List<ComponentLink> IComponent.GetComponentLinks()
        {
            throw new NotImplementedException();
        }

        public void Rename(string newName)
        {
            throw new NotImplementedException();
        }
    }
}
