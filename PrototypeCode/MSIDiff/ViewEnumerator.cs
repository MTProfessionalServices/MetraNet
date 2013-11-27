using System;
using System.Diagnostics;
using System.Collections;

using Interop.msi;

namespace MSIDiff
{
	public class ViewHolder : IDisposable, IEnumerable
	{
		private View m_view;

		public ViewHolder( View view )
		{
			Debug.Assert( view != null );
			m_view = view;
		}

		public int GetRecordCount()
		{
			int i = 0;

			m_view.Close();
			m_view.Execute( null );

			while ( m_view.Fetch() != null )
				i++;
			
			return i;
		}

		public void Dispose()
		{
			m_view.Close();
		}
		
		public IEnumerator GetEnumerator()
		{
			return new ViewEnumerator( this.m_view );
		}
	}

	/// <summary>
	/// Summary description for ViewEnumerator.
	/// </summary>
	public class ViewEnumerator : IEnumerator
	{
		private View m_view;
		private object m_current;

		public ViewEnumerator( View view )
		{
			m_view = view;
			m_view.Close();
			m_view.Execute( null );
		}

		public void Reset()
		{
			throw new InvalidOperationException();
		}

		public object Current
		{
			get
			{
				return m_current;
			}
		}

		public bool MoveNext()
		{
			m_current = m_view.Fetch();			
			return m_current != null;
		}
	}
}
