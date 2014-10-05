#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <GL/glew.h>
#include <GL/glew.h>

#include <GLFW/glfw3.h>

#include "gl.h"

#define LENGTH(x) (sizeof(x) / sizeof(x[0]))

static int sw, sh;
static int m1, m2;
static double mx, my;

static GLFWwindow *window;

static GLuint program;
static GLuint vertex_buffer;
static GLuint index_buffer;
static GLint center_uniform;
static GLint zoom_uniform;
static GLint position_attrib;

/*********************************************/

static const GLfloat
quad_vertices[] =
{
    -1, -1, 1, -1, 1, 1, -1, 1,
};

static const GLubyte
quad_indices[] =
{
    0, 1, 2, 2, 3, 0,
};

/*********************************************/

static void
error_callback(int error, const char *description)
{
    fprintf(stderr, "GLFW error: %s", description);
}

static void
cursor_position_callback(GLFWwindow *window, double x, double y)
{
    mx = 2.0 * x / sw - 1.0;
    my = 1.0 - 2.0 * y / sh;
}

static void
key_callback(GLFWwindow *window, int key, int scancode, int action, int mods)
{
    if (GLFW_KEY_ESCAPE == key && GLFW_PRESS == action)
        glfwSetWindowShouldClose(window, GL_TRUE);

    if (GLFW_KEY_LEFT == key && GLFW_PRESS == action)
        ;

    if (GLFW_KEY_RIGHT == key && GLFW_PRESS == action)
        ;
}

static void
mouse_button_callback(GLFWwindow *window, int button, int action, int mods)
{
    if (0 == button)
        m1 = action;
    else if (1 == button)
        m2 = action;
}

static void
window_size_callback(GLFWwindow *window, int width, int height)
{
    sw = width;
    sh = height;

    glViewport(0, 0, sw, sh);
}

/*********************************************/

static void
glfw_init()
{
    glfwSetErrorCallback(error_callback);

    if (0 == glfwInit())
        err(EXIT_FAILURE, "glfwInit");

    if (0 == (window = glfwCreateWindow(1000, 1000, "hi", NULL, NULL)))
        err(EXIT_FAILURE, "glfwCreateWindow");

    glfwMakeContextCurrent(window);

    glfwSetCursorPosCallback(window, cursor_position_callback);
    glfwSetKeyCallback(window, key_callback);
    glfwSetMouseButtonCallback(window, mouse_button_callback);
    glfwSetWindowSizeCallback(window, window_size_callback);

    glfwGetFramebufferSize(window, &sw, &sh);
}

static void
gl_init()
{
    GLenum glew_status;

    if (GLEW_OK != (glew_status = glewInit()))
        errx(EXIT_FAILURE, "glewInit: %s", glewGetErrorString(glew_status));

    fprintf(stderr, "GLEW %s\n", glewGetString(GLEW_VERSION));
    fprintf(stderr, "OpenGL %d.%d\n", GLEW_VERSION_MAJOR, GLEW_VERSION_MINOR);

    program = gl_load_program("vertex.glsl", "fragment.glsl");

    glUseProgram(program);

    center_uniform = glGetUniformLocation(program, "center");
    zoom_uniform = glGetUniformLocation(program, "zoom");
    position_attrib = glGetAttribLocation(program, "position");

    glViewport(0, 0, sw, sh);

    glEnable(GL_CULL_FACE);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnableVertexAttribArray(position_attrib);

    glClearColor(0.0, 0.0, 0.0, 1.0);

    glGenBuffers(1, &vertex_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quad_vertices), quad_vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &index_buffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index_buffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(quad_indices), quad_indices, GL_STATIC_DRAW);
}

/*********************************************/

int
main()
{
    double centerx, centery, zoom;

    centerx = 0.0;
    centery = 0.0;
    zoom = 1.0;

    glfw_init();

    gl_init();

    glClear(GL_COLOR_BUFFER_BIT);

    glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index_buffer);
    glVertexAttribPointer(position_attrib, 2, GL_FLOAT, GL_FALSE, 0, 0);

    glUniform2f(center_uniform, centerx, centery);
    glUniform1f(zoom_uniform, zoom);

    while (!glfwWindowShouldClose(window))
    {
        {
            int m;

            m = m2 - m1;

            if (m)
            {
                centerx = mx;
                centery = my;

                glUniform2f(center_uniform, centerx, centery);

                if (0 < m)
                    zoom *= 1.01;
                else if (m < 0)
                    zoom /= 1.01;

                glUniform1f(zoom_uniform, zoom);
            }
        }

        glDrawElements(GL_TRIANGLES, LENGTH(quad_indices), GL_UNSIGNED_BYTE, 0);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    return EXIT_SUCCESS;
}
