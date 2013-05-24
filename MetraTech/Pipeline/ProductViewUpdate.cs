namespace MetraTech.Pipeline
{
	using System;
	using System.Collections;
	using System.Runtime.InteropServices;
	using System.EnterpriseServices;

	using MetraTech.Interop.MTProductViewExec;

  [Guid("8e0f3e15-2fad-4e42-881f-d5ede1257628")]
  [InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIDispatch)]
	public interface IProductViewUpdate
	{
		void DiffAndUpdate(MetraTech.Interop.MTProductViewExec.IMTSessionContext apCTX, 
											 MetraTech.Interop.MTProductViewExec.IProductView before, 
											 MetraTech.Interop.MTProductViewExec.IProductView after);
	}

	[ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("82e5eb16-720a-4915-a9b2-088fae8a7e2a")]
	public class ProductViewUpdate : ServicedComponent, IProductViewUpdate
	{
		[AutoComplete]
		public void DiffAndUpdate(MetraTech.Interop.MTProductViewExec.IMTSessionContext apCTX, 
															MetraTech.Interop.MTProductViewExec.IProductView before, 
															MetraTech.Interop.MTProductViewExec.IProductView after)
		{
			IMTProductViewWriter w = new MTProductViewWriter();
			// Update the product view itself by setting the database ID
			after.ID = before.ID;
			w.Update(apCTX, after);
			// Do a changed data capture on the set of properties
			ArrayList deleteMe = new ArrayList();
			ArrayList updateMe = new ArrayList();
			ArrayList insertMe = new ArrayList();

			// Initially assume that all old properties are deleted.
			// As they are matched with a new property, convert them to updates.
			foreach(MetraTech.Interop.MTProductViewExec.IProductViewProperty prop in before.GetProperties())
			{
				deleteMe.Add(prop);
			}

			foreach(MetraTech.Interop.MTProductViewExec.IProductViewProperty prop1 in after.GetProperties())
			{
				MetraTech.Interop.MTProductViewExec.IProductViewProperty match = null;
				foreach(MetraTech.Interop.MTProductViewExec.IProductViewProperty prop2 in deleteMe)
				{
					if(prop1.DN.Equals(prop2.DN))
					{
						match = prop2;
						break;
					}
				}

				if(match != null)
				{
					deleteMe.Remove(match);
					prop1.ID = match.ID;
					prop1.ProductViewID = match.ProductViewID;
					updateMe.Add(prop1);
				}
				else
				{
					prop1.ProductViewID = before.ID;
					insertMe.Add(prop1);
				}
			}

			// Invoke the update operations
			foreach(MetraTech.Interop.MTProductViewExec.IProductViewProperty prop in deleteMe)
			{
				new MTProductViewPropertyWriter().Remove(apCTX, prop.ID);
			}
			foreach(MetraTech.Interop.MTProductViewExec.IProductViewProperty prop in updateMe)
			{
				new MTProductViewPropertyWriter().Update(apCTX, prop);
			}
			foreach(MetraTech.Interop.MTProductViewExec.IProductViewProperty prop in insertMe)
			{
				new MTProductViewPropertyWriter().Create(apCTX, prop);
			}
		}
	}
}
