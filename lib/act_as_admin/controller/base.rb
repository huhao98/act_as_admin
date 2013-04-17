module ActAsAdmin::Controller

  # Base controller. 
  #
  # Instance methods should be defined

  #
  # Class methods should be defined
  # - admin_config
  # - singular_name
  # - plural_name
  module Base

    # POST /:resources
    def create
      respond_to do |format|
        if @resource.save
          format.html { redirect_to resources_path, notice: 'Successfully created' }
        else
          @form = self.class.admin_config.forms[:new]
          format.html { render action: "new" }
        end
      end
    end

    # PUT /:resources/:id
    def update
      respond_to do |format|
        if @resource.update_attributes(params[singular_name])
          format.html { redirect_to resource_path(@resource), notice: 'Successfully updated' }
        else
          @form = self.class.admin_config.forms[:edit]
          format.html { render action: "edit" }
        end
      end
    end

    # DELETE /:resources/:id
    def destroy
      @resource.destroy
      respond_to do |format|
        format.html { redirect_to resources_path, notice: 'Successfully deleted' }
      end
    end

  end

end
