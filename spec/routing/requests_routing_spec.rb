require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RequestsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "requests", :action => "index").should == "/requests"
    end

    it "maps #new" do
      route_for(:controller => "requests", :action => "new").should == "/requests/new"
    end

    it "maps #show" do
      route_for(:controller => "requests", :action => "show", :id => "1").should == "/requests/1"
    end

    it "maps #edit" do
      route_for(:controller => "requests", :action => "edit", :id => "1").should == "/requests/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "requests", :action => "create").should == {:path => "/requests", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "requests", :action => "update", :id => "1").should == {:path =>"/requests/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "requests", :action => "destroy", :id => "1").should == {:path =>"/requests/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/requests").should == {:controller => "requests", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/requests/new").should == {:controller => "requests", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/requests").should == {:controller => "requests", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/requests/1").should == {:controller => "requests", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/requests/1/edit").should == {:controller => "requests", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/requests/1").should == {:controller => "requests", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/requests/1").should == {:controller => "requests", :action => "destroy", :id => "1"}
    end
  end
end
