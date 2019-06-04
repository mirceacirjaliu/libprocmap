#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include "libprocmap.h"

void callback(struct vma_map *map)
{
	printf("%016lx - %016lx in %s\n", map->start, map->end, map->pathname);
}

int main(int argc, char* argv[])
{
	int pid;
	int result;

	if (argc == 2) {
		pid = atoi(argv[1]);
		printf("Doing process: %d\n", pid);
		result = get_proc_map(pid, callback);
	}
	else if (argc == 3 && !strcmp(argv[1], "-d"))
	{
		printf("Doing file: %s\n", argv[2]);
		result = direct_parse(argv[2], callback);
	}
	else {
		printf("Usage: %s <-d file> | <pid>\n", argv[1]);
		return 1;
	}

	if (result == 0)
		printf("Success!\n");
	else
		fprintf(stderr, "Error: %s\n", strerror(errno));

	return result;
}
