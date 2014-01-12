class SettingsViewController < UIViewController
	
	def initWithNibName(name, bundle: bundle)
	  super

		self.view.backgroundColor = UIColor.whiteColor
	
    newTaskButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target:self, action:nil)
    self.navigationItem.leftBarButtonItems = [newTaskButton]
		self.tabBarItem.image = UIImage.imageNamed "cogs"	

    self
  end

  def viewDidLoad
    super
		self.title = 'Instellingen'

  end
end
