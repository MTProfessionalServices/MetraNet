

using System;
using System.Collections.Generic;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;


namespace MetraTech.Tax.Framework.DataAccess
{
    /// <summary>
    /// A TaxableTransaction contains the information necessary to perform
    /// a tax calculation.  Therefore, this class contains the name-value pairs
    /// that will be passed to vendor's tax software to calculate taxes.
    /// This class abstracts the details of how the default values will be
    /// extracted from t_tax_vendor_params when non-default values are not
    /// provided.
    /// </summary>
    public class TaxableTransaction
    {
        private static readonly Logger m_Logger = new Logger("[TaxableTransaction]");

        /// <summary>
        /// Except for the well known fields, most all parameters are 
        /// outlined in the t_tax_vender_params table. When processing an input row
        /// we will need to provide access to all rows (known and unknown)
        /// thus this implemenation is in the form of a dictionary or property bag.
        /// </summary>
        private readonly Dictionary<string, TaxParameter> m_TaxParameters;

        /// <summary>
        /// Specifies which vendor will be used to perform the tax calculation.
        /// </summary>
        private readonly TaxVendor m_TaxVendor;

        /// <summary>
        /// Constructor that creates a TaxableTransaction this is suitable
        /// for the specified tax vendor.
        /// </summary>
        /// <param name="taxVendor"></param>
        public TaxableTransaction(TaxVendor taxVendor)
        {
            m_TaxVendor = taxVendor;
            m_TaxParameters = new Dictionary<string, TaxParameter>();
        }

        public TaxVendor GetTaxVendor()
        {
            return m_TaxVendor;
        }

        /// <summary>
        /// Returns the TaxParameter object associated with the specified parameter name
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns></returns>
        public TaxParameter GetTaxParameter(string parameterName)
        {
            TaxParameter taxParameter = null;
            if (m_TaxParameters.TryGetValue(parameterName, out taxParameter))
            {
                return taxParameter;
            }
            return null;
        }

        /// <summary>
        /// Returns the TaxParameter object associated with the specified parameter name
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns></returns>
        public TaxParameter GetTaxParameterOrDefault(string parameterName)
        {
            TaxParameter taxParameter = null;
            if (m_TaxParameters.TryGetValue(parameterName, out taxParameter))
            {
                return taxParameter;
            }
            else
            {
                return TaxParameterDefaultManager.Instance.GetDefaultTaxParameter(parameterName, m_TaxVendor);
            }
        }
        /// <summary>
        /// Gets the field as the correct type (assumes that object already is that type)
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns>the value, null or, can throw and exception if the value is not in parameter table</returns>
        public Int32? GetInt32(string parameterName)
        {
            Boolean isNull;

            // If the column doesn't have a value, then we are just going to retrieve
            // the value as an int32.  The method we call will get the default from
            // the tax_vendor_params table.
            if (!IsParameterValueAvailable(parameterName))
            {
                Int32? r32 = GetParameterValueOrDefault<Int32>(parameterName, "Int32", out isNull);
                return isNull ? null : r32;
            }

            // If we are here, we know that there is a value in t_tax_input.
            // Read the value as an int64 (avoids hitting a cast error).
            Int64? r64 = GetParameterValueOrDefault<Int64>(parameterName, "Int64", out isNull);
            if (isNull)
            {
                return null;
            }

            // Make sure that the value will fit into int32
            if (r64 > 2147483648 || r64 < -2147483648)
            {
                String msg = "Unable to return t_tax_input table value " + r64 +
                    " column (" + parameterName + ") as " + "an Int32 because it is too large (or small) to fit. ";
                throw new TaxException(msg);
            }

            Int32? r = (Int32?)r64;

            return r;
        }

        /// <summary>
        /// Gets the field as the correct type (assumes that object already is that type)
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns>the value, null or, can throw and exception if the value is not in parameter table</returns>
        public String GetString(string parameterName)
        {
            Boolean isNull;
            var r = GetParameterValueOrDefault<String>(parameterName, "String", out isNull);
            return isNull ? String.Empty : r;
        }
        /// <summary>
        /// Gets the field as the correct type (assumes that object already is that type)
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns>the value, null or, can throw and exception if the value is not in parameter table</returns>
        public Decimal? GetDecimal(string parameterName)
        {
            Boolean isNull;
            Decimal? r = GetParameterValueOrDefault<Decimal>(parameterName, "Decimal", out isNull);
            return isNull ? null : r;
        }
        /// <summary>
        /// Gets the field as the correct type (assumes that object already is that type)
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns>the value, null or, can throw and exception if the value is not in parameter table</returns>
        public DateTime? GetDateTime(string parameterName)
        {
            Boolean isNull;
            DateTime? r = GetParameterValueOrDefault<DateTime>(parameterName, "DateTime", out isNull);
            return isNull ? null : r;
        }
        /// <summary>
        /// Gets the field as the correct type (assumes that object already is that type)
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns>the value, null or, can throw and exception if the value is not in parameter table</returns>
        public Int64? GetInt64(string parameterName)
        {
            Boolean isNull;
            Int64? r = GetParameterValueOrDefault<Int64>(parameterName, "Int64", out isNull);
            return isNull ? null : r;
        }
        /// <summary>
        /// Gets the field as the correct type (assumes that object already is that type)
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns>the value, null or, can throw and exception if the value is not in parameter table</returns>
        public Boolean? GetBool(string parameterName)
        {
            Boolean isNull;
            var s = GetParameterValueOrDefault<String>(parameterName, "String", out isNull);
            return isNull ? (bool?)null : ConvertStringToBoolean(s);
        }

        /// <summary>
        /// Converts the string flag to a real boolean.
        /// </summary>
        /// <param name="flag">string flag, acceptable values (true, false, 0, 1, t, f, y, n, yes, no)</param>
        /// <returns>boolean representation</returns>
        private static bool ConvertStringToBoolean(string flag)
        {
            switch (flag.ToUpper().Trim())
            {
                case "TRUE":
                case "YES":
                case "Y":
                case "T":
                case "1":
                    return true;
             
                default:
                    return false;
            }
        }

        /// <summary>
        /// Returns true if the tax_input table has a value for given column.
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns>true if value is present</returns>
        private bool IsParameterValueAvailable(string parameterName)
        {
            try
            {
                return (m_TaxParameters.ContainsKey(parameterName) && null != m_TaxParameters[parameterName].ParameterValue);
            }
            catch (Exception e)
            {
                String err = "Failed to determine if tax_input table column " + parameterName + " has a value";
                err = err + " Inner exception: " + e.Message;
                throw new TaxException(err);
            }
        }

        /// <summary>
        /// Retrieve the parameter value for the specified parameterName
        /// from this TaxableTransaction, or retrieve the default value
        /// from the TaxParameterDefaultManager.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="parameterName">name of a parameter within a TaxableTransaction</param>
        /// <param name="desiredType"> </param>
        /// <param name="isNull"></param>
        /// <returns></returns>
        private T GetParameterValueOrDefault<T>(string parameterName, string desiredType, out bool isNull)
        {
            isNull = false;

            try
            {
                // Column exists in row, and has a value
                if (m_TaxParameters.ContainsKey(parameterName) && null != m_TaxParameters[parameterName].ParameterValue)
                {
                    if ((m_TaxParameters[parameterName].ParameterValue.GetType().ToString() == "System.Int32") &&
                        (desiredType == "Int64"))
                    {
                        // Integer values are handled differently on Oracle and SqlServer.  This
                        // double cast handles the special case where the value returned by the
                        // DB is an "Int32" object, and the caller wants the value as an Int64.
                        // (Note: can't unbox and convert type with a single cast)
                        //return (T)(Int32)m_TaxParameters[parameterName].ParameterValue;
                        Int64 tmp64Value = Convert.ToInt64(m_TaxParameters[parameterName].ParameterValue);
                        Object tmp64Object = tmp64Value;
                        return (T)tmp64Object;
                    }
                    if ((m_TaxParameters[parameterName].ParameterValue.GetType().ToString() == "System.Decimal") &&
                        (desiredType == "Int64"))
                    {
                        // Integer values are handled differently on Oracle and SqlServer.  The MT reader
                        // returns "System.Decimal" for columns in a table with type "number(20,0)".
                        // This double cast handles the special case where the value returned by the
                        // DB is a "System.Decimal" object, and the caller wants the value as an Int64.
                        // (Note: can't unbox and convert type with a single cast)
                        Int64 tmp64Value = Convert.ToInt64(m_TaxParameters[parameterName].ParameterValue);
                        Object tmp64Object = tmp64Value;
                        return (T)tmp64Object;
                    }
                    
                    return (T)m_TaxParameters[parameterName].ParameterValue;
                    
                }

                // At this point we're going to have to get the default from the
                // vendor parameter table.
                return TaxParameterDefaultManager.Instance.GetDefaultTaxParameterValue<T>(parameterName, m_TaxVendor, out isNull);
            }
            catch (Exception e)
            {
                String err = "Failed to properly cast the datatype of column " + parameterName + " to " + desiredType + ".";
                if (m_TaxParameters.ContainsKey(parameterName) && null != m_TaxParameters[parameterName].ParameterValue &&
                    m_TaxParameters[parameterName].ParameterValue != null)
                {
                    err = err + " The type of the t_tax_input column is " +
                          m_TaxParameters[parameterName].ParameterValue;
                    err = err + " The value of field is " + m_TaxParameters[parameterName].ParameterValue;
                }
                err = err + " Inner exception: " + e.Message;
                throw new TaxException(err);
            }

        }

        /// <summary>
        /// Stores a taxParameter within the TaxTransaction
        /// </summary>
        /// <param name="taxParameter"></param>
        /// <returns>nothing</returns>
        public void StoreTaxParameter(TaxParameter taxParameter)
        {
            m_TaxParameters[taxParameter.ParameterName] = taxParameter;
        }

        public override string ToString()
        {
            string retString = String.Format("m_TaxVendor={0}\n", m_TaxVendor);
            foreach (var pair in m_TaxParameters)
            {
                retString += String.Format("ParameterName={0}, ParameterValue={1}\n", pair.Value.ParameterName,
                                           pair.Value.ParameterValue);
            }
            return retString;
        }

        /// <summary>
        /// Write the contents of the TaxableTransaction to the log file.
        /// </summary>
        public void LogContents()
        {
            m_Logger.LogDebug("m_TaxVendor={0}", m_TaxVendor);
            foreach (var pair in m_TaxParameters)
            {
                m_Logger.LogDebug("ParameterName={0}, Description={1}, ParameterType={2}, ParameterValue={3}",
                        pair.Value.ParameterName,
                        pair.Value.Description,
                        pair.Value.ParameterType,
                        pair.Value.ParameterValue);
            }
        }
    }
}
