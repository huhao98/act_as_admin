module ActAsAdmin::Builder

  class Page
    include ::ActAsAdmin::Builder::Dsl
    attr_accessor :partial
    field :headers, :inherit=>true, :key=> true, :proc => :text
    field :data_columns, :inherit=>true, :key=> true, :proc => :content

    field :actions, :key=> true, :proc => :url
    field :data_actions, :key=> true, :proc => :url
    field :breadcrumbs, :inherit=>true, :key=> true, :proc => :link
  end
  
end
