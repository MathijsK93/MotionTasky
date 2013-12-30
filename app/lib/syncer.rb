class Syncer
  API_TASKS_ENDPOINT = "http://localhost:3000/api/tasks"
  # @tasks = Task.deserialize_from_file('tasks.dat')
	
	def fetch
    BW::HTTP.get("http://localhost:3000/api/tasks.json") do |res|
       if res.ok?
				 p 'hooi'
         parsedData = BW::JSON.parse( res.body.to_s )
         self.sync( parsedData )
       end
     end
	end
	
	def create( data, remote = false )
		p 'created'
		item = if remote
			BW::HTTP.post("#{API_TASKS_ENDPOINT}", { payload: data }) do |res|
				if res.ok?
					BW::JSON.parse(res.body.to_s)
				end
			end
		else
			p data
			Task.create(data)
		end
	end
	
	def update( data, remote = false )

		item = if remote
			p 'update remote'
			p data.id
			BW::HTTP.put("#{API_TASKS_ENDPOINT}/#{data.id}.json", { payload: { task: data } } ) do |res|
				if res.ok?
					p res.body.to_s
					BW::JSON.parse(res.body.to_s)
				end
			end
		else
			p 'update local'
			Task.find(data[:id]).update_attributes(data)
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
      localItem = Task.find(remoteItem[:id])
						
			if !localItem
				p 'init1'
				self.create( remoteItem )
			end
			
			if remoteItem				
				date_formatter = NSDateFormatter.alloc.init
				date_formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
				remoteDate = date_formatter.dateFromString "#{remoteItem[:lastSyncAt]}" if remoteItem
			end
			
			if localItem && localItem.lastSyncAt < remoteDate
				p 'init2'
				p "lokaal: #{localItem.lastSyncAt}"
				p "remote: #{remoteDate}"				
				self.update( remoteItem )
			end
			if localItem && localItem.lastSyncAt > remoteDate
				
				p 'init3'
				p "lokaal: #{localItem.lastSyncAt}"
				p "remote: #{remoteDate}"
				self.update( localItem, true )
			end
    end
  end
end