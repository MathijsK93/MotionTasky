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
                                                       action:'dismissModal')
    self.navigationItem.rightBarButtonItems = [cancelButton]
    self.title = 'Nieuwe taak'
		
  end
	
	def dismissModal
		self.navigationController.dismissModalViewControllerAnimated(true)
	end

  def createTask
    
    if form.render[:name].nil?
      App.alert("U bent een naam vergeten in te vullen")
    else
  		data = { task: { name: form.render[:name] } }

      BW::HTTP.post(API_TASKS_ENDPOINT, { payload: data }) do |res|
        if res.ok?
          task = BubbleWrap::JSON.parse(res.body.to_str)
          Task.create remoteId: task[:id], name: task[:name], lastSyncAt: task[:updated_at], completed: task[:completed]
      		self.dismissModal
        elsif res.status_code.to_s =~ /40\d/
          App.alert("Er is iets fout gegaan")
        else
          p res.body
          App.alert(res.body.to_str)
        end
      end
    end
  end
end