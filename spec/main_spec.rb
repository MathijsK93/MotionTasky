describe "Application 'tasky'" do
  tests TasksViewController
  
  before do
    @app = UIApplication.sharedApplication
  end

  it "has one window" do
    @app.windows.size.should == 1
  end
  
  it "changes instance variable when button is tapped" do
    tap 'Annuleren'
    controller.instance_variable_get("@was_tapped").should == true
  end
  
end
