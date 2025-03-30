#include <stdio.h>

extern int add(int a, int b, int c);
extern int sub(int a, int b);

int main(int argc, char **argv)
{
  printf("%d\n", add(4, 6, 8));
  printf("%d\n", sub(10,5));
  return 0;
}
