using System;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;
using System.Reflection.Emit;
using Auth.Capabilities;
using Auth.SecurityFramework;
using Auth.Principals;
using System.Runtime.InteropServices;
using System.Collections;


namespace AuthTest
{
	class Run
	{
		static void Main(string[] args)
		{

			//populate available capability classes into db
			//Auth deployment hook will do it from XML file
			SqlConnection netmeter = new SqlConnection("Data Source=eng-6;" +
				"Initial Catalog=netmeter;User ID=nmdbo;Password=nmdbo");
			netmeter.Open();
			SqlCommand command = netmeter.CreateCommand();

			ArrayList allcaps = new ArrayList();
			CompositeCapability cap = new AllCapability();

			cap.Description = "this is a super user capability, it impilies all others.";
			cap.Editor = "GenericEditor.asp";
			

			//cap.
			allcaps.Add(cap);

			cap = new ManageAHCapability();

			cap.Description = "Composite capability, please specify access type (READ or WRITE) and Sub-hierarchy the principal will be able to manage";
			cap.Editor = "GenericEditor.asp";

			allcaps.Add(cap);

			cap = new IssueCreditCapability();

			cap.Description = "Composite capability, please specify access type, Path and limit on the credit amount";
			cap.Editor = "GenericEditor.asp";

			allcaps.Add(cap);

			command.CommandText = "TRUNCATE table t_capability_class";
			command.ExecuteNonQuery();
			IEnumerator en = allcaps.GetEnumerator();

			while(en.MoveNext())
			{
				CompositeCapability c = (CompositeCapability)en.Current;
				string query = "INSERT INTO t_capability_class VALUES(";
				query += "'" + c.GetType().ToString() + "'";
				query += ", '" + c.Description + "', '" + c.Editor + "')";
				command.CommandText = query;
				command.ExecuteNonQuery();
			}

			//load all available system capabilities
			//MAM will use this method in Add/Remove capabilities screen
			SecurityPolicy policy = new SecurityPolicy();

			en = policy.GetSystemCapabilities();

			while(en.MoveNext())
			{
				CompositeCapability syscap = (CompositeCapability)en.Current;
			}

			//create role
			Role scsr = new Role();
			scsr.Name = "SeniorCSR";
			scsr.Description = "Big cheese, can manage all Metratech hierarchy and issue unlimited credits";
			int id = scsr.Save();

			//create manage AH capability and grant it to SeniorCSR
			ManageAHCapability mahcap = new ManageAHCapability();
			mahcap.AddPathParameter("/metratech/*");
			mahcap.SetAccessType(AccessType.WRITE);

			policy.GrantCapability(scsr, mahcap);

			policy.GrantRole(123, scsr);

			IEnumerator roles = policy.GetRoles();

			while(roles.MoveNext())
			{
				Role role = (Role)roles.Current;
				string name = role.Name;
				string desc = role.Description;

				IEnumerator caps = role.Capabilities;

				while (caps.MoveNext())
				{
					CompositeCapability rolecap = (CompositeCapability)caps.Current;
					
				}
			}

			LoginContext loginctx = new LoginContext();
			SecurityContext ctx = loginctx.login("demo", "mt");

			//test - demand different capabilities
			ManageAHCapability mahcap0 = new ManageAHCapability();
			mahcap.SetAccessType(AccessType.READ);
			mahcap.AddPathParameter("/metratech/core/raju");

			//test - demand different capabilities
			ManageAHCapability mahcap1 = new ManageAHCapability();
			mahcap.SetAccessType(AccessType.READWRITE);
			mahcap.AddPathParameter("/metratech/core/raju");

			//test - demand different capabilities
			ManageAHCapability mahcap2 = new ManageAHCapability();
			mahcap.SetAccessType(AccessType.READ);
			mahcap.AddPathParameter("/bellca/madman");


			AllCapability allcap = new AllCapability();


			//should succeed
			bool match = ctx.CheckAccess(mahcap0);
			//should fail
			match = ctx.CheckAccess(mahcap1);
			//should fail
			match = ctx.CheckAccess(mahcap2);

			

			



			
		}
	}
}