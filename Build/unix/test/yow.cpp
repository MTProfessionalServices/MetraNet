#include "test.h"

yow::yow(void) : yikes("foo")
{
  yikes.erase();
}

yow::~yow(void)
{
  yikes.erase();
}


string & yow::Get()
{
  return yikes;
}
