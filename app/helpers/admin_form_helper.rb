#encoding : utf-8
module AdminFormHelper
  def render_form form, data
    if data.persisted? 
      action ={:url=>resolve(form.actions[:edit][:action_url], data), :method=>:put}
    else
      action ={:url=>resolve(form.actions[:new][:action_url]), :method=>:post}
    end
    
    form_for(data, action.merge(:as=>form.as, :html =>{ :class => 'form-horizontal' })) do |f|
      form.fields.each { |field, option| concat render_field(f, data, field, option)}
      concat form_action(f.submit("保存", :class=>'btn btn-primary'))
    end
  end

  def render_field f, data, field, option
    type = option[:type].to_sym
    form_field = case type
    when :text_field, :text_area, :password_field, :file_field, :hidden_field, :email_field, \
      :number_field, :phone_field, :range_field, :search_field, :telephone_field, :url_field
      f.send(type, field)
    when :check_box
      vals = option[:values] || %w[1 0]
      f.check_box(field, option, vals[0], vals[1])
    when :radio_button
      f.radio_button(field, option[:value], option)
    when :select_field
      f.select(field, option[:values])
    when :date_field
      f.text_field("#{field}_input".to_sym)
    end

    unless type == :hidden_field
      control_group(
        f.label(field, :class=>"control-label"),
        form_field,
        errors: data.errors[field],
        help: option[:help]
      )
    else
      form_field
    end
  end
end