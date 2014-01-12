class Syncer
  API_TASKS_ENDPOINT = "http://localhost:3000/api/tasks"
  # @tasks = Task.deserialize_from_file('tasks.dat')
	
	def fetch
    BW::HTTP.get("http://localhost:3000/api/tasks") do |res|
       if res.ok?
				 p 'Fetch all'
         data = BW::JSON.parse( res.body.to_s )
         self.sync(data)
       end
     end
	end
	
	def create( data, remote = false )
		item = if remote
			BW::HTTP.post("#{API_TASKS_ENDPOINT}", { payload: data }) do |res|
				if res.ok?
					data = BW::JSON.parse(res.body.to_s)
				end
			end
		else
      p 'Local create'
			p data
			Task.create remoteId: data[:id], name: data[:name], completed: data[:completed], lastSyncAt: data[:lastSyncAt]
		end
	end
	
	def update( data, remote = false )
		item = if remote
			p 'update remote'
			BW::HTTP.put("#{API_TASKS_ENDPOINT}/#{data[:remoteId]}.json", { payload: { task: data } } ) do |res|
				if res.ok?
					BW::JSON.parse(res.body.to_s)
				end
			end
		else
			p 'update local'
			Task.where(:remoteId).eq(data[:id]).first.update_attributes(data)
		end
	end
	
	def delete( id, remote = false )
		item = if remote
			BW::HTTP.delete("#{API_TASKS_ENDPOINT}/#{id}") do |res|
				if res.ok?
					BW::JSON.parse(res.body.to_s)
				end
			end
		else
			Task.where(:id).eq(id).first.delete
		end		
	end
	
  protected
 
  def sync(remoteData)
    return unless remoteData.kind_of?(Array)

    for remoteItem in remoteData do
      localItem = Task.where(:remoteId).eq(remoteItem[:id]).first

      # Localitem not present
			if !localItem
				self.create( remoteItem )
			end
			
      # Convert remoteDate
			if remoteItem
				date_formatter = NSDateFormatter.alloc.init
        date_formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
				remoteDate = date_formatter.dateFromString "#{remoteItem[:lastSyncAt]}"
			end
			
            # If remoteItem is updated
      if localItem && localItem.lastSyncAt < remoteDate
        p 'init2'
        p "lokaal: #{localItem.lastSyncAt}"
        p "remote: #{remoteDate}"        
        self.update( remoteItem )
      end
            
            # If remoteItem is outdated
      if localItem && localItem.lastSyncAt > remoteDate
        
        p 'init3'
        p "lokaal: #{localItem.lastSyncAt}"
        p "remote: #{remoteDate}"
        self.update( localItem, true )
      end
    end
  end
end