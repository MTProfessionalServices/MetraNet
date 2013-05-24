
using System;
using System.Collections.Generic;


namespace MetraTech.Tax.Framework.DataAccess
{
    /// <summary>
    /// This class represents a parameter that needs to be passed to
    /// a tax vendor so that the vendor can compute taxes.
    /// This class can also be viewed as a representation of a single
    /// row from the t_tax_vendor_params table.
    /// </summary>
    public class TaxParameter
    {
        public TaxParameter(string parameterName, string description, Type parameterType, object parameterValue)
        {
            if (String.IsNullOrEmpty(parameterName)) throw new TaxException("Parameter name cannot be null or empty.");
            ParameterName = parameterName;
            if (String.IsNullOrEmpty(description))
                Description = "";
            ParameterType = parameterType;
            ParameterValue = parameterValue;
        }

        /// <summary>
        /// Name of the tax vendor parameter
        /// </summary>
        public string ParameterName { set; get; }

        /// <summary>
        /// Description of the tax vendor parameter
        /// </summary>
        public string Description { set; get; }

        /// <summary>
        ///  Type of the tax vendor parameter
        /// </summary>
        public Type ParameterType { set; get; }

        /// <summary>
        /// Value of the tax vendor parameter
        /// </summary>
        public object ParameterValue { set; get; }

        public override string ToString()
        {
            return String.Format("ParameterName={0}, Description={1}, ParameterType={2}, ParameterValue={3}",
                                 ParameterName, Description, ParameterType, ParameterValue);
        }
    }
}
