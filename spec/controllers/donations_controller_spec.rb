describe DonationsController do

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Donation.any_instance.stub(:valid?).and_return(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Donation.any_instance.stub(:valid?).and_return(true)
    post :create
    assert_response :redirect
  end

end
