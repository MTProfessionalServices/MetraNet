#region Generated using ICE (Do not modify this region)
/// Generated using ICE
/// ICE CodeGen Version: 1.0.0
#endregion
#undef ERROR_ON_NULL_GET

//////////////////////////////////////////////////////////////////////////////
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Diagnostics;
using System.Configuration;
using System.Collections.Generic;
using System.Xml;
using MetraTech.Pipeline;
using MetraTech.Interop.MTPipelineLib;
//STANDARD_ENUM_REFERENCES

using IMTSystemContext = MetraTech.Interop.SysContext.IMTSystemContext;
using IMTConfigPropSet = MetraTech.Interop.MTPipelineLib.IMTConfigPropSet;
using MTLog = MetraTech.Interop.SysContext.MTLog;
using IMTNameID = MetraTech.Interop.SysContext.IMTNameID;
using IEnumConfig = MetraTech.Interop.SysContext.IEnumConfig;
using System.Collections.ObjectModel;
//ENUM_USING

namespace MetraTech.Tax.Plugins
{
    #region Properties class
    public class Properties
    {
        #region Variables
        private PipelineProperties m_pipeline;
        private ISession m_session;
        #endregion

        #region Construction
        internal static Properties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
            PipelineProperties pipelinePrototype = PipelineProperties.CreatePrototype(log, systemContext, xmlConfig);

            return new Properties(pipelinePrototype);
        }
        internal static Properties Create(Properties prototype, ISession session)
        {
            PipelineProperties pipeline = PipelineProperties.Create(prototype.m_pipeline, session);

            return new Properties(pipeline, session);
        }
        private Properties(PipelineProperties pipeline) : this(pipeline, null) { }
        private Properties(PipelineProperties pipeline, ISession session)
        {
            m_pipeline = pipeline;
            m_session = session;
        }
        #endregion

        #region Properties
        internal ISession Session
        {
            get { return m_session; }
        }
        internal PipelineProperties Pipeline
        {
            get { return m_pipeline; }
        }
        #endregion
    }
    #endregion

    #region GeneralConfig class
    public sealed class GeneralConfig
    {
        #region General config variables
        private bool? m_shouldtaxdetailsbestored;
        private bool? m_defaultisimpliedtax;
        private string m_defaultproductcode;
        private string m_defaultroundingalgorithm;
        private int? m_defaultroundingdigits;

	// Taxware specific
        private string m_defaultcustomername;
        private string m_defaultcustomercode;
        private string m_defaultbilltoaddress;
        private string m_defaultbilltocity;
        private string m_defaultbilltostateprovince;
        private string m_defaultbilltopostalcode;
        private string m_defaultbilltocountry;
        private string m_defaultbilltolocationcode;
        private int? m_defaultbilltogeocode;
	
        private string m_defaultloaaddress;
        private string m_defaultloacity;
        private string m_defaultloastateprovince;
        private string m_defaultloapostalcode;
        private string m_defaultloacountry;
        private string m_defaultloalocationcode;
        private int? m_defaultloageocode;
	
        private string m_defaultloraddress;
        private string m_defaultlorcity;
        private string m_defaultlorstateprovince;
        private string m_defaultlorpostalcode;
        private string m_defaultlorcountry;
        private string m_defaultlorlocationcode;
        private int? m_defaultlorgeocode;
	
        private string m_defaultlspaddress;
        private string m_defaultlspcity;
        private string m_defaultlspstateprovince;
        private string m_defaultlsppostalcode;
        private string m_defaultlspcountry;
        private string m_defaultlsplocationcode;
        private int? m_defaultlspgeocode;
	
        private string m_defaultluaddress;
        private string m_defaultlucity;
        private string m_defaultlustateprovince;
        private string m_defaultlupostalcode;
        private string m_defaultlucountry;
        private string m_defaultlulocationcode;
        private int? m_defaultlugeocode;
	
        private string m_defaultshipfromaddress;
        private string m_defaultshipfromcity;
        private string m_defaultshipfromstateprovince;
        private string m_defaultshipfrompostalcode;
        private string m_defaultshipfromcountry;
        private string m_defaultshipfromlocationcode;
        private int? m_defaultshipfromgeocode;
	
        private string m_defaultshiptoaddress;
        private string m_defaultshiptocity;
        private string m_defaultshiptostateprovince;
        private string m_defaultshiptopostalcode;
        private string m_defaultshiptocountry;
        private string m_defaultshiptolocationcode;
        private int? m_defaultshiptogeocode;
	
        private string m_defaultgoodorservicecode;
        private string m_defaultsku;
        private string m_defaultcurrency;
        private string m_defaultorganizationcode;
        //GENERAL_CONFIG_VAR
        #endregion

        #region Construction 
        private const string GeneralConfigTag = "GeneralConfig";
        private readonly string XPathToGeneralConfig = String.Format("{0}", GeneralConfigTag);
        internal GeneralConfig(IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
            XmlNode generalConfigProps = xmlConfig.DocumentElement.SelectSingleNode(XPathToGeneralConfig);
            

            if (generalConfigProps == null)
            {
                throw new ConfigurationErrorsException(String.Format("The '{0}' was not found in t xpath = {1}. Can not configure Plug-in. Configuration content = '{2}'"
                    , GeneralConfigTag, XPathToGeneralConfig, xmlConfig.OuterXml));
            }

            
            
            m_shouldtaxdetailsbestored = bool.Parse(GetValueFromParameter(generalConfigProps, "ShouldTaxDetailsBeStored"));
            m_defaultisimpliedtax = bool.Parse(GetValueFromParameter(generalConfigProps, "DefaultIsImpliedTax"));
            m_defaultproductcode = (string)GetValueFromParameter(generalConfigProps, "DefaultProductCode");
            m_defaultroundingalgorithm = (string)GetValueFromParameter(generalConfigProps, "DefaultRoundingAlgorithm");
            m_defaultroundingdigits = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultRoundingDigits"));

            

            m_defaultcustomername = (string)GetValueFromParameter(generalConfigProps, "DefaultCustomerName");


            m_defaultcustomercode = (string)GetValueFromParameter(generalConfigProps, "DefaultCustomerCode");

            m_defaultbilltoaddress = (string)GetValueFromParameter(generalConfigProps, "DefaultBillToAddress");
            m_defaultbilltocity = (string)GetValueFromParameter(generalConfigProps, "DefaultBillToCity");
            m_defaultbilltostateprovince = (string)GetValueFromParameter(generalConfigProps, "DefaultBillToStateProvince");
            m_defaultbilltopostalcode = (string)GetValueFromParameter(generalConfigProps, "DefaultBillToPostalCode");
            m_defaultbilltocountry = (string)GetValueFromParameter(generalConfigProps, "DefaultBillToCountry");
            m_defaultbilltolocationcode = (string)GetValueFromParameter(generalConfigProps, "DefaultBillToLocationCode");
            m_defaultbilltogeocode = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultBillToGeoCode"));

            m_defaultloaaddress = (string)GetValueFromParameter(generalConfigProps, "DefaultLoaAddress");
            m_defaultloacity = (string)GetValueFromParameter(generalConfigProps, "DefaultLoaCity");
            m_defaultloastateprovince = (string)GetValueFromParameter(generalConfigProps, "DefaultLoaStateProvince");
            m_defaultloapostalcode = (string)GetValueFromParameter(generalConfigProps, "DefaultLoaPostalCode");
            m_defaultloacountry = (string)GetValueFromParameter(generalConfigProps, "DefaultLoaCountry");
            m_defaultloalocationcode = (string)GetValueFromParameter(generalConfigProps, "DefaultLoaLocationCode");
            m_defaultloageocode = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultLoaGeoCode"));

            

            m_defaultloraddress = (string)GetValueFromParameter(generalConfigProps, "DefaultLorAddress");
            m_defaultlorcity = (string)GetValueFromParameter(generalConfigProps, "DefaultLorCity");
            m_defaultlorstateprovince = (string)GetValueFromParameter(generalConfigProps, "DefaultLorStateProvince");
            m_defaultlorpostalcode = (string)GetValueFromParameter(generalConfigProps, "DefaultLorPostalCode");
            m_defaultlorcountry = (string)GetValueFromParameter(generalConfigProps, "DefaultLorCountry");
            m_defaultlorlocationcode = (string)GetValueFromParameter(generalConfigProps, "DefaultLorLocationCode");
            m_defaultlorgeocode = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultLorGeoCode"));

            m_defaultlspaddress = (string)GetValueFromParameter(generalConfigProps, "DefaultLspAddress");
            m_defaultlspcity = (string)GetValueFromParameter(generalConfigProps, "DefaultLspCity");
            m_defaultlspstateprovince = (string)GetValueFromParameter(generalConfigProps, "DefaultLspStateProvince");
            m_defaultlsppostalcode = (string)GetValueFromParameter(generalConfigProps, "DefaultLspPostalCode");
            m_defaultlspcountry = (string)GetValueFromParameter(generalConfigProps, "DefaultLspCountry");
            m_defaultlsplocationcode = (string)GetValueFromParameter(generalConfigProps, "DefaultLspLocationCode");
            m_defaultlspgeocode = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultLspGeoCode"));

            m_defaultluaddress = (string)GetValueFromParameter(generalConfigProps, "DefaultLuAddress");
            m_defaultlucity = (string)GetValueFromParameter(generalConfigProps, "DefaultLuCity");
            m_defaultlustateprovince = (string)GetValueFromParameter(generalConfigProps, "DefaultLuStateProvince");
            m_defaultlupostalcode = (string)GetValueFromParameter(generalConfigProps, "DefaultLuPostalCode");
            m_defaultlucountry = (string)GetValueFromParameter(generalConfigProps, "DefaultLuCountry");
            m_defaultlulocationcode = (string)GetValueFromParameter(generalConfigProps, "DefaultLuLocationCode");
            m_defaultlugeocode = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultLuGeoCode"));

            m_defaultshipfromaddress = (string)GetValueFromParameter(generalConfigProps, "DefaultShipFromAddress");
            m_defaultshipfromcity = (string)GetValueFromParameter(generalConfigProps, "DefaultShipFromCity");
            m_defaultshipfromstateprovince = (string)GetValueFromParameter(generalConfigProps, "DefaultShipFromStateProvince");
            m_defaultshipfrompostalcode = (string)GetValueFromParameter(generalConfigProps, "DefaultShipFromPostalCode");
            m_defaultshipfromcountry = (string)GetValueFromParameter(generalConfigProps, "DefaultShipFromCountry");
            m_defaultshipfromlocationcode = (string)GetValueFromParameter(generalConfigProps, "DefaultShipFromLocationCode");
            m_defaultshipfromgeocode = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultShipFromGeoCode"));

            m_defaultshiptoaddress = (string)GetValueFromParameter(generalConfigProps, "DefaultShipToAddress");
            m_defaultshiptocity = (string)GetValueFromParameter(generalConfigProps, "DefaultShipToCity");
            m_defaultshiptostateprovince = (string)GetValueFromParameter(generalConfigProps, "DefaultShipToStateProvince");
            m_defaultshiptopostalcode = (string)GetValueFromParameter(generalConfigProps, "DefaultShipToPostalCode");
            m_defaultshiptocountry = (string)GetValueFromParameter(generalConfigProps, "DefaultShipToCountry");
            m_defaultshiptolocationcode = (string)GetValueFromParameter(generalConfigProps, "DefaultShipToLocationCode");
            m_defaultshiptogeocode = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultShipToGeoCode"));

            m_defaultgoodorservicecode = (string)GetValueFromParameter(generalConfigProps, "DefaultGoodOrServiceCode");
            m_defaultsku = (string)GetValueFromParameter(generalConfigProps, "DefaultSku");
            m_defaultcurrency = (string)GetValueFromParameter(generalConfigProps, "DefaultCurrency");
            m_defaultorganizationcode = (string)GetValueFromParameter(generalConfigProps, "DefaultOrganizationCode");
            //GENERAL_CONFIG_ASSIGN
        }
        
        private static string GetValueFromParameter(XmlNode node, string paramName)
        {
            XmlNode childNode = node.SelectSingleNode(paramName);
            if (childNode == null)
            {
                throw new ConfigurationErrorsException(String.Format("The '{0}' parametr name does not set into '{1}'. Section content = '{2}'"
                    , paramName, GeneralConfigTag, node.OuterXml));
            }
            return childNode.InnerText;
        }
        #endregion

        #region General Config Properties
        /// <summary>
        /// For each transaction tax, MetraNet can stored detalied information (in the t_tax_details table).  This value determines if these details are saved or not.
        /// </summary>
        internal bool? ShouldTaxDetailsBeStored
        {
            get
            {
                return m_shouldtaxdetailsbestored;
            }
        }
        /// <summary>
        /// If true, the amount already includes the tax.
        /// </summary>
        internal bool? DefaultIsImpliedTax
        {
            get
            {
                return m_defaultisimpliedtax;
            }
        }
        /// <summary>
        /// A code identifying the product.  This same code should be used in the MetraTax parameter table define the tax rate for the product.
        /// </summary>
        internal string DefaultProductCode
        {
            get
            {
                return m_defaultproductcode;
            }
        }
        /// <summary>
        /// The rounding algorithm to use.  Acceptable values are: NONE or BANK.  NONE means no rounding will be performed. BANK means banker's rounding will be performed.
        /// </summary>
        internal string DefaultRoundingAlgorithm
        {
            get
            {
                return m_defaultroundingalgorithm;
            }
        }
        /// <summary>
        /// The number of rounding digits. 0 - no rounding, 1 round to 1 digit after decimal point, 2 for 2 digits, etc.
        /// </summary>
        internal int? DefaultRoundingDigits
        {
            get
            {
                return m_defaultroundingdigits;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultCustomerName
        {
            get
            {
                return m_defaultcustomername;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultCustomerCode
        {
            get
            {
                return m_defaultcustomercode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultBillToAddress
        {
            get
            {
                return m_defaultbilltoaddress;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultBillToCity
        {
            get
            {
                return m_defaultbilltocity;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultBillToStateProvince
        {
            get
            {
                return m_defaultbilltostateprovince;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultBillToPostalCode
        {
            get
            {
                return m_defaultbilltopostalcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultBillToCountry
        {
            get
            {
                return m_defaultbilltocountry;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultBillToLocationCode
        {
            get
            {
                return m_defaultbilltolocationcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal int? DefaultBillToGeoCode
        {
            get
            {
                return m_defaultbilltogeocode;
            }
        }

        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLoaAddress
        {
            get
            {
                return m_defaultloaaddress;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLoaCity
        {
            get
            {
                return m_defaultloacity;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLoaStateProvince
        {
            get
            {
                return m_defaultloastateprovince;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLoaPostalCode
        {
            get
            {
                return m_defaultloapostalcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLoaCountry
        {
            get
            {
                return m_defaultloacountry;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLoaLocationCode
        {
            get
            {
                return m_defaultloalocationcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal int? DefaultLoaGeoCode
        {
            get
            {
                return m_defaultloageocode;
            }
        }

        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLorAddress
        {
            get
            {
                return m_defaultloaaddress;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLorCity
        {
            get
            {
                return m_defaultloacity;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLorStateProvince
        {
            get
            {
                return m_defaultloastateprovince;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLorPostalCode
        {
            get
            {
                return m_defaultloapostalcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLorCountry
        {
            get
            {
                return m_defaultloacountry;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLorLocationCode
        {
            get
            {
                return m_defaultloalocationcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal int? DefaultLorGeoCode
        {
            get
            {
                return m_defaultloageocode;
            }
        }

        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLspAddress
        {
            get
            {
                return m_defaultlspaddress;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLspCity
        {
            get
            {
                return m_defaultlspcity;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLspStateProvince
        {
            get
            {
                return m_defaultlspstateprovince;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLspPostalCode
        {
            get
            {
                return m_defaultlsppostalcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLspCountry
        {
            get
            {
                return m_defaultlspcountry;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLspLocationCode
        {
            get
            {
                return m_defaultlsplocationcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal int? DefaultLspGeoCode
        {
            get
            {
                return m_defaultlspgeocode;
            }
        }

        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLuAddress
        {
            get
            {
                return m_defaultluaddress;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLuCity
        {
            get
            {
                return m_defaultlucity;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLuStateProvince
        {
            get
            {
                return m_defaultlustateprovince;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLuPostalCode
        {
            get
            {
                return m_defaultlupostalcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLuCountry
        {
            get
            {
                return m_defaultlucountry;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultLuLocationCode
        {
            get
            {
                return m_defaultlulocationcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal int? DefaultLuGeoCode
        {
            get
            {
                return m_defaultlugeocode;
            }
        }

        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipFromAddress
        {
            get
            {
                return m_defaultshipfromaddress;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipFromCity
        {
            get
            {
                return m_defaultshipfromcity;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipFromStateProvince
        {
            get
            {
                return m_defaultshipfromstateprovince;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipFromPostalCode
        {
            get
            {
                return m_defaultshipfrompostalcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipFromCountry
        {
            get
            {
                return m_defaultshipfromcountry;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipFromLocationCode
        {
            get
            {
                return m_defaultshipfromlocationcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal int? DefaultShipFromGeoCode
        {
            get
            {
                return m_defaultshipfromgeocode;
            }
        }

        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipToAddress
        {
            get
            {
                return m_defaultshiptoaddress;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipToCity
        {
            get
            {
                return m_defaultshiptocity;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipToStateProvince
        {
            get
            {
                return m_defaultshiptostateprovince;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipToPostalCode
        {
            get
            {
                return m_defaultshiptopostalcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipToCountry
        {
            get
            {
                return m_defaultshiptocountry;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultShipToLocationCode
        {
            get
            {
                return m_defaultshiptolocationcode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal int? DefaultShipToGeoCode
        {
            get
            {
                return m_defaultshiptogeocode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultGoodOrServiceCode
        {
            get
            {
                return m_defaultgoodorservicecode;
            }
        }
        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultSku
        {
            get
            {
                return m_defaultsku;
            }
        }

        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultCurrency
        {
            get
            {
                return m_defaultcurrency;
            }
        }

        /// <summary>
        /// YYYYY
        /// </summary>
        internal string DefaultOrganizationCode
        {
            get
            {
                return m_defaultorganizationcode;
            }
        }

        //GENERAL_CONFIG_PROP
        #endregion
    }
    #endregion

    #region Properties Collection class
    public sealed class PropertiesCollection : IEnumerable<Properties>
    {
        private ReadOnlyCollection<ISession> m_sessions;
        private Properties m_prototype;

        public PropertiesCollection(Properties prototype, ReadOnlyCollection<ISession> sessions)
        {
            m_sessions = sessions;
            m_prototype = prototype;
        }

        public int IndexOf(Properties item)
        {
            return m_sessions.IndexOf(item.Session);
        }

        public Properties this[int index]
        {
            get
            {
                return Properties.Create(m_prototype, m_sessions[index]);
            }
        }

        public bool Contains(Properties item)
        {
            return m_sessions.Contains(item.Session);
        }

        public void CopyTo(Properties[] array, int arrayIndex)
        {
            for (int i = 0, j = arrayIndex;
                j < array.Length && i < m_sessions.Count;
                ++i, ++j)
            {
                array[j] = Properties.Create(m_prototype, m_sessions[i]);
            }
        }

        public int Count
        {
            get { return m_sessions.Count; }
        }

        public bool IsReadOnly
        {
            get { return true; }
        }

        public IEnumerator<Properties> GetEnumerator()
        {
            return new PropertiesEnumerator(this);
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return new PropertiesEnumerator(this);
        }

        public struct PropertiesEnumerator : IEnumerator<Properties>
        {
            private PropertiesCollection m_propsCol;
            private int m_index;
            private const int START = -1;

            public PropertiesEnumerator(PropertiesCollection propsCol)
            {
                m_propsCol = propsCol;
                m_index = START;
            }
            public Properties Current
            {
                get
                {
                    return m_propsCol[m_index];
                }
            }
            public void Dispose()
            {
                m_propsCol = null;
                m_index = START;
            }
            object System.Collections.IEnumerator.Current
            {
                get { return this.Current; }
            }

            public bool MoveNext()
            {
                if ((m_index + 1) <= (m_propsCol.Count - 1))
                {
                    ++m_index;
                    return true;
                }
                else
                    return false;
            }

            public void Reset()
            {
                m_index = START;
            }
        }
    }
    #endregion

    #region PipelineProperties Class
    public sealed class PipelineProperties
    {
        #region Non-Pipeline variables
        private ISession m_session;
        private IEnumConfig m_enumConfig;
        private PlugInBase.LogDelegate Log;
        #endregion

        #region Pipeline variables
        private Binding<int> m_accountid;
        private Binding<decimal> m_amount;
        private Binding<DateTime> m_invoicedate;
        private Binding<int> m_intervalid;
        private Binding<string> m_productcode;
        private Binding<bool> m_isimpliedtax;
        private Binding<string> m_roundingalgorithm;
        private Binding<int> m_roundingdigits;

        private Binding<string> m_customername;
        private Binding<string> m_customercode;

        private Binding<string> m_billtoaddress;
        private Binding<string> m_billtocity;
        private Binding<string> m_billtostateprovince;
        private Binding<string> m_billtopostalcode;
        private Binding<string> m_billtocountry;
        private Binding<string> m_billtolocationcode;
        private Binding<int> m_billtogeocode;

        private Binding<string> m_loaaddress;
        private Binding<string> m_loacity;
        private Binding<string> m_loastateprovince;
        private Binding<string> m_loapostalcode;
        private Binding<string> m_loacountry;
        private Binding<string> m_loalocationcode;
        private Binding<int> m_loageocode;

        private Binding<string> m_loraddress;
        private Binding<string> m_lorcity;
        private Binding<string> m_lorstateprovince;
        private Binding<string> m_lorpostalcode;
        private Binding<string> m_lorcountry;
        private Binding<string> m_lorlocationcode;
        private Binding<int> m_lorgeocode;

        private Binding<string> m_lspaddress;
        private Binding<string> m_lspcity;
        private Binding<string> m_lspstateprovince;
        private Binding<string> m_lsppostalcode;
        private Binding<string> m_lspcountry;
        private Binding<string> m_lsplocationcode;
        private Binding<int> m_lspgeocode;

        private Binding<string> m_luaddress;
        private Binding<string> m_lucity;
        private Binding<string> m_lustateprovince;
        private Binding<string> m_lupostalcode;
        private Binding<string> m_lucountry;
        private Binding<string> m_lulocationcode;
        private Binding<int> m_lugeocode;

        private Binding<string> m_shipfromaddress;
        private Binding<string> m_shipfromcity;
        private Binding<string> m_shipfromstateprovince;
        private Binding<string> m_shipfrompostalcode;
        private Binding<string> m_shipfromcountry;
        private Binding<string> m_shipfromlocationcode;
        private Binding<int> m_shipfromgeocode;

        private Binding<string> m_shiptoaddress;
        private Binding<string> m_shiptocity;
        private Binding<string> m_shiptostateprovince;
        private Binding<string> m_shiptopostalcode;
        private Binding<string> m_shiptocountry;
        private Binding<string> m_shiptolocationcode;
        private Binding<int> m_shiptogeocode;

        private Binding<string> m_goodorservicecode;
        private Binding<string> m_sku;
        private Binding<string> m_currency;
        private Binding<string> m_organizationcode;

        private Binding<decimal> m_federaltaxamount;
        private Binding<decimal> m_federaltaxamountrounded;
        private Binding<string> m_federaltaxname;
        private Binding<decimal> m_statetaxamount;
        private Binding<decimal> m_statetaxamountrounded;
        private Binding<string> m_statetaxname;
        private Binding<decimal> m_countytaxamount;
        private Binding<decimal> m_countytaxamountrounded;
        private Binding<string> m_countytaxname;
        private Binding<decimal> m_localtaxamount;
        private Binding<decimal> m_localtaxamountrounded;
        private Binding<string> m_localtaxname;
        private Binding<decimal> m_othertaxamount;
        private Binding<decimal> m_othertaxamountrounded;
        private Binding<string> m_othertaxname;
        private Binding<long> m_taxchargeid;
        //BINDING_ID_VAR
        #endregion

        #region Construction
        internal static PipelineProperties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
            return new PipelineProperties(log, systemContext, xmlConfig);
        }
        internal static PipelineProperties Create(PipelineProperties prototype, ISession session)
        {
            return new PipelineProperties(prototype, session);
        }
        
        private const string PipelineBinding = "PipelineBinding";
        private readonly string XPathToPipelineBinding = String.Format("{0}", PipelineBinding);
        private PipelineProperties(PlugInBase.LogDelegate log, IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
            Log = log;

            //Init the enum config
            m_enumConfig = systemContext.GetEnumConfig();

            //get the nameID
            IMTNameID nameID = systemContext.GetNameID();

            XmlNode pipelineProps = xmlConfig.DocumentElement.SelectSingleNode(XPathToPipelineBinding);

            if (pipelineProps == null)
            {
                throw new ConfigurationErrorsException(String.Format("The '{0}' was not found in t xpath = {1}. Can not configure Plug-in. Configuration content = '{2}'"
                    , PipelineBinding, XPathToPipelineBinding, xmlConfig.OuterXml));
            }
            
            m_accountid = new Binding<int>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "AccountID")));
            m_amount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "Amount")));
            m_invoicedate = new Binding<DateTime>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "InvoiceDate")));
            m_intervalid = new Binding<int>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "IntervalID")));

            // These values do not have to be set.
            m_productcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ProductCode"));
            m_isimpliedtax = CreateOptionalBindingBool(nameID, GetValueFromParameter(pipelineProps, "IsImpliedTax"));
            m_roundingalgorithm = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "RoundingAlgorithm"));
            m_roundingdigits = CreateOptionalBindingInt(nameID, GetValueFromParameter(pipelineProps, "RoundingDigits"));
            
	    // Taxware specific values that do not have to be set.
            m_customername = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "CustomerName"));
            m_customercode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "CustomerCode"));

            m_billtoaddress = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "BillToAddress"));
            m_billtocity = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "BillToCity"));
            m_billtostateprovince = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "BillToStateProvince"));
            m_billtopostalcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "BillToPostalCode"));
            m_billtocountry = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "BillToCountry"));
            m_billtolocationcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "BillToLocationCode"));
            m_billtogeocode = CreateOptionalBindingInt(nameID, GetValueFromParameter(pipelineProps, "BillToGeoCode"));

            m_loaaddress = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LoaAddress"));
            m_loacity = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LoaCity"));
            m_loastateprovince = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LoaStateProvince"));
            m_loapostalcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LoaPostalCode"));
            m_loacountry = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LoaCountry"));
            m_loalocationcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LoaLocationCode"));
            m_loageocode = CreateOptionalBindingInt(nameID, GetValueFromParameter(pipelineProps, "LoaGeoCode"));

            m_loraddress = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LorAddress"));
            m_lorcity = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LorCity"));
            m_lorstateprovince = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LorStateProvince"));
            m_lorpostalcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LorPostalCode"));
            m_lorcountry = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LorCountry"));
            m_lorlocationcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LorLocationCode"));
            m_lorgeocode = CreateOptionalBindingInt(nameID, GetValueFromParameter(pipelineProps, "LorGeoCode"));

            m_lspaddress = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LspAddress"));
            m_lspcity = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LspCity"));
            m_lspstateprovince = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LspStateProvince"));
            m_lsppostalcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LspPostalCode"));
            m_lspcountry = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LspCountry"));
            m_lsplocationcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LspLocationCode"));
            m_lspgeocode = CreateOptionalBindingInt(nameID, GetValueFromParameter(pipelineProps, "LspGeoCode"));

            m_luaddress = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LuAddress"));
            m_lucity = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LuCity"));
            m_lustateprovince = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LuStateProvince"));
            m_lupostalcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LuPostalCode"));
            m_lucountry = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LuCountry"));
            m_lulocationcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "LuLocationCode"));
            m_lugeocode = CreateOptionalBindingInt(nameID, GetValueFromParameter(pipelineProps, "LuGeoCode"));

            m_shipfromaddress = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipFromAddress"));
            m_shipfromcity = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipFromCity"));
            m_shipfromstateprovince = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipFromStateProvince"));
            m_shipfrompostalcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipFromPostalCode"));
            m_shipfromcountry = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipFromCountry"));
            m_shipfromlocationcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipFromLocationCode"));
            m_shipfromgeocode = CreateOptionalBindingInt(nameID, GetValueFromParameter(pipelineProps, "ShipFromGeoCode"));

            m_shiptoaddress = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipToAddress"));
            m_shiptocity = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipToCity"));
            m_shiptostateprovince = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipToStateProvince"));
            m_shiptopostalcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipToPostalCode"));
            m_shiptocountry = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipToCountry"));
            m_shiptolocationcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ShipToLocationCode"));
            m_shiptogeocode = CreateOptionalBindingInt(nameID, GetValueFromParameter(pipelineProps, "ShipToGeoCode"));

            m_goodorservicecode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "GoodOrServiceCode"));
            m_sku = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "Sku"));
            m_currency = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "Currency"));
            m_organizationcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "OrganizationCode"));

	    // output parameters
            m_federaltaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "FederalTaxAmount")));
            m_federaltaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "FederalTaxName")));
            m_statetaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "StateTaxAmount")));
            m_statetaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "StateTaxName")));
            m_countytaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "CountyTaxAmount")));
            m_countytaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "CountyTaxName")));
            m_localtaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "LocalTaxAmount")));
            m_localtaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "LocalTaxName")));
            m_othertaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "OtherTaxAmount")));
            m_othertaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "OtherTaxName")));
            m_taxchargeid = new Binding<long>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "TaxChargeID")));

            m_federaltaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "FederalTaxAmountRounded")));
            m_statetaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "StateTaxAmountRounded")));
            m_countytaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "CountyTaxAmountRounded")));
            m_localtaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "LocalTaxAmountRounded")));
            m_othertaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "OtherTaxAmountRounded")));

            //BINDING_ID_ASSIGN            
        }
        

        Binding<string> CreateOptionalBindingString(IMTNameID nameID, String configuredParameter)
        {
            if (configuredParameter.Length <= 0)
            {
                Binding<string> result = new Binding<string>(-1);
                result.HasID = false;
                return result;
            }

            return new Binding<string>(nameID.GetNameID(configuredParameter));
        }


        Binding<bool> CreateOptionalBindingBool(IMTNameID nameID, String configuredParameter)
        {
            if (configuredParameter.Length <= 0)
            {
                Binding<bool> result = new Binding<bool>(-1);
                result.HasID = false;
                return result;
            }

            return new Binding<bool>(nameID.GetNameID(configuredParameter));
        }


        Binding<int> CreateOptionalBindingInt(IMTNameID nameID, String configuredParameter)
        {
            if (configuredParameter.Length <= 0)
            {
                Binding<int> result = new Binding<int>(-1);
                result.HasID = false;
                return result;
            }

            return new Binding<int>(nameID.GetNameID(configuredParameter));
        }

         private static string GetValueFromParameter(XmlNode node, string paramName)
        {
            XmlNode childNode = node.SelectSingleNode(paramName);
            if (childNode == null)
            {
                throw new ConfigurationErrorsException(String.Format("The '{0}' parametr name does not set into '{1}'. Section content = '{2}'"
                   , paramName, PipelineBinding, node.OuterXml));
            }
            return childNode.InnerText;
        }
        
        private PipelineProperties(PipelineProperties prototype, ISession session)
        {
            m_session = session;
            m_enumConfig = prototype.m_enumConfig;
            Log = prototype.Log;

            m_accountid = new Binding<int>(prototype.m_accountid.ID);
            m_amount = new Binding<decimal>(prototype.m_amount.ID);
            m_invoicedate = new Binding<DateTime>(prototype.m_invoicedate.ID);
            m_intervalid = new Binding<int>(prototype.m_intervalid.ID);
            m_productcode = new Binding<string>(prototype.m_productcode.ID);
            m_isimpliedtax = new Binding<bool>(prototype.m_isimpliedtax.ID);
            m_roundingalgorithm = new Binding<string>(prototype.m_roundingalgorithm.ID);
            m_roundingdigits = new Binding<int>(prototype.m_roundingdigits.ID);

	    // Taxware specific input params
            m_customername = new Binding<string>(prototype.m_customername.ID);
            m_customercode = new Binding<string>(prototype.m_customercode.ID);

            m_billtoaddress = new Binding<string>(prototype.m_billtoaddress.ID);
            m_billtocity = new Binding<string>(prototype.m_billtocity.ID);
            m_billtostateprovince = new Binding<string>(prototype.m_billtostateprovince.ID);
            m_billtopostalcode = new Binding<string>(prototype.m_billtopostalcode.ID);
            m_billtocountry = new Binding<string>(prototype.m_billtocountry.ID);
            m_billtolocationcode = new Binding<string>(prototype.m_billtolocationcode.ID);
            m_billtogeocode = new Binding<int>(prototype.m_billtogeocode.ID);

            m_loaaddress = new Binding<string>(prototype.m_loaaddress.ID);
            m_loacity = new Binding<string>(prototype.m_loacity.ID);
            m_loastateprovince = new Binding<string>(prototype.m_loastateprovince.ID);
            m_loapostalcode = new Binding<string>(prototype.m_loapostalcode.ID);
            m_loacountry = new Binding<string>(prototype.m_loacountry.ID);
            m_loalocationcode = new Binding<string>(prototype.m_loalocationcode.ID);
            m_loageocode = new Binding<int>(prototype.m_loageocode.ID);

            m_loraddress = new Binding<string>(prototype.m_loraddress.ID);
            m_lorcity = new Binding<string>(prototype.m_lorcity.ID);
            m_lorstateprovince = new Binding<string>(prototype.m_lorstateprovince.ID);
            m_lorpostalcode = new Binding<string>(prototype.m_lorpostalcode.ID);
            m_lorcountry = new Binding<string>(prototype.m_lorcountry.ID);
            m_lorlocationcode = new Binding<string>(prototype.m_lorlocationcode.ID);
            m_lorgeocode = new Binding<int>(prototype.m_lorgeocode.ID);

            m_lspaddress = new Binding<string>(prototype.m_lspaddress.ID);
            m_lspcity = new Binding<string>(prototype.m_lspcity.ID);
            m_lspstateprovince = new Binding<string>(prototype.m_lspstateprovince.ID);
            m_lsppostalcode = new Binding<string>(prototype.m_lsppostalcode.ID);
            m_lspcountry = new Binding<string>(prototype.m_lspcountry.ID);
            m_lsplocationcode = new Binding<string>(prototype.m_lsplocationcode.ID);
            m_lspgeocode = new Binding<int>(prototype.m_lspgeocode.ID);

            m_luaddress = new Binding<string>(prototype.m_luaddress.ID);
            m_lucity = new Binding<string>(prototype.m_lucity.ID);
            m_lustateprovince = new Binding<string>(prototype.m_lustateprovince.ID);
            m_lupostalcode = new Binding<string>(prototype.m_lupostalcode.ID);
            m_lucountry = new Binding<string>(prototype.m_lucountry.ID);
            m_lulocationcode = new Binding<string>(prototype.m_lulocationcode.ID);
            m_lugeocode = new Binding<int>(prototype.m_lugeocode.ID);

            m_shipfromaddress = new Binding<string>(prototype.m_shipfromaddress.ID);
            m_shipfromcity = new Binding<string>(prototype.m_shipfromcity.ID);
            m_shipfromstateprovince = new Binding<string>(prototype.m_shipfromstateprovince.ID);
            m_shipfrompostalcode = new Binding<string>(prototype.m_shipfrompostalcode.ID);
            m_shipfromcountry = new Binding<string>(prototype.m_shipfromcountry.ID);
            m_shipfromlocationcode = new Binding<string>(prototype.m_shipfromlocationcode.ID);
            m_shipfromgeocode = new Binding<int>(prototype.m_shipfromgeocode.ID);

            m_shiptoaddress = new Binding<string>(prototype.m_shiptoaddress.ID);
            m_shiptocity = new Binding<string>(prototype.m_shiptocity.ID);
            m_shiptostateprovince = new Binding<string>(prototype.m_shiptostateprovince.ID);
            m_shiptopostalcode = new Binding<string>(prototype.m_shiptopostalcode.ID);
            m_shiptocountry = new Binding<string>(prototype.m_shiptocountry.ID);
            m_shiptolocationcode = new Binding<string>(prototype.m_shiptolocationcode.ID);
            m_shiptogeocode = new Binding<int>(prototype.m_shiptogeocode.ID);

            m_goodorservicecode = new Binding<string>(prototype.m_goodorservicecode.ID);
            m_sku = new Binding<string>(prototype.m_sku.ID);
            m_currency = new Binding<string>(prototype.m_currency.ID);
            m_organizationcode = new Binding<string>(prototype.m_organizationcode.ID);
	    
            m_federaltaxamount = new Binding<decimal>(prototype.m_federaltaxamount.ID);
            m_federaltaxname = new Binding<string>(prototype.m_federaltaxname.ID);
            m_statetaxamount = new Binding<decimal>(prototype.m_statetaxamount.ID);
            m_statetaxname = new Binding<string>(prototype.m_statetaxname.ID);
            m_countytaxamount = new Binding<decimal>(prototype.m_countytaxamount.ID);
            m_countytaxname = new Binding<string>(prototype.m_countytaxname.ID);
            m_localtaxamount = new Binding<decimal>(prototype.m_localtaxamount.ID);
            m_localtaxname = new Binding<string>(prototype.m_localtaxname.ID);
            m_othertaxamount = new Binding<decimal>(prototype.m_othertaxamount.ID);
            m_othertaxname = new Binding<string>(prototype.m_othertaxname.ID);

            m_federaltaxamountrounded = new Binding<decimal>(prototype.m_federaltaxamountrounded.ID);
            m_statetaxamountrounded = new Binding<decimal>(prototype.m_statetaxamountrounded.ID);
            m_countytaxamountrounded = new Binding<decimal>(prototype.m_countytaxamountrounded.ID);
            m_localtaxamountrounded = new Binding<decimal>(prototype.m_localtaxamountrounded.ID);
            m_othertaxamountrounded = new Binding<decimal>(prototype.m_othertaxamountrounded.ID);

            m_taxchargeid = new Binding<long>(prototype.m_taxchargeid.ID);
            //BINDING_ID_CLONE
        }
        #endregion
    

        #region Pipeline Properties
        /// <summary>
        /// (In) This account will be examined to determine country and country zone.  This will then be used with parameter tables containing MetraTax rates and other information to determine the tax rate.
        /// </summary>
        internal int? AccountID
        {
            get
            {
                try
                {
                    if (!m_accountid.HasValue)
                    {
                        m_accountid.HasValue = true;
                        m_accountid.Value = m_session.GetIntegerProperty(m_accountid.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_accountid.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_accountid.IsNull)
                    return null;
                else
                    return m_accountid.Value;
            }
            
        }
        /// <summary>
        /// (In) The amount that should be taxed.
        /// </summary>
        internal decimal? Amount
        {
            get
            {
                try
                {
                    if (!m_amount.HasValue)
                    {
                        m_amount.HasValue = true;
                        m_amount.Value = m_session.GetDecimalProperty(m_amount.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_amount.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_amount.IsNull)
                    return null;
                else
                    return m_amount.Value;
            }
            
        }
        /// <summary>
        /// (In) This is the date of the transaction.  The date is used to select the best fitting rate from the MetraTax parameter tables.
        /// </summary>
        internal DateTime? InvoiceDate
        {
            get
            {
                try
                {
                    if (!m_invoicedate.HasValue)
                    {
                        m_invoicedate.HasValue = true;
                        m_invoicedate.Value = m_session.GetDateTimeProperty(m_invoicedate.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_invoicedate.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_invoicedate.IsNull)
                    return null;
                else
                    return m_invoicedate.Value;
            }
            
        }
        /// <summary>
        /// (In) The interval ID associated with the transaction.
        /// </summary>
        internal int? IntervalID
        {
            get
            {
                try
                {
                    if (!m_intervalid.HasValue)
                    {
                        m_intervalid.HasValue = true;
                        m_intervalid.Value = m_session.GetIntegerProperty(m_intervalid.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_intervalid.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_intervalid.IsNull)
                    return null;
                else
                    return m_intervalid.Value;
            }
            
        }
        /// <summary>
        /// (In) A code identifying the product.  This same code should be used in the MetraTax parameter table define the tax rate for the product.
        /// </summary>
        internal string ProductCode
        {        
            get
            {
                try
                {
                    if (!m_productcode.HasValue)
                    {
                        m_productcode.HasValue = true;
                        m_productcode.Value = m_session.GetStringProperty(m_productcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_productcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_productcode.IsNull)
                    return null;
                else
                    return m_productcode.Value;
            }
            
        }
        /// <summary>
        /// (In) If true, the amount already includes the tax.
        /// </summary>
        internal bool? IsImpliedTax
        {
            get
            {
                try
                {
                    if (!m_isimpliedtax.HasValue)
                    {
                        m_isimpliedtax.HasValue = true;
                        m_isimpliedtax.Value = m_session.GetBooleanProperty(m_isimpliedtax.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_isimpliedtax.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_isimpliedtax.IsNull)
                    return null;
                else
                    return m_isimpliedtax.Value;
            }
            
        }
        /// <summary>
        /// (In) The rounding algorithm to use.  Acceptable values are: NONE or BANK.  NONE means no rounding will be performed. BANK means banker's rounding will be performed.
        /// </summary>
        internal string RoundingAlgorithm
        {        
            get
            {
                try
                {
                    if (!m_roundingalgorithm.HasValue)
                    {
                        m_roundingalgorithm.HasValue = true;
                        m_roundingalgorithm.Value = m_session.GetStringProperty(m_roundingalgorithm.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_roundingalgorithm.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_roundingalgorithm.IsNull)
                    return null;
                else
                    return m_roundingalgorithm.Value;
            }
            
        }
        /// <summary>
        /// (In) The number of rounding digits. 0 - no rounding, 1 round to 1 digit after decimal point, 2 for 2 digits, etc.
        /// </summary>
        internal int? RoundingDigits
        {
            get
            {
                try
                {
                    if (!m_roundingdigits.HasValue)
                    {
                        m_roundingdigits.HasValue = true;
                        m_roundingdigits.Value = m_session.GetIntegerProperty(m_roundingdigits.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_roundingdigits.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_roundingdigits.IsNull)
                    return null;
                else
                    return m_roundingdigits.Value;
            }
            
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string CustomerName
        {        
            get
            {
                try
                {
                    if (!m_customername.HasValue)
                    {
                        m_customername.HasValue = true;
                        m_customername.Value = m_session.GetStringProperty(m_customername.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_customername.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_customername.IsNull)
                    return null;
                else
                    return m_customername.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string CustomerCode
        {        
            get
            {
                try
                {
                    if (!m_customercode.HasValue)
                    {
                        m_customercode.HasValue = true;
                        m_customercode.Value = m_session.GetStringProperty(m_customercode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_customercode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_customercode.IsNull)
                    return null;
                else
                    return m_customercode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string BillToAddress
        {        
            get
            {
                try
                {
                    if (!m_billtoaddress.HasValue)
                    {
                        m_billtoaddress.HasValue = true;
                        m_billtoaddress.Value = m_session.GetStringProperty(m_billtoaddress.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_billtoaddress.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_billtoaddress.IsNull)
                    return null;
                else
                    return m_billtoaddress.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string BillToCity
        {        
            get
            {
                try
                {
                    if (!m_billtocity.HasValue)
                    {
                        m_billtocity.HasValue = true;
                        m_billtocity.Value = m_session.GetStringProperty(m_billtocity.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_billtocity.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_billtocity.IsNull)
                    return null;
                else
                    return m_billtocity.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string BillToStateProvince
        {        
            get
            {
                try
                {
                    if (!m_billtostateprovince.HasValue)
                    {
                        m_billtostateprovince.HasValue = true;
                        m_billtostateprovince.Value = m_session.GetStringProperty(m_billtostateprovince.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_billtostateprovince.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_billtostateprovince.IsNull)
                    return null;
                else
                    return m_billtostateprovince.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string BillToPostalCode
        {        
            get
            {
                try
                {
                    if (!m_billtopostalcode.HasValue)
                    {
                        m_billtopostalcode.HasValue = true;
                        m_billtopostalcode.Value = m_session.GetStringProperty(m_billtopostalcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_billtopostalcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_billtopostalcode.IsNull)
                    return null;
                else
                    return m_billtopostalcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string BillToCountry
        {        
            get
            {
                try
                {
                    if (!m_billtocountry.HasValue)
                    {
                        m_billtocountry.HasValue = true;
                        m_billtocountry.Value = m_session.GetStringProperty(m_billtocountry.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_billtocountry.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_billtocountry.IsNull)
                    return null;
                else
                    return m_billtocountry.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string BillToLocationCode
        {        
            get
            {
                try
                {
                    if (!m_billtolocationcode.HasValue)
                    {
                        m_billtolocationcode.HasValue = true;
                        m_billtolocationcode.Value = m_session.GetStringProperty(m_billtolocationcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_billtolocationcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_billtolocationcode.IsNull)
                    return null;
                else
                    return m_billtolocationcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal int? BillToGeoCode
        {
            get
            {
                try
                {
                    if (!m_billtogeocode.HasValue)
                    {
                        m_billtogeocode.HasValue = true;
                        m_billtogeocode.Value = m_session.GetIntegerProperty(m_billtogeocode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_billtogeocode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_billtogeocode.IsNull)
                    return null;
                else
                    return m_billtogeocode.Value;
            }
            
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LoaAddress
        {        
            get
            {
                try
                {
                    if (!m_loaaddress.HasValue)
                    {
                        m_loaaddress.HasValue = true;
                        m_loaaddress.Value = m_session.GetStringProperty(m_loaaddress.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_loaaddress.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_loaaddress.IsNull)
                    return null;
                else
                    return m_loaaddress.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LoaCity
        {        
            get
            {
                try
                {
                    if (!m_loacity.HasValue)
                    {
                        m_loacity.HasValue = true;
                        m_loacity.Value = m_session.GetStringProperty(m_loacity.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_loacity.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_loacity.IsNull)
                    return null;
                else
                    return m_loacity.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LoaStateProvince
        {        
            get
            {
                try
                {
                    if (!m_loastateprovince.HasValue)
                    {
                        m_loastateprovince.HasValue = true;
                        m_loastateprovince.Value = m_session.GetStringProperty(m_loastateprovince.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_loastateprovince.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_loastateprovince.IsNull)
                    return null;
                else
                    return m_loastateprovince.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LoaPostalCode
        {        
            get
            {
                try
                {
                    if (!m_loapostalcode.HasValue)
                    {
                        m_loapostalcode.HasValue = true;
                        m_loapostalcode.Value = m_session.GetStringProperty(m_loapostalcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_loapostalcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_loapostalcode.IsNull)
                    return null;
                else
                    return m_loapostalcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LoaCountry
        {        
            get
            {
                try
                {
                    if (!m_loacountry.HasValue)
                    {
                        m_loacountry.HasValue = true;
                        m_loacountry.Value = m_session.GetStringProperty(m_loacountry.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_loacountry.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_loacountry.IsNull)
                    return null;
                else
                    return m_loacountry.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LoaLocationCode
        {        
            get
            {
                try
                {
                    if (!m_loalocationcode.HasValue)
                    {
                        m_loalocationcode.HasValue = true;
                        m_loalocationcode.Value = m_session.GetStringProperty(m_loalocationcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_loalocationcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_loalocationcode.IsNull)
                    return null;
                else
                    return m_loalocationcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal int? LoaGeoCode
        {
            get
            {
                try
                {
                    if (!m_loageocode.HasValue)
                    {
                        m_loageocode.HasValue = true;
                        m_loageocode.Value = m_session.GetIntegerProperty(m_loageocode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_loageocode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_loageocode.IsNull)
                    return null;
                else
                    return m_loageocode.Value;
            }
            
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LorAddress
        {        
            get
            {
                try
                {
                    if (!m_loraddress.HasValue)
                    {
                        m_loraddress.HasValue = true;
                        m_loraddress.Value = m_session.GetStringProperty(m_loraddress.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_loraddress.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_loraddress.IsNull)
                    return null;
                else
                    return m_loraddress.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LorCity
        {        
            get
            {
                try
                {
                    if (!m_lorcity.HasValue)
                    {
                        m_lorcity.HasValue = true;
                        m_lorcity.Value = m_session.GetStringProperty(m_lorcity.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lorcity.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lorcity.IsNull)
                    return null;
                else
                    return m_lorcity.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LorStateProvince
        {        
            get
            {
                try
                {
                    if (!m_lorstateprovince.HasValue)
                    {
                        m_lorstateprovince.HasValue = true;
                        m_lorstateprovince.Value = m_session.GetStringProperty(m_lorstateprovince.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lorstateprovince.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lorstateprovince.IsNull)
                    return null;
                else
                    return m_lorstateprovince.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LorPostalCode
        {        
            get
            {
                try
                {
                    if (!m_lorpostalcode.HasValue)
                    {
                        m_lorpostalcode.HasValue = true;
                        m_lorpostalcode.Value = m_session.GetStringProperty(m_lorpostalcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lorpostalcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lorpostalcode.IsNull)
                    return null;
                else
                    return m_lorpostalcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LorCountry
        {        
            get
            {
                try
                {
                    if (!m_lorcountry.HasValue)
                    {
                        m_lorcountry.HasValue = true;
                        m_lorcountry.Value = m_session.GetStringProperty(m_lorcountry.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lorcountry.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lorcountry.IsNull)
                    return null;
                else
                    return m_lorcountry.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LorLocationCode
        {        
            get
            {
                try
                {
                    if (!m_lorlocationcode.HasValue)
                    {
                        m_lorlocationcode.HasValue = true;
                        m_lorlocationcode.Value = m_session.GetStringProperty(m_lorlocationcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lorlocationcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lorlocationcode.IsNull)
                    return null;
                else
                    return m_lorlocationcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal int? LorGeoCode
        {
            get
            {
                try
                {
                    if (!m_lorgeocode.HasValue)
                    {
                        m_lorgeocode.HasValue = true;
                        m_lorgeocode.Value = m_session.GetIntegerProperty(m_lorgeocode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lorgeocode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lorgeocode.IsNull)
                    return null;
                else
                    return m_lorgeocode.Value;
            }
            
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LspAddress
        {        
            get
            {
                try
                {
                    if (!m_lspaddress.HasValue)
                    {
                        m_lspaddress.HasValue = true;
                        m_lspaddress.Value = m_session.GetStringProperty(m_lspaddress.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lspaddress.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lspaddress.IsNull)
                    return null;
                else
                    return m_lspaddress.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LspCity
        {        
            get
            {
                try
                {
                    if (!m_lspcity.HasValue)
                    {
                        m_lspcity.HasValue = true;
                        m_lspcity.Value = m_session.GetStringProperty(m_lspcity.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lspcity.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lspcity.IsNull)
                    return null;
                else
                    return m_lspcity.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LspStateProvince
        {        
            get
            {
                try
                {
                    if (!m_lspstateprovince.HasValue)
                    {
                        m_lspstateprovince.HasValue = true;
                        m_lspstateprovince.Value = m_session.GetStringProperty(m_lspstateprovince.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lspstateprovince.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lspstateprovince.IsNull)
                    return null;
                else
                    return m_lspstateprovince.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LspPostalCode
        {        
            get
            {
                try
                {
                    if (!m_lsppostalcode.HasValue)
                    {
                        m_lsppostalcode.HasValue = true;
                        m_lsppostalcode.Value = m_session.GetStringProperty(m_lsppostalcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lsppostalcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lsppostalcode.IsNull)
                    return null;
                else
                    return m_lsppostalcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LspCountry
        {        
            get
            {
                try
                {
                    if (!m_lspcountry.HasValue)
                    {
                        m_lspcountry.HasValue = true;
                        m_lspcountry.Value = m_session.GetStringProperty(m_lspcountry.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lspcountry.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lspcountry.IsNull)
                    return null;
                else
                    return m_lspcountry.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LspLocationCode
        {        
            get
            {
                try
                {
                    if (!m_lsplocationcode.HasValue)
                    {
                        m_lsplocationcode.HasValue = true;
                        m_lsplocationcode.Value = m_session.GetStringProperty(m_lsplocationcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lsplocationcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lsplocationcode.IsNull)
                    return null;
                else
                    return m_lsplocationcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal int? LspGeoCode
        {
            get
            {
                try
                {
                    if (!m_lspgeocode.HasValue)
                    {
                        m_lspgeocode.HasValue = true;
                        m_lspgeocode.Value = m_session.GetIntegerProperty(m_lspgeocode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lspgeocode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lspgeocode.IsNull)
                    return null;
                else
                    return m_lspgeocode.Value;
            }
            
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LuAddress
        {        
            get
            {
                try
                {
                    if (!m_luaddress.HasValue)
                    {
                        m_luaddress.HasValue = true;
                        m_luaddress.Value = m_session.GetStringProperty(m_luaddress.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_luaddress.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_luaddress.IsNull)
                    return null;
                else
                    return m_luaddress.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LuCity
        {        
            get
            {
                try
                {
                    if (!m_lucity.HasValue)
                    {
                        m_lucity.HasValue = true;
                        m_lucity.Value = m_session.GetStringProperty(m_lucity.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lucity.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lucity.IsNull)
                    return null;
                else
                    return m_lucity.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LuStateProvince
        {        
            get
            {
                try
                {
                    if (!m_lustateprovince.HasValue)
                    {
                        m_lustateprovince.HasValue = true;
                        m_lustateprovince.Value = m_session.GetStringProperty(m_lustateprovince.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lustateprovince.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lustateprovince.IsNull)
                    return null;
                else
                    return m_lustateprovince.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LuPostalCode
        {        
            get
            {
                try
                {
                    if (!m_lupostalcode.HasValue)
                    {
                        m_lupostalcode.HasValue = true;
                        m_lupostalcode.Value = m_session.GetStringProperty(m_lupostalcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lupostalcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lupostalcode.IsNull)
                    return null;
                else
                    return m_lupostalcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LuCountry
        {        
            get
            {
                try
                {
                    if (!m_lucountry.HasValue)
                    {
                        m_lucountry.HasValue = true;
                        m_lucountry.Value = m_session.GetStringProperty(m_lucountry.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lucountry.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lucountry.IsNull)
                    return null;
                else
                    return m_lucountry.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string LuLocationCode
        {        
            get
            {
                try
                {
                    if (!m_lulocationcode.HasValue)
                    {
                        m_lulocationcode.HasValue = true;
                        m_lulocationcode.Value = m_session.GetStringProperty(m_lulocationcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lulocationcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lulocationcode.IsNull)
                    return null;
                else
                    return m_lulocationcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal int? LuGeoCode
        {
            get
            {
                try
                {
                    if (!m_lugeocode.HasValue)
                    {
                        m_lugeocode.HasValue = true;
                        m_lugeocode.Value = m_session.GetIntegerProperty(m_lugeocode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_lugeocode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_lugeocode.IsNull)
                    return null;
                else
                    return m_lugeocode.Value;
            }
            
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipFromAddress
        {        
            get
            {
                try
                {
                    if (!m_shipfromaddress.HasValue)
                    {
                        m_shipfromaddress.HasValue = true;
                        m_shipfromaddress.Value = m_session.GetStringProperty(m_shipfromaddress.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shipfromaddress.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shipfromaddress.IsNull)
                    return null;
                else
                    return m_shipfromaddress.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipFromCity
        {        
            get
            {
                try
                {
                    if (!m_shipfromcity.HasValue)
                    {
                        m_shipfromcity.HasValue = true;
                        m_shipfromcity.Value = m_session.GetStringProperty(m_shipfromcity.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shipfromcity.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shipfromcity.IsNull)
                    return null;
                else
                    return m_shipfromcity.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipFromStateProvince
        {        
            get
            {
                try
                {
                    if (!m_shipfromstateprovince.HasValue)
                    {
                        m_shipfromstateprovince.HasValue = true;
                        m_shipfromstateprovince.Value = m_session.GetStringProperty(m_shipfromstateprovince.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shipfromstateprovince.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shipfromstateprovince.IsNull)
                    return null;
                else
                    return m_shipfromstateprovince.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipFromPostalCode
        {        
            get
            {
                try
                {
                    if (!m_shipfrompostalcode.HasValue)
                    {
                        m_shipfrompostalcode.HasValue = true;
                        m_shipfrompostalcode.Value = m_session.GetStringProperty(m_shipfrompostalcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shipfrompostalcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shipfrompostalcode.IsNull)
                    return null;
                else
                    return m_shipfrompostalcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipFromCountry
        {        
            get
            {
                try
                {
                    if (!m_shipfromcountry.HasValue)
                    {
                        m_shipfromcountry.HasValue = true;
                        m_shipfromcountry.Value = m_session.GetStringProperty(m_shipfromcountry.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shipfromcountry.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shipfromcountry.IsNull)
                    return null;
                else
                    return m_shipfromcountry.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipFromLocationCode
        {        
            get
            {
                try
                {
                    if (!m_shipfromlocationcode.HasValue)
                    {
                        m_shipfromlocationcode.HasValue = true;
                        m_shipfromlocationcode.Value = m_session.GetStringProperty(m_shipfromlocationcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shipfromlocationcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shipfromlocationcode.IsNull)
                    return null;
                else
                    return m_shipfromlocationcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal int? ShipFromGeoCode
        {
            get
            {
                try
                {
                    if (!m_shipfromgeocode.HasValue)
                    {
                        m_shipfromgeocode.HasValue = true;
                        m_shipfromgeocode.Value = m_session.GetIntegerProperty(m_shipfromgeocode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shipfromgeocode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shipfromgeocode.IsNull)
                    return null;
                else
                    return m_shipfromgeocode.Value;
            }
            
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipToAddress
        {        
            get
            {
                try
                {
                    if (!m_shiptoaddress.HasValue)
                    {
                        m_shiptoaddress.HasValue = true;
                        m_shiptoaddress.Value = m_session.GetStringProperty(m_shiptoaddress.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shiptoaddress.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shiptoaddress.IsNull)
                    return null;
                else
                    return m_shiptoaddress.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipToCity
        {        
            get
            {
                try
                {
                    if (!m_shiptocity.HasValue)
                    {
                        m_shiptocity.HasValue = true;
                        m_shiptocity.Value = m_session.GetStringProperty(m_shiptocity.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shiptocity.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shiptocity.IsNull)
                    return null;
                else
                    return m_shiptocity.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipToStateProvince
        {        
            get
            {
                try
                {
                    if (!m_shiptostateprovince.HasValue)
                    {
                        m_shiptostateprovince.HasValue = true;
                        m_shiptostateprovince.Value = m_session.GetStringProperty(m_shiptostateprovince.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shiptostateprovince.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shiptostateprovince.IsNull)
                    return null;
                else
                    return m_shiptostateprovince.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipToPostalCode
        {        
            get
            {
                try
                {
                    if (!m_shiptopostalcode.HasValue)
                    {
                        m_shiptopostalcode.HasValue = true;
                        m_shiptopostalcode.Value = m_session.GetStringProperty(m_shiptopostalcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shiptopostalcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shiptopostalcode.IsNull)
                    return null;
                else
                    return m_shiptopostalcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipToCountry
        {        
            get
            {
                try
                {
                    if (!m_shiptocountry.HasValue)
                    {
                        m_shiptocountry.HasValue = true;
                        m_shiptocountry.Value = m_session.GetStringProperty(m_shiptocountry.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shiptocountry.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shiptocountry.IsNull)
                    return null;
                else
                    return m_shiptocountry.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string ShipToLocationCode
        {        
            get
            {
                try
                {
                    if (!m_shiptolocationcode.HasValue)
                    {
                        m_shiptolocationcode.HasValue = true;
                        m_shiptolocationcode.Value = m_session.GetStringProperty(m_shiptolocationcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shiptolocationcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shiptolocationcode.IsNull)
                    return null;
                else
                    return m_shiptolocationcode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal int? ShipToGeoCode
        {
            get
            {
                try
                {
                    if (!m_shiptogeocode.HasValue)
                    {
                        m_shiptogeocode.HasValue = true;
                        m_shiptogeocode.Value = m_session.GetIntegerProperty(m_shiptogeocode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_shiptogeocode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_shiptogeocode.IsNull)
                    return null;
                else
                    return m_shiptogeocode.Value;
            }
            
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string GoodOrServiceCode
        {        
            get
            {
                try
                {
                    if (!m_goodorservicecode.HasValue)
                    {
                        m_goodorservicecode.HasValue = true;
                        m_goodorservicecode.Value = m_session.GetStringProperty(m_goodorservicecode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_goodorservicecode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_goodorservicecode.IsNull)
                    return null;
                else
                    return m_goodorservicecode.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string Sku
        {        
            get
            {
                try
                {
                    if (!m_sku.HasValue)
                    {
                        m_sku.HasValue = true;
                        m_sku.Value = m_session.GetStringProperty(m_sku.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_sku.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_sku.IsNull)
                    return null;
                else
                    return m_sku.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string Currency
        {        
            get
            {
                try
                {
                    if (!m_currency.HasValue)
                    {
                        m_currency.HasValue = true;
                        m_currency.Value = m_session.GetStringProperty(m_currency.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_currency.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_currency.IsNull)
                    return null;
                else
                    return m_currency.Value;
            }
        }
        /// <summary>
        /// (In) YYYYY
        /// </summary>
        internal string OrganizationCode
        {        
            get
            {
                try
                {
                    if (!m_organizationcode.HasValue)
                    {
                        m_organizationcode.HasValue = true;
                        m_organizationcode.Value = m_session.GetStringProperty(m_organizationcode.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
                #pragma warning restore 0168
                {
                    m_organizationcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_organizationcode.IsNull)
                    return null;
                else
                    return m_organizationcode.Value;
            }
        }
        /// <summary>
        /// (Out) The federal tax amount.
        /// </summary>
        internal decimal? FederalTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_federaltaxamount.ID, value.Value);
                m_federaltaxamount.Value = value.Value;
            }
        }
        /// <summary>
        /// (Out) The federal tax name. This comes from the configured MetraTax parameter table defining the rate.
        /// </summary>
        internal string FederalTaxName
        {        
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_federaltaxname.ID, value);
                m_federaltaxname.Value = value;
            }
        }
        /// <summary>
        /// (Out) The state tax amount.
        /// </summary>
        internal decimal? StateTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_statetaxamount.ID, value.Value);
                m_statetaxamount.Value = value.Value;
            }
        }
        /// <summary>
        /// (Out) The state tax name.
        /// </summary>
        internal string StateTaxName
        {        
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_statetaxname.ID, value);
                m_statetaxname.Value = value;
            }
        }
        /// <summary>
        /// (Out) The county tax amount.
        /// </summary>
        internal decimal? CountyTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_countytaxamount.ID, value.Value);
                m_countytaxamount.Value = value.Value;
            }
        }
        /// <summary>
        /// (Out) The county tax name.
        /// </summary>
        internal string CountyTaxName
        {        
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_countytaxname.ID, value);
                m_countytaxname.Value = value;
            }
        }
        /// <summary>
        /// (Out) The local tax amount.
        /// </summary>
        internal decimal? LocalTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_localtaxamount.ID, value.Value);
                m_localtaxamount.Value = value.Value;
            }
        }
        /// <summary>
        /// (Out) The local tax name.
        /// </summary>
        internal string LocalTaxName
        {        
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_localtaxname.ID, value);
                m_localtaxname.Value = value;
            }
        }
        /// <summary>
        /// (Out) Other tax amount.
        /// </summary>
        internal decimal? OtherTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_othertaxamount.ID, value.Value);
                m_othertaxamount.Value = value.Value;
            }
        }
        /// <summary>
        /// (Out) Other tax name.
        /// </summary>
        internal string OtherTaxName
        {        
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_othertaxname.ID, value);
                m_othertaxname.Value = value;
            }
        }

        internal decimal? FederalTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_federaltaxamountrounded.ID, value.Value);
                m_federaltaxamountrounded.Value = value.Value;
            }
        }

        internal decimal? StateTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_statetaxamountrounded.ID, value.Value);
                m_statetaxamountrounded.Value = value.Value;
            }
        }

        internal decimal? CountyTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_countytaxamountrounded.ID, value.Value);
                m_countytaxamountrounded.Value = value.Value;
            }
        }

        internal decimal? LocalTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_localtaxamountrounded.ID, value.Value);
                m_localtaxamountrounded.Value = value.Value;
            }
        }

        internal decimal? OtherTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_othertaxamountrounded.ID, value.Value);
                m_othertaxamountrounded.Value = value.Value;
            }
        }


        /// <summary>
        /// (Out) An index that can be used to get detailed information about the tax if tax details were stored (based on configuration).  This value is used for the column id_tax_charge in t_tax_details.
        /// </summary>
        internal long? TaxChargeID
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetLongProperty(m_taxchargeid.ID, value.Value);
                m_taxchargeid.Value = value.Value;
            }
        }
        //BINDING_ID_PROP
        #endregion
    }
    #endregion

    #region Binding Class
    [DebuggerStepThrough]
    internal class Binding<T>
    {
        #region Protected Variables
        protected readonly int m_id;
        protected T m_value;
        protected bool m_isNull;
        protected bool m_hasValue;
        protected bool m_hasID;
        #endregion

        internal Binding(int id)
        {
            m_id = id;
            m_value = default(T);
            m_isNull = false;
            m_hasValue = false;
            m_hasID = true;
        }

        internal bool HasValue
        {
            get { return m_hasValue; }
            set { m_hasValue = value; }
        }


        internal bool HasID
        {
            get { return m_hasID; }
            set { m_hasID = value; }
        }

        internal bool IsNull
        {
            get { return m_isNull; }
            set { m_isNull = value; }
        }
        internal T Value
        {
            get { return m_value; }
            set { m_value = value; }
        }
        internal int ID
        {
            get { return m_id; }
        }

        internal virtual void Reset()
        {
            m_hasValue = false;
            m_isNull = false;
            m_value = default(T);
        }
    }
    #endregion

#if CONTAINS_ENUMS
    #region EnumBinding Class
    internal sealed class EnumBinding<T> : Binding<T>
        where T : struct
    {
    #region Private Variables
        private readonly Dictionary<int, int> m_csToDb;
        private readonly Dictionary<int, int> m_dbToCs;
        private readonly string m_enumSpace;
        private readonly string m_enumName;
        #endregion

    #region Construction
        internal EnumBinding(int id, IEnumConfig enumConfig)
            : base(id)
        {
            m_csToDb = new Dictionary<int, int>();
            m_dbToCs = new Dictionary<int, int>();

            //build the enum id mapping
            object[] attrs = typeof(T).GetCustomAttributes(typeof(MTEnumAttribute), false);

            MTEnumAttribute info = attrs[0] as MTEnumAttribute;

            m_enumSpace = info.EnumSpace;
            m_enumName = info.EnumName;

            //get the ordinal of the value in the C# enum and save it along with the db id for the enum value
            foreach (string oldEnumStr in info.OldEnumValues)
            {
                if (!oldEnumStr.Contains(":"))
                    throw new InvalidEnumAttributeException(m_enumSpace + " " + m_enumName + " has an invalid OldEnumValues value on it's MTEnumAttribute");

                string[] set = oldEnumStr.Split(':');
                int ordinal = int.Parse(set[0]);
                string strVal = set[1];

                //trim extra quotes
                strVal = strVal.Trim('"');

                //get the id from the database
                int dbId = enumConfig.GetID(m_enumSpace, m_enumName, strVal);

                //add to both forward and reverse lookup lists
                //this will use up twice as much memory (still very little compared to everything else...)
                //but it will be just as fast for forward and reverse lookups
                m_csToDb.Add(ordinal, dbId);
                m_dbToCs.Add(dbId, ordinal);
            }
        }
        #endregion

    #region Properties and Methods
        internal int GetDatabaseIDForValue(T value)
        {
            return m_csToDb[Convert.ToInt32(value)];
        }
        internal void SetUsingDatabaseID(int dbId)
        {
            m_value = (T)Enum.ToObject(typeof(T), m_dbToCs[dbId]);
        }
        internal string EnumSpace
        {
            get { return m_enumSpace; }
        }
        internal string EnumName
        {
            get { return m_enumName; }
        }
        #endregion
    }
    #endregion
#endif
}
