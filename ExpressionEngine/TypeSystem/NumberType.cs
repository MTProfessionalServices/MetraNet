using System;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Infrastructure;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    /// <summary>
    /// General class for numbers. NOTE that the name is intentionlly not "NumericType" because
    /// "Numeric" is a BaseType which implies every typeof NumberType. This is a very important 
    /// distinction.
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class NumberType : Type
    {
        #region Constants
        public const string UnitOfMeasureCategoryPropertyName = "UnitOfMeasureCategory";
        public const string FixedUnitOfMeasurePropertyName = "FixedUnitOfMeasure";
        public const string UnitOfMeasurePropertyPropertyName = "UnitOfMeasureProperty";
        #endregion

        #region Properties

        /// <summary>
        /// Indicates the unit of measure mode (fixed or driven by other property)
        /// </summary>
        [DataMember]
        public UnitOfMeasureMode UnitOfMeasureMode { get; set; }

        /// <summary>
        /// The unit of measure category (e.g., Duration, Length, etc.). Only valid when UnitOfMeasureMode is FixedUnitOfMeasure or FixedCategory
        /// </summary>
        [DataMember(EmitDefaultValue = false)]
        public string UnitOfMeasureCategory { get; set; }

        /// <summary>
        /// The unit of measure. Must be a value within the UnitofMeasureCategoryName. This is the fully qualifed name 
        /// (i.e., UnitOfMeasureCategory isn't used in combination with this combination). Only valid when UnitOfMeasuremode=FixedUnitOfMeasure
        /// </summary>
        [DataMember(EmitDefaultValue = false)]
        public string FixedUnitOfMeasure { get; set; }

        /// <summary>
        /// The name of the property that specifies the unit of measure; Only valid when UnitOfMeasureMode=PropertyDriven
        /// </summary>
        [DataMember(EmitDefaultValue = false)]
        public string UnitOfMeasureProperty { get; set; }

        #endregion

        #region Constructor
        public NumberType(BaseType type, UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureCategory)
            : base(type)
        {
            if (!TypeHelper.IsNumeric(type))
                throw new ArgumentException("Invalid type: " + type);

            UnitOfMeasureMode = unitOfMeasureMode;
            UnitOfMeasureCategory = unitOfMeasureCategory;
        }
        #endregion

        #region Methods

        /// <summary>
        /// Given the UnitOfMeasureMode, set all of the properties that have irrlevant values to null. Not doing
        /// so doesn't hurt anything but this makes things cleaner.
        /// </summary>
        public void CleanProperties()
        {
            switch (UnitOfMeasureMode)
            {
                //case UnitOfMeasureMode.ContextDriven:
                case UnitOfMeasureMode.Count:
                    UnitOfMeasureProperty = null;
                    UnitOfMeasureCategory = null;
                    FixedUnitOfMeasure = null;
                    break;
                case UnitOfMeasureMode.FixedCategory:
                    UnitOfMeasureProperty = null;
                    FixedUnitOfMeasure = null;
                    break;
                case UnitOfMeasureMode.FixedUnitOfMeasure:
                    UnitOfMeasureProperty = null;
                    UnitOfMeasureCategory = null;
                    break;
            }
        }

        public new NumberType Copy()
        {
            var type = (NumberType)base.Copy();
            InternalCopy(type);
            type.UnitOfMeasureMode = UnitOfMeasureMode;
            type.UnitOfMeasureCategory = UnitOfMeasureCategory;
            type.FixedUnitOfMeasure = FixedUnitOfMeasure;
            type.UnitOfMeasureProperty = UnitOfMeasureProperty;
            return type;
        }
        #endregion

        #region Link Methods
        public override ComponentLinkCollection GetComponentLinks()
        {
            var links = new ComponentLinkCollection();

            switch (UnitOfMeasureMode)
            {
                case UnitOfMeasureMode.FixedCategory:
                    links.Add(GetFixedCategoryLink());
                    break;
                case UnitOfMeasureMode.FixedUnitOfMeasure:
                    links.Add(GetFixedUnitOfMeasureLink());
                    break;
                case UnitOfMeasureMode.PropertyDriven:
                    links.Add(GetUnitOfMeasurePropertyLink());
                    break;
            }
            return links;
        }
        public ComponentLink GetFixedCategoryLink()
        {
            return new ComponentLink(ComponentType.UnitOfMeasureCategory, this, UnitOfMeasureCategoryPropertyName, true, "Unit of Measure Category");
        }
        public ComponentLink GetFixedUnitOfMeasureLink()
        {
            return new ComponentLink(ComponentType.UnitOfMeasure, this, FixedUnitOfMeasurePropertyName, true, "Fixed Unit of Measure");
        }
        public PropertyLink GetUnitOfMeasurePropertyLink()
        {
            return new PropertyLink(TypeFactory.CreateUnitOfMeasure(), this, UnitOfMeasurePropertyPropertyName, true, "Unit of Measure Property");
        }
        #endregion
    }
}
