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

    if [:text_field, :text_area, :password_field].include? type
      form_field = f.send(type, field) 
    else
      case type
      when :date_field
        form_field = f.text_field("#{field}_input".to_sym)
      end
    end

    control_group(
      f.label(field, :class=>"control-label"),
      form_field,
      errors: data.errors[field],
      help: option[:help]
    )
  end
end