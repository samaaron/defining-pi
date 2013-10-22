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
             clear_image_cache
           end
         end
       end

       def image(x, y, src)
         image_info = fetch_image(src)

         sketch_command({:x => x,
                         :y => y,
                         :cmd => :image,
                         :src => image_info[:web_path],
                         :local? => true})
       end

       def read_png(src)
         image_info = fetch_image(src)
         p = ChunkyPNG::Image.from_file(image_info[:path])
         @pngs[src] = {:png => p, :modified => true}
         message "PNG succesfully read"
       end

       def clear_image_cache
         Dir["#{media_path}/*"].each {|f| FileUtils.rm f}
         sleep 0.5
         @pngs = {}
       end

       def clear
         sketch_command({:cmd => :clear})
       end

       def destroy(id)
         sketch_command({:cmd => :destroy, :id => id})
       end

       def move(id, x, y)
         sketch_command({:cmd => :move, :id => id, :x => x, :y => y})
       end

       def png(width, height, id)
         p = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
         @pngs[id] = {:png => p, :modified => true}
         message "Created png with id: #{id} #{width}x#{height}"
       end

       def set_png_pixel(id, x, y, color)
         png_info = @pngs[id]

         raise "Can't find png with id #{id}" unless png_info
         p = png_info[:png]
         png_info[:modified] = true
         red = color[:red] || 0
         green = color[:green] || 0
         blue = color[:blue] || 0
         alpha = color[:alpha] || 255
         p[x,y] = ChunkyPNG::Color.rgba(red, green, blue, alpha)
         :pixel_set
       end

       def update_png_pixel(id, x, y, color)
         png_info = @pngs[id]
         raise "Can't find png with id #{id}" unless png_info
         p = png_info[:png]
         png_info[:modified] = true
         curr_color = get_png_pixel(id, x, y)
         color = curr_color.merge(color)
         red = color[:red]
         green = color[:green]
         blue = color[:blue]
         alpha = color[:alpha]

         p[x,y] = ChunkyPNG::Color.rgba(red, green, blue, alpha)
         :pixel_updated
       end

       def get_png_pixel(id, x, y)
         png_info = @pngs[id]
         raise "Can't find png with id #{id}" unless png_info
         p = png_info[:png]

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

       def circle(x, y, radius, *opts)
         opts = Hash[*opts]
         sketch_command(opts.merge({:x => x, :y => y, :radius => radius, :cmd => :circle}))
       end

       def text(x,y, txt, *opts)
         opts = Hash[*opts]
         sketch_command(opts.merge({:x => x, :y => y, :text => txt, :cmd => :text}))
       end

       def fetch_image(src)
         web_path = ""
         path = ""
         png_info = @pngs[src]

         if(src.class == Symbol)
           p = png_info[:png]
           raise "Can't find png with id #{id}" unless p
           path = "#{media_path}/#{src.to_s}.png"
           if(png_info[:modified] || !File.exists?(path))
             p.save(path, :interlace => true)
             png_info[:modified] = false
           end
           web_path = "media/#{src}.png"
         elsif(src.class == String)
           safe_src = safe_pathname(src)
           path = safe_media_path(src)
           web_path = "media/#{safe_src}"

           if png_info and (png_info[:modified] || !File.exists?(path))
             png_info[:png].save(path, :interlace => true)
             png_info[:modified] = false
           elsif(File.exists? src)
             unless(File.exists? path)
               FileUtils.cp(src, path)
             end
             web_path = "media/#{safe_src}"
           else
             #only download file if it hasn't yet been cached.
             unless (File.exists? path)
               r = Net::HTTP.get_response URI(src)
               open(path, 'w') {|f| f.write r.body}
             end
             web_path = "media/#{safe_src}"
           end
         end

         {:web_path => web_path,
           :path    => path}

       end



       private

       def safe_pathname(path)
         path.gsub(/[^a-zA-Z0-9.]/, "_|_")
       end

       def safe_media_path(path)
         safe_src = safe_pathname(path)
         "#{media_path}/#{safe_src}"
       end



     end
   end
 end
