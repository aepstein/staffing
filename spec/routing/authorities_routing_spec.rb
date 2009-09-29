require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AuthoritiesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "authorities", :action => "index").should == "/authorities"
    end

    it "maps #new" do
      route_for(:controller => "authorities", :action => "new").should == "/authorities/new"
    end

    it "maps #show" do
      route_for(:controller => "authorities", :action => "show", :id => "1").should == "/authorities/1"
    end

    it "maps #edit" do
      route_for(:controller => "authorities", :action => "edit", :id => "1").should == "/authorities/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "authorities", :action => "create").should == {:path => "/authorities", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "authorities", :action => "update", :id => "1").should == {:path =>"/authorities/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "authorities", :action => "destroy", :id => "1").should == {:path =>"/authorities/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/authorities").should == {:controller => "authorities", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/authorities/new").should == {:controller => "authorities", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/authorities").should == {:controller => "authorities", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/authorities/1").should == {:controller => "authorities", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/authorities/1/edit").should == {:controller => "authorities", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/authorities/1").should == {:controller => "authorities", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/authorities/1").should == {:controller => "authorities", :action => "destroy", :id => "1"}
    end
  end
end
