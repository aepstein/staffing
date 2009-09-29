require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AuthoritiesController do

  def mock_authority(stubs={})
    @mock_authority ||= mock_model(Authority, stubs)
  end

  describe "GET index" do
    it "assigns all authorities as @authorities" do
      Authority.stub!(:find).with(:all).and_return([mock_authority])
      get :index
      assigns[:authorities].should == [mock_authority]
    end
  end

  describe "GET show" do
    it "assigns the requested authority as @authority" do
      Authority.stub!(:find).with("37").and_return(mock_authority)
      get :show, :id => "37"
      assigns[:authority].should equal(mock_authority)
    end
  end

  describe "GET new" do
    it "assigns a new authority as @authority" do
      Authority.stub!(:new).and_return(mock_authority)
      get :new
      assigns[:authority].should equal(mock_authority)
    end
  end

  describe "GET edit" do
    it "assigns the requested authority as @authority" do
      Authority.stub!(:find).with("37").and_return(mock_authority)
      get :edit, :id => "37"
      assigns[:authority].should equal(mock_authority)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created authority as @authority" do
        Authority.stub!(:new).with({'these' => 'params'}).and_return(mock_authority(:save => true))
        post :create, :authority => {:these => 'params'}
        assigns[:authority].should equal(mock_authority)
      end

      it "redirects to the created authority" do
        Authority.stub!(:new).and_return(mock_authority(:save => true))
        post :create, :authority => {}
        response.should redirect_to(authority_url(mock_authority))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved authority as @authority" do
        Authority.stub!(:new).with({'these' => 'params'}).and_return(mock_authority(:save => false))
        post :create, :authority => {:these => 'params'}
        assigns[:authority].should equal(mock_authority)
      end

      it "re-renders the 'new' template" do
        Authority.stub!(:new).and_return(mock_authority(:save => false))
        post :create, :authority => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested authority" do
        Authority.should_receive(:find).with("37").and_return(mock_authority)
        mock_authority.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :authority => {:these => 'params'}
      end

      it "assigns the requested authority as @authority" do
        Authority.stub!(:find).and_return(mock_authority(:update_attributes => true))
        put :update, :id => "1"
        assigns[:authority].should equal(mock_authority)
      end

      it "redirects to the authority" do
        Authority.stub!(:find).and_return(mock_authority(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(authority_url(mock_authority))
      end
    end

    describe "with invalid params" do
      it "updates the requested authority" do
        Authority.should_receive(:find).with("37").and_return(mock_authority)
        mock_authority.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :authority => {:these => 'params'}
      end

      it "assigns the authority as @authority" do
        Authority.stub!(:find).and_return(mock_authority(:update_attributes => false))
        put :update, :id => "1"
        assigns[:authority].should equal(mock_authority)
      end

      it "re-renders the 'edit' template" do
        Authority.stub!(:find).and_return(mock_authority(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested authority" do
      Authority.should_receive(:find).with("37").and_return(mock_authority)
      mock_authority.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the authorities list" do
      Authority.stub!(:find).and_return(mock_authority(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(authorities_url)
    end
  end

end
