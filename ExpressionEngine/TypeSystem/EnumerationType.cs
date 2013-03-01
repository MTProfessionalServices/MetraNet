using System;
using System.Runtime.Serialization;
using System.Globalization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract (Namespace = "MetraTech")]
    public class EnumerationType : Type
    {
        #region Properties
        /// <summary>
        /// The namespace; used to prevent name collisions
        /// </summary>
        [DataMember]
        public string Namespace { get; set; }

        /// <summary>
        /// The enum's category (what contains the actual values)
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
        public EnumerationType(string enumSpace, string enumType):base(BaseType.Enumeration)
        {
            Namespace = enumSpace;
            Category = enumType;
        }
        #endregion

        #region Methods
        public override string ToString(bool robust)
        {
            if (robust)
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}.{2}", BaseType, Namespace, Category);
            return BaseType.ToString();
        }


        public override void Validate(string prefix, ValidationMessageCollection messages)
        {
            if (messages == null)
                throw new ArgumentNullException("messages");

            //Check if the EnumNamespace was specified
            if (string.IsNullOrEmpty(Namespace))
            {
                messages.Error(Localization.EnumNamespaceNotSpecified);
                return;
            }

            ////Check if the NameSpace exists
            //if (!Context.NamespaceExists(EnumNamespace))
            //{
            //    messages.Error(string.Format(CultureInfo.InvariantCulture, Localization.UnableToFindEnumNamespace, EnumNamespace));
            //    return;
            //}

            //Check if the Category was specified
            if (string.IsNullOrEmpty(Category))
            {
                messages.Error(string.Format(CultureInfo.CurrentCulture, Localization.EnumTypeNotSpecified));
                return;
            }

            //Check if the Cateegory exists
            //if (!Context.TypeExists(EnumNamespace, Category))
            //{
            //    messages.Error(string.Format(CultureInfo.InvariantCulture, Localization.UnableToFindEnumType, EnumNamespace + "." + Category));
            //}
        }

        public new EnumerationType Copy()
        {
            var type = (EnumerationType)base.Copy();
            InternalCopy(type);
            type.Namespace = Namespace;
            type.Category = Category;
            return type;
        }
        #endregion

    }
}
