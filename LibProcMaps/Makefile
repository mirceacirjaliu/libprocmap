

YACC = bison

OBJECTS = libprocmap.tab.o libprocmap.yy.o

libprocmap.a : $(OBJECTS)
	ar rcs libprocmap.a $(OBJECTS)

libprocmap.tab.c libprocmap.tab.h : libprocmap.y
	bison -d libprocmap.y
		
libprocmap.yy.c : libprocmap.l
	flex -o libprocmap.yy.c libprocmap.l

libprocmap.yy.o : libprocmap.yy.c libprocmap.tab.h

%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

test : test.c libprocmap.a
	$(CC) -O0 -o test test.c libprocmap.a

.PHONY: clean

clean:
	rm -f *.a *.o *.tab.* *.yy.* test
