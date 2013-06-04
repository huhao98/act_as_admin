#encoding : utf-8
module AdminFormHelper

  def render_form form, resource
    url = form.url
    url = self.instance_exec(resource, &url) if url.is_a?(Proc)
    form_for(resource, :url=>url, :method=>form.method, :as=>form.as, :html =>{ :class => 'form-horizontal'}) do |f|
      concat form.input_fields.collect{|field, option| control_group(f, field, option.merge(:errors=>errors_of(resource, field)))}.join("\n").html_safe
      concat form_action(f, form_action_options(form, resource))
    end
  end

  private

  def form_action_options form, resource
    actions = {:submit=>form.submit_label}
    if form.cancel_url.is_a?(Proc)
      cancel_url = self.instance_exec(resource, &form.cancel_url)
      actions.merge!(:cancel=>[form.cancel_label || "Cancel", cancel_url])
    end
    return actions
  end

  def errors_of resource, field
    nested_fields = field.to_s.split(".")
    if (nested_fields.size == 2)
      data = resource.send(nested_fields[0].to_sym)
      if data
        return data.errors[nested_fields[1].to_sym]
      else
        return resource.errors[nested_fields[0]]
      end
    else
      return resource.errors[field.to_sym]
    end
  end

end
