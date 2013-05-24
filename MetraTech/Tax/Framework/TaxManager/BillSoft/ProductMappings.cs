#region

using System;
using System.Collections.Generic;
using System.IO;
using MetraTech.DataAccess;
using MetraTech.Interop.RCD;
using MetraTech.Tax.Framework.MtBillSoft;

#endregion

namespace MetraTech.Tax.Framework.MtBillSoft
{
  public class ProductMapping
  {
    /// <summary>
    /// This is a primary key for the table and the foreign key 
    /// of t_tax_input_XX table.  
    /// </summary>
    public string product_code { set; get; }

    /// <summary>
    /// BillSoft transaction type
    /// </summary>
    public int transaction_type { set; get; }

    /// <summary>
    /// BillSoft service type.
    /// </summary>
    public int service_type { set; get; }
  }

  public class ProductCodeMapper
  {
    public static Logger mLogger = new Logger("[TaxManager.BillSoft.ProductCodeMapper]");
    private string mBSQueryDir = "";
    private Dictionary<string, ProductMapping> mProductMappings;

    public ProductCodeMapper(string queryDirPath)
    {
      if (String.IsNullOrEmpty(queryDirPath)) throw new ArgumentNullException("Must define query path parameter");

      var objRCD = new MTRcd();
      var fullPath = objRCD.ConfigDir + "\\" + queryDirPath.Trim();
      if (!Directory.Exists(fullPath))
      {
        throw new DirectoryNotFoundException(string.Format("Path [{0}] does not exist.", fullPath));
      }
      mBSQueryDir = queryDirPath;
      mProductMappings = new Dictionary<string, ProductMapping>();
    }

    public ProductMapping GetProductCode(string productCode)
    {
      return mProductMappings.ContainsKey(productCode) ? mProductMappings[productCode] : null;
    }

    public void PopulateMappingDictionary()
    {
      var mappings = new List<ProductMapping>();
      try
      {
          using (var conn = ConnectionManager.CreateConnection())
          using (var stmt = conn.CreateAdapterStatement(mBSQueryDir, "__GET_ALL_PRODUCT_MAPPINGS__"))
          {
              using (var reader = stmt.ExecuteReader())
              {
                  ProcessReader(ref mappings, reader);
              }
          }
      }
      catch (Exception e)
      {
          mLogger.LogError("Failed to load values from t_tax_billsoft_pc_map. Error: " + e.Message +
                           " Inner exception: " + e.InnerException + " Stack: " + e.StackTrace);
          // We're going to continue execution.  Ultimately, this will result in another error if
          // the product code cannot be found in the map.
      }
    }

#if false
    public List<ProductMapping> GetMappingsByProductCode(string productCode)
    {
      var mappings = new List<ProductMapping>();

      if (String.IsNullOrEmpty(productCode))
      {
        mLogger.LogError("GetMappingsByProductCode called with null or empty product code");
        return mappings;
      }
      using (var conn = ConnectionManager.CreateConnection())
      using (var stmt = conn.CreateAdapterStatement(mBSQueryDir, "__GET_PRODUCT_MAPPING_BY_PRODUCT_CODE__"))
      {
        stmt.AddParam("%%PRODUCTCODE%%", productCode);
        using (var reader = stmt.ExecuteReader())
        {
          ProcessReader(ref mappings, reader);
        }
      }
      return mappings;
    }

    public List<ProductMapping> GetMappingsByCatagoryCode(int catCode)
    {
      var mappings = new List<ProductMapping>();
      using (var conn = ConnectionManager.CreateConnection())
      using (var stmt = conn.CreateAdapterStatement(mBSQueryDir, "__GET_PRODUCT_MAPPING_BY_CATAGORY_CODE__"))
      {
        stmt.AddParam("%%CATAGORYCODE%%", catCode);
        using (var reader = stmt.ExecuteReader())
        {
          ProcessReader(ref mappings, reader);
        }
      }
      return mappings;
    }

    public List<ProductMapping> GetMappingsByServiceCode(int serviceCode)
    {
      var mappings = new List<ProductMapping>();
      using (var conn = ConnectionManager.CreateConnection())
      using (var stmt = conn.CreateAdapterStatement(mBSQueryDir, "__GET_PRODUCT_MAPPING_BY_SERVICE_CODE__"))
      {
        stmt.AddParam("%%SERVICECODE%%", serviceCode);
        using (var reader = stmt.ExecuteReader())
        {
          ProcessReader(ref mappings, reader);
        }
      }
      return mappings;
    }

    public List<ProductMapping> GetMappingsByCatagoryAndServiceCode(int catCode, int serviceCode)
    {
      var mappings = new List<ProductMapping>();
      using (var conn = ConnectionManager.CreateConnection())
      using (var stmt = conn.CreateAdapterStatement(mBSQueryDir, "__GET_PRODUCT_MAPPING_BY_CATAGORY_AND_SERVICE_CODE__")
        )
      {
        stmt.AddParam("%%CATAGORYCODE%%", catCode);
        stmt.AddParam("%%SERVICECODE%%", serviceCode);
        using (var reader = stmt.ExecuteReader())
        {
          ProcessReader(ref mappings, reader);
        }
      }
      return mappings;
    }
#endif

    private void ProcessReader(ref List<ProductMapping> mappings, IMTDataReader reader)
    {
      while (reader.Read())
      {
        // Note that product code is a primary key in the table
        // and is therefore guaranteed to be unique.

        var pc = CreateProductMapping(reader);
        mappings.Add(pc);
        if (!mProductMappings.ContainsKey(pc.product_code))
        {
          mProductMappings.Add(pc.product_code, pc);
        }
      }
    }

    private static ProductMapping CreateProductMapping(IMTDataReader reader)
    {
      try
      {
        return new ProductMapping
                 {
                   product_code = reader.GetString("product_code"),
                   transaction_type = reader.GetInt32("transaction_type"),
                   service_type = reader.GetInt32("service_type")
                 };
      }
      catch (Exception e)
      {
        throw e;
      }
    }
  }
}
