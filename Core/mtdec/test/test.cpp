/**************************************************************************
 * TEST
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#include <MTDec.h>

#include <iostream>

using std::string;
using std::cout;
using std::endl;

class MTDecimalTest
{

public:
	BOOL SimpleTest();

};

BOOL MTDecimalTest::SimpleTest()
{
	MTDecimal val1;
	MTDecimal val2;
	MTDecimal val3;
	MTDecimal val4;

	//
	// test SetValue and comparisions
	//
	cout << "----- SetValue test" << endl;
	val1.SetValue(1234, 5000000000);
	if (val1 != 1234.5)
	{
		cout << "SetValue failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}

	val1.SetValue(-1234, 5000000000);
	if (val1 != -1234.5)
	{
		cout << "SetValue failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}

	val1.SetValue("3.14159");
	if (val1 != 3.14159)
	{
		cout << "SetValue failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}

	if (val1.SetValue("la la la di da")) //should return false
	{
		cout << "SetValue failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}

	//
	// multiplication test
	//
	cout << "----- Multiplication test" << endl;
	val1.SetValue(10);
	val2.SetValue(20);

	cout << "Val1 = " << val1.Format().c_str() << endl;
	cout << "Val2 = " << val2.Format().c_str() << endl;

	val3 = val1 * val2;

	cout << "Result = " << val3.Format().c_str() << endl;

	if (val3 != 200.0)
	{
		cout << "Failure: val3 = " << val3.Format().c_str() << endl;
		return FALSE;
	}

	val1.SetValue(100);
	val2.SetValue(-200);

	cout << "Val1 = " << val1.Format().c_str() << endl;
	cout << "Val2 = " << val2.Format().c_str() << endl;

	val3 = val1 * val2;

	cout << "Result = " << val3.Format().c_str() << endl;

	if (val3 != -20000.0)
	{
		cout << "Failure: val3 = " << val3.Format().c_str() << endl;
		return FALSE;
	}

	//
	// division test
	//
	cout << "----- Division test" << endl;
	val1.SetValue(80779, 8533760000);
	val2.SetValue(  654, 3210000000);
	cout << "Val1 = " << val1.Format().c_str() << endl;
	cout << "Val2 = " << val2.Format().c_str() << endl;

	// 123.456
	// 654.321
	//      .000000
	// 80779.853376

	val3 = val1 / val2;

	cout << "Result = " << val3.Format().c_str() << endl;

	val4.SetValue(123, 4560000000);

	if (val3 != val4)
	{
		cout << "Failure: val3 = " << val3.Format().c_str() << endl;
		return FALSE;
	}

	val1.SetValue(80779, 8533760000);
	val2.SetValue( -654, 3210000000);
	cout << "Val1 = " << val1.Format().c_str() << endl;
	cout << "Val2 = " << val2.Format().c_str() << endl;

	val3 = val1 / val2;

	cout << "Result = " << val3.Format().c_str() << endl;

	val4.SetValue(-123, 4560000000);

	if (val3 != val4)
	{
		cout << "Failure: val3 = " << val3.Format().c_str() << endl;
		return FALSE;
	}

	//
	// addition test
	//
	cout << "----- Addition test" << endl;
	// 1973.4862 + 14789.63214 = 16763.11834
	val1.SetValue( 1973, 4862000000);
	val2.SetValue(14789, 6321400000);
	cout << "Val1 = " << val1.Format().c_str() << endl;
	cout << "Val2 = " << val2.Format().c_str() << endl;

	val3 = val1 + val2;
	cout << "Result = " << val3.Format().c_str() << endl;

	val4.SetValue(16763, 1183400000);

	if (val3 != val4)
	{
		cout << "Failure: val3 = " << val3.Format().c_str() << endl;
		return FALSE;
	}

	//
	// subtraction test
	//
	cout << "----- Subtraction test" << endl;
	// 16763.11834 - 1973.4862 = 14789.63214
	val1.SetValue(16763, 1183400000);
	val2.SetValue( 1973, 4862000000);
	cout << "Val1 = " << val1.Format().c_str() << endl;
	cout << "Val2 = " << val2.Format().c_str() << endl;

	val3 = val1 - val2;
	cout << "Result = " << val3.Format().c_str() << endl;

	val4.SetValue(14789, 6321400000);

	if (val3 != val4)
	{
		cout << "Failure: val3 = " << val3.Format().c_str() << endl;
		return FALSE;
	}

	//
	// decimal comparison test
	//
	cout << "----- Decimal comparison test" << endl;
	// 16763.11834 - 1973.4862 = 14789.63214
	val1.SetValue(16763, 1183405531);
	val2.SetValue( 1973, 4862006642);
	cout << "Val1 = " << val1.Format().c_str() << endl;
	cout << "Val2 = " << val2.Format().c_str() << endl;

	if (val1 == val2)
	{
		cout << "Failure for equality" << endl;
		return FALSE;
	}

	if (!(val1 != val2))
	{
		cout << "Failure for inequality" << endl;
		return FALSE;
	}

	if (val1 < val2)
	{
		cout << "Failure for <" << endl;
		return FALSE;
	}

	if (!(val1 > val2))
	{
		cout << "Failure for >" << endl;
		return FALSE;
	}

	if (!(val1 >= val2))
	{
		cout << "Failure for >=" << endl;
		return FALSE;
	}

	if (val1 <= val2)
	{
		cout << "Failure for <=" << endl;
		return FALSE;
	}

	if (!(val1 >= val1))
	{
		cout << "Failure for >=" << endl;
		return FALSE;
	}

	if (!(val1 <= val1))
	{
		cout << "Failure for <=" << endl;
		return FALSE;
	}


	//
	// format test
	//
	cout << "----- Format test" << endl;
	val1.SetValue(1);
	val2.SetValue(3, 1415906780);
	val3.SetValue(1000000000);
	cout << "Val1 = " << val1.Format().c_str() << endl;
	cout << "Val2 = " << val2.Format(3).c_str() << endl;
	cout << "Val2 = " << val2.Format(2).c_str() << endl;
	cout << "Val3 = " << val3.Format(2, TRUE).c_str() << endl;

	//
	// math function test
	//
	cout << "----- Math function test" << endl;
	val1.SetValue(1, 4650006789);
	val2.SetValue(3, 1415902234);

	val1.Floor();
	if (val1 != 1.0) {
		cout << "Floor failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}
	cout << "Val1 = " << val1.Format().c_str() << endl;

	val2.Round(1);
	if (val2 != 3.1) {
		cout << "Round failure: val2 = " << val2.Format().c_str() << endl;
		return FALSE;
	}
	cout << "Val2 = " << val2.Format().c_str() << endl;

	
	val1.SetValue(1, 4650000000);
	val2.SetValue(3, 1415906789);
	val3 = MTDecimal::Min(val1, val2);
	val4 = MTDecimal::Min(val2, val1);
	if ((val3 != val4) || (val3 != val1)) {
		cout << "Min failure: val1 = " << val1.Format().c_str() << endl;
		cout << "             val2 = " << val2.Format().c_str() << endl;
		cout << "             val3 = " << val3.Format().c_str() << endl;
		cout << "             val4 = " << val4.Format().c_str() << endl;
		return FALSE;
	}
	cout << "Val3 = " << val3.Format().c_str() << endl;

	val1.SetValue(100, 1234006789);
	val2.SetValue(3, 1415900000);
	val3 = MTDecimal::Max(val1, val2);
	val4 = MTDecimal::Max(val2, val1);
	if ((val3 != val4) || (val3 != val1)) {
		cout << "Max failure: val1 = " << val1.Format().c_str() << endl;
		cout << "             val2 = " << val2.Format().c_str() << endl;
		cout << "             val3 = " << val3.Format().c_str() << endl;
		cout << "             val4 = " << val4.Format().c_str() << endl;
		return FALSE;
	}
	cout << "Val3 = " << val3.Format().c_str() << endl;

  cout << "testing Abs()" << endl;
  val1.SetValue(-2, 1234567809);
  val2 = val1.Abs();
  val3.SetValue(99999, 1234567809);
  val4 = val3.Abs();
  if ((val1 != -val2) || val3 != val4) {
		cout << "Abs failure: val1 = " << val1.Format().c_str() << endl;
		cout << "             val2 = " << val2.Format().c_str() << endl;
    cout << "             val3 = " << val3.Format().c_str() << endl;
		cout << "             val4 = " << val4.Format().c_str() << endl;
		return FALSE;
	}

	cout << "Val1 = " << val1.Format().c_str() << endl;
  cout << "Val2 = " << val2.Format().c_str() << endl;
  cout << "Val3 = " << val3.Format().c_str() << endl;
  cout << "Val4 = " << val4.Format().c_str() << endl;


	
	//
	// misc test
	//
	cout << "----- Misc test" << endl;
	val1 = 5;
	val1 = MTDecimal::ZERO;

	if (val1 != 0.0) {
		cout << "Assignment failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}
	cout << "Val1 = " << val1.Format().c_str() << endl;

	
	//
	// big value aUnits test
	// Can only test up to 15 significant digits in aUnits
	// because of the range of type double (used in the != comparison below).
	cout << "----- big value aUnits test" << endl;
//	val1.SetValue(/*911*/ 5554443332221110);
//	if (val1 !=   /*911*/ 5554443332221110) {  //SUCCESS
//	val1.SetValue(/*911*/ 5554443332221111);
//	if (val1 !=   /*911*/ 5554443332221111) {  //FAILS
	val1.SetValue(/*911*/   9999999999999990);
	if (val1 !=   /*911*/   9999999999999990) {  //SUCCESS
		cout << "Assignment failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}
	cout << "Val1 = " << val1.Format().c_str() << endl;

  
	//
	// only aFrac test
	cout << "----- only aFrac test" << endl;
	val1.SetValue(0, 5000000000);
	if (val1 !=    0.5) {  //SUCCESS
		cout << "Assignment failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}
	cout << "Val1 = " << val1.Format().c_str() << endl;

  
	//
	// big value aUnits/aFrac test
	// aFrac can only have 10 digits, or else assertion in mtdec.cpp will fail.
	// Can only test up to 15 significant digits across aUnits and aFrac
	// because of the range of type double (used in the != comparison below).
	cout << "----- big value aUnits/aFrac test" << endl;
	val1.SetValue(99999999999999,9000000000);
	if (val1 !=   99999999999999.90) {  //SUCCESS
		cout << "Assignment failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}
	cout << "Val1 = " << val1.Format().c_str() << endl;
//	val1.SetValue(99999999999999,9100000000);
//	if (val1 !=   99999999999999.91) {  //FAILS
//	val1.SetValue( 9999999999999,9100000000);
//	if (val1 !=    9999999999999.910) {  //SUCCESS
//	val1.SetValue( 9999,98765432018);
//	if (val1 !=    9999.98765432018) {  //FAILED ASSERTION (too many decimal digits)
	val1.SetValue( 99999,9876543201);
	if (val1 !=    99999.9876543201) {  //SUCCESS
		cout << "Assignment failure: val1 = " << val1.Format().c_str() << endl;
		return FALSE;
	}
	cout << "Val1 = " << val1.Format().c_str() << endl;


  return TRUE;
}

int main(int argc, char * argv[])
{
	MTDecimalTest test;
	if (!test.SimpleTest())
	{
		cout << "Test FAILED" << endl;
		return -1;
	}
	else
	{
		cout << "Test PASSED" << endl;
		return 0;
	}
}
