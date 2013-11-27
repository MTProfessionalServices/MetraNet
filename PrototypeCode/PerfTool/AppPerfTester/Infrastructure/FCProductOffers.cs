using System;
using System.Collections.Generic;
using System.Data;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;


namespace BaselineGUI
{
    public class FCProductOffers : FrameworkComponentBase, IFrameworkComponent 
    {
        public DataTable tabularModel;

        public List<ProductOffering> productOfferings = new List<ProductOffering>();

        public FCProductOffers()
        {
            name = "ProductOffers";
            fullName = "Product Offers";

            tabularModel = new DataTable();
            tabularModel.Columns.Add(new DataColumn("Product Offer", typeof(string)));
            tabularModel.Columns.Add(new DataColumn("Product Offer ID", typeof(int)));
            tabularModel.Columns.Add(new DataColumn("Priceable Item ID", typeof(int)));
        }

        public void Bringup()
        {
            ProductOfferingServiceClient client = new ProductOfferingServiceClient("NetTcpBinding_IMetraTech.Core.Services.ProductOfferingService");
            client.ClientCredentials.UserName.UserName = PrefRepo.active.actSvcs.authName; // "admin";
            client.ClientCredentials.UserName.Password = PrefRepo.active.actSvcs.authPassword; // "123";
            int count = 0;

            try
            {
                bringupState.message = "Opening client";
                client.Open();

                bringupState.message = "Getting the list";
                MTList<ProductOffering> mtlistPo = new MTList<ProductOffering>();
                client.GetProductOfferings(ref mtlistPo);

                productOfferings = mtlistPo.Items;

                bringupState.message = "Building the table"; 
                foreach (ProductOffering po in productOfferings)
                {
                    DataRow row = tabularModel.NewRow();
                    row[0] = po.DisplayName;
                    row[1] = po.ProductOfferingId;
                    tabularModel.Rows.Add(row);
                    count++;

                    foreach (var PI in po.PriceableItems)
                    {
                        row = tabularModel.NewRow();
                        row[0] = po.DisplayName;
                        row[1] = po.ProductOfferingId;
                        row[2] = PI.ID;

                        tabularModel.Rows.Add(row);
                        count++;
                        var foo = po.ProductOfferingId;
                    }
                }
                bringupState.message = "Closing the client"; 
                client.Close();
                bringupState.message = string.Format("Found {0} product offers", count);

            }
            catch
            {
            }



        }

        public ProductOffering findPO( string name)
        {
            foreach (var po in productOfferings)
            {
                if (po.Name.ToLower() == name.ToLower())
                    return po;
            }
            return null;
        }


        public List<int> getRefDataList()
        {
            List<int> poList = new List<int>();
            foreach (ProductOffering po in productOfferings)
            {
                string key = po.Name;
                ProductOfferPreferences pref = PrefRepo.active.findPoPreferences(key);
                if (pref.staticEnabled)
                {
                    poList.Add((int)po.ProductOfferingId);
                }
            }

            return poList;
        }


        public void Teardown()
        {
        }

    }
}
