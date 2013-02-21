using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem;
//using Type = MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// Implements a ComplexType, esentially something that PropertyCollection which may include properties and
    /// other complex types. Note that DataTypeInfo.IsEntity determines if it's deemed an Entity (an important destinction for Metanga)
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class Entity : IProperty, IExpressionEngineTreeNode
    {
        //#region Enums
        //public enum ComplexTypeEnum {None, ServiceDefinition, ProductView, ParameterTable, AccountType, AccountView, BusinessModelingEntity, Any, Metanga}
        //#endregion

        #region Properties
        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public bool Required { get; set; }

        [DataMember]
        public bool IsCore { get; set; }

        [DataMember]
        public MtType Type { get; set; }

        public VectorType VectorType { get { return (VectorType)Type; } }

        [DataMember]
        public PropertyCollection Properties { get; private set; }

        public Entity ParentEntity { get; set; }

        [DataMember]
        public string Description { get; set; }

        [DataMember]
        public Property.DirectionType Direction { get; set; }

        public string CompatibleKey { get { return string.Format(CultureInfo.InvariantCulture, "{0}|{1}", Name, Type.CompatibleKey); } }

        /// <summary>
        /// The actual database table name. Used in MetraNet which has a prefix on all table names.
        /// Not sure what to do for Metanga here.
        /// </summary>
        public string DBTableName
        {
            get
            {
                switch (VectorType.ComplexType)
                {
                    //case ComplexTypeEnum.AccountView:
                    //    return "t_av_" + Name;
                    //case ComplexTypeEnum.ParameterTable:
                    //    return "t_pt_" + Name;
                    //case ComplexTypeEnum.ProductView:
                    //    return "t_pv_" + Name;
                    default:
                        return null;
                }
            }
        }
        #endregion

        #region GUI Helper Properties (move in future)
        public string TreeNodeLabel { get { return Name + Type.ListSuffix; } }
        public string ToolTip
        {
            get
            {
                var tip = VectorType.ComplexType.ToString();
                if (!string.IsNullOrEmpty(Description))
                    tip += Environment.NewLine + Description;
                if (UserSettings.ShowActualMappings)
                    tip += string.Format(CultureInfo.InvariantCulture, "\r\n[TableName={0}]", DBTableName);
                return tip;
            }
        }

        public string Image
        {
            get
            {
                if (VectorType.ComplexType == VectorType.ComplexTypeEnum.Metanga)
                {
                    if (VectorType.IsEntity)
                        return "Entity.png";
                    else
                        return "ComplexType.png";
                }

                return VectorType.ToString() + ".png";
            }
        }


        public string ImageDirection
        {
            get
            {
                switch (Direction)
                {
                    case Property.DirectionType.InOut:
                        return "EntityInOut.png";
                    case Property.DirectionType.Input:
                        return "EntityInput.png";
                    case Property.DirectionType.Output:
                        return "EntityOutput.png";
                    default:
                        return null;
                }
            }
        }
        #endregion

        #region Constructor

        public Entity(string name, VectorType.ComplexTypeEnum type, string subType, bool isEntity, string description)
        {
            Name = name;
            Type = TypeFactory.CreateComplexType(type, subType, isEntity);
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
        public bool HasPropertyMatch(Regex nameFilter, MtType typeFilter)
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

        public string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", GetPrefix(), Name);
            }
        }

        public string GetPrefix()
        {
            switch (VectorType.ComplexType)
            {
                case VectorType.ComplexTypeEnum.ProductView:
                    return UserSettings.NewSyntax? "EVENT": "USAGE";
                case VectorType.ComplexTypeEnum.AccountView:
                    return "ACCOUNT";
                default:
                    return String.Empty;
            }
        }

        public object Clone()
        {
            throw new NotImplementedException();
            //var newEntity = new ComplexType(Name, Type.ComplexType, Description);
            //newEntity.Properties = Properties.Clone();
            //return newEntity;
        }

        public ValidationMessageCollection Validate(bool prefixMsg)
        {
            return Validate(prefixMsg, null);
        }

        public ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages)
        {
            if (messages == null)
                messages = new ValidationMessageCollection();

            var prefix = string.Format(CultureInfo.InvariantCulture, Localization.PropertyMessagePrefix, Name);

            //if (NameRegex.IsMatch(Name))
            //    messages.Error(prefix + Localization.InvalidName);

            Type.Validate(prefix, messages);

            foreach (var property in Properties)
            {
                property.Validate(prefixMsg, messages);
            }

            return messages;
        }

        #endregion

        #region Create Methods
        public static Entity CreateProductView(string name, string description)
        {
            return new Entity(name, VectorType.ComplexTypeEnum.ProductView, null, true, description);
        }
        #endregion
    }
}
