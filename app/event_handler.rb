class Event_Handler
    attr_accessor :current_event, :event_id, :event_chain


    def initialize(events: [])
        @events = events
        @event_id = -1
        @starting_likely_hood = 0.01 
        @event_likely_hood = @starting_likely_hood
        @random_val = rand
        @tick_interval = 60
        @event_chain = []
        @event_graphic = []

        create_event(0, true)
    end


    def create_event(tick_count, force_create = false)
        @random_val = rand if(tick_count % @tick_interval == 0)

        if((@current_event.nil? && @event_likely_hood > @random_val) || force_create)
            @current_event = @events.sample().clone()
            @current_event.event_start = tick_count

            add_to_chain(@current_event.start_text)
            puts @current_event.event_start

            @event_id += 1
        end
    end


    def event_proceed(resources, tick_count)
        return resources if(@current_event.nil? || @current_event.completed)

        results = @current_event.process(resources, tick_count)

        if(@current_event.completed)
            add_to_chain(@current_event.end_text)
            @current_event = nil
            @event_likely_hood = @starting_likely_hood
        end

        return results
    end


    def add_to_chain(event_text)
        event_index = 1
        event_total = 0
        subs = wrap_event_chain(event_text)

        create_event_entries(subs) 
#        @event_graphic << {
#            :x => 0,
#            :y => 0,
#            :w => event_text.length() * 9.95,
#            :h => 17,
#            :path => 'sprites/green_fill_bar.png'
#        }.sprite!()

        event_total = @event_chain.length()

        @event_chain.reverse_each() do |event|
            event_offset = event_index
#            graphic = @event_graphic[event_total - event_offset]
            y_position = event_index * 20
            alpha_change = 255 * (1 - (((event_index - 1) * 20) / 255))

            event.y = y_position
            event.a = alpha_change

#            graphic.y = y_position - 18
#            graphic.a = alpha_change

            event_index += 1
        end
    end


    def wrap_event_chain(text)
        index = 0
        subs = []
        character_limit = 36
        split_count = (text.length / character_limit).ceil()

        split_count.times() do |split|
            sub_end = index + character_limit
            index += 1 if(text[index] == ' ')

            subs << text[index..sub_end]

            index = sub_end
        end

        return subs
    end


    def create_event_entries(subs)
        subs.each do |subling|
            @event_chain << {
                :x => 0,
                :y => 0,
                :size_enum => -2,
                :text => subling
            }.label!()
        end
    end


    def get_renders()
        return @event_chain
    end
end