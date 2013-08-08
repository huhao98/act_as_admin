require 'act_as_admin/builder/resource_components'

module ActAsAdmin::Builder

  # ResourcePath.new(:product).to(:album, :on=>:great_albums).to(:photo)
  # ResourcePath.new(:product).to(:album).to(:photo)
  #
  # /products/:product_id/albums/:album_id/photoes/:id, 
  # Product.find(:id=>product_id).albums.find(:id=>album_id).photoes.find(:id=>id)
  class ResourcePath

    attr_reader :paths

    def initialize resource, opts={}, &finder
      if finder.nil?
        model = opts.delete(:model) || resource.to_s.classify.constantize
        finder = root_finder(model)
      end

      @paths = {resource => opts.merge(:finder=>finder)}
    end

    def to resource, opts={}, &finder
      if (finder.nil?)
        field = opts.delete(:on) || resource.to_s.underscore.pluralize.to_sym
        finder ||= path_finder(field)
      end
      @paths[resource] = opts.merge(:finder=>finder)

      return self
    end

    def match? params
      parents = paths.keys
      parents.slice!(-1)
      
      parent_ids = parents.collect{|resource| to_id(resource)} 
      param_ids = params.keys.reject{|k| (k =~ /.+_id$/).nil?}

      (parent_ids.size == param_ids.size) && (parent_ids - param_ids).empty?
    end

    # [paths] - path defination
    #   {
    #     :product => proc}, 
    #     :albums  => proc}, 
    #     :photo   => proc}, 
    #   }
    # [params] - params
    #   {:product_id=>"product_id", :album_id=>"album_id"}
    #
    def resource_components params
      # Output components
      # {
      #   :product => {:collection=>Product.all, :resource=>Product.find("product_id")},
      #   :album => {:collection=>product.albums, :resource=>product.albums.find("album_id")},
      #   :photo => { :collection=>album.photoes}
      # } 
      last = paths.keys.last
      parent = nil

      components = paths.inject(Hash.new) do |memo, path|
        resource_name = path[0] 
        opts = path[1]

        id = params[(resource_name == last) ? "id" : to_id(resource_name)]
        result = opts[:finder].call(id, parent)
        parent = result[:resource]

        opts = opts.select{|k,v| [:title, :exclude, :namespace].include? k}
        memo.merge!(resource_name => result.merge(opts))
      end
      return ActAsAdmin::Builder::ResourceComponents.new(components)
    end




    private

    def to_id resource
      "#{singular_name(resource)}_id"
    end

    def singular_name resource
      resource.to_s.singularize
    end

    def path_finder field
      singular = field.to_s == field.to_s.singularize

      return Proc.new do |id, parent|
        unless singular
          collection = parent.send(field)
          result = {:collection => collection}
          result.merge!(:resource => collection.find(id)) if id.present?
        else
          result = {:resource=>parent.send(field)}
        end
        result
      end
    end

    def root_finder model
      return Proc.new do |id|
        collection = model.all

        result = {:collection => collection}
        result.merge!(:resource => collection.find(id)) if id.present?
        result
      end
    end

  end
end