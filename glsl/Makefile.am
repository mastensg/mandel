AM_CFLAGS = -Wall -Wextra -pedantic -std=c99

bin_PROGRAMS = mandel

mandel_CFLAGS = $(GLEW_CFLAGS) $(GLFW_CFLAGS)
mandel_LDADD = $(GLEW_LIBS) $(GLFW_LIBS) -lm
mandel_SOURCES = main.c \
				   gl.c gl.h
