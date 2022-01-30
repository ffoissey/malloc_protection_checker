#include <unistd.h>
#include <dlfcn.h>
#include <execinfo.h>
#include <stdbool.h>
#include <string.h>

#define MALLOC_FUNCTION_NAME "malloc"
#define MAIN "main"
#define CALLED_BY "Called by: "
#define NEWLINE "\n"
#define LAST_TRACE 1
#define NB_STACKTRACE_REQUESTED 2
#define NB_START_NAMES 2

#ifndef MALLOC_LIMIT
# define MALLOC_LIMIT 1
#endif

#ifndef BIN_NAME
# define BIN_NAME UNKNOW
#endif

static void print_stacktrace(char * const * const calledby)
{
	if (calledby != NULL && calledby[LAST_TRACE] != NULL)
	{
		write(STDERR_FILENO, CALLED_BY, sizeof(CALLED_BY));
		write(STDERR_FILENO, calledby[LAST_TRACE], strlen(calledby[LAST_TRACE]));
		write(STDERR_FILENO, NEWLINE, sizeof(NEWLINE));
	}
}

static bool has_the_program_started(char * const * const calledby)
{
	static const char *stacktrace_start_names[NB_START_NAMES] = {BIN_NAME, MAIN};

	if (calledby != NULL && calledby[LAST_TRACE] != NULL)
	{
		for (int i = 0; i < NB_START_NAMES; ++i)
		{
			if (strstr(calledby[LAST_TRACE], stacktrace_start_names[i]) != NULL)
				return true;
		}
	}
	return false;
}

void *malloc(size_t size)
{
	static unsigned int counter = 0;
	static bool backtrace_function_need_allocation = false;
	static bool start_counter = false;
	static void *(*real_malloc)(size_t) = NULL;
	void *called_functions_address[NB_STACKTRACE_REQUESTED] = {NULL, NULL};
	char **calledby;

	if (real_malloc == NULL)
		real_malloc = dlsym(RTLD_NEXT, MALLOC_FUNCTION_NAME);
	if (backtrace_function_need_allocation == true)
		return real_malloc(size);
	if (backtrace_function_need_allocation == false)
	{
		backtrace_function_need_allocation = true;
		backtrace(called_functions_address, NB_STACKTRACE_REQUESTED);
		calledby = backtrace_symbols(called_functions_address, NB_STACKTRACE_REQUESTED);
		backtrace_function_need_allocation = false;
		if (start_counter == false)
		{
			if (has_the_program_started(calledby) == true)
				start_counter = true;
			else
				return real_malloc(size);
		}
	}
	++counter;
	if (counter <= MALLOC_LIMIT)
		return real_malloc(size);
	print_stacktrace(calledby);
	return NULL;
}

