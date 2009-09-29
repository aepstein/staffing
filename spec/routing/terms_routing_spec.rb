require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TermsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "terms", :action => "index").should == "/terms"
    end

    it "maps #new" do
      route_for(:controller => "terms", :action => "new").should == "/terms/new"
    end

    it "maps #show" do
      route_for(:controller => "terms", :action => "show", :id => "1").should == "/terms/1"
    end

    it "maps #edit" do
      route_for(:controller => "terms", :action => "edit", :id => "1").should == "/terms/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "terms", :action => "create").should == {:path => "/terms", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "terms", :action => "update", :id => "1").should == {:path =>"/terms/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "terms", :action => "destroy", :id => "1").should == {:path =>"/terms/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/terms").should == {:controller => "terms", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/terms/new").should == {:controller => "terms", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/terms").should == {:controller => "terms", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/terms/1").should == {:controller => "terms", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/terms/1/edit").should == {:controller => "terms", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/terms/1").should == {:controller => "terms", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/terms/1").should == {:controller => "terms", :action => "destroy", :id => "1"}
    end
  end
end
