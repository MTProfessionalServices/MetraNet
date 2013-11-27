#include <MTUtil.h>
#include <string>
using namespace std;

void printDate(MTDate& date) {
	cout << date.GetMonth() << "/"
			 << date.GetDay()   << "/"
		   << date.GetYear()  << " ("
			 << date.GetWeekdayName() << ")";
}

void main() {
	
	//****************************
	//CONSTRUCTOR TEST
	//****************************
	cout << "--- CONSTRUCTOR TEST ---" << endl;
	MTDate c1(MTDate::TODAY);
	cout << " current date        == ";
	printDate(c1);
	cout << endl;

	MTDate c2(9, 1, 1980);
	cout << " 9/1/1980 (Monday)   == ";
	printDate(c2);
	cout << endl;

	string dateStr = "1/10/1978";
	MTDate c3(dateStr);
	cout << " 1/10/1978 (Tuesday) == ";
	printDate(c3);
	cout << endl;

	//****************************
	//ACCESSOR TEST
	//****************************
	cout << "\n--- ACCESSOR TEST ---\n ";
	MTDate a(9, 28, 2000);
	printDate(a);
	cout << endl;

	cout << " GetMonth():       9             == " << a.GetMonth() << endl;
	cout << " GetMonthName():   September     == " << a.GetMonthName() << endl;
	cout << " GetDay():         28            == " << a.GetDay() << endl;
	cout << " GetWeekdayName(): 5             == " << a.GetWeekday() << endl;
	cout << " GetWeekdayName(): Thursday      == " << a.GetWeekdayName() << endl;
	cout << " GetYear():        2000          == " << a.GetYear() << endl;
	cout << " GetDaysInMonth(): 30            == " << a.GetDaysInMonth() << endl;
	cout << " IsLeap():         true          == " << (a.IsLeap() ? "true" : "false") << endl;
	
	string str;
	int count = a.ToString("%m/%d/%Y", str);
	cout << " ToString():       09/28/2000 10 == " << str.c_str() << " " << count << endl;

	//****************************
	//MUTATOR TEST
	//****************************
	cout << endl << "--- MUTATOR TEST ---" << endl;
	MTDate m(9, 28, 2000);
//	printDate(m);
//	cout << endl;
	m.AddDay(15);
	cout << " 10/13/2000 (Friday)   == ";
	printDate(m);
	cout << endl;
	

	//tests for DST back to standard time transition
	m.SetDate(MTDate::OCTOBER, 17, 2000);
	m.AddDay(13);
	cout << " 10/30/2000 (Monday)   == ";
	printDate(m);
	cout << endl;

	//TODO: tests for standard time to DST transition

	m.SetDate(MTDate::SEPTEMBER, MTDate::END_OF_MONTH, 2000);
	cout << " 9/30/2000 (Saturday)  == ";
	printDate(m);
	cout << endl;

	//TODO: test mutator SetDate(DATE&)

	m.AddMonth(7);
	cout << " 4/30/2001 (Monday)    == ";
	printDate(m);
	cout << endl;

	m.SubtractMonth(7);
	cout << " 9/30/2000 (Saturday)  == ";
	printDate(m);
	cout << endl;

	m.AddYear(5);
	cout << " 9/30/2005 (Friday)    == ";
	printDate(m);
	cout << endl;

	m.SetDate(9, 28, 2000);
	m.NextWeekday(MTDate::MONDAY);
	cout << " 10/2/2000 (Monday)    == ";
	printDate(m);
	cout << endl;

	m.SetDate(9, 28, 2000);
	m.NextWeekday(2);
	cout << " 10/2/2000 (Monday)    == ";
	printDate(m);
	cout << endl;

	m.SetDate(9, 28, 2000);
	m.NextWeekday(MTDate::SATURDAY);
	cout << " 9/30/2000 (Saturday)  == ";
	printDate(m);
	cout << endl;

	m.SetDate(9, 28, 2000);
	m.SetDay(15);
	cout << " 9/15/2000 (Friday)    == ";
	printDate(m);
	cout << endl;

	m.SetDate(9, 28, 2000);
	m.SetMonth(10);
	cout << " 10/28/2000 (Saturday) == ";
	printDate(m);
	cout << endl;

	m.SetDate(9, 28, 2000);
	m.SetYear(2005);
	cout << " 9/28/2005 (Wednesday) == ";
	printDate(m);
	cout << endl;

	//****************************
	//OPERATOR TEST
	//****************************
	cout << endl << "--- OPERATOR TEST ---" << endl;
	MTDate op1(9, 28, 2000);
	MTDate op2(9, 29, 2000);

	op1.AddDay(1);
	cout << " true  == " << ((op1 == op2) ? "true" : "false");
	cout << endl;

	op1.AddDay(1);
	cout << " false == " << ((op1 == op2) ? "true" : "false");
	cout << endl;

	op1.SetDate(3, 15, 2000);
	op2.SetDate(4, 15, 2000);
	cout << " false == " << ((op1 > op2) ? "true" : "false");
	cout << endl;

	cout << " false == " << ((op1 >= op2) ? "true" : "false");
	cout << endl;

	cout << " true  == " << ((op1 < op2) ? "true" : "false");
	cout << endl;

	cout << " true  == " << ((op1 <= op2) ? "true" : "false");
	cout << endl;
	
	op1.SetDate(4, 15, 2000);
	op2.SetDate(4, 15, 2000);

	cout << " false == " << ((op1 > op2) ? "true" : "false");
	cout << endl;

	cout << " true  == " << ((op1 >= op2) ? "true" : "false");
	cout << endl;

	cout << " false == " << ((op1 < op2) ? "true" : "false");
	cout << endl;

	cout << " true  == " << ((op1 <= op2) ? "true" : "false");
	cout << endl;

	MTDate op3(10,1,2000);
	MTDate op4;

	op4 = op3 + 6;
	cout << " 10/7/2000 (Saturday)  == ";
	printDate(op4);
	cout << endl;

	op4 = op4 - 6;
	cout << " 10/1/2000 (Sunday)    == ";
	printDate(op4);
	cout << endl;
	
	op4 += 6;
	cout << " 10/7/2000 (Saturday)  == ";
	printDate(op4);
	cout << endl;

	op4 -= 6;
	cout << " 10/1/2000 (Sunday)    == ";
	printDate(op4);
	cout << endl;

	op4.SetDate(10,1,2000);
	op4++;
	cout << " 10/2/2000 (Monday)    == ";
	printDate(op4);
	cout << endl;

	op4--;
	cout << " 10/1/2000 (Sunday)    == ";
	printDate(op4);
	cout << endl;


	//****************************
	//OLE DATE TEST
	//****************************
	cout << endl << "--- OLE DATE TEST ---" << endl;
	DATE testDATE;
	MTDate ole1(11, 10, 2000);
	ole1.GetOLEDate(&testDATE);
	MTDate ole2(testDATE);
	MTDate ole3 = testDATE;
	
	cout << " 11/10/2000 (Friday)    == ";
	printDate(ole1);
	cout << endl;
	cout << " 11/10/2000 (Friday)    == ";
	printDate(ole2);
	cout << endl;
	cout << " 11/10/2000 (Friday)    == ";
	printDate(ole3);
	cout << endl;

	//****************************
	//LEAP YEAR TEST
	//****************************
	cout << endl << "--- LEAP YEAR TEST ---" << endl;
	MTDate ly(2,24,2000);

	ly.AddDay(5);
	cout << " 2/29/2000 (Tuesday)  == ";
	printDate(ly);
	cout << endl;

	ly.AddDay(1);
	cout << " 3/1/2000 (Wednesday) == ";
	printDate(ly);
	cout << endl;

	ly.SetDate(2,24,1999);
	ly.AddDay(5);
	cout << " 3/1/1999 (Monday)    == ";
	printDate(ly);
	cout << endl;

	ly.SubtractDay(1);
	cout << " 2/28/1999 (Sunday)   == ";
	printDate(ly);
	cout << endl;

	ly.SetDate(2,24, 2004);
	ly.AddDay(5);
	cout << " 2/29/2004 (Sunday)   == ";
	printDate(ly);
	cout << endl;


	//
	//BIWEEKLY TEST
	//
	cout << endl << "--- BIWEEKLY TEST ---" << endl;
	MTDate cycle8(1,9,2000);

	MTDate reference(1, 1, 2000);
	MTDate startDate; //(4,2,2000);

	long startTime;
	long referenceTime = reference.GetSecondsSinceEpoch();
	long diff;
	long oldDiff = 0;
	long cycle;

	for (int i= 0; i < 26; i++) {
		cout << i << ": ";
		printDate(cycle8);


		startDate = cycle8;

		startTime      = startDate.GetSecondsSinceEpoch();
		diff           = startTime - referenceTime;
		cycle          = ((diff / MTDate::SECONDS_IN_DAY) % 14) + 1;  //1 - 14
		cout << " diff: " << diff << " cycle: " << cycle << " delta: " << diff - oldDiff;
		cout << endl;

		oldDiff = diff;
		cycle8.AddDay(14);
	}
		

}
