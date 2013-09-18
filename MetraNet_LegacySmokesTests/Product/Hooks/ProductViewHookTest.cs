using System;
using System.Collections;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Reflection;
using System.Xml;
using System.Xml.Serialization;
using System.Xml.Schema;
using System.IO;
using System.Text;
using System.Data.OleDb;

using MetraTech;
using MetraTech.Product.Hooks;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTHooklib;
using MetraTech.Interop.MTHookHandler;
using MetraTech.Interop.RCD;
using MetraTech.Product.Hooks.DynamicTableUpdate;
using MetraTech.DataAccess;

using NUnit.Framework;

namespace MetraTech.Product.Hooks.Test
{

	[TestFixture]
  [Category("NoAutoRun")]
  public class ProductViewHookTest
	{
		Hashtable tests = new Hashtable();
		MSIXDef m6 = new MSIXDef();
		string defPath = null;
		string m6name = null;
		PartitionOps partOps = new PartitionOps();
		UniqueKeyOps ukOps = new UniqueKeyOps();
		Logger mLog;
		IMTHookHandler handler = new MTHookHandlerClass();
    bool isOracle;

		#region ctor & helpers

	    public ProductViewHookTest()
	    {
	        using (IMTConnection conn = ConnectionManager.CreateConnection())
	        {
	            isOracle = conn.ConnectionInfo.IsOracle;
	        }
	    }

	    void runHook()
		{
			int x = 0;
			handler.RunHookWithProgid("MetraHook.DeployProductView.1", null, ref x);
		}
		MSIXDef fishhook()
		{
			showcaller();
			m6.SaveToFile(defPath);
			runHook();
			return MSIXDef.FromDatabase(m6.name);
		}
		void setupm6()
		{
			// create the msixdef file for the hook
			using (StreamWriter sr = File.CreateText(defPath))
				sr.WriteLine(testPropsXml);

			// load it, change it's name, and other stuff
			m6 = MSIXDef.FromFile(defPath);
			m6.name = m6name;
			m6.FindPtypeByName("BoolProp1").required = "N";
			m6.FindPtypeByName("DecProp1").required = "N";
			m6.ptypes.Remove(m6.FindPtypeByName("DoubleProp1"));  // remove double type; no longer supp'd
			m6.ptypes.Remove(m6.FindPtypeByName("DoubleProp1Default"));
			m6.uniqueKeys.Add(new UniqueKey("dpv_uk1", "IntProp1", "StringProp1Default", "DecProp1Default"));
			m6.uniqueKeys.Add(new UniqueKey("dpv_uk2", "StringProp2Default", "StringProp1Default", "DecProp1Default"));
			//m6.Show();
		}
		void showcaller()
		{
			StackTrace stack = new StackTrace();
			StackFrame frame = stack.GetFrame(2);
			MethodBase method = frame.GetMethod();
			Console.WriteLine(method.Name);
		}
		string funcname()
		{
			StackTrace stack = new StackTrace();
			StackFrame frame = stack.GetFrame(1);
			MethodBase method = frame.GetMethod();
			return method.Name;
		}

		#endregion ctor & helpers

        [TestFixtureSetUp]
        public void FixtureSetup()
        {
            Console.WriteLine("\nProductViewHook test setup()");

            mLog = new Logger("[ProductViewHookUnitTest]");
            if (mLog == null)
                throw new ApplicationException("Couldn't create the Logger object");

            m6name = "metratech.com/dpvunittest";

            // create msixdef for unit test
            IMTRcd rcd = new MTRcdClass();
            defPath = rcd.ExtensionDir +
                @"\Core\config\productview\metratech.com\dpvunittest.msixdef";
            Console.WriteLine("Using dir:  " + defPath);

            // load a list of all test methods
            Type t = this.GetType();
            MethodInfo[] mis = this.GetType().GetMethods();
            foreach (MethodInfo mi in mis)
            {
                foreach (object o in mi.GetCustomAttributes(true))
                {
                    if (o is TestAttribute)
                    {
                        tests.Add(mi.Name, null);
                        break;
                    }
                }
            }

            try
            {
                // Make sure the product view is dropped.
                setupm6();
                DropProductView();

                // Setup the product view for testing.
                setupm6();
                MSIXDef m7 = fishhook();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                while (e.InnerException != null)
                    Console.WriteLine((e = e.InnerException).Message);
                Console.WriteLine(e.StackTrace);
                throw e;
            }
        }

        [TestFixtureTearDown]
		public void TearDown()
		{
			//Console.WriteLine("teardown()...");
			DropProductView();

			// run the hook one last time to make sure t_view_hierarchy gets repopulated
			runHook();
		}

		[Test]
        public void T01AddProductView()
		{
			string me = funcname();
			tests.Remove(me);

			// setup already created the product view
			MSIXDef m7 = MSIXDef.FromDatabase(m6.name);

			// compare props against expected database values
			Assert.IsTrue(m7.ptypes.Count == m6.ptypes.Count, "Number or properties in table don't match msixdef.");

			ArrayList tested = new ArrayList();
			foreach (Ptype p in m7.ptypes)
			{
				tested.Add(p);
				switch (p.dn)
				{
					case "TestCase":
						Assert.IsTrue(p.type == (isOracle ? "NUMBER" : "int"));
						Assert.IsTrue(p.length == (isOracle ? "0" : null));
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "IntProp1":
						Assert.IsTrue(p.type == (isOracle ? "NUMBER" : "int"));
						Assert.IsTrue(p.length == (isOracle ? "0" : null));
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "IntProp1Default":
						Assert.IsTrue(p.type == (isOracle ? "NUMBER" : "int"));
						Assert.IsTrue(p.length == (isOracle ? "0" : null));
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "StringProp1":
						Assert.IsTrue(p.type == (isOracle ? "NVARCHAR2" : "nvarchar"));
						Assert.IsTrue(p.length == "1");
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "StringProp1Default":
						Assert.IsTrue(p.type == (isOracle ? "NVARCHAR2" : "nvarchar"));
						Assert.IsTrue(p.length == "1");
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "StringProp2":
						Assert.IsTrue(p.type == (isOracle ? "NVARCHAR2" : "nvarchar"));
						Assert.IsTrue(p.length == "80");
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "StringProp2Default":
						Assert.IsTrue(p.type == (isOracle ? "NVARCHAR2" : "nvarchar"));
						Assert.IsTrue(p.length == "80");
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "DecProp1":
						Assert.IsTrue(p.type == (isOracle ? "NUMBER" : "numeric"));
						Assert.IsTrue(p.length == (isOracle ? "0" : null));
						Assert.IsTrue(p.required == "N");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "DecProp1Default":
						Assert.IsTrue(p.type == (isOracle ? "NUMBER" : "numeric"));
						Assert.IsTrue(p.length == (isOracle ? "0" : null));
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "BoolProp1":
						Assert.IsTrue(p.type == (isOracle ? "CHAR" : "char"));
						Assert.IsTrue(p.length == "1");
						Assert.IsTrue(p.required == "N");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "BoolProp1Default":
						Assert.IsTrue(p.type == (isOracle ? "CHAR" : "char"));
						Assert.IsTrue(p.length == "1");
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "EnumProp1":
						Assert.IsTrue(p.type == (isOracle ? "NUMBER" : "int"));
						Assert.IsTrue(p.length == (isOracle ? "0" : null));
						Assert.IsTrue(p.required =="Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "EnumProp1Default":
						Assert.IsTrue(p.type == (isOracle ? "NUMBER" : "int"));
						Assert.IsTrue(p.length == (isOracle ? "0" : null));
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "TimestampProp1":
						Assert.IsTrue(p.type == (isOracle ? "DATE" : "datetime"));
						Assert.IsTrue(p.length == (isOracle ? "0" : null));
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					case "TimestampProp1Default":
						Assert.IsTrue(p.type == (isOracle ? "DATE" : "datetime"));
						Assert.IsTrue(p.length == (isOracle ? "0" : null));
						Assert.IsTrue(p.required == "Y");
						Assert.IsTrue(p.defaultvalue == null);
						break;
					default:
						Assert.Fail(string.Format(
							"Found unexpected property: {0}", p.dn));
						break;
				}	// end switch
			}	// end foreach ptype

			Assert.IsTrue(tested.Count >= m7.ptypes.Count, "Some properties were not created.");

		}

		[Test]
    public void T02AddDefaultValue()
		{
			string me = funcname();
			tests.Remove(me);

			Ptype p = m6.FindPtypeByName("IntProp1");
			p.defaultvalue = "6";

			MSIXDef m7 = fishhook();
			Ptype p7 = m7.FindPtypeByName("IntProp1");

			// todo: defaults not stored in database?
			//Assert.IsTrue(p7.defaultvalue == p.defaultvalue);
		}

		[Test]
    public void T03AddRequired()
		{
			string me = funcname();
			tests.Remove(me);

			// add a req property
			Ptype p = m6.AddPtype("required_int", "int32", "", "Y", "55", "gotta have it");

			MSIXDef m7 = fishhook();
			Ptype p7 = m7.FindPtypeByName("required_int");

			Assert.IsTrue(p7 != null);
			Assert.IsTrue(p7.required == "Y");
		}

		[Test]
    public void T04AddNonRequired()
		{
			string me = funcname();
			tests.Remove(me);

			// add a new non req property
			Ptype newp = m6.AddPtype( "not_required", "int32", "", "N", "55", "gotta have it");

			MSIXDef m7 = fishhook();
			Ptype p7 = m7.FindPtypeByName("not_required");

			Assert.IsTrue(p7 != null);
			Assert.IsTrue(p7.required == "N");
		}

		[Test]
    public void T05DropProperty()
		{
			string me = funcname();
			tests.Remove(me);

			// drop a property
			Ptype p = m6.FindPtypeByName("TimestampProp1");
			m6.ptypes.Remove(p);

			MSIXDef m7 = fishhook();
			Ptype p7 = m7.FindPtypeByName("TimestampProp1");

			Assert.IsTrue(p7 == null);
		}
		[Test]
    public void T06NonRequiredToRequired()
		{
			string me = funcname();
			tests.Remove(me);

			// change non-required prop to required
			Ptype p6 = m6.FindPtypeByName("BoolProp1");
			p6.required = "Y";
			p6.defaultvalue = "N";  // chg to required must have default

			MSIXDef m7 = fishhook();
			Ptype p7 = m7.FindPtypeByName("BoolProp1");

			Assert.IsTrue(p7 != null);
			Assert.IsTrue(p7.required == "Y");
		}

		[Test]
    public void T07NonReqDecToReqString()
		{
			string me = funcname();
			tests.Remove(me);

			// change a non-req decimal prop to required string
			Ptype p6 = m6.FindPtypeByName("DecProp1");
			p6.required = "Y";
			p6.defaultvalue = "2.7182818";  // chg to required must have default
			p6.type = "string";
			p6.length = "300";

			MSIXDef m7 = fishhook();
			Ptype p7 = m7.FindPtypeByName("DecProp1");

			Assert.IsTrue(p7 != null);
			Assert.IsTrue(p7.required == "Y");
			Assert.IsTrue(p7.type == (isOracle ? "NVARCHAR2" : "nvarchar"));
		}

		[Test]
    public void T08IncreaseStringLen()
		{
			string me = funcname();
			tests.Remove(me);

			// increase string length
			Ptype p6 = m6.FindPtypeByName("StringProp2");
			p6.length = "137";

			MSIXDef m7 = fishhook();
			Ptype p7 = m7.FindPtypeByName("StringProp2");

			Assert.IsTrue(p7 != null);
			Assert.IsTrue(p7.length == "137");
		}

		[Test]
    public void T09StringToEnum()
		{
			string me = funcname();
			tests.Remove(me);

			// change string to enum
			Ptype p6 = m6.FindPtypeByName("StringProp1");
			p6.type = "enum";
			p6.typeAttrib.EnumSpace = "Global";
			p6.typeAttrib.EnumType = "CountryName";

			MSIXDef m7 = fishhook();
			Ptype p7 = m7.FindPtypeByName("StringProp1");

			Assert.IsTrue(p7 != null);
			Assert.IsTrue(p7.type == (isOracle ? "NUMBER" : "int"));
		}

		[Test]
    public void T10EnumToString()
		{
			string me = funcname();
			tests.Remove(me);

			// change enum to string
			Ptype p6 = m6.FindPtypeByName("EnumProp1");
			p6.type = "string";
			//p6.typeAttrib.EnumSpace = null;
			//p6.typeAttrib.EnumType = null;

			p6.length = "606";

			MSIXDef m7 = fishhook();
			Ptype p7 = m7.FindPtypeByName("EnumProp1");

			Assert.IsTrue(p7 != null);
			Assert.IsTrue(p7.type == (isOracle ? "NVARCHAR2" : "nvarchar"));
		}

		[Test]
    public void T11AddUniqueKey()
		{
			string me = funcname();
			tests.Remove(me);

			// add a new uniquekey
			UniqueKey uk6 = new UniqueKey("dpv_newuk1", "StringProp2Default", "TestCase");
			m6.uniqueKeys.Add(uk6);

			MSIXDef m7 = fishhook();
			UniqueKey uk7 = m7.FindUniqueKeyByName("dpv_newuk1");

			Assert.IsTrue(uk7 != null);
			Assert.IsTrue(uk6.Equals(uk7));
		}

		[Test]
    public void T12DropUniqueKey()
		{
			string me = funcname();
			tests.Remove(me);

			// drop a unique key
			m6.uniqueKeys.Remove(m6.FindUniqueKeyByName("dpv_uk1"));

			MSIXDef m7 = fishhook();
			UniqueKey p7 = m7.FindUniqueKeyByName("dpv_uk1");

			Assert.IsTrue(p7 == null);
		}
		
		[Test]
    public void T13ChangeUniqueKey()
		{
			string me = funcname();
			tests.Remove(me);

			// change unique key columns; cause a drop-add operation
			UniqueKey uk6 = m6.FindUniqueKeyByName("dpv_uk2");
			uk6.cols.RemoveAt(0);  // remove first element

			MSIXDef m7 = fishhook();
			UniqueKey uk7 = m7.FindUniqueKeyByName("dpv_uk2");

			Assert.IsTrue(uk6.Equals(uk7));
		}

	    [Test]
	    public void T14ChangePropertyTypeWithDependentKey()
	    {
	        string me = funcname();
	        tests.Remove(me);

	        // change type of a property that has a dependent key; must fail
	        Ptype p6 = m6.FindPtypeByName("DecProp1Default");
	        p6.type = "string";
	        p6.length = "200";

	        Exception savedex = null;
	        try
	        {
	            // fire in the hole!
	            MSIXDef m7 = fishhook();
	        }
	        catch (ApplicationException ex)
	        {
	            savedex = ex;
	        }

	        MSIXDef def = MSIXDef.FromDatabase(m6name);
	        p6 = m6.FindPtypeByName("DecProp1Default");

	        Assert.IsNotNull(p6); // property is still there
	        Assert.IsNotNull(savedex); // exception really happened

	    }

	    [Test]
    public void T15DropPropertyWithDependentKey()
		{
            string me = funcname();
            tests.Remove(me);

            // drop a property that has a dependent key; must fail
            Ptype p6 = m6.FindPtypeByName("DecProp1Default");
            m6.ptypes.Remove(p6);

            Exception savedex = null;
            try 
            {
                // fire in the hole!
                MSIXDef m7 = fishhook();
            }
            catch (Exception ex)
            {
                savedex = ex;
            }

            MSIXDef def = MSIXDef.FromDatabase(m6name);
            Ptype decprop1 = def.FindPtypeByName("DecProp1Default");

            Assert.IsNotNull(decprop1);  // property is still there
            Assert.IsNotNull(savedex);  // exception really happened
		}
 
        // Call by dtor to clear out the test product view
	    public void DropProductView()
	    {
	        try
	        {
	            partOps.Init(mLog);

	            try
	            {
	                ukOps.Init(mLog, defPath);
	            }
	            catch (ApplicationException e)
	            {
	                Console.WriteLine(e.Message);
	            }

	            // delete msixdef file
	            if (File.Exists(defPath))
	                File.Delete(defPath);

	            // deploy product view currently doesn't detect deleted msixdefs
	            //runHook();

	            //MSIXDef m7 = MSIXDef.FromDatabase(m6.name);

	            using (IMTServicedConnection conn =
	                ConnectionManager.CreateConnection())
	            {

	                // drop the unique key tables
	                if (partOps.UseUkTables)
	                    partOps.DropUniqueKeyTables(m6.uniqueKeys, conn);

	                // drop the product view tables
	                using (
	                    IMTAdapterStatement droptable = conn.CreateAdapterStatement("queries\\ProductView",
	                                                                              "__DROP_PRODUCT_VIEW_TABLE__"))
	                {
                        droptable.AddParam("%%PRODUCT_VIEW_NAME%%", m6.PVTableName);
                        droptable.ExecuteNonQuery();
	                }

	                // delete the metadata
	                using (IMTCallableStatement delmeta =
	                    conn.CreateCallableStatement("DeleteProductViewMetadata"))
	                {
	                    delmeta.AddParam("tabname", MTParameterType.String, m6.PVTableName);
	                    delmeta.ExecuteNonQuery();
	                }

	                //conn.CommitTransaction();
	            }
	        }
	        catch (Exception e)
	        {
	            Console.WriteLine("Drop Product View Table: " + e.Message);
	        }
	    }


	    #region dpvunittest.msixdef
		const string testPropsXml = @"
<defineservice>
	<name>metratech.com/dpvunittest</name>
	<description>Basis for testing several aspects of the product view hook.</description>
	<ptype>
		<dn>TestCase</dn>
		<type>int32</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>The specific case that was tested</description>
	</ptype>
	<ptype>
		<dn>IntProp1</dn>
		<type>int32</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test integer property</description>
	</ptype>
	<ptype>
		<dn>IntProp1Default</dn>
		<type>int32</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test default integer property</description>
	</ptype>
	<ptype>
		<dn>StringProp1</dn>
		<type>string</type>
		<length>1</length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test string property (tiny)</description>
	</ptype>
	<ptype>
		<dn>StringProp1Default</dn>
		<type>string</type>
		<length>1</length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test default string property (tiny)</description>
	</ptype>
	<ptype>
		<dn>StringProp2</dn>
		<type>string</type>
		<length>80</length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test string property</description>
	</ptype>
	<ptype>
		<dn>StringProp2Default</dn>
		<type>string</type>
		<length>80</length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test default string property</description>
	</ptype>
	<ptype>
		<dn>DecProp1</dn>
		<type>DECIMAL</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test decimal property</description>
	</ptype>
	<ptype>
		<dn>DecProp1Default</dn>
		<type>DECIMAL</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test default decimal property</description>
	</ptype>
	<ptype>
		<dn>DoubleProp1</dn>
		<type>double</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test double property</description>
	</ptype>
	<ptype>
		<dn>DoubleProp1Default</dn>
		<type>double</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test defaultdouble property</description>
	</ptype>
	<ptype>
		<dn>BoolProp1</dn>
		<type>boolean</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test boolean property</description>
	</ptype>
	<ptype>
		<dn>BoolProp1Default</dn>
		<type>boolean</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test default boolean property</description>
	</ptype>
	<ptype>
		<dn>EnumProp1</dn>
		<type EnumSpace=""Global"" EnumType=""CountryName"">enum</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test enum property</description>
	</ptype>
	<ptype>
		<dn>EnumProp1Default</dn>
		<type EnumSpace=""Global"" EnumType=""CountryName"">enum</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test default enum property</description>
	</ptype>
	<ptype>
		<dn>TimestampProp1</dn>
		<type>timestamp</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test timestamp property</description>
	</ptype>
	<ptype>
		<dn>TimestampProp1Default</dn>
		<type>timestamp</type>
		<length></length>
		<required>Y</required>
		<defaultvalue></defaultvalue>
		<description>Test default timestamp property</description>
	</ptype>
</defineservice>
";
		#endregion sample msixdef
	}
}