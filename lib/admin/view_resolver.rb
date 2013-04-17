class Admin::ViewResolver < ::ActionView::FileSystemResolver
  def initialize default_path="admin/defaults"
    super("app/views")
    @default_path = default_path
  end

  def find_templates(name, prefix, partial, details)
    super(name, @default_path, partial, details)
  end
end
