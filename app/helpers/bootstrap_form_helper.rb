module BootstrapFormHelper

  def control_group(label, field, options={})
    errors = options.delete(:errors)
    help = options.delete(:help)

    content_tag(:div, :class=>"control-group") do
      concat label
      controls = content_tag(:div, :class=>"controls") do
        concat field
        if (errors && errors.count >0)
          concat content_tag(:span, help.html_safe, :class=>"help-inline") if help
          concat content_tag(:span, errors.join(","), :class=>"help-inline error-help")
        else
          concat content_tag(:span, help.html_safe, :class=>"help-inline") if help
        end
      end
      concat controls
    end
  end

  def form_action(*actions)
    content_tag(:div, :class=>"form-actions") do
      actions.join("\n").html_safe
    end
  end

  def fileupload(file_field, extra=nil)
    extra ||= ""
    render :partial=>"components/bootstrap/fileupload", :locals=>{file_field: file_field, extra:extra}
  end

end
