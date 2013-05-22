#encoding : utf-8
module AdminFormHelper

  def render_form form, resource
    url = form.url
    url = self.instance_exec(resource, &url) if url.is_a?(Proc)

    form_for(resource, :url=>url, :method=>form.method, :as=>form.as, :html =>{ :class => 'form-horizontal'}) do |f|
      form.input_fields.each do |field, option| 
        concat render_field(f, resource, field, option)
      end

      concat form_action(f.submit(form.action, :class=>'btn btn-primary'))
    end
  end

  def render_field f, resource, field, option
    type = option[:type].to_sym
    form_field = case type
    when :text_field, :text_area, :password_field, :file_field, :hidden_field, :email_field, \
      :number_field, :phone_field, :range_field, :search_field, :telephone_field, :url_field
      f.send(type, field)
    when :checkbox
      vals = option[:values] || %w[1 0]
      f.checkbox(field, option, vals[0], vals[1])
    when :radio_button
      f.radio_button(field, option[:value], option)
    when :select_field
      f.select(field, option[:values])
    when :date_field
      f.text_field("#{field}_input".to_sym)
    end

    control_group(
      f.label(field, :class=>"control-label"),
      form_field,
      errors: resource.errors[field],
      help: option[:help]
    )
  end
end