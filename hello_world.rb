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
    puts "Hello LWJGL #{Sys.get_version}!"

    begin
      init
      game_loop

      # Release window and window callbacks
      GLFW.glfw_destroy_window @window
      @key_callback.release
    ensure
      # Terminate GLFW and release the GLFWerrorfun
      GLFW.glfw_terminate
      @error_callback.release
    end
  end

  def init
    # Setup an error callback. The default implementation
    # will print the error message in System.err.
    GLFW.glfw_set_error_callback(@error_callback = Callbacks.error_callback_print(System.err))

    # Initialize GLFW. Most GLFW functions will not work before doing this.
    if GLFW.glfw_init != GL11::GL_TRUE
      raise IllegalStateException.new "Unable to initialize GLFW"
    end

    # Configure our window
    GLFW.glfw_default_window_hints # optional, the current window hints are already the default
    GLFW.glfw_window_hint GLFW::GLFW_VISIBLE, GL11::GL_FALSE  # the window will stay hidden after creation
    GLFW.glfw_window_hint GLFW::GLFW_RESIZABLE, GL11::GL_TRUE  # the window will be resizable

    # Create the window
    @window = GLFW.glfw_create_window WIDTH, HEIGHT, "Hello World!", MemoryUtil::NULL, MemoryUtil::NULL
    if @window.nil?
      raise "Failed to create the GLFW window"
    end

    # Setup a key callback. It will be called every time a key is pressed, repeated or released.
    @key_callback = Class.new(GLFWKeyCallback) do
      def invoke win, key, scancode, action, mods
        if key == GLFW::GLFW_KEY_ESCAPE && action == GLFW::GLFW_RELEASE
          GLFW.glfw_set_window_should_close(win, GL11::GL_TRUE) # We will detect this in our rendering loop
        end
      end
    end.new

    GLFW.glfw_set_key_callback @window, @key_callback

    # Get the resolution of the primary monitor
    vidmode = GLFW.glfw_get_video_mode(GLFW::glfw_get_primary_monitor)

    # Center our window
    GLFW.glfw_set_window_pos(
      @window,
      (GLFWvidmode.width(vidmode) - WIDTH) / 2,
      (GLFWvidmode.height(vidmode) - HEIGHT) / 2
    )

    # Make the OpenGL context current
    GLFW.glfw_make_context_current @window
    # Enable v-sync
    GLFW.glfw_swap_interval 1

    # Make the window visible
    GLFW.glfw_show_window @window
  end

  def game_loop
    # This line is critical for LWJGL's interoperation with GLFW's
    # OpenGL context, or any context that is managed externally.
    # LWJGL detects the context that is current in the current thread,
    # creates the ContextCapabilities instance and makes the OpenGL
    # bindings available for use.
    GLContext.create_from_current

    # Set the clear color
    GL11.gl_clear_color 1.0, 0.0, 0.0, 0.0

    # Run the rendering loop until the user has attempted to close
    # the window or has pressed the ESCAPE key.
    while GLFW.glfw_window_should_close(@window) == GL11::GL_FALSE
      GL11.gl_clear(GL11::GL_COLOR_BUFFER_BIT | GL11::GL_DEPTH_BUFFER_BIT) # clear the framebuffer

      GLFW.glfw_swap_buffers @window # swap the color buffers

      # Poll for window events. The key callback above will only be
      # invoked during this call.
      GLFW.glfw_poll_events
    end
  end

end

HelloWorld.new.run
