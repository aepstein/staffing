require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuizzesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "quizzes", :action => "index").should == "/quizzes"
    end

    it "maps #new" do
      route_for(:controller => "quizzes", :action => "new").should == "/quizzes/new"
    end

    it "maps #show" do
      route_for(:controller => "quizzes", :action => "show", :id => "1").should == "/quizzes/1"
    end

    it "maps #edit" do
      route_for(:controller => "quizzes", :action => "edit", :id => "1").should == "/quizzes/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "quizzes", :action => "create").should == {:path => "/quizzes", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "quizzes", :action => "update", :id => "1").should == {:path =>"/quizzes/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "quizzes", :action => "destroy", :id => "1").should == {:path =>"/quizzes/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/quizzes").should == {:controller => "quizzes", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/quizzes/new").should == {:controller => "quizzes", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/quizzes").should == {:controller => "quizzes", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/quizzes/1").should == {:controller => "quizzes", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/quizzes/1/edit").should == {:controller => "quizzes", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/quizzes/1").should == {:controller => "quizzes", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/quizzes/1").should == {:controller => "quizzes", :action => "destroy", :id => "1"}
    end
  end
end
