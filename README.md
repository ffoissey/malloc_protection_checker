# C Malloc Protection Checker
In this repo you will find a shell script and a malloc wrapper to check malloc protection in your programs.

This script allows you to test your program by deliberately causing the malloc function to fail (i.e. by returning NULL) after a certain number of calls defined by the "limit" variable.
You can test the program in a loop from zero to the defined limit or use it in "oneshot" mode in order to fail at exactly the defined number of calls.

:warning: **The program is currently adapted to an OSX system, some small adaptations are necessary for GNU/Linux System.**

## Run:

- First clone this repo.
- Compile your program as usual, without changing anything.
- Then, Run the script "malloc_checker.sh" with this usage:

  ##### ./malloc_checker bin={your_compiled_program} limit={malloc_limit} [loop={false|true}]"
  
  #### Here is the possible arguments: 
  
  - **bin**: binary you want to test
  - **limit**: the number of calls to malloc that can succeed before malloc returns NULL
  - **loop**: [optional parameter] -> use if you want to loop from 0 to limit (default: false)"
  
  #### Here is an example to test malloc function failure in your compiled program 'test' after first call, until 20th call
  
  ##### ./malloc_checker bin=./test limit=20 loop=true
  
