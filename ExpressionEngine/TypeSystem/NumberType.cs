using System;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Validations;

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

        /// <summary>
        /// The unit of measure category (e.g., Duration, Length, etc.). Only valid when UnitOfMeasureMode is Fixed or Category
        /// </summary>
        [DataMember]
        public string UnitOfMeasureCategory { get; set; }

        /// <summary>
        /// The unit of measure. Must be a value within the UnitofMeasureCategoryName. Only valid when UnitOfMeasuremode=Fixed
        /// </summary>
        [DataMember]
        public string FixedUnitOfMeasure { get; set; }

        /// <summary>
        /// The name of the property that specifies the unit of measure; Only valid when UnitOfMeasureMode=Property
        /// </summary>
        [DataMember]
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

        private void AddError(ValidationMessageCollection messages, string prefix, string message)
        {
            if (messages == null)
                throw new ArgumentException("messages is null");

            messages.Error(prefix + ": " + message);
        }

        public override void Validate(string prefix, ValidationMessageCollection messages, Context context)
        {
            if (UnitOfMeasureMode == UnitOfMeasureMode.None)
            {
                AddError(messages, prefix, Localization.UnitOfMeasureNotSpecified);
                return;
            }
            if (UnitOfMeasureMode == UnitOfMeasureMode.Category || UnitOfMeasureMode == UnitOfMeasureMode.Fixed)
            {
                if (string.IsNullOrEmpty(UnitOfMeasureCategory))
                {
                    AddError(messages, prefix, Localization.UnitOfMeasureCategoryNotSpecified);
                    return;
                }

                //If there's no context, we can't look for things
                if (context == null)
                    return;

                //Find the category
                var enumCategory = context.GetEnumCategory(new EnumerationType(PropertyBagConstants.MetraTechUnitOfMeasureNamespace));
                if (enumCategory == null)
                {
                    AddError(messages, prefix, Localization.UnableToFindEnumCategory);
                    return;
                }

                //Ensure Enum is a UoM
                if (enumCategory.EnumMode != EnumMode.UnitOfMeasure)
                {
                    AddError(messages, prefix, Localization.UnitOfMeasureCategoryMustBeUom);
                    return;
                }

                //Ensure the value is specified
                if (string.IsNullOrEmpty(FixedUnitOfMeasure))
                {
                    AddError(messages, prefix, Localization.UnitOfMeasureNotSpecified);
                    return;
                }

                //Ensure that the value exists
                if (UnitOfMeasureMode == UnitOfMeasureMode.Fixed)
                {
                    AddError(messages, prefix, string.Format(CultureInfo.CurrentCulture, Localization.UnableToFindUnitOfMeasure, FixedUnitOfMeasure));
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
            type.FixedUnitOfMeasure = FixedUnitOfMeasure;
            type.UnitOfMeasureProperty = UnitOfMeasureProperty;
            return type;
        }
        #endregion

    }
}
