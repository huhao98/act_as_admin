module ActAsAdmin::Controller
  module Base
    extend ActiveSupport::Concern

    included do
      before_filter :init_context
      before_filter :new_resource, :only=>[:new, :create]
      before_filter :find_resource, :only=>[:show, :destroy, :edit, :update]
      before_filter :find_resources
    end

    # POST /:resources
    def create
      respond_to do |format|
        if @resource.save
          success_path = @context.exclude_nested_index? ? parent_path : resources_path
          format.html { redirect_to success_path, notice: 'Successfully created' }
        else
          format.html { render action: "new" }
        end
      end
    end

    # PUT /:resources/:id
    def update
      respond_to do |format|
        if @resource.update_attributes(params[model_sym])
          format.html { redirect_to resource_path(@resource), notice: 'Successfully updated' }
        else
          format.html { render action: "edit" }
        end
      end
    end

    # DELETE /:resources/:id
    def destroy
      @resource.destroy
      respond_to do |format|
        success_path = @context.exclude_nested_index? ? parent_path : resources_path
        format.html { redirect_to success_path, notice: 'Successfully deleted' }
      end
    end

    # Filters
    def init_context
      @context = ::ActAsAdmin::Controller::Context.new self.class.admin_config, params
    end

    def new_resource
      @resource = @context.model.new(params[model_sym])
      @context.fields{|name, value| @resource.send("#{name}=", resolve(value))}
    end

    def find_resource
      @resource = resolve(@context.find_from).find(params[:id])
    end

    def find_resources
      query = @context.query
      return unless query

      @query_result = query_by(query, :from => resolve(query.from || @context.find_from))
      @resources = @query_result.items
      instance_variable = query.as
      self.instance_variable_set("@#{instance_variable}", @resources) if instance_variable
    end


    private
    
    def resolve value
      resolved = self.instance_exec(&value) if value.is_a? Proc
      return resolved || value
    end

    def model_sym
      self.class.admin_config.model.model_name.split(/:+/).last.underscore.to_sym
    end

  end
end
