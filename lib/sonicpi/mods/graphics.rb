require 'chunky_png'

 module SonicPi
   module Mods
     module Graphics

       def self.included(base)
         base.instance_exec {alias_method :sonic_pi_mods_graphics_initialize_old, :initialize}

         base.instance_exec do
           define_method(:initialize) do |*splat, &block|
             sonic_pi_mods_graphics_initialize_old *splat, &block
             @pngs = {}
           end
         end
       end

       def image(x, y, src)
         local = false

         if(src.class == Symbol)
           p = @pngs[src]
           raise "Can't find png with id #{id}" unless p
           p.save("#{media_path}/#{src.to_s}.png", :interlace => true)
           src = "media/#{src}.png"
           local = true
         end

         if(src.class == String)
           if(File.exists? src)
             safe_src = src.gsub(/[^a-zA-Z0-9.]/, "_|_")
             src_basename = File.basename src
             media_src = "#{media_path}/#{safe_src}"
             unless(File.exists? media_src)
               FileUtils.cp(src, media_src)
             end
             src = "media/#{safe_src}"
             local = true
           end
         end

         cmd = {:type => :sketch, :opts => {:x => x, :y => y, :cmd => :image, :src => src, :locyal? => local}}
         sync_msg_command cmd
       end

       def clear
         sync_msg_command({:cmd => :clear})
       end

       def png(width, height, id)
         p = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
         @pngs[id] = p
         message "Created png with id: #{id} #{width}x#{height}"
       end

       def set_png_pixel(id, x, y, color)
         p = @pngs[id]
         raise "Can't find png with id #{id}" unless p

         red = color[:red] || 0
         green = color[:green] || 0
         blue = color[:blue] || 0
         alpha = color[:alpha] || 255
         p[x,y] = ChunkyPNG::Color.rgba(red, green, blue, alpha)
       end

       def get_png_pixel(id, x, y)
         p = @pngs[id]
         raise "Can't find png with id #{id}" unless p

         color = p[x,y]
         red = ChunkyPNG::Color.r(color)
         green = ChunkyPNG::Color.g(color)
         blue = ChunkyPNG::Color.b(color)
         alpha = ChunkyPNG::Color.a(color)

         {
           :red => red,
           :green => green,
           :blue => blue,
           :alpha => alpha
         }
       end

       def sketch_command(opts)
         cmd = {:type => :sketch, :opts => opts}
         sync_msg_command cmd
       end

       def circle(x, y, radius)
         sketch_command({:x => x, :y => y, :radius => radius, :cmd => :circle})
       end

     end
   end
 end
