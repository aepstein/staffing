require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QualificationsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "qualifications", :action => "index").should == "/qualifications"
    end

    it "maps #new" do
      route_for(:controller => "qualifications", :action => "new").should == "/qualifications/new"
    end

    it "maps #show" do
      route_for(:controller => "qualifications", :action => "show", :id => "1").should == "/qualifications/1"
    end

    it "maps #edit" do
      route_for(:controller => "qualifications", :action => "edit", :id => "1").should == "/qualifications/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "qualifications", :action => "create").should == {:path => "/qualifications", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "qualifications", :action => "update", :id => "1").should == {:path =>"/qualifications/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "qualifications", :action => "destroy", :id => "1").should == {:path =>"/qualifications/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/qualifications").should == {:controller => "qualifications", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/qualifications/new").should == {:controller => "qualifications", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/qualifications").should == {:controller => "qualifications", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/qualifications/1").should == {:controller => "qualifications", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/qualifications/1/edit").should == {:controller => "qualifications", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/qualifications/1").should == {:controller => "qualifications", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/qualifications/1").should == {:controller => "qualifications", :action => "destroy", :id => "1"}
    end
  end
end
