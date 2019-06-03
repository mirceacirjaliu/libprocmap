#include <stdio.h>
#include <stdint.h>
#include <string.h>
#define __STDC_FORMAT_MACROS
#include <inttypes.h>

// 7effb8a6d000 - 7effb926d000 rw - p 00000000 00:00 0
// 7effb926d000 - 7effb9278000 r - xp 00000000 08 : 01 27001099 / lib / x86_64 - linux - gnu / libnss_files - 2.23.so
struct mem_map
{
	uint64_t start;
	uint64_t end;

	char perms[5];
	uint32_t nuj1;		// ???

	uint32_t nuj2;		// ???
	uint32_t nuj3;		// ???

	uint32_t nuj4;		// ???

	char file[128];		// mapped file
};

int main(int argc, char *argv[])
{
	int pid;
	char maps_name[32];
	FILE *maps;
	int result;

	if (argc != 2) {
		printf("Usage: %s <pid>\n", argv[0]);
		return 1;
	}

	if (sscanf(argv[1], "%d\n", &pid) != 1) {
		printf("PID parse error: %s\n", argv[1]);
		return 1;
	}

	sprintf(maps_name, "/proc/%d/maps", pid);

	maps = fopen(maps_name, "r");
	if (maps == NULL) {
		printf("Failed opening: %s\n", maps_name);
		return 1;
	}

	/*do {
		struct mem_map map;
		memset(&map, 0, sizeof(map));

		result = fscanf(maps, SCNx64"-"SCNx64" %s "SCNx32" %d:%d %d %s\n",
			&map.start, &map.end, map.perms, &map.nuj1,
			&map.nuj2, &map.nuj3, &map.nuj4, map.file);

		printf(PRIx64"-"PRIx64" -> %s\n", map.start, map.end, map.file);

	} while (result == 6 || result == 7);*/

	do {
		struct mem_map map;
		memset(&map, 0, sizeof(map));

		char line[256];

		result = fscanf(maps, SCNx64"-"SCNx64" %s %s %s %s %s\n",
			&map.start, &map.end, line, line, line, line, line);

		printf("%d: %s\n", result, line);

	} while (result != EOF);

	fclose(maps);

	return 0;
}
