
#include <string>
#include <iostream>
#include "test.h"

using std::cout;
using std::endl;


int mangle(string &s)
{
  
  s.assign("arf");

  return 0;
}


int main(int argc, char *argv[], char *envp[])
{
  string stest;
  yow		 gonk;
  foo<yow> blork;
  int    x;

  stest.erase();

  x = blork.FooGet();

  stest = "puke";

  cout << stest << endl;

  gonk.Get() = "block";

  gonk.Get() = "ck";

  gonk.Get() = "blockkkkkkkkkkkkkkkkk";

  mangle(stest);

  cout << stest << endl;

  stest.assign("gak.");

  cout << stest << endl;

  return 0;
}
  
