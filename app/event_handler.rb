class Event_Handler
    def initialize(events: [])
        @events = events
    end


    def create_event(tick_count)
        if(@current_event.nil?)
            @current_event = @events.sample().clone()
            @current_event.event_start = tick_count
        end
    end


    def event_proceed(tick_count)
        return 0 if(@current_event.nil?)

        return @current_event.output if(@current_event.complete())
    end
end