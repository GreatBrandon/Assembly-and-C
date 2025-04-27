# Assembly project 2 readme

## Converted code:
The converted code maintains the exact same functionality as the original code and no functionality changes have been made

## Security:
All vulnerabilites have been dealt with and are properly handled, here are some examples:
- All string lengths are constant and no vulnerabilities can occur when calling the kernel to display a string as no strings are being modified and they're all hard coded.
- Proper stack handling is also maintained by always returning properly after calling each function and never popping more items than were pushed, the stack is always kept clean with nothing left on the stack after the program finishes running.
- Input buffer overflow is handled by discarding all excess input that doesn't fit into the buffer and adding '0' instead to the sum. No arbitrary code execution can be run by exploiting buffer overflow as the overflow is discarded immediately. 
- Input processing is also handled by checking and only allowing the numbers 0-9 to be entered, any non numeric characters found in the input string cause the whole input to be discarded and replaced with '0' to prevent arbitrary code execution. 
- Integer overflow is handled effectively by restricting the user to enter numbers far lower than the 64 bit integer limit, effectively making it impossible to ever hit the limit.