class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
		@window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
		
		tasks = TasksViewController.alloc.init		
		tasks_nav = UINavigationController.alloc.initWithRootViewController(tasks)

		settings = SettingsViewController.alloc.init
		settings_nav = UINavigationController.alloc.initWithRootViewController(settings)

    #     login = LoginViewController.alloc.init
    # login_nav = UINavigationController.alloc.initWithRootViewController(login)

		tabController = UITabBarController.alloc.initWithNibName(nil, bundle: nil)
		tabController.viewControllers = [tasks_nav, settings_nav]

		@sync = syncDataOnStartUp()
		@window.rootViewController = tabController
		@window.makeKeyAndVisible
    true
  end

  def syncDataOnStartUp    
    # Create the new syncer class
    # @tasks = Task.deserialize_from_file('tasky.dat')
    # @tasky.tableView.reloadData
    @syncer = Syncer.new
    @syncer.fetch
  end
end
