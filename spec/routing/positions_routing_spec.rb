require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PositionsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "positions", :action => "index").should == "/positions"
    end

    it "maps #new" do
      route_for(:controller => "positions", :action => "new").should == "/positions/new"
    end

    it "maps #show" do
      route_for(:controller => "positions", :action => "show", :id => "1").should == "/positions/1"
    end

    it "maps #edit" do
      route_for(:controller => "positions", :action => "edit", :id => "1").should == "/positions/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "positions", :action => "create").should == {:path => "/positions", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "positions", :action => "update", :id => "1").should == {:path =>"/positions/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "positions", :action => "destroy", :id => "1").should == {:path =>"/positions/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/positions").should == {:controller => "positions", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/positions/new").should == {:controller => "positions", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/positions").should == {:controller => "positions", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/positions/1").should == {:controller => "positions", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/positions/1/edit").should == {:controller => "positions", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/positions/1").should == {:controller => "positions", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/positions/1").should == {:controller => "positions", :action => "destroy", :id => "1"}
    end
  end
end
