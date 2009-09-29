require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AnswersController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "answers", :action => "index").should == "/answers"
    end

    it "maps #new" do
      route_for(:controller => "answers", :action => "new").should == "/answers/new"
    end

    it "maps #show" do
      route_for(:controller => "answers", :action => "show", :id => "1").should == "/answers/1"
    end

    it "maps #edit" do
      route_for(:controller => "answers", :action => "edit", :id => "1").should == "/answers/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "answers", :action => "create").should == {:path => "/answers", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "answers", :action => "update", :id => "1").should == {:path =>"/answers/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "answers", :action => "destroy", :id => "1").should == {:path =>"/answers/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/answers").should == {:controller => "answers", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/answers/new").should == {:controller => "answers", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/answers").should == {:controller => "answers", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/answers/1").should == {:controller => "answers", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/answers/1/edit").should == {:controller => "answers", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/answers/1").should == {:controller => "answers", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/answers/1").should == {:controller => "answers", :action => "destroy", :id => "1"}
    end
  end
end
