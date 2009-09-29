require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RequestsController do

  def mock_request(stubs={})
    @mock_request ||= mock_model(Request, stubs)
  end

  describe "GET index" do
    it "assigns all requests as @requests" do
      Request.stub!(:find).with(:all).and_return([mock_request])
      get :index
      assigns[:requests].should == [mock_request]
    end
  end

  describe "GET show" do
    it "assigns the requested request as @request" do
      Request.stub!(:find).with("37").and_return(mock_request)
      get :show, :id => "37"
      assigns[:request].should equal(mock_request)
    end
  end

  describe "GET new" do
    it "assigns a new request as @request" do
      Request.stub!(:new).and_return(mock_request)
      get :new
      assigns[:request].should equal(mock_request)
    end
  end

  describe "GET edit" do
    it "assigns the requested request as @request" do
      Request.stub!(:find).with("37").and_return(mock_request)
      get :edit, :id => "37"
      assigns[:request].should equal(mock_request)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created request as @request" do
        Request.stub!(:new).with({'these' => 'params'}).and_return(mock_request(:save => true))
        post :create, :request => {:these => 'params'}
        assigns[:request].should equal(mock_request)
      end

      it "redirects to the created request" do
        Request.stub!(:new).and_return(mock_request(:save => true))
        post :create, :request => {}
        response.should redirect_to(request_url(mock_request))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved request as @request" do
        Request.stub!(:new).with({'these' => 'params'}).and_return(mock_request(:save => false))
        post :create, :request => {:these => 'params'}
        assigns[:request].should equal(mock_request)
      end

      it "re-renders the 'new' template" do
        Request.stub!(:new).and_return(mock_request(:save => false))
        post :create, :request => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested request" do
        Request.should_receive(:find).with("37").and_return(mock_request)
        mock_request.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :request => {:these => 'params'}
      end

      it "assigns the requested request as @request" do
        Request.stub!(:find).and_return(mock_request(:update_attributes => true))
        put :update, :id => "1"
        assigns[:request].should equal(mock_request)
      end

      it "redirects to the request" do
        Request.stub!(:find).and_return(mock_request(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(request_url(mock_request))
      end
    end

    describe "with invalid params" do
      it "updates the requested request" do
        Request.should_receive(:find).with("37").and_return(mock_request)
        mock_request.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :request => {:these => 'params'}
      end

      it "assigns the request as @request" do
        Request.stub!(:find).and_return(mock_request(:update_attributes => false))
        put :update, :id => "1"
        assigns[:request].should equal(mock_request)
      end

      it "re-renders the 'edit' template" do
        Request.stub!(:find).and_return(mock_request(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested request" do
      Request.should_receive(:find).with("37").and_return(mock_request)
      mock_request.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the requests list" do
      Request.stub!(:find).and_return(mock_request(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(requests_url)
    end
  end

end
