#region

using System;
using MetraTech.DataAccess;

#endregion

namespace MetraTech.Tax.Framework.DataAccess
{
    /// <summary>
    /// This class represents a row in the t_tax_details table.
    /// 
    /// When the tax package is called, multiple taxes can be reported for a single jurisdication.  
    /// For example, the tax package may return that there are two county taxes 
    /// (example: county-tax-a = $1, county-tax-b=$2).  In the tax output table the multple 
    /// jurisidications are aggregated and returned (example: county tax = $3).  In the 
    /// t_tax_details the breakdown of the taxes are stored 
    /// (example: a separate row for county-tax-a and county-tax-b).
    /// You can use the t_tax_details table for retrieving the tax details by the id_tax_charge.  
    /// You may want to consider storing the id_tax_charge (example: in the product view) if you are
    /// planning on accessing the breakdown of the taxes is the future, perhaps as part of a user interface display.
    /// </summary>
    public class TransactionIndividualTax : TaxManagerPersistenceObject
    {
        /// <summary>
        /// integer	This is the primary key for the table.
        /// </summary>
        public int IdTaxDetail { set; get; }

        /// <summary>
        /// integer	This is a foreign key of t_tax_input_ table.  
        /// </summary>
        public long IdTaxCharge { set; get; }

        /// <summary>
        /// The account associated with the tax calculation.
        /// </summary>
        public int IdAcc { set; get; }

        /// <summary>
        /// The usage interval assocatied with the tax calculation.
        /// </summary>
        public int IdUsageInterval { set; get; }

        /// <summary>
        /// integer Identifies the tax run ID associated with the tax calculation.
        /// This ID is used in the EOP Tax scenario where the input and output table
        /// names end with this number.  By having the tax run ID, we can easily
        /// remove all the rows associated with a particular tax run.
        /// </summary>
        public int IdTaxRun { set; get; }

        /// <summary>
        /// Date when calculation occurred
        /// </summary>
        public DateTime DateOfCalc { set; get; }

        /// <summary>
        /// decimal 	tax amount. 
        /// </summary>
        public decimal TaxAmount { set; get; }

        /// <summary>
        /// decimal 	tax rate. 
        /// </summary>
        public decimal Rate { set; get; }

        /// <summary>
        /// 0-Federal, 1-State, 2,-County, 3-Local, 4-other
        /// </summary>
        public int TaxJurLevel { set; get; }

        /// <summary>
        /// The name of the particular Jurisdiction. For example US is Federal, MA - is state
        /// </summary>
        public string TaxJurName { set; get; }

        /// <summary>
        /// Vendor specific tax number
        /// </summary>
        public int TaxType { set; get; }

        /// <summary>
        /// Name for the tax_type. Example ('Sales tax', ' Federal Excise Tax')
        /// </summary>
        public string TaxTypeName { set; get; }

        /// <summary>
        /// If true, the amount is an implied tax (example: USF).  
        /// This means that this amount was NOT aggregated as part 
        /// of the jurisdication tax amount.  The amount is not 
        /// aggregated because it is assumed to already be a part 
        /// of the amount being taxed.
        /// </summary>
        public bool IsImplied { set; get; }

        /// <summary>
        /// Hold any details about how the taxes were calculated.
        /// This is especially important for MetraTax, which uses
        /// this field as a form of audit.
        /// </summary>
        public string Notes { set; get; }

        /// <summary>
        /// This is the method for performing a SQLServer bulk insert.
        /// </summary>
        /// <param name="bcpObj"></param>
        public override void Persist(ref BCPBulkInsert bcpObj)
        {
            bcpObj.SetValue(1, MTParameterType.Integer, IdTaxDetail);
            bcpObj.SetValue(2, MTParameterType.BigInteger, IdTaxCharge);
            bcpObj.SetValue(3, MTParameterType.Integer, IdAcc);
            bcpObj.SetValue(4, MTParameterType.Integer, IdUsageInterval);
            bcpObj.SetValue(5, MTParameterType.Integer, IdTaxRun);
            bcpObj.SetValue(6, MTParameterType.DateTime, DateOfCalc.ToUniversalTime());
            bcpObj.SetValue(7, MTParameterType.Decimal, TaxAmount);
            bcpObj.SetValue(8, MTParameterType.Decimal, Rate);
            bcpObj.SetValue(9, MTParameterType.Integer, TaxJurLevel);
            bcpObj.SetValue(10, MTParameterType.WideString, TaxJurName);
            bcpObj.SetValue(11, MTParameterType.Integer, TaxType);
            bcpObj.SetValue(12, MTParameterType.WideString, TaxTypeName);
            bcpObj.SetValue(13, MTParameterType.WideString, (IsImplied) ? @"Y" : @"N");
            if (!String.IsNullOrEmpty(Notes)) bcpObj.SetValue(14, MTParameterType.WideString, Notes);
        }

        /// <summary>
        /// This is the method for performing an Oracle bulk insert.
        /// </summary>
        /// <param name="arrayBulkInsert"></param>
        public override void Persist(ref ArrayBulkInsert arrayBulkInsert)
        {
            arrayBulkInsert.SetValue(1, MTParameterType.Integer, IdTaxDetail);
            arrayBulkInsert.SetValue(2, MTParameterType.BigInteger, IdTaxCharge);
            arrayBulkInsert.SetValue(3, MTParameterType.Integer, IdAcc);
            arrayBulkInsert.SetValue(4, MTParameterType.Integer, IdUsageInterval);
            arrayBulkInsert.SetValue(5, MTParameterType.Integer, IdTaxRun);
            arrayBulkInsert.SetValue(6, MTParameterType.DateTime, DateOfCalc.ToUniversalTime());
            arrayBulkInsert.SetValue(7, MTParameterType.Decimal, TaxAmount);
            arrayBulkInsert.SetValue(8, MTParameterType.Decimal, Rate);
            arrayBulkInsert.SetValue(9, MTParameterType.Integer, TaxJurLevel);
            arrayBulkInsert.SetValue(10, MTParameterType.WideString, TaxJurName);
            arrayBulkInsert.SetValue(11, MTParameterType.Integer, TaxType);
            arrayBulkInsert.SetValue(12, MTParameterType.WideString, TaxTypeName);
            arrayBulkInsert.SetValue(13, MTParameterType.WideString, (IsImplied) ? @"Y" : @"N");
            if (!String.IsNullOrEmpty(Notes))
                arrayBulkInsert.SetValue(14, MTParameterType.WideString, Notes);
        }

        public override string ToString()
        {
            string ret = string.Format("TransactionIndividualTax: IdTaxDetail={0}\n", IdTaxDetail);
            ret += string.Format("IdTaxCharge={0}, IdAcc={1}, IdUsageInterval={2}\n", IdTaxCharge, IdAcc, IdUsageInterval);
            ret += string.Format("IdTaxRun={0}, DateOfCalc={1}, TaxAmount={2}\n", IdTaxRun, DateOfCalc, TaxAmount);
            ret += string.Format("Rate={0}, TaxJurLevel={1}, TaxJurName={2}\n", Rate, TaxJurLevel, TaxJurName);
            ret += string.Format("TaxType={0}, TaxTypeName={1}, IsImplied={2}\n", TaxType, TaxTypeName, IsImplied);
            ret += string.Format("Notes={0}", Notes);

            return ret;
        }
    }
}
