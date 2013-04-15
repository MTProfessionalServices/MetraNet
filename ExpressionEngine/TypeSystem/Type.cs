﻿using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Infrastructure;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    /// <summary>
    /// The base class for all types. Note that simple types (i.e., boolean) aren't implemented
    /// as a subclass. The simply have a different BaseType. Other similar types may share the same
    /// sub class. For example, NumberType implements all of the numeric types and EnumerationType implements
    /// Enumerations, Currencies and UnitOfMeasures.
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    [KnownType(typeof(EnumerationType))]
    [KnownType(typeof(MoneyType))]
    [KnownType(typeof(NumberType))]
    [KnownType(typeof(PropertyBagType))]
    [KnownType(typeof(StringType))]
    [KnownType(typeof(ChargeType))]
    [KnownType(typeof(TaxType))]
    public class Type
    {
        #region Properties

        /// <summary>
        /// The underlying type (e.g, String, Integer32, Integer64, etc.)
        /// </summary>
        [DataMember]
        public BaseType BaseType { get; private set; }

        /// <summary>
        /// The type of list (Scalar, List or KeyList)
        /// </summary>
        [DataMember]
        public ListType ListType { get; set; }

        /// <summary>
        /// Returns the suffix assoicated with the ListType
        /// </summary>
        public string ListSuffix
        {
            get
            {
                if (ListType == ListType.List)
                    return "[]";
                if (ListType == ListType.KeyList)
                    return "<>";
                return null;
            }
        }

        /// <summary>
        /// Returns a string that can be used to determine if two types are directly compatible (which is differnt than castable)
        /// </summary>
        /// <returns></returns>
        public virtual string CompatibleKey
        {
            get { return BaseType.ToString(); }}

        #endregion

        #region Constructor

        public Type(BaseType baseType)
        {
            BaseType = baseType;
        }

        #endregion

        #region Methods

        /// <summary>
        /// Returns a list of property links by first calling GetComponentLinks
        /// and then filtering the results
        /// </summary>
        public List<PropertyLink> GetPropertyLinks()
        {
            var propertyLinks = new List<PropertyLink>();
            foreach (var link in GetComponentLinks())
            {
                if (link is PropertyLink)
                    propertyLinks.Add((PropertyLink)link);
            }
            return propertyLinks;
        }

        /// <summary>
        /// Returns a collection that contains all references to components. Very useful
        /// for generic validation and name refactoring.
        /// </summary>
        public virtual ComponentLinkCollection GetComponentLinks()
        {
            var links = new ComponentLinkCollection();
            //AddComponentLinks(links);
            return links;
        }

        //public virtual void AddComponentLinks(ComponentLinkCollection links)
        //{
        //    //Do something in subclass if necessary
        //}

        #endregion

        #region To Methods
        /// <summary>
        /// Returns a formatted version of the type
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return ToString(true);
        }

        public virtual string ToString(bool robust)
        {
            return BaseType.ToString();
        }
        #endregion

        #region IsType methods
        public bool IsAny { get { return BaseType == BaseType.Any; } }
        public bool IsBinary { get { return BaseType == BaseType.Binary; } }
        public bool IsBoolean { get { return BaseType == BaseType.Boolean; } }
        public bool IsCharge { get { return BaseType == BaseType.Charge; } }
        public bool IsCurrency { get { return BaseType == BaseType.Currency; } }
        public bool IsDateTime { get { return BaseType == BaseType.DateTime; } }
        public bool IsDecimal { get { return BaseType == BaseType.Decimal; } }
        public bool IsDouble { get { return BaseType == BaseType.Double; } }
        public bool IsPropertyBag { get { return BaseType == BaseType.PropertyBag; } }
        public bool IsEnum { get { return (BaseType == BaseType.Enumeration); } }
        public bool IsFloat { get { return BaseType == BaseType.Float; } }
        public bool IsGuid { get { return BaseType == BaseType.Guid; } }
        public bool IsInteger { get { return BaseType == BaseType.Integer; } }
        public bool IsInteger32 { get { return BaseType == BaseType.Integer32; } }
        public bool IsInteger64 { get { return BaseType == BaseType.Integer64; } }
        public bool IsMoney { get { return BaseType == BaseType.Money; } }
        public bool IsNumeric { get { return TypeHelper.IsNumeric(BaseType); } }
        public bool IsString { get { return BaseType == BaseType.String; } }
        public bool IsTax { get { return BaseType == BaseType.Tax; } }
        public bool IsUniqueIdentifier { get { return BaseType == BaseType.UniqueIdentifier; } }
        public bool IsUnitOfMeasure { get { return BaseType == BaseType.UnitOfMeasure; } }
        public bool IsUnknown { get { return BaseType == BaseType.Unknown; } }
        #endregion

        #region Type comparision and filtering

        public bool IsMatch(Type type2, MatchType minimumMatchType)
        {
            var result = CompareType(type2);
            return (result >= minimumMatchType);
        }

        public MatchType CompareType(Type type2)
        {
            if (type2 == null)
                throw new ArgumentNullException("type2");


            //Any match only works one way
            if (BaseType == BaseType.Any)
                return MatchType.Any;

            //Enum MOVE THIS TO SUB CLASS
            if (BaseType == BaseType.Enumeration)
            {
                if (type2.BaseType != BaseType.Enumeration)
                    return MatchType.None;
                var enumType = (EnumerationType)this;
                var enumType2 = (EnumerationType)type2;
                if (enumType.Namespace == enumType2.Namespace && enumType.Category == enumType2.Category)
                    return MatchType.Exact;
                return MatchType.BaseTypeWithDiff;
            }

            if (IsNumeric)
            {
                if (!type2.IsNumeric)
                    return MatchType.None;

                if (IsImplicitCast(this, type2))
                    return MatchType.ImplicitCast;

                return MatchType.Convertible;
            }

            if (BaseType == type2.BaseType)
                return MatchType.Exact;
            return MatchType.None;

            //Not dealing with UoM or Currencies
        }

        public bool IsBaseTypeFilterMatch(BaseType baseType)
        {
            return IsBaseTypeFilterMatch(TypeFactory.Create(baseType));
        }
        public bool IsBaseTypeFilterMatch(Type type)
        {
            if (type == null)
                throw new ArgumentNullException("type");

            switch (type.BaseType)
            {
                case BaseType.Any:
                    return true;
                case BaseType.Numeric:
                    return IsNumeric;
                default:
                    return type.BaseType == BaseType;
            }
        }

        public bool CanBeImplicitlyCastTo(Type target)
        {
            return IsImplicitCast(this, target);
        }

        public static bool IsImplicitCast(Type start, Type end)
        {
            if (start == null)
                throw new ArgumentNullException("start");
            if (end == null)
                throw new ArgumentNullException("end");
            if (!start.IsNumeric || !end.IsNumeric)
                throw new ArgumentException("Arguments must be numeric");

            if (start.BaseType == end.BaseType)
                return true;
            return false;
        }

        public Type Copy()
        {
            var type = TypeFactory.Create(BaseType);
            InternalCopy(type);
            return type;
        }
        protected void InternalCopy(Type type)
        {
            if (type == null)
                throw new ArgumentNullException("type");
            type.ListType = ListType;
        }

        public virtual void Validate(IComponent component, ValidationMessageCollection messages, Context context, PropertyCollection properties)
        {
            if (component == null)
                throw new ArgumentException("component is null");
            if (messages == null)
                throw new ArgumentNullException("messages");

            foreach (var link in GetComponentLinks())
            {
                link.Validate(component, messages, context);
            }
        }
        #endregion
    }
}
