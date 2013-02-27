using System;
using System.Text.RegularExpressions;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.MTProperties
{
    /// <summary>
    /// General abstraction for properties spanning MetraNet(ProductViews, BMEs, etc.) and Metanga. There will be subclasses to
    /// implement variants. For example, ProductView properties have many other attributes such as access levels.
    /// 
    /// TO DO:
    /// *Fix NameRegex
    /// *XML serialization and deserialization
    /// *Unit tests
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class Property : IExpressionEngineTreeNode
    {
        #region Static Properties
        /// <summary>
        /// Used to validate the Name property
        /// </summary>
        private readonly Regex NameRegex = new Regex(".*");//[a-zA-Z][a-ZA-Z0-9_]*");
        #endregion

        #region Properties

        /// <summary>
        /// The collection to which the property belongs (may be null)
        /// </summary>
        public PropertyCollection PropertyCollection { get; set; }

        public PropertyBag ParentEntity
        {
            get
            {
                if (PropertyCollection == null || PropertyCollection.Entity == null)
                    return null;
                return PropertyCollection.Entity;
            }
        }

        /// <summary>
        /// The name of the property
        /// </summary>
        [DataMember]
        public string Name { get; set; }

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
        /// The name of the column in the database. MetraNet typically prefixes columns with a "c_". In 
        /// other cases we have aliases to make things easier for the customer
        /// </summary>
        public virtual string DBColumnName { get { return Name; } }

        /// <summary>
        /// Indicates the how the Property is interacted with (e.g., Input, Output or InOut)
        /// </summary>
        [DataMember]
        public Direction Direction { get; set; }

        //
        //Determines if the Direction is Input or InOut
        //
        public bool IsInputOrInOut
        {
            get { return Direction == Direction.Input || Direction == MTProperties.Enumerations.Direction.InOut; }
        }

        //
        //Determines if the Direction is Ouput or InOut
        //
        public bool IsOutputOrInOut
        {
            get { return Direction == Direction.Output || Direction == Direction.InOut; }
        }

        public virtual string CompatibleKey { get { return Type.CompatibleKey; } }

        /// <summary>
        /// Used for end-user-drive testing etc. 
        /// </summary>
        public string Value { get; set; }

        #endregion Properties

        #region GUI Helper Properties (should be moved)
        public string TreeNodeLabel { get { return Name + Type.ListSuffix; } }
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
                    if (UserSettings.ShowActualMappings)
                        tooltipStr += string.Format(CultureInfo.InvariantCulture, "\r\n[ColumnName={0}]", "");
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
                    case Direction.InOut:
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
                switch (Type.BaseType)
                {
                    case BaseType.Boolean:
                        return "Boolean.png";
                    case BaseType.Charge:
                        return "Charge.png";
                    case BaseType.Decimal:
                        return "Decimal.png";
                    case BaseType.Enumeration:
                        return "EnumType.png";
                    case BaseType.DateTime:
                        return "DateTime.png";
                    case BaseType.String:
                        return "String.png";
                    case BaseType.Integer32:
                        return "Int32.png";
                    case BaseType.Integer64:
                        return "Int64.png";
                    case BaseType.Guid:
                        return "Guid.png";
                    case BaseType.Entity:
                        return "Entity.png";
                }
                return null;
            }
        }
        #endregion

        #region Constructors

        public Property(string name, Type type, bool isRequired, string description = null)
        {
            Name = name;
            Type = type;
            Required = isRequired;
            Description = description;

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

        public static Property CreateEnum(string name, bool isRequired, string description, string enumSpace, string enumType)
        {
            var property = new Property(name, TypeFactory.CreateEnumeration(enumSpace, enumType), isRequired, description);
            return property;
        }
        #endregion

        #region Methods

        /// <summary>
        /// Returns the Units property associated with this property. Only valid for Charges.
        /// </summary>
        public Property GetUnitsProperty()
        {
            if (!Type.IsMoney || PropertyCollection == null)
                return null;

            return null;
            //throw new NotImplementedException("need to decide right model");
            //return PropertyCollection.Get(((MoneyType)Type).UnitsProperty);
        }

        /// <summary>
        /// Returns the UOM property associated with this property. Only valid for Numerics.
        /// </summary>
        public Property GetUnitOfMeasureProperty()
        {
            if (!Type.IsNumeric || Type.IsMoney)
                return null;

            var type = (NumberType)Type;
            if (!Type.IsNumeric || type.UnitOfMeasureMode != UnitOfMeasureMode.Property || PropertyCollection == null)
                return null;
            return PropertyCollection.Get(type.UnitOfMeasureQualifier);
        }

        public virtual object Clone()
        {
            throw new NotImplementedException();
            //May want to be more judicious when creating a copy of the property
            //but using MemberwiseClone works for the moment
            //var property = this.MemberwiseClone() as Property;
            //property.DataTypeInfo = this.DataTypeInfo.Copy();
            //return property;
        }

        public virtual ValidationMessageCollection Validate(bool prefixMsg)
        {
            return Validate(prefixMsg, null);
        }
        public virtual ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages)
        {
            if (messages == null)
                messages = new ValidationMessageCollection();

            var prefix = string.Format(CultureInfo.CurrentUICulture, Localization.PropertyMessagePrefix, Name);

            if (NameRegex.IsMatch(Name))
                messages.Error(prefix + Localization.InvalidName);

            Type.Validate(prefix, messages);

            return messages;
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
                var entity = ParentEntity;
                if (entity == null)
                    return null;

                string snippet;
                if (UserSettings.NewSyntax)
                    snippet = string.Format(CultureInfo.InvariantCulture, "{0}.{1}", entity.XqgPrefix, Name);
                else
                    snippet = string.Format(CultureInfo.InvariantCulture, "{0}.c_{1}", entity.XqgPrefix, Name);

                return snippet + Type.ListSuffix;
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
            var entity = ParentEntity;
            if (ParentEntity == null)
                return Name;

            var name = string.Format(CultureInfo.InvariantCulture, "{0}.{1}", entity.Name, Name);
            if (prefix)
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", entity.XqgPrefix, name);
            return name;
        }

        #endregion
    }
}
