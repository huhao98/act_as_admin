module ParamsHelper

  class Params
    attr_reader :query_params
    def initialize(params, view_helper)
      @query_params = params
      @view_helper = view_helper
    end

    def query_url
      @view_helper.query_url(query_params)
    end

    def hidden_fields
      @view_helper.hidden_fields(query_params)
    end
  end


  # filter(:age).query_url
  # filter(:age, 10).query_url
  # order(:age, "desc").query_url
  # order(:age).query_url


  def filter(field, value=nil)
    p = query_params
    p[:f] = (p[:f] || {}).clone
    if (value.nil?)
      p[:f].except!(field)
    else
      p[:f].merge!(field =>value)
    end
    return Params.new(p, self)
  end

  def filter_value params, field
    return (params[:f] || {})[field]
  end

  def order(field, value, default=nil)
    p = query_params

    dir = order_value(p, field) || default || "asc"
    p.merge!(:o=> {field => dir})
    return Params.new(p, self)
  end

  def order_value params, field
    current = (params[:o] || {})[field]
    {"desc"=>"asc", "asc"=>"desc"}[current] unless (current.nil?)
  end

  def hidden_fields params
    cleaned_hash = params.except("action", "controller", "commit", "utf8").reject { |k, v| v.nil? }
    pairs = cleaned_hash.to_query.split(Rack::Utils::DEFAULT_SEP)
    tags = pairs.map do |pair|
      key, value = pair.split('=', 2).map { |str| Rack::Utils.unescape(str) }
      hidden_field_tag(key, value)
    end
    tags.join("\n").html_safe
  end


  def query_url params={}
    if (@query_result)
      self.instance_exec(params, &@query_result.path_proc)
    else
      url_for(params)
    end
  end

  def query_params
    if @query_result
      @query_result.query_params.merge(params.except(:f, :o))
    else
      params.clone
    end
  end

end
