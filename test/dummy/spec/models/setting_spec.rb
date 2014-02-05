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

# describe Goldencobra::Setting do
#   describe "changing a data_type" do
#     it "succesfully changes data_type" do
#       Goldencobra::Setting.change_data_types(data_type: "boolean")
#       Goldencobra::Setting.save
#       Goldencobra:Setting.where(value: "true").data_type.should == "boolean"
#     end
#   end
# end