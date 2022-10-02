class Event_Handler
    attr_accessor :current_event, :event_id


    def initialize(events: [])
        @events = events
        @event_id = -1
        @starting_likely_hood = 0.1
        @event_likely_hood = @starting_likely_hood
        @random_val = rand
        @tick_interval = 60
    end


    def create_event(tick_count)
        @random_val = rand if(tick_count % @tick_interval == 0)

        if(@current_event.nil? && @event_likely_hood > @random_val)
            @current_event = @events.sample().clone()
            @current_event.event_start = tick_count

            puts @current_event.start_text
            puts @current_event.event_start

            @event_id += 1
        end
    end


    def event_proceed(resources, tick_count)
        return resources if(@current_event.nil? || @current_event.completed)

        results = @current_event.process(resources, tick_count)

        if(@current_event.completed)
            puts @current_event.end_text 

            @current_event = nil
            @event_likely_hood = @starting_likely_hood
        end

        return results
    end
end