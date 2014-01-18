class LoginViewController < Formotion::FormController
  API_ENDPOINT = "http://localhost:3000/api"
	
  def init
    form = Formotion::Form.new({
      sections: [{
        title: 'Inloggen met je gegevens',
        rows: [{
          title: "Emailadres",
          key: :email,
          type: :string,
          auto_correction: :no,
          auto_capitalization: :none
				},
        {
          title: "Wachtwoord",
          key: :password,
          type: :string,
          secure: true
				}],
      }, {
        rows: [{
          title: "Inloggen",
          type: :submit,
        }]
      }]
    })
    form.on_submit do
      self.login
    end
    super.initWithForm(form)
  end

  def viewDidLoad
    super
    self.title = 'Inloggen'
  end


  def login
    data = { email: form.render[:email], password: form.render[:password] }
    BW::HTTP.post(API_ENDPOINT, { payload: data }) do |res|
      if res.ok?
        p 'responseok'
        json = BubbleWrap::JSON.parse(res.body.to_str)
        p json
        self.cancel
      elsif res.status_code.to_s =~ /40\d/
        p 'login failed'
        App.alert("Inloggen mislukt")
      else
      p 'error'
        App.alert(res.error_message)
      end
    end
    
  end
end