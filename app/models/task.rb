class Task  
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter

  columns name:        		:string,
          remoteId:  			:int,
					completed:  		:boolean,
					lastSyncAt:  		:date,
					created_at:  		:date,
					updated_at: 		:date

	def toggle!
    p 'toggle completed'
		self.completed = !self.completed
		self.save
    @syncer = Syncer.new
    @syncer.update(self.attributes, true)
	end
	
	def before_save(sender)
    # self.uuid = BW.create_uuid unless self.uuid
	end
  # 
  def after_save(sender)
    Task.serialize_to_file('tasky.dat')
  end
  
  # def after_delete(sender)
  #     Task.serialize_to_file('tasks.dat')
  # end
end