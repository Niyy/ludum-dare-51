class Event
    attr_accessor :start_tick


    def initialize(event_timer: 600, start_text: 'An event has started', end_text: 'An event has ended', resources: {})
        @start_text = start_text
        @end_text = end_text
        @event_timer = event_timer
        @resources = resources
    end


    def complete(tick_count)
        end_tick = tick_count - @start_tick

        @resources if(ticker >= @event_timer)
    end
end