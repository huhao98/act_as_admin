shared_examples "admin controller assign page variables" do |actions|

  actions.each do |options|
    action = options.delete(:action)
    verb = options.delete(:verb)
    on = options.delete(:on)
    page = options.delete(:page)
    assigned = options.delete(:assigned) || []
    not_assigned = options.delete(:not_assigned) || []
    desc = []
    desc << "#{verb} #{action}"
    desc << on if on

    describe desc.join(" ") do
      before :each do
        p = self.send("#{action}_#{on}".to_sym) if on
        send(verb, action, p)
      end

      specify("has model class"){ expect(assigns[:model]).not_to be_nil }

      specify("use #{page} page in admin config"){ expect(assigns[:page]).to eq(described_class.admin_config.pages[page])}

      assigned.each do |v|
        specify("should assign #{v}"){expect(assigns[v]).not_to be_nil}
      end

      not_assigned.each do |v|
        specify("should not assign #{v}"){expect(assigns[v]).to be_nil}
      end

    end
  end

end
