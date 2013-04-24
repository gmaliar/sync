module Sync
  module Clients
    class PubnubAdapter
      
      def setup
        require 'logger'
        require 'pubnub'
        @@callback = lambda { |message| Logger.new(STDOUT).debug(message) }
      end

      def batch_publish(*args)
        Message.batch_publish(*args)
      end

      def build_message(*args)
        Message.new(*args)
      end

      def self.callback
        @@callback
      end

      class Message

        attr_accessor :channel, :data

        def self.batch_publish(messages)
          messages.each do |message|
            message.publish
          end
        end

        def initialize(channel, data)
          @channel = channel
          @data = data
        end

        def publish
          if Sync.async?
            publish_asynchronous
          else
            publish_synchronous
          end
        end

        def publish_synchronous
          publish_pubnub
        end

        def publish_asynchronous
          publish_pubnub
        end

        def publish_pubnub
          pubnub = Pubnub.new(:publish_key => Sync.pubnub_publish_key, :subscribe_key => Sync.pubnub_subscribe_key)
          pubnub.publish(
              :channel  => @channel,
              :message  => @data,
              :callback => PubnubAdapter.callback
          )
        end
      end
    end
  end
end