#include <err.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>

#include <GL/glew.h>

#include "gl.h"

const char *
gl_strerror(GLint error)
{
    switch (error)
    {
    case GL_NO_ERROR:
        return "GL_NO_ERROR, No error has been recorded.";
        break;

    case GL_INVALID_ENUM:
        return "GL_INVALID_ENUM, An unacceptable value is specified for an "
            "enumerated argument. The offending command is ignored and has "
            "no other side effect than to set the error flag.";
        break;

    case GL_INVALID_VALUE:
        return "GL_INVALID_VALUE, A numeric argument is out of range. The "
            "offending command is ignored and has no other side effect than "
            "to set the error flag.";
        break;

    case GL_INVALID_OPERATION:
        return "GL_INVALID_OPERATION, The specified operation is not allowed "
            "in the current state. The offending command is ignored and has "
            "no other side effect than to set the error flag.";
        break;

    case GL_INVALID_FRAMEBUFFER_OPERATION:
        return "GL_INVALID_FRAMEBUFFER_OPERATION, The command is trying to "
            "render to or read from the framebuffer while the currently "
            "bound framebuffer is not framebuffer complete (i.e. the return "
            "value from glCheckFramebufferStatus is not "
            "GL_FRAMEBUFFER_COMPLETE). The offending command is ignored and "
            "has no other side effect than to set the error flag.";
        break;

    case GL_OUT_OF_MEMORY:
        return "GL_OUT_OF_MEMORY, There is not enough memory left to execute "
            "the command. The state of the GL is undefined, except for the "
            "state of the error flags, after this error is recorded.";
        break;

    default:
        return "Unknown GL error.";
    }
}

static void *
map_file(const char *path, off_t *numbytes)
{
    int fd;
    void *p;

    if (-1 == (fd = open(path, O_RDONLY)))
        err(EXIT_FAILURE, "open(\"%s\")", path);

    if (-1 == (*numbytes = lseek(fd, 0, SEEK_END)))
        err(EXIT_FAILURE, "lseek");

    if (MAP_FAILED == (p = mmap(NULL, *numbytes, PROT_READ, MAP_SHARED, fd, 0)))
        err(EXIT_FAILURE, "mmap");

    close(fd);

    return p;
}

static GLuint
load_shader(GLenum type, const char *path)
{
    GLuint shader;
    GLint compiled;
    char *source;
    off_t source_len;

    if (0 == (shader = glCreateShader(type)))
        errx(EXIT_FAILURE, "glCreateShader: %s", gl_strerror(glGetError()));

    source = map_file(path, &source_len);

    glShaderSource(shader, 1, (const GLchar **)&source, (GLint *)&source_len);

    if (-1 == munmap(source, source_len))
        err(EXIT_FAILURE, "munmap");

    glCompileShader(shader);

    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);

    if (!compiled)
    {
        GLint infolen = 0;

        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infolen);

        if (infolen > 1)
        {
            char *infolog = calloc(infolen, sizeof(char));

            glGetShaderInfoLog(shader, infolen, NULL, infolog);

            fprintf(stderr, "shader compilation:\n%s\n", infolog);

            free(infolog);
        }

        glDeleteShader(shader);

        exit(EXIT_FAILURE);
    }

    return shader;
}

GLuint
gl_load_program(const char *vs_path, const char *fs_path)
{
    GLuint program;
    GLuint vertex_shader;
    GLuint fragment_shader;
    GLint linked;

    vertex_shader = load_shader(GL_VERTEX_SHADER, vs_path);
    fragment_shader = load_shader(GL_FRAGMENT_SHADER, fs_path);

    if (0 == (program = glCreateProgram()))
        errx(EXIT_FAILURE, "glCreateProgram: %s", gl_strerror(glGetError()));

    glAttachShader(program, vertex_shader);
    glAttachShader(program, fragment_shader);

    glLinkProgram(program);

    glGetProgramiv(program, GL_LINK_STATUS, &linked);

    if (!linked)
    {
        GLint infolen = 0;

        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infolen);

        if (infolen > 1)
        {
            char *infolog = calloc(infolen, sizeof(char));

            glGetProgramInfoLog(program, infolen, NULL, infolog);

            fprintf(stderr, "shader linking:\n%s\n", infolog);

            free(infolog);
        }

        glDeleteProgram(program);

        exit(EXIT_FAILURE);
    }

    return program;
}
