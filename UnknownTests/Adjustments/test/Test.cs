using System;
using System.Runtime.InteropServices;
using System.Collections;
using NUnit.Framework;
using MetraTech.Test;
using MetraTech.Adjustments;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using Col = MetraTech.Interop.GenericCollection;
using DA = MetraTech.DataAccess.OleDb;
using MetraTech.DataAccess;

namespace MetraTech.Adjustments.test
{
	/// <summary>
	/// Summary description for Test.
	/// </summary>
	[TestFixture]
	public class BASmokeTest
	{

		private string sub_user;
		private PC.MTProductCatalog productcatalog;
		private AdjustmentCatalog adjustcatalog ;
		 

		public BASmokeTest()
		{
			//
			// TODO: Add constructor logic here
			//
		}

		[Test]
		public void TestBulkAdjustmentsForNormal()
		{
			try
			{
				DoTheAdjustments("BA001", "CallPercentAdjustment", "AudioConfCall");
			}
			catch(Exception ex)
			{
				TestLibrary.Trace( "The Bulk Adjustments test failed for normal adjustment type. Error message: " +ex.Message );
				Assert.Fail( "Execution of the test 'BA001' for Normal Adjustment types failed" );
			}
		}
		
		
		[Test]
		public void TestBulkAdjustmentsForComposite()
		{
			try
			{
				DoTheAdjustments("BA002", "TestCompositeAdjustment", "AudioConfCall");
			}
			catch(Exception ex)
			{
				TestLibrary.Trace( "The Bulk Adjustments test failed for composite adjustment type. Error message: " +ex.Message );
				Assert.Fail( "Execution of the test 'BA002' for Composite Adjustment types failed" );
			}
		}
		
		/// <summary>
		/// This function would be used to test the bulk Adjustments on the normal and
		/// composite adjustment types 
		/// </summary>
		/// <param name="id_test"></param>
		/// <param name="adjustment_name"></param>
		/// <param name="pi_type_name"></param>
		private void DoTheAdjustments(string id_test, string adjustment_name, string pi_type_name)
		{
			string testid = id_test;
			string adjustmentname = adjustment_name;
			string pitypename = pi_type_name;

			TestLibrary.Trace( string.Format( "Starting execution of the test {0} ", testid ) ); 
			if(!ReadFromProperyBag())
			{
				Assert.Fail("Can't read the required info from the PropertyBag.");
				return;
			}

			if(!InitializeTheProductCatalog())
			{
				Assert.Fail("Failed to initialize the Product Catalog.");
				return;
			}

			TestLibrary.Trace( "Successfully initialized the Product Catalog" ); 
			
			PC.IMTPriceableItemType pitype = productcatalog.GetPriceableItemTypeByName( pitypename );

			PC.IMTCollection adjustmentypesCol = pitype.AdjustmentTypes;
			
			//Retrieve the object of the adjustment type from the pi type object
			IAdjustmentType adjusttype = null;
			for(int count=1; count<=adjustmentypesCol.Count; count++ )
			{
				if ( ((IAdjustmentType) adjustmentypesCol[count]).Name ==  adjustmentname )
				{
					adjusttype = (IAdjustmentType)adjustmentypesCol[count]; 
					break;
				}
			}
			if( adjusttype == null )
			{
				Assert.Fail(string.Format( "Couldn't find the '{0}' adjustment type in the database",adjustmentname) );
			}
			TestLibrary.Trace( string.Format( "Clearing the adjustments for the pi type {0}",pitype.Name)  ); 
			//Deleteing all the adjustments for this pi type
			DeleteThePreviousAdjustments(adjusttype, adjustcatalog, pitype );			
			
			Col.IMTCollection sessioncol = new Col.MTCollectionClass();
			//Retrieve the list of sessions that has to be adjusted
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{
				string get_session = "select * from t_acc_usage au inner join t_pi_template pit ON " +
					"au.id_pi_template = pit.id_template inner join t_account_mapper amap on amap.id_acc = au.id_payee" +
					" where pit.id_pi = '" +pitype.ID +"' AND amap.nm_login ='" +sub_user +"'";

				using(IMTStatement sessionStmt = conn.CreateStatement(get_session))
                {
                    using (IMTDataReader sessionReader = sessionStmt.ExecuteReader())
                    {

                        while (sessionReader.Read())
                        {
                            sessioncol.Add(sessionReader.GetInt32("id_sess"));
                        }
                    }
                }
			}
			
			IAdjustmentTransactionSet transactionset = adjusttype.CreateAdjustmentTransactions(sessioncol);
			IEnumerator ienum = transactionset.Inputs.GetEnumerator(); 
				
			while (ienum.MoveNext())
			{
				PC.MTProperty p = (PC.MTProperty)ienum.Current;
				p.Value = 10;
			}
			TestLibrary.Trace( "Set the input charges to 10." ); 
			IMTRowSet warningset = (IMTRowSet)transactionset.CalculateAdjustments(null);

			if(warningset.RecordCount>0)
			{
				Assert.Fail("Got Warnings while calculating adjustments.");
				return;
			}
			
			//Setting the reason code for the transaction set
			IReasonCode reason = (IReasonCode)transactionset.GetApplicableReasonCodes()[1];
			transactionset.ReasonCode = reason;

			TestLibrary.Trace( "Set the reason code to: " +reason.Name ); 			
				
			warningset = (IMTRowSet) transactionset.SaveAdjustments(null);
			if(warningset.RecordCount > 0 )
			{
				Assert.Fail("Got Warnings while Saving adjustments.");
				return;
			}
			
			//Matching the values saved in the database with the values in the results file
			string filename = TestLibrary.TestDatabaseFolder + @"Development\AudioConf\Adjustments\BAResults.csv";

            decimal tadjamount = 0, csvadjamount = 0;
            int no_trans = 0, csv_trans = 0;
                    
			using(IMTFileConnection csvConn = ConnectionManager.CreateFileConnection(filename))
			{
				string csvquery = string.Format("select * from {0} where Test = '{1}'",	csvConn.Filename, testid);
                using (IMTStatement csvStmt = csvConn.CreateStatement(csvquery))
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        string query;
                        if (adjusttype.IsCompositeType)
                        {
                            query = string.Format("select * from t_adjustment_transaction tat inner join t_account_mapper tmap on tmap.id_acc=tat.id_acc_payer inner join t_composite_adjustment tca on tca.id_adjustment_type = tat.id_aj_type where tca.id_prop={0} AND tmap.nm_login = '{1}' AND c_status = 'A'", adjusttype.ID, sub_user);
                        }
                        else
                        {
                            query = string.Format("select * from t_adjustment_transaction tat inner join t_account_mapper tmap on tmap.id_acc=tat.id_acc_payer where id_aj_type={0} AND tmap.nm_login = '{1}' AND c_status = 'A'", adjusttype.ID, sub_user);
                        }

                        using (IMTStatement outputStmt = conn.CreateStatement(query))
                        {
                            using (IMTDataReader outputReader = outputStmt.ExecuteReader())
                            {
                                while (outputReader.Read())
                                {
                                    no_trans++;
                                    tadjamount += outputReader.GetDecimal("AdjustmentAmount");
                                }
                            }
                        }
                    }

                    using (IMTDataReader csvReader = csvStmt.ExecuteReader())
                    {
                        csvReader.Read();
                        csvadjamount = Decimal.Parse(csvReader.GetValue("TotalAdjustmentAmount").ToString().Trim());
                        csv_trans = int.Parse(csvReader.GetValue("TotalNoAdjustment").ToString().Trim());
                    }
                }

				if( (no_trans!=csv_trans) || (csvadjamount!=tadjamount))
				{
					TestLibrary.Trace( string.Format( "Values received from the database are: AdjustmentAmount={0},NofAdjustments={1}", tadjamount, no_trans ) );
					TestLibrary.Trace( string.Format( "Values received from the csv file are: AdjustmentAmount={0},NofAdjustments={1}", csvadjamount, csv_trans ) );
					Assert.Fail( "Bulk Adjustments for normal adjustment type failed. Values didn't match.");
				}
				else
					TestLibrary.Trace( string.Format( "Execution of test {0} was successful", testid ) ); 
			}

		}
	
		/// <summary>
		/// This function is used to read the subscribed user from the property bag file.
		/// This entry is made by the DBMP smoketest
		/// </summary>
		/// <returns></returns>
		private bool ReadFromProperyBag()
		{
			try
			{
				PropertyBag pb = new PropertyBag();
				pb.Initialize( "Metering.SmokeTest" );
				sub_user =  pb["SubscribedUser"].ToString();

				if( sub_user.Length == 0)
					return false;
				return true;
			}
			catch(Exception)
			{
				return false;
			}
		}

		/// <summary>
		/// This function is used to initialize the ProductCatalog and AdjustmentCatalog object
		/// </summary>
		/// <returns></returns>
		private bool InitializeTheProductCatalog()
		{
			try
			{
				productcatalog = new PC.MTProductCatalogClass();
				adjustcatalog = new AdjustmentCatalog();
				IMTLoginContext logincontext = new MTLoginContextClass();
				PC.IMTSessionContext ctx = (PC.IMTSessionContext) logincontext.Login( "su", "system_user", "su123");
			
				adjustcatalog.Initialize( ctx);
				productcatalog.SetSessionContext(ctx);
				return true;
			}
			catch(Exception ex)
			{	
				TestLibrary.Trace( "Error occured while initializing the PC: " +ex.Message );
				return false;
			}
		}

		/// <summary>
		/// This function is used to delete the previous adjustment from the database
		/// </summary>
		/// <param name="adjType"></param>
		/// <param name="adjCat"></param>
		/// <param name="piType"></param>
		private void DeleteThePreviousAdjustments(IAdjustmentType adjType, IAdjustmentCatalog adjCat, PC.IMTPriceableItemType piType )
		{
			try
			{
				string get_session;
				Col.IMTCollection sessioncol = new Col.MTCollectionClass();
				using(IMTConnection conn = ConnectionManager.CreateConnection())
				{
					if(adjType.IsCompositeType)
					{
						get_session = "select * from t_acc_usage au inner join t_pi_template pit ON " +
							"au.id_pi_template = pit.id_template inner join t_account_mapper amap on amap.id_acc = au.id_payee" +
							" where amap.nm_login ='" +sub_user +"'";
					}
					else
					{
						get_session = "select * from t_acc_usage au inner join t_pi_template pit ON " +
							"au.id_pi_template = pit.id_template inner join t_account_mapper amap on amap.id_acc = au.id_payee" +
							" where pit.id_pi = '" +piType.ID +"' AND amap.nm_login ='" +sub_user +"'";
					}

                    using (IMTStatement sessionStmt = conn.CreateStatement(get_session))
                    {
                        using (IMTDataReader sessionReader = sessionStmt.ExecuteReader())
                        {
                            while (sessionReader.Read())
                            {
                                sessioncol.Add(sessionReader.GetInt32("id_sess"));
                            }
                        }
                    }
				}

				IAdjustmentTransactionSet transactionset = adjustcatalog.CreateAdjustmentTransactions(sessioncol);
				transactionset.DeleteAndSave(null);
			}
			catch(Exception)
			{
				throw;
			}
		}
		
	}
}
