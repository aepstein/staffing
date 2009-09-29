require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommitteesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "committees", :action => "index").should == "/committees"
    end

    it "maps #new" do
      route_for(:controller => "committees", :action => "new").should == "/committees/new"
    end

    it "maps #show" do
      route_for(:controller => "committees", :action => "show", :id => "1").should == "/committees/1"
    end

    it "maps #edit" do
      route_for(:controller => "committees", :action => "edit", :id => "1").should == "/committees/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "committees", :action => "create").should == {:path => "/committees", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "committees", :action => "update", :id => "1").should == {:path =>"/committees/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "committees", :action => "destroy", :id => "1").should == {:path =>"/committees/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/committees").should == {:controller => "committees", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/committees/new").should == {:controller => "committees", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/committees").should == {:controller => "committees", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/committees/1").should == {:controller => "committees", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/committees/1/edit").should == {:controller => "committees", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/committees/1").should == {:controller => "committees", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/committees/1").should == {:controller => "committees", :action => "destroy", :id => "1"}
    end
  end
end
