class NewTaskController < Formotion::FormController
  API_TASKS_ENDPOINT = "http://localhost:3000/api/tasks"
	
  def init
    form = Formotion::Form.new({
      sections: [{
        rows: [{
          title: "Naam",
          key: :name,
          placeholder: "Naam van taak",
          type: :string,
          auto_correction: :yes,
          auto_capitalization: :none
				}],
      }, {
        rows: [{
          title: "Opslaan",
          type: :submit,
        }]
      }]
    })
    form.on_submit do
      self.createTask
    end
    super.initWithForm(form)
  end

  def viewDidLoad
    super
    cancelButton = UIBarButtonItem.alloc.initWithTitle("Annuleren",
                                                       style:UIBarButtonItemStylePlain,
                                                       target:self,
                                                       action:'cancel')
    self.navigationItem.rightBarButtonItems = [cancelButton]	 
		
    self.title = "Nieuwe taak"
  end
	
	def cancel
		self.navigationController.dismissModalViewControllerAnimated(true)
	end

  def createTask
		data = { task: { name: form.render[:name] } }
		BW::HTTP.post(API_TASKS_ENDPOINT, { payload: data }) do |response|
		  if response.ok?
        p 'responseok'
		    json = BubbleWrap::JSON.parse(response.body.to_str)
				Task.create name: form.render[:name]
		  elsif response.status_code.to_s =~ /40\d/
				p 'login failed'
		    # App.alert("Login failed") # helper provided by the kernel file in this repo.
		  else
        p 'error'
		    App.alert(response.error_message)
		  end
		end
		# Task.create(name: form.render[:name])
    # Pagee.create(pageParams)

		self.cancel
    # PagesViewControllerr.refresh
  end
	
  def cancel
    self.navigationController.dismissModalViewControllerAnimated(true)
  end
end