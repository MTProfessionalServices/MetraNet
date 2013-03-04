using System;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
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
        #region Properties

        /// <summary>
        /// Indicates the unit of measure mode (fixed or driven by other property)
        /// </summary>
        [DataMember]
        public UnitOfMeasureMode UnitOfMeasureMode { get; set; }

        ///// <summary>
        ///// Depending on the UomMode, specifies a fixed UoM, a UoM category or the name of the property that determines the UOM.
        ///// </summary>
        //[DataMember]
        //public string UnitOfMeasureQualifier { get; set; }

        /// <summary>
        /// The unit of measure category (e.g., Duration, Length, etc.). Only valid when UnitOfMeasureMode is Fixed or Category
        /// </summary>
        [DataMember]
        public string UnitOfMeasureCategory { get; set; }

        /// <summary>
        /// The unit of measure. Must be a value within the UnitofMeasureCategoryName. Only valid when UnitOfMeasuremode is Fixed
        /// </summary>
        [DataMember]
        public string UnitOfMeasure { get; set; }

        /// <summary>
        /// The name of the property that specifies the unit of measure; Only valid when UnitOfMeasureMode is Property
        /// </summary>
        [DataMember]
        public string UnitOfMeasureProperty { get; set; }

        #endregion

        #region Constructor
        public NumberType(BaseType type, UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureCategory)
            : base(type)
        {
            if (!TypeHelper.IsNumeric(type))
                throw new ArgumentException("Invalid type: " + type.ToString());

            UnitOfMeasureMode = unitOfMeasureMode;
            UnitOfMeasureCategory = unitOfMeasureCategory;
        }
        #endregion

        #region Methods

        public override void Validate(string prefix, Validations.ValidationMessageCollection messages, Context context)
        {
            if (UnitOfMeasureMode == UnitOfMeasureMode.None)
            {
                messages.Error(prefix + ": " + Localization.UnitOfMeasureNotSpecified);
                return;
            }
            if (UnitOfMeasureMode == UnitOfMeasureMode.Category || UnitOfMeasureMode == UnitOfMeasureMode.Fixed)
            {
                if (string.IsNullOrEmpty(UnitOfMeasureCategory))
                {
                    messages.Error(prefix + ": " + Localization.UnitOfMeasureCategoryNotSpecified);
                    return;
                }

                //If there's no context, we can't look for things
                if (context == null)
                    return;

                //Find the category
                EnumCategory enumCategory;
                if (!context.TryGetEnumCategory(new EnumerationType(PropertyBagConstants.MetraTechNamespace, UnitOfMeasureCategory), out enumCategory))
                {
                    messages.Error(prefix + ": " + Localization.UnableToFindEnumCategory);
                    return;
                }

                //Ensure Enum is a UoM
                if (!enumCategory.IsUnitOfMeasure)
                {
                    messages.Error(prefix + ": " + Localization.UnitOfMeasureCategoryMustBeUom);
                    return;
                }

                //Ensure the value is specified
                if (string.IsNullOrEmpty(UnitOfMeasure))
                {
                    messages.Error(prefix + ": " + Localization.UnitOfMeasureNotSpecified);
                    return;
                }

                //Ensure that the value exists
                if (UnitOfMeasureMode == UnitOfMeasureMode.Fixed)
                {
                    messages.Error(prefix + ": " + string.Format(Localization.UnableToFindUnitOfMeasure, UnitOfMeasure));
                    return;
                }
            }
        }

        //public UnitOfMeasureCategory GetUnitOfMeasureCategory(Context context)
        //{
        //    if (context == null)
        //        throw new ArgumentException("context");

        //}


        public new NumberType Copy()
        {
            var type = (NumberType)base.Copy();
            InternalCopy(type);
            type.UnitOfMeasureMode = UnitOfMeasureMode;
            type.UnitOfMeasureCategory = UnitOfMeasureCategory;
            type.UnitOfMeasure = UnitOfMeasure;
            type.UnitOfMeasureProperty = UnitOfMeasureProperty;
            return type;
        }
        #endregion

    }
}
