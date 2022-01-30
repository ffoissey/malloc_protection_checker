# C Malloc Protection Checker

First of all, if you wonder why it is important to protect your malloc calls, I suggest this [medium article](https://medium.com/pvs-studio/why-it-is-important-to-check-what-the-malloc-function-returned-ba39f3d13a83).

In this repo you will find a shell script and a malloc wrapper to check malloc protection in your programs.

This script allows you to test your program by deliberately causing the malloc function to fail (i.e. by returning NULL) after a certain number of calls defined by the "limit" variable.
You can test the program in a loop from zero to the defined limit or use it in "oneshot" mode in order to fail at exactly the defined number of calls.

:warning: **If you are on a GNU/Linux system, you have to compile your project with CLANG compiler, not GCC compiler.**
**Still for Linux, I advise you to compile your project with the ```-rdynamic``` CLANG flag in order to have the name of the calling function in the stacktrace and not just its address**

## Run:

- First, clone this repo.
- Compile your program as usual, without changing anything.
- Then, Run the script "malloc_checker.sh" with this usage:

  ##### ```./malloc_checker.sh bin={your_compiled_program} limit={malloc_limit} [loop={false|true}]"```
  
  #### Here is the possible arguments: 
  
  - **bin**: binary you want to test
  - **limit**: the number of calls to malloc that can succeed before malloc returns NULL
  - **loop**: [optional parameter] -> use if you want to loop from 0 to limit (default: false)"
  
  #### Here is an example to test malloc function failure in your compiled program 'test' after first call, until 20th call
  
  ##### ```./malloc_checker.sh bin=./test limit=20 loop=true```
  
  **Note that if you want to run your program with arguments: just enclose the whole thing in quotes like this:**
  
   ##### ```./malloc_checker.sh bin="./test ARG1 ARG2 ARG3" limit=20 loop=true```
