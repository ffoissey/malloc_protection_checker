#include <unistd.h>
#include <dlfcn.h>
#include <execinfo.h>
#include <stdbool.h>
#include <strings.h>

#define MAIN "main"
#define UNKNOW "???"

#ifndef MALLOC_LIMIT
# define MALLOC_LIMIT 1
#endif

#ifndef BIN_NAME
# define BIN_NAME "???"
#endif

void *malloc(size_t size)
{
	static int i = 0;
	static int subprocess = false;
	static bool start_counter = false;
	static void *(*real_malloc)(size_t);
	void *called_func[2] = {NULL};
	char **calledby;

	if (subprocess == true)
		return real_malloc(size);
	if (real_malloc == NULL)
		real_malloc = dlsym(RTLD_NEXT, "malloc");
	if (subprocess == false)
	{
		subprocess = true;
		backtrace(called_func, 2);
		calledby = backtrace_symbols(called_func, 2);
		subprocess = false;
		if (calledby[1] != NULL && start_counter == false)
		{
			if (strstr(calledby[1], BIN_NAME) != NULL ||
				strstr(calledby[1], UNKNOW) != NULL ||
				strstr(calledby[1], MAIN) != NULL)
				start_counter = true;
			else
				return real_malloc(size);
		}
	}
	++i;
	if (i <= MALLOC_LIMIT)
		return real_malloc(size);
	if (calledby[1] != NULL)
	{
		write(STDERR_FILENO, "Called by: ", 11);
		write(STDERR_FILENO, calledby[1], strlen(calledby[1]));
		write(STDERR_FILENO, "\n", 1);
	}
	return NULL;
}

