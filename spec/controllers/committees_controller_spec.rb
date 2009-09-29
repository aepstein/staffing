require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommitteesController do

  def mock_committee(stubs={})
    @mock_committee ||= mock_model(Committee, stubs)
  end

  describe "GET index" do
    it "assigns all committees as @committees" do
      Committee.stub!(:find).with(:all).and_return([mock_committee])
      get :index
      assigns[:committees].should == [mock_committee]
    end
  end

  describe "GET show" do
    it "assigns the requested committee as @committee" do
      Committee.stub!(:find).with("37").and_return(mock_committee)
      get :show, :id => "37"
      assigns[:committee].should equal(mock_committee)
    end
  end

  describe "GET new" do
    it "assigns a new committee as @committee" do
      Committee.stub!(:new).and_return(mock_committee)
      get :new
      assigns[:committee].should equal(mock_committee)
    end
  end

  describe "GET edit" do
    it "assigns the requested committee as @committee" do
      Committee.stub!(:find).with("37").and_return(mock_committee)
      get :edit, :id => "37"
      assigns[:committee].should equal(mock_committee)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created committee as @committee" do
        Committee.stub!(:new).with({'these' => 'params'}).and_return(mock_committee(:save => true))
        post :create, :committee => {:these => 'params'}
        assigns[:committee].should equal(mock_committee)
      end

      it "redirects to the created committee" do
        Committee.stub!(:new).and_return(mock_committee(:save => true))
        post :create, :committee => {}
        response.should redirect_to(committee_url(mock_committee))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved committee as @committee" do
        Committee.stub!(:new).with({'these' => 'params'}).and_return(mock_committee(:save => false))
        post :create, :committee => {:these => 'params'}
        assigns[:committee].should equal(mock_committee)
      end

      it "re-renders the 'new' template" do
        Committee.stub!(:new).and_return(mock_committee(:save => false))
        post :create, :committee => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested committee" do
        Committee.should_receive(:find).with("37").and_return(mock_committee)
        mock_committee.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :committee => {:these => 'params'}
      end

      it "assigns the requested committee as @committee" do
        Committee.stub!(:find).and_return(mock_committee(:update_attributes => true))
        put :update, :id => "1"
        assigns[:committee].should equal(mock_committee)
      end

      it "redirects to the committee" do
        Committee.stub!(:find).and_return(mock_committee(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(committee_url(mock_committee))
      end
    end

    describe "with invalid params" do
      it "updates the requested committee" do
        Committee.should_receive(:find).with("37").and_return(mock_committee)
        mock_committee.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :committee => {:these => 'params'}
      end

      it "assigns the committee as @committee" do
        Committee.stub!(:find).and_return(mock_committee(:update_attributes => false))
        put :update, :id => "1"
        assigns[:committee].should equal(mock_committee)
      end

      it "re-renders the 'edit' template" do
        Committee.stub!(:find).and_return(mock_committee(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested committee" do
      Committee.should_receive(:find).with("37").and_return(mock_committee)
      mock_committee.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the committees list" do
      Committee.stub!(:find).and_return(mock_committee(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(committees_url)
    end
  end

end
