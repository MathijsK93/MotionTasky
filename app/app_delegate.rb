class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
		@window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
		
		@tasky = TasksViewController.alloc.init
		@tasky.tabBarItem.image = UIImage.imageNamed "notepad"
		
		tasks_nav = UINavigationController.alloc.initWithRootViewController(@tasky)

		settings = SettingsViewController.alloc.init
		settings.tabBarItem.image = UIImage.imageNamed "cogs"	
		settings_nav = UINavigationController.alloc.initWithRootViewController(settings)

		tabController = UITabBarController.alloc.initWithNibName(nil, bundle: nil)
		tabController.viewControllers = [tasks_nav, settings_nav]

		@sync = syncDataOnStartUp()
		@window.rootViewController = tabController
		@window.makeKeyAndVisible
    true
  end
	
  def syncDataOnStartUp    
    # Create the new syncer class
    # @tasks = Task.deserialize_from_file('tasks.dat')
    # @tasky.tableView.reloadData
    @syncer = Syncer.new
    @syncer.fetch
  end
end
