class Task
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter

  columns name:        		:string,
					completed:  		:boolean,
					created_at:  		:date,
					updated_at: 		:date,
					uuid:      			:string, 
					lastSyncAt:  		:time

	def toggle!
		self.completed = !self.completed
		self.save
	end
	
	def before_save(sender)
		self.uuid = BW.create_uuid unless self.uuid
	end
	
	def after_save(sender)
		Task.serialize_to_file('tasks.dat')
	end
end