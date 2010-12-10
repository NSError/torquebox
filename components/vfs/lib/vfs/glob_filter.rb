

module VFS
  class GlobFilter
    include Java::org.jboss.vfs.VirtualFileFilter
  
    def initialize(child_path, glob)
      @child_path = child_path
      glob_segments = glob.split( '/' )
      regexp_segments = []
  
      glob_segments.each_with_index do |gs,i|
        if ( gs == '**' )
          regexp_segments << '(.*)'
        else
          gs.gsub!( /\./, '\.')
          gs.gsub!( /\*/ ) do |m|
            if ( $` == '' )
              '([^\/\.][^\/]*)?'
            else
              '[^\/]*'
            end
          end
          gs.gsub!( /\?/, '.')
          gs.gsub!( /\{[^\}]+\}/ ) do |m|
            options = m[1..-2].split(',', -1)
            options = options.collect{|e| "(#{e})"}
            "(#{options.join('|')})"
          end
          if ( i < (glob_segments.size()-1))
            gs = "#{gs}/"
          end
          regexp_segments << gs
        end
      end
      
      regexp_str = regexp_segments.join
      if ( @child_path && @child_path != '' )
        #regexp_str = ::File.join( "^#{@child_path}", "#{regexp_str}$" )
        if ( @child_path[-1,1] == '/' )
          regexp_str = "^#{@child_path}#{regexp_str}$"
        else
          regexp_str = "^#{@child_path}/#{regexp_str}$"
        end
      else
        regexp_str = "^#{regexp_str}$"
      end
      @regexp = Regexp.new( regexp_str )
    end
  
    def accepts(file)
      acceptable = ( !!( file.path_name =~ @regexp ) )
      !!( file.path_name =~ @regexp )
    end
  end
end

