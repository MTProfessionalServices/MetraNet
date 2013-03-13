using System;
using System.Runtime.Serialization;
using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    /// <summary>
    /// A enumeration which requires a Namespace and Category 
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class EnumerationType : Type
    {
        #region Properties
        /// <summary>
        /// The namespace; used to prevent Category name collisions 
        /// </summary>
        public string Namespace { get { return BasicHelper.GetNamespaceFromFullName(Category); } }

        /// <summary>
        /// The enum's category. This is a fully qualified name that includes the namespace
        /// </summary>
        [DataMember]
        public string Category { get; set; }

        /// <summary>
        /// Returns a string that can be used to determine if two types are directly compatible (which is differnt than castable)
        /// </summary>
        /// <returns></returns>
        public override string CompatibleKey
        {
            get
            {
             return string.Format(CultureInfo.InvariantCulture, "{0}|{1}|{2}", BaseType, Namespace, Category);
            }
        }
        #endregion

        #region Constructor
        public EnumerationType(string category):base(BaseType.Enumeration)
        {
            Category = category;
        }
        #endregion

        #region Methods
        public override string ToString(bool robust)
        {
            if (robust)
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", BaseType, Category);
            return BaseType.ToString();
        }


        public override void Validate(string prefix, ValidationMessageCollection messages, Context context)
        {
            if (messages == null)
                throw new ArgumentNullException("messages");

            //Check if the Category was specified
            if (string.IsNullOrEmpty(Category))
            {
                messages.Error(string.Format(CultureInfo.CurrentCulture, Localization.EnumCategoryNotSpecified));
                return;
            }

            //Check if the Category exists         
            if (context != null)
            {
                var enumCategory = context.GetEnumCategory(Category);
                if (enumCategory == null)
                    messages.Error(string.Format(CultureInfo.InvariantCulture, Localization.UnableToFindEnumCategory, Namespace + "." + Category));
            }
        }

        public new EnumerationType Copy()
        {
            var type = (EnumerationType)base.Copy();
            InternalCopy(type);
            type.Category = Category;
            return type;
        }
        #endregion

    }
}
