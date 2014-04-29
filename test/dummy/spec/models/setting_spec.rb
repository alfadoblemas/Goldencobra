require 'spec_helper'

describe Goldencobra::Setting do
  describe "changing a value" do
    it "successfully changes a value" do
      Goldencobra::Setting.create(title: "url", value: "www.goldencobra.de", ancestry: "goldencobra")
      Goldencobra::Setting.set_value_for_key("http://www.goldencobra.de", "goldencobra.url")
      Goldencobra::Setting.where(title: "url").first.value.should =="http://www.goldencobra.de"
    end
  end
end  

describe Goldencobra::Setting do
  it "is changed to the right data type" do
    a = Goldencobra::Setting.new
    a.value = "2012-03-05"
    a.change_data_types
    a.date_type.should == Date.parse(a.value)
  end
end