/**************************************************************************
 * CMTPathRegEx
 *
 * Copyright 1997-2000 by MetraTech Corp.
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Boris Partensky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <StdAfx.h>
#include <iostream>
#include "../PathRegEx.h"

using std::cout;
using std::endl;

int main(int argc, char* argv[])
{
	cout << "Testing non-case sensitive" << endl;
	CMTPathRegEx ex0("/metratech/engineering/Core/-");
	CMTPathRegEx ex1("/metratech/engineering/Core/*");
	CMTPathRegEx ex2("/metratech/-");
	CMTPathRegEx ex3("/metratech/engineering/*");
	CMTPathRegEx ex4("/metratech/engineering");
	CMTPathRegEx ex5("/metratech/engineering/Core/Raju");
	CMTPathRegEx ex6("/metratech");
	
	bool match = ex0.Implies(ex5);
	match = ex1.Implies(ex5);
	match = ex2.Implies(ex5);
	match = ex3.Implies(ex5);
	match = ex4.Implies(ex5);
	match = ex5.Implies(ex5);
	match = ex6.Implies(ex5);
	
	return 0;
}

