require_relative 'lib/lwjgl.jar'

import org.lwjgl.Sys
import org.lwjgl.glfw.Callbacks
import org.lwjgl.glfw.GLFW
import org.lwjgl.glfw.GLFWKeyCallback
import org.lwjgl.glfw.GLFWvidmode
import org.lwjgl.opengl.GL11
import org.lwjgl.opengl.GLContext
import org.lwjgl.system.MemoryUtil

import java.lang.System
import java.nio.ByteBuffer

class HelloWorld
  WIDTH = 300
  HEIGHT = 300

  def run
    puts "Hello LWJGL #{Sys.getVersion}!"

    begin
      init
      game_loop

      # Release window and window callbacks
      GLFW.glfwDestroyWindow @window
      @keyCallback.release
    ensure
      # Terminate GLFW and release the GLFWerrorfun
      GLFW.glfwTerminate
      @errorCallback.release
    end
  end

  def init
    puts "Initializing"
    # Setup an error callback. The default implementation
    # will print the error message in System.err.
    GLFW.glfwSetErrorCallback(@errorCallback = Callbacks.errorCallbackPrint(System.err))

    # Initialize GLFW. Most GLFW functions will not work before doing this.
    if GLFW.glfwInit != GL11::GL_TRUE
      raise IllegalStateException.new "Unable to initialize GLFW"
    end

    # Configure our window
    GLFW.glfwDefaultWindowHints # optional, the current window hints are already the default
    GLFW.glfwWindowHint GLFW::GLFW_VISIBLE, GL11::GL_FALSE  # the window will stay hidden after creation
    GLFW.glfwWindowHint GLFW::GLFW_RESIZABLE, GL11::GL_TRUE  # the window will be resizable

    # Create the window
    @window = GLFW.glfwCreateWindow WIDTH, HEIGHT, "Hello World!", MemoryUtil::NULL, MemoryUtil::NULL
    if @window.nil?
      raise "Failed to create the GLFW window"
    end

    # Setup a key callback. It will be called every time a key is pressed, repeated or released.
    @keyCallback = Class.new(GLFWKeyCallback) do
      def invoke win, key, scancode, action, mods
        if key == GLFW::GLFW_KEY_ESCAPE && action == GLFW::GLFW_RELEASE
          GLFW.glfwSetWindowShouldClose(win, GL11::GL_TRUE) # We will detect this in our rendering loop
        end
      end
    end.new

    GLFW.glfwSetKeyCallback @window, @keyCallback

    # Get the resolution of the primary monitor
    vidmode = GLFW.glfwGetVideoMode(GLFW::glfwGetPrimaryMonitor)

    # Center our window
    GLFW.glfwSetWindowPos(
      @window,
      (GLFWvidmode.width(vidmode) - WIDTH) / 2,
      (GLFWvidmode.height(vidmode) - HEIGHT) / 2
    )

    # Make the OpenGL context current
    GLFW.glfwMakeContextCurrent @window
    # Enable v-sync
    GLFW.glfwSwapInterval 1

    # Make the window visible
    GLFW.glfwShowWindow @window
  end

  def game_loop
    # This line is critical for LWJGL's interoperation with GLFW's
    # OpenGL context, or any context that is managed externally.
    # LWJGL detects the context that is current in the current thread,
    # creates the ContextCapabilities instance and makes the OpenGL
    # bindings available for use.
    GLContext.createFromCurrent

    # Set the clear color
    GL11.glClearColor 1.0, 0.0, 0.0, 0.0

    # Run the rendering loop until the user has attempted to close
    # the window or has pressed the ESCAPE key.
    while GLFW.glfwWindowShouldClose(@window) == GL11::GL_FALSE
      GL11.glClear(GL11::GL_COLOR_BUFFER_BIT | GL11::GL_DEPTH_BUFFER_BIT) # clear the framebuffer

      GLFW.glfwSwapBuffers @window # swap the color buffers

      # Poll for window events. The key callback above will only be
      # invoked during this call.
      GLFW.glfwPollEvents
    end
  end

end

HelloWorld.new.run
