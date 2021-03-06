class TasksViewController < UITableViewController
  API_TASKS_ENDPOINT = "http://localhost:3000/api/tasks"
	MotionModelDataDidChangeNotification = 'MotionModelDataDidChangeNotification'
	
	def initWithNibName(name, bundle: bundle)
	  super

	  refreshButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action: 'popActionSheet')
    newTaskButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCompose, target:self, action:'addNewTask')

    self.navigationItem.leftBarButtonItems = [refreshButton]	 
    self.navigationItem.rightBarButtonItems = [newTaskButton]	 
		self.tabBarItem.image = UIImage.imageNamed "notepad"
		
    @syncer = Syncer.new
		reloadData
  
		@refreshControl = UIRefreshControl.alloc.init
		@refreshControl.addTarget self, action:'refresh', forControlEvents:UIControlEventValueChanged
		self.refreshControl = @refreshControl
    self
  end

  def viewDidLoad
    super

		self.title = 'Taken'
	
    self.tableView.dataSource = self.tableView.delegate = self
    @task_model_change_observer = App.notification_center.observe MotionModelDataDidChangeNotification do |notification|
      if notification.object.is_a?(Task)
        reloadData
      end
    end		
  end
	
  def popActionSheet
    UIActionSheet.alloc.initWithTitle('Taken opties',
    delegate: self,
    cancelButtonTitle: 'Annuleren',
    destructiveButtonTitle: 'Alle taken verwijderen',
    otherButtonTitles: 'Voltooide taken verwijderen', nil).showInView(view)
  end
  
  def actionSheet(view, clickedButtonAtIndex:buttonIndex)
    case buttonIndex
    when 0
      p 'Delete all tasks'
      for task in @tasks
        @syncer.delete(task.remoteId, true)
        task.delete
      end
    when 1
      p 'Delete completed tasks'
      for task in Task.where(:completed).eq(true)
        @syncer.delete(task.remoteId, true)
        task.delete
      end 
    end
  end
  
  def addNewTask
    @newTaskController = NewTaskController.alloc.init
    @newTaskNavigationController = UINavigationController.alloc.init
    @newTaskNavigationController.pushViewController(@newTaskController, animated:false)

    self.presentModalViewController(@newTaskNavigationController, animated:true)
  end  	

	def refresh
		@syncer.fetch
		reloadData
		@refreshControl.endRefreshing
	end
	
  def reloadData
		@tasks = Task.all
		self.tableView.reloadData	
  end
	
  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    Task.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
     cellIdentifier = self.class.name
     cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) || begin
       cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellIdentifier)
     end

     task = @tasks[indexPath.row]		 
     cell.textLabel.text = task.name
     if task.completed
       cell.textLabel.color = '#aaaaaa'.to_color
       cell.accessoryType = UITableViewCellAccessoryCheckmark
     else
       cell.textLabel.color = '#222222'.to_color
       cell.accessoryType = UITableViewCellAccessoryNone
     end
     cell
  end
	
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    task = @tasks[indexPath.row]
		Task.find(task.id).toggle!
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    if editingStyle == UITableViewCellEditingStyleDelete
      task = @tasks[indexPath.row]
      @tasks.delete(task)
      @syncer.delete(task.remoteId, true)
			
      view.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
    end
  end
	
	def tableView(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath)
		'Verwijder'
	end

  def tableView(tableView, editingStyleForRowAtIndexPath:indexPath)
    if indexPath.row == @tasks.length
      return UITableViewCellEditingStyleInsert
    else
      return UITableViewCellEditingStyleDelete
    end
  end
end
