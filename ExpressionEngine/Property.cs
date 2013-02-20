using System;
using System.Xml;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Data;
using System.Globalization;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine
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
    public class Property : IProperty, IExpressionEngineTreeNode
    {
        #region Enums
        public enum DirectionType { Input, Output, InOut }
        #endregion

        #region Static Properties
        /// <summary>
        /// Used to validate the Name property
        /// </summary>
        private Regex NameRegex = new Regex(".*");//[a-zA-Z][a-ZA-Z0-9_]*");
        #endregion

        #region Properties

        /// <summary>
        /// The collection to which the property belongs (may be null)
        /// </summary>
        public PropertyCollection PropertyCollection { get; set; }

        public ComplexType ParentEntity
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
        public DataTypeInfo DataTypeInfo { get; set; }

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
        /// Indicates the how the Property is interacted with (e.g., Input, Output or InOut)
        /// </summary>
        [DataMember]
        public DirectionType Direction { get; set; }

        //
        //Determines if the Direction is Input or InOut
        //
        public bool IsInputOrInOut
        {
            get { return Direction == DirectionType.Input || Direction == DirectionType.InOut; }
        }

        //
        //Determines if the Direction is Ouput or InOut
        //
        public bool IsOutputOrInOut
        {
            get { return Direction == DirectionType.Output || Direction == DirectionType.InOut; }
        }

        /// <summary>
        /// Used for testing etc. type purposes. We may want to put this into a subclass
        /// </summary>
        public string Value { get; set; }

        #endregion Properties

        #region GUI Helper Properties (should be moved)
        public string TreeNodeLabel { get { return Name + DataTypeInfo.ListSuffix; } }
        /// <summary>
        /// Combines the data type and description
        /// </summary>
        public string ToolTip
        {
            get
            {
                {
                    var tooltipStr = DataTypeInfo.ToUserString(true);
                    if (!string.IsNullOrEmpty(Description))
                        tooltipStr += Environment.NewLine + Description;
                    if (UserSettings.ShowActualMappings)
                        tooltipStr += string.Format(CultureInfo.InvariantCulture, "\r\n[ColumnName={0}]", "");
                    return tooltipStr;
                }
            }
        }

        public string ImageDirection
        {
            get
            {
                switch (Direction)
                {
                    case DirectionType.InOut:
                        return "PropertyInOut.png";
                    case DirectionType.Input:
                        return "PropertyInput.png";
                    case DirectionType.Output:
                        return "PropertyOutput.png";
                    default:
                        return null;
                }
            }
        }

        public string Image
        {
            get
            {
                switch (DataTypeInfo.BaseType)
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
                    case BaseType.ComplexType:
                        return "Entity.png";
                }
                return null;
            }
        }
        #endregion

        #region Constructors

        public Property(string name, DataTypeInfo dtInfo, string description = null)
        {
            Name = name;
            DataTypeInfo = dtInfo;
            Description = description;

            IsCore = false;
        }

        #endregion Constructors

        #region Static Create Methods
        public static Property CreateUnknown(string name, string description)
        {
            return new Property(name, new DataTypeInfo(BaseType.Unknown), description);
        }
        public static Property CreateInteger32(string name, string description)
        {
            return new Property(name, new DataTypeInfo(BaseType.Integer32), description);
        }
        public static Property CreateString(string name, string description, int length)
        {
            var property = new Property(name, DataTypeInfo.CreateString(length), description);
            return property;
        }

        public static Property CreateBoolean(string name, string description)
        {
            var property = new Property(name, DataTypeInfo.CreateBoolean(), description);
            return property;
        }

        public static Property CreateEnum(string name, string description, string enumSpace, string EnumType)
        {
            var property = new Property(name, DataTypeInfo.CreateEnum(enumSpace, EnumType), description);
            return property;
        }
        #endregion

        #region Methods

        /// <summary>
        /// Returns the Units property associated with this property. Only valid for Charges.
        /// </summary>
        public IProperty GetUnitsProperty()
        {
            if (!DataTypeInfo.IsCharge || PropertyCollection == null)
                return null;
            return PropertyCollection.Get(DataTypeInfo.UnitsProperty);
        }

        /// <summary>
        /// Returns the UOM property associated with this property. Only valid for Numerics.
        /// </summary>
        public IProperty GetUnitOfMeasureProperty()
        {
            if (!DataTypeInfo.IsNumeric || DataTypeInfo.UnitOfMeasureMode != ExpressionEngine.DataTypeInfo.UnitOfMeasureModeType.Property || PropertyCollection == null)
                return null;
            return PropertyCollection.Get(DataTypeInfo.UnitOfMeasureQualifier);
        }

        public object Clone()
        {
            throw new NotImplementedException();
            //May want to be more judicious when creating a copy of the property
            //but using MemberwiseClone works for the moment
            //var property = this.MemberwiseClone() as Property;
            //property.DataTypeInfo = this.DataTypeInfo.Copy();
            //return property;
        }

        public ValidationMessageCollection Validate(bool prefixMsg)
        {
            return Validate(prefixMsg, null);
        }
        public ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages)
        {
            if (messages == null)
                messages = new ValidationMessageCollection();

            var prefix = string.Format(CultureInfo.CurrentUICulture, Localization.PropertyMessagePrefix, Name);

            if (NameRegex.IsMatch(Name))
                messages.Error(prefix + Localization.InvalidName);

            DataTypeInfo.Validate(prefix, messages);

            return messages;
        }

        /// <summary>
        /// Useful for debugging.
        /// </summary>
        public override string ToString()
        {
            return string.Format(CultureInfo.InvariantCulture, "{0} ({1})", Name, DataTypeInfo.ToUserString(true));
        }

        public string ToExpressionSnippet
        {
            get
            {
                var entity = ParentEntity;
                if (entity == null)
                    return null;

                string snippet;
                if (UserSettings.NewSyntax)
                    snippet = string.Format(CultureInfo.InvariantCulture, "{0}.{1}", entity.GetPrefix(), Name);
                else
                    snippet = string.Format(CultureInfo.InvariantCulture, "{0}.c_{1}", entity.GetPrefix(), Name);

                return snippet + DataTypeInfo.ListSuffix;
            }
        }

        /// <summary>
        /// Used when searching for properties across entities. The underlying datatype might not be the same. Perhaps
        /// the DataType level formatting should be moved to DataTypeInfo class
        /// NOTE THAT WE'RE NOT DEALING WITH UOMs
        /// </summary>
        public string CompatibleKey
        {
            get
            {
                var key = string.Format(CultureInfo.InvariantCulture, "{0}|{1}", Name, DataTypeInfo.BaseType);
                switch (DataTypeInfo.BaseType)
                {
                    case BaseType.Enumeration:
                        key += string.Format(CultureInfo.InvariantCulture, "|{0}|{1}", DataTypeInfo.EnumSpace, DataTypeInfo.EnumType);
                        break;
                }
                return key;
            }
        }

        public string GetFullyQualifiedName(bool prefix)
        {
            var entity = ParentEntity;
            if (ParentEntity == null)
                return Name;

            var name = string.Format(CultureInfo.InvariantCulture, "{0}.{1}", entity.Name, Name);
            if (prefix)
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", entity.GetPrefix(), name);
            else
                return name;
        }

        #endregion

    }
}
