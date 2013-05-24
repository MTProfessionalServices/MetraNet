using System;
using MetraTech;
using MetraTech.Interop.MTRuleSet;
using MetraTech.Interop.RCD;
using System.IO;
using System.Collections;
using System.Text;
using System.Xml;
using ProdCat = MetraTech.Interop.MTProductCatalog;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Diagnostics;
using Enum = MetraTech.Interop.MTEnumConfig;
using Rowset=MetraTech.Interop.Rowset;

[assembly: Guid("B4762271-3982-4482-A08C-BF211DF2E742")]

namespace MetraTech.UI.ProductCatalogXml
{

  [Guid("CC110581-5D28-4673-95F0-209517E48675")]
  public interface IRenderXML
  {
    string GetProductOfferingXML(ProdCat.IMTProductOffering po);
    string GetPricelistXML(ProdCat.IMTPriceList pl);
    string GetPriceableItemsXML(Rowset.IMTDataFilter oFilter);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("9DE7CD57-E238-4a7d-A2A1-CF028175BBB5")]
  public class RenderXML: IRenderXML
  {
    protected Logger mLogger = new Logger("[RuleSetImportExport]");

    public RenderXML()
    {
    }

    public string GetPriceableItemsXML(Rowset.IMTDataFilter oFilter)
    {
      ProdCat.IMTProductCatalog pc = null;
      pc = new ProdCat.MTProductCatalogClass();

      StringBuilder xmlBuffer = new StringBuilder("\n");
      xmlBuffer.Capacity = 2048;

      ProdCat.IMTRowSet priceableItemsRowset = pc.FindPriceableItemsAsRowset(oFilter);

      GetPriceableItemsXML(priceableItemsRowset,xmlBuffer,true,pc);

      return xmlBuffer.ToString();
    }

    protected void GetPriceableItemsXML(ProdCat.IMTRowSet priceableItemRowset, StringBuilder xmlBuffer, bool bTopLevel, ProdCat.IMTProductCatalog pc)
    {
      xmlBuffer.Append("    <priceableitems>" + Environment.NewLine);
        
      for (int i=0;i<priceableItemRowset.RecordCount;i++)
      {
        int idPriceableItem;
        //Properties are different depending on if the list came from the PO or a PI... UUUGGGGHHH!
        if (bTopLevel)
          idPriceableItem = Convert.ToInt32(priceableItemRowset.get_Value("id_prop"));
        else
          idPriceableItem = Convert.ToInt32(priceableItemRowset.get_Value("id_template"));

        xmlBuffer.Append("      <priceableitem>" + Environment.NewLine);

        xmlBuffer.Append("        <id>" + idPriceableItem + "</id>" + Environment.NewLine);
        xmlBuffer.Append("        <name><![CDATA[" + priceableItemRowset.get_Value("nm_name") + "]]></name>" + Environment.NewLine);
        xmlBuffer.Append("        <displayname><![CDATA[" + priceableItemRowset.get_Value("nm_display_name") + "]]></displayname>" + Environment.NewLine);
        xmlBuffer.Append("        <description><![CDATA[" + priceableItemRowset.get_Value("nm_desc") + "]]></description>" + Environment.NewLine);
        xmlBuffer.Append("        <kind>" + priceableItemRowset.get_Value("n_kind") + "</kind>" + Environment.NewLine);
    
        ProdCat.IMTPriceableItem pi = pc.GetPriceableItem(idPriceableItem);
        ProdCat.IMTRowSet childPriceableItemRowset = pi.GetChildrenAsRowset();
 
        GetPriceableItemsXML(childPriceableItemRowset,xmlBuffer,false,pc);

        ProdCat.IMTPriceableItemType piType = pi.PriceableItemType;
       
        xmlBuffer.Append("        <parametertables>" + Environment.NewLine);

        foreach(ProdCat.IMTParamTableDefinition pt in piType.GetParamTableDefinitions())
        {
          xmlBuffer.Append("          <parametertable>" + Environment.NewLine);
          xmlBuffer.Append("            <id>" + pt.ID + "</id>" + Environment.NewLine);
          xmlBuffer.Append("            <name><![CDATA[" + pt.Name + "]]></name>" + Environment.NewLine);
          //Override default displayname in case it was not specified
          string sDisplayName = pt.DisplayName;
          if (sDisplayName.Trim().Length==0) sDisplayName = pt.Name;
          xmlBuffer.Append("            <displayname><![CDATA[" + sDisplayName + "]]></displayname>" + Environment.NewLine);
          xmlBuffer.Append("          </parametertable>" + Environment.NewLine);
        }
        xmlBuffer.Append("        </parametertables>" + Environment.NewLine);

        xmlBuffer.Append("      </priceableitem>" + Environment.NewLine);
        
        priceableItemRowset.MoveNext();
      }
      xmlBuffer.Append("    </priceableitems>" + Environment.NewLine);

    }
  

    public string GetPricelistXML(ProdCat.IMTPriceList pl)
    {
      ProdCat.IMTProductCatalog pc = null;
      pc = new ProdCat.MTProductCatalogClass();

      StringBuilder xmlBuffer = new StringBuilder("\n");
      xmlBuffer.Capacity = 2048;
      
      xmlBuffer.Append("<pricelist>" + Environment.NewLine);
      xmlBuffer.Append("    <id>" + pl.ID + "</id>" + Environment.NewLine);
      xmlBuffer.Append("    <name><![CDATA[" + pl.Name + "]]></name>" + Environment.NewLine);
      xmlBuffer.Append("    <description><![CDATA[" + pl.Description + "]]></description>" + Environment.NewLine);

      GetPricelistPriceableItemsXML(pl.ID, xmlBuffer);
      xmlBuffer.Append("</pricelist>" + Environment.NewLine);

      return xmlBuffer.ToString();
    }

    protected void GetPricelistPriceableItemsXML(int idPricelist, StringBuilder xmlBuffer)
    {
      Rowset.IMTSQLRowset rowset = (Rowset.IMTSQLRowset)new Rowset.MTSQLRowset();
      rowset.Init(@"Queries\mcm");
      rowset.SetQueryTag("__SELECT_PRICEABLE_ITEMS_ON_PRICELIST__");
      rowset.AddParam("%%ID_PRICELIST%%", idPricelist, false);
      rowset.Execute();

      xmlBuffer.Append("    <priceableitems>" + Environment.NewLine);
      
      StringBuilder xmlTempBuffer = new StringBuilder();

      Hashtable childPriceableitemsXml = new Hashtable();

      int idCurrentPriceableItem = 0; //Use this to determine when the priceable has changed
      object idCurrentParentPriceableitem = null;

      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        int idPriceableItem = Convert.ToInt32(rowset.get_Value("id_pi_template"));
        int idParameterTable = Convert.ToInt32(rowset.get_Value("id_pt"));

        if (idCurrentPriceableItem!=idPriceableItem)
        {
          if (idCurrentPriceableItem!=0)
          {
            xmlTempBuffer.Append("        </rateschedules>" + Environment.NewLine);

            xmlTempBuffer.Append("      </priceableitem>" + Environment.NewLine);

            //We are done with this priceable item, if it is a child, store it away in our hash for later (they come first)
            //and if it is a parent then add it now
            if (idCurrentParentPriceableitem != DBNull.Value)
            {
              if(childPriceableitemsXml.ContainsKey(idCurrentParentPriceableitem.ToString()))
              {
                childPriceableitemsXml[idCurrentParentPriceableitem.ToString()] += xmlTempBuffer.ToString();
              }
              else
              {
                childPriceableitemsXml.Add(idCurrentParentPriceableitem.ToString(),xmlTempBuffer.ToString());
              }            
            }
            else
            {
              xmlBuffer.Append(xmlTempBuffer);
            }
            xmlTempBuffer = new StringBuilder();
          }

          idCurrentPriceableItem=idPriceableItem;
          idCurrentParentPriceableitem = rowset.get_Value("id_pi_template_parent");

          xmlTempBuffer.Append("      <priceableitem>" + Environment.NewLine);

          xmlTempBuffer.Append("        <id>" + idPriceableItem + "</id>" + Environment.NewLine);
          xmlTempBuffer.Append("        <kind>" + rowset.get_Value("PiKind") + "</kind>" + Environment.NewLine);
          xmlTempBuffer.Append("        <name><![CDATA[" + rowset.get_Value("PiName") + "]]></name>" + Environment.NewLine);
          xmlTempBuffer.Append("        <displayname><![CDATA[" + rowset.get_Value("PiDisplayName") + "]]></displayname>" + Environment.NewLine);
          xmlTempBuffer.Append("        <priceableitems>" + Environment.NewLine);
          //Check for child priceable items that we have already parsed
          if (childPriceableitemsXml.ContainsKey(idPriceableItem.ToString()))
          {
            xmlTempBuffer.Append(childPriceableitemsXml[idPriceableItem.ToString()].ToString());
            childPriceableitemsXml.Remove(idPriceableItem.ToString());
          }

          xmlTempBuffer.Append("        </priceableitems>" + Environment.NewLine);
          xmlTempBuffer.Append("        <rateschedules>" + Environment.NewLine);

        }

        xmlTempBuffer.Append("        <rateschedule>" + Environment.NewLine);

        xmlTempBuffer.Append("          <paramtable_id>" + idParameterTable + "</paramtable_id>" + Environment.NewLine);
        xmlTempBuffer.Append("          <paramtable><![CDATA[" + rowset.get_Value("PtName") + "]]></paramtable>" + Environment.NewLine);
        xmlTempBuffer.Append("          <paramtable_displayname><![CDATA[" + rowset.get_Value("PtDisplayName") + "]]></paramtable_displayname>" + Environment.NewLine);
        xmlTempBuffer.Append("        </rateschedule>" + Environment.NewLine);

        rowset.MoveNext();
    
      }

      if (idCurrentPriceableItem!=0)
      {
        xmlTempBuffer.Append("        </rateschedules>" + Environment.NewLine);
        xmlTempBuffer.Append("      </priceableitem>" + Environment.NewLine);

        //We are done with this priceable item, if it is a child, store it away in our hash for later (they come first)
        //and if it is a parent then add it now
        if (idCurrentParentPriceableitem != DBNull.Value)
        {
          if(childPriceableitemsXml.ContainsKey(idCurrentParentPriceableitem.ToString()))
          {
            childPriceableitemsXml[idCurrentParentPriceableitem.ToString()] += xmlTempBuffer.ToString();
          }
          else
          {
            childPriceableitemsXml.Add(idCurrentParentPriceableitem.ToString(),xmlTempBuffer.ToString());
          }        
        }
        else
        {
          xmlBuffer.Append(xmlTempBuffer);
        }

        xmlTempBuffer = new StringBuilder();
      }

      //If there are any child priceable items left, write them out at the top level (children without parents with rates on this pricelist
      //appear at the top level with no empty parent)
      foreach (DictionaryEntry de in childPriceableitemsXml)
      {
        xmlBuffer.Append(de.Value);
      }

      xmlBuffer.Append("    </priceableitems>" + Environment.NewLine);
    }


    public string GetProductOfferingXML(ProdCat.IMTProductOffering po)
    {
      ProdCat.IMTProductCatalog pc = null;
      pc = new ProdCat.MTProductCatalogClass();

      StringBuilder xmlBuffer = new StringBuilder("\n");
      xmlBuffer.Capacity = 2048;
      
      xmlBuffer.Append("<productoffering>" + Environment.NewLine);
      xmlBuffer.Append("    <id>" + po.ID + "</id>" + Environment.NewLine);
      xmlBuffer.Append("    <name><![CDATA[" + po.Name + "]]></name>" + Environment.NewLine);
      xmlBuffer.Append("    <displayname><![CDATA[" + po.DisplayName + "]]></displayname>" + Environment.NewLine);
      xmlBuffer.Append("    <description><![CDATA[" + po.Description + "]]></description>" + Environment.NewLine);
      
      ProdCat.IMTRowSet priceableItemRowset = po.GetPriceableItemsAsRowset();
      GetProductOfferingPriceableItemsXML(priceableItemRowset,xmlBuffer,true,po.NonSharedPriceListID,pc);
      xmlBuffer.Append("</productoffering>" + Environment.NewLine);

      return xmlBuffer.ToString();
    }
    
    //Help method to be used recursively to retrieve the priceable items in the product offering
    protected void GetProductOfferingPriceableItemsXML(ProdCat.IMTRowSet priceableItemRowset, StringBuilder xmlBuffer, bool bTopLevel, int idNonSharedPricelist, ProdCat.IMTProductCatalog pc)
    {
      xmlBuffer.Append("    <priceableitems>" + Environment.NewLine);
        
      for (int i=0;i<priceableItemRowset.RecordCount;i++)
      {
        int ratingType = -1;
        try
        {
          if (priceableItemRowset.get_Value("n_rating_type").ToString() != "")
          {
            ratingType = Convert.ToInt32(priceableItemRowset.get_Value("n_rating_type"));
          }
        }
        catch (Exception exp)
        {
          mLogger.LogException("Error getting n_rating_type:", exp);
        }

        int idPriceableItem;
        //Properties are different depending on if the list came from the PO or a PI... UUUGGGGHHH!
        if (bTopLevel)
          idPriceableItem = Convert.ToInt32(priceableItemRowset.get_Value("id_prop"));
        else
          idPriceableItem = Convert.ToInt32(priceableItemRowset.get_Value("id_pi_instance"));

        xmlBuffer.Append("      <priceableitem>" + Environment.NewLine);

        xmlBuffer.Append("        <id>" + idPriceableItem + "</id>" + Environment.NewLine);
        xmlBuffer.Append("        <name><![CDATA[" + priceableItemRowset.get_Value("nm_name") + "]]></name>" + Environment.NewLine);
        xmlBuffer.Append("        <displayname><![CDATA[" + priceableItemRowset.get_Value("nm_display_name") + "]]></displayname>" + Environment.NewLine);
        xmlBuffer.Append("        <description><![CDATA[" + priceableItemRowset.get_Value("nm_desc") + "]]></description>" + Environment.NewLine);
        xmlBuffer.Append("        <kind>" + priceableItemRowset.get_Value("n_kind") + "</kind>" + Environment.NewLine);
        ProdCat.IMTPriceableItem pi = pc.GetPriceableItem(idPriceableItem);
        ProdCat.IMTRowSet childPriceableItemRowset = pi.GetChildrenAsRowset();
 
        GetProductOfferingPriceableItemsXML(childPriceableItemRowset,xmlBuffer,false,idNonSharedPricelist,pc);
      
        //ok - let's go deeper and get the GetNonICBPriceListMappingsAsRowset and make links to the rates
        xmlBuffer.Append("        <pricelistmappings>" + Environment.NewLine);
        ProdCat.IMTRowSet pricelistMappingsRowset= pi.GetNonICBPriceListMappingsAsRowset();
        for (int j=0; j<pricelistMappingsRowset.RecordCount;j++)
        {
          // Only show paramtables with the current rating type 
          if (ratingType != -1 &&
              (pricelistMappingsRowset.get_Value("tpt_nm_name").ToString().ToLower() == "metratech.com/udrctapered" ||
              pricelistMappingsRowset.get_Value("tpt_nm_name").ToString().ToLower() == "metratech.com/udrctiered"))
          {
            switch (ratingType)
            {
              case 0:
                if ("metratech.com/udrctiered" != pricelistMappingsRowset.get_Value("tpt_nm_name").ToString().ToLower())
                {
                  pricelistMappingsRowset.MoveNext();
                  continue;
                }
                break;

              case 1:
                if ("metratech.com/udrctapered" != pricelistMappingsRowset.get_Value("tpt_nm_name").ToString().ToLower())
                {
                  pricelistMappingsRowset.MoveNext();
                  continue;
                }
                break;

              default:
                break;
            }
          }

          xmlBuffer.Append("          <pricelistmapping>" + Environment.NewLine);
          xmlBuffer.Append("          <paramtable_id>" + pricelistMappingsRowset.get_Value("id_paramtable") + "</paramtable_id>" + Environment.NewLine);
          xmlBuffer.Append("          <paramtable_name><![CDATA[" + pricelistMappingsRowset.get_Value("tpt_nm_name") + "]]></paramtable_name>" + Environment.NewLine);
          //Override default displayname in case it was not specified
          string sDisplayName = pricelistMappingsRowset.get_Value("nm_display_name").ToString();
          if (sDisplayName.Trim().Length==0) sDisplayName = pricelistMappingsRowset.get_Value("tpt_nm_name").ToString();
          xmlBuffer.Append("          <paramtable_displayname><![CDATA[" + sDisplayName + "]]></paramtable_displayname>" + Environment.NewLine);
          xmlBuffer.Append("          <pricelist_id>" + pricelistMappingsRowset.get_Value("id_pricelist") + "</pricelist_id>" + Environment.NewLine);

          if (pricelistMappingsRowset.get_Value("tpl_nm_name").ToString().Length>0)
            xmlBuffer.Append("          <pricelist_name><![CDATA[" + pricelistMappingsRowset.get_Value("tpl_nm_name") + "]]></pricelist_name>" + Environment.NewLine);
            
		  if ((pricelistMappingsRowset.get_Value("id_pricelist")!=System.DBNull.Value) && (Convert.ToInt32(pricelistMappingsRowset.get_Value("id_pricelist")) == idNonSharedPricelist))
			xmlBuffer.Append("          <nonsharedpricelist>TRUE</nonsharedpricelist>" + Environment.NewLine);
          else
            xmlBuffer.Append("          <nonsharedpricelist>FALSE</nonsharedpricelist>" + Environment.NewLine);


          if (pricelistMappingsRowset.get_Value("b_canICB").ToString()=="Y")
            xmlBuffer.Append("          <allowicb>TRUE</allowicb>" + Environment.NewLine);
          else
            xmlBuffer.Append("          <allowicb>FALSE</allowicb>" + Environment.NewLine);

          xmlBuffer.Append("          </pricelistmapping>" + Environment.NewLine);   
          pricelistMappingsRowset.MoveNext();
        }

        xmlBuffer.Append("        </pricelistmappings>" + Environment.NewLine);
        xmlBuffer.Append("      </priceableitem>" + Environment.NewLine);
        
        priceableItemRowset.MoveNext();
      }
      xmlBuffer.Append("    </priceableitems>" + Environment.NewLine);

    }
  }

 
  [ComVisible(false)]
  public class EnumInfo
  {
    public EnumInfo()
    {
    }

    public EnumInfo(string sEnumSpace, string sEnumType)
    {
      mEnumSpace = sEnumSpace;
      mEnumType = sEnumType;
    }
    
    public string Space
    {
      get { return mEnumSpace;}
      set { mEnumSpace = value;}
    }

    public string Type
    {
      get { return mEnumType;}
      set { mEnumType = value;}
    }

    protected string mEnumSpace;
    protected string mEnumType;

  }

}
