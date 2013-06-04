module ActAsAdmin::Controller
  module Base
    extend ActiveSupport::Concern

    included do
      before_filter :init_context
      before_filter :new_resource, :only=>[:new, :create]
      before_filter :find_resource, :only=>[:show, :destroy, :edit, :update]
    end

    # POST /:resources
    def create
      respond_to do |format|
        if @resource.save
          format.html { redirect_to redirect_to_resources_path, notice: 'Successfully created' }
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
        format.html { redirect_to redirect_to_resources_path, notice: 'Successfully deleted' }
      end
    end

    # Filters
    def init_context
      @context = ::ActAsAdmin::Controller::Context.new self.class.admin_config, params
    end

    def new_resource
      @resource = @context.model.new(params[model_sym])
      @context.resource_config.assign_fields(@resource, :use=>self)

      self.instance_variable_set("@#{@context.config.resource_name}", @resource)
    end

    def find_resource
      @resource = @context.resource
      self.instance_variable_set("@#{@context.config.resource_name}", @resource)
    end


    private
    def model_sym
      self.class.admin_config.model.model_name.split(/:+/).last.underscore.to_sym
    end

  end
end
