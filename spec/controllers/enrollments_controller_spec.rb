require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EnrollmentsController do

  def mock_enrollment(stubs={})
    @mock_enrollment ||= mock_model(Enrollment, stubs)
  end

  describe "GET index" do
    it "assigns all enrollments as @enrollments" do
      Enrollment.stub!(:find).with(:all).and_return([mock_enrollment])
      get :index
      assigns[:enrollments].should == [mock_enrollment]
    end
  end

  describe "GET show" do
    it "assigns the requested enrollment as @enrollment" do
      Enrollment.stub!(:find).with("37").and_return(mock_enrollment)
      get :show, :id => "37"
      assigns[:enrollment].should equal(mock_enrollment)
    end
  end

  describe "GET new" do
    it "assigns a new enrollment as @enrollment" do
      Enrollment.stub!(:new).and_return(mock_enrollment)
      get :new
      assigns[:enrollment].should equal(mock_enrollment)
    end
  end

  describe "GET edit" do
    it "assigns the requested enrollment as @enrollment" do
      Enrollment.stub!(:find).with("37").and_return(mock_enrollment)
      get :edit, :id => "37"
      assigns[:enrollment].should equal(mock_enrollment)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created enrollment as @enrollment" do
        Enrollment.stub!(:new).with({'these' => 'params'}).and_return(mock_enrollment(:save => true))
        post :create, :enrollment => {:these => 'params'}
        assigns[:enrollment].should equal(mock_enrollment)
      end

      it "redirects to the created enrollment" do
        Enrollment.stub!(:new).and_return(mock_enrollment(:save => true))
        post :create, :enrollment => {}
        response.should redirect_to(enrollment_url(mock_enrollment))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved enrollment as @enrollment" do
        Enrollment.stub!(:new).with({'these' => 'params'}).and_return(mock_enrollment(:save => false))
        post :create, :enrollment => {:these => 'params'}
        assigns[:enrollment].should equal(mock_enrollment)
      end

      it "re-renders the 'new' template" do
        Enrollment.stub!(:new).and_return(mock_enrollment(:save => false))
        post :create, :enrollment => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested enrollment" do
        Enrollment.should_receive(:find).with("37").and_return(mock_enrollment)
        mock_enrollment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :enrollment => {:these => 'params'}
      end

      it "assigns the requested enrollment as @enrollment" do
        Enrollment.stub!(:find).and_return(mock_enrollment(:update_attributes => true))
        put :update, :id => "1"
        assigns[:enrollment].should equal(mock_enrollment)
      end

      it "redirects to the enrollment" do
        Enrollment.stub!(:find).and_return(mock_enrollment(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(enrollment_url(mock_enrollment))
      end
    end

    describe "with invalid params" do
      it "updates the requested enrollment" do
        Enrollment.should_receive(:find).with("37").and_return(mock_enrollment)
        mock_enrollment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :enrollment => {:these => 'params'}
      end

      it "assigns the enrollment as @enrollment" do
        Enrollment.stub!(:find).and_return(mock_enrollment(:update_attributes => false))
        put :update, :id => "1"
        assigns[:enrollment].should equal(mock_enrollment)
      end

      it "re-renders the 'edit' template" do
        Enrollment.stub!(:find).and_return(mock_enrollment(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested enrollment" do
      Enrollment.should_receive(:find).with("37").and_return(mock_enrollment)
      mock_enrollment.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the enrollments list" do
      Enrollment.stub!(:find).and_return(mock_enrollment(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(enrollments_url)
    end
  end

end
