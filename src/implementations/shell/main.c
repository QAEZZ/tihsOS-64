#include "print.h"
#include "shell.h"
#include "keyboardio.h"
#include "char.h"
#include <stdio.h>

#define MAX_COMMAND_LENGTH 1000

void prompt()
{
  print("\n$ ");
  // char user_input[MAX_COMMAND_LENGTH];
  // scanf("%[^\n]%*c", user_input);
  // print("You said: ");
  // print(user_input);
}

uint8_t inb(uint16_t port)
{
  uint8_t ret;
  asm volatile("inb %1, %0"
               : "=a"(ret)
               : "d"(port));
  return ret;
}

void outb(uint16_t port, uint8_t data)
{
  asm volatile("outb %0, %1"
               : "=a"(data)
               : "d"(port));
}

char get_input_keycode()
{
  char ch = 0;
  while ((ch = inb(KEYBOARD_PORT)) != 0)
  {
    if (ch > 0)
      return ch;
  }
  return ch;
}

/*
keep the cpu busy for doing nothing(nop)
so that io port will not be processed by cpu
here timer can also be used, but lets do this in looping counter
*/
void wait_for_io(uint32_t timer_count)
{
  while (1)
  {
    asm volatile("nop");
    timer_count--;
    if (timer_count <= 0)
      break;
  }
}

void sleep(uint32_t timer_count)
{
  wait_for_io(timer_count);
}

void test_input()
{
  char ch = 0;
  char keycode = 0;
  do
  {
    keycode = get_input_keycode();
    if (keycode == KEY_ENTER)
    {
      print_newline();
    }
    else
    {
      ch = get_ascii_char(keycode);
      if (!ch == 0)
      {
        print_char(ch);
      } else if (ch == 2) {
        print(" [backspace has not been implemented] ");
      }
    }
    sleep(21000000);
  } while (ch > 0);
}

void shell_main()
{
  print("Type here, ENTER to go to next line\n");
  while (1)
  {
    test_input();
  }
}
