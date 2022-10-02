class Event
    attr_accessor :event_start, :start_text, :end_text, :completed


    def initialize(
        event_timer: 600, start_text: 'An event has started', 
        end_text: 'An event has ended', resources: {}
    )
        @event_start = 0 
        @start_text = start_text
        @end_text = end_text
        @event_timer = event_timer
        @resources = resources
        @completed = false
    end


    def process(resources, tick_count)
        ticker = tick_count - @event_start

        return resources if(ticker <= @event_timer)

        @completed = true

        @resources.entries().each do |key, value|
            resources[key].value += value
        end

        return resources
    end
end