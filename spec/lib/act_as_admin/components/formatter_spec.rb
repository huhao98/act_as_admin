require "spec_helper"

describe ActAsAdmin::Components::Formatter do

  def setup_formatter opts={}
    formatter = ActAsAdmin::Components::Formatter.new :name, opts
  end

  describe "score" do
    specify do
      formatter = setup_formatter
      action_formatter = setup_formatter :action=>:index
      format_formatter = setup_formatter :format=>:csv
      another_formatter = setup_formatter :action=>:index, :format=>:csv

      expect(formatter.score).to eq(2)
      expect(action_formatter.score).to eq(1.5)
      expect(format_formatter.score).to eq(1.5)

      expect(formatter.score :action=>:index).to eq(2)
      expect(action_formatter.score :action=>:index).to eq(3)
      expect(format_formatter.score :action=>:index).to eq(1.5)

      expect(formatter.score(:format=>:csv)).to eq(2)
      expect(action_formatter.score(:format=>:csv)).to eq(1.5)
      expect(format_formatter.score :format=>:csv).to eq(3)

      expect(formatter.score(:action=>:index, :format=>:csv)).to eq(2)
      expect(action_formatter.score(:action=>:index, :format=>:csv)).to eq(3)
      expect(format_formatter.score(:action=>:index, :format=>:csv)).to eq(3)
      expect(another_formatter.score(:action=>:index, :format=>:csv)).to eq(4)
    end
  end

  describe "value_of" do
    it "should return nested field value" do
      formatter = ActAsAdmin::Components::Formatter.new :"address.city"
      data = mock("data", :address=>{:city=>"city"}.to_ostruct)
      expect(formatter.value_of data).to eq("city")
    end
  end

end
