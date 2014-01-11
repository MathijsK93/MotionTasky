class Task  
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter

  columns name:        		:string,
          remoteId:  			:string,
					completed:  		:boolean,
					lastSyncAt:  		:date,
					created_at:  		:date,
					updated_at: 		:date

	def toggle!
		self.completed = !self.completed
		self.save
	end
	
	def before_save(sender)
    # self.uuid = BW.create_uuid unless self.uuid
	end
	
	def after_save(sender)
    # Task.serialize_to_file('tasks.dat')
	end
  
	def after_delete(sender)
		Task.serialize_to_file('tasks.dat')
	end
end